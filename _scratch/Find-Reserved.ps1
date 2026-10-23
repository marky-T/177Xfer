$f = 'E:\Repos\SsgTrial\docs\Reference Docs\78311784-010.md'
$l = [IO.File]::ReadAllLines($f)
for ($i = 0; $i -lt $l.Count; $i++) { if ($l[$i] -match 'Table 3.9|Table 3.10|Table 3.11|Reserved Global|reserved global variables') { '{0,6}: {1}' -f ($i + 1), $l[$i].Trim().Substring(0, [Math]::Min(150, $l[$i].Trim().Length)) } }
