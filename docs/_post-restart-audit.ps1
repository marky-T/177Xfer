$out = New-Object System.Collections.Generic.List[string]
$out.Add('=== ReportPool copies of Assurfed_Utilit_Cfh_Copy.dll ===')
Get-ChildItem -LiteralPath 'E:\Repos\Federale_InternalRelease\AFBUS_2200COBOL\Binaries' -Recurse -File -Filter 'Assurfed_Utilit_Cfh_Copy.dll' -ErrorAction SilentlyContinue | ForEach-Object {
  $out.Add(('{0} | {1} | {2} bytes' -f $_.LastWriteTime, $_.FullName, $_.Length))
}
$out.Add('')
$out.Add('=== SqlServerWrapper folder current state ===')
$w = 'E:\Repos\Federale_InternalRelease\AmtTools\SqlServerWrapper'
Get-ChildItem -LiteralPath $w -File | ForEach-Object { $out.Add($_.Name + ' | ' + $_.LastWriteTime) }
$out.Add('HasNativeSNI: ' + (Test-Path -LiteralPath (Join-Path $w 'runtimes\win-x64\native\Microsoft.Data.SqlClient.SNI.dll')))
$out.Add('HasManagedDll: ' + (Test-Path -LiteralPath (Join-Path $w 'Microsoft.Data.SqlClient.dll')))
$out.Add('')
$out.Add('=== AmtSettings.xml AppName (deployed copies) ===')
Get-ChildItem -LiteralPath 'E:\Repos\Federale_InternalRelease' -Recurse -File -Filter 'AmtSettings.xml' -ErrorAction SilentlyContinue | ForEach-Object {
  $out.Add('--- ' + $_.FullName + ' ---')
  Select-String -LiteralPath $_.FullName -Pattern 'AppName' | ForEach-Object { $out.Add($_.Line.Trim()) }
}
[IO.File]::WriteAllLines('E:\Repos\SsgTrial\docs\_post-restart-audit.txt', $out)
Write-Output 'DONE'
