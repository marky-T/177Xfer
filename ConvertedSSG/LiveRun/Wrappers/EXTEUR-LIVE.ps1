<#
  EXTEUR-LIVE.ps1 - auto-generated live Tier-3 wrapper (Generate-T3-Live-Wrappers.ps1).
  Wraps Binaries\Scripts\EXTEUR.ps1 in a real ECL skeleton, seeding SGS from
  Tier1Mock\sgs-values\EXTEUR.sgs-values.json (same values used for the Tier-1 mock run).
#>

$rt = 'C:\Amt\Migration\T3ConvertedSSG\ConvertedSSG\RealRuntime'
$AmtSettingsFile = 'C:\Amt\Migration\Trial3\run\AmtSettings-AFBUS2200COBOL.xml'
$scriptPath = 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\EXTEUR.ps1'

Import-Module (Join-Path $rt 'AmtPsEclLib.psm1')  -Force -DisableNameChecking -ErrorAction Stop
Import-Module (Join-Path $rt 'AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction SilentlyContinue

Trap {
  HandleTrapAndAbort "Error trapped:" $_
}

Set-Jobname "T3_20_EXTEUR_LIVE"
Initialize $AmtSettingsFile
Write-Host "=== Initialize OK - live Connect-Application succeeded ===" -ForegroundColor Green

$global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
AddTo-SgsList 'COND 0'
AddTo-SgsList 'DEVOUTPUT 0'
AddTo-SgsList 'LONG 80'
AddTo-SgsList 'BLOCK 10'
AddTo-SgsList 'DEVISE NONE,02'
AddTo-SgsList 'DATIME$ 30/09/2026'

Write-Host "=== Running EXTEUR.ps1 body ===" -ForegroundColor Green
& $scriptPath -Parameters @('80')
Write-Host "=== Body completed without a thrown exception ===" -ForegroundColor Green

Fin
