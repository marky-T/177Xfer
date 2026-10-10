<#
.SYNOPSIS
  Tier-1 PowerShell reference oracle for SSG-COBOL program LOADIS-ASCII
  (SSG element: LOADIS_MULT-NODUP).

.DESCRIPTION
  Faithful stand-in for the LOADIS-ASCII COBOL logic used as the Tier-1 golden
  executor in the SSG-COBOL -> C# proof harness. No AMT runtime required.

  Cleaned COBOL semantics reproduced (candidates/trial-14-loadis-ascii/LOADIS-ASCII.TXT):
    * INPUT  BDE1    (ECL-BDE1): fixed 80-byte records, CRLF-delimited.
    * OUTPUT DISQ    (ECL-DISQ): indexed file — simulated sequentially here.
      Each input record is READ INTO WREC (first 20 bytes only, PIC X(20)).
      MOVE KEYA(8) -> CLEF; MOVE KEYB(12) -> CLEG; WRITE ZDISQ FROM WREC.
      Since test input has no duplicate keys, INVALID KEY is never reached.
    * OUTPUT PRINTER: DISPLAY 'NB.RECORDS ECRITS' CTRIN UPON PRINTER.
      CTRIN PIC 9(10) COMP VALUE 0; incremented once per successful WRITE.
      Display format: zero-padded 10-digit decimal.

  Combined output written to $OutFile (= PRINTER assignment):
    DISQ records (20-char each, CRLF)
    PRINTER line  (CRLF)

  Trial-14. Simplified: ASCII=1, INPUT,1=1, KEYIS=2, no fillers.
  Input record size=80, DISQ record size=20 (CLEF=8 + CLEG=12).

.PARAMETER InFile
  Path to the BDE1 fixture file (assign.json BDE1 -> input.dat).

.PARAMETER OutFile
  Combined output path (assign.json PRINTER -> output.dat).
  DISQ records are written first, PRINTER line follows.
#>
param(
    [Parameter(Mandatory)][string]$InFile,
    [Parameter(Mandatory)][string]$OutFile
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path $InFile)) { throw "InFile not found: $InFile" }

$RSZ_IN  = 80   # [INPUT,1,1,2]
$RSZ_OUT = 20   # [OUTPUT,1,1,2] = CLEF(8) + CLEG(12)

# ── Read BDE1 records ─────────────────────────────────────────────────────────
$lines = [System.IO.File]::ReadAllLines($InFile)

$disqRecords = [System.Collections.Generic.List[string]]::new()
$ctrin       = 0
$ff          = 1    # GO TO LECT1 FINB DEPENDING ON FF: 1->LECT1, 2->FINB

foreach ($line in $lines) {
    # READ BDE1 INTO WREC: take first RSZ_OUT bytes of the RSZ_IN-byte record
    $rec = $line.PadRight($RSZ_IN).Substring(0, $RSZ_IN)
    $wrec = $rec.Substring(0, $RSZ_OUT)

    # MOVE KEYA TO CLEF; MOVE KEYB TO CLEG (just layout names for documentation)
    # WRITE ZDISQ FROM WREC — no duplicate key in clean test input
    $disqRecords.Add($wrec)
    $ctrin++
}
# (AT END: ADD 1 TO FF -> FF becomes 2 -> next GO TO LECT1 FINB goes to FINB)

# ── FINB: DISPLAY 'NB.RECORDS ECRITS' CTRIN UPON PRINTER ─────────────────────
# CTRIN PIC 9(10) COMP displayed as zero-padded 10-digit decimal
$ctrinStr = $ctrin.ToString('D10')
$printerLine = 'NB.RECORDS ECRITS' + $ctrinStr

# ── Write combined output: DISQ records then PRINTER line ────────────────────
$all = [System.Collections.Generic.List[string]]::new()
foreach ($r in $disqRecords) { $all.Add($r) }
$all.Add($printerLine)

$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutFile, ($all -join "`r`n") + "`r`n", $enc)

Write-Host "LOADIS-ASCII refimpl: $ctrin record(s) written to DISQ; PRINTER line appended."
