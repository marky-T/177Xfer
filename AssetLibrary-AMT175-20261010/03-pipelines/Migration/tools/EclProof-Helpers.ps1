# EclProof-Helpers.ps1
# Shared helper functions dot-sourced by all fill-XXX-cells.ps1 scripts.
# Dot-source at the top of each fill script: . "$PSScriptRoot\EclProof-Helpers.ps1"

<#
.SYNOPSIS
  Returns the P-number label string for a pat-card ID.
  Add new entries here when a new P-card is created (Trigger E).
#>
function Get-PatLabel([string]$patId) {
    switch ($patId) {
        'pat-define'    { return 'P2' }
        'pat-increment' { return 'P3' }
        'pat-if'        { return 'P4' }
        'pat-tokens'    { return 'P5' }
        'pat-ucob'      { return 'P6' }
        default         { return 'Pn' }   # unknown — update this table when a new P-card is added
    }
}

<#
.SYNOPSIS
  Returns the HTML for a matrix cell.
  Usage:
    Get-MatrixCell -Yes              # ✓ without link
    Get-MatrixCell -Yes -Pat 'pat-if'  # ✓ →P4
    Get-MatrixCell -No               # ✗
    Get-MatrixCell -Pend             # — (leave as pending)
#>
function Get-MatrixCell {
    param(
        [switch]$Yes,
        [switch]$No,
        [switch]$Pend,
        [string]$Pat = ''
    )
    if ($Pend) { return '<td class="cell"><span class="cv cv-pend">&mdash;</span></td>' }
    if ($No)   { return '<td class="cell"><span style="color:#b91c1c;font-weight:700;">&#10007;</span></td>' }
    if ($Yes) {
        if ($Pat) {
            $label = Get-PatLabel $Pat
            return '<td class="cell"><span class="cv cv-yes">&#10003;</span><a class="pat-link" href="#' + $Pat + '">&#8594;' + $label + '</a></td>'
        }
        return '<td class="cell"><span class="cv cv-yes">&#10003;</span></td>'
    }
    throw "Get-MatrixCell: specify -Yes, -No, or -Pend"
}

<#
.SYNOPSIS
  In-place replace the N-th <td class="cell"> in the <tr> starting at $startIdx.
  Returns the line index of the replaced cell, or -1 if not found.
#>
function Replace-NthCell($lines, [int]$startIdx, [int]$n, [string]$newCell) {
    $cellCount = 0
    for ($i = $startIdx; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '<td class="cell">') {
            $cellCount++
            if ($cellCount -eq $n) {
                $lines[$i] = $lines[$i] -replace '<td class="cell">.*?</td>', $newCell
                return $i
            }
        }
        if ($lines[$i] -match '</tr>') { break }
    }
    return -1
}
