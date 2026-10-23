$out = 'E:\Repos\SsgTrial\_scratch\ssgfix2\out'
$gold = 'E:\Repos\SsgTrial\SsgConverter\Examples\Output'
foreach ($n in 'ARCHIFORMAT', 'CFH-COPY_ASCII', 'TAPELD_ASCII', 'LOADIS_MULTI') {
  "=================== $n"
  git diff --no-index --unified=1 "$gold\$n.ps1" "$out\$n.ps1" | Select-Object -First 70
}
