<#
.SYNOPSIS
  Tier-1 PowerShell reference oracle for SSG-COBOL program ARCHITAB1.

.DESCRIPTION
  Faithful stand-in for the converted ARCHITAB1 logic, used as the Tier-1 golden
  executor in the SSG-COBOL -> C# proof harness. No AMT runtime required.

  Cleaned COBOL (candidates/trial-07-architab1/ARCHITAB1.TXT) semantics reproduced:
    * NO COBOL input file. ARCHITAB1 is a pure output generator: it OPENs ficout
      (DISC "ECL-FNAME"), writes three fixed 80-char records (type 0 / 1 / 9),
      then STOP RUN.
    * The only runtime-variable value is ACCEPT dt-ach FROM DATE YYYYMMDD. To keep
      the Tier-1 golden deterministic, the run date is supplied as a one-line
      parameter card (InFile, line 1 = yyyymmdd) instead of the system clock.
      => At Tier 2 (real C#) dt-ach0 (cols 38-45) and dt-ach9 (cols 38-45) hold the
         actual run date and must be masked when diffing against this golden.
    * Token-derived values mirror the trial-07 STUBBED candidate (-AnnotateStubs):
        nm-bas0/9  X(6)   <- MOVE "ECL-TNAME1"  -> "ECL-TN"  (truncated)
        nm-tab0/9  X(30)  <- MOVE "ECL-TNAME2"  -> "ECL-TNAME2" + spaces
        nm-cle     X(30)  <- MOVE "ECL-KEY1"    -> "ECL-KEY1"   + spaces
        type-cle   X(1)   <- MOVE "ECL-KEY2"    -> "E"          (truncated)
        longueur   99.99  <- MOVE 00.00         -> "00.00"
    * Program literals (not token-derived):
        cd-don0/1/9 = "0"/"1"/"9"; dt-tab X(8) = spaces;
        nombre / nombre2 PIC S9(11) SIGN LEADING SEPARATE VALUE 99999999999
          -> "+99999999999" (positive, explicit leading sign).
    * WRITE ligneout FROM ligne-typeN: the 53/37/69-char group is MOVEd to the
      80-char ligneout record, left-justified and space-padded to 80.

.PARAMETER InFile
  Path to the ECL parameter card (line 1 = pinned run date, yyyymmdd).

.PARAMETER OutFile
  Path to write the ficout output (three 80-char records, CRLF-delimited).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$InFile,
    [Parameter(Mandatory)][string]$OutFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RECLEN = 80

# COBOL alphanumeric MOVE to a fixed PIC X(w): left-justify, truncate or space-pad.
function Move-X([string]$s, [int]$w) {
    if ($s.Length -ge $w) { return $s.Substring(0, $w) }
    return $s.PadRight($w)
}

# --- ACCEPT dt-ach FROM DATE YYYYMMDD : pinned via the parameter card ----------
$cardLines = @([IO.File]::ReadAllLines($InFile))
$rundate = ''
foreach ($l in $cardLines) { if ($l.Trim().Length -gt 0) { $rundate = $l.Trim(); break } }
if ($rundate -notmatch '^[0-9]{8}$') {
    throw "ARCHITAB1: parameter card must supply an 8-digit yyyymmdd run date; got '$rundate'"
}
$dt = $rundate.Substring(0, 8)

# --- Stub literals (mirror the trial-07 candidate) -----------------------------
$tname1 = 'ECL-TNAME1'
$tname2 = 'ECL-TNAME2'
$key1   = 'ECL-KEY1'
$key2   = 'ECL-KEY2'
$longueur = '00.00'                 # PIC 99.99 display of MOVE 00.00
$nombre   = '+99999999999'          # PIC S9(11) SIGN LEADING SEPARATE, VALUE 99999999999

# --- 100-type0 : WRITE ligneout FROM ligne-type0 -------------------------------
$type0 = (Move-X $tname1 6) + (Move-X $tname2 30)
$grp0  = '0' + $type0 + $dt + (' ' * 8)                 # 1+6+30+8+8 = 53

# --- 101-type1 : WRITE ligneout FROM ligne-type1 -------------------------------
$grp1  = '1' + (Move-X $key1 30) + (Move-X $key2 1) + $longueur   # 1+30+1+5 = 37

# --- 102-type9 : WRITE ligneout FROM ligne-type9 -------------------------------
$type9 = (Move-X $tname1 6) + (Move-X $tname2 30)
$grp9  = '9' + $type9 + $dt + $nombre + $nombre        # 1+6+30+8+12+12 = 69

$records = @(
    (Move-X $grp0 $RECLEN)
    (Move-X $grp1 $RECLEN)
    (Move-X $grp9 $RECLEN)
)

[IO.File]::WriteAllText($OutFile, (($records -join "`r`n") + "`r`n"))
