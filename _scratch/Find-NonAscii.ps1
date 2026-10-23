$src = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter'
'== mojibake-looking characters in our source (file:line: text)'
Get-ChildItem $src -Recurse -Filter *.cs | Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' } | ForEach-Object {
  $f = $_; $n = 0
  foreach ($line in [IO.File]::ReadLines($f.FullName)) { $n++; if ($line -match '[^\x00-\x7F]') { '{0}:{1}: {2}' -f $f.Name, $n, $line.Trim().Substring(0, [Math]::Min(120, $line.Trim().Length)) } }
}
'== non-ASCII in the 27 July base and R&D develop for the same files'
foreach ($d in 'E:\Repos\SsgTrial\_scratch\rd-jul27\SsgConverter\SsgConverter', 'E:\Repos\amt-go-net-ref\Migration Tools\SsgConverter\SsgConverter') {
  $c = 0; Get-ChildItem $d -Recurse -Filter *.cs | Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' } | ForEach-Object { foreach ($line in [IO.File]::ReadLines($_.FullName)) { if ($line -match '[^\x00-\x7F]') { $c++ } } }
  '{0}: {1} lines' -f $d, $c
}
'== manuals (pdf/docx) under docs'
Get-ChildItem 'E:\Repos\SsgTrial\docs' -Recurse -Include *.pdf, *.docx -ErrorAction SilentlyContinue | Where-Object { $_.FullName -match 'SSG|Unisys|Symbiont|Stream|Reference' } | Select-Object -First 40 | ForEach-Object { '{0,10}  {1}' -f $_.Length, $_.FullName.Substring(24) }
