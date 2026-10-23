$fx = 'E:\Repos\SsgTrial\SsgConverter\Fixes'
Get-ChildItem $fx | ForEach-Object { '{0}  {1} bytes' -f $_.Name, $_.Length }
foreach ($f in Get-ChildItem $fx -Filter *.md) {
  "`n=== $($f.Name)"
  Select-String -Path $f.FullName -Pattern '^#{1,3} ' | ForEach-Object { '{0,4}: {1}' -f $_.LineNumber, $_.Line }
}
"`n=== diff stats vs the 27 July AMT 178 base (ignoring line endings)"
$j = 'E:\Repos\SsgTrial\_scratch\rd-jul27\SsgConverter\SsgConverter'
$o = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter'
$r = 'E:\Repos\amt-go-net-ref\Migration Tools\SsgConverter\SsgConverter'
foreach ($f in 'SymstreamProcessor.cs', 'SymstreamExpressionMigrator.cs', 'SymstreamExpressionParser.cs') {
  $a = git diff --no-index --ignore-space-at-eol --numstat "$j\$f" "$o\$f" 2>$null
  $b = git diff --no-index --ignore-space-at-eol --numstat "$r\$f" "$o\$f" 2>$null
  '{0,-34} vs jul27: {1}   vs R&D develop: {2}' -f $f, (($a -split '\s+')[0..1] -join '/'), (($b -split '\s+')[0..1] -join '/')
}
"`n=== hunk headers vs jul27 (Processor)"
git diff --no-index --ignore-space-at-eol -U0 "$j\SymstreamProcessor.cs" "$o\SymstreamProcessor.cs" 2>$null | Select-String '^@@' | ForEach-Object { $_.Line }
"`n=== hunk headers vs jul27 (Migrator)"
git diff --no-index --ignore-space-at-eol -U0 "$j\SymstreamExpressionMigrator.cs" "$o\SymstreamExpressionMigrator.cs" 2>$null | Select-String '^@@' | ForEach-Object { $_.Line }
"`n=== hunk headers vs jul27 (Parser)"
git diff --no-index --ignore-space-at-eol -U0 "$j\SymstreamExpressionParser.cs" "$o\SymstreamExpressionParser.cs" 2>$null | Select-String '^@@' | ForEach-Object { $_.Line }
