$outFile = "E:\Repos\SsgTrial\docs\_security-log-check2.txt"
Remove-Item $outFile -ErrorAction SilentlyContinue

$start = Get-Date "2026-09-25 16:00:00"
$end   = Get-Date "2026-09-28 08:00:00"

"=== 0. Current audit policy (which categories are actually logged) ===" | Out-File $outFile -Append
auditpol /get /category:* | Out-File $outFile -Append -Width 300

"" | Out-File $outFile -Append
"=== 1. Total Security log record count (sanity check log isn't empty/cleared) ===" | Out-File $outFile -Append
try {
  $secLog = Get-WinEvent -ListLog Security -ErrorAction Stop
  "RecordCount=$($secLog.RecordCount)  OldestRecordTime=$($secLog.OldestRecordNumber)  IsEnabled=$($secLog.IsEnabled)" | Out-File $outFile -Append
} catch { "ERROR: $($_.Exception.Message)" | Out-File $outFile -Append }

"" | Out-File $outFile -Append
"=== 2. Any Security event at all in full weekend window (no Id filter) - count + first/last ===" | Out-File $outFile -Append
$all = Get-WinEvent -FilterHashtable @{LogName='Security'; StartTime=$start; EndTime=$end} -ErrorAction SilentlyContinue
"Count=$($all.Count)" | Out-File $outFile -Append
if ($all.Count -gt 0) {
  $all | Sort-Object TimeCreated | Group-Object Id | Sort-Object Count -Descending | Select-Object Count, Name | Out-File $outFile -Append -Width 300
}

"" | Out-File $outFile -Append
"=== 3. Logon (4624) / Logoff (4634) / Lock-Unlock (4800/4801) - FULL weekend window ===" | Out-File $outFile -Append
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624,4634,4800,4801; StartTime=$start; EndTime=$end} -ErrorAction SilentlyContinue |
  Sort-Object TimeCreated |
  ForEach-Object {
    $acct  = ($_.Message -split "`n" | Select-String 'Account Name:' | Select-Object -Last 1)
    "$($_.TimeCreated)  Id=$($_.Id)  $acct"
  } | Out-File $outFile -Append -Width 300

Write-Host "Done. Output written to $outFile"
