$ErrorActionPreference = 'Stop'
$ssg = 'E:\Repos\SsgTrial\SsgConverter'
$w = 'E:\Repos\SsgTrial\_scratch\ssgfix'
if (Test-Path $w) { Remove-Item $w -Recurse -Force }
New-Item -ItemType Directory -Force "$w\Source" | Out-Null
robocopy "$ssg\Source\SsgConverter" "$w\Source\SsgConverter" /E /XD bin obj /NFL /NDL /NJH /NJS /NP | Out-Null
robocopy "$ssg\Source\_deps" "$w\Source\_deps" /E /NFL /NDL /NJH /NJS /NP | Out-Null
robocopy "$ssg\Build\Console" "$w\Console" /E /NFL /NDL /NJH /NJS /NP | Out-Null
& "$ssg\Trials\Patch-DefineScope.ps1" -File "$w\Source\SsgConverter\SymstreamProcessor.cs"


$before = (Get-Item "$w\Console\SsgConverter.dll").Length
dotnet build "$w\Source\SsgConverter\SsgConverter.csproj" -c Debug --nologo 2>&1 | Select-String 'error|Build succeeded|Warn.*\d+ Warning' | Select-Object -First 6 | ForEach-Object { $_.Line }
$dll = "$w\Source\SsgConverter\bin\Debug\net10.0\SsgConverter.dll"
'built dll bytes: ' + (Get-Item $dll).Length + '  console dll bytes before: ' + $before
Copy-Item $dll "$w\Console\SsgConverter.dll" -Force

New-Item -ItemType Directory -Force "$w\out" | Out-Null
dotnet "$w\Console\SsgConverterConsole.dll" /INPUT:"$ssg\Examples\Input" /OUTPUT:"$w\out" /CONTINUEONERROR:TRUE /VERBOSE:2 /ENABLELOGFILE:TRUE /LOGFILE:"$w\out" 2>&1 | Select-String 'Conversion complete|Error converting' | ForEach-Object { $_.Line }
foreach ($g in Get-ChildItem "$ssg\Examples\Output" -Filter *.ps1) {
  $n = Join-Path "$w\out" $g.Name
  if (-not (Test-Path $n)) { '{0}: MISSING in new output' -f $g.Name; continue }
  $same = (Get-FileHash $g.FullName).Hash -eq (Get-FileHash $n).Hash
  $errs = $null; [void][System.Management.Automation.Language.Parser]::ParseFile($n, [ref]$null, [ref]$errs)
  '{0}: {1}  parseErrors={2}' -f $g.Name, $(if ($same) { 'identical' } else { 'CHANGED' }), $errs.Count
}
