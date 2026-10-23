<#
  Run-T3-CFH-COPY-Live.ps1 - genuine Tier-3 attempt for the T3 20-program bundle.

  Wraps the raw SsgConverter output (Binaries\Scripts\CFH-COPY.ps1 - a body-only SSG-codegen
  script with NO job skeleton, per the AMT177/178 handoff) in a real ECL job-control skeleton
  (Set-Jobname -> Initialize -> Connect-Application -> body -> Fin), using the RealRuntime
  AmtPsEclLib.psm1/AmtPsSortLib.psm1 copy AMT177/178 bundled (already proven, on their side, to
  support GetSgsValue/AddTo-SgsList against this exact script in their isolated Stage A run).

  SGS seed mirrors AMT177/178's own proven Run-StageA.ps1 seed for CFH-COPY exactly (their
  Stage A run reached FIN with only this 3-line seed - PRINT/FIELDIN/FIELDOUT/etc. all default
  to 0/false unseeded).

  EXPECTED OUTCOME: per both our own AMT172 finding (Microsoft.Data.SqlClient / native SNI
  dependency-closure) and AMT177/178's independent confirmation of the same limitation, a bare
  pwsh run is expected to fail inside Initialize/Connect-Application at the system-DB connect
  step ("... is not supported on this platform"). That failure is itself the useful result -
  it would confirm AMT172 has the identical limitation. Getting past it requires hosting via
  AmtPowershellHost.exe (net8/PS 7.4) through BatchController/CC, not bare pwsh.
#>

$rt = 'C:\Amt\Migration\T3ConvertedSSG\ConvertedSSG\RealRuntime'
$AmtSettingsFile = 'C:\Amt\Migration\Trial3\run\AmtSettings-AFBUS2200COBOL.xml'
$scriptPath = 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\CFH-COPY.ps1'

Import-Module (Join-Path $rt 'AmtPsEclLib.psm1')  -Force -DisableNameChecking -ErrorAction Stop
Import-Module (Join-Path $rt 'AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction SilentlyContinue

Trap {
  HandleTrapAndAbort "Error trapped:" $_
}

Set-Jobname "T3_20_CFH_COPY_LIVE"
Initialize $AmtSettingsFile
Write-Host "=== Initialize OK - live Connect-Application succeeded ===" -ForegroundColor Green

# Seed SGS context - identical to AMT177/178's own proven Stage A seed for this program.
$global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
AddTo-SgsList 'INPUT ECL-TAPEIN,80,1'
AddTo-SgsList 'OUTPUT ECL-TAPEOUT,80,1'
AddTo-SgsList 'ASCII 1'
Write-Host ("Seeded SGS: [INPUT,1,1,1]={0}  [ASCII]={1}" -f (GetSgsValue '[INPUT,1,1,1]'), (GetSgsValue '[ASCII]'))

Write-Host "=== Running CFH-COPY.ps1 body ===" -ForegroundColor Green
& $scriptPath -Parameters @('80')
Write-Host "=== Body completed without a thrown exception ===" -ForegroundColor Green

Fin
