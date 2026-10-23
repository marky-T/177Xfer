<#
  CFH-COPY_ASCII-LIVE.ps1 - AMT177 release wrapper (portable, basepath-driven).
  Wraps the converted SSG body 'CFH-COPY_ASCII.ps1' in a real ECL skeleton and runs it under Control Center.
  The body is resolved at run time from the CC-configured Script basepath
  (System Configuration > System Setup > Basepaths > Script path).
  Seeded from SgsSeeds\CFH-COPY_ASCII.sgs-values.json - the same SGS values proven in the Tier-1 harness.
#>

# AMT runtime library + settings. Set by the installer (see README); relative fallback = CC Script layout.
$rt              = if ($env:AMT_RT)       { $env:AMT_RT }       else { Join-Path $PSScriptRoot '..\..\Libraries' }
$AmtSettingsFile = if ($env:AMT_SETTINGS) { $env:AMT_SETTINGS } else { Join-Path $PSScriptRoot '..\..\Settings\AmtSettings.xml' }

Import-Module (Join-Path $rt 'AmtPsEclLib.psm1')  -Force -DisableNameChecking -ErrorAction Stop
Import-Module (Join-Path $rt 'AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction SilentlyContinue

Trap {
  HandleTrapAndAbort "Error trapped:" $_
}

Set-Jobname "T3_20_CFH_COPY_ASCII_LIVE"
Initialize $AmtSettingsFile
Write-Host "=== Initialize OK - live Connect-Application succeeded ===" -ForegroundColor Green

$global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
AddTo-SgsList 'INPUT 1,80,1'
AddTo-SgsList 'OUTPUT 1,80,1'
AddTo-SgsList 'ASCII 1'
AddTo-SgsList 'PRINT 0'
AddTo-SgsList 'FIELDIN 0'
AddTo-SgsList 'FIELDOUT 0'
AddTo-SgsList 'FIXE 0,0'
AddTo-SgsList 'REPRISE 0'
AddTo-SgsList 'MAXCOPY 0'
AddTo-SgsList 'SUPCOM 0'
AddTo-SgsList 'REPSIM 0'
AddTo-SgsList 'STARTFIELD 0'
AddTo-SgsList 'STARTREC 0'
AddTo-SgsList 'Y2K 0'

# Converted SSG body, resolved from the CC Basepaths > Script path (captured by Initialize).
$scriptPath = Join-Path $global:AmtPath.ScriptPath 'CFH-COPY_ASCII.ps1'

Write-Host "=== Running CFH-COPY_ASCII.ps1 body ===" -ForegroundColor Green
& $scriptPath -Parameters @('80')
Write-Host "=== Body completed without a thrown exception ===" -ForegroundColor Green

Fin
