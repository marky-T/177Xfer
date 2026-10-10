# Install FileController
$fcExe = "C:\Amt\Working\AMTTools\FileController\AmtFileController.exe"
$fcSvc = "AMT FileController"
sc.exe delete $fcSvc 2>$null
sc.exe create $fcSvc binpath= "`"$fcExe`" /SERVICE" start= auto DisplayName= "AMT FileController"
if ($LASTEXITCODE -eq 0) { Write-Host "FileController install: OK" } else { Write-Host "FileController install: FAILED" }

# Start FileController first (AppServer depends on it)
Start-Service $fcSvc -ErrorAction SilentlyContinue
Start-Sleep -Seconds 4
Write-Host "FileController status: $((Get-Service $fcSvc).Status)"

# Start ApplicationServer
Start-Service "AmtApplicationServer" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 4
Write-Host "ApplicationServer status: $((Get-Service 'AmtApplicationServer').Status)"

if ((Get-Service 'AmtApplicationServer').Status -ne 'Running') {
    Write-Host "AppServer did not start - last 3 errors from event log:"
    Get-EventLog -LogName Application -Source "AmtApplicationServer" -Newest 3 |
        ForEach-Object { Write-Host "  $($_.TimeGenerated): $($_.Message.Substring(0,[Math]::Min(300,$_.Message.Length)))" }
}
Write-Host "--- Done. Press Enter to close ---"
Read-Host
