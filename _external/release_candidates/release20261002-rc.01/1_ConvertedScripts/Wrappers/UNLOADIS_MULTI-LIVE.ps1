<#
  UNLOADIS_MULTI-LIVE.ps1 - AMT177 release wrapper (portable, basepath-driven).
  Wraps the converted SSG body 'UNLOADIS_MULTI.ps1' in a real ECL skeleton and runs it under Control Center.
  The body is resolved at run time from the CC-configured Script basepath
  (System Configuration > System Setup > Basepaths > Script path).
  Seeded from SgsSeeds\UNLOADIS_MULTI.sgs-values.json - the same SGS values proven in the Tier-1 harness.
#>

# AMT runtime library + settings. Set by the installer (see README); relative fallback = CC Script layout.
$rt              = if ($env:AMT_RT)       { $env:AMT_RT }       else { Join-Path $PSScriptRoot '..\..\Libraries' }
$AmtSettingsFile = if ($env:AMT_SETTINGS) { $env:AMT_SETTINGS } else { Join-Path $PSScriptRoot '..\..\Settings\AmtSettings.xml' }

Import-Module (Join-Path $rt 'AmtPsEclLib.psm1')  -Force -DisableNameChecking -ErrorAction Stop
Import-Module (Join-Path $rt 'AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction SilentlyContinue

Trap {
  HandleTrapAndAbort "Error trapped:" $_
}

Set-Jobname "T3_20_UNLOADIS_MULTI_LIVE"
Initialize $AmtSettingsFile
Write-Host "=== Initialize OK - live Connect-Application succeeded ===" -ForegroundColor Green

$global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
AddTo-SgsList 'ASCII 1'
AddTo-SgsList 'SFS 0'
AddTo-SgsList 'OMITTED 0'
AddTo-SgsList 'MAXREC 0'
AddTo-SgsList 'OUTPUT ECL-BDE1,80,1'
AddTo-SgsList 'INPUT ECL-DISQ,20,1'
AddTo-SgsList 'KEYIS 0,8,12 0,12,8'

# Converted SSG body, resolved from the CC Basepaths > Script path (captured by Initialize).
$scriptPath = Join-Path $global:AmtPath.ScriptPath 'UNLOADIS_MULTI.ps1'

Write-Host "=== Running UNLOADIS_MULTI.ps1 body ===" -ForegroundColor Green
& $scriptPath -Parameters @('80')
Write-Host "=== Body completed without a thrown exception ===" -ForegroundColor Green

Fin
