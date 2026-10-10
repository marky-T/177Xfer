<#
.SYNOPSIS
  Back up the AMT175 Keycloak-related config now that the shared amtrealm setup is verified.

.DESCRIPTION
  Copies the two Control Center appsettings.json files (Core + WebApi) that were edited during
  the Keycloak bring-up, and (optionally) exports the amtrealm realm itself via the Keycloak
  Admin REST API (clients, client scopes, mappers - no live server restart required).

  Location: C:\Amt\Parallel\AMT175\AMT-Local-Backups\keycloak\<timestamp>\
  (no AMT_ReferenceDocuments steer found for backup location - repo-convention choice,
  matching existing AMT-Local-Fixes / AMT-Local-Support folders.)

  Admin credentials are prompted at runtime (SecureString) and never written to disk or
  passed as a plain-text parameter - avoids hardcoded secrets.

.NOTES
  Verified against Keycloak 26.2.5, realm amtrealm, client amt-cc / amt-cc-api. 2026-09-02.
#>
[CmdletBinding()]
param(
    [string]$AmtRoot     = "C:\Amt\Parallel\AMT175",
    [string]$BackupRoot  = "C:\Amt\Parallel\AMT175\AMT-Local-Backups\keycloak",
    [string]$KcBaseUrl   = "http://localhost:8080",
    [string]$Realm       = "amtrealm",
    [switch]$SkipRealmExport
)

$stamp   = Get-Date -Format "yyyyMMdd-HHmmss"
$destDir = Join-Path $BackupRoot $stamp
New-Item -ItemType Directory -Path $destDir -Force | Out-Null
Write-Host "Backup folder: $destDir" -ForegroundColor Cyan

# 1) Copy Control Center appsettings (Core + WebApi)
$files = @(
    "AmtTools\ControlCenterCore\appsettings.json",
    "AmtTools\ControlCenterWebApi\appsettings.json"
)
foreach ($rel in $files) {
    $src = Join-Path $AmtRoot $rel
    if (Test-Path $src) {
        $destName = ($rel -replace '[\\/]', '_')
        Copy-Item $src (Join-Path $destDir $destName) -Force
        Write-Host "Copied $rel" -ForegroundColor Green
    } else {
        Write-Host "Missing (skipped): $rel" -ForegroundColor Yellow
    }
}

# 2) Manifest of the fixed config values, for quick reference on restore
@"
AMT175 Keycloak config backup - $stamp
Realm (shared):  $Realm
Authority:       $KcBaseUrl/realms/$Realm
Core ClientId:   amt-cc          (Scope: amt-cc-api-scope)
WebApi Audience: amt-cc-api      (resource client, all auth flows off)
"@ | Out-File (Join-Path $destDir "manifest.txt") -Encoding utf8
Write-Host "Wrote manifest.txt" -ForegroundColor Green

if ($SkipRealmExport) { Write-Host "Skipping realm export (-SkipRealmExport)." -ForegroundColor Yellow; return }

# 3) Optional: export the realm itself via Keycloak Admin REST API (no server restart needed)
Write-Host "`nRealm export requires Keycloak admin credentials (master realm)." -ForegroundColor Cyan
$adminUser = Read-Host "Admin username (e.g. tempadmin / admin)"
$securePwd = Read-Host "Admin password" -AsSecureString
$plainPwd  = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePwd))

try {
    $tokenResp = Invoke-RestMethod -Method Post -Uri "$KcBaseUrl/realms/master/protocol/openid-connect/token" -Body @{
        client_id  = "admin-cli"
        grant_type = "password"
        username   = $adminUser
        password   = $plainPwd
    }
    $headers = @{ Authorization = "Bearer $($tokenResp.access_token)" }

    $export = Invoke-RestMethod -Method Post -Headers $headers `
        -Uri "$KcBaseUrl/admin/realms/$Realm/partial-export?exportClients=true&exportGroupsAndRoles=true"

    $exportPath = Join-Path $destDir "$Realm-realm-export.json"
    $export | ConvertTo-Json -Depth 50 | Out-File $exportPath -Encoding utf8
    Write-Host "Realm export saved: $exportPath" -ForegroundColor Green
} catch {
    Write-Host "Realm export failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Fallback: Admin Console -> Realm settings -> Action -> Export (manual)." -ForegroundColor Yellow
} finally {
    $plainPwd = $null
}

Write-Host "`nDone. Backup at: $destDir" -ForegroundColor Cyan
