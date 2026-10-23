$j = 'E:\Repos\SsgTrial\_scratch\rd-jul27\SsgConverter'
$s = 'E:\Repos\SsgTrial\SsgConverter\Source'
$d = 'E:\Repos\SsgTrial\_scratch\diffs'
foreach ($rel in 'SsgConverterConsole\Os2200ContentConverter.cs', 'SsgConverterConsole\Program.cs', 'SsgConverterGui\App.xaml.cs', 'SsgConverterGui\MainWindow.xaml.cs', 'SsgConverterConsole\SsgConverterConsole.csproj', 'SsgConverterGui\SsgConverterGui.csproj', 'SsgConverter\SsgConverter.csproj') {
  "`n######## $rel"
  git diff --no-index --ignore-space-at-eol -U1 "$j\$rel" "$s\$rel" 2>$null | Select-Object -Skip 4
}
