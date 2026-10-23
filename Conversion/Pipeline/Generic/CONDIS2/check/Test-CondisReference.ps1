# CONDIS2 reference checks: the PowerShell model of the generic program (CondisModel.ps1) against real static programs
# in the mock system, on the case inputs of Prepare-CondisCc.ps1:
#  D42: the delivered static CONDIS2_ASCII (built from AUMH01_D3_L87's cards);
#  UE / DT: test-only programs from the VIRJ01_UE_L850 / AUPA02_MJ_L68 expansions (CONDIS2-RV / -RD, same LionDev round).
param([String]$Environment = 'Mock', [String]$Binaries)
$ErrorActionPreference = 'Continue'
$repo = (Resolve-Path "$PSScriptRoot\..\..\..\..\..").Path
. "$repo\Conversion\Pipeline\Generic\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
if (-not $Binaries) { $Binaries = $ge.MockRebuild }
$mt = "$repo\Conversion\Pipeline\MockTest"
$root = "$($ge.GenericWork)\CONDIS2\cases"
. "$mt\MockFc.ps1"
foreach ($ref in @(@('D42', 'ASSURFED_UTILIT_CONDIS2_ASCII.dll'), @('UE', 'ASSURFED_UTILIT_CONDIS2_RV.dll'), @('DT', 'ASSURFED_UTILIT_CONDIS2_RD.dll'))) {
  $case = $ref[0]; $dll = $ref[1]
  if (-not (Test-Path "$Binaries\$dll")) { "$case $dll not built yet (LionDev round)"; continue }
  try {
    Start-MockFc
    $r = & "$mt\Run-ProgramCase.ps1" -Case "CONDIS_REF_$case" -Dll $dll -Inputs @{ FILEIN = "$root\$case\input\INP" } -ExpectedName FILEOUT -ExpectedFile "$root\$case\expected\OUTP" -Binaries $Binaries
    '{0} static {1} vs model: {2} {3}' -f $case, $dll, $r.Result, $r.Detail
  } finally { Stop-MockFc }
}
