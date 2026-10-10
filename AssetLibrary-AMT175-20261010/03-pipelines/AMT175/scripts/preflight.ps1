# Preflight for AMT175 parallel lane
$errors = @()

# 1. Ports must be free
foreach ($port in 5175, 7175) {
  if ((Test-NetConnection localhost -Port $port -WarningAction SilentlyContinue).TcpTestSucceeded) {
    $errors += "Port $port already in use"
  }
}

# 2. No Sys.ini above the lane root (search-up isolation)
foreach ($p in "C:\Amt\Sys.ini", "C:\Amt\Parallel\Sys.ini", "C:\Sys.ini") {
  if (Test-Path $p) { $errors += "Rogue Sys.ini at $p (breaks lane search-up)" }
}

# 3. AMTSYSTEM contains both lane paths, semi-colon separated, no spaces
$amtsys = [Environment]::GetEnvironmentVariable("AMTSYSTEM", "Machine")
if (-not $amtsys) { $errors += "AMTSYSTEM (Machine) is not set" }
elseif ($amtsys -match "; " -or $amtsys -match " ;") {
  $errors += "AMTSYSTEM contains spaces around ; -- remove them (AICVC)"
}
elseif ($amtsys -notmatch "C:\\Amt\\Parallel\\AMT172" -or $amtsys -notmatch "C:\\Amt\\Parallel\\AMT175") {
  $errors += "AMTSYSTEM must list BOTH lane paths (found: $amtsys)"
}

# 4. .NET SDK 10.0.203 exact
$sdk = dotnet --list-sdks | Select-String "^10\.0\.203"
if (-not $sdk) { $errors += ".NET SDK 10.0.203 not installed (global.json requires this exact version)" }

# 5. Keycloak reachable on 8080
try {
  $r = Invoke-WebRequest -UseBasicParsing http://localhost:8080/realms/master -TimeoutSec 3
  if ($r.StatusCode -ne 200) { $errors += "Keycloak not responding on 8080" }
} catch { $errors += "Keycloak not reachable on http://localhost:8080" }

if ($errors.Count -eq 0) { Write-Host "PREFLIGHT OK" -ForegroundColor Green }
else { $errors | ForEach-Object { Write-Host "FAIL: $_" -ForegroundColor Red }; exit 1 }
