$root = 'E:\Repos\SsgTrial\_scratch'
$ex = 'E:\Repos\SsgTrial\SsgConverter\Examples'
'== blank / whitespace-only lines in the 20 example inputs'
foreach ($f in Get-ChildItem "$ex\Input" -File | Sort-Object Name) {
  $l = [IO.File]::ReadAllLines($f.FullName)
  $empty = ($l | Where-Object { $_.Length -eq 0 }).Count
  $ws = ($l | Where-Object { $_.Length -gt 0 -and $_.Trim().Length -eq 0 }).Count
  '{0,-34} lines={1,5} empty={2,3} whitespace-only={3,3}' -f $f.Name, $l.Count, $empty, $ws
}
'== PILO / NSIGN / LBRK handling in the converter source'
Get-ChildItem 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter' -Recurse -Filter *.cs | Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' } | Select-String -Pattern 'PILO|NSIGN|LBRK|IMGLEN|GOSCNT' | ForEach-Object { '{0}:{1}: {2}' -f $_.Filename, $_.LineNumber, $_.Line.Trim().Substring(0, [Math]::Min(140, $_.Line.Trim().Length)) } | Select-Object -First 20
'== variant A: R&D rule (IsNullOrEmpty) vs merged'
$v = "$root\ssgvarA"
Remove-Item $v -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$root\ssgmerged" $v -Recurse
$p = "$v\Source\SsgConverter\SymstreamProcessor.cs"
$t = [IO.File]::ReadAllText($p)
$old = '} else if (!String.IsNullOrWhiteSpace(lines[i])) {'
$new = '} else if (!String.IsNullOrEmpty(lines[i])) {'
'occurrences of old rule: ' + ([regex]::Matches($t, [regex]::Escape($old))).Count
[IO.File]::WriteAllText($p, $t.Replace($old, $new))
dotnet build "$v\Source\SsgConverter\SsgConverter.csproj" -c Debug --nologo 2>&1 | Select-Object -Last 3
Copy-Item "$v\Source\SsgConverter\bin\Debug\net10.0\SsgConverter.dll" "$v\Console\SsgConverter.dll" -Force
$o = "$v\out"; New-Item -ItemType Directory $o | Out-Null
dotnet "$v\Console\SsgConverterConsole.dll" /INPUT:"$ex\Input" /OUTPUT:"$o" /CONTINUEONERROR:TRUE /VERBOSE:2 /ENABLELOGFILE:TRUE /LOGFILE:"$o" 2>&1 | Select-String 'Conversion complete|Error converting' | ForEach-Object { $_.Line }
$diffs = 0
foreach ($g in Get-ChildItem "$root\ssgmerged\out" -Filter *.ps1) {
  $a = ([IO.File]::ReadAllText($g.FullName)) -replace "`r`n", "`n"; $b = ([IO.File]::ReadAllText("$o\$($g.Name)")) -replace "`r`n", "`n"
  if ($a -cne $b) { $diffs++; '{0}: DIFFERENT' -f $g.BaseName; git diff --no-index --ignore-space-at-eol --numstat $g.FullName "$o\$($g.Name)" }
}
'programs with differing output (IsNullOrEmpty vs IsNullOrWhiteSpace): ' + $diffs
