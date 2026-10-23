# SSG-4 (MT-043) SCAN group, print programs: inputs, model print text (PrintModels.ps1), the SCAN and TAPELD hand-offs
# deployed into the converted skeletons, and one CC script job SSG4_SCANGRP_PRINTS: per case one runstream-style step
# (Invoke-Ssg, Xqt as the runstream) and, for reference cases, the static reference program on the same input right
# after it (CloneReports set by hand). Writes cc-prints.json for Test-CcPrints.ps1. Delivery is separate.
param([String]$Environment = 'CC-Trial', [Switch]$NoDeploy)
$ErrorActionPreference = 'Stop'
$utility = Split-Path $PSScriptRoot
$gn = Split-Path $utility
. "$gn\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = "$($ge.GenericWork)\SCANGROUP"
$scripts = $ge.ScriptRoot
$x = $ge.ExtractPath
$root = "$work\cases"
$prints = $ge.PrintPath
Remove-Item "$x\PRINTCAP" -Recurse -Force -ErrorAction SilentlyContinue
$cards = $ge.SgsCards
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
. "$PSScriptRoot\PrintModels.ps1"
$r = @()
if (-not $NoDeploy) {
  $d = & "$gn\Deploy-GnSkeleton.ps1" -Skeleton 'UTILIT_SCAN_ASCII' -ParmScript "$gn\SCAN\gen\ScanParm.ps1" -Call 'Invoke-ScanHandoff' -Target "$scripts\ASSURFED_UTILIT"
  $r += "$($d.Skeleton).ps1 hand-off deployed, parse errors: $($d.ParseErrors)"
  $d = & "$gn\Deploy-GnSkeleton.ps1" -Skeleton 'UTILIT_TAPELD_ASCII' -ParmScript "$gn\TAPELD\gen\TapeldParm.ps1" -Call 'Invoke-TapeldHandoff' -Target "$scripts\ASSURFED_UTILIT"
  $r += "$($d.Skeleton).ps1 hand-off deployed, parse errors: $($d.ParseErrors)"
}
$chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-/'
$rnd = [Random]::new(2026102150)
$txt = { param($n) -join (1..$n | ForEach-Object { $chars[$rnd.Next($chars.Length)] }) }
$recs = { param($n, $len) foreach ($i in 1..$n) { ('R{0:D4}' -f $i) + (& $txt ($len - 5)) } }
# Case: skeleton, call (sgs-calls Call id), records, reference program (or ''), Xqt as the runstream, Hdg.
$cases = [ordered]@{
  S1 = @{ Sk = 'SCAN'; Call = '-d_VIRD36_MJ_L292'; Recs = @(& $recs 23 304) + @('SHORT RECORD') + @(& $recs 2 304); Ref = 'ASSURFED_UTILIT_SCAN_RA'; Xqt = 'TPF$.SCAN' }
  S2 = @{ Sk = 'SCAN'; Call = 'PBDA04_L132'; Recs = @(& $recs 14 900); Ref = 'ASSURFED_UTILIT_SCAN_RB'; Xqt = 'TPF$.SCAN' }
  S3 = @{ Sk = 'SCAN'; Call = 'VIES01_L202'; Recs = @(& $recs 4 80); Ref = ''; Xqt = 'TPF$.SCAN' }
  S4 = @{ Sk = 'SCAN'; Call = 'CCSA14_L76'; Recs = @(& $recs 5 300); Ref = ''; Xqt = 'TPF$.SCAN' }
  T1 = @{ Sk = 'TAPELD'; Call = 'PBDA04_L805'; Recs = @(& $recs 120 80); Ref = 'ASSURFED_UTILIT_TAPELD_RA'; Xqt = 'TPF$.'; Hdg = 'P     CHANGEMENT COMBINAISON IND' }
  T2 = @{ Sk = 'TAPELD'; Call = 'VIRA12_PI_L590'; Recs = @(& $recs 53 114); Ref = 'ASSURFED_UTILIT_TAPELD_RB'; Xqt = 'TPF$.'; Hdg = 'P     VIRA12' }
  T3 = @{ Sk = 'TAPELD'; Call = 'PBDA04_L339'; Recs = @(& $recs 10 900); Ref = ''; Xqt = 'TPF$.'; Hdg = 'P     MULTIPLES COUCHE HIST ENCOURS' }
  T4 = @{ Sk = 'TAPELD'; Call = '-d_VIRD50_PI_L579'; Recs = @(& $recs 5 114); Ref = ''; Xqt = 'TPF$.'; Hdg = 'P     VIRD50' }
}
$calls = @(Import-Csv "$cards\sgs-calls.csv" | Where-Object ProgramKey -in 'SCAN_ASCII', 'TAPELD_ASCII')
$esc = { param($v) $v.Replace('`', '``').Replace('"', '`"').Replace('$', '`$') }
$cc = @()
New-Item -ItemType Directory -Force "$x\P`$SGS" | Out-Null
$body = foreach ($case in $cases.Keys) {
  $c = $cases[$case]
  $parmFile = "$($ge.GenericWork)\$($c.Sk)\parm\$($c.Call).parm"
  $parm = [IO.File]::ReadAllLines($parmFile, $latin1)
  $id = { param($cf) $cf -replace '^calls\\ASSURFED_F999RUN', '' -replace '\.sgs$', '' -replace '__', '_' -replace '^_', '' }
  $call = $calls | Where-Object { (& $id $_.CardFile) -eq $c.Call } | Select-Object -First 1
  if (-not $call) { throw "$case : call $($c.Call) not found" }
  $inName = (Get-Content (Join-Path $cards $call.CardFile) | Where-Object { $_ -match '^\s*INPUT\s' } | Select-Object -First 1) -replace '^\s*INPUT\s+([^,\s]+).*$', '$1'
  $q = "SG$case"
  New-Item -ItemType Directory -Force "$root\$case", "$x\$q" | Out-Null
  Get-ChildItem "$x\$q" -File | Remove-Item -Force
  [IO.File]::WriteAllBytes("$root\$case\INP", $latin1.GetBytes(($c.Recs -join "`r`n") + "`r`n"))
  Copy-Item "$root\$case\INP" "$x\$q\INP" -Force
  Copy-Item (Join-Path $cards $call.CardFile) "$x\P`$SGS\SG$case" -Force
  $model = if ($c.Sk -eq 'SCAN') { Get-ScanModelLines $parm "$root\$case\INP" } else { Get-TapeldModelLines $parm "$root\$case\INP" }
  [IO.File]::WriteAllLines("$root\$case\model.txt", [String[]]$model, $latin1)
  $r += '{0} {1,-7} {2,-18} input {3,-11} {4,3} records -> {5,4} model lines{6}' -f $case, $c.Sk, $c.Call, $inName, $c.Recs.Count, $model.Count, $(if ($c.Ref) { ", reference $($c.Ref)" } else { '' })
  $cc += [pscustomobject]@{ Case = $case; Ref = [bool]$c.Ref; Model = "$root\$case\model.txt" }
  "  Msg `"`" (`"SCAN group case $case ($($c.Sk) $($c.Call))`")"
  "  Qual `"D`" `"$q`""
  "  Asg `"A`" (`"INP`")"
  "  Use (`"$inName`") `"INP`""
  "  Invoke-Ssg -Options `"IA`" -Skeleton `"../../ASSURFED_UTILIT/UTILIT_$($c.Sk)_ASCII`" -SgsFile `"P```$SGS\SG$case`""
  # R&D writes Hdg "P     text" (all in the options: aborts, T3-046); the valid form is options + heading.
  if ($c.Hdg) { "  Hdg `"$($c.Hdg.Substring(0, 1))`" (`"$(& $esc $c.Hdg.Substring(1).Trim())`")" }
  "  Xqt `"R, W`" (`"$(& $esc $c.Xqt)`")"
  "  Save-GnPrints '$case-GN'"
  if ($c.Ref) {
    "  `$global:CloneReports = @(@(`$global:CloneReports | Where-Object { `$_ -and `$_.Clone -ne 'GNREF' }) + [pscustomobject]@{ Name = '$($c.Ref)'; Clone = 'GNREF' })"
    "  Xqt `"R, W`" (`"TPF```$.GNREF`")"
    "  Save-GnPrints '$case-REF'"
  }
  "  Free `"`" (`"INP`")"
  ''
}
$job = @"
# SSG-4 (MT-043): the generic SCAN and TAPELD programs on $($cases.Count) print cases, with static references (Prepare-ScanGroupCc.ps1).
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
`$AmtSettingsFile = Join-Path `$PSScriptRoot '..\..\Settings\AmtSettings.xml'

