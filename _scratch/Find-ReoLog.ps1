$out = 'E:\Repos\SsgTrial\_scratch\reo-log-search.txt'
$since = (Get-Date).AddMinutes(-90)
$spots = 'E:\Amt\AMTTools\Reorganize', 'E:\Amt\AMTTools', 'E:\Amt', 'E:\Repos\Federale_InternalRelease\AmtTools',
  'E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Logs\20261020', "$env:LOCALAPPDATA", "$env:TEMP"
$lines = foreach ($s in $spots) {
  if (-not (Test-Path $s)) { continue }
  Get-ChildItem $s -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt $since -and $_.Name -match 'reo|reorg|licen|\.log$|\.txt$' } |
    ForEach-Object { '{0:HH:mm:ss} {1,9:N0} {2}' -f $_.LastWriteTime, $_.Length, $_.FullName }
}
$lines | Out-File $out -Width 300
"matches: $(@($lines).Count)"
