<#
.SYNOPSIS
  Tier-1 PowerShell reference oracle for SSG-COBOL program UNLOAD-ASCII
  (SSG element: UNLOADIS_MULT).

.DESCRIPTION
  Faithful stand-in for the UNLOAD-ASCII COBOL logic used as the Tier-1 golden
  executor in the SSG-COBOL -> C# proof harness. No AMT runtime required.

  Cleaned COBOL semantics reproduced (candidates/trial-15-unload-ascii/UNLOAD-ASCII.TXT):
    * INPUT  DISQ    (ECL-DISQ): indexed file — simulated sequentially here.
      Records are 20 bytes each: CLEF PIC X(8) + CLEG PIC X(12).
      Sequential read (ACCESS MODE IS SEQUENTIAL) delivers all records in key order.
    * OUTPUT BDE     (ECL-BDE1): fixed 80-byte records.
      Each 20-byte DISQ record is moved into the 80-byte ZBDE (COBOL MOVE semantics:
      left-align, pad right with spaces to 80).
    * CONSOLE DISPLAY 'FIN DE FICHIER' UPON CONSOLE: written after end-of-file.
    * CONSOLE DISPLAY MES1 UPON CONSOLE: 'NB.ARTICLES ECRITS=' (19) + CTR-1 PIC 9(7).

  Combined output written to $OutFile (= BDE assignment):
    BDE records (80-char each, CRLF)
    'FIN DE FICHIER'          (CRLF)
    'NB.ARTICLES ECRITS=NNNNNNN' (CRLF)

  Trial-15. Simplified: ASCII=1, OUTPUT,1,1=3 (DISC), KEYIS=2, no fillers.
  DISQ record size=20 (CLEF=8 + CLEG=12), BDE record size=80.

.PARAMETER InFile
  Path to the DISQ fixture file (assign.json DISQ -> disq.dat).

.PARAMETER OutFile
  Combined output path (assign.json BDE -> output.dat).
  BDE records are written first, then CONSOLE messages.
#>
param(
    [Parameter(Mandatory)][string]$InFile,
    [Parameter(Mandatory)][string]$OutFile
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path $InFile)) { throw "InFile not found: $InFile" }

$RSZ_IN  = 20   # [INPUT,1,1,2] = DISQ record size (CLEF 8 + CLEG 12)
$RSZ_OUT = 80   # [OUTPUT,1,1,2] = BDE record size

# ── Read DISQ records (indexed file simulated sequentially) ───────────────────
$lines = [System.IO.File]::ReadAllLines($InFile)

$bdeRecords = [System.Collections.Generic.List[string]]::new()
$ctr        = 0

# DEB: OPEN OUTPUT BDE; OPEN INPUT DISQ; MOVE SPACES TO ZBUF; MOVE ALL ' ' TO CLEF
# DEBF: READ DISQ INTO ZBUF AT END GO TO FBDE
foreach ($line in $lines) {
    # READ DISQ INTO ZBUF: take RSZ_IN bytes (pad/trim to exact size)
    $zbuf = $line.PadRight($RSZ_IN).Substring(0, $RSZ_IN)

    # ADD 1 TO CTR
    $ctr++

    # WRITE ZBDE FROM ZBUF: COBOL MOVE of 20-char ZBUF into 80-char ZBDE -> pad to 80
    $zbde = $zbuf.PadRight($RSZ_OUT)
    $bdeRecords.Add($zbde)

    # MOVE SPACES TO ZBUF; MOVE CTR TO CTR-1; GO TO DEBF
}

# AT END -> GO TO FBDE
# FBDE: DISPLAY 'FIN DE FICHIER' UPON CONSOLE
$finFichier = 'FIN DE FICHIER'

# MOVE CTR TO CTR-1; DISPLAY MES1 UPON CONSOLE
# MES1: 'NB.ARTICLES ECRITS=' (19) + CTR-1 PIC 9(7) (7-digit zero-padded)
$ctrStr = $ctr.ToString('D7')
$mes1   = 'NB.ARTICLES ECRITS=' + $ctrStr

# ── Write combined output: BDE records, then CONSOLE lines ───────────────────
$all = [System.Collections.Generic.List[string]]::new()
foreach ($r in $bdeRecords) { $all.Add($r) }
$all.Add($finFichier)
$all.Add($mes1)

$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutFile, ($all -join "`r`n") + "`r`n", $enc)

Write-Host "UNLOAD-ASCII refimpl: $ctr record(s) unloaded from DISQ to BDE; CONSOLE messages appended."
