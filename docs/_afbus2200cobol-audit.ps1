$out = New-Object System.Collections.Generic.List[string]
$out.Add('=== 1. Every AmtSqlServerWrapper.dll under Federale_InternalRelease ===')
Get-ChildItem -LiteralPath 'E:\Repos\Federale_InternalRelease' -Recurse -File -Filter 'Asysco.Amt.AmtSqlServerWrapper.dll' -ErrorAction SilentlyContinue | ForEach-Object {
  $folder = $_.DirectoryName
  $hasDll = Test-Path -LiteralPath (Join-Path $folder 'Microsoft.Data.SqlClient.dll')
  $hasSni = Test-Path -LiteralPath (Join-Path $folder 'runtimes\win-x64\native\Microsoft.Data.SqlClient.SNI.dll')
  $out.Add(('{0} | HasDll={1} | HasNativeSNI={2}' -f $_.FullName, $hasDll, $hasSni))
}
$out.Add('')
$out.Add('=== 2. cfh-copy.ps1 locations under AFBUS_2200COBOL ===')
Get-ChildItem -LiteralPath 'E:\Repos\Federale_InternalRelease\AFBUS_2200COBOL' -Recurse -File -Filter 'cfh-copy.ps1' -ErrorAction SilentlyContinue | ForEach-Object { $out.Add($_.FullName) }
$out.Add('')
$out.Add('=== 3. AFBUS_2200COBOL top-level dirs ===')
Get-ChildItem -LiteralPath 'E:\Repos\Federale_InternalRelease\AFBUS_2200COBOL' -Directory -ErrorAction SilentlyContinue | ForEach-Object { $out.Add($_.Name) }
$out.Add('')
$out.Add('=== 4. Compiled Assurfed_Utilit_Cfh_Copy DLL locations ===')
Get-ChildItem -LiteralPath 'E:\Repos\Federale_InternalRelease\AFBUS_2200COBOL' -Recurse -File -Filter 'Assurfed_Utilit_Cfh_Copy.dll' -ErrorAction SilentlyContinue | ForEach-Object {
  $folder = $_.DirectoryName
  $hasDll = Test-Path -LiteralPath (Join-Path $folder 'Microsoft.Data.SqlClient.dll')
  $out.Add(('{0} | LastWriteTime={1} | HasSqlClientDllHere={2}' -f $_.FullName, $_.LastWriteTime, $hasDll))
}
$out.Add('')
$out.Add('=== 5. Sys.ini / AmtSettings.xml under AFBUS_2200COBOL ===')
Get-ChildItem -LiteralPath 'E:\Repos\Federale_InternalRelease\AFBUS_2200COBOL' -Recurse -File -Include 'Sys.ini','AmtSettings.xml' -ErrorAction SilentlyContinue | ForEach-Object {
  $out.Add('--- ' + $_.FullName + ' ---')
  $out.AddRange([string[]](Get-Content -LiteralPath $_.FullName))
}
[IO.File]::WriteAllLines('E:\Repos\SsgTrial\docs\_afbus2200cobol-audit.txt', $out)
Write-Output 'DONE'
