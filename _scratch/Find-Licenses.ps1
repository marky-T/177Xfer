$out = 'E:\Repos\SsgTrial\_scratch\lic-search.txt'
$roots = 'C:\Amt\lic', 'E:\Amt', 'E:\Repos\Federale_InternalRelease', 'E:\Repos\z-old\AMT', 'E:\Repos\AMT'
$lines = foreach ($r in $roots) {
  if (-not (Test-Path $r)) { "MISSING $r"; continue }
  Get-ChildItem $r -Recurse -File -Include '*.lic' -ErrorAction SilentlyContinue |
    ForEach-Object { '{0,-95} {1,7:N0}  {2:yyyy-MM-dd HH:mm}  {3}' -f $_.FullName, $_.Length, $_.LastWriteTime, (Get-FileHash $_.FullName -Algorithm SHA256).Hash.Substring(0, 10) }
}
$lines | Out-File $out -Width 300
"lines: $(@($lines).Count)"
