<#
.SYNOPSIS
  Reusable "Build" step for an SsgConverter source fix (replaces _scratch\Build-FixN.ps1).
.DESCRIPTION
  Copies SsgConverter\Source (SsgConverter + _deps) into _scratch\fix-<FixId>\src, runs -EditScript
  against that copy (the script receives -SrcDir and makes its own Edit-SourceFile/ReplaceOnce calls -
  import ConverterFixLib.psm1 for those helpers), then dotnet-builds the scratch SsgConverter.csproj.
  Only the patch content is one-off per fix (the -EditScript); this plumbing is shared by every fix.
  Writes the full edit/build output to files under the workspace and prints a short summary.
.EXAMPLE
  pwsh -NoProfile -File New-ConverterFix.ps1 -FixId T3-035 -EditScript E:\Repos\SsgTrial\_scratch\fix-T3-035\Edit.ps1
#>
param(
  [Parameter(Mandatory)][String]$FixId,
  [Parameter(Mandatory)][String]$EditScript,
  [String]$Repo = 'E:\Repos\SsgTrial'
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $EditScript)) { throw "Edit script not found: $EditScript" }

$work = Join-Path $Repo "_scratch\fix-$FixId"
$srcDir = Join-Path $work 'src'
New-Item -ItemType Directory -Force -Path $srcDir | Out-Null
robocopy (Join-Path $Repo 'SsgConverter\Source\SsgConverter') (Join-Path $srcDir 'SsgConverter') /E /XD bin obj /NFL /NDL /NJH /NJS | Out-Null
robocopy (Join-Path $Repo 'SsgConverter\Source\_deps') (Join-Path $srcDir '_deps') /E /NFL /NDL /NJH /NJS | Out-Null

$editLog = Join-Path $work 'edit.log'
$editOk = $true
try {
  & $EditScript -SrcDir $srcDir *>&1 | Out-File $editLog
} catch {
  ($_ | Out-String) | Out-File $editLog -Append
  $editOk = $false
}
"Workspace : $work"
"Edit log  : $editLog"
if (-not $editOk) { "Edit: FAILED - see $editLog"; return }

$proj = Join-Path $srcDir 'SsgConverter\SsgConverter.csproj'
$buildLog = Join-Path $work 'build.log'
Write-Host ("[{0}] dotnet build..." -f (Get-Date -Format 'HH:mm:ss'))
dotnet build $proj -c Debug --nologo *> $buildLog
Write-Host ("[{0}] Build finished." -f (Get-Date -Format 'HH:mm:ss'))
$ok = Select-String -Path $buildLog -Pattern 'Build succeeded' -Quiet
"Build log : $buildLog"
if ($ok) { "Build: OK" } else { "Build: FAILED - see $buildLog" }
