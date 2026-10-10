<#
.SYNOPSIS
  Create a temporary Keycloak admin via bootstrap-admin, safely.

.DESCRIPTION
  Sets JAVA_HOME/Path, detects a Keycloak server already listening on :8080
  (which locks the dev H2 DB and makes bootstrap-admin fail), offers to stop it,
  waits for the lock to clear, then runs `kc.bat bootstrap-admin user`.

  Shared across AMT lanes (AMT172/AMT175/AMT177) - the temporary admin lands in
  the Keycloak `master` realm, not in `amtrealm`.

.NOTES
  Verified 2026-09-02 on Keycloak 26.2.5 / JDK 21. The server is STOPPED after
  bootstrap-admin exits - start it again with `bin\kc.bat start-dev`.
#>
[CmdletBinding()]
param(
    [string]$JavaHome = "C:\Program Files\Microsoft\jdk-21.0.11.10-hotspot",
    [string]$KcRoot   = "C:\Keycloak\keycloak-26.2.5",
    [int]$Port        = 8080
)

$env:JAVA_HOME = $JavaHome
$env:Path = "$env:JAVA_HOME\bin;$env:Path"

# 1) Java present?
if (-not (Test-Path "$env:JAVA_HOME\bin\java.exe")) {
    Write-Host "JAVA_HOME invalid: $env:JAVA_HOME" -ForegroundColor Red; return
}

# 2) start-dev running? It locks the dev H2 DB -> offer to stop it.
$listener = Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue
if ($listener) {
    $kcPid = ($listener | Select-Object -First 1).OwningProcess
    $proc  = Get-Process -Id $kcPid -ErrorAction SilentlyContinue
    Write-Host "Keycloak is running on :$Port (PID $kcPid, $($proc.ProcessName)) - it locks the dev H2 DB." -ForegroundColor Yellow
    $ans = Read-Host "Stop it so bootstrap-admin can run? (y/N)"
    if ($ans -notmatch '^(y|yes)$') {
        Write-Host "Left running - bootstrap-admin aborted." -ForegroundColor Yellow; return
    }
    Write-Host "Stopping PID $kcPid..." -ForegroundColor Cyan
    Stop-Process -Id $kcPid -Force -ErrorAction SilentlyContinue
    for ($i = 1; $i -le 12; $i++) {
        Start-Sleep -Seconds 1
        if (-not (Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue)) { break }
    }
    if (Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue) {
        Write-Host ":$Port still in use after stop - check manually." -ForegroundColor Red; return
    }
    Write-Host "Stopped. Port $Port free." -ForegroundColor Green
}

# 3) Bootstrap the temporary admin (prompts for username + password).
Write-Host "Running bootstrap-admin (use a NEW username e.g. tempadmin2 + password)..." -ForegroundColor Cyan
Set-Location $KcRoot
& .\bin\kc.bat bootstrap-admin user
