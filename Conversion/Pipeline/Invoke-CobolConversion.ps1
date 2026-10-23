<#
.SYNOPSIS
  SSG-4 pipeline step: convert one expanded COBOL program to a .LionSource with CobolConverterConsole.
.DESCRIPTION
  Stages the COBOL text as <PROGRAM-ID>.TXT (the converter names the object after the file, Bug 14),
  writes a .settings file, runs the console from the work folder (its prefab fallback is
  <current directory>\LionRoutines, MT-033 item 4) and reports exit code, errors and warnings.
  The console returns 0 for warnings and 1 for errors; it is run with redirected output, never
  through a pipe, so the exit code is real.
.EXAMPLE
  pwsh -NoProfile -File Invoke-CobolConversion.ps1 -CobolFile E:\Repos\ssg4-work\expanded\CFH-COPY_ASCII__VIRM01_CO.cob -Name CFH-COPY_ASCII__VIRM01_CO
#>
param(
  # One expanded COBOL file, or several: all of them become programs of ONE application / ONE .LionSource.
  [Parameter(Mandatory = $true)][String[]]$CobolFile,
  [Parameter(Mandatory = $true)][String]$Name,
  # Optional PROGRAM-ID per file (same order as -CobolFile), for example ASSURFED-UTILIT-CFH-COPY-ASCII.
  [String[]]$ProgramId,
  # Application name inside LionDev; default is -Name without punctuation. Underscores are kept when given here.
  [String]$AppName,
  [String]$WorkDir = 'E:\Repos\ssg4-work\cobol',
  [String]$Console = 'E:\Repos\amt-go-net-ref\_build\CobolConverterConsole\CobolConverterConsole.exe',
  [String]$RndMigration = 'E:\Repos\amt-go-net-ref\Migration',
  [String]$MacrosFile = (Join-Path $PSScriptRoot '..\..\Trial3\macros\ssg-stub.macros.xml'),
  # LionDev crashes on Options ("un-representable DateTime") when BaseYear is 0 (AMT172 Bug 13; their fix value was 1900).
  # Default 1957, the LINC base year given by the project owner; only the year can be stored here.
  [Int32]$BaseYear = 1957
)

$ErrorActionPreference = 'Stop'
foreach ($p in $CobolFile + $Console + $MacrosFile) { if (-not (Test-Path -LiteralPath $p)) { throw "Not found: $p" } }
if ($ProgramId -and $ProgramId.Count -ne $CobolFile.Count) { throw '-ProgramId needs one entry per -CobolFile.' }

$enc = [System.Text.Encoding]::GetEncoding(1252)
$programs = for ($i = 0; $i -lt $CobolFile.Count; $i++) {
  $text = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $CobolFile[$i]), $enc)
  $m = [regex]::Match($text, "PROGRAM-ID\.\s*'?([A-Za-z0-9-]+)'?", 'IgnoreCase')
  if (-not $m.Success) { throw "No PROGRAM-ID in $($CobolFile[$i])" }
  $id = if ($ProgramId) { $ProgramId[$i].ToUpperInvariant() } else { $m.Groups[1].Value.ToUpperInvariant() }
  if ($ProgramId) { $text = $text.Remove($m.Index, $m.Length).Insert($m.Index, "PROGRAM-ID. '$id'") }
  [pscustomobject]@{ Id = $id; Text = $text }
}
$dup = $programs.Id | Group-Object | Where-Object Count -gt 1
if ($dup) { throw "Duplicate program names: $($dup.Name -join ', '). Give each file its own -ProgramId." }
$programId = $programs.Id -join ','

$routines = Join-Path $WorkDir 'LionRoutines'
if (-not (Test-Path $routines)) {
  New-Item -ItemType Directory -Path $routines -Force | Out-Null
  Copy-Item (Join-Path $RndMigration 'CobolPrefab\*'), (Join-Path $RndMigration 'LionRoutines\*') -Destination $routines
}

