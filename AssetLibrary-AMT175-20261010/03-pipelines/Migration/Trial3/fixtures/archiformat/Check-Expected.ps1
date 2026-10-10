$f = 'C:\Amt\Migration\EclCobolPipeline\fixtures\archiformat\expected.dat'
$sz = (Get-Item $f).Length
Write-Host "bytes: $sz"
$lines = [System.IO.File]::ReadAllLines($f)
Write-Host "lines: $($lines.Count)"
$i = 0
foreach ($l in $lines) {
    $i++
    $preview = $l.Substring(0,[Math]::Min(55,$l.Length))
    Write-Host "$i len=$($l.Length): $preview"
}
