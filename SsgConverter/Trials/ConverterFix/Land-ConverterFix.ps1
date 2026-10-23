<#
.SYNOPSIS
  Reusable "Land" step for an SsgConverter source fix (replaces _scratch\Land-FixN.ps1). RUN ELEVATED.
.DESCRIPTION
  Finds every .cs under the scratch workspace's src\SsgConverter (New-ConverterFix.ps1) that differs by
  hash from the real Source\SsgConverter, backs each one up to SsgConverter\_backup\<file>.before-<FixId>,
  copies the scratch version over it, verifies the hash landed, then runs
  SsgConverter\Trials\Reconvert-And-Verify.ps1 -Rebuild -RefreshDll -UpdateGoldens.
  Source and Build files need an elevated shell to change - this script is prepared to be run, not run
  automatically.
.EXAMPLE
  pwsh -NoProfile -File Land-ConverterFix.ps1 -FixId T3-035
#>
param(
  [Parameter(Mandatory)][String]$FixId,
  [String]$Repo = 'E:\Repos\SsgTrial'
)
$ErrorActionPreference = 'Stop'
$work = Join-Path $Repo "_scratch\fix-$FixId"
$srcScratch = Join-Path $work 'src\SsgConverter'
$srcReal = Join-Path $Repo 'SsgConverter\Source\SsgConverter'
if (-not (Test-Path $srcScratch)) { throw "No scratch source at $srcScratch - run New-ConverterFix.ps1 first." }

$changed = @()
Get-ChildItem $srcScratch -Filter *.cs -Recurse | ForEach-Object {
  $rel = $_.FullName.Substring($srcScratch.Length + 1)
  $target = Join-Path $srcReal $rel
  if (-not (Test-Path $target) -or (Get-FileHash $_.FullName).Hash -ne (Get-FileHash $target).Hash) { $changed += $rel }
}
if (-not $changed) { throw 'No changed .cs files found between the scratch build and Source - nothing to land.' }

"Changed files:"
$changed | ForEach-Object { "  $_" }
foreach ($rel in $changed) {
  $target = Join-Path $srcReal $rel
  $backup = Join-Path $Repo ("SsgConverter\_backup\" + [IO.Path]::GetFileName($rel) + ".before-$FixId")
  if (Test-Path $target) { Copy-Item $target $backup -Force }
  Copy-Item (Join-Path $srcScratch $rel) $target -Force
  if ((Get-FileHash (Join-Path $srcScratch $rel)).Hash -ne (Get-FileHash $target).Hash) { throw "Source copy did not land: $rel" }
}
"Source updated: $($changed.Count) file(s)."
& (Join-Path $Repo 'SsgConverter\Trials\Reconvert-And-Verify.ps1') -Rebuild -RefreshDll -UpdateGoldens
