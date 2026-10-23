$src = 'E:\Repos\177Xfer-ssgconv\Downloads-20261014'
$j27 = 'E:\Repos\SsgTrial\_scratch\rd-jul27'
$rel = 'E:\Repos\SsgTrial\_scratch\rel-20260821'
foreach ($p in $j27, $rel) { Remove-Item $p -Recurse -Force -ErrorAction SilentlyContinue }
Expand-Archive "$src\SsgConverter Jul27 from AMT178release.zip" $j27
Expand-Archive "$src\SsgConverter-Release-20260821.zip" $rel
'jul27 top: ' + ((Get-ChildItem $j27 | Select-Object -ExpandProperty Name) -join ', ')
'release top: ' + ((Get-ChildItem $rel | Select-Object -ExpandProperty Name) -join ', ')
$lib27 = Get-ChildItem $j27 -Recurse -Directory -Filter SsgConverter | Where-Object { Test-Path "$($_.FullName)\SymstreamProcessor.cs" } | Select-Object -First 1
$libRel = Get-ChildItem $rel -Recurse -File -Filter SymstreamProcessor.cs | Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' } | Select-Object -First 1
$libs = [ordered]@{
  'jul27(AMT178)' = $lib27.FullName
  'release-0821'  = $libRel.DirectoryName
  'ourBase(0908)' = 'E:\Repos\SsgTrial\_scratch\ssgbase'
  'RnD develop'   = 'E:\Repos\amt-go-net-ref\Migration Tools\SsgConverter\SsgConverter'
  'ours now'      = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter'
}
$libs.GetEnumerator() | ForEach-Object { '{0,-14} {1}' -f $_.Key, $_.Value }
function Norm($p) { (Get-Content $p -Raw) -replace "`r`n", "`n" }
$files = 'SymstreamProcessor.cs', 'SymstreamExpressionMigrator.cs', 'SymstreamExpressionParser.cs'
foreach ($f in $files) {
  "`n== $f   (identical after line-ending normalisation?)"
  $names = @($libs.Keys)
  foreach ($a in $names) { $row = foreach ($b in $names) { if ($a -eq $b) { '  -  ' } else { $pa = Join-Path $libs[$a] $f; $pb = Join-Path $libs[$b] $f; if (-not (Test-Path $pa) -or -not (Test-Path $pb)) { 'n/a' } elseif ((Norm $pa) -ceq (Norm $pb)) { 'SAME' } else { 'diff' } }; }; '{0,-14} {1}' -f $a, ($row -join ' | ') }
}
"`nline changes vs jul27 (added/removed, ignoring EOL):"
foreach ($f in $files) { foreach ($k in 'release-0821', 'ourBase(0908)', 'RnD develop', 'ours now') { $s = git diff --no-index --ignore-space-at-eol --numstat (Join-Path $libs['jul27(AMT178)'] $f) (Join-Path $libs[$k] $f) 2>$null; $n = ($s -split '\s+')[0..1] -join '/'; '{0,-32} jul27 -> {1,-14} +/- {2}' -f $f, $k, $(if ($s) { $n } else { 'no difference' }) } }
