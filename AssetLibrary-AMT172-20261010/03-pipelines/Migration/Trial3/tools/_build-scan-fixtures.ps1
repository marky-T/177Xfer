# Generates fixtures\scan\input.dat and fixtures\scan\expected.dat
# for the SCAN-VAR_ASCII Tier-1 proof.
#
# Parameterisation: ASCII=1, INPUT,1,1=3, all optional features off.
# PROGRAM-ID SCAN: reads all records, prints each with a CT-LINE header.
# Input: 3 x 80-char fixed records (CRLF). Output: printer simulation (100-char lines, CRLF).
#
# COBOL logic (condensed for 3 records):
#   FIVE-CT starts at 6.
#   Per record: FIVE-CT++ (7,8,9 — never >9 for 3 recs) -> CT-LINE then data line.
#   End: 9 blank lines (AFTER ADVANCING 10) then M-LINE.

$fixtureDir = 'C:\Amt\Migration\EclCobolPipeline\fixtures\scan'

# ── Input records (3 x 80-char, CRLF) ───────────────────────────────────────
$enc  = [System.Text.Encoding]::ASCII
$crlf = [byte[]](13, 10)
$inputStream = [System.Collections.Generic.List[byte]]::new()
$recs = @(
    ('A' * 80),
    ('B' * 80),
    ('C' * 80)
)
foreach ($r in $recs) {
    $inputStream.AddRange([byte[]]($enc.GetBytes($r)))
    $inputStream.AddRange($crlf)
}
[System.IO.File]::WriteAllBytes("$fixtureDir\input.dat", $inputStream.ToArray())
Write-Host "input.dat : $($inputStream.Count) bytes  ($($recs.Count) records)"

# ── Expected output ──────────────────────────────────────────────────────────
# CT-LINE (100 chars): '**' + ZZZZ9(n) + '**' + 91 spaces
# Data line (100 chars): 80-char record + 20 spaces
# End: 9 blank lines + M-LINE (100 chars)

$M_FILLER1 = '** END SCAN **      '           # PIC X(20)
$M_FILLER2 = 'RECORDS READ FROM ECL-FICHIN-1 = '.PadRight(37)  # PIC X(37)
$M_FILLER4 = ' RECORD MATCHING = '            # PIC X(19)

$outputLines = [System.Collections.Generic.List[string]]::new()
$FIVE_CT     = 6
$REC_IN_CT   = 0
$REC_FOUND_CT = 0

foreach ($r in $recs) {
    $REC_IN_CT++
    $REC_FOUND_CT++
    $FIVE_CT++

    if ($FIVE_CT -gt 9) {
        # F-LINE: '**' + ZZZZ9 + '**' + column rulers, truncated to 100
        $fct   = ('{0,5}' -f $REC_IN_CT)
        $ruler = '1.........2.........3.........4.........5.........6.........7.........8.........9.........0.........1.........2.........3..'
        $fLine = ('**' + $fct + '**' + $ruler).PadRight(100).Substring(0, 100)
        $outputLines.Add($fLine)
        $FIVE_CT = 1
    } else {
        # CT-LINE: '**' + ZZZZ9(REC_IN_CT) + '**' + 91 spaces (= 100 chars)
        $ct     = ('{0,5}' -f $REC_IN_CT)
        $ctLine = ('**' + $ct + '**').PadRight(100)
        $outputLines.Add($ctLine)
    }

    # Data line: 80-char record padded to 100
    $outputLines.Add($r.PadRight(100))
}

# END-OUT: AFTER ADVANCING 10 LINES = 9 blank lines then M-LINE
for ($k = 0; $k -lt 9; $k++) { $outputLines.Add('') }

# M-LINE (98 chars) padded to PRT-LINE (100 chars)
$mct  = ('{0,11}' -f $REC_IN_CT)    # Z(10)9 = 11 chars right-justified
$fnct = ('{0,11}' -f $REC_FOUND_CT)
$mRaw = $M_FILLER1 + $M_FILLER2 + $mct + $M_FILLER4 + $fnct   # 98 chars
$mLine = $mRaw.PadRight(100)
$outputLines.Add($mLine)

# Write expected.dat (CRLF-terminated, ASCII)
[System.IO.File]::WriteAllLines("$fixtureDir\expected.dat", $outputLines, $enc)

$expectedBytes = (Get-Item "$fixtureDir\expected.dat").Length
Write-Host "expected.dat : $expectedBytes bytes  ($($outputLines.Count) lines)"

# Spot-check
Write-Host ''
Write-Host '--- Spot-check ---'
Write-Host "Line 1 (CT  ): [$($outputLines[0].Substring(0,15))...] (len=$($outputLines[0].Length))"
Write-Host "Line 2 (data): [$($outputLines[1].Substring(0,15))...] (len=$($outputLines[1].Length))"
Write-Host "Line 7 (blank): len=$($outputLines[6].Length)"
Write-Host "Last (M-LINE): [$($outputLines[-1].Substring(0,40))...] (len=$($outputLines[-1].Length))"
