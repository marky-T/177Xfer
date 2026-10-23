$outFile = "E:\Repos\SsgTrial\docs\_security-log-check3.txt"
Remove-Item $outFile -ErrorAction SilentlyContinue

"=== Security log retained time span (oldest vs newest record actually present) ===" | Out-File $outFile -Append
$oldest = Get-WinEvent -LogName Security -Oldest -MaxEvents 1 -ErrorAction SilentlyContinue
$newest = Get-WinEvent -LogName Security -MaxEvents 1 -ErrorAction SilentlyContinue
"Oldest record TimeCreated: $($oldest.TimeCreated)" | Out-File $outFile -Append
"Newest record TimeCreated: $($newest.TimeCreated)" | Out-File $outFile -Append

"" | Out-File $outFile -Append
"=== Log file size / max size / retention mode ===" | Out-File $outFile -Append
$log = Get-WinEvent -ListLog Security
"MaximumSizeInBytes: $($log.MaximumSizeInBytes)" | Out-File $outFile -Append
"FileSize: $($log.FileSize)" | Out-File $outFile -Append
"LogMode: $($log.LogMode)" | Out-File $outFile -Append
wevtutil gl Security | Out-File $outFile -Append

Write-Host "Done. Output written to $outFile"
