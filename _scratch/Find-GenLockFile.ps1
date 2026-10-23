"== files written since 15 Oct 17:00 under the generation set folders (excluding generated sources)"
foreach ($root in 'E:\AMT_Work\Apps177', 'E:\Amt\Lion', "$env:TEMP", 'C:\ProgramData') {
  if (-not (Test-Path $root)) { continue }
  Get-ChildItem $root -Recurse -File -Force -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -gt [datetime]'2026-10-15 17:00' -and $_.Extension -notin '.cs', '.dll', '.pdb', '.json', '.xml', '.cache' -and $_.FullName -notmatch '\\(obj|bin)\\' -and ($root -notmatch 'TEMP|ProgramData' -or $_.Name -match 'lion|amt|gen|lock') } |
    Select-Object -First 40 FullName, Length, LastWriteTime | Format-Table -AutoSize | Out-String -Width 250
}
"== lock-looking files anywhere under E:\AMT_Work and E:\Amt"
Get-ChildItem E:\AMT_Work, E:\Amt -Recurse -File -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'lock|\.lck$|generating|busy|\.pid$' } |
  Select-Object FullName, Length, LastWriteTime | Format-Table -AutoSize | Out-String -Width 250
