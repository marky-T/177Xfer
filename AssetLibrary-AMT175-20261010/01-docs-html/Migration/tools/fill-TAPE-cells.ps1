# Fill TAPE column (TAPELD_DISTRIB, position 14) in SSG-ECL-Command-Matrix.html
# Trial-17. Updates both the §2 ECL table and the §3 SSG Directives table.
# Uses shared helpers from EclProof-Helpers.ps1 (Get-MatrixCell, Replace-NthCell, Get-PatLabel).
. "$PSScriptRoot\EclProof-Helpers.ps1"

$htmlPath = 'C:\Amt\Migration\SSG-ECL-Command-Matrix.html'
$TAPE_COL  = 14   # 1-indexed position among the 16 program columns

# Group B ECL: analyse ASSURFED_UTILIT_TAPELD_DISTRIB(P).TXT
#   @UCOB,I  : not present
#   #ucob,is : not present
#   #ACOB    : present (#ACOB,IPEC and #ACOB,IPECT in *IF [ASCII]>0 / *ELSE block)
$ecl_updates = @{
    '@UCOB,I'   = (Get-MatrixCell -No)
    '#ucob,is'  = (Get-MatrixCell -No)
    '#ACOB'     = (Get-MatrixCell -Yes)   # present; no specific P-card
}

# SSG Macro Directives
#   *DEFINE   : present — *DEFINE FILER block (P2)
#   *SET      : present — *SET FILLCTR TO [#1]-1 inside DEFINE (P2)
#   *PROCESS  : present — *PROCESS FILER in FIELDIN/FIELDOUT/FIXE loops (suppressed at simplification; still in source)
#   *INCREMENT: present — *INCREMENT I in FIELDIN/FIELDOUT/FIXE loops (suppressed) (P3)
#   *IF       : present — many conditions: [ASCII], [INPUT,1,1,1]=CARDREADER, [OUTPUT,...]=PRINTER/CARDPUNCH etc. (P4)
#   [PARAM,r,1,f]: present — scalar tokens: [INPUT,1,1,1], [INPUT,1,1,2], [OUTPUT,1,1,1] etc. (P5)
#   [PARAM,r,A,f]: present — subscripted loop tokens: [FIELDIN,1,I,1], [FIELDOUT,1,I,2] etc. in suppressed blocks (P5)
#   [PARAM,r,COL,f]: not present
#   [*varname]: present — [*FILLCTR] inside *DEFINE FILER body (P5)
#   [*I]      : present — loop counter in suppressed *INCREMENT blocks (P5)
$ssg_updates = @{
    '*DEFINE'         = (Get-MatrixCell -Yes -Pat 'pat-define')
    '*SET'            = (Get-MatrixCell -Yes -Pat 'pat-define')
    '*PROCESS'        = (Get-MatrixCell -Yes)
    '*INCREMENT'      = (Get-MatrixCell -Yes -Pat 'pat-increment')
    '*IF'             = (Get-MatrixCell -Yes -Pat 'pat-if')
    '[PARAM,r,1,f]'   = (Get-MatrixCell -Yes -Pat 'pat-tokens')
    '[PARAM,r,A,f]'   = (Get-MatrixCell -Yes -Pat 'pat-tokens')
    '[PARAM,r,COL,f]' = (Get-MatrixCell -No)
    '[*varname]'      = (Get-MatrixCell -Yes -Pat 'pat-tokens')
    '[*I]'            = (Get-MatrixCell -Yes -Pat 'pat-tokens')
}

$lines = [System.IO.File]::ReadAllLines($htmlPath)

# ---- Update the two TAPE column headers ----
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '<th class="prog">TAPE</th>') {
        $lines[$i] = $lines[$i] -replace '<th class="prog">TAPE</th>', '<th class="prog done-prog">TAPE</th>'
        Write-Host "  Updated TAPE header at line $($i+1)"
    }
}

# ---- Update §2 Group B ECL rows + §3 SSG rows ----
for ($i = 0; $i -lt $lines.Count; $i++) {
    $trimmed = $lines[$i].Trim()

    foreach ($key in $ecl_updates.Keys) {
        if ($trimmed -match "<td class=""directive""><code>$([regex]::Escape($key))</code>") {
            $idx = Replace-NthCell $lines $i $TAPE_COL $ecl_updates[$key]
            if ($idx -ge 0) { Write-Host "  Updated ECL row '$key' at cell line $($idx+1)" }
            else            { Write-Warning "  Could not find cell $TAPE_COL in row '$key'" }
        }
    }

    foreach ($key in $ssg_updates.Keys) {
        $codeEsc = [regex]::Escape($key)
        if ($trimmed -match "<td class=""directive""><code>$codeEsc") {
            $idx = Replace-NthCell $lines $i $TAPE_COL $ssg_updates[$key]
            if ($idx -ge 0) { Write-Host "  Updated SSG row '$key' at cell line $($idx+1)" }
            else            { Write-Warning "  Could not find cell $TAPE_COL in row '$key'" }
        }
    }
}

$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllLines($htmlPath, $lines, $enc)
Write-Host "Done. SSG-ECL-Command-Matrix.html saved."
