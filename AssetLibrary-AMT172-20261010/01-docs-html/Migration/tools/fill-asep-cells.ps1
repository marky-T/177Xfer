Set-StrictMode -Off
$htmlPath = 'C:\Amt\Migration\SSG-ECL-Command-Matrix.html'
$raw = [System.IO.File]::ReadAllText($htmlPath)

$asepMap = [ordered]@{
    '@UCOB,I'           = 'cross'
    '#ucob,is'          = 'check'
    '#ACOB'             = 'cross'
    '*DEFINE'           = 'cross'
    '*SET'              = 'check'
    '*PROCESS'          = 'cross'
    '*INCREMENT'        = 'cross'
    '*IF'               = 'check'
    '[PARAM,r,1,f]'     = 'check'
    '[PARAM,r,A,f]'     = 'cross'
    '[PARAM,r,COL,f]'   = 'cross'
    '[*varname]'        = 'check'
    '[*I]'              = 'cross'
}

$checkCell = '<td class="cell"><span class="cv cv-yes">&#10003;</span></td>'
$crossCell = '<td class="cell"><span style="color:#b91c1c;font-weight:700;">&#10007;</span></td>'
$pendCell  = '<td class="cell"><span class="cv cv-pend">&mdash;</span></td>'

$rows = [System.Text.RegularExpressions.Regex]::Split($raw, '(?=<tr[\s>])')
Write-Host "Row segments: $($rows.Count)"

$changed = 0
$newRows = New-Object System.Collections.Generic.List[string]

foreach ($row in $rows) {
    $hit = $false
    foreach ($kv in $asepMap.GetEnumerator()) {
        $key = $kv.Key
        $val = $kv.Value
        $escapedKey = [regex]::Escape($key)
        if (($row -match $escapedKey) -and ($row -match 'class="directive"')) {
            $cellPattern = '(?s)<td class="cell">.*?</td>'
            $cells = [System.Text.RegularExpressions.Regex]::Matches($row, $cellPattern)
            if ($cells.Count -ge 8) {
                $target = $cells[7]
                if ($target.Value -eq $pendCell) {
                    $replacement = if ($val -eq 'check') { $checkCell } else { $crossCell }
                    $row = $row.Substring(0, $target.Index) + $replacement + $row.Substring($target.Index + $target.Length)
                    $changed++
                    Write-Host ("  Changed ASEP for '" + $key + "' -> " + $val + " (cells=" + $cells.Count + ")")
                } else {
                    Write-Host ("  SKIP '" + $key + "': cell-8 already filled")
                }
            } else {
                Write-Host ("  WARN '" + $key + "': only " + $cells.Count + " cells found")
            }
            $hit = $true
            break
        }
    }
    $newRows.Add($row)
}

Write-Host "Total changed: $changed"
$result = $newRows -join ''
Write-Host ("Length delta: " + ($result.Length - $raw.Length))

# Also update both ASEP column headers
$result = $result.Replace('<th class="prog">ASEP</th>', '<th class="prog done-prog">ASEP</th>')
$headerCount = ([regex]::Matches($result, 'done-prog">ASEP')).Count
Write-Host "ASEP headers now done-prog: $headerCount"

[System.IO.File]::WriteAllText($htmlPath, $result)
Write-Host "Written."
