# fix-amt175-realm.ps1
# One-pass fix for the AMT175 Control Center OIDC 500 (missing amt-cc-api-scope).
# Creates realm amt175 + client scope amt-cc-api-scope + client amt-cc (lane-scoped redirects),
# reads the secret, patches CC appsettings.json, recycles IIS, and tests.
# Keycloak: single instance on 8080 (hard rule - never 8081).

$ErrorActionPreference = 'Stop'
$kc     = 'http://localhost:8080'
$ccPath = 'C:\Amt\Parallel\AMT175\AmtTools\ControlCenterCore\appsettings.json'
$ccWeb  = 'C:\Amt\Parallel\AMT175\AmtTools\ControlCenterCore\web.config'

function Get-Token {
  (Invoke-RestMethod -Method Post -Uri "$kc/realms/master/protocol/openid-connect/token" `
    -Body @{client_id='admin-cli';grant_type='password';username='admin';password='admin'} `
    -ContentType 'application/x-www-form-urlencoded').access_token
}

Write-Host '== 1. Admin token ==' -ForegroundColor Cyan
$t  = Get-Token
$H  = @{ Authorization = "Bearer $t" }
$Hj = @{ Authorization = "Bearer $t"; 'Content-Type' = 'application/json' }

Write-Host '== 2. Ensure realm amt175 exists (create if missing) ==' -ForegroundColor Cyan
$realms = (Invoke-RestMethod -Uri "$kc/admin/realms" -Headers $H).realm
if ($realms -notcontains 'amt175') {
  Invoke-RestMethod -Uri "$kc/admin/realms" -Method Post -Headers $Hj -Body (@{ realm='amt175'; enabled=$true } | ConvertTo-Json)
  Write-Host '   created realm amt175'
} else { Write-Host '   realm amt175 already present' }

Write-Host '== 3. Ensure client scope amt-cc-api-scope (with audience mapper aud=amt-cc) ==' -ForegroundColor Cyan
$scopes = Invoke-RestMethod -Uri "$kc/admin/realms/amt175/client-scopes" -Headers $H
$scope  = $scopes | Where-Object name -eq 'amt-cc-api-scope'
if (-not $scope) {
  $scopeBody = @{
    name     = 'amt-cc-api-scope'
    protocol = 'openid-connect'
    attributes = @{ 'include.in.token.scope' = 'true'; 'display.on.consent.screen' = 'false' }
    protocolMappers = @(@{
      name           = 'amt-cc-audience'
      protocol       = 'openid-connect'
      protocolMapper = 'oidc-audience-mapper'
      config = @{ 'included.client.audience' = 'amt-cc'; 'access.token.claim' = 'true'; 'id.token.claim' = 'false' }
    })
  } | ConvertTo-Json -Depth 8
  Invoke-RestMethod -Uri "$kc/admin/realms/amt175/client-scopes" -Method Post -Headers $Hj -Body $scopeBody
  Write-Host '   created client scope amt-cc-api-scope'
} else { Write-Host '   client scope already present' }
$scopeId = (Invoke-RestMethod -Uri "$kc/admin/realms/amt175/client-scopes" -Headers $H | Where-Object name -eq 'amt-cc-api-scope').id

Write-Host '== 4. Ensure client amt-cc (lane-scoped redirects) ==' -ForegroundColor Cyan
$existing = Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients?clientId=amt-cc" -Headers $H
if (-not $existing -or $existing.Count -eq 0) {
  $clientBody = @{
    clientId = 'amt-cc'; enabled = $true; protocol = 'openid-connect'; publicClient = $false
    standardFlowEnabled = $true; directAccessGrantsEnabled = $true
    redirectUris = @('http://localhost/AMT175/ControlCenter/*','http://localhost/AMT175/ControlCenter/signin-oidc')
    webOrigins   = @('http://localhost')
  } | ConvertTo-Json -Depth 8
  Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients" -Method Post -Headers $Hj -Body $clientBody
  Write-Host '   created client amt-cc'
} else { Write-Host '   client amt-cc already present' }
$cid = (Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients?clientId=amt-cc" -Headers $H)[0].id

Write-Host '== 5. Attach amt-cc-api-scope as a DEFAULT client scope ==' -ForegroundColor Cyan
Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients/$cid/default-client-scopes/$scopeId" -Method Put -Headers $H
Write-Host '   scope attached as default'

Write-Host '== 6. Read amt-cc client secret ==' -ForegroundColor Cyan
$secret = (Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients/$cid/client-secret" -Headers $H).value
if (-not $secret) {
  $secret = (Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients/$cid/client-secret" -Method Post -Headers $H).value
}
Write-Host "   secret: $secret"

Write-Host '== 7. Patch CC appsettings.json ClientSecret ==' -ForegroundColor Cyan
Copy-Item $ccPath "$ccPath.bak-$(Get-Date -f yyyyMMddHHmmss)"
$cfg = Get-Content $ccPath -Raw | ConvertFrom-Json
$cfg.Amt.Authentication.AmtOIDC.OIDC.ClientSecret = $secret
[System.IO.File]::WriteAllText($ccPath, ($cfg | ConvertTo-Json -Depth 40), (New-Object System.Text.UTF8Encoding($false)))
Write-Host '   appsettings.json updated'

Write-Host '== 8. Verify scope present on amt175 ==' -ForegroundColor Cyan
(Invoke-RestMethod -Uri "$kc/admin/realms/amt175/client-scopes" -Headers $H).name -join ', '

Write-Host '== 9. Recycle CC app pool + test ==' -ForegroundColor Cyan
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
    } else {
      Write-Host "RESULT: STATUS $([int]$resp.StatusCode)  LOCATION $loc" -ForegroundColor Yellow
    }
  } else {
    Write-Host "RESULT: NO RESPONSE - $($_.Exception.Message)" -ForegroundColor Red
  }
}
Write-Host '== DONE ==' -ForegroundColor Cyan
