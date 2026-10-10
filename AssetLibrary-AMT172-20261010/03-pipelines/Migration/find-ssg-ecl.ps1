$pat = "ARCHIFORMAT|ARCHIINSERT|ARCHISEPARE|ARCHITAB1|CFH-COPY|CONDIS_ASCII|ECLAT|LECTIS_MULT|LOADIS_MULT|MONTANT_SIGNE|TRI_ASCII|UNLOADIS_MULT|TAPELD_DISTRIB"
$dir = "C:\Amt\MainframeSource\Codedrop 2025\RunsPrd"
$enc = [System.Text.Encoding]::GetEncoding(1252)
$hits = @()
foreach ($f in Get-ChildItem $dir -Filter "*.TXT") {
    $bytes = [System.IO.File]::ReadAllBytes($f.FullName)
    $text = $enc.GetString($bytes)
    if ($text -match $pat) {
        $found = ([regex]::Matches($text, $pat) | ForEach-Object { $_.Value }) | Sort-Object -Unique
        $hits += [PSCustomObject]@{ File = $f.Name; Programs = ($found -join ', ') }
    }
}
$hits | Sort-Object File | Format-Table -AutoSize -Wrap
Write-Host "Total: $($hits.Count) files"
