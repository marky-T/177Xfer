$root = 'E:\Repos\SsgTrial\_scratch'
$ex = 'E:\Repos\SsgTrial\SsgConverter\Examples'
$v = "$root\ssgvarA"
$o = "$v\out"
Remove-Item $o -Recurse -Force -ErrorAction SilentlyContinue; New-Item -ItemType Directory $o | Out-Null
dotnet "$v\Console\SsgConverterConsole.dll" /INPUT:"$ex\Input" /OUTPUT:"$o" /CONTINUEONERROR:TRUE /VERBOSE:2 /ENABLELOGFILE:TRUE /LOGFILE:"$o" 2>&1 | Select-String 'Conversion complete|Error converting' | ForEach-Object { $_.Line }
$diffs = 0
foreach ($g in Get-ChildItem "$root\ssgmerged\out" -Filter *.ps1) {
  $a = ([IO.File]::ReadAllText($g.FullName)) -replace "`r`n", "`n"; $b = ([IO.File]::ReadAllText("$o\$($g.Name)")) -replace "`r`n", "`n"
  if ($a -cne $b) { $diffs++; $st = git diff --no-index --ignore-space-at-eol --numstat $g.FullName "$o\$($g.Name)"; '{0}: DIFFERENT  {1}' -f $g.BaseName, ($st -split '\s+')[0..1] -join '/' }
}
'programs with differing output (IsNullOrEmpty vs IsNullOrWhiteSpace): ' + $diffs
'--- sample of one difference'
$first = Get-ChildItem "$root\ssgmerged\out" -Filter *.ps1 | Where-Object { (([IO.File]::ReadAllText($_.FullName)) -replace "`r`n", "`n") -cne (([IO.File]::ReadAllText("$o\$($_.Name)")) -replace "`r`n", "`n") } | Select-Object -First 1
if ($first) { git diff --no-index --ignore-space-at-eol -U1 $first.FullName "$o\$($first.Name)" | Select-Object -Skip 4 -First 24 }
