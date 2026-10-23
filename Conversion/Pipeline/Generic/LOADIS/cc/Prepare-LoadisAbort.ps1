# LOADIS INVALID KEY path (MT-043, T3-029): job SSG4_LOADIS_ABORT takes the case as its CC command-line parameter
# (UNSORTED | DUPLICATE); each run must abort with the 2200 skeleton's ERRDISQ lines. Writes abort-cases.json.
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
. "$(Split-Path (Split-Path $PSScriptRoot))\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = "$($ge.GenericWork)\LOADIS"
$scripts = $ge.ScriptRoot
$x = $ge.ExtractPath
$enc = [Text.Encoding]::GetEncoding(28591)
$recs = [Collections.Generic.List[String]]::new([String[]][IO.File]::ReadAllLines("$($ge.MockRef)\LOADIS_ASCII-UNLOADIS_ASCII\B010SINAUTCL.bin", $enc))
$unsorted = [Collections.Generic.List[String]]::new($recs); $t = $unsorted[2]; $unsorted[2] = $unsorted[3]; $unsorted[3] = $t
$dup = [Collections.Generic.List[String]]::new($recs); $dup.Insert(5, $recs[4])
$cases = @(
  [pscustomobject]@{ Case = 'UNSORTED'; Qual = 'LDXU'; Records = $unsorted; Record = 4; Key = $recs[2].Substring(6, 8) }
  [pscustomobject]@{ Case = 'DUPLICATE'; Qual = 'LDXD'; Records = $dup; Record = 6; Key = $recs[4].Substring(6, 8) }
)
foreach ($c in $cases) {
  New-Item -ItemType Directory -Force "$x\$($c.Qual)" | Out-Null
  Get-ChildItem "$x\$($c.Qual)" -File | Remove-Item -Force
  [IO.File]::WriteAllBytes("$x\$($c.Qual)\B010SINAUTCL", $enc.GetBytes((($c.Records | ForEach-Object { "$_`r`n" }) -join '')))
}
Copy-Item "$($ge.SgsCards)\calls\ASSURFED_F999RUN_CLOA49__L141.sgs" "$x\P`$SGS\LDXC" -Force
$job = @"
# SSG-4 (MT-043): LOADIS with keys out of order; must abort like the skeleton's ERRDISQ (Prepare-LoadisAbort.ps1).
param([ValidateSet('UNSORTED', 'DUPLICATE')][String]`$Case = 'UNSORTED')
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
`$AmtSettingsFile = Join-Path `$PSScriptRoot '..\..\Settings\AmtSettings.xml'

Set-Jobname "LOADABRT"
Initialize `$AmtSettingsFile

Try {
  Qual "" "LOADABRT"
  `$q = if (`$Case -eq 'UNSORTED') { 'LDXU' } else { 'LDXD' }
  Msg "" ("LOADIS-ABORT case `$Case")
  Qual "D" `$q
  Asg "A" ("B010SINAUTCL")
  Delete "C" ("OUTCLOA49")
  Asg "P, U" ("OUTCLOA49")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_LOADIS_ASCII" -SgsFile "P```$SGS\LDXC"
  Xqt "" ("TPF```$.LOADIS")
  Msg "" ("LOADIS-ABORT case `$Case NOT STOPPED")
  Free "" ("B010SINAUTCL")
  Free "" ("OUTCLOA49")
  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " `$_
} Finally {
  Cleanup `$false
}
"@
$path = "$scripts\ASSURFED_F999\RUN\SSG4_LOADIS_ABORT.ps1"
[IO.File]::WriteAllText($path, $job)
$e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$null, [ref]$e)
$cases | Select-Object Case, Qual, Record, Key | ConvertTo-Json | Set-Content "$work\abort-cases.json"
$cases | ForEach-Object { '{0,-9} {1}: expect INVALID KEY at record {2}, key {3}' -f $_.Case, $_.Qual, $_.Record, $_.Key }
"SSG4_LOADIS_ABORT.ps1 written, parse errors: $($e.Count)"
