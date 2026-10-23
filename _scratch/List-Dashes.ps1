$base = 'E:\Repos\SsgTrial\_scratch\rd-jul27\SsgConverter\SsgConverter'
$ours = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter'
foreach ($f in 'SymstreamProcessor.cs', 'SymstreamExpressionMigrator.cs', 'SymstreamExpressionParser.cs') {
  $bl = @([IO.File]::ReadAllLines("$base\$f") | Where-Object { $_ -match [char]0x2014 } | ForEach-Object { $_.Trim() })
  $n = 0
  foreach ($l in [IO.File]::ReadLines("$ours\$f")) {
    $n++
    if ($l -match [char]0x2014) { '{0}:{1} {2}: {3}' -f $f, $n, $(if ($bl -contains $l.Trim()) { 'R&D' } else { 'OURS' }), $l.Trim().Substring(0, [Math]::Min(110, $l.Trim().Length)) }
  }
}
'--- BOM / line endings of ours'
foreach ($f in 'SymstreamProcessor.cs', 'SymstreamExpressionMigrator.cs', 'SymstreamExpressionParser.cs') {
  $b = [IO.File]::ReadAllBytes("$ours\$f"); $crlf = 0; for ($i = 1; $i -lt $b.Length; $i++) { if ($b[$i] -eq 10 -and $b[$i - 1] -eq 13) { $crlf++ } }
  '{0}: BOM={1} CRLF={2} size={3}' -f $f, ($b[0] -eq 0xEF -and $b[1] -eq 0xBB), $crlf, $b.Length
}
