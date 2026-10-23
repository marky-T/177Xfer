# CONDIS2 (MT-043): test inputs and expected outputs (CondisModel.ps1), deploy the hand-off into the converted skeleton,
# and one CC script job SSG4_CONDIS_CASES (one runstream-style step per case under qualifier CON<case>: Use FILEIN /
# FILEOUT, Invoke-Ssg, Xqt TPF$.CONDIS2). Writes cc-cases.json for Test-CcJob.ps1. Delivery is separate.
param([String]$Environment = 'CC-Trial', [Switch]$NoDeploy)
$ErrorActionPreference = 'Stop'
$utility = Split-Path $PSScriptRoot
$gn = Split-Path $utility
. "$gn\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = "$($ge.GenericWork)\CONDIS2"
$scripts = $ge.ScriptRoot
$x = $ge.ExtractPath
$root = "$work\cases"
$cardsDir = $ge.SgsCards
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
. "$utility\check\CondisModel.ps1"
. "$PSScriptRoot\CondisCases.ps1"
$calls = @(Import-Csv "$($ge.WorkRoot)\allcalls\expanded-fix\CONDIS2_ASCII-expansion.csv")
$r = @()
if (-not $NoDeploy) {
  $d = & "$gn\Deploy-GnSkeleton.ps1" -Skeleton 'UTILIT_CONDIS2_ASCII' -ParmScript "$utility\gen\CondisParm.ps1" -Call 'Invoke-CondisHandoff' -Target "$scripts\ASSURFED_UTILIT"
  $r += "$($d.Skeleton).ps1 hand-off deployed, parse errors: $($d.ParseErrors)"
}
New-Item -ItemType Directory -Force "$x\P`$SGS" | Out-Null
$cc = @()
$n = 0
$body = foreach ($case in $CondisCases.Keys) {
  $c = $CondisCases[$case]
  $p = Read-CondisParm (Get-Content "$work\parm\$($c.Call).parm" -Encoding Latin1)
  $rnd = [Random]::new(20261021 + $n++)
  $recs = @(& $c.Make $p $rnd)
  $q = "CON$case"
  New-Item -ItemType Directory -Force "$root\$case\input", "$root\$case\expected", "$x\$q" | Out-Null
  Get-ChildItem "$x\$q" -File | Remove-Item -Force
  [IO.File]::WriteAllBytes("$root\$case\input\INP", $latin1.GetBytes(($recs -join "`r`n") + "`r`n"))
  Copy-Item "$root\$case\input\INP" "$x\$q\INP" -Force
  Copy-Item (Join-Path $cardsDir ($calls | Where-Object Call -eq $c.Call | Select-Object -First 1).CardFile) "$x\P`$SGS\COND$case" -Force
  $m = Invoke-CondisModel $p "$root\$case\input\INP" "$root\$case\expected\OUTP"
  $r += '{0,-4} {1,-16} {2,4} -> {3,4}, groups {4,2}: read {5}, written {6}, dropped {7}' -f $case, $c.Call, $p.In, $p.Out, $p.Groups.Count, $m.Read, $m.Written, $m.Dropped
  $cc += [pscustomobject]@{ Case = $case; Actual = "$x\$q\OUTP"; Expected = "$root\$case\expected\OUTP" }
  "  Msg `"`" (`"CONDIS2 case $case ($($c.Call))`")"
  "  Qual `"D`" `"$q`""
  "  Delete `"C`" (`"OUTP`")"
  "  Asg `"A`" (`"INP`")"
  "  Use (`"FILEIN`") `"INP`""
  "  Asg `"P, U`" (`"OUTP`")"
  "  Use (`"FILEOUT`") `"OUTP`""
  "  Invoke-Ssg -Options `"I`" -Skeleton `"../../ASSURFED_UTILIT/UTILIT_CONDIS2_ASCII`" -SgsFile `"P```$SGS\COND$case`""
  "  Xqt `"`" (`"TPF```$.CONDIS2`")"
  "  Free `"`" (`"INP`")"
  "  Free `"`" (`"OUTP`")"
  ''
}
$job = @"
# SSG-4 (MT-043): the generic CONDIS2 program on $($CondisCases.Count) test cases, one runstream-style step each (Prepare-CondisCc.ps1).
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
`$AmtSettingsFile = Join-Path `$PSScriptRoot '..\..\Settings\AmtSettings.xml'

Set-Jobname "CONDTEST"
Initialize `$AmtSettingsFile

Try {
  Qual "" "CONDTEST"
$($body -join "`r`n")
  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " `$_
} Finally {
  Cleanup `$false
}
"@
[IO.File]::WriteAllText("$scripts\ASSURFED_F999\RUN\SSG4_CONDIS_CASES.ps1", $job)
$e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile("$scripts\ASSURFED_F999\RUN\SSG4_CONDIS_CASES.ps1", [ref]$null, [ref]$e)
$r += "SSG4_CONDIS_CASES.ps1 written, $($CondisCases.Count) steps, parse errors: $($e.Count)"
$cc | ConvertTo-Json | Set-Content "$work\cc-cases.json"
$r | Out-File "$work\prepare-cc.txt"
$r
