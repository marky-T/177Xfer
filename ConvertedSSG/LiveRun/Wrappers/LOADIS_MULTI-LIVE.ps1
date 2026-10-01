<#
  LOADIS_MULTI-LIVE.ps1 - auto-generated live Tier-3 wrapper (Generate-T3-Live-Wrappers.ps1).
  Wraps Binaries\Scripts\LOADIS_MULTI.ps1 in a real ECL skeleton, seeding SGS from
  Tier1Mock\sgs-values\LOADIS_MULTI.sgs-values.json (same values used for the Tier-1 mock run).
#>

$rt = 'C:\Amt\Migration\T3ConvertedSSG\ConvertedSSG\RealRuntime'
$AmtSettingsFile = 'C:\Amt\Migration\Trial3\run\AmtSettings-AFBUS2200COBOL.xml'
$scriptPath = 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\LOADIS_MULTI.ps1'

Import-Module (Join-Path $rt 'AmtPsEclLib.psm1')  -Force -DisableNameChecking -ErrorAction Stop
Import-Module (Join-Path $rt 'AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction SilentlyContinue

Trap {
  HandleTrapAndAbort "Error trapped:" $_
}

Set-Jobname "T3_20_LOADIS_MULTI_LIVE"
Initialize $AmtSettingsFile
Write-Host "=== Initialize OK - live Connect-Application succeeded ===" -ForegroundColor Green

$global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
AddTo-SgsList 'ASCII 1'
AddTo-SgsList 'SFS 0'
AddTo-SgsList 'INPUT ECL-BDE1,80,1'
AddTo-SgsList 'OUTPUT ECL-DISQ,20,1,0'
AddTo-SgsList 'KEYIS 0,8,12 0,12,8'

Write-Host "=== Running LOADIS_MULTI.ps1 body ===" -ForegroundColor Green
& $scriptPath -Parameters @('80')
Write-Host "=== Body completed without a thrown exception ===" -ForegroundColor Green

Fin
