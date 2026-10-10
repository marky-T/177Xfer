# Fill LMND column (LOADIS_MULT-NODUP, position 12) in SSG-ECL-Command-Matrix.html
# Trial-14. Updates both the §2 ECL table and the §3 SSG Directives table.
# Uses shared helpers from EclProof-Helpers.ps1 (Get-MatrixCell, Replace-NthCell, Get-PatLabel).
. "$PSScriptRoot\EclProof-Helpers.ps1"

$htmlPath = 'C:\Amt\Migration\SSG-ECL-Command-Matrix.html'
$LMND_COL  = 12   # 1-indexed position among the 16 program columns

# Group B ECL directives to update (Group A ECL stays as-pend)
$ecl_updates = @{
    '@UCOB,I'   = (Get-MatrixCell -No)              # not present in LOADIS source
    '#ucob,is'  = (Get-MatrixCell -No)              # not present
    '#ACOB'     = (Get-MatrixCell -Yes)             # present: #ACOB,IPEC + #ACOB,IET
}

# SSG Macro Directive rows to update
$ssg_updates = @{
    '*DEFINE'         = (Get-MatrixCell -Yes -Pat 'pat-define')      # present: *DEFINE FILER block
    '*SET'            = (Get-MatrixCell -Yes -Pat 'pat-define')      # present: *SET FILLCTR inside DEFINE
    '*PROCESS'        = (Get-MatrixCell -No)                         # not present
    '*INCREMENT'      = (Get-MatrixCell -Yes -Pat 'pat-increment')   # present: 3 loops
    '*IF'             = (Get-MatrixCell -Yes -Pat 'pat-if')          # present: multiple *IF/*ELSE/*END
    '[PARAM,r,1,f]'   = (Get-MatrixCell -Yes -Pat 'pat-tokens')     # present: [INPUT,1,1,1] style tokens
    '[PARAM,r,A,f]'   = (Get-MatrixCell -No)                        # not present
    '[PARAM,r,COL,f]' = (Get-MatrixCell -No)                        # not present
    '[*varname]'      = (Get-MatrixCell -Yes -Pat 'pat-tokens')      # present: [*FILLCTR] in DEFINE block
    '[*I]'            = (Get-MatrixCell -Yes -Pat 'pat-tokens')      # present: loop variable
}

$lines = [System.IO.File]::ReadAllLines($htmlPath)

# ---- Update the two LMND column headers ----
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '<th class="prog">LMND</th>') {
        $lines[$i] = $lines[$i] -replace '<th class="prog">LMND</th>', '<th class="prog done-prog">LMND</th>'
        Write-Host "  Updated LMND header at line $($i+1)"
    }
}

# ---- Update §2 Group B ECL rows + §3 SSG rows ----
for ($i = 0; $i -lt $lines.Count; $i++) {
    $trimmed = $lines[$i].Trim()

    foreach ($key in $ecl_updates.Keys) {
        if ($trimmed -match "<td class=""directive""><code>$([regex]::Escape($key))</code>") {
            $idx = Replace-NthCell $lines $i $LMND_COL $ecl_updates[$key]
            if ($idx -ge 0) { Write-Host "  Updated ECL row '$key' at cell line $($idx+1)" }
            else            { Write-Warning "  Could not find cell $LMND_COL in row '$key'" }
        }
    }

    foreach ($key in $ssg_updates.Keys) {
        $codeEsc = [regex]::Escape($key)
        if ($trimmed -match "<td class=""directive""><code>$codeEsc") {
            $idx = Replace-NthCell $lines $i $LMND_COL $ssg_updates[$key]
            if ($idx -ge 0) { Write-Host "  Updated SSG row '$key' at cell line $($idx+1)" }
            else            { Write-Warning "  Could not find cell $LMND_COL in row '$key'" }
        }
    }
}

$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllLines($htmlPath, $lines, $enc)
Write-Host "Done. SSG-ECL-Command-Matrix.html saved."
