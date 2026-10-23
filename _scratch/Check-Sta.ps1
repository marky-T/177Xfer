$p = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter\SymstreamProcessor.cs'
$l = [IO.File]::ReadAllLines($p)
'== each "not used in STA sources" branch: the directive case it sits in'
for ($i = 0; $i -lt $l.Count; $i++) {
  if ($l[$i] -match 'STA sources') {
    $j = $i; while ($j -gt 0 -and $l[$j] -notmatch 'case DirectiveId\.') { $j-- }
    '{0,5}: {1}   <- {2}' -f ($i + 1), $l[$i].Trim(), $l[$j].Trim()
  }
}
'== other source files mentioning STA'
foreach ($f in Get-ChildItem 'E:\Repos\SsgTrial\SsgConverter\Source' -Recurse -Filter *.cs | Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' }) {
  Select-String -Path $f.FullName -Pattern '\bSTA\b' | ForEach-Object { '{0}:{1}: {2}' -f $f.Name, $_.LineNumber, $_.Line.Trim().Substring(0, [Math]::Min(120, $_.Line.Trim().Length)) }
}
'== R&D clone / notes mentioning STA sources or UBOOT / P$JOBC'
Get-ChildItem 'E:\Repos\amt-go-net-ref' -Recurse -Include *.cs, *.md, *.txt -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\(bin|obj|_build)\\' -and $_.Length -lt 3000000 } | Select-String -Pattern 'STA sources|UBOOT|P\$JOBC' -List | Select-Object -First 12 | ForEach-Object { '{0}:{1}: {2}' -f $_.Path.Substring(24), $_.LineNumber, $_.Line.Trim().Substring(0, [Math]::Min(120, $_.Line.Trim().Length)) }
'== our docs / examples mentioning UBOOT or P$JOBC'
Get-ChildItem 'E:\Repos\SsgTrial\docs','E:\Repos\SsgTrial\SsgConverter\Examples' -Recurse -Include *.md, *.txt, *.TXT, *.html -ErrorAction SilentlyContinue | Where-Object { $_.Length -lt 5000000 } | Select-String -Pattern 'UBOOT|P\$JOBC' -List | Select-Object -First 8 | ForEach-Object { '{0}:{1}' -f $_.Path.Substring(18), $_.LineNumber }
'== manual: comment images'
$m = [IO.File]::ReadAllLines('E:\Repos\SsgTrial\docs\Reference Docs\78311784-010.md')
for ($i = 3990; $i -lt 4075; $i++) { if ($m[$i] -match 'omment') { '{0}: {1}' -f ($i + 1), $m[$i].Trim() } }
