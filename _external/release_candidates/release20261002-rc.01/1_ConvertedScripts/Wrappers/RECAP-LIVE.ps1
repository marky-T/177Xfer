<#
  RECAP-LIVE.ps1 - AMT177 release wrapper (portable, basepath-driven).
  Wraps the converted SSG body 'RECAP.ps1' in a real ECL skeleton and runs it under Control Center.
  The body is resolved at run time from the CC-configured Script basepath
  (System Configuration > System Setup > Basepaths > Script path).
  Seeded from SgsSeeds\RECAP.sgs-values.json - the same SGS values proven in the Tier-1 harness.
#>

# AMT runtime library + settings. Set by the installer (see README); relative fallback = CC Script layout.
$rt              = if ($env:AMT_RT)       { $env:AMT_RT }       else { Join-Path $PSScriptRoot '..\..\Libraries' }
$AmtSettingsFile = if ($env:AMT_SETTINGS) { $env:AMT_SETTINGS } else { Join-Path $PSScriptRoot '..\..\Settings\AmtSettings.xml' }

Import-Module (Join-Path $rt 'AmtPsEclLib.psm1')  -Force -DisableNameChecking -ErrorAction Stop
Import-Module (Join-Path $rt 'AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction SilentlyContinue

Trap {
  HandleTrapAndAbort "Error trapped:" $_
}

Set-Jobname "T3_20_RECAP_LIVE"
Initialize $AmtSettingsFile
Write-Host "=== Initialize OK - live Connect-Application succeeded ===" -ForegroundColor Green

$global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
AddTo-SgsList 'ASCII 1'
AddTo-SgsList 'ASCIIFD 0'
AddTo-SgsList 'CFH 0'
AddTo-SgsList 'SCHEMA 0'
AddTo-SgsList 'Y2K 0'
AddTo-SgsList 'NEURO 0'
AddTo-SgsList 'INPUT ECL-TAPEIN,80,1'
AddTo-SgsList 'OUTPUT ECL-TAPEOUT,80,1'
AddTo-SgsList 'FIELDIN 0'
AddTo-SgsList 'FIELDOUT 0'
AddTo-SgsList 'TOTIN 0'
AddTo-SgsList 'TOTOUT 0'
AddTo-SgsList 'INDIC 0'

# Converted SSG body, resolved from the CC Basepaths > Script path (captured by Initialize).
$scriptPath = Join-Path $global:AmtPath.ScriptPath 'RECAP.ps1'

Write-Host "=== Running RECAP.ps1 body ===" -ForegroundColor Green
& $scriptPath -Parameters @('80')
Write-Host "=== Body completed without a thrown exception ===" -ForegroundColor Green

Fin
