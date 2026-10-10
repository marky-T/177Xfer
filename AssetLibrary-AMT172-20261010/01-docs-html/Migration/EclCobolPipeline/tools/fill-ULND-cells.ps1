# Fill ULND (UNLOADIS_MULT-NODUP) column cells in SSG-ECL-Command-Matrix.html
# Uses row-by-row HTML approach: finds each row by directive code text, replaces the 16th cell.

$htmlPath = "C:\Amt\Migration\SSG-ECL-Command-Matrix.html"
$colIndex  = 16  # ULND is the 16th <td class="cell"> in each data row

$CV_YES   = '<span class="cv cv-yes">&#10003;</span>'
$CV_NO    = '<span style="color:#b91c1c;font-weight:700;">&#10007;</span>'
$CV_PEND  = '<span class="cv cv-pend">&mdash;</span>'
$CELL_YES = "<td class=""cell"">$CV_YES</td>"
$CELL_NO  = "<td class=""cell"">$CV_NO</td>"
$CELL_P2  = "<td class=""cell"">$CV_YES<a class=""pat-link"" href=""#pat-define"">&#8594;P2</a></td>"
$CELL_P4  = "<td class=""cell"">$CV_YES<a class=""pat-link"" href=""#pat-if"">&#8594;P4</a></td>"
$CELL_P5  = "<td class=""cell"">$CV_YES<a class=""pat-link"" href=""#pat-tokens"">&#8594;P5</a></td>"
$CELL_PEND= "<td class=""cell"">$CV_PEND</td>"

# Cell values for ULND per directive (using FIRST <code> text in the directive cell as key)
# Group A (RunsPrd - leave as PEND) => all stay as-is (no change for Group A rows)
# Group B (SSG-Embedded ECL)
# §3 SSG Directives
$cells = @{
    # §2 Group B ECL
    '@UCOB,I'         = $CELL_NO
    '#ucob,is'        = $CELL_NO
    '#ACOB'           = $CELL_YES

    # §3 Group A SSG Macros  (keys = first <code> text in the cell)
    '*DEFINE'         = $CELL_P2   # *DEFINE…*END row
    '*SET'            = $CELL_P2
    '*PROCESS'        = $CELL_NO

    # §3 Group B SSG Loop/Conditional
    '*INCREMENT'      = $CELL_NO   # *INCREMENT…*LOOP row
    '*IF'             = $CELL_P4   # *IF / *ELSE / *ENDIF row

    # §3 Group C Token forms
    '[PARAM,r,1,f]'   = $CELL_P5
    '[PARAM,r,A,f]'   = $CELL_NO
    '[PARAM,r,COL,f]' = $CELL_NO
    '[*varname]'      = $CELL_P5
    '[*I]'            = $CELL_NO
}

$raw = [System.IO.File]::ReadAllText($htmlPath)

# Split into segments on <tr> boundaries, preserving delimiters
$segments = [System.Text.RegularExpressions.Regex]::Split($raw, '(<tr[\s>]|</tr>)')

$changed = 0

for ($i = 0; $i -lt $segments.Count; $i++) {
    $seg = $segments[$i]
    # Check if this is a <tr> content segment (not a tag itself)
    if ($seg -notmatch '<td' ) { continue }

    # Find directive code text in this segment
    $codeMatch = [System.Text.RegularExpressions.Regex]::Match($seg, '<td class="directive"><code>([^<]+)</code>')
    if (-not $codeMatch.Success) { continue }

    $directiveText = $codeMatch.Groups[1].Value.Trim()
    if (-not $cells.ContainsKey($directiveText)) { continue }

    $newCell = $cells[$directiveText]

    # Count to the colIndex-th <td class="cell"> in this segment and replace it
    $cellPattern = '<td class="cell">.*?</td>'
    $cellMatches = [System.Text.RegularExpressions.Regex]::Matches($seg, $cellPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)

    if ($cellMatches.Count -lt $colIndex) {
        Write-Warning "Row '$directiveText': found $($cellMatches.Count) cells, expected >= $colIndex"
        continue
    }

    $targetMatch = $cellMatches[$colIndex - 1]  # 0-based index
    $oldCell = $targetMatch.Value

    if ($oldCell -eq $newCell) {
        Write-Host "  SKIP (already set): $directiveText"
        continue
    }

    $segments[$i] = $seg.Remove($targetMatch.Index, $targetMatch.Length).Insert($targetMatch.Index, $newCell)
    $changed++
    Write-Host "  SET $directiveText  col=$colIndex  $($oldCell.Substring(0,[Math]::Min(60,$oldCell.Length))) -> $($newCell.Substring(0,[Math]::Min(60,$newCell.Length)))"
}

$result = $segments -join ''
[System.IO.File]::WriteAllText($htmlPath, $result, [System.Text.Encoding]::UTF8)
Write-Host "Done. $changed cell(s) updated."
