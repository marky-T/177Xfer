$src = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter'
'== code points of non-ASCII chars in our source (distinct)'
$seen = @{}
Get-ChildItem $src -Recurse -Filter *.cs | Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' } | ForEach-Object {
  $t = [IO.File]::ReadAllText($_.FullName)
  foreach ($ch in $t.ToCharArray()) { if ([int]$ch -gt 127) { $k = 'U+{0:X4}' -f [int]$ch; $seen[$k] = 1 + [int]$seen[$k] } }
}
$seen.GetEnumerator() | ForEach-Object { '{0} x{1}' -f $_.Key, $_.Value }
'== same for Jul27 base'
$seen = @{}
Get-ChildItem 'E:\Repos\SsgTrial\_scratch\rd-jul27\SsgConverter\SsgConverter' -Recurse -Filter *.cs | ForEach-Object {
  $t = [IO.File]::ReadAllText($_.FullName)
  foreach ($ch in $t.ToCharArray()) { if ([int]$ch -gt 127) { $k = 'U+{0:X4}' -f [int]$ch; $seen[$k] = 1 + [int]$seen[$k] } }
}
$seen.GetEnumerator() | ForEach-Object { '{0} x{1}' -f $_.Key, $_.Value }
'== which of the 4 Jul27 lines'
Get-ChildItem 'E:\Repos\SsgTrial\_scratch\rd-jul27\SsgConverter\SsgConverter' -Recurse -Filter *.cs | ForEach-Object { $f = $_; $n = 0; foreach ($l in [IO.File]::ReadLines($f.FullName)) { $n++; if ($l -match '[^\x00-\x7F]') { '{0}:{1}' -f $f.Name, $n } } }
'== PDF titles (raw metadata scan)'
foreach ($p in Get-ChildItem 'E:\Repos\SsgTrial\docs\Reference Docs' -Filter *.pdf) {
  $b = [IO.File]::ReadAllBytes($p.FullName); $s = [Text.Encoding]::Latin1.GetString($b, 0, [Math]::Min($b.Length, 400000))
  $m = [regex]::Match($s, '/Title\s*\(([^)]{3,120})\)'); '{0}: {1}' -f $p.Name, $(if ($m.Success) { $m.Groups[1].Value } else { '(no title)' })
}
Get-ChildItem 'E:\Repos\SsgTrial\docs\Reference Docs' | Select-Object -ExpandProperty Name
