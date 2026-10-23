$ErrorActionPreference = 'Stop'
$w = 'E:\Repos\SsgTrial\_scratch\ssgfix'
$f = "$w\Source\SsgConverter\SymstreamExpressionMigrator.cs"
$t = [System.IO.File]::ReadAllText($f)
$anchor = '      SymstreamExpressionPrimitive primitive = operand as SymstreamExpressionPrimitive;'
if (-not $t.Contains($anchor)) { throw 'anchor' }
$dbg = $anchor + "`r`n      System.IO.File.AppendAllText(@""$w\dbg2.txt"", binaryOperator + "" | "" + operand.GetType().Name + "" | "" + (primitive == null ? """" : primitive.PrimitiveType + "":"" + primitive.Image) + ""\r\n"");"
[System.IO.File]::WriteAllText($f, $t.Replace($anchor, $dbg))
Remove-Item "$w\dbg2.txt" -ErrorAction SilentlyContinue
dotnet build "$w\Source\SsgConverter\SsgConverter.csproj" -c Debug --nologo 2>&1 | Select-String 'error|Build succeeded' | Select-Object -First 4 | ForEach-Object { $_.Line }
Copy-Item "$w\Source\SsgConverter\bin\Debug\net10.0\SsgConverter.dll" "$w\Console\SsgConverter.dll" -Force
Remove-Item "$w\dbgout" -Recurse -Force -ErrorAction SilentlyContinue
dotnet "$w\Console\SsgConverterConsole.dll" /INPUT:"$w\dbgin" /OUTPUT:"$w\dbgout" /CONTINUEONERROR:TRUE 2>&1 | Select-String 'Conversion complete|Error' | ForEach-Object { $_.Line }
Get-Content "$w\dbg2.txt" | Select-Object -First 20
