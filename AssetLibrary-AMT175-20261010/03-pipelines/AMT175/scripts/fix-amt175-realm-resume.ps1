# fix-amt175-realm-resume.ps1
# Resumes after realm/scope/client were created. Attaches scope, reads secret, patches appsettings, recycles, tests.
$ErrorActionPreference = 'Stop'
$kc     = 'http://localhost:8080'
$ccPath = 'C:\Amt\Parallel\AMT175\AmtTools\ControlCenterCore\appsettings.json'
$ccWeb  = 'C:\Amt\Parallel\AMT175\AmtTools\ControlCenterCore\web.config'

$t  = (Invoke-RestMethod -Method Post -Uri "$kc/realms/master/protocol/openid-connect/token" `
        -Body @{client_id='admin-cli';grant_type='password';username='admin';password='admin'} `
        -ContentType 'application/x-www-form-urlencoded').access_token
$H = @{ Authorization = "Bearer $t" }

Write-Host '== Resolve client + scope ids ==' -ForegroundColor Cyan
$cid     = (Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients?clientId=amt-cc" -Headers $H)[0].id
$scopeId = (Invoke-RestMethod -Uri "$kc/admin/realms/amt175/client-scopes" -Headers $H | Where-Object name -eq 'amt-cc-api-scope').id
Write-Host "   cid=$cid"
Write-Host "   scopeId=$scopeId"
if (-not $cid -or -not $scopeId) { throw "Missing id: cid=$cid scopeId=$scopeId" }

Write-Host '== Attach amt-cc-api-scope as DEFAULT client scope ==' -ForegroundColor Cyan
Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients/$cid/default-client-scopes/$scopeId" -Method Put -Headers $H
Write-Host '   attached'

Write-Host '== Read amt-cc secret ==' -ForegroundColor Cyan
$secret = (Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients/$cid/client-secret" -Headers $H).value
if (-not $secret) { $secret = (Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients/$cid/client-secret" -Method Post -Headers $H).value }
Write-Host "   secret: $secret"

Write-Host '== Patch appsettings.json ==' -ForegroundColor Cyan
Copy-Item $ccPath "$ccPath.bak-$(Get-Date -f yyyyMMddHHmmss)"
$cfg = Get-Content $ccPath -Raw | ConvertFrom-Json
$cfg.Amt.Authentication.AmtOIDC.OIDC.ClientSecret = $secret
[System.IO.File]::WriteAllText($ccPath, ($cfg | ConvertTo-Json -Depth 40), (New-Object System.Text.UTF8Encoding($false)))
Write-Host '   updated'

Write-Host '== Verify default scopes on client ==' -ForegroundColor Cyan
(Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients/$cid/default-client-scopes" -Headers $H).name -join ', '

Write-Host '== Recycle + test ==' -ForegroundColor Cyan
(Get-Item $ccWeb).LastWriteTime = Get-Date
Start-Sleep 6
try {
  $r = Invoke-WebRequest 'http://localhost/AMT175/ControlCenter' -UseBasicParsing -MaximumRedirection 0 -TimeoutSec 30
  Write-Host "RESULT: STATUS $($r.StatusCode)  LOCATION $($r.Headers.Location)" -ForegroundColor Green
} catch {
  $resp = $_.Exception.Response
  if ($resp) {
    $loc = $resp.Headers['Location']
    if ([int]$resp.StatusCode -eq 302 -and $loc -match 'realms/amt175') {
      Write-Host "RESULT: 302 -> $loc  (SUCCESS - CC redirects to Keycloak login)" -ForegroundColor Green
    } else { Write-Host "RESULT: STATUS $([int]$resp.StatusCode)  LOCATION $loc" -ForegroundColor Yellow }
  } else { Write-Host "RESULT: NO RESPONSE - $($_.Exception.Message)" -ForegroundColor Red }
}
Write-Host '== DONE ==' -ForegroundColor Cyan
