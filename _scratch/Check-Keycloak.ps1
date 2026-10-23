$out = 'E:\Repos\SsgTrial\_scratch\kc-check.txt'
$lines = @()
$l = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue
$lines += "Port 8080 listening: $([bool]$l)"
if ($l) { $lines += "Owning PID: $($l[0].OwningProcess) ($((Get-Process -Id $l[0].OwningProcess -ErrorAction SilentlyContinue).ProcessName))" }
try {
  $r = Invoke-WebRequest -Uri 'http://localhost:8080/realms/Federale/.well-known/openid-configuration' -UseBasicParsing -TimeoutSec 10
  $lines += "Realm Federale OIDC discovery: HTTP $($r.StatusCode)"
} catch {
  $lines += "Realm Federale OIDC discovery: FAILED - $($_.Exception.Message)"
}
$lines | Out-File $out
$lines
