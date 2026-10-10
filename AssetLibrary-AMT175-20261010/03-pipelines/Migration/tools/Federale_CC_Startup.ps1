<#
.SYNOPSIS
  Federale_CC_Startup - brings up the full AMT 172 Control Center stack in the correct order.

.DESCRIPTION
  Order matters:
    1. Keycloak (OIDC auth, http://localhost:8080)  - CC login depends on it
    2. IIS site/app pool for CC (http://localhost/Working/ControlCenter)  - usually auto-started
    3. AmtFileController  (AFC - file I/O + log streaming; everything else depends on it)
    4. AmtBatchController (runs batch jobs / reports)
    5. AmtApplicationServer (online screens; optional for batch-only)

  MUST be run ELEVATED (Run as administrator) because the AMT Windows services need admin
  to start. Keycloak does not need admin, but is launched from here for a single entry point.

.NOTES
  Gotchas baked in from hard-won experience (2026-07-15):
   - AmtFileController fails with "File service FileController not found" if AMTSYSFILECONTROLLER.SERVICENAME
     is not exactly 'FileController' (the AmtService base strips the 'Amt' prefix). This script verifies it.
   - The CC "Server Control" Start/Stop buttons are broken (impersonation NRE) - start services from here instead.
   - Do NOT also run the standalone ControlCenterWebApi on :5000 - it collides localhost auth cookies with IIS.
   - OIDC correlation cookie fails over plain HTTP on a full re-login (form_post + SameSite=None needs HTTPS).
     Reprieve: clear browser cookies. Real fix: serve CC over HTTPS.

  Usage (elevated PowerShell):
    powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Amt\Migration\tools\Federale_CC_Startup.ps1"
#>

#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [string]$KeycloakRoot = 'C:\Tools\keycloak-25.0.6-fresh\keycloak-25.0.6',
    [int]   $KeycloakPort = 8080,
    [string]$SqlServer    = 'localhost',
    [string]$SystemDb     = 'WORKING_SYSTEM',
    [switch]$SkipKeycloak,
    [switch]$SkipAppServer   # skip the online Application Server (batch-only startups)
)

$ErrorActionPreference = 'Stop'
function Write-Step($m){ Write-Host "`n=== $m ===" -ForegroundColor Cyan }
function Write-Ok  ($m){ Write-Host "  [OK]   $m" -ForegroundColor Green }
function Write-Warn($m){ Write-Host "  [WARN] $m" -ForegroundColor Yellow }
function Write-Err ($m){ Write-Host "  [FAIL] $m" -ForegroundColor Red }

function Test-PortListening([int]$Port){
    $null -ne (Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue)
}

# ---------------------------------------------------------------------------
# 1. Keycloak
# ---------------------------------------------------------------------------
if (-not $SkipKeycloak) {
    Write-Step "1/5 Keycloak (auth) on :$KeycloakPort"
    if (Test-PortListening $KeycloakPort) {
        Write-Ok "Keycloak already listening on :$KeycloakPort"
    } else {
        $kc = Join-Path $KeycloakRoot 'bin\kc.bat'
        if (-not (Test-Path $kc)) { Write-Err "kc.bat not found at $kc"; }
        else {
            $env:KC_HTTP_PORT='8080'; $env:KC_HOSTNAME='localhost'; $env:KC_HOSTNAME_STRICT='false'
            $env:KC_HTTP_ENABLED='true'; $env:KC_PROXY='edge'; $env:KC_HEALTH_ENABLED='true'; $env:KC_DB='dev-file'
            $env:KC_BOOTSTRAP_ADMIN_USERNAME='admin'; $env:KC_BOOTSTRAP_ADMIN_PASSWORD='admin'
            # launch in its own window so it keeps running after this script exits
            Start-Process -FilePath 'cmd.exe' -ArgumentList @(
                '/k', "`"$kc`" start-dev --http-port=8080 --hostname=localhost --hostname-strict=false --db=dev-file"
            ) -WorkingDirectory $KeycloakRoot | Out-Null
            Write-Host "  launching Keycloak, waiting for it to become ready..."
            $ready=$false
            for ($i=0; $i -lt 60; $i++) {
                Start-Sleep -Seconds 2
                try {
                    $r = Invoke-WebRequest "http://localhost:$KeycloakPort/realms/master/.well-known/openid-configuration" -UseBasicParsing -TimeoutSec 3
                    if ($r.StatusCode -eq 200) { $ready=$true; break }
                } catch { }
            }
            if ($ready) { Write-Ok "Keycloak master realm is serving" } else { Write-Warn "Keycloak not confirmed ready (check its window)" }
        }
    }
} else { Write-Step "1/5 Keycloak - SKIPPED" }

# ---------------------------------------------------------------------------
# 2. IIS site/app pool for Control Center
# ---------------------------------------------------------------------------
Write-Step "2/5 IIS Control Center site"
if (Test-PortListening 80) {
    Write-Ok "IIS (port 80) is up - http://localhost/Working/ControlCenter/"
} else {
    try { Start-Service W3SVC -ErrorAction Stop; Write-Ok "Started W3SVC (IIS)" }
    catch { Write-Warn "IIS (W3SVC) not running and could not be started: $($_.Exception.Message)" }
}

# ---------------------------------------------------------------------------
# 3-5. AMT Windows services, in dependency order
# ---------------------------------------------------------------------------
function Ensure-FileControllerServiceName {
    # AmtFileController needs AMTSYSFILECONTROLLER.SERVICENAME = 'FileController' exactly
    try {
        $cur = sqlcmd -S $SqlServer -E -d $SystemDb -h -1 -W -Q "SET NOCOUNT ON; SELECT SERVICENAME FROM AMTSYSFILECONTROLLER WHERE CONTROLLERID=1"
        $cur = ($cur | Select-Object -First 1).Trim()
        if ($cur -cne 'FileController') {
            Write-Warn "AMTSYSFILECONTROLLER.SERVICENAME is '$cur' - correcting to 'FileController'"
            sqlcmd -S $SqlServer -E -d $SystemDb -h -1 -W -Q "SET NOCOUNT ON; UPDATE AMTSYSFILECONTROLLER SET SERVICENAME='FileController' WHERE CONTROLLERID=1" | Out-Null
            Write-Ok "SERVICENAME set to 'FileController'"
        } else { Write-Ok "SERVICENAME already 'FileController'" }
    } catch { Write-Warn "Could not verify SERVICENAME: $($_.Exception.Message)" }
}

function Start-AmtService([string]$Name, [string]$Label){
    $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if (-not $svc) { Write-Err "$Label ($Name) not installed"; return }
    if ($svc.Status -eq 'Running') { Write-Ok "$Label already running"; return }
    try {
        Start-Service -Name $Name -ErrorAction Stop
        Start-Sleep -Seconds 3
        $svc.Refresh()
        if ($svc.Status -eq 'Running') { Write-Ok "$Label started" }
        else { Write-Warn "$Label status = $($svc.Status)" }
    } catch {
        Write-Err "$Label failed to start: $($_.Exception.Message)"
        $bug = "C:\Amt\Working\SystemLogging\$(Get-Date -Format yyyyMMdd)\$($Name.Replace('Amt',''))_BugReport.Log"
        if (Test-Path $bug) { Write-Host "     see: $bug" -ForegroundColor DarkYellow }
    }
}

Write-Step "3/5 AmtFileController (AFC)"
Ensure-FileControllerServiceName
Start-AmtService -Name 'AmtFileController' -Label 'FileController'

Write-Step "4/5 AmtBatchController"
Start-AmtService -Name 'AmtBatchController' -Label 'BatchController'

if (-not $SkipAppServer) {
    Write-Step "5/5 AmtApplicationServer (online)"
    Start-AmtService -Name 'AmtApplicationServer' -Label 'ApplicationServer'
} else { Write-Step "5/5 AmtApplicationServer - SKIPPED (batch-only)" }

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
Write-Step "Summary"
Get-Service AmtFileController,AmtBatchController,AmtApplicationServer -ErrorAction SilentlyContinue |
    Select-Object Status, Name | Format-Table -AutoSize
Write-Host "Control Center: http://localhost/Working/ControlCenter/" -ForegroundColor Green
Write-Host "Keycloak admin: http://localhost:$KeycloakPort/  (admin/admin)" -ForegroundColor Green
Write-Host "If login loops: clear browser cookies for localhost (see script header for the HTTPS fix)." -ForegroundColor DarkGray
