$out = 'E:\Repos\SsgTrial\_scratch\reo-log-search2.txt'
$since = (Get-Date).AddHours(-3)
$lines = @()
$lines += '--- recently written files under E:\Amt (depth 4)'
$lines += Get-ChildItem 'E:\Amt' -Recurse -Depth 4 -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt $since } |
  ForEach-Object { '{0:HH:mm:ss} {1,9:N0} {2}' -f $_.LastWriteTime, $_.Length, $_.FullName }
$lines += '--- sub-folders of Reorganize'
$lines += Get-ChildItem 'E:\Amt\AMTTools\Reorganize' -Directory -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }
$lines += '--- E:\Amt top level'
$lines += Get-ChildItem 'E:\Amt' -ErrorAction SilentlyContinue | ForEach-Object { '{0,-4} {1}' -f $(if ($_.PSIsContainer) { 'dir' } else { 'file' }), $_.Name }
$lines | Out-File $out -Width 300
"lines: $($lines.Count)"
