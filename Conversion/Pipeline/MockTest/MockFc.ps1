# Helpers for the mock file controller (port 18132). Dot-source this file. Only touches the controller started from E:\AMT_Work\MockSystem\FC.
function Stop-MockFc {
  Get-Process AmtFileController -ErrorAction SilentlyContinue | ForEach-Object {
    $path = try { $_.Path } catch { '' }
    if ($path -like 'E:\AMT_Work\MockSystem\FC\*') { Stop-Process -Id $_.Id -Force }
  }
}
# A killed or failed run leaves its files locked in the controller, so every case starts a fresh one and clears the extract folder.
function Start-MockFc {
  Stop-MockFc; Start-Sleep 2
  Get-ChildItem E:\AMT_Work\MockTest\Extracts -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
  Start-Process -FilePath E:\AMT_Work\MockSystem\FC\AmtFileController.exe -ArgumentList '/VS', '/N:MockFileController' -WorkingDirectory E:\AMT_Work\MockSystem\FC -WindowStyle Hidden | Out-Null
  for ($i = 0; $i -lt 40; $i++) { if (Get-NetTCPConnection -LocalPort 18132 -State Listen -ErrorAction SilentlyContinue) { return }; Start-Sleep 1 }
  throw 'Mock file controller did not start.'
}
