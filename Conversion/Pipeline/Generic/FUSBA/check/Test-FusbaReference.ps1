# FUSBA reference checks: the PowerShell model of the generic program (FusbaModel.ps1) against
#  (C) the real static FUSBA_ASCII DLL (built from COMA16_U1_L113's cards, ANNUL COPY) in the mock system, synthetic data;
#  (M) the independent FUSBA2 reference Ref\FUSBA2_L766 (model of the skeleton, already passed by the static FUSBA2 DLL).
param([String]$Environment = 'Mock', [String]$Binaries)
$ErrorActionPreference = 'Continue'
$repo = (Resolve-Path "$PSScriptRoot\..\..\..\..\..").Path
. "$repo\Conversion\Pipeline\Generic\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
if (-not $Binaries) { $Binaries = $ge.MockRebuild }
$work = "$($ge.GenericWork)\FUSBA"
$mt = "$repo\Conversion\Pipeline\MockTest"
. "$PSScriptRoot\FusbaModel.ps1"
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
function Same([String]$a, [String]$b) { if (-not (Test-Path $a) -or -not (Test-Path $b)) { return $false }; [Linq.Enumerable]::SequenceEqual([IO.File]::ReadAllBytes($a), [IO.File]::ReadAllBytes($b)) }

# ---- M: FUSBA2 independent reference
$ref = "$($ge.MockRef)\FUSBA2_L766"
$p = Read-FusbaParm (Get-Content "$work\parm\FUSBA2_-d_VIRD03_L766.parm")
$m = Invoke-FusbaModel $p @("$ref\MAJ.bin", "$ref\INP.bin") @("$ref\OUT.model")
'M  model vs independent FUSBA2 reference: {0} (read {1}, written {2})' -f $(if (Same "$ref\OUT.model" "$ref\OUT.expected") { 'PASS' } else { 'FAIL' }), ($m.Read -join '/'), ($m.Written -join '/')

# ---- C: static FUSBA_ASCII (COMA16_U1_L113: CLE 29 key 1,10 / UNL 296 key 2,10 / LOA, SUP 296)
$root = "$($ge.MockRoot)\FUSBA_COMA16_U1"
New-Item -ItemType Directory -Force "$root\input", "$root\model" | Out-Null
$rnd = [Random]::new(2026102113)
$chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-/'
$txt = { param($n) -join (1..$n | ForEach-Object { $chars[$rnd.Next($chars.Length)] }) }
$pool = 1..40 | ForEach-Object { 'K' + ('{0:D9}' -f ($_ * 7)) }
# masters: 0-3 per key (duplicates), updates: about a third of the keys plus keys with no master, ascending
$unl = foreach ($k in $pool) { for ($n = $rnd.Next(0, 4); $n -gt 0; $n--) { (& $txt 1) + $k + (& $txt 285) } }
$cleKeys = @($pool | Where-Object { $rnd.Next(0, 3) -eq 0 }) + @('A000000001', 'K000000050', 'Z999999999') | Sort-Object -Unique -CaseSensitive
$cleKeys = [String[]]$cleKeys; [Array]::Sort($cleKeys, [StringComparer]::Ordinal)
$cle = foreach ($k in $cleKeys) { $k + (& $txt 19) }
[IO.File]::WriteAllText("$root\input\CLE", ($cle -join "`r`n") + "`r`n", $latin1)
[IO.File]::WriteAllText("$root\input\UNL", ($unl -join "`r`n") + "`r`n", $latin1)
$p = Read-FusbaParm (Get-Content "$work\parm\FUSBA_COMA16_U1_L113.parm")
$m = Invoke-FusbaModel $p @("$root\input\CLE", "$root\input\UNL") @("$root\model\LOA", "$root\model\SUP")
'C  model: read {0}, written LOA/SUP {1}' -f ($m.Read -join '/'), ($m.Written -join '/')
. "$mt\MockFc.ps1"
try {
  Start-MockFc
  $r = & "$mt\Run-ProgramCase.ps1" -Case FUSBA_STATIC_COMA16 -Dll ASSURFED_UTILIT_FUSBA_ASCII.dll -Inputs @{ CLE = "$root\input\CLE"; UNL = "$root\input\UNL" } -ExpectedName LOA -ExpectedFile "$root\model\LOA" -KeepOutputAs SUP -KeepOutputTo "$root\SUP.static" -Binaries $Binaries
  'C  static DLL vs model, LOA: {0} {1}' -f $r.Result, $r.Detail
  'C  static DLL vs model, SUP: {0}' -f $(if (Same "$root\SUP.static" "$root\model\SUP") { 'PASS' } else { 'FAIL' })
} finally { Stop-MockFc }

# ---- D and U: static reference programs built from VIRJ01_UE_L701 (D) and -d_VIRD03_L707 (U) expansions, generated in
# the same LionDev round as the generic program (FUSBAGN1.LionSource). Run on the D1 / U1 cases (New-FusbaCases.ps1).
foreach ($ref in @(@('D1', 'ASSURFED_UTILIT_FUSBA_RD.dll'), @('U1', 'ASSURFED_UTILIT_FUSBA_RU.dll'))) {
  $case = $ref[0]; $dll = $ref[1]
  if (-not (Test-Path "$Binaries\$dll")) { "$case $dll not built yet (LionDev round)"; continue }
  . "$PSScriptRoot\..\cc\FusbaCases.ps1"
  $p = Read-FusbaParm (Get-Content "$work\parm\$($FusbaCases[$case]).parm")
  $dir = "$work\cases\$case"
  $in = @{}; foreach ($i in $p.Ins) { $in[$i[0]] = "$dir\input\$($i[0])" }
  try {
    Start-MockFc
    $r = & "$mt\Run-ProgramCase.ps1" -Case "FUSBA_REF_$case" -Dll $dll -Inputs $in -ExpectedName $p.Outs[0][0] -ExpectedFile "$dir\expected\$($p.Outs[0][0])" -Binaries $Binaries
    '{0} static {1} vs model: {2} {3}' -f $case, $dll, $r.Result, $r.Detail
  } finally { Stop-MockFc }
}
