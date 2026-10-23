$root = 'E:\Repos\SsgTrial\_scratch'
$ex = 'E:\Repos\SsgTrial\SsgConverter\Examples'
$v = "$root\ssgfinal"
Remove-Item $v -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory $v | Out-Null
Copy-Item "$root\ssgfix\Console" "$v\Console" -Recurse
Copy-Item "$root\ssgfix\Source\_deps" "$v\_deps" -Recurse
Copy-Item 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter' "$v\SsgConverter" -Recurse -Exclude bin, obj
$build = dotnet build "$v\SsgConverter\SsgConverter.csproj" -c Debug --nologo 2>&1 | Select-Object -Last 4
$build
Copy-Item "$v\SsgConverter\bin\Debug\net10.0\SsgConverter.dll" "$v\Console\SsgConverter.dll" -Force
$o = "$v\out"; New-Item -ItemType Directory $o | Out-Null
dotnet "$v\Console\SsgConverterConsole.dll" /INPUT:"$ex\Input" /OUTPUT:"$o" /CONTINUEONERROR:TRUE /VERBOSE:2 /ENABLELOGFILE:TRUE /LOGFILE:"$o" 2>&1 | Select-String 'Conversion complete|Error converting' | ForEach-Object { $_.Line }
$same = 0; $diff = 0; $parseBad = 0
foreach ($g in Get-ChildItem "$root\ssgvarA\out" -Filter *.ps1) {
  $a = ([IO.File]::ReadAllText($g.FullName)) -replace "`r`n", "`n"; $b = ([IO.File]::ReadAllText("$o\$($g.Name)")) -replace "`r`n", "`n"
  if ($a -ceq $b) { $same++ } else { $diff++; 'DIFF vs variant A: ' + $g.Name }
}
foreach ($f in Get-ChildItem $o -Filter *.ps1) { $e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$null, [ref]$e); if ($e.Count -gt 0) { $parseBad++; '{0}: {1} parse errors' -f $f.Name, $e.Count } }
'identical to variant A: {0}   different: {1}   parse errors in {2} files' -f $same, $diff, $parseBad
'ps1 files produced: ' + (Get-ChildItem $o -Filter *.ps1).Count
