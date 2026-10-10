# One-shot generator for LECTIS Tier-1 fixtures.
# input.dat   = 3 x 120-char sequential records (flat; Tier-1 reads FICHIN sequentially via START > LOW-VALUES + READ NEXT).
#               Same key layout as Phase-14 FICHIN-1 (C:\Amt\Working\Files\Extracts\FICHIN-1):
#               SYMK PIC X(8) + SYMK1 PIC X(4) + remainder spaces, total 120 chars, CRLF-delimited.
# expected.dat = INDEPENDENTLY hand-derived PRINTER output (IMP file), logical content only
#               (no LINAGE page-control headers; BEFORE PAGE / BEFORE SAUT produce plain blank lines).
#               Derived by tracing LECTIS COBOL (candidates/trial-05-lectis/LECTIS.TXT):
#
#   OUVERT: WRITE ZP1 BEFORE PAGE -> ZP1=spaces -> blank line
#   Per record:
#     SUITE:  WRITE TIT BEFORE 1  -> "***  RECORD NUMERO " + FILCO(Z.ZZZ.ZZZ) + "  ***" (33 chars)
#             PERFORM IMPRES:
#               WRITE ZP1 BEFORE 1  -> chars 1-100 of WREC, trailing spaces trimmed
#               WRITE ZP2 BEFORE 1  -> chars 101-120+80spaces trimmed (blank for 120-char recs where 101-120=spaces)
#               CTRLI reaches 200 -> GO TO RAZ:
#                 MOVE ALL '*' TO ZPRINT; WRITE ZPRINT BEFORE 1 -> 100 asterisks
#   FIN: WRITE ZPRINT(spaces) BEFORE SAUT -> blank line
#        DISPLAY ... UPON PRINTER -> sysout (not IMP file, omitted)
#
# FILCO PIC Z.ZZZ.ZZZ (DECIMAL-POINT IS COMMA, group sep='.'):
#   CTR=1 -> '        1'  CTR=2 -> '        2'  CTR=3 -> '        3'
$ErrorActionPreference = 'Stop'
$dir = $PSScriptRoot
function Rec([string]$key) { $key.PadRight(120) }
$in = @(
    (Rec 'AAAAAAAAAAAA'),
    (Rec 'BBBBBBBBBBBB'),
    (Rec 'CCCCCCCCCCCC')
)
$sep = '*' * 100
$exp = @(
    '',                                         # OUVERT: WRITE ZP1 BEFORE PAGE
    '***  RECORD NUMERO         1  ***',        # TIT CTR=1
    'AAAAAAAAAAAA',                             # ZP1
    '',                                         # ZP2 (all spaces, trimmed)
    $sep,
    '***  RECORD NUMERO         2  ***',
    'BBBBBBBBBBBB',
    '',
    $sep,
    '***  RECORD NUMERO         3  ***',
    'CCCCCCCCCCCC',
    '',
    $sep,
    ''                                          # FIN: WRITE ZPRINT BEFORE SAUT
)
[IO.File]::WriteAllText((Join-Path $dir 'input.dat'),    (($in  -join "`r`n") + "`r`n"))
[IO.File]::WriteAllText((Join-Path $dir 'expected.dat'), (($exp -join "`r`n") + "`r`n"))
Write-Host ("input.dat    bytes=" + (Get-Item (Join-Path $dir 'input.dat')).Length)
Write-Host ("expected.dat bytes=" + (Get-Item (Join-Path $dir 'expected.dat')).Length)
Get-Content (Join-Path $dir 'expected.dat') | ForEach-Object { Write-Host ('[' + $_ + ']') }
