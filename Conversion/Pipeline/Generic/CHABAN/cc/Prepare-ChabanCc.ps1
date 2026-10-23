# CHABAN (MT-043): expected outputs (ChabanModel.ps1), deploy the hand-off into both converted skeletons, and one CC
# script job SSG4_CHABAN_CASES (one runstream-style step per case under qualifier CHB<case>: Invoke-Ssg, Xqt .CHABAN,
# data images). Writes cc-cases.json for Test-CcJob.ps1. Delivery is separate (Deliver-GnPrograms.ps1).
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$utility = Split-Path $PSScriptRoot
$gn = Split-Path $utility
. "$gn\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = "$($ge.GenericWork)\CHABAN"
$scripts = $ge.ScriptRoot
$x = $ge.ExtractPath
$root = "$work\expected"
$cardsDir = $ge.SgsCards
. "$utility\check\ChabanModel.ps1"
. "$PSScriptRoot\ChabanCases.ps1"
$calls = @(Import-Csv "$($ge.WorkRoot)\allcalls\expanded\CHABAN_ASCII-expansion.csv") + @(Import-Csv "$($ge.WorkRoot)\allcalls\expanded\CHAB100_ASCII-expansion.csv")
$r = @()
foreach ($v in 'CHABAN', 'CHAB100') {
  $d = & "$gn\Deploy-GnSkeleton.ps1" -Skeleton "UTILIT_$($v)_ASCII" -ParmScript "$utility\gen\ChabanParm.ps1" -Call "Invoke-ChabanHandoff -Variant $v"
  $r += "$($d.Skeleton).ps1 hand-off deployed, parse errors: $($d.ParseErrors)"
}
New-Item -ItemType Directory -Force "$x\P`$SGS" | Out-Null
$esc = { param($s) $s.Replace('`', '``').Replace('"', '`"').Replace('$', '`$') }
$cc = @()
$body = foreach ($case in $ChabanCases.Keys) {
  $c = $ChabanCases[$case]
  $p = Read-ChabanParm (Get-Content "$work\parm\$($c.Parm).parm")
  $call = $c.Parm -replace '^CHAB(AN|100)_'
  $q = "CHB$case"
  New-Item -ItemType Directory -Force "$root\$case\expected", "$x\$q" | Out-Null
  Get-ChildItem "$x\$q" -File | Remove-Item -Force
  Copy-Item (Join-Path $cardsDir ($calls | Where-Object Call -eq $call | Select-Object -First 1).CardFile) "$x\P`$SGS\CHAB$case" -Force
  $n = Invoke-ChabanModel $p ([String[]]$c.Lines) "$root\$case\expected\$($p.OutName)"
  $r += '{0,-5} {1,-24} len {2,4} card {3,3} records {4} x {5} cards; {6} data images -> {7} record(s)' -f $case, $call, $p.Len, $p.Card, $p.Records, $p.PerRecord, $c.Lines.Count, $n
  $cc += [pscustomobject]@{ Case = $case; Actual = "$x\$q\$($p.OutName)"; Expected = "$root\$case\expected\$($p.OutName)" }
  $sk = if ($c.Parm -like 'CHAB100_*') { 'UTILIT_CHAB100_ASCII' } else { 'UTILIT_CHABAN_ASCII' }
  "  Msg `"`" (`"CHABAN case $case ($call)`")"
  "  Qual `"D`" `"$q`""
  "  Delete `"C`" (`"$($p.OutName)`")"
  "  Asg `"P, U`" (`"$($p.OutName)`")"
  "  Invoke-Ssg -Options `"IA`" -Skeleton `"../../ASSURFED_UTILIT/$sk`" -SgsFile `"P```$SGS\CHAB$case`""
  "  Xqt `"`" (`".CHABAN`")"
  foreach ($l in $c.Lines) { "  DataLineOrNoStatement (`"$(& $esc $l)`")" }
  "  Free `"`" (`"$($p.OutName)`")"
  ''
}
$job = @"
# SSG-4 (MT-043): the generic CHABAN program on $($ChabanCases.Count) test cases, one runstream-style step each (Prepare-ChabanCc.ps1).
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
`$AmtSettingsFile = Join-Path `$PSScriptRoot '..\..\Settings\AmtSettings.xml'

Set-Jobname "CHABTEST"
Initialize `$AmtSettingsFile

Try {
  Qual "" "CHABTEST"
$($body -join "`r`n")
  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " `$_
} Finally {
  Cleanup `$false
}
"@
[IO.File]::WriteAllText("$scripts\ASSURFED_F999\RUN\SSG4_CHABAN_CASES.ps1", $job)
$e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile("$scripts\ASSURFED_F999\RUN\SSG4_CHABAN_CASES.ps1", [ref]$null, [ref]$e)
$r += "SSG4_CHABAN_CASES.ps1 written, $($ChabanCases.Count) steps, parse errors: $($e.Count)"
$cc | ConvertTo-Json | Set-Content "$work\cc-cases.json"
$r | Out-File "$work\prepare-cc.txt"
$r
