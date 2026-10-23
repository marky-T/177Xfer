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
'== our docs and examples mentioning UBOOT or P$JOBC'
Get-ChildItem 'E:\Repos\SsgTrial\SsgConverter\Examples', 'E:\Repos\SsgTrial\SsgConverter\Fixes' -Recurse -File -ErrorAction SilentlyContinue | Select-String -Pattern 'UBOOT|P\$JOBC|STA source' -List | Select-Object -First 8 | ForEach-Object { '{0}:{1}' -f $_.Path.Substring(18), $_.LineNumber }
'== manual: comment images (section 4.5)'
$m = [IO.File]::ReadAllLines('E:\Repos\SsgTrial\docs\Reference Docs\78311784-010.md')
for ($i = 3990; $i -lt 4075; $i++) { if ($m[$i] -match 'omment') { '{0}: {1}' -f ($i + 1), $m[$i].Trim() } }
