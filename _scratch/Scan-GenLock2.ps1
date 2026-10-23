$f = 'E:\Amt\Lion\LionGeneratorBusinessLogic.dll'
$s = [Text.Encoding]::Unicode.GetString([IO.File]::ReadAllBytes($f))
$all = [regex]::Matches($s, '[\x20-\x7E]{4,}') | ForEach-Object Value
$i = 0
foreach ($x in $all) {
  if ($x -match 'Another process|is generating|already running|GENERATING|LOCK|BUSY|INUSE|ACTIVE|REVAPP|APPSTATUS|GENSTATUS|UPDATE |SELECT |DELETE |INSERT ') { '{0,5}: {1}' -f $i, $x }
  $i++
}
"== neighbours of 'Another process'"
for ($k = 0; $k -lt $all.Count; $k++) { if ($all[$k] -match 'Another process') { ($k - 6)..($k + 6) | Where-Object { $_ -ge 0 -and $_ -lt $all.Count } | ForEach-Object { '{0,5}: {1}' -f $_, $all[$_] }; '--' } }
