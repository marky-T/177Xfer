<#
.SYNOPSIS
  Tier-1 PowerShell reference oracle for SSG-COBOL program ECLAT (UGXB02).

.DESCRIPTION
  Faithful stand-in for the converted ECLAT merge logic used as the Tier-1 golden
  executor in the SSG-COBOL -> C# proof harness. No AMT runtime required.

  Cleaned COBOL semantics reproduced (candidates/trial-09-eclat/ECLAT.TXT):
    * Parameterisation: key=1, filekey record=10 bytes, table record=20 bytes.
      PROGRAM-ID = UGXB02.
    * INPUT FILEKEY  (ECL-FILEKEY): fixed 10-byte records, CRLF-delimited.
    * INPUT TABLE    (ECL-TABLE):   fixed 20-byte records, CRLF-delimited.
      TABLE path is derived from the same directory as -InFile (filekey.dat).
    * OUTPUT FARCHIVE (ECL-FARCHIVE): 68-byte records — NOM-TAB(30) DAT-ARC(8) CLES-TAB(10) ENR(20).
    * OUTPUT FENCOURS (ECL-FENCOURS): 20-byte records — ENR-ENC = full TABLE record.
    * Both FARCHIVE and FENCOURS are written sequentially to -OutFile (encours.dat).

  Merge algorithm (000-MAIN / 020-TRT-PRINC):
    * Read from both files. Loop UNTIL (EOF-CHER=1 AND EOF-FILE=1).
      - SEQ-KEY = SEQ-KEY-T  → FARCHIVE: NOM-TAB/DAT-ARC/CLES-TAB/ENR; advance both.
      - SEQ-KEY > SEQ-KEY-T  → FENCOURS: ENR-ENC = full TABLE record; advance TABLE.
      - SEQ-KEY < SEQ-KEY-T  → discard FILEKEY record; advance FILEKEY only.
    * HIGH-VALUE sentinel on EOF: when FILEKEY exhausted remaining TABLE drains to FENCOURS.

  Date pinning (ACCEPT DAT-DAT FROM DATE):
    * Pinned to 20260629: DAT-AA=26, DAT-MM=06, DAT-JJ=29, DAT-SS=20 (26<28).
    * DAT-ARC = DAT-SS(2) + DAT-AA(2) + DAT-MM(2) + DAT-JJ(2) = '20260629'.

  NOM-TAB: '[table,1,1,3]' = 'ARCHIVE-TABLE' padded to 30 chars with trailing spaces.

  Output written to -OutFile: FARCHIVE records first (in match order), then FENCOURS
  records (in TABLE order), all CRLF-terminated. This matches the sequence produced by
  the merge loop: archive records are emitted during the loop when keys match; encours
  records are emitted when TABLE key < FILEKEY key (after FILEKEY EOF, all remaining
  TABLE records drain to FENCOURS in sequence).

.PARAMETER InFile
  Path to the FILEKEY input file (assign.json FILEKEY → filekey.dat).
  TABLE is derived automatically from the same directory as InFile (table.dat).

.PARAMETER OutFile
  Combined output path (assign.json FENCOURS → encours.dat).
  FARCHIVE records are prepended, FENCOURS records follow.

.EXAMPLE
  .\eclat.ps1 -InFile "..\fixtures\eclat\filekey.dat" -OutFile "..\fixtures\eclat\work\encours.dat"
