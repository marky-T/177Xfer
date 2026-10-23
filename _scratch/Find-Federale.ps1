$root = 'E:\Repos\SsgTrial\SsgConverter\Release-RnD-20261014'
foreach ($term in 'Federale', 'ASSURFED', 'AFBUS', 'FA_AFBUS') {
  "== $term (case-insensitive)"
  $hits = Get-ChildItem $root -Recurse -File | Select-String -Pattern $term
  if (-not $hits) { 'none' } else { $hits | ForEach-Object { '{0}:{1}: {2}' -f $_.Path.Substring($root.Length + 1), $_.LineNumber, $_.Line.Trim().Substring(0, [Math]::Min(150, $_.Line.Trim().Length)) } }
}