$inDir = Join-Path $WorkDir "in\$Name"
foreach ($d in $inDir, (Join-Path $WorkDir 'out'), (Join-Path $WorkDir 'logs')) {
  if (Test-Path $d) { if ($d -eq $inDir) { Remove-Item $d -Recurse -Force } }
  New-Item -ItemType Directory -Path $d -Force | Out-Null
}
foreach ($pr in $programs) { [System.IO.File]::WriteAllText((Join-Path $inDir "$($pr.Id).TXT"), $pr.Text, $enc) }

$outFile = Join-Path $WorkDir "out\$Name.LionSource"
foreach ($f in $outFile, ($outFile -replace '\.LionSource$', '.xrf'), (Join-Path $WorkDir "out\$($Name)_Import.txt")) {
  if (Test-Path $f) { Remove-Item $f -Force }
}

$settings = [ordered]@{
  AppList = @([ordered]@{
    AppName = $(if ($AppName) { $AppName.ToUpperInvariant() } else { ($Name -replace '[^A-Za-z0-9]', '').ToUpperInvariant() }); IsSelected = $true
    BatchDir = $inDir; OnlineDir = ''; SubProgDir = ''; CopyDir = ''; GlobalCopyDir = ''
    OutputFile = $outFile; InitialTransaction = ''; ChangeFile = ''; FormDir = ''; ScreenFileName = ''; PsbDir = ''
  })
  Env = 4096; UseCobolAnalyser = $true; OutputInAscii = $true; OutputLowercase = $false
  IncludeUnusedCopies = $false; AutoDetectSubprogs = $false; DontIncludeFolderNames = $true
  WriteAppDef = $true; WriteGlbFileDefs = $true; WriteInsertables = $true; WritePerformables = $true
  WriteGlobalDefs = $true; WriteCreatedObjects = $true
  LogToFile = $true; LogFile = (Join-Path $WorkDir "logs\$Name.log"); LogVerboseLevelFile = 0; LogVerboseLevelGui = 2
  PrecompilerMacrosFile = (Resolve-Path $MacrosFile).Path
  Cobol85 = $false; Cobol68 = $false; Unicode = $false; EbcdicSort = $false; IgnDecCommaPic = $false
  NumFillerToAlpha = $false; ConvertHexValues = $false; RecLockFilesToDB = $false; Interrupts = $false
  TargetVs = $false; TestMatchScreenDefs = $false; DbsList = @(); UserName = ''; TransCodeFile = ''
  VarDefsDir = ''; RepLayoutDir = ''; CustomerSettingsFile = ''; LayoutSuffix = ''; CursorQueryPrefix = ''
  AmtDatabaseType = 0; SequenceNumberAction = 0; CbSequenceNumbers = 0; LineNumbers = 0; BaseYear = $BaseYear
}
$settingsFile = Join-Path $WorkDir "$Name.settings"
$settings | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $settingsFile -Encoding utf8

$stdout = Join-Path $WorkDir "logs\$Name.stdout.txt"
$stderr = Join-Path $WorkDir "logs\$Name.stderr.txt"
$proc = Start-Process -FilePath $Console -ArgumentList "`"$settingsFile`"" -WorkingDirectory $WorkDir `
  -RedirectStandardOutput $stdout -RedirectStandardError $stderr -NoNewWindow -Wait -PassThru

$log = Get-Content -LiteralPath $stdout
$count = { param($label) $x = $log | Select-String "^${label}:\s*(\d+)" | Select-Object -Last 1; if ($x) { [int]$x.Matches[0].Groups[1].Value } else { $null } }
[pscustomobject]@{
  Name      = $Name
  ProgramId = $programId
  Exit      = $proc.ExitCode
  Errors    = & $count 'Errors'
  Warnings  = & $count 'Warnings'
  OutBytes  = if (Test-Path $outFile) { (Get-Item $outFile).Length } else { 0 }
  FirstError = ($log | Select-String '^\s*ERROR:' | Select-Object -First 1).Line
  OutFile   = $outFile
}
