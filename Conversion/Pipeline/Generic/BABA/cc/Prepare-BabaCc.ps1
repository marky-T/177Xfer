# BABA (MT-043): deploy the generic BABA hand-off and one CC script job that runs the 7 test cases as runstream steps
# (Asg/Use/Invoke-Ssg/Xqt/Free, the way R&D's converted runstreams call BABA), and stage their inputs and cards.
# Delivery of ASSURFED_UTILIT_BABA_GN.dll is separate (Deliver-GnPrograms.ps1).
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$utility = Split-Path $PSScriptRoot
$gn = Split-Path $utility
. "$gn\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = "$($ge.GenericWork)\BABA"
$scripts = $ge.ScriptRoot
$x = $ge.ExtractPath
$root = "$work\cases"
. "$utility\check\BabaModel.ps1"
$r = @()
# Skeleton: hand-off first, then return (the generic program does not use the expansion).
$null = & "$gn\Deploy-GnSkeleton.ps1" -Skeleton UTILIT_BABA_ASCII -ParmScript "$utility\gen\BabaParm.ps1" -Call 'Invoke-BabaHandoff' -Target "$scripts\ASSURFED_UTILIT"

# One script job, one step per case; files under qualifier BABATEST so nothing else is touched.
$cases = [ordered]@{ E1 = '2PPJ11_L74'; R2 = '-d_AFID01_L76'; AM1 = '-d_AFPD03_L94'; RM2 = '-d_EXPD05_OP_L54'; C2 = '-d_VIRD13_MJ_L48'; RB2 = 'PAIJ01_PP_L69'; E19 = 'SINM05_L211' }
New-Item -ItemType Directory -Force "$x\BABATEST", "$x\P`$SGS" | Out-Null
Get-ChildItem "$x\BABATEST" -File | Remove-Item -Force
$body = foreach ($case in $cases.Keys) {
  $p = Read-BabaParm (Get-Content "$work\parm\$($cases[$case]).parm")
  Copy-Item "$root\$case\input\$($p.InName)" "$x\BABATEST\$($p.InName)" -Force
  Copy-Item "$root\$case\cards.sgs" "$x\P`$SGS\BABA$case" -Force
  "  Msg `"`" (`"BABA case $case ($($cases[$case]))`")"
  "  Asg `"A`" (`"$($p.InName)`")"
  foreach ($o in $p.Outs) { "  Delete `"C`" (`"$($o[0])`")"; "  Asg `"P, U`" (`"$($o[0])`")" }
  "  Invoke-Ssg -Options `"IA`" -Skeleton `"../../ASSURFED_UTILIT/UTILIT_BABA_ASCII`" -SgsFile `"P```$SGS\BABA$case`""
  "  Xqt `"`" (`"TPF```$.BABA`")"
  "  Free `"`" (`"$($p.InName)`")"
  foreach ($o in $p.Outs) { "  Free `"`" (`"$($o[0])`")" }
  ''
}
$job = @"
# SSG-4 (MT-043): the generic BABA program on 7 test cases, one runstream-style step each (Prepare-BabaCc.ps1).
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
`$AmtSettingsFile = Join-Path `$PSScriptRoot '..\..\Settings\AmtSettings.xml'

Set-Jobname "BABATEST"
Initialize `$AmtSettingsFile

Try {
  Qual "" "BABATEST"
$($body -join "`r`n")
  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " `$_
} Finally {
  Cleanup `$false
}
"@
[IO.File]::WriteAllText("$scripts\ASSURFED_F999\RUN\SSG4_BABA_CASES.ps1", $job)
$ccCases = foreach ($case in $cases.Keys) {
  foreach ($o in (Read-BabaParm (Get-Content "$work\parm\$($cases[$case]).parm")).Outs) { [pscustomobject]@{ Case = $case; Actual = "$x\BABATEST\$($o[0])"; Expected = "$root\$case\expected\$($o[0])" } }
}
$ccCases | ConvertTo-Json | Set-Content "$work\cc-cases.json"
$e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile("$scripts\ASSURFED_F999\RUN\SSG4_BABA_CASES.ps1", [ref]$null, [ref]$e)
$r += "SSG4_BABA_CASES.ps1 written, $($cases.Count) steps, parse errors: $($e.Count)"
$r += Get-ChildItem "$x\BABATEST" -File | ForEach-Object { 'staged BABATEST\{0} {1:N0} B' -f $_.Name, $_.Length }
$r | Out-File "$work\prepare-cc.txt"
$r
