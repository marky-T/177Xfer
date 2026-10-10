$dir = 'C:\Amt\MainframeSource\Codedrop 2025\RunsPrd'
$enc = [System.Text.Encoding]::GetEncoding(1252)
foreach ($f in Get-ChildItem $dir -Filter '*.TXT') {
    $text = $enc.GetString([System.IO.File]::ReadAllBytes($f.FullName))
    if ($text -match 'SCAN-VAR|@XQT\s+\.SCAN\b|@SSG[^`n]*SCAN') {
        Write-Host "=== $($f.Name) ==="
        ($text -split "`n") | Select-String 'SCAN' | Select-Object -First 10 | ForEach-Object { $_.Line }
    }
}
Write-Host "Done."
