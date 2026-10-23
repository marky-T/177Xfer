$rd = 'E:\Repos\amt-go-net-ref\Migration Tools\SsgConverter\SsgConverter'
$ours = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter'
$base = 'E:\Repos\SsgTrial\_scratch\ssgbase'
$out = 'E:\Repos\SsgTrial\_scratch\ssgmerge'
Remove-Item $out -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $out | Out-Null
foreach ($f in 'SymstreamProcessor.cs', 'SymstreamExpressionMigrator.cs', 'SymstreamExpressionParser.cs') {
  Copy-Item "$ours\$f" "$out\$f"
  # git merge-file merges base->theirs changes into the first file; exit code = number of conflicts
  git merge-file -L ours -L base -L rd "$out\$f" "$base\$f" "$rd\$f" 2>&1 | Out-Null
  $conf = $LASTEXITCODE
  $markers = (Select-String -Path "$out\$f" -Pattern '^<<<<<<< ' | Measure-Object).Count
  '{0}: conflicts={1} markers={2}' -f $f, $conf, $markers
}
'--- conflict hunks'
foreach ($f in 'SymstreamProcessor.cs', 'SymstreamExpressionMigrator.cs', 'SymstreamExpressionParser.cs') {
  $l = Get-Content "$out\$f"
  for ($i = 0; $i -lt $l.Count; $i++) {
    if ($l[$i] -like '<<<<<<< *') {
      $j = $i; while ($l[$j] -notlike '>>>>>>> *') { $j++ }
      "== $f lines $($i + 1)-$($j + 1)"; $l[$i..$j] | ForEach-Object { '   ' + $_.Substring(0, [Math]::Min(150, $_.Length)) }
    }
  }
}
