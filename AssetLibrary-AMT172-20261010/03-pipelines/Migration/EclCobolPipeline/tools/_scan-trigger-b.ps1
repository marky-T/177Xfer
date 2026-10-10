# Trigger B: populate SCAN column cells in SSG-ECL-Command-Matrix.html
# SCAN is the 13th data cell (0-indexed: 12) in each matrix row.
# Run from any directory.

$path = 'C:\Amt\Migration\SSG-ECL-Command-Matrix.html'
$html = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

$yes    = '<span class="cv cv-yes">&#10003;</span>'
$no     = '<span style="color:#b91c1c;font-weight:700;">&#10007;</span>'
$pend   = '<td class="cell"><span class="cv cv-pend">&mdash;</span></td>'
$yesP   = @{
    'P1' = '<td class="cell"><span class="cv cv-yes">&#10003;</span><a class="pat-link" href="#pat-ssg-ia">&#8594;P1</a></td>'
    'P2' = '<td class="cell"><span class="cv cv-yes">&#10003;</span><a class="pat-link" href="#pat-define">&#8594;P2</a></td>'
    'P3' = '<td class="cell"><span class="cv cv-yes">&#10003;</span><a class="pat-link" href="#pat-increment">&#8594;P3</a></td>'
    'P4' = '<td class="cell"><span class="cv cv-yes">&#10003;</span><a class="pat-link" href="#pat-if">&#8594;P4</a></td>'
    'P5' = '<td class="cell"><span class="cv cv-yes">&#10003;</span><a class="pat-link" href="#pat-tokens">&#8594;P5</a></td>'
    '' = '<td class="cell"><span class="cv cv-yes">&#10003;</span></td>'
}
$yesNo  = '<td class="cell"><span style="color:#b91c1c;font-weight:700;">&#10007;</span></td>'

# Map: directive text (partial, unique) -> replacement for SCAN cell
# ECL matrix
$ecl = [ordered]@{
    '@SSG,IA</code></td>'          = 'P1'
    '@XQT .progname</code>'        = 'P1'
    '@USE lname,phys</code>'       = 'P1'
    '@FREE filename</code>'        = 'P1'
    '@ASG,UP</code>'               = ''     # confirmed in RunsPrd, no pattern card yet
    '@ASG,A</code>'                = ''
    '@DELETE,C</code>'             = ''
    '@CAT,P</code>'                = $null  # NOT FOUND - mark ✗
    '@ADD</code>'                  = ''
    '@LAB</code>'                  = ''
    '@ERS</code>'                  = ''
    '@UCOB,I</code>'               = $null  # NOT FOUND - mark ✗
    '#ucob,is</code>'              = $null  # NOT FOUND - mark ✗
    '#ACOB</code>'                 = ''
}
# SSG matrix
$ssg = [ordered]@{
    '*DEFINE</code>'               = 'P2'
    '*SET</code>'                  = 'P2'
    '*PROCESS</code>'              = 'P2'
    '*INCREMENT</code>'            = 'P3'
    '*IF</code>'                   = 'P4'
    '[PARAM,r,1,f]</code>'         = 'P5'
    '[PARAM,r,A,f]</code>'         = $null  # NOT FOUND - mark ✗
    '[PARAM,r,COL,f]</code>'       = $null  # NOT FOUND - mark ✗
    '[*varname]</code>'            = 'P5'
    '[*I]</code>'                  = 'P5'
}

function Replace-ScanCell([string]$html, [string]$directiveSnippet, $pat) {
    # Find the row by locating the directive snippet.
    # Then find the 13th <td class="cell"> within that row and replace it.
    $rowStart = $html.IndexOf($directiveSnippet)
    if ($rowStart -lt 0) {
        Write-Warning "NOT FOUND: $directiveSnippet"
        return $html
    }
    # Walk back to <tr>
    $trIdx = $html.LastIndexOf('<tr>', $rowStart)
    if ($trIdx -lt 0) {
        Write-Warning "No <tr> before: $directiveSnippet"
        return $html
    }
    $rowEnd = $html.IndexOf('</tr>', $rowStart)
    $row = $html.Substring($trIdx, $rowEnd - $trIdx + 5)

    # Count <td class="cell"> occurrences; SCAN is index 12 (0-based)
    $pos = 0; $count = 0; $scanStart = -1; $scanEnd = -1
    while ($true) {
        $found = $row.IndexOf('<td class="cell">', $pos)
        if ($found -lt 0) { break }
        if ($count -eq 12) {
            $scanStart = $found
            $scanEnd = $row.IndexOf('</td>', $found) + 5
            break
        }
        $pos = $found + 1
        $count++
    }
    if ($scanStart -lt 0) {
        Write-Warning "Could not find SCAN cell (13th) in row: $directiveSnippet"
        return $html
    }
    $oldCell = $row.Substring($scanStart, $scanEnd - $scanStart)
    if ($null -eq $pat) {
        $newCell = $yesNo
    } else {
        $newCell = $yesP[$pat]
    }
    $newRow = $row.Substring(0, $scanStart) + $newCell + $row.Substring($scanEnd)
    $label = if ($null -eq $pat) { 'no' } else { "yes$pat" }
    Write-Host "  $directiveSnippet -> $label"
    return $html.Substring(0, $trIdx) + $newRow + $html.Substring($trIdx + $row.Length)
}

foreach ($kvp in $ecl.GetEnumerator()) {
    $html = Replace-ScanCell $html $kvp.Key $kvp.Value
}
foreach ($kvp in $ssg.GetEnumerator()) {
    $html = Replace-ScanCell $html $kvp.Key $kvp.Value
}

[System.IO.File]::WriteAllText($path, $html, [System.Text.Encoding]::UTF8)
Write-Host "`nDone. SCAN column populated."
