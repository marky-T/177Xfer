<#
  Run-T3-HelloWorld-Live.ps1 - isolation test: does ANY script succeed via a real CC Start Job,
  or is this specific to invoking an SsgConverter-generated body?

  Follows the AMT official training doc's own Exercise 1 (Overview Batch Jobs in AMT - from ECL
  to PowerShell.md, "Basic script in AMT"): the minimal possible job - no CFH-COPY/SsgConverter
  body at all, just the bare ECL skeleton + one informational message.
#>

$rt = 'C:\Amt\Migration\T3ConvertedSSG\ConvertedSSG\RealRuntime'
$AmtSettingsFile = 'C:\Amt\Migration\Trial3\run\AmtSettings-AFBUS2200COBOL.xml'

Import-Module (Join-Path $rt 'AmtPsEclLib.psm1')  -Force -DisableNameChecking -ErrorAction Stop
Import-Module (Join-Path $rt 'AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction SilentlyContinue

Trap {
  HandleTrapAndAbort "Error trapped:" $_
}

Set-Jobname "T3_HELLOWORLD_LIVE"
Initialize $AmtSettingsFile
Write-Host "=== Initialize OK ===" -ForegroundColor Green

Add-InformationMsg "Hello World"

Fin
