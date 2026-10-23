$outFile = "E:\Repos\SsgTrial\docs\_qualys-log-check.txt"
Remove-Item $outFile -ErrorAction SilentlyContinue

"=== Qualys Agent directory listing (files modified since Fri 9/25) ===" | Out-File $outFile -Append
$since = Get-Date "2026-09-25 00:00:00"
Get-ChildItem 'C:\ProgramData\Qualys' -Recurse -ErrorAction SilentlyContinue |
  Where-Object { -not $_.PSIsContainer -and $_.LastWriteTime -ge $since } |
  Select-Object FullName, Length, LastWriteTime |
  Sort-Object LastWriteTime |
  Format-Table -AutoSize | Out-File $outFile -Append -Width 300

"" | Out-File $outFile -Append
"=== Grep those files for 'Lion' (case-insensitive) ===" | Out-File $outFile -Append
Get-ChildItem 'C:\ProgramData\Qualys' -Recurse -ErrorAction SilentlyContinue |
  Where-Object { -not $_.PSIsContainer -and $_.LastWriteTime -ge $since } |
  ForEach-Object {
    try {
      Select-String -Path $_.FullName -Pattern 'Lion' -ErrorAction SilentlyContinue |
        ForEach-Object { "$($_.Path):$($_.LineNumber): $($_.Line.Trim())" }
    } catch {}
  } | Out-File $outFile -Append -Width 300

"" | Out-File $outFile -Append
"=== Grep same files for delete/remove/quarantine keywords, narrow window context ===" | Out-File $outFile -Append
Get-ChildItem 'C:\ProgramData\Qualys' -Recurse -ErrorAction SilentlyContinue |
  Where-Object { -not $_.PSIsContainer -and $_.LastWriteTime -ge $since } |
  ForEach-Object {
    try {
      Select-String -Path $_.FullName -Pattern 'delete|remove|quarantine|clean' -ErrorAction SilentlyContinue |
        ForEach-Object { "$($_.Path):$($_.LineNumber): $($_.Line.Trim())" }
    } catch {}
  } | Out-File $outFile -Append -Width 300

Write-Host "Done. Output written to $outFile"
