$in = 'E:\Repos\SsgTrial\_scratch\y2k-in'; $out = 'E:\Repos\SsgTrial\_scratch\y2k-out'
Remove-Item $in, $out -Recurse -Force -ErrorAction SilentlyContinue; New-Item -ItemType Directory $in, $out | Out-Null
Copy-Item 'E:\Repos\SsgTrial\docs\Reference-Trials\AssetLibrary-AMT175-20261010\03-pipelines\Parallel\Source-SSG\Temp\ASSURFED_UTILIT_Y2KCLR_PRD.txt' $in
Expand-Archive 'E:\Repos\177Xfer-ssgconv\Downloads-20261014\Cobol SSG.zip' 'E:\Repos\SsgTrial\_scratch\allard-cobolssg' -Force
dotnet 'E:\Repos\SsgTrial\_scratch\ssgmerged\Console\SsgConverterConsole.dll' /INPUT:$in /OUTPUT:$out /CONTINUEONERROR:TRUE /VERBOSE:2 2>&1 | Select-String 'Conversion complete|Error' | ForEach-Object { $_.Line }
Get-ChildItem $out | Select-Object Name, Length
$a = 'E:\Repos\SsgTrial\_scratch\allard-cobolssg\Cobol SSG\ASSURFED_UTILIT_Y2KCLR_PRD(P).ps1'
$m = Get-ChildItem $out -Filter *.ps1 | Select-Object -First 1
'--- Allard (15 Jul) ---'; Get-Content $a
'--- merged converter ---'; Get-Content $m.FullName
'--- diff numstat ---'; git diff --no-index --ignore-space-at-eol --numstat $a $m.FullName
