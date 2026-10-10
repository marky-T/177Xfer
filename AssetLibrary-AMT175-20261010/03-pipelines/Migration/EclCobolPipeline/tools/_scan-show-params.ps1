$files = @(
    'C:\Amt\MainframeSource\Codedrop 2025\RunsPrd\ASSURFED_F999RUN_VIRA05(P).TXT',
    'C:\Amt\MainframeSource\Codedrop 2025\RunsPrd\ASSURFED_F999RUN-d_EXPD05_OP(P).TXT'
)
foreach ($path in $files) {
    Write-Host "=== $([System.IO.Path]::GetFileName($path)) ==="
    $lines = Get-Content $path -Encoding Default
    $found = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '@SSG,IA.*SCAN') {
            $start = [Math]::Max(0, $i - 5)
            $end   = [Math]::Min($lines.Count - 1, $i + 25)
            $lines[$start..$end] | ForEach-Object { Write-Host $_ }
            $found = $true
            break
        }
    }
    if (-not $found) { Write-Host '(not found)' }
    Write-Host ''
}
