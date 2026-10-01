<#
  SCAN_ASCII-LIVE.ps1 - auto-generated live Tier-3 wrapper (Generate-T3-Live-Wrappers.ps1).
  Wraps Binaries\Scripts\SCAN_ASCII.ps1 in a real ECL skeleton, seeding SGS from
  Tier1Mock\sgs-values\SCAN_ASCII.sgs-values.json (same values used for the Tier-1 mock run).
#>

$rt = 'C:\Amt\Migration\T3ConvertedSSG\ConvertedSSG\RealRuntime'
$AmtSettingsFile = 'C:\Amt\Migration\Trial3\run\AmtSettings-AFBUS2200COBOL.xml'
$scriptPath = 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\SCAN_ASCII.ps1'

Import-Module (Join-Path $rt 'AmtPsEclLib.psm1')  -Force -DisableNameChecking -ErrorAction Stop
Import-Module (Join-Path $rt 'AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction SilentlyContinue

Trap {
  HandleTrapAndAbort "Error trapped:" $_
}

Set-Jobname "T3_20_SCAN_ASCII_LIVE"
Initialize $AmtSettingsFile
Write-Host "=== Initialize OK - live Connect-Application succeeded ===" -ForegroundColor Green

$global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
AddTo-SgsList 'ASCII 1'
AddTo-SgsList 'OMITTED 0'
AddTo-SgsList 'LIST 0'
AddTo-SgsList 'IF 0'
AddTo-SgsList 'NOCONT 0'
AddTo-SgsList 'INDIC 0'
AddTo-SgsList 'TITLE 0'
AddTo-SgsList 'Y2K 0'
AddTo-SgsList 'INPUT ECL-TAPEIN,100,10'

Write-Host "=== Running SCAN_ASCII.ps1 body ===" -ForegroundColor Green
& $scriptPath -Parameters @('80')
Write-Host "=== Body completed without a thrown exception ===" -ForegroundColor Green

Fin
