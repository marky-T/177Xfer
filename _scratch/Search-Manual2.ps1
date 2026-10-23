$f = 'E:\Repos\SsgTrial\docs\Reference Docs\78311784-010.md'
$lines = [IO.File]::ReadAllLines($f)
$pat = '\bblanks?\b|does not begin with|not begin with an asterisk|written to the output|output image|passed to the output|copied to the output|data image|text image'
$hits = 0
for ($i = 0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match $pat) {
    $hits++
    if ($hits -le 70) { '{0,6}: {1}' -f ($i + 1), $lines[$i].Trim().Substring(0, [Math]::Min(200, $lines[$i].Trim().Length)) }
  }
}
'total hits: ' + $hits
