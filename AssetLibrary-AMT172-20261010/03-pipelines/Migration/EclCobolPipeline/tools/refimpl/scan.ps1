<#
.SYNOPSIS
  Tier-1 PowerShell reference oracle for SSG-COBOL program SCAN (SCAN-VAR_ASCII).

.DESCRIPTION
  Faithful stand-in for the converted SCAN logic, used as the Tier-1 golden
  executor in the SSG-COBOL -> C# proof harness. No AMT runtime required.

  Cleaned COBOL (candidates/trial-08-scan/SCAN.TXT) semantics reproduced:
    * Parameterisation: ASCII=1, 80-char fixed records, no KEY/IF/DESC/INDIC/NOCONT.
      All records are "found" (no conditional filtering). PROGRAM-ID = SCAN.
    * INPUT:  FICHIN-1 (DISC, 80-char fixed, CRLF-delimited records)
    * OUTPUT: PRT (PRINTER, 100-char lines, CRLF-terminated)

  Per-record output (FOUND-REC):
    * CT-LINE header:   '**{ZZZZ9}**' + 91 spaces = 100 chars (while FIVE-CT <=9)
    * F-LINE header:    '**{ZZZZ9}**' + column ruler truncated to 100 (every 9th+ rec)
    * Data line:        80-char record padded to 100 chars (PRINT-LINE-1)
    FIVE-CT starts at 6; increments per FOUND-REC; resets to 1 when > 9.

  End-of-file (END-OUT):
    * WRITE M-LINE AFTER ADVANCING 10 LINES = 9 blank lines then M-LINE (100 chars)
    * M-LINE = '** END SCAN **      ' (20) + 'RECORDS READ FROM ECL-FICHIN-1 = '
               padded to 37 + Z(10)9(REC-IN-CT) (11) + ' RECORD MATCHING = ' (19)
               + Z(10)9(REC-FOUND-CT) (11) = 98 chars, padded to PRT-LINE 100 chars.

  Tier-2 note: at Tier-2 (real C# under AMT runtime), verify the same output
  format, replacing ECL-FICHIN-1 stub with the actual production file name.

.PARAMETER InFile
  Path to the input file (materialised by the proof harness from fixtures/scan/input.dat).
  Contains 80-char fixed records, CRLF-delimited.

.PARAMETER OutFile
  Path for the printer output (written by this oracle; compared to expected.dat).
#>
param(
    [Parameter(Mandatory)][string]$InFile,
    [Parameter(Mandatory)][string]$OutFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Read input (80-char fixed, CRLF-delimited) ────────────────────────────────
$raw = [System.IO.File]::ReadAllBytes($InFile)
$inputRecs = [System.Collections.Generic.List[string]]::new()
$enc = [System.Text.Encoding]::ASCII
$i = 0
while ($i -lt $raw.Length) {
    $j = $i
    while ($j -lt $raw.Length -and $raw[$j] -ne 13 -and $raw[$j] -ne 10) { $j++ }
    if ($j -gt $i) {
        $inputRecs.Add($enc.GetString($raw, $i, $j - $i).PadRight(80))
    }
    $i = $j
    if ($i -lt $raw.Length -and $raw[$i] -eq 13) { $i++ }
    if ($i -lt $raw.Length -and $raw[$i] -eq 10)  { $i++ }
}

# ── COBOL WS working storage ──────────────────────────────────────────────────
$FIVE_CT      = 6   # VALUE 6
$REC_IN_CT    = 0
$REC_FOUND_CT = 0

# F-LINE column ruler (positions 9.. of F-LINE, truncated to 100 in WRITE)
$F_RULER = '1.........2.........3.........4.........5.........6.........7.........8.........9.........0.........1.........2.........3..'

# M-LINE constants (ECL-stub values from paramOverrides)
$M_FILLER1 = '** END SCAN **      '   # PIC X(20)
$M_FILLER2 = 'RECORDS READ FROM ECL-FICHIN-1 = '.PadRight(37)   # PIC X(37): 33 chars + 4 spaces
$M_FILLER4 = ' RECORD MATCHING = '   # PIC X(19)

# ── Proof output stream ────────────────────────────────────────────────────────
$output = [System.Collections.Generic.List[string]]::new()

# ── Main loop (FIRST-READ / LR / PLUS-UN / SUITE-RECHERCHE / FOUND-REC) ──────
foreach ($rec in $inputRecs) {
    # ADD 1 TO CTRLU (CTRLU not used in output — tracked for fidelity only)
    # PLUS-UN:
    $REC_IN_CT++
    # SUITE-RECHERCHE: empty (INDIC=0) -> fall through to FOUND-REC
    # FOUND-REC:
    $REC_FOUND_CT++
    # MOVE ZERO TO LINE-CNT  (not used in output calculation)
    $FIVE_CT++

    if ($FIVE_CT -gt 9) {
        # WRITE PRT-LINE FROM F-LINE AFTER 1
        # F-LINE: '**' + ZZZZ9(REC_IN_CT) + '**' + ruler; truncate to PRT-LINE 100 chars
        $fct   = ('{0,5}' -f $REC_IN_CT)
        $fLine = ('**' + $fct + '**' + $F_RULER).Substring(0, 100)
        $output.Add($fLine)
        $FIVE_CT = 1
    } else {
        # WRITE PRT-LINE FROM CT-LINE AFTER 1
        # CT-LINE: '**' + ZZZZ9(REC_IN_CT) + '**' + 122 spaces; truncate to 100
        $ct     = ('{0,5}' -f $REC_IN_CT)
        $ctLine = ('**' + $ct + '**').PadRight(100)
        $output.Add($ctLine)
    }

    # WRITE PRT-LINE FROM PRINT-LINE-1 AFTER ADVANCING SKIP (SKIP=1)
    # PRINT-LINE-1 = 80-char record padded to PRT-LINE 100 chars
    $output.Add($rec.PadRight(100))

    # MOVE SPACES TO REC-AREA (implicit for next READ INTO)
}

# ── END-OUT: WRITE M-LINE AFTER ADVANCING 10 LINES ───────────────────────────
# AFTER ADVANCING 10 = advance 10 lines; interpreted as 9 blank lines + 1 content line
for ($k = 0; $k -lt 9; $k++) { $output.Add('') }

# M-LINE (98 chars) padded to PRT-LINE (100 chars)
$mct   = ('{0,11}' -f $REC_IN_CT)    # Z(10)9 = 10 zero-suppressed + 1 digit = 11 chars
$fnct  = ('{0,11}' -f $REC_FOUND_CT)
$mRaw  = $M_FILLER1 + $M_FILLER2 + $mct + $M_FILLER4 + $fnct  # 20+37+11+19+11 = 98 chars
$output.Add($mRaw.PadRight(100))

# ── Write output (CRLF, ASCII) ────────────────────────────────────────────────
[System.IO.File]::WriteAllLines($OutFile, $output, $enc)
