# FUSBA (MT-043): deploy the generic FUSBA hand-off into both converted skeletons (FUSBA, FUSBA2) and one CC script job
# that runs the 9 test cases as runstream steps (Asg/Use/Invoke-Ssg/Xqt/Free, the way R&D's converted runstreams call
# FUSBA), each under its own qualifier FUSB<case> (several cases share file names), and stage inputs and cards.
# Delivery of ASSURFED_UTILIT_FUSBA_GN.dll is separate (Deliver-GnPrograms.ps1).
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$utility = Split-Path $PSScriptRoot
$gn = Split-Path $utility
. "$gn\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = "$($ge.GenericWork)\FUSBA"
$scripts = $ge.ScriptRoot
$x = $ge.ExtractPath
$root = "$work\cases"
. "$utility\check\FusbaModel.ps1"
. "$PSScriptRoot\FusbaCases.ps1"
$r = @()
# Skeletons: hand-off first, then return (the generic program does not use the expansion).
foreach ($v in 'FUSBA', 'FUSBA2') {
  $r += (& "$gn\Deploy-GnSkeleton.ps1" -Skeleton "UTILIT_$($v)_ASCII" -ParmScript "$utility\gen\FusbaParm.ps1" -Call "Invoke-FusbaHandoff -Variant $v" -Target "$scripts\ASSURFED_UTILIT" | ForEach-Object { "$($_.Skeleton).ps1 hand-off deployed, parse errors: $($_.ParseErrors)" })
}

New-Item -ItemType Directory -Force "$x\P`$SGS" | Out-Null
$body = foreach ($case in $FusbaCases.Keys) {
  $p = Read-FusbaParm (Get-Content "$work\parm\$($FusbaCases[$case]).parm")
  $q = "FUSB$case"
  New-Item -ItemType Directory -Force "$x\$q" | Out-Null
  Get-ChildItem "$x\$q" -File | Remove-Item -Force
  foreach ($i in $p.Ins) { Copy-Item "$root\$case\input\$($i[0])" "$x\$q\$($i[0])" -Force }
  Copy-Item "$root\$case\cards.sgs" "$x\P`$SGS\FUSBA$case" -Force
  $sk = if ($FusbaCases[$case] -like 'FUSBA2_*') { 'UTILIT_FUSBA2_ASCII' } else { 'UTILIT_FUSBA_ASCII' }
  "  Msg `"`" (`"FUSBA case $case ($($FusbaCases[$case]))`")"
  "  Qual `"D`" `"$q`""
  foreach ($i in $p.Ins) { "  Asg `"A`" (`"$($i[0])`")" }
  foreach ($o in $p.Outs) { "  Delete `"C`" (`"$($o[0])`")"; "  Asg `"P, U`" (`"$($o[0])`")" }
  "  Invoke-Ssg -Options `"IA`" -Skeleton `"../../ASSURFED_UTILIT/$sk`" -SgsFile `"P```$SGS\FUSBA$case`""
  "  Xqt `"`" (`"TPF```$.FUSBA`")"
  foreach ($i in $p.Ins) { "  Free `"`" (`"$($i[0])`")" }
  foreach ($o in $p.Outs) { "  Free `"`" (`"$($o[0])`")" }
  ''
}
$job = @"
# SSG-4 (MT-043): the generic FUSBA program on 9 test cases, one runstream-style step each (Prepare-FusbaCc.ps1).
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
`$AmtSettingsFile = Join-Path `$PSScriptRoot '..\..\Settings\AmtSettings.xml'

Set-Jobname "FUSBATEST"
Initialize `$AmtSettingsFile

Try {
  Qual "" "FUSBATEST"
$($body -join "`r`n")
  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " `$_
} Finally {
  Cleanup `$false
}
"@
[IO.File]::WriteAllText("$scripts\ASSURFED_F999\RUN\SSG4_FUSBA_CASES.ps1", $job)
$ccCases = foreach ($case in $FusbaCases.Keys) {
  foreach ($o in (Read-FusbaParm (Get-Content "$work\parm\$($FusbaCases[$case]).parm")).Outs) { [pscustomobject]@{ Case = $case; Actual = "$x\FUSB$case\$($o[0])"; Expected = "$root\$case\expected\$($o[0])" } }
}
$ccCases | ConvertTo-Json | Set-Content "$work\cc-cases.json"
$e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile("$scripts\ASSURFED_F999\RUN\SSG4_FUSBA_CASES.ps1", [ref]$null, [ref]$e)
$r += "SSG4_FUSBA_CASES.ps1 written, $($FusbaCases.Count) steps, parse errors: $($e.Count)"
$r += Get-ChildItem "$x\FUSB*" -Directory | ForEach-Object { '{0}: {1}' -f $_.Name, ((Get-ChildItem $_.FullName -File | ForEach-Object { '{0} {1:N0} B' -f $_.Name, $_.Length }) -join ', ') }
$r | Out-File "$work\prepare-cc.txt"
$r
