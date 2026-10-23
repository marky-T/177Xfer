$f = 'E:\Repos\SsgTrial\docs\Reference Docs\78311784-010.md'
$lines = [IO.File]::ReadAllLines($f)
$pat = 'skeleton image|image in (a|the) skeleton|images? in the skeleton|asterisk|column 1|\bimage length|80 characters|trailing space|truncat|margin'
$hits = 0
for ($i = 0; $i -lt 1400; $i++) {
  if ($lines[$i] -match $pat) { $hits++; '{0,6}: {1}' -f ($i + 1), $lines[$i].Trim().Substring(0, [Math]::Min(190, $lines[$i].Trim().Length)) }
}
'hits in first 1400 lines: ' + $hits
'--- Section 3.2.x / 5.x headings with output'
for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i] -match '^\s*(5\.\d+(\.\d+)?\.?\s+\*?[A-Z]|2\.[3-9]\.)') { '{0,6}: {1}' -f ($i + 1), $lines[$i].Trim() } }
