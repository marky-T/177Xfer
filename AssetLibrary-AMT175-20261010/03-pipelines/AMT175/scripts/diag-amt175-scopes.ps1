# diag-amt175-scopes.ps1 — list what actually exists in realm amt175
$ErrorActionPreference = 'Stop'
$kc = 'http://localhost:8080'
$t  = (Invoke-RestMethod -Method Post -Uri "$kc/realms/master/protocol/openid-connect/token" `
        -Body @{client_id='admin-cli';grant_type='password';username='admin';password='admin'} `
        -ContentType 'application/x-www-form-urlencoded').access_token
$H = @{ Authorization = "Bearer $t" }

Write-Host '== ALL client-scopes in amt175 ==' -ForegroundColor Cyan
Invoke-RestMethod -Uri "$kc/admin/realms/amt175/client-scopes" -Headers $H |
  Select-Object name, id | Sort-Object name | Format-Table -AutoSize

Write-Host '== Does amt-cc-api-scope exist? ==' -ForegroundColor Cyan
$s = Invoke-RestMethod -Uri "$kc/admin/realms/amt175/client-scopes" -Headers $H | Where-Object { $_.name -eq 'amt-cc-api-scope' }
if ($s) { "FOUND id=$($s.id)" } else { "NOT FOUND" }

Write-Host '== amt-cc client default + optional scopes ==' -ForegroundColor Cyan
$cid = (Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients?clientId=amt-cc" -Headers $H)[0].id
"cid=$cid"
"default : " + ((Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients/$cid/default-client-scopes" -Headers $H).name -join ', ')
"optional: " + ((Invoke-RestMethod -Uri "$kc/admin/realms/amt175/clients/$cid/optional-client-scopes" -Headers $H).name -join ', ')
