Set-Location C:\Amt\Migration\EclCobolPipeline
$tmpOut = "fixtures\loadis-ascii\work-test.dat"
& tools\refimpl\loadis-ascii.ps1 -InFile "fixtures\loadis-ascii\input.dat" -OutFile $tmpOut
Write-Host "--- output ---"
Get-Content $tmpOut
Write-Host "--- bytes: $((Get-Item $tmpOut).Length) ---"
$exp = Get-Content "fixtures\loadis-ascii\expected.dat"
$got = Get-Content $tmpOut
$diff = Compare-Object $exp $got
if ($diff) { Write-Host "DIFF:"; $diff | Format-Table } else { Write-Host "MATCH: standalone refimpl == expected.dat" }
Remove-Item $tmpOut
