# LOADIS/UNLOADIS via CFH-COPY-GN + index writer (MT-043): deploy the hand-off into the 4 converted skeletons and write
# CC script job SSG4_LOADIS_CASES. Per layout (ASCII 204/6,8 and MULTI 200/164,26): S = the static LOADIS program,
# L = the LOADIS call through the hand-off (same files, other qualifier), U = the UNLOADIS call on L's output.
# Check-LoadisCc.ps1 compares L with S (DAT, .Index apart from the qualifier in the path) and U with the references.
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$utility = Split-Path $PSScriptRoot
$gn = Split-Path $utility
. "$gn\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = "$($ge.GenericWork)\LOADIS"
$scripts = $ge.ScriptRoot
$x = $ge.ExtractPath
$cards = "$($ge.SgsCards)\calls"
$ref = $ge.MockRef
$r = @()
foreach ($s in @(@('UTILIT_LOADIS_ASCII', 'LOADIS'), @('UTILIT_LOADIS_MULTI', 'LOADIS'), @('UTILIT_UNLOADIS_ASCII', 'UNLOADIS'), @('UTILIT_UNLOADIS_MULTI', 'UNLOADIS'))) {
  $d = & "$gn\Deploy-GnSkeleton.ps1" -Skeleton $s[0] -ParmScript "$utility\gen\LoadisParm.ps1" -Call "Invoke-LoadisHandoff -Mode $($s[1])"
  $r += "$($d.Skeleton).ps1 hand-off deployed, parse errors: $($d.ParseErrors)"
}
$sets = @(
  @{ Tag = 'A'; Static = 'ASSURFED-UTILIT-LOADIS-ASCII'; Skel = 'ASCII'; Len = 204; Off = 6; KLen = 8; In = 'B010SINAUTCL'; InData = "$ref\LOADIS_ASCII-UNLOADIS_ASCII\B010SINAUTCL.bin"; Out = 'OUTCLOA49'
     LCard = 'ASSURFED_F999RUN_CLOA49__L141.sgs'; UCard = 'ASSURFED_F999RUN_CLOA43__L473.sgs'; UIn = 'FSCR001ATO'; UOut = 'OUT' }
  @{ Tag = 'M'; Static = 'ASSURFED-UTILIT-LOADIS-MULTI'; Skel = 'MULTI'; Len = 200; Off = 164; KLen = 26; In = 'INVIGA50'; InData = "$ref\LOADIS_MULTI-UNLOADIS_MULTI\INVIGA50.bin"; Out = 'F006GRS'
     LCard = 'ASSURFED_F999RUN_VIGA50__L129.sgs'; UCard = 'ASSURFED_F999RUN_VIGA50__L45.sgs'; UIn = 'F006GRS'; UOut = 'OUTVIGA50' }
)
New-Item -ItemType Directory -Force "$x\P`$SGS" | Out-Null
$body = foreach ($t in $sets) {
  $q0 = "LDS$($t['Tag'])0"; $q1 = "LDS$($t['Tag'])1"; $q2 = "LDS$($t['Tag'])2"
  foreach ($q in $q0, $q1, $q2) {
    New-Item -ItemType Directory -Force "$x\$q" | Out-Null
    Get-ChildItem "$x\$q" -File | Remove-Item -Force
    Copy-Item $t['InData'] "$x\$q\$($t['In'])" -Force
  }
  Copy-Item "$cards\$($t['LCard'])" "$x\P`$SGS\LDL$($t['Tag'])" -Force
  Copy-Item "$cards\$($t['UCard'])" "$x\P`$SGS\LDU$($t['Tag'])" -Force
  "  Msg `"`" (`"LOADIS case S$($t['Tag']): static $($t['Static'])`")"
  "  Qual `"D`" `"$q0`""
  "  Asg `"A`" (`"$($t['In'])`")"
  "  Delete `"C`" (`"$($t['Out'])`")"
  "  Asg `"P, U`" (`"$($t['Out'])`")"
  "  Xqt `"`" (`"$($t['Static'])`")"
  "  Free `"`" (`"$($t['In'])`")"
  "  Free `"`" (`"$($t['Out'])`")"
  "  Msg `"`" (`"LOADIS case L$($t['Tag']): LOADIS call via CFH-COPY-GN + index`")"
  "  Qual `"D`" `"$q1`""
  "  Asg `"A`" (`"$($t['In'])`")"
  "  Delete `"C`" (`"$($t['Out'])`")"
  "  Asg `"P, U`" (`"$($t['Out'])`")"
  "  Invoke-Ssg -Options `"IA`" -Skeleton `"../../ASSURFED_UTILIT/UTILIT_LOADIS_$($t['Skel'])`" -SgsFile `"P```$SGS\LDL$($t['Tag'])`""
  "  Xqt `"`" (`"TPF```$.LOADIS`")"
  "  Msg `"`" (`"LOADIS case L$($t['Tag']): program done`")"
  "  Msg `"`" (`"index after the program: `" + `$global:AmtFile.FileExists(`$global:LoadisIndexFc))"
  "  Free `"`" (`"$($t['In'])`")"
  "  Msg `"`" (`"LOADIS case U$($t['Tag']): UNLOADIS call via CFH-COPY-GN`")"
  if ($t['UIn'] -ne $t['Out']) { "  Use (`"$($t['UIn'])`") `"$($t['Out'])`"" }
  "  Delete `"C`" (`"$($t['UOut'])`")"
  "  Asg `"P, U`" (`"$($t['UOut'])`")"
  "  Invoke-Ssg -Options `"IA`" -Skeleton `"../../ASSURFED_UTILIT/UTILIT_UNLOADIS_$($t['Skel'])`" -SgsFile `"P```$SGS\LDU$($t['Tag'])`""
  "  Xqt `"`" (`"TPF```$.UNLOADIS`")"
  "  Free `"`" (`"$($t['UOut'])`")"
  "  Free `"`" (`"$($t['Out'])`")"
  "  Msg `"`" (`"index after Free: `" + `$global:AmtFile.FileExists(`$global:LoadisIndexFinal))"
  ''
}
$job = @"
# SSG-4 (MT-043): LOADIS/UNLOADIS through CFH-COPY-GN + the hand-off's index writer, next to the static LOADIS (Prepare-LoadisCc.ps1).
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
`$AmtSettingsFile = Join-Path `$PSScriptRoot '..\..\Settings\AmtSettings.xml'

Set-Jobname "LOADTEST"
Initialize `$AmtSettingsFile

Try {
  Qual "" "LOADTEST"
$($body -join "`r`n")
  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " `$_
} Finally {
  Cleanup `$false
}
"@
$path = "$scripts\ASSURFED_F999\RUN\SSG4_LOADIS_CASES.ps1"
[IO.File]::WriteAllText($path, $job)
$e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$null, [ref]$e)
$r += "SSG4_LOADIS_CASES.ps1 written, parse errors: $($e.Count)"
$r | Out-File "$work\prepare-cc.txt"
$r
