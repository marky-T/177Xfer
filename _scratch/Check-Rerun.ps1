$day = Get-Date -Format 'yyyyMMdd'
$logs = "E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Logs\$day"
$bc = Get-Content (Join-Path $logs 'FederaleBatchController.Log') | Where-Object { $_ -match 'CFH_COPY_ASCII' } | Select-Object -Last 3 | ForEach-Object { ($_ -replace '\s+', ' ').Trim() }
'--- BatchController (last CFH_COPY_ASCII lines)'; $bc
$reports = @(Get-ChildItem $logs -Filter '*_BugReport.Log' | Sort-Object LastWriteTime)
'--- bug reports now: {0} (baseline was 3)' -f $reports.Count
$reports | ForEach-Object { '{0:HH:mm:ss} {1,7:N0} {2}' -f $_.LastWriteTime, $_.Length, $_.Name }
$x = 'E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Extracts\OUTASC.DAT'
'--- OUTASC.DAT: ' + $(if (Test-Path $x) { '{0:HH:mm:ss}, {1} bytes' -f (Get-Item $x).LastWriteTime, (Get-Item $x).Length } else { 'not written' })
