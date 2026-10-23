<#
.SYNOPSIS
  SSG-4 pipeline driver: builds ONE LionDev application (one .LionSource) with one program per SSG skeleton.
.DESCRIPTION
  For each program: takes its first exported @SSG call (the cards of that call), expands the converted skeleton with them
  (Invoke-SsgExpansion.ps1), names the program ASSURFED-UTILIT-<KEY> (the first release used ASSURFED_UTILIT_<NAME>; the
  C# class and DLL come out as ASSURFED_UTILIT_<KEY>), then converts all expansions together (Invoke-CobolConversion.ps1).
  Writes <WorkDir>\selection.csv: which runstream call each program was built from, so the choice is on record.
  Which call a skeleton is built from is a choice, not a fact: several skeletons are called many times with different
  layouts (CFH-COPY_ASCII has 47 calls). How Federale picks the matching one at run time is not yet known.
.EXAMPLE
  pwsh -NoProfile -File Build-AppLionSource.ps1
  pwsh -NoProfile -File Build-AppLionSource.ps1 -Programs CFH-COPY_ASCII,RECAP -CallIndex 2
#>
param(
  [String[]]$Programs = @('CFH-COPY_ASCII', 'FUSBA2_ASCII', 'LECTIS_ASCII', 'LOADIS_ASCII', 'RECAP', 'UNLOADIS_ASCII'),
  [String]$AppName = 'AFBUS_2200COBOL',
  [String]$CardsDir = 'E:\Repos\ssg4-work\sgs-cards',
  [String]$WorkDir = 'E:\Repos\ssg4-work\app',
  [Int32]$CallIndex = 1,
  [Int32]$BaseYear = 1957,
  # folder with converted skeletons (<key>.ps1); default is SsgConverter\Examples\Output
  [String]$SkeletonDir = ''
)
$ErrorActionPreference = 'Stop'
$Programs = @($Programs | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$here = $PSScriptRoot
New-Item -ItemType Directory -Force "$WorkDir\expanded" | Out-Null
$calls = Import-Csv (Join-Path $CardsDir 'sgs-calls.csv') | Where-Object { $_.Converted -eq 'True' }

$cobs = @(); $ids = @(); $sel = @()
"[{0}] Expanding {1} program(s), one call each..." -f (Get-Date -Format 'HH:mm:ss'), $Programs.Count
for ($i = 0; $i -lt $Programs.Count; $i++) {
  $key = $Programs[$i]
  $tag = "[{0}] ({1}/{2}) {3}" -f (Get-Date -Format 'HH:mm:ss'), ($i + 1), $Programs.Count, $key
  $rows = @($calls | Where-Object ProgramKey -eq $key)
  if ($rows.Count -lt $CallIndex) { Write-Warning "$key : only $($rows.Count) exported call(s); skipped"; continue }
  $call = $rows[$CallIndex - 1]
  $id = 'ASSURFED-UTILIT-' + ($key -replace '_', '-')
  $cob = Join-Path $WorkDir "expanded\$id.cob"
  "$tag : expanding..."
  $expandArgs = @('-NoProfile', '-File', (Join-Path $here 'Invoke-SsgExpansion.ps1'), '-Program', $key, '-CardFile', (Join-Path $CardsDir $call.CardFile),
    '-OutFile', $cob, '-RunInfo', "$($call.RunId),$($call.RunAccount),$($call.RunProject)")
  if ($SkeletonDir) { $expandArgs += '-ScriptPath', (Join-Path $SkeletonDir "$key.ps1") }
  $sw = [Diagnostics.Stopwatch]::StartNew()
  $out = pwsh @expandArgs 2>&1
  $sw.Stop()
  if ($LASTEXITCODE -ne 0 -or -not (Test-Path $cob)) {
    "$tag : FAILED after {0:N1}s" -f $sw.Elapsed.TotalSeconds
    Write-Warning "$key : expansion failed ($(($out | Out-String).Trim().Split("`n")[0])); skipped"
    continue
  }
  "$tag : done in {0:N1}s" -f $sw.Elapsed.TotalSeconds
  $cobs += $cob; $ids += $id
  $sel += [pscustomobject]@{ ProgramId = $id; Skeleton = $key; Runstream = $call.Runstream; Line = $call.Line; RunId = $call.RunId; Cards = $call.Cards; CallsAvailable = $rows.Count; CallIndex = $CallIndex }
}
if (-not $cobs) { throw 'Nothing to convert.' }
$sel | Export-Csv (Join-Path $WorkDir 'selection.csv') -NoTypeInformation -Encoding utf8

"[{0}] Converting {1} program(s) together via CobolConverterConsole (one call, can take a while)..." -f (Get-Date -Format 'HH:mm:ss'), $cobs.Count
$conv = pwsh -NoProfile -Command "& '$(Join-Path $here 'Invoke-CobolConversion.ps1')' -CobolFile @('$($cobs -join "','")') -ProgramId @('$($ids -join "','")') -Name '$AppName' -AppName '$AppName' -WorkDir '$WorkDir\cobol' -BaseYear $BaseYear | ConvertTo-Json -Compress" | ConvertFrom-Json
"[{0}] Converter finished." -f (Get-Date -Format 'HH:mm:ss')
$sel | Format-Table ProgramId, Runstream, Line, CallsAvailable -AutoSize | Out-String -Width 200
"Application : $AppName   programs: $($ids.Count)"
"Converter   : exit $($conv.Exit), errors $($conv.Errors), warnings $($conv.Warnings), {0:N0} bytes" -f $conv.OutBytes
if ($conv.FirstError) { "First error  : $($conv.FirstError)" }
"LionSource  : $($conv.OutFile)"
