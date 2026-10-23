$out = 'E:\Repos\SsgTrial\_scratch\ssgfix2\out'
$gold = 'E:\Repos\SsgTrial\SsgConverter\Examples\Output'
foreach ($n in 'ARCHIFORMAT', 'ARCHISEPARE', 'CFH-COPY', 'CHAB100_ASCII', 'EXTEUR', 'UNLOADIS_MULTI') {
  "=================== $n"
  git diff --no-index --unified=0 "$gold\$n.ps1" "$out\$n.ps1" | Select-Object -Skip 4 -First 60
}
