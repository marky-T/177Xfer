$day = Get-Date -Format 'yyyyMMdd'
$logs = "E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Logs\$day"
$bc = Join-Path $logs 'FederaleBatchController.Log'
$out = 'E:\Repos\SsgTrial\_scratch\bc-since-start.txt'
$all = Get-Content $bc
$idx = ($all | Select-String 'AmtService started at').LineNumber | Select-Object -Last 1
$tail = $all[($idx - 1)..($all.Count - 1)] | Where-Object { $_ -match '^\d{8}' } | ForEach-Object { ($_ -replace '\s+', ' ').Trim() }
"batch log last write: $((Get-Item $bc).LastWriteTime)   now: $(Get-Date -Format 'HH:mm:ss')" | Out-File $out
$tail | Select-Object -Last 40 | Out-File $out -Append -Width 400
"--- new log files in the last 15 minutes under $logs"  | Out-File $out -Append
Get-ChildItem $logs -File | Where-Object LastWriteTime -gt (Get-Date).AddMinutes(-15) | Sort-Object LastWriteTime |
  ForEach-Object { '{0:HH:mm:ss} {1,9:N0} {2}' -f $_.LastWriteTime, $_.Length, $_.Name } | Out-File $out -Append
"--- Extracts" | Out-File $out -Append
Get-ChildItem 'E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Extracts' -File | ForEach-Object { '{0:HH:mm:ss} {1,9:N0} {2}' -f $_.LastWriteTime, $_.Length, $_.Name } | Out-File $out -Append
Get-Content $out | Select-Object -First 3
