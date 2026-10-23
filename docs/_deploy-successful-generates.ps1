$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDir = "E:\Repos\SsgTrial\SsgConverter\_backup\AFBUS_2200COBOL-Binaries-Programs-$stamp"
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
Copy-Item -Path 'E:\Repos\Federale_InternalRelease\AFBUS_2200COBOL\Binaries\Programs\*' -Destination $backupDir -Recurse -Force
Write-Output "Backed up deployed Binaries\Programs -> $backupDir"
Get-ChildItem -LiteralPath $backupDir | Select-Object Name | Format-Table -AutoSize | Out-String -Width 4096 | Write-Output

$srcDir = 'E:\Repos\Federale_InternalRelease\AFBUS_2200COBOL\Source\Cobol_AMT\Binaries\Programs'
$dstDir = 'E:\Repos\Federale_InternalRelease\AFBUS_2200COBOL\Binaries\Programs'

# map: source basename (as generated, upper/underscore) -> deployed target basename (PascalCase, matching existing convention)
$map = @{
  'ASSURFED_UTILIT_ARCHIFORMAT'       = 'Assurfed_Utilit_Archiformat'
  'ASSURFED_UTILIT_ARCHITAB1'         = 'Assurfed_Utilit_Architab1'
  'ASSURFED_UTILIT_CFH_COPY'          = 'Assurfed_Utilit_Cfh_Copy'
  'ASSURFED_UTILIT_COMPARE2_ASCII'    = 'Assurfed_Utilit_Compare2_Ascii'
  'ASSURFED_UTILIT_LOADIS_MULT_NODUP' = 'Assurfed_Utilit_Loadis_Mult_Nodup'
  'ASSURFED_UTILIT_MONTANT_SIGNE'     = 'Assurfed_Utilit_Montant_Signe'
  'ASSURFED_UTILIT_TAPELD_DISTRIB'    = 'Assurfed_Utilit_Tapeld_Distrib'
}

Write-Output '=== COPY RESULTS ==='
foreach ($srcName in $map.Keys) {
  $dstName = $map[$srcName]
  $srcDll = Join-Path $srcDir "$srcName.dll"
  $dstDll = Join-Path $dstDir "$dstName.dll"
  if (Test-Path -LiteralPath $srcDll) {
    Copy-Item -LiteralPath $srcDll -Destination $dstDll -Force
    $hadDepsBefore = Test-Path -LiteralPath (Join-Path $dstDir "$dstName.deps.json")
    Write-Output ("COPIED  {0} -> {1}  (deps.json already present: {2})" -f (Split-Path $srcDll -Leaf), $dstDll, $hadDepsBefore)
  } else {
    Write-Output ("MISSING SOURCE: $srcDll")
  }
}

Write-Output ''
Write-Output '=== DEPLOYED FOLDER AFTER COPY ==='
Get-ChildItem -LiteralPath $dstDir -File | Sort-Object Name | Select-Object Name, LastWriteTime, Length | Format-Table -AutoSize | Out-String -Width 4096 | Write-Output
