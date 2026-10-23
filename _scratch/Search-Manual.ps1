$f = 'E:\Repos\SsgTrial\docs\Reference Docs\78311784-010.md'
$lines = [IO.File]::ReadAllLines($f)
'total lines: ' + $lines.Count
$pat = 'blank line|null line|empty line|blank card|blank image|entirely blank|all blank|only blank|consist[a-z]* of blanks|trailing blank|lines? that (is|are) blank|spaces only|zero-length'
for ($i = 0; $i -lt $lines.Count; $i++) {
  if ($lines[$i] -match $pat) {
    $s = [Math]::Max(0, $i - 2); $e = [Math]::Min($lines.Count - 1, $i + 3)
    "--- line $($i + 1) ---"
    $lines[$s..$e] | ForEach-Object { $_.Substring(0, [Math]::Min(260, $_.Length)) }
  }
}
