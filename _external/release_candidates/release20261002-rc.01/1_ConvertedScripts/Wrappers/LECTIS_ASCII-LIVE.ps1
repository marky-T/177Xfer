<#
  LECTIS_ASCII-LIVE.ps1 - AMT177 release wrapper (portable, basepath-driven).
  Wraps the converted SSG body 'LECTIS_ASCII.ps1' in a real ECL skeleton and runs it under Control Center.
  The body is resolved at run time from the CC-configured Script basepath
  (System Configuration > System Setup > Basepaths > Script path).
  Seeded from SgsSeeds\LECTIS_ASCII.sgs-values.json - the same SGS values proven in the Tier-1 harness.
#>

# AMT runtime library + settings. Set by the installer (see README); relative fallback = CC Script layout.
$rt              = if ($env:AMT_RT)       { $env:AMT_RT }       else { Join-Path $PSScriptRoot '..\..\Libraries' }
$AmtSettingsFile = if ($env:AMT_SETTINGS) { $env:AMT_SETTINGS } else { Join-Path $PSScriptRoot '..\..\Settings\AmtSettings.xml' }

Import-Module (Join-Path $rt 'AmtPsEclLib.psm1')  -Force -DisableNameChecking -ErrorAction Stop
Import-Module (Join-Path $rt 'AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction SilentlyContinue

Trap {
  HandleTrapAndAbort "Error trapped:" $_
}

Set-Jobname "T3_20_LECTIS_ASCII_LIVE"
Initialize $AmtSettingsFile
Write-Host "=== Initialize OK - live Connect-Application succeeded ===" -ForegroundColor Green

$global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
AddTo-SgsList 'ASCII 1'
AddTo-SgsList 'INPUT FICHIN-1,120,1'
AddTo-SgsList 'LKEY 2,8,0 4'
AddTo-SgsList 'KEYS 0'
AddTo-SgsList 'NOLIST 0'
AddTo-SgsList 'UN 1'
AddTo-SgsList 'DEUX 0'
AddTo-SgsList 'TROIS 0'
AddTo-SgsList 'Y2K 0'
AddTo-SgsList 'COND 0'

# Converted SSG body, resolved from the CC Basepaths > Script path (captured by Initialize).
$scriptPath = Join-Path $global:AmtPath.ScriptPath 'LECTIS_ASCII.ps1'

Write-Host "=== Running LECTIS_ASCII.ps1 body ===" -ForegroundColor Green
& $scriptPath -Parameters @('80')
Write-Host "=== Body completed without a thrown exception ===" -ForegroundColor Green

Fin