#>
param(
    [Parameter(Mandatory)][string]$InFile,
    [Parameter(Mandatory)][string]$OutFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── File paths ────────────────────────────────────────────────────────────────
$workDir  = Split-Path $InFile -Parent
$tableFile = Join-Path $workDir 'table.dat'

if (-not (Test-Path $InFile))    { throw "FILEKEY not found: $InFile" }
if (-not (Test-Path $tableFile)) { throw "TABLE not found: $tableFile" }

$outDir = Split-Path $OutFile -Parent
if ($outDir -and -not (Test-Path $outDir)) { New-Item -ItemType Directory -Force $outDir | Out-Null }

# ── Read files (strip CRLF; each line is one record) ────────────────────────
$cherRecs = [System.IO.File]::ReadAllLines($InFile,  [System.Text.Encoding]::ASCII)
$fileRecs = [System.IO.File]::ReadAllLines($tableFile, [System.Text.Encoding]::ASCII)

# ── Constants matching ECLAT COBOL parameterisation ──────────────────────────
$NOM_TAB  = 'ARCHIVE-TABLE                 '   # 13 + 17 spaces = 30 chars  *> SSG-STUB [table,1,1,3]
$DAT_ARC  = '20260629'                          # pinned date (YYYYMMDD = SS+AA+MM+JJ)
$HIGH     = [char]0xFF                          # HIGH-VALUE sentinel

# ── LEC-CHER / LEC-FILE state ─────────────────────────────────────────────────
$cherIdx  = 0;  $eofCher = $false
$fileIdx  = 0;  $eofFile = $false
$seqKey   = '';  $seqKeyT  = ''

function Read-Cher {
    if ($cherIdx -lt $cherRecs.Count) {
        $rec  = $cherRecs[$cherIdx].PadRight(10).Substring(0,10)
        $script:cherIdx++
        $script:seqKey  = $rec         # S-KEY1 = KEY1
    } else {
        $script:eofCher = $true
        $script:seqKey  = [string]$HIGH * 10   # MOVE HIGH-VALUE TO SEQ-KEY
    }
}

function Read-File {
    if ($fileIdx -lt $fileRecs.Count) {
        $script:fileIdx++
        # seqKeyT is updated in the main loop from current fileRec
    } else {
        $script:eofFile = $true
        $script:seqKeyT = [string]$HIGH * 10   # MOVE HIGH-VALUE TO SEQ-KEY-T
    }
}

# ── Output collection (separate streams, then concatenate: FARCHIVE first) ────
$arcOutput = [System.Collections.Generic.List[byte[]]]::new()
$encOutput = [System.Collections.Generic.List[byte[]]]::new()
$enc    = [System.Text.Encoding]::ASCII
$CRLF   = [byte[]](0x0D, 0x0A)

function Write-Archive([string]$keyVal, [string]$tabRec) {
    # NOM-TAB(30) + DAT-ARC(8) + CLES-TAB(10) + ENR(20) = 68 bytes
    $clesTab = $keyVal.PadRight(10).Substring(0,10)
    $enr     = $tabRec.PadRight(20).Substring(0,20)
    $line    = $NOM_TAB + $DAT_ARC + $clesTab + $enr   # 30+8+10+20=68
    $arcOutput.Add($enc.GetBytes($line) + $CRLF)
}

function Write-Encours([string]$tabRec) {
    # ENR-ENC = PIC X(20) = full TABLE record
    $enrEnc = $tabRec.PadRight(20).Substring(0,20)
    $encOutput.Add($enc.GetBytes($enrEnc) + $CRLF)
}

# ── 010-OUVERTURE: initial reads ───────────────────────────────────────────────
Read-Cher
# Prime FILE: set seqKeyT from first record (if any)
if ($fileIdx -lt $fileRecs.Count) {
    $seqKeyT = $fileRecs[$fileIdx].PadRight(10).Substring(0,10)
    $fileIdx++
} else {
    $eofFile = $true
    $seqKeyT = [string]$HIGH * 10
}

# ── 020-TRT-PRINC: merge loop ──────────────────────────────────────────────────
while (-not ($eofCher -and $eofFile)) {
    if ($seqKey -eq $seqKeyT) {
        # Keys match: write to FARCHIVE; advance both
        $tabRec = $fileRecs[$fileIdx - 1].PadRight(20).Substring(0,20)
        Write-Archive $seqKey $tabRec
        Read-Cher
        # Advance FILE
        if ($fileIdx -lt $fileRecs.Count) {
            $seqKeyT = $fileRecs[$fileIdx].PadRight(10).Substring(0,10)
            $fileIdx++
        } else {
            $eofFile = $true
            $seqKeyT = [string]$HIGH * 10
        }
    } elseif ([string]::Compare($seqKey, $seqKeyT, [System.StringComparison]::Ordinal) -gt 0) {
        # TABLE key < FILEKEY key: TABLE record not in FILEKEY → FENCOURS
        $tabRec = $fileRecs[$fileIdx - 1].PadRight(20).Substring(0,20)
        Write-Encours $tabRec
        # Advance FILE
        if ($fileIdx -lt $fileRecs.Count) {
            $seqKeyT = $fileRecs[$fileIdx].PadRight(10).Substring(0,10)
            $fileIdx++
        } else {
            $eofFile = $true
            $seqKeyT = [string]$HIGH * 10
        }
    } else {
        # FILEKEY key < TABLE key: FILEKEY record has no TABLE match → discard
        Read-Cher
    }
}

# ── Flatten FARCHIVE then FENCOURS and write output ──────────────────────────
$allBytes = [System.Collections.Generic.List[byte]]::new()
foreach ($chunk in $arcOutput) { $allBytes.AddRange($chunk) }
foreach ($chunk in $encOutput) { $allBytes.AddRange($chunk) }
[System.IO.File]::WriteAllBytes($OutFile, $allBytes.ToArray())

Write-Host "ECLAT refimpl: $($fileRecs.Count) TABLE recs, $($cherRecs.Count) FILEKEY recs"
Write-Host "Output: $($allBytes.Count) bytes -> $OutFile"
