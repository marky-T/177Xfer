<#
.SYNOPSIS
  SSG-4 pre-flight: expand each remaining program's first real call and run the COBOL converter on it alone.
.DESCRIPTION
  For CONDIS2_ASCII, EXTEUR, SCAN_ASCII, TABAN_ASCII, TAPELD_ASCII (or -Programs): expands the converted
  skeleton with its first exported @SSG call (Invoke-SsgExpansion.ps1), then converts that ONE program alone
  (Invoke-CobolConversion.ps1 - its own LionSource, not combined into one application like Build-AppLionSource.ps1
  does for the delivery package). Runs one program at a time, in series - no background jobs.
  Full expansion/conversion logs land under -WorkDir\logs; this script itself only prints a short summary.
.EXAMPLE
  pwsh -NoProfile -File Preflight-Next5.ps1
#>
param(
  [String[]]$Programs = @('CONDIS2_ASCII', 'EXTEUR', 'SCAN_ASCII', 'TABAN_ASCII', 'TAPELD_ASCII'),
  [String]$CardsDir = 'E:\Repos\ssg4-work\sgs-cards',
  [String]$WorkDir = 'E:\Repos\SsgTrial\_scratch\preflight-next5',
  [Int32]$CallIndex = 1
)
$ErrorActionPreference = 'Stop'
$repo = 'E:\Repos\SsgTrial'
$pipeline = Join-Path $repo 'Conversion\Pipeline'
$skeletons = Join-Path $repo 'SsgConverter\Examples\Output'
$logDir = Join-Path $WorkDir 'logs'
Remove-Item $WorkDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force "$WorkDir\expanded", $logDir | Out-Null

$callsFile = Join-Path $CardsDir 'sgs-calls.csv'
if (-not (Test-Path $callsFile)) { throw "Not found: $callsFile" }
$calls = Import-Csv $callsFile | Where-Object { $_.Converted -eq 'True' }

$report = foreach ($key in $Programs) {
  $row = [ordered]@{ Program = $key; CallsAvailable = 0; ExpandOk = $false; Lines = 0; AmtMsgs = 0; ConvExit = '-'; Errors = '-'; Warnings = '-'; Defect = '' }
  $skeleton = Join-Path $skeletons "$key.ps1"
  if (-not (Test-Path $skeleton)) { $row.Defect = 'no converted skeleton'; [pscustomobject]$row; continue }

  $rows = @($calls | Where-Object ProgramKey -eq $key)
  $row.CallsAvailable = $rows.Count
  if ($rows.Count -lt $CallIndex) { $row.Defect = 'no exported call'; [pscustomobject]$row; continue }
  $call = $rows[$CallIndex - 1]

  $cob = Join-Path $WorkDir "expanded\$key.cob"
  $expLog = Join-Path $logDir "$key.expand.log"
  $runInfo = "$($call.RunId),$($call.RunAccount),$($call.RunProject)"
  Write-Host ("[{0}] {1}: expanding..." -f (Get-Date -Format 'HH:mm:ss'), $key)
  $sw = [Diagnostics.Stopwatch]::StartNew()
  pwsh -NoProfile -File (Join-Path $pipeline 'Invoke-SsgExpansion.ps1') -Program $key `
    -CardFile (Join-Path $CardsDir $call.CardFile) -OutFile $cob -RunInfo $runInfo -ScriptPath $skeleton *> $expLog
  $expExit = $LASTEXITCODE
  Write-Host ("[{0}] {1}: expansion done in {2:N1}s (exit {3})" -f (Get-Date -Format 'HH:mm:ss'), $key, $sw.Elapsed.TotalSeconds, $expExit)
  $expText = (Get-Content $expLog -Raw) -replace "`e\[[0-9;]*m", ''
  $row.Lines = [regex]::Match($expText, 'Lines\s*:\s*(\d+)').Groups[1].Value
  $row.AmtMsgs = [regex]::Match($expText, 'AmtMessages\s*:\s*(\d+)').Groups[1].Value
  $row.ExpandOk = ($expExit -eq 0)
  if ($expExit -ne 0 -or -not (Test-Path $cob)) {
    $errLine = ($expText -split "`n" | Where-Object { $_ -match 'Error\s*:' } | Select-Object -First 1)
    $row.Defect = "expansion failed: $($errLine.Trim())"
    [pscustomobject]$row; continue
  }

  $convJson = Join-Path $logDir "$key.conv.json"
  $convLog = Join-Path $logDir "$key.conv.log"
  $convScript = Join-Path $pipeline 'Invoke-CobolConversion.ps1'
  $convWork = Join-Path $WorkDir "cobol\$key"
  Write-Host ("[{0}] {1}: converting..." -f (Get-Date -Format 'HH:mm:ss'), $key)
  $sw = [Diagnostics.Stopwatch]::StartNew()
  pwsh -NoProfile -Command "& '$convScript' -CobolFile '$cob' -Name '$key' -WorkDir '$convWork' | ConvertTo-Json -Compress" > $convJson 2> $convLog
  Write-Host ("[{0}] {1}: conversion done in {2:N1}s" -f (Get-Date -Format 'HH:mm:ss'), $key, $sw.Elapsed.TotalSeconds)
  $conv = $null
  try { $conv = Get-Content $convJson -Raw | ConvertFrom-Json } catch {}
  if (-not $conv) {
    $row.Defect = "converter did not run (see $convLog)"
    [pscustomobject]$row; continue
  }
  $row.ConvExit = $conv.Exit; $row.Errors = $conv.Errors; $row.Warnings = $conv.Warnings
  if ($conv.Exit -ne 0) { $row.Defect = "converter error: $($conv.FirstError)" }
  [pscustomobject]$row
}

$reportFile = Join-Path $WorkDir 'preflight-report.csv'
$report | Export-Csv $reportFile -NoTypeInformation -Encoding utf8
$report | Format-Table Program, CallsAvailable, ExpandOk, Lines, AmtMsgs, ConvExit, Errors, Warnings -AutoSize |
  Out-File (Join-Path $WorkDir 'preflight-summary.txt')

"Full report: $reportFile"
"Per-program logs: $logDir"
$defects = $report | Where-Object { $_.Defect }
if ($defects) {
  "$($defects.Count) of $($report.Count) program(s) have a defect:"
  $defects | ForEach-Object { "  $($_.Program): $($_.Defect)" }
} else {
  "All $($report.Count) programs expanded and converted clean (0 converter errors each)."
}
