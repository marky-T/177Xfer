$root = 'E:\Repos\SsgTrial\_scratch'
$ex   = 'E:\Repos\SsgTrial\SsgConverter\Examples'
$stage = "$root\ssgmerged"
# merged console = ssgfix console + merged DLL
Copy-Item "$stage\Source\SsgConverter\bin\Debug\net10.0\SsgConverter.dll" "$stage\Console\SsgConverter.dll" -Force
# pure R&D develop console (library built from R&D source) for comparison
$rdStage = "$root\ssgrd"
Remove-Item $rdStage -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item "$stage" $rdStage -Recurse
$rdLib = "$rdStage\Source\SsgConverter"
foreach ($f in 'SymstreamProcessor.cs','SymstreamExpressionMigrator.cs','SymstreamExpressionParser.cs') { Copy-Item "$root\ssgmerge2\n\rd_$f" "$rdLib\$f" -Force }
dotnet build "$rdLib\SsgConverter.csproj" -c Debug --nologo 2>&1 | Select-Object -Last 4
Copy-Item "$rdLib\bin\Debug\net10.0\SsgConverter.dll" "$rdStage\Console\SsgConverter.dll" -Force
foreach ($v in 'ssgmerged','ssgrd') {
  $o = "$root\$v\out"; Remove-Item $o -Recurse -Force -ErrorAction SilentlyContinue; New-Item -ItemType Directory $o | Out-Null
  "== convert with $v"
  dotnet "$root\$v\Console\SsgConverterConsole.dll" /INPUT:"$ex\Input" /OUTPUT:"$o" /CONTINUEONERROR:TRUE /VERBOSE:2 /ENABLELOGFILE:TRUE /LOGFILE:"$o" 2>&1 | Select-String 'Conversion complete|Error converting' | ForEach-Object { $_.Line }
}
function N($p) { (Get-Content $p -Raw) -replace "`r`n", "`n" }
'{0,-18} {1,-10} {2,-10} {3,-14} {4}' -f 'Program', 'ours=merged', 'rd=merged', 'parse(rd/merged)', 'rd vs ours (+/-)'
foreach ($g in Get-ChildItem "$ex\Output" -Filter *.ps1 | Sort-Object Name) {
  $m = "$root\ssgmerged\out\$($g.Name)"; $r = "$root\ssgrd\out\$($g.Name)"
  $ours = N $g.FullName
  $pe = foreach ($p in $r, $m) { $e = $null; if (Test-Path $p) { [void][System.Management.Automation.Language.Parser]::ParseFile($p, [ref]$null, [ref]$e); $e.Count } else { 'missing' } }
  $st = git diff --no-index --ignore-space-at-eol --numstat $g.FullName $r 2>$null
  '{0,-18} {1,-11} {2,-10} {3,-16} {4}' -f $g.BaseName, $(if ((Test-Path $m) -and $ours -ceq (N $m)) { 'SAME' } else { 'DIFF' }), $(if ((Test-Path $m) -and (Test-Path $r) -and (N $r) -ceq (N $m)) { 'SAME' } else { 'DIFF' }), ($pe -join '/'), $(if ($st) { (($st -split '\s+')[0..1]) -join '/' } else { 'none' })
}
