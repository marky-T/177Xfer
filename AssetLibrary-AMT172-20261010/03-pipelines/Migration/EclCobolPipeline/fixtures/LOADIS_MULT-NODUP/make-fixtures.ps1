$enc = New-Object System.Text.UTF8Encoding($false)
$r1 = 'A' * 80
$r2 = 'B' * 80
$r3 = 'C' * 80
$inp = "$r1`r`n$r2`r`n$r3`r`n"
[System.IO.File]::WriteAllText("C:\Amt\Migration\EclCobolPipeline\fixtures\loadis-ascii\input.dat", $inp, $enc)
Write-Host "input.dat bytes: $((Get-Item 'C:\Amt\Migration\EclCobolPipeline\fixtures\loadis-ascii\input.dat').Length)"

# expected.dat: 3 DISQ records (20 chars each) + 1 printer line, all CRLF
$d1 = 'A' * 20
$d2 = 'B' * 20
$d3 = 'C' * 20
$printer = 'NB.RECORDS ECRITS' + '0000000003'
$all = @($d1, $d2, $d3, $printer)
[System.IO.File]::WriteAllText("C:\Amt\Migration\EclCobolPipeline\fixtures\loadis-ascii\expected.dat", ($all -join "`r`n") + "`r`n", $enc)
Write-Host "expected.dat bytes: $((Get-Item 'C:\Amt\Migration\EclCobolPipeline\fixtures\loadis-ascii\expected.dat').Length)"