# Msg ends the pending Xqt (End-Xqt runs at the next statement). A program's print goes to Prints\<date>\<Xqt name>__<time>.<FD>.PRN
# and Cleanup deletes the unprinted ones at job end (RemoveNonPrintedFiles), so copy each new one now.
function Save-GnPrints([String]`$Tag) {
  Msg "" ("prints after `$Tag")
  `$cap = '$x\PRINTCAP'
  New-Item -ItemType Directory -Force `$cap | Out-Null
  foreach (`$f in @(Get-ChildItem ('$prints\' + (Get-Date -Format yyyyMMdd)) -Filter *.PRN -File -ErrorAction SilentlyContinue)) {
    if (Test-Path (Join-Path `$cap `$f.Name)) { continue }
    Copy-Item `$f.FullName `$cap
    Msg "" ("  print `$Tag `$(`$f.Name) `$(`$f.Length)")
  }
}

Set-Jobname "SCANGRP"
Initialize `$AmtSettingsFile

Try {
  Qual "" "SCANGRP"
$($body -join "`r`n")
  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " `$_
} Finally {
  Cleanup `$false
}
"@
[IO.File]::WriteAllText("$scripts\ASSURFED_F999\RUN\SSG4_SCANGRP_PRINTS.ps1", $job)
$e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile("$scripts\ASSURFED_F999\RUN\SSG4_SCANGRP_PRINTS.ps1", [ref]$null, [ref]$e)
$r += "SSG4_SCANGRP_PRINTS.ps1 written, $($cases.Count) steps, parse errors: $($e.Count)"
$cc | ConvertTo-Json | Set-Content "$work\cc-prints.json"
$r | Out-File "$work\prepare-cc.txt"
$r
