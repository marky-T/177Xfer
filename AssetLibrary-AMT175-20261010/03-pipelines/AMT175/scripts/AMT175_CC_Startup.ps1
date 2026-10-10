<#
.SYNOPSIS
  AMT175_CC_Startup - brings up the AMT175 Control Center stack after a reboot.

.DESCRIPTION
  Modelled on Amt/Migration/tools/Federale_CC_Startup.ps1 (AMT172), adapted for the AMT175 lane.
  Order matters:
    1. Keycloak (OIDC auth, http://localhost:8080)  - SHARED single instance; CC login depends on it.
    2. IIS (W3SVC) + AMT175 app pools               - serves http://localhost/AMT175/ControlCenter
    3. AMT175 Windows services (File/Batch/App)     - Phase 4; only started if they exist yet.

  Hard rules honoured:
   - ONE Keycloak on 8080 (never 8081). If 8080 is already listening, it is NOT restarted.
   - Keycloak launched from the WORKING (-fresh) install; the old C:\Tools\keycloak-25.0.6 tree is corrupted.
   - AMT172 (Working) lane services are NOT touched by this script.

  MUST be run ELEVATED for the IIS/app-pool and (later) AMT service starts. Keycloak itself does not need admin.

  Usage (elevated PowerShell):
    powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Amt\Parallel\AMT175\scripts\AMT175_CC_Startup.ps1"
#>

#Requires -RunAsAdministrator
[CmdletBinding()]
param(
    [string]$KeycloakRoot = 'C:\Tools\keycloak-25.0.6-fresh\keycloak-25.0.6',
    [int]   $KeycloakPort = 8080,
    [string]$CcUrl        = 'http://localhost/AMT175/ControlCenter',
    [string[]]$AppPools   = @('AMT175_ControlCenterPool','AMT175_ControlCenterBLPool'),
    [switch]$SkipKeycloak
)

$ErrorActionPreference = 'Stop'
function Write-Step($m){ Write-Host "`n=== $m ===" -ForegroundColor Cyan }
function Write-Ok  ($m){ Write-Host "  [OK]   $m" -ForegroundColor Green }
function Write-Warn($m){ Write-Host "  [WARN] $m" -ForegroundColor Yellow }
function Write-Err ($m){ Write-Host "  [FAIL] $m" -ForegroundColor Red }
function Test-PortListening([int]$Port){ $null -ne (Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue) }

# ---------------------------------------------------------------------------
# 1. Keycloak (shared, single instance on 8080)
# ---------------------------------------------------------------------------
if (-not $SkipKeycloak) {
    Write-Step "1/3 Keycloak (auth) on :$KeycloakPort"
    if (Test-PortListening $KeycloakPort) {
        Write-Ok "Keycloak already listening on :$KeycloakPort (not restarting - single-instance rule)"
    } else {
        $kc = Join-Path $KeycloakRoot 'bin\kc.bat'
        if (-not (Test-Path $kc)) { Write-Err "kc.bat not found at $kc" }
        else {
            $env:KC_BOOTSTRAP_ADMIN_USERNAME='admin'; $env:KC_BOOTSTRAP_ADMIN_PASSWORD='admin'
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
} else { Write-Step "1/3 Keycloak - SKIPPED" }

# ---------------------------------------------------------------------------
# 2. IIS + AMT175 app pools
# ---------------------------------------------------------------------------
Write-Step "2/3 IIS + AMT175 Control Center app pools"
if (-not (Test-PortListening 80)) {
    try { Start-Service W3SVC -ErrorAction Stop; Write-Ok "Started W3SVC (IIS)" }
    catch { Write-Warn "IIS (W3SVC) could not be started: $($_.Exception.Message)" }
} else { Write-Ok "IIS (port 80) already up" }

Import-Module WebAdministration -ErrorAction SilentlyContinue
foreach ($p in $AppPools) {
    if (Test-Path "IIS:\AppPools\$p") {
        $state = (Get-WebAppPoolState -Name $p).Value
        if ($state -ne 'Started') { Start-WebAppPool -Name $p; Write-Ok "Started app pool $p" }
        else { Write-Ok "App pool $p already started" }
    } else { Write-Warn "App pool $p not found" }
}

# ---------------------------------------------------------------------------
# 3. AMT175 Windows services (Phase 4 - only if they exist)
# ---------------------------------------------------------------------------
Write-Step "3/3 AMT175 Windows services (Phase 4)"
$amt175Svc = Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'Amt175' }
if (-not $amt175Svc) {
    Write-Warn "No AMT175-specific services installed yet (File/Batch/App controllers are configured in Phase 4 via Control Center)."
} else {
    foreach ($s in $amt175Svc) {
        if ($s.Status -ne 'Running') { try { Start-Service $s.Name; Write-Ok "Started $($s.Name)" } catch { Write-Err "$($s.Name): $($_.Exception.Message)" } }
        else { Write-Ok "$($s.Name) already running" }
    }
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
Write-Step "Summary"
Write-Host "Keycloak admin : http://localhost:$KeycloakPort/  (admin/admin)" -ForegroundColor Green
Write-Host "AMT175 CC      : $CcUrl" -ForegroundColor Green
Write-Host "AMT172 (Working) is untouched by this script." -ForegroundColor DarkGray
try {
    $r = curl.exe -s -S -i --max-time 20 $CcUrl 2>&1
    $status = ($r | Select-String '^HTTP/' | Select-Object -First 1).ToString()
    $col = if ($status -match '30[12]|200') { 'Green' } else { 'Yellow' }
    Write-Host "AMT175 CC probe: $status" -ForegroundColor $col
} catch { Write-Warn "CC probe failed: $($_.Exception.Message)" }
