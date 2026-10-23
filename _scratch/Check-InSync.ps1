$s = 'E:\Repos\SsgTrial\SsgConverter\Source'
$p = 'E:\Repos\SsgTrial\SsgConverter\Release-RnD-20261014\Migration Tools\SsgConverter'
foreach ($f in 'SsgConverter\SymstreamProcessor.cs', 'SsgConverter\SymstreamExpressionMigrator.cs', 'SsgConverter\SymstreamExpressionParser.cs', 'SsgConverterConsole\Os2200ContentConverter.cs', 'SsgConverterConsole\Program.cs', 'SsgConverterGui\App.xaml.cs', 'SsgConverterGui\MainWindow.xaml.cs') {
  $a = (Get-FileHash "$s\$f" -Algorithm SHA256).Hash; $b = (Get-FileHash "$p\$f" -Algorithm SHA256).Hash
  '{0,-5} {1}' -f $(if ($a -eq $b) { 'SAME' } else { 'DIFF' }), $f
}
'built DLL vs Source (newest source write {0:HH:mm}, Build dll {1:HH:mm})' -f (Get-ChildItem $s -Recurse -Filter *.cs | Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' } | Sort-Object LastWriteTime | Select-Object -Last 1).LastWriteTime, (Get-Item 'E:\Repos\SsgTrial\SsgConverter\Build\Console\SsgConverter.dll').LastWriteTime
