# final-fix-amt175.ps1 — attach amt-cc-api-scope to amt-cc (default), patch secret, recycle, test.
$ErrorActionPreference = 'Stop'
$kc     = 'http://localhost:8080'
$ccPath = 'C:\Amt\Parallel\AMT175\AmtTools\ControlCenterCore\appsettings.json'
$ccWeb  = 'C:\Amt\Parallel\AMT175\AmtTools\ControlCenterCore\web.config'

$t = (Invoke-RestMethod -Method Post -Uri "$kc/realms/master/protocol/openid-connect/token" `
      -Body @{client_id='admin-cli';grant_type='password';username='admin';password='admin'} `
      -ContentType 'application/x-www-form-urlencoded').access_token
$H = @{ Authorization = "Bearer $t" }

Write-Host '== Resolve client id ==' -ForegroundColor Cyan
$cid = (Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients?clientId=amt-cc" -Headers $H)[0].id
Write-Host "   cid=$cid"

Write-Host '== Resolve amt-cc-api-scope id (single) ==' -ForegroundColor Cyan
$allScopes = Invoke-RestMethod -Uri "$kc/admin/realms/amt175/client-scopes" -Headers $H
$scope = @($allScopes | Where-Object { $_.name -eq 'amt-cc-api-scope' })[0]
$scopeId = $scope.id
Write-Host "   scopeId=$scopeId"
if ([string]::IsNullOrWhiteSpace($scopeId)) { throw "amt-cc-api-scope id not resolved" }

Write-Host '== Attach as DEFAULT client scope ==' -ForegroundColor Cyan
$attachUri = "$kc/admin/realms/amt175/clients/$cid/default-client-scopes/$scopeId"
Write-Host "   PUT $attachUri"
Invoke-RestMethod -Uri $attachUri -Method Put -Headers $H
Write-Host '   attached OK'

Write-Host '== Verify client default scopes now include amt-cc-api-scope ==' -ForegroundColor Cyan
$def = (Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients/$cid/default-client-scopes" -Headers $H).name
$def -join ', '
if ($def -notcontains 'amt-cc-api-scope') { throw "scope still not attached" }

Write-Host '== Read secret + patch appsettings.json ==' -ForegroundColor Cyan
$secret = (Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients/$cid/client-secret" -Headers $H).value
if (-not $secret) { $secret = (Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients/$cid/client-secret" -Method Post -Headers $H).value }
Write-Host "   secret: $secret"
Copy-Item $ccPath "$ccPath.bak-$(Get-Date -f yyyyMMddHHmmss)"
$cfg = Get-Content $ccPath -Raw | ConvertFrom-Json
$cfg.Amt.Authentication.AmtOIDC.OIDC.ClientSecret = $secret
[System.IO.File]::WriteAllText($ccPath, ($cfg | ConvertTo-Json -Depth 40), (New-Object System.Text.UTF8Encoding($false)))
Write-Host '   appsettings.json updated'

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
      Write-Host "RESULT: 302 -> $loc" -ForegroundColor Green
      Write-Host "SUCCESS - Control Center now redirects to Keycloak login." -ForegroundColor Green
    } else { Write-Host "RESULT: STATUS $([int]$resp.StatusCode)  LOCATION $loc" -ForegroundColor Yellow }
  } else { Write-Host "RESULT: NO RESPONSE - $($_.Exception.Message)" -ForegroundColor Red }
}
Write-Host '== DONE ==' -ForegroundColor Cyan
