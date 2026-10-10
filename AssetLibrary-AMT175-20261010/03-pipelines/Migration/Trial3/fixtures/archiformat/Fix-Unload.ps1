Set-StrictMode -Off
$enc = New-Object System.Text.UTF8Encoding($false)
$d1 = 'DATA1'.PadRight(55)
$d2 = 'DATA2'.PadRight(55)
$l1 = '1234567890' + $d1 + 'X  '
$l2 = '0000000042' + $d2 + 'X  '
Write-Host "l1 len=$($l1.Length) l2 len=$($l2.Length)"
$txt = $l1 + "`r`n" + $l2 + "`r`n"
Write-Host "txt len=$($txt.Length)"
$path = 'C:\Amt\Migration\EclCobolPipeline\fixtures\archiformat\fic-unload.dat'
[System.IO.File]::WriteAllText($path, $txt, $enc)
$sz = (Get-Item $path).Length
Write-Host "file size=$sz"
$lines = [System.IO.File]::ReadAllLines($path)
Write-Host "lines=$($lines.Count) line0.len=$($lines[0].Length) line1.len=$($lines[1].Length)"
