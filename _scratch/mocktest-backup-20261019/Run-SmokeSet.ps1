<#
.SYNOPSIS
  Smoke-runs the five non-copy programs of the AFBUS_2200COBOL set (FUSBA2, LECTIS, LOADIS, RECAP, UNLOADIS) one by one.
.DESCRIPTION
  Restarts the mock file controller (hidden) before every case, because a killed or failed run leaves its files locked in the
  controller. Results are objects (exit code, new files, first error); there is no reference output, so a clean run only
  shows that the program loads, opens its files and ends.
#>
param([String]$Binaries = 'E:\AMT_Work\Rebuild177a\AFBUS_2200COBOL\Binaries\Programs', [Int32]$TimeoutSeconds = 45)
$run = Join-Path $PSScriptRoot 'Run-SmokeCase.ps1'
function Stop-MockFc {
  Get-Process AmtFileController -ErrorAction SilentlyContinue | ForEach-Object {
    $path = try { $_.Path } catch { '' }
    if ($path -like 'E:\AMT_Work\MockSystem\FC\*') { Stop-Process -Id $_.Id -Force }
  }
}
function Reset-MockFc {
  Stop-MockFc
  Start-Sleep 2
  Get-ChildItem E:\AMT_Work\MockTest\Extracts -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
  Start-Process -FilePath E:\AMT_Work\MockSystem\FC\AmtFileController.exe -ArgumentList '/VS', '/N:MockFileController' -WorkingDirectory E:\AMT_Work\MockSystem\FC -WindowStyle Hidden | Out-Null
  for ($i = 0; $i -lt 40; $i++) { if (Get-NetTCPConnection -LocalPort 18132 -State Listen -ErrorAction SilentlyContinue) { return }; Start-Sleep 1 }
  throw 'Mock file controller did not start.'
}
$c = 'E:\Repos\ssg4-work\sgs-cards\calls'
$set = @(
  @{ Case = 'VIRD03_L766'; Dll = 'ASSURFED_UTILIT_FUSBA2_ASCII.dll';   Cards = "$c\ASSURFED_F999RUN-d_VIRD03__L766.sgs" },
  @{ Case = 'CCTA09_L479'; Dll = 'ASSURFED_UTILIT_LECTIS_ASCII.dll';   Cards = "$c\ASSURFED_F999RUN_CCTA09__L479.sgs" },
  @{ Case = 'CLOA49_L141'; Dll = 'ASSURFED_UTILIT_LOADIS_ASCII.dll';   Cards = "$c\ASSURFED_F999RUN_CLOA49__L141.sgs" },
  @{ Case = 'CCTA08_L287'; Dll = 'ASSURFED_UTILIT_RECAP.dll';          Cards = "$c\ASSURFED_F999RUN_CCTA08__L287.sgs" },
  @{ Case = 'CLOA43_L473'; Dll = 'ASSURFED_UTILIT_UNLOADIS_ASCII.dll'; Cards = "$c\ASSURFED_F999RUN_CLOA43__L473.sgs" }
)
try {
  foreach ($s in $set) {
    Reset-MockFc
    pwsh -NoProfile -File $run -Case $s.Case -Application AFBUS_2200COBOL -Dll $s.Dll -Cards $s.Cards -Binaries $Binaries -TimeoutSeconds $TimeoutSeconds
  }
} finally { Stop-MockFc }
