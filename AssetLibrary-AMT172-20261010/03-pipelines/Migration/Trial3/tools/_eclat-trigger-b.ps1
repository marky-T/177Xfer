# Trigger B for ECLAT trial-09: populate the ECLAT column (11th data column) in the
# SSG-ECL-Command-Matrix.html. Processes both the ECL table (§2) and SSG table (§3).
#
# ECLAT (PROGRAM-ID UGXB02) ECL/SSG usage summary:
#   @SSG,IA: NO (uses #UCOB)    @XQT: YES    @USE: YES    @FREE: YES
#   @ASG,UP: NO    @ASG,A: YES  @DELETE,C: YES  @CAT,P: YES
#   @ADD: NO    @LAB/EOF: NO    @ERS: NO    @UCOB,I: YES    #ucob,is: NO    #ACOB: NO
#   *DEFINE: NO    *SET: YES-P2    *PROCESS: NO    *INCREMENT/*LOOP: YES-P3
#   *IF/*ELSE/*ENDIF: YES-P4    [PARAM,r,1,f]: YES-P5    [PARAM,r,A,f]: NO
#   [PARAM,r,COL,f]: NO    [*varname]: YES-P5    [*I]: NO

$file = 'C:\Amt\Migration\SSG-ECL-Command-Matrix.html'
$html = Get-Content $file -Raw -Encoding UTF8

# ── Cell snippet constants ─────────────────────────────────────────────────────
$PEND  = '            <td class="cell"><span class="cv cv-pend">&mdash;</span></td>'
$YES   = '            <td class="cell"><span class="cv cv-yes">&#10003;</span></td>'
$NO    = '            <td class="cell"><span style="color:#b91c1c;font-weight:700;">&#10007;</span></td>'
$NO_P6 = '            <td class="cell"><span style="color:#b91c1c;font-weight:700;">&#10007;</span><a class="pat-link" href="#pat-ucob">&#8594;P6</a></td>'
$YES_P1 = '            <td class="cell"><span class="cv cv-yes">&#10003;</span><a class="pat-link" href="#pat-ssg-ia">&#8594;P1</a></td>'
$YES_P2 = '            <td class="cell"><span class="cv cv-yes">&#10003;</span><a class="pat-link" href="#pat-define">&#8594;P2</a></td>'
$YES_P3 = '            <td class="cell"><span class="cv cv-yes">&#10003;</span><a class="pat-link" href="#pat-increment">&#8594;P3</a></td>'
$YES_P4 = '            <td class="cell"><span class="cv cv-yes">&#10003;</span><a class="pat-link" href="#pat-if">&#8594;P4</a></td>'
$YES_P5 = '            <td class="cell"><span class="cv cv-yes">&#10003;</span><a class="pat-link" href="#pat-tokens">&#8594;P5</a></td>'

# ── ECLAT values per row (in table order) ─────────────────────────────────────
# ECL table (§2): 14 rows
# SSG table (§3): 10 rows
# Total: 24 rows
$rowMap = [ordered]@{
    # ECL §2 table
    '@SSG,IA'              = $NO_P6    # ECLAT uses #UCOB, not @SSG,IA
    '@XQT .progname'       = $YES_P1   # #XQT TPF$.ARCH
    '@USE lname,phys'      = $YES_P1   # #USE LINK$PF,...
    '@FREE filename'       = $YES_P1   # #FREE (multiple)
    '@ASG,UP'              = $NO       # no ASG,UP in ECLAT
    '@ASG,A'               = $YES      # #ASG,A (FILEKEY, TABLE, SYS$LIB)
    '@DELETE,C'            = $YES      # #DELETE,C (FARCHIVE, FENCOURS)
    '@CAT,P'               = $YES      # #CAT,P (FARCHIVE, FENCOURS)
    '@ADD'                 = $NO       # no @ADD
    '@LAB'                 = $NO       # no tape label ops
    '@ERS'                 = $NO       # no #ERS
    '@UCOB,I'              = $YES      # #UCOB TPF$.arch inline compile
    '#ucob,is'             = $NO       # different form; ECLAT uses #UCOB not #ucob,is
    '#ACOB'                = $NO       # no #ACOB
    # SSG §3 table
    '*DEFINE'              = $NO       # no *DEFINE block
    '*SET'                 = $YES_P2   # *SET pos, fil, b, lg etc. (pre-COBOL section)
    '*PROCESS'             = $NO       # no *PROCESS
    '*INCREMENT'           = $YES_P3   # *increment a/b/c from 1 to [key] by 1
    '*IF'                  = $YES_P4   # *if [*a] = [key], *if [*pos] > ..., *endif
    '[PARAM,r,1,f]'        = $YES_P5   # [key,1,1,1], [filekey,1,1,1], [table,1,1,2] etc.
    '[PARAM,r,A,f]'        = $NO       # no A-variant row tokens
    '[PARAM,r,COL,f]'      = $NO       # no COL-variant tokens
    '[*varname]'           = $YES_P5   # [*a], [*b], [*pos], [*fil], [*lg] in loop bodies
    '[*I]'                 = $NO       # uses named letters (a,b,c) not [*I]
}

# ── Process each row: replace the 11th data cell (ECLAT column) ────────────────
$changes = 0
foreach ($directive in $rowMap.Keys) {
    $target = $rowMap[$directive]
    # Split HTML into <tr> segments; find the row for this directive; replace cell 11
    $rows = $html -split '(?=[ \t]*<tr[>\s])'
    $newRows = foreach ($row in $rows) {
        if ($row -match ('class="directive"><code>' + [regex]::Escape($directive))) {
            # Process line by line; count <td class="cell"> lines; replace the 11th
            $lines   = $row -split "`n"
            $cellIdx = 0
            $out     = foreach ($ln in $lines) {
                if ($ln -match '<td class="cell">') {
                    $cellIdx++
                    if ($cellIdx -eq 11 -and $ln -match 'cv-pend') {
                        $changes++
                        $target      # emit replacement cell line
                    } else {
                        $ln
                    }
                } else {
                    $ln
                }
            }
            $out -join "`n"
        } else {
            $row
        }
    }
    $html = $newRows -join ''
}

[System.IO.File]::WriteAllText($file, $html, [System.Text.Encoding]::UTF8)
Write-Host "Trigger B complete. $changes ECLAT cells updated."
