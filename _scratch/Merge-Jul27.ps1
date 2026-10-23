$j27 = 'E:\Repos\SsgTrial\_scratch\rd-jul27\SsgConverter\SsgConverter'
$rd = 'E:\Repos\amt-go-net-ref\Migration Tools\SsgConverter\SsgConverter'
$ours = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter'
$out = 'E:\Repos\SsgTrial\_scratch\ssgmerge2'
Remove-Item $out -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force "$out\n" | Out-Null
$lf = { param($src, $dst) [System.IO.File]::WriteAllText($dst, ([System.IO.File]::ReadAllText($src) -replace "`r`n", "`n")) }
foreach ($f in 'SymstreamProcessor.cs', 'SymstreamExpressionMigrator.cs', 'SymstreamExpressionParser.cs') {
  & $lf "$ours\$f" "$out\$f"; & $lf "$j27\$f" "$out\n\base_$f"; & $lf "$rd\$f" "$out\n\rd_$f"
  git merge-file -L ours -L jul27 -L rd "$out\$f" "$out\n\base_$f" "$out\n\rd_$f" 2>&1 | Out-Null
  '{0}: conflicts={1}' -f $f, $LASTEXITCODE
}
"`n== R&D changes since the 27 July release (SymstreamProcessor.cs, jul27 -> develop)"
git diff --no-index --ignore-space-at-eol -U1 "$out\n\base_SymstreamProcessor.cs" "$out\n\rd_SymstreamProcessor.cs" 2>$null | Select-Object -Skip 4 | ForEach-Object { $_.Substring(0, [Math]::Min(170, $_.Length)) }
"`n== conflict hunks"
$l = Get-Content "$out\SymstreamProcessor.cs"
for ($i = 0; $i -lt $l.Count; $i++) {
  if ($l[$i] -like '<<<<<<< *') {
    $j = $i; while ($l[$j] -notlike '>>>>>>> *') { $j++ }
    "-- lines $($i + 1)-$($j + 1)"; $l[$i..$j] | ForEach-Object { '   ' + $_.Substring(0, [Math]::Min(150, $_.Length)) }
  }
}
