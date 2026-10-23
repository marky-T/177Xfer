$ex = 'E:\Repos\SsgTrial\SsgConverter\Examples'
$n = 0
foreach ($f in Get-ChildItem "$ex\Input" -File) {
  $i = 0
  foreach ($l in [IO.File]::ReadLines($f.FullName)) { $i++; if ($l.StartsWith('"')) { $n++; '{0}:{1}: {2}' -f $f.Name, $i, $l.Substring(0, [Math]::Min(80, $l.Length)) } }
}
'lines with a double quote in column 1: ' + $n
$m = 0
foreach ($f in Get-ChildItem "$ex\Input" -File) { $i = 0; foreach ($l in [IO.File]::ReadLines($f.FullName)) { $i++; if ($l -match '(?i)^\*\s*SET\s+(PILO|LBRK|IMGLEN|NSIGN)') { $m++; '{0}:{1}: {2}' -f $f.Name, $i, $l.Trim() } } }
'SET of PILO/LBRK/IMGLEN/NSIGN: ' + $m
'--- ours vs jul27 base: where is the whitespace rule'
git diff --no-index --ignore-space-at-eol -U0 'E:\Repos\SsgTrial\_scratch\rd-jul27\SsgConverter\SsgConverter\SymstreamProcessor.cs' 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter\SymstreamProcessor.cs' | Select-String 'IsNullOrWhiteSpace|IsNullOrEmpty'
'--- Fix-20260820 notes mentioning blank'
Select-String -Path 'E:\Repos\SsgTrial\SsgConverter\Fixes\*.md' -Pattern 'blank|whitespace|IsNullOr' | ForEach-Object { '{0}:{1}: {2}' -f $_.Filename, $_.LineNumber, $_.Line.Trim().Substring(0, [Math]::Min(160, $_.Line.Trim().Length)) }
