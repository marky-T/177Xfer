$ErrorActionPreference = 'Stop'
$w = 'E:\Repos\SsgTrial\_scratch\ssgfix'
$f = "$w\Source\SsgConverter\SymstreamExpressionMigrator.cs"
$t = [System.IO.File]::ReadAllText($f)
$anchor = '      SymstreamExpressionPrimitive pe = expression as SymstreamExpressionPrimitive;'
if (-not $t.Contains($anchor)) { throw 'anchor' }
$dbg = $anchor + "`r`n      if (pe != null && pe.Image != null && pe.Image.IndexOf(""VALUE"", StringComparison.OrdinalIgnoreCase) >= 0) { System.IO.File.AppendAllText(@""$w\dbg.txt"", pe.PrimitiveType + "" | "" + pe.Image + ""\r\n""); }"
[System.IO.File]::WriteAllText($f, $t.Replace($anchor, $dbg))
Remove-Item "$w\dbg.txt" -ErrorAction SilentlyContinue
dotnet build "$w\Source\SsgConverter\SsgConverter.csproj" -c Debug --nologo 2>&1 | Select-String 'error|Build succeeded' | Select-Object -First 4 | ForEach-Object { $_.Line }
Copy-Item "$w\Source\SsgConverter\bin\Debug\net10.0\SsgConverter.dll" "$w\Console\SsgConverter.dll" -Force
New-Item -ItemType Directory -Force "$w\dbgin" | Out-Null
Copy-Item E:\Repos\SsgTrial\SsgConverter\Examples\Input\FUSBA2_ASCII.TXT "$w\dbgin" -Force
dotnet "$w\Console\SsgConverterConsole.dll" /INPUT:"$w\dbgin" /OUTPUT:"$w\dbgout" /CONTINUEONERROR:TRUE 2>&1 | Select-String 'Conversion complete|Error' | ForEach-Object { $_.Line }
if (Test-Path "$w\dbg.txt") { Get-Content "$w\dbg.txt" | Select-Object -First 10 } else { 'no VALUE primitive reached Migrate' }
