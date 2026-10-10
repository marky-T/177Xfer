# Fill-AfmtColumn.ps1 — sets ARCHIFORMAT (AFMT, 6th program column) cells
# in SSG-ECL-Command-Matrix.html for both ECL (Section 2) and SSG (Section 3) matrices.

$file = 'C:\Amt\Migration\SSG-ECL-Command-Matrix.html'
$html = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

$CELL_OPEN  = '<td class="cell">'
$CELL_CLOSE = '</td>'
$N          = 6   # AFMT is the 6th program column

# Cell HTML helpers
$YES   = '<td class="cell"><span class="cv cv-yes">&#10003;</span></td>'
$YES1  = '<td class="cell"><span class="cv cv-yes">&#10003;</span><a class="pat-link" href="#pat-ssg-ia">&#8594;P1</a></td>'
$NO    = '<td class="cell"><span style="color:#b91c1c;font-weight:700;">&#10007;</span></td>'
$NOP6  = '<td class="cell"><span style="color:#b91c1c;font-weight:700;">&#10007;</span><a class="pat-link" href="#pat-ucob">&#8594;P6</a></td>'
$PEND  = '<td class="cell"><span class="cv cv-pend">&mdash;</span></td>'

function Set-AfmtCell([string]$h, [string]$rowKey, [string]$newCell) {
    $keyPos = $h.IndexOf($rowKey)
    if ($keyPos -lt 0) { Write-Warning "  Row key not found: $rowKey"; return $h }

    $trStart = $h.LastIndexOf('<tr>', $keyPos)
    if ($trStart -lt 0) { Write-Warning "  <tr> not found for key: $rowKey"; return $h }
    $trEnd = $h.IndexOf('</tr>', $keyPos)
    if ($trEnd -lt 0) { Write-Warning "  </tr> not found for key: $rowKey"; return $h }
    $trEnd += 5   # include </tr>

    $row = $h.Substring($trStart, $trEnd - $trStart)

    # Find the Nth <td class="cell"> in the row
    $cellCount  = 0
    $searchFrom = 0
    $cellStart  = -1
    $cellEnd    = -1

    while ($cellCount -lt $N) {
        $pos = $row.IndexOf($CELL_OPEN, $searchFrom)
        if ($pos -lt 0) { Write-Warning "  Not enough cells in row: $rowKey"; return $h }
        $cellCount++
        $closePos = $row.IndexOf($CELL_CLOSE, $pos) + $CELL_CLOSE.Length
        if ($cellCount -eq $N) {
            $cellStart = $pos
            $cellEnd   = $closePos
        }
        $searchFrom = $closePos
    }

    if ($cellStart -lt 0) { Write-Warning "  Could not locate cell $N in row: $rowKey"; return $h }

    $oldCell = $row.Substring($cellStart, $cellEnd - $cellStart)
    Write-Host "  [$rowKey] replacing: $($oldCell.Substring(0,[Math]::Min(60,$oldCell.Length)))"

    $newRow = $row.Substring(0, $cellStart) + $newCell + $row.Substring($cellEnd)
    return $h.Substring(0, $trStart) + $newRow + $h.Substring($trEnd)
}

Write-Host '--- Updating header badges ---'
$html = $html.Replace('<th class="prog">AFMT</th>', '<th class="prog done-prog">AFMT</th>')
Write-Host '  Both AFMT headers -> done-prog'

Write-Host ''
Write-Host '--- Section 2: ECL Group A ---'
$html = Set-AfmtCell $html '<code>@SSG,IA</code>'       $NOP6
$html = Set-AfmtCell $html '<code>@XQT .progname</code>' $YES1
$html = Set-AfmtCell $html '<code>@USE lname,phys</code>' $YES1
$html = Set-AfmtCell $html '<code>@FREE filename</code>'  $YES1
# @ASG,UP, @ASG,A, @DELETE,C, @CAT,P, @ADD, @LAB/@EOF, @ERS — leave &mdash;

Write-Host ''
Write-Host '--- Section 2: ECL Group B ---'
$html = Set-AfmtCell $html '<code>@UCOB,I</code>'  $NO
$html = Set-AfmtCell $html '<code>#ucob,is</code>'  $YES
$html = Set-AfmtCell $html '<code>#ACOB</code>'     $NO

Write-Host ''
Write-Host '--- Section 3: SSG Group A (macros) ---'
$html = Set-AfmtCell $html '>*DEFINE<'       $NO
$html = Set-AfmtCell $html '<code>*SET</code>'                                   $YES
$html = Set-AfmtCell $html '<code>*PROCESS</code>'                               $NO

Write-Host ''
Write-Host '--- Section 3: SSG Group B (loop/cond) ---'
$html = Set-AfmtCell $html '>*INCREMENT<'   $NO
$html = Set-AfmtCell $html '>*ENDIF<'  $NO

Write-Host ''
Write-Host '--- Section 3: SSG Group C (tokens) ---'
$html = Set-AfmtCell $html '<code>[PARAM,r,1,f]</code>'    $YES
$html = Set-AfmtCell $html '<code>[PARAM,r,A,f]</code>'    $NO
$html = Set-AfmtCell $html '<code>[PARAM,r,COL,f]</code>'  $NO
$html = Set-AfmtCell $html '<code>[*varname]</code>'        $YES
$html = Set-AfmtCell $html '<code>[*I]</code>'              $NO

[System.IO.File]::WriteAllText($file, $html, [System.Text.Encoding]::UTF8)
Write-Host ''
Write-Host 'Done. SSG-ECL-Command-Matrix.html updated.'
