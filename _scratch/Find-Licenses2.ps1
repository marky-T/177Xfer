$out = 'E:\Repos\SsgTrial\_scratch\lic-search2.txt'
# Shallow, known places only (a full recursive scan of the big trees is slow).
$spots = 'C:\Amt\lic', 'E:\Amt', 'E:\Amt\License', 'E:\Amt\Lion', 'E:\Amt\AMTTools', 'E:\Amt\AMTTools\Reorganize',
  'E:\Repos\Federale_InternalRelease', 'E:\Repos\Federale_InternalRelease\AmtTools', 'E:\Repos\Federale_InternalRelease\AmtTools\Reorganize',
  'E:\Repos\z-old\AMT', 'E:\Repos\z-old\AMT\License', 'E:\Repos\AMT'
$lines = foreach ($s in $spots) {
  if (-not (Test-Path $s)) { "MISSING  $s"; continue }
  $f = Get-ChildItem $s -File -Filter '*.lic' -ErrorAction SilentlyContinue
  if (-not $f) { "none     $s"; continue }
  foreach ($x in $f) { '{0,-70} {1,6:N0} B  {2:yyyy-MM-dd}  {3}' -f $x.FullName, $x.Length, $x.LastWriteTime, (Get-FileHash $x.FullName -Algorithm SHA256).Hash.Substring(0, 10) }
}
$lines | Out-File $out -Width 300
"written: $out ($(@($lines).Count) lines)"
