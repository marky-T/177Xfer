$s = 'E:\Repos\SsgTrial\SsgConverter'
$list = @(
  'Source\SsgConverter\SymstreamProcessor.cs', 'Source\SsgConverter\SymstreamExpressionMigrator.cs', 'Source\SsgConverter\SymstreamExpressionParser.cs',
  'Source\SsgConverterConsole\Os2200ContentConverter.cs', 'Source\SsgConverterConsole\Program.cs',
  'Source\SsgConverterGui\App.xaml.cs', 'Source\SsgConverterGui\MainWindow.xaml.cs',
  'Build\Console\SsgConverter.dll', 'Build\Gui\SsgConverter.dll',
  'Release-RnD-20261014\CHANGELIST.md', 'Release-RnD-20261014\SsgConverter-vs-develop.patch', 'Release-RnD-20261014\SHA256SUMS.txt',
  'Trials\New-RnDPackage.ps1', 'Trials\Reconvert-And-Verify.ps1', 'Trials\Patch-DefineScope.ps1')
foreach ($r in $list) {
  $p = Join-Path $s $r
  if (Test-Path $p) { $i = Get-Item $p; '{0:yyyy-MM-dd HH:mm}  {1,9}  {2}' -f $i.LastWriteTime, $i.Length, $p } else { "MISSING  $p" }
}
'--- package copies'
Get-ChildItem "$s\Release-RnD-20261014\Migration Tools" -Recurse -File | ForEach-Object { '{0,9}  {1}' -f $_.Length, $_.FullName }
'--- goldens'
$g = Get-ChildItem "$s\Examples\Output" -Filter *.ps1
'count {0}, oldest {1:yyyy-MM-dd HH:mm}, newest {2:yyyy-MM-dd HH:mm}' -f $g.Count, ($g | Sort-Object LastWriteTime | Select-Object -First 1).LastWriteTime, ($g | Sort-Object LastWriteTime | Select-Object -Last 1).LastWriteTime
'--- golden backups'
Get-ChildItem "$s\_backup" -Directory -Filter 'Output-*' | Select-Object -Last 3 | ForEach-Object { $_.FullName }
