<#
.SYNOPSIS
  One command for the whole AFBUS_2200COBOL mock test at Federale's 177a runtime.
.DESCRIPTION
  1. CFH-COPY_ASCII (call AFPH12 line 427): runs it and compares its output with the independent reference made from the cards.
  2. The five other programs (FUSBA2, LECTIS, LOADIS, RECAP, UNLOADIS): smoke runs only (no reference output), each with a
     fresh mock file controller and a time limit.
  Starts and stops its own hidden mock file controller (port 18132); never touches other file controllers.
  Needs: the rebuilt set (Rebuild-SetAgainstRuntime.ps1), the 177a runner E:\AMT_Work\MockSystem\Run177, the mock databases.
.EXAMPLE
  pwsh -NoProfile -File Run-AllMockTests.ps1
#>
param(
  [String]$Binaries = 'E:\AMT_Work\Rebuild177a\AFBUS_2200COBOL\Binaries\Programs',
  [String]$RunnerBase = 'E:\AMT_Work\MockSystem\Run177',
  [Int32]$TimeoutSeconds = 45
)
$here = $PSScriptRoot
function Stop-MockFc {
  Get-Process AmtFileController -ErrorAction SilentlyContinue | ForEach-Object {
    $path = try { $_.Path } catch { '' }
    if ($path -like 'E:\AMT_Work\MockSystem\FC\*') { Stop-Process -Id $_.Id -Force }
  }
}
function Start-MockFc {
  Stop-MockFc; Start-Sleep 2
  Get-ChildItem E:\AMT_Work\MockTest\Extracts -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
  Start-Process -FilePath E:\AMT_Work\MockSystem\FC\AmtFileController.exe -ArgumentList '/VS', '/N:MockFileController' -WorkingDirectory E:\AMT_Work\MockSystem\FC -WindowStyle Hidden | Out-Null
  for ($i = 0; $i -lt 40; $i++) { if (Get-NetTCPConnection -LocalPort 18132 -State Listen -ErrorAction SilentlyContinue) { return }; Start-Sleep 1 }
  throw 'Mock file controller did not start.'
}

"== 1. CFH-COPY_ASCII against the reference (AFPH12 line 427)"
try {
  Start-MockFc
  Remove-Item E:\AMT_Work\MockSystem\Run_AFPH12_L427 -Recurse -Force -ErrorAction SilentlyContinue
  pwsh -NoProfile -File (Join-Path $here 'Run-MockCase.ps1') -Case AFPH12_L427 -Application AFBUS_2200COBOL `
    -Cards E:\Repos\ssg4-work\sgs-cards\calls\ASSURFED_F999RUN_AFPH12__L427.sgs -Dll ASSURFED_UTILIT_CFH_COPY_ASCII.dll `
    -Binaries $Binaries -RunnerBase $RunnerBase
} finally { Stop-MockFc }

"`n== 2. Smoke runs (no reference output: loads, opens files, ends)"
pwsh -NoProfile -File (Join-Path $here 'Run-SmokeSet.ps1') -Binaries $Binaries -TimeoutSeconds $TimeoutSeconds

"`n== 3. Reference tests (expected output worked out independently of the C#)"
pwsh -NoProfile -File (Join-Path $here 'Run-ReferenceTests.ps1') -Binaries $Binaries
