# create-amt175-users.ps1 — create marky-t, amt175admin, amt175user in realm amt175 (idempotent)
$ErrorActionPreference = 'Stop'
$kc    = 'http://localhost:8080'
$realm = 'amt175'
$pwd   = 'Asysco12345!'

$sharedEmail = 'mark.truman@avanade.com'
$users = @(
  @{ username='amt175admin'; first='AMT175'; last='Admin'; email=$sharedEmail }
  @{ username='amt175user';  first='AMT175'; last='User';  email=$sharedEmail }
  @{ username='marky-t';     first='Mark';   last='Truman'; email=$sharedEmail }
)

$t = (Invoke-RestMethod -Method Post -Uri "$kc/realms/master/protocol/openid-connect/token" `
      -Body @{client_id='admin-cli';grant_type='password';username='admin';password='admin'} `
      -ContentType 'application/x-www-form-urlencoded').access_token
$H  = @{ Authorization = "Bearer $t" }
$Hj = @{ Authorization = "Bearer $t"; 'Content-Type' = 'application/json' }

Write-Host '== Allow duplicate emails on realm amt175 (requires loginWithEmail=false) ==' -ForegroundColor Cyan
$r = Invoke-RestMethod -Uri "$kc/admin/realms/$realm" -Headers $H
$r.loginWithEmailAllowed  = $false
$r.duplicateEmailsAllowed = $true
Invoke-RestMethod -Uri "$kc/admin/realms/$realm" -Method Put -Headers $Hj -Body ($r | ConvertTo-Json -Depth 40)
$chk = Invoke-RestMethod -Uri "$kc/admin/realms/$realm" -Headers $H
Write-Host ("   loginWithEmailAllowed={0}  duplicateEmailsAllowed={1}" -f $chk.loginWithEmailAllowed, $chk.duplicateEmailsAllowed)

foreach ($u in $users) {
  Write-Host "== $($u.username) ==" -ForegroundColor Cyan
  $existing = Invoke-RestMethod -Uri "$kc/admin/realms/$realm/users?username=$($u.username)&exact=true" -Headers $H
  if ($existing -and $existing.Count -gt 0) {
    $uid = $existing[0].id
    Write-Host "   exists (id=$uid) - ensuring enabled + password"
  } else {
    $body = @{
      username=$u.username; enabled=$true; emailVerified=$true
      email=$u.email; firstName=$u.first; lastName=$u.last
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "$kc/admin/realms/$realm/users" -Method Post -Headers $Hj -Body $body
    $uid = (Invoke-RestMethod -Uri "$kc/admin/realms/$realm/users?username=$($u.username)&exact=true" -Headers $H)[0].id
    Write-Host "   created (id=$uid)"
  }
  # Ensure email (shared), emailVerified, enabled on the user record
  $rep = @{ email=$u.email; emailVerified=$true; enabled=$true; firstName=$u.first; lastName=$u.last } | ConvertTo-Json
  Invoke-RestMethod -Uri "$kc/admin/realms/$realm/users/$uid" -Method Put -Headers $Hj -Body $rep
  Write-Host "   email=$($u.email) verified=true"
  # Set non-temporary password
  $pw = @{ type='password'; value=$pwd; temporary=$false } | ConvertTo-Json
  Invoke-RestMethod -Uri "$kc/admin/realms/$realm/users/$uid/reset-password" -Method Put -Headers $Hj -Body $pw
  Write-Host "   password set (non-temporary)"
}

Write-Host '== Verify: all users in realm amt175 ==' -ForegroundColor Cyan
Invoke-RestMethod -Uri "$kc/admin/realms/$realm/users" -Headers $H |
  Select-Object username, email, enabled | Sort-Object username | Format-Table -AutoSize

Write-Host '== Login test (direct grant) for each ==' -ForegroundColor Cyan
foreach ($u in $users) {
  try {
    $tok = Invoke-RestMethod -Method Post -Uri "$kc/realms/$realm/protocol/openid-connect/token" `
      -Body @{ client_id='amt-cc'; grant_type='password'; username=$u.username; password=$pwd;
               client_secret=(Invoke-RestMethod -Uri "$kc/admin/realms/$realm/clients?clientId=amt-cc" -Headers $H | ForEach-Object { (Invoke-RestMethod -Uri "$kc/admin/realms/$realm/clients/$($_.id)/client-secret" -Headers $H).value }) } `
      -ContentType 'application/x-www-form-urlencoded'
    Write-Host ("   {0}: LOGIN OK (token {1} chars)" -f $u.username, $tok.access_token.Length) -ForegroundColor Green
  } catch {
    Write-Host ("   {0}: login test failed - {1}" -f $u.username, $_.Exception.Message) -ForegroundColor Yellow
  }
}
Write-Host '== DONE ==' -ForegroundColor Cyan
