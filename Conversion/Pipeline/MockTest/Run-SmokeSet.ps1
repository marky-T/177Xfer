<#
.SYNOPSIS
  Smoke-runs every generated program of the AFBUS_2200COBOL set (except those in TestCatalog.psd1 SmokeExclude), one by one.
.DESCRIPTION
  The list comes from the DLLs in -Binaries and the exported @SSG call each was built from (MockTestLib.psm1 Get-SetCalls), so a newly
  generated program is included without edits. Programs with a card reader get the data cards that follow the call in the run stream.
  Restarts the mock file controller (hidden) before every case, because a killed or failed run leaves its files locked in the
  controller. Results are objects (exit code, new files, first error); there is no reference output, so a clean run only
  shows that the program loads, opens its files and ends.
#>
param([String]$Binaries = 'E:\AMT_Work\Rebuild177a\AFBUS_2200COBOL\Binaries\Programs', [Int32]$TimeoutSeconds = 45, [String]$Work = 'E:\AMT_Work\MockTest\Smoke')
Import-Module (Join-Path $PSScriptRoot 'MockTestLib.psm1') -Force -DisableNameChecking
$run = Join-Path $PSScriptRoot 'Run-SmokeCase.ps1'
$catalog = Import-PowerShellDataFile (Join-Path $PSScriptRoot 'TestCatalog.psd1')
New-Item -ItemType Directory -Force $Work | Out-Null
try {
  foreach ($c in Get-SetCalls -Binaries $Binaries | Where-Object { $catalog.SmokeExclude -notcontains $_.Key }) {
    $extra = New-CardReaderInput $c $Work
    Start-MockFc
    & $run -Case $c.Case -Application AFBUS_2200COBOL -Dll $c.Dll -Cards $c.Cards -ExtraInputs $extra -Binaries $Binaries -TimeoutSeconds $TimeoutSeconds
  }
} finally { Stop-MockFc }
