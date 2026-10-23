$ErrorActionPreference = 'Stop'
$seven = 'C:\Program Files\7-Zip\7z.exe'
if (-not (Test-Path $seven)) { $seven = (Get-Command 7z -ErrorAction Stop).Source }
$x = 'E:\Repos\177Xfer\8.0.26230.0'
'=== integrity of the 177 media (7z test, nothing extracted)'
foreach ($f in 'YDrive_C#.7z', 'Release_8.0.26230.0.7z') {
  $o = & $seven t (Join-Path $x $f) 2>&1 | Select-String 'Everything is Ok|ERROR|Errors'
  '{0,-26} {1}' -f $f, ($o -join ' ')
}
'=== SHA-256 of the installer pair'
foreach ($f in 'Setup.exe', 'AMT_177.dat') { '{0,-14} {1}  {2}' -f $f, (Get-Item (Join-Path $x $f)).Length, (Get-FileHash (Join-Path $x $f) -Algorithm SHA256).Hash }
'=== top level of YDrive_C#.7z'
& $seven l (Join-Path $x 'YDrive_C#.7z') 2>&1 | Select-String -Pattern '^\d{4}-\d\d-\d\d.*\s(Amt\.Net|AmtLion|Common_Lion_Amt|Common_lion_amt)\\?[^\\]*$' | Select-Object -First 12 | ForEach-Object { $_.Line }
& $seven l (Join-Path $x 'YDrive_C#.7z') 2>&1 | Select-String -Pattern 'files|folders' | Select-Object -Last 2 | ForEach-Object { $_.Line }
'=== does the 179 source on E:\AMT_Y have the same top-level layout?'
Get-ChildItem E:\AMT_Y\CSharpNet -Directory | ForEach-Object Name
'=== free space (GB)'; '{0:N0}' -f ((Get-PSDrive E).Free / 1GB)
