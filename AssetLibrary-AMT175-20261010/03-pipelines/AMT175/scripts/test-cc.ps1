# test-cc.ps1 — clean probe of the AMT175 Control Center (uses curl.exe for reliable headers)
$u = 'http://localhost/AMT175/ControlCenter'
Write-Host "== Probe $u ==" -ForegroundColor Cyan
# -s silent, -S show errors, -i include headers, no auto-redirect
$out = curl.exe -s -S -i --max-time 30 $u 2>&1
$statusLine = ($out | Select-String -Pattern '^HTTP/' | Select-Object -First 1).ToString()
$location   = ($out | Select-String -Pattern '^location:' -CaseSensitive:$false | Select-Object -First 1)
Write-Host "STATUS  : $statusLine"
Write-Host "LOCATION: $location"
if ($location -match 'realms/amt175') {
  Write-Host 'SUCCESS - Control Center redirects to Keycloak login (amt175 realm).' -ForegroundColor Green
} elseif ($statusLine -match ' 500') {
  Write-Host 'Still 500 - fetching latest CC stdout log tail...' -ForegroundColor Yellow
  $log = Get-ChildItem 'C:\Amt\Parallel\AMT175\AmtTools\ControlCenterCore\logs' -Filter 'stdout*.log' -EA SilentlyContinue |
         Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($log) { "---- $($log.FullName) ----"; Get-Content $log.FullName -Tail 30 }
  else { 'No stdout log (ANCM stdout may be disabled).' }
}
