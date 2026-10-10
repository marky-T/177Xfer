# Fill UNL column (UNLOADIS_MULT, position 15) in SSG-ECL-Command-Matrix.html
# Trial-15. Updates both the §2 ECL table and the §3 SSG Directives table.
# Uses shared helpers from EclProof-Helpers.ps1 (Get-MatrixCell, Replace-NthCell, Get-PatLabel).
. "$PSScriptRoot\EclProof-Helpers.ps1"

$htmlPath = 'C:\Amt\Migration\SSG-ECL-Command-Matrix.html'
$UNL_COL   = 15   # 1-indexed position among the 16 program columns

# Group B ECL: analyse ASSURFED_UTILIT_UNLOADIS_MULT(P).TXT
#   @UCOB,I  : not present
#   #ucob,is : not present
#   #ACOB    : present (#ACOB,IPEC and #ACOB,IT)
$ecl_updates = @{
    '@UCOB,I'   = (Get-MatrixCell -No)
    '#ucob,is'  = (Get-MatrixCell -No)
    '#ACOB'     = (Get-MatrixCell -Yes)     # present; no specific P-card
}

# SSG Macro Directives
$ssg_updates = @{
    '*DEFINE'         = (Get-MatrixCell -Yes -Pat 'pat-define')
    '*SET'            = (Get-MatrixCell -Yes -Pat 'pat-define')
    '*PROCESS'        = (Get-MatrixCell -No)
    '*INCREMENT'      = (Get-MatrixCell -No)
    '*IF'             = (Get-MatrixCell -Yes -Pat 'pat-if')
    '[PARAM,r,1,f]'   = (Get-MatrixCell -Yes -Pat 'pat-tokens')
    '[PARAM,r,A,f]'   = (Get-MatrixCell -No)
    '[PARAM,r,COL,f]' = (Get-MatrixCell -No)
    '[*varname]'      = (Get-MatrixCell -Yes -Pat 'pat-tokens')
    '[*I]'            = (Get-MatrixCell -No)
}

$lines = [System.IO.File]::ReadAllLines($htmlPath)

# ---- Update the two UNL column headers ----
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '<th class="prog">UNL</th>') {
        $lines[$i] = $lines[$i] -replace '<th class="prog">UNL</th>', '<th class="prog done-prog">UNL</th>'
        Write-Host "  Updated UNL header at line $($i+1)"
    }
}

# ---- Update §2 Group B ECL rows + §3 SSG rows ----
for ($i = 0; $i -lt $lines.Count; $i++) {
    $trimmed = $lines[$i].Trim()

    foreach ($key in $ecl_updates.Keys) {
        if ($trimmed -match "<td class=""directive""><code>$([regex]::Escape($key))</code>") {
            $idx = Replace-NthCell $lines $i $UNL_COL $ecl_updates[$key]
            if ($idx -ge 0) { Write-Host "  Updated ECL row '$key' at cell line $($idx+1)" }
            else            { Write-Warning "  Could not find cell $UNL_COL in row '$key'" }
        }
    }

    foreach ($key in $ssg_updates.Keys) {
        $codeEsc = [regex]::Escape($key)
        if ($trimmed -match "<td class=""directive""><code>$codeEsc") {
            $idx = Replace-NthCell $lines $i $UNL_COL $ssg_updates[$key]
            if ($idx -ge 0) { Write-Host "  Updated SSG row '$key' at cell line $($idx+1)" }
            else            { Write-Warning "  Could not find cell $UNL_COL in row '$key'" }
        }
    }
}

$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllLines($htmlPath, $lines, $enc)
Write-Host "Done. SSG-ECL-Command-Matrix.html saved."
