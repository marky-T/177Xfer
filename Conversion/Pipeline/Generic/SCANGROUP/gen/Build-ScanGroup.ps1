# SSG-4 (MT-043) SCAN group: one LionSource with the three generic programs (CONDIS2-GN, SCAN-GN, TAPELD-GN) and six
# test-only static reference programs, each the expansion of one real call renamed:
#   CONDIS2-RV VIRJ01_UE_L850 (34 CASEs, CONST, OTHERWISE)   CONDIS2-RD AUPA02_MJ_L68 (D24, D68)
#   SCAN-RA    -d_VIRD36_MJ_L292 (304, no IF)                SCAN-RB    PBDA04_L132 (900, IF R < 10; the landed T3-045 expansion has it)
#   TAPELD-RA  PBDA04_L805 (80, 3 fields, 2 titles)          TAPELD-RB  VIRA12_PI_L590 (114, 7 fields, 7 titles)
# TAPELD expansions come from Test-TapeldParm.ps1 (titles' spaces as '~', T3-028), turned back into spaces here.
# -RefsOnly writes the reference sources and returns {Id, File} objects (Invoke-GnPipeline -Stage Build makes the reference LionSource).
param([String]$Environment = 'CC-Trial', [Switch]$RefsOnly)
$ErrorActionPreference = 'Stop'
$genericDir = Split-Path (Split-Path $PSScriptRoot)
. "$genericDir\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$x = "$($ge.WorkRoot)\allcalls\expanded-fix"
$xScan = $ge.Expanded
$g = "$($ge.GenericWork)\SCANGROUP"
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
New-Item -ItemType Directory -Force "$g\ref" | Out-Null
function New-Ref([String]$From, [String]$IdPattern, [String]$Name, [ScriptBlock]$Fix = { param($t) $t }) {
  $t = [IO.File]::ReadAllText($From, $latin1)
  if (([regex]::Matches($t, $IdPattern)).Count -ne 1) { throw "$Name : PROGRAM-ID not found once in $From" }
  $t = [regex]::Replace($t, $IdPattern, "PROGRAM-ID. 'ASSURFED-UTILIT-$Name'.")
  $t = & $Fix $t
  $f = "$g\ref\ASSURFED-UTILIT-$Name.cob"
  [IO.File]::WriteAllText($f, $t, $latin1)
  $f
}
$refs = [ordered]@{}
$refs['CONDIS2-RV'] = New-Ref "$x\CONDIS2_ASCII__VIRJ01_UE_L850.cob" 'PROGRAM-ID\.\s+CONDIS2\.' 'CONDIS2-RV'
$refs['CONDIS2-RD'] = New-Ref "$x\CONDIS2_ASCII__AUPA02_MJ_L68.cob" 'PROGRAM-ID\.\s+CONDIS2\.' 'CONDIS2-RD'
$refs['SCAN-RA'] = New-Ref "$xScan\SCAN_ASCII__-d_VIRD36_MJ_L292.cob" 'PROGRAM-ID\.\s+SCAN\.' 'SCAN-RA'
$refs['SCAN-RB'] = New-Ref "$xScan\SCAN_ASCII__PBDA04_L132.cob" 'PROGRAM-ID\.\s+SCAN\.' 'SCAN-RB'
$tilde = { param($t) $n = ([regex]::Matches($t, '~')).Count; $o = [regex]::Replace($t, "VALUE\s+'[^']*'", { param($m) $m.Value.Replace('~', ' ') }); if (([regex]::Matches($o, '~')).Count) { throw 'tilde outside VALUE' }; $o }
$refs['TAPELD-RA'] = New-Ref "$($ge.GenericWork)\TAPELD\expanded\PBDA04_L805.cob" "PROGRAM-ID\.\s+'CFH-COPY'\." 'TAPELD-RA' $tilde
$refs['TAPELD-RB'] = New-Ref "$($ge.GenericWork)\TAPELD\expanded\VIRA12_PI_L590.cob" "PROGRAM-ID\.\s+'CFH-COPY'\." 'TAPELD-RB' $tilde
if ($RefsOnly) { foreach ($k in $refs.Keys) { [pscustomobject]@{ Id = "ASSURFED-UTILIT-$k"; File = $refs[$k] } }; return }

$gn = [ordered]@{
  'CONDIS2-GN' = "$genericDir\CONDIS2\gen\ASSURFED-UTILIT-CONDIS2-GN.cob"
  'SCAN-GN'    = "$genericDir\SCAN\gen\ASSURFED-UTILIT-SCAN-GN.cob"
  'TAPELD-GN'  = "$genericDir\TAPELD\gen\ASSURFED-UTILIT-TAPELD-GN.cob"
}
# T3-040: every generic input FD must be varying with maximum 4001 (Deliver-GnPrograms checks the generated C# too).
foreach ($k in $gn.Keys) { if ((Get-Content $gn[$k] -Raw) -notmatch 'VARYING IN SIZE FROM 1 TO 4001') { throw "$k : input FD is not 1 TO 4001" } }
$files = @($gn.Values) + @($refs.Values)
$ids = @($gn.Keys) + @($refs.Keys) | ForEach-Object { "ASSURFED-UTILIT-$_" }
Push-Location $g
try {
  & "$genericDir\..\Invoke-CobolConversion.ps1" -CobolFile $files -ProgramId $ids -Name SCANGRP1 -AppName AFBUS_2200COBOL -WorkDir "$g\work1" *> "$g\convert1.log"
} finally { Pop-Location }
Get-Content "$g\convert1.log" | Where-Object { $_ -match '^(Name|Exit|Errors|Warnings|FirstError|OutFile)\s*:' }
Get-Content "$g\work1\logs\SCANGRP1.stdout.txt" | Select-String 'ERR' | Select-Object -First 5 | ForEach-Object Line
