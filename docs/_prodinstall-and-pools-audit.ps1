$out = New-Object System.Collections.Generic.List[string]
$out.Add('=== 1. ProdInstall / PInstall / AmtProdInstall.config search ===')
Get-ChildItem -LiteralPath 'E:\Repos\Federale_InternalRelease' -Recurse -File -Include 'ProdInstall.exe','PInstall.exe','AmtProdInstall.config','sample_AmtProdInstall.config' -ErrorAction SilentlyContinue | ForEach-Object { $out.Add($_.FullName + ' | ' + $_.LastWriteTime) }
$out.Add('')
$out.Add('=== 2. PowerShellHost SqlClient closure freshness ===')
$psh = 'E:\Repos\Federale_InternalRelease\AmtTools\AmtBatchController\PowerShellHost'
Get-ChildItem -LiteralPath $psh -File -Filter 'Microsoft.Data.SqlClient*.dll' -ErrorAction SilentlyContinue | ForEach-Object { $out.Add($_.Name + ' | ' + $_.LastWriteTime + ' | ' + $_.VersionInfo.FileVersion) }
$sniPath = Join-Path $psh 'runtimes\win-x64\native\Microsoft.Data.SqlClient.SNI.dll'
if (Test-Path -LiteralPath $sniPath) { $out.Add('native SNI: ' + (Get-Item -LiteralPath $sniPath).LastWriteTime) } else { $out.Add('native SNI: MISSING') }
$out.Add('')
$out.Add('=== 3. All BatchWorking pool folder names under AFBUS_2200COBOL ===')
Get-ChildItem -LiteralPath 'E:\Repos\Federale_InternalRelease\AFBUS_2200COBOL\Binaries\BatchWorking' -Recurse -Directory -ErrorAction SilentlyContinue | ForEach-Object { $out.Add($_.FullName) }
[IO.File]::WriteAllLines('E:\Repos\SsgTrial\docs\_prodinstall-and-pools-audit.txt', $out)
Write-Output 'DONE'
