@echo off
:: Start the AMT Launcher server (if not already running)
netstat -ano | findstr ":9797" >nul 2>&1
if %errorlevel%==0 (
    echo AMT Launcher server already running on port 9797.
) else (
    echo Starting AMT Launcher server on port 9797...
    start "AMT Launcher Server" /min "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "C:\Amt\Migration\tools\Start-AmtLauncher.ps1"
    timeout /t 2 /nobreak >nul
)

:: Open the guide in the default browser
start "" "C:\Amt\Migration\AMT172-Setup-Guide.html"
