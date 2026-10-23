$ErrorActionPreference = 'Stop'
$repo = 'E:\Repos\SsgTrial'
$work = "$repo\_scratch\ssgfix2"
$ex = "$repo\SsgConverter\Examples"
$con = "$work\console"
$out = "$work\out"
Remove-Item $con, $out -Recurse -Force -ErrorAction SilentlyContinue
robocopy "$repo\SsgConverter\Build\Console" $con /E /NFL /NDL /NJH /NJS | Out-Null
$dll = Get-ChildItem "$work\src\SsgConverter\bin" -Recurse -Filter SsgConverter.dll | Select-Object -First 1
Copy-Item $dll.FullName "$con\SsgConverter.dll" -Force
"dll: $($dll.FullName) $((Get-Item "$con\SsgConverter.dll").Length) bytes"
New-Item -ItemType Directory -Force -Path $out | Out-Null
dotnet "$con\SsgConverterConsole.dll" /INPUT:"$ex\Input" /OUTPUT:"$out" /CONTINUEONERROR:TRUE /VERBOSE:2 /ENABLELOGFILE:TRUE /LOGFILE:"$out" 2>&1 |
  Select-String -Pattern 'Conversion complete|Error converting' | ForEach-Object { $_.Line }

"`n== parse + diff against current goldens"
foreach ($f in Get-ChildItem $out -Filter *.ps1 | Sort-Object Name) {
  $errs = $null
  [void][System.Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$null, [ref]$errs)
  $gold = Join-Path "$ex\Output" $f.Name
  $a = @(Get-Content $gold); $b = @(Get-Content $f.FullName)
  $d = @(Compare-Object $a $b -SyncWindow 0).Count
  '{0,-22} parse={1} lines {2}->{3} differing={4}' -f $f.BaseName, $errs.Count, $a.Count, $b.Count, $d
}
