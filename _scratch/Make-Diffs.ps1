$j = 'E:\Repos\SsgTrial\_scratch\rd-jul27\SsgConverter\SsgConverter'
$o = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter'
$d = 'E:\Repos\SsgTrial\_scratch\diffs'
New-Item -ItemType Directory -Force $d | Out-Null
foreach ($f in 'SymstreamProcessor.cs', 'SymstreamExpressionMigrator.cs', 'SymstreamExpressionParser.cs') {
  git diff --no-index --ignore-space-at-eol -U2 "$j\$f" "$o\$f" 2>$null | Select-Object -Skip 4 | Set-Content "$d\$f.diff" -Encoding utf8
  '{0}: {1} lines' -f $f, (Get-Content "$d\$f.diff").Count
}
