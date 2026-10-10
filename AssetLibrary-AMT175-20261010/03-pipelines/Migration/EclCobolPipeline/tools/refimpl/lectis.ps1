<#
.SYNOPSIS
  Tier-1 PowerShell reference oracle for SSG-COBOL program LECTIS (LECTIS_MULT).

.DESCRIPTION
  Faithful stand-in for the converted LECTIS logic used as the Tier-1 golden
  executor in the SSG-COBOL -> C# proof harness. No AMT runtime required.

  Cleaned COBOL (candidates/trial-05-lectis/LECTIS.TXT) semantics reproduced:
    * Input:  FICHIN, DISC FICHIN-1, ORGANIZATION INDEXED, ACCESS MODE DYNAMIC,
              120-char records. RECORD KEY SYMK X(8), ALTERNATE KEY SYMK1 X(4).
              In Tier-1, the input is read as a flat-sequential file (the logic
              uses START > LOW-VALUES then READ NEXT = full sequential scan, so
              no AMT indexed-file stack is required at this tier).
    * Output: IMP, PRINTER, LINAGE 63 / AT TOP 6 / AT BOTTOM 3. Records
              ZPRINT PIC X(100) DISPLAY-1. Tier-1 captures to a text .prn file;
              page-control directives (BEFORE PAGE / BEFORE SAUT) produce plain
              blank writes (no form-feed bytes). DISPLAY...UPON PRINTER goes to
              sysout and is not emitted to the .prn file.
    * Logic (OUVERT -> LECTURE loop -> FIN):
        OUVERT: WRITE ZP1 BEFORE PAGE  (ZP1 = spaces -> blank line)
        Per record: WRITE TIT; PERFORM IMPRES THRU FIIMPRES:
          WRITE ZP1 (chars 1-100 of WREC), WRITE ZP2 (chars 101-120 + spaces);
          CTRLI reaches 200 -> RAZ: MOVE ALL '*' TO ZPRINT; WRITE ZPRINT (100 *)
        FIN: WRITE ZPRINT(spaces) BEFORE SAUT -> blank line;
             DISPLAY ... UPON PRINTER -> omitted (sysout).
    * FILCO PIC Z.ZZZ.ZZZ (DECIMAL-POINT IS COMMA, group separator = '.'):
        1 -> '        1', 3 -> '        3', 1000 -> '    1.000', etc.
    * All WRITEs strip trailing spaces from the 100-char ZPRINT/ZPR fields.

  Reference for indexed file semantics in AMT LION:
    AMT-LION Primary Developer Training (ALPD) §18.1.3 (File indexes) +
    §18.1.7 (File functions). ALPD notes indexed files are a COBOL-compatibility
    feature; sequential is the recommended method. The C# runtime API names
    (OpenFile / LocateRecordIndexedFile / ReadRandomAccessFileNextRecord /
    CloseFile) are generated automatically and are not covered in available docs.

.PARAMETER InFile
  Path to the assigned FICHIN-1 data file (120-char fixed records, CRLF-delimited,
  read sequentially).

.PARAMETER OutFile
  Path to write the IMP printer output (text .prn, CRLF-delimited, trailing spaces
  stripped per line).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$InFile,
    [Parameter(Mandatory)][string]$OutFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RECLEN  = 120
$ZPR_W   = 100   # ZPRINT / ZPR slice width
$LINAGE  = 63    # LINAGE value — Tier-1 does not emit page-break bytes

# ---- FILCO formatter: PIC Z.ZZZ.ZZZ (DECIMAL-POINT IS COMMA, group sep='.') ----
# 9 print positions: Z '.' ZZZ '.' ZZZ  — zero-suppress from the left globally.
function Format-Filco([long]$n) {
    $d = @(
        [int]($n / 1000000),
        [int](($n % 1000000) / 100000),
        [int](($n % 100000)  / 10000),
        [int](($n % 10000)   / 1000),
        [int](($n % 1000)    / 100),
        [int](($n % 100)     / 10),
        [int]($n % 10)
    )
    $seen = $false
    $out  = New-Object System.Text.StringBuilder
    # pos 1 (d[0] = millions)
    if ($d[0] -gt 0) { [void]$out.Append($d[0]); $seen = $true } else { [void]$out.Append(' ') }
    # pos 2 (group separator)
    [void]$out.Append( $(if ($seen) { '.' } else { ' ' }) )
    # pos 3-5 (d[1..3] = hundred-thousands, ten-thousands, thousands)
    foreach ($i in 1,2,3) {
        if (-not $seen -and $d[$i] -eq 0) { [void]$out.Append(' ') }
        else { [void]$out.Append($d[$i]); $seen = $true }
    }
    # pos 6 (group separator)
    [void]$out.Append( $(if ($seen) { '.' } else { ' ' }) )
    # pos 7-9 (d[4..6] = hundreds, tens, units)
    foreach ($i in 4,5,6) {
        if (-not $seen -and $d[$i] -eq 0) { [void]$out.Append(' ') }
        else { [void]$out.Append($d[$i]); $seen = $true }
    }
    return $out.ToString()
}

function Trim-Right([string]$s) { return $s.TrimEnd() }

$lines    = [IO.File]::ReadAllLines($InFile)
$outLines = New-Object System.Collections.Generic.List[string]

# OUVERT: WRITE ZP1 BEFORE PAGE (ZP1 = initial spaces -> blank line)
$outLines.Add('')

$ctr = [long]0
foreach ($raw in $lines) {
    if ($raw.Length -eq 0) { continue }                   # AT END guard
    $wrec = $raw.PadRight($RECLEN).Substring(0, $RECLEN)  # READ ... INTO WREC (120 chars)
    $ctr++

    # SUITE: MOVE CTR TO FILCO; WRITE ZPRINT FROM TIT BEFORE 1
    $filco = Format-Filco $ctr
    $tit   = '***  RECORD NUMERO ' + $filco + '  ***'     # 5 + 14 + 9 + 5 = 33 chars
    $outLines.Add((Trim-Right $tit))

    # MOVE WREC TO ZPR (ZPR = 2000 chars; first 120 = WREC, rest = spaces)
    $zpr   = $wrec.PadRight(2000)
    $zp1   = $zpr.Substring(  0, $ZPR_W)
    $zp2   = $zpr.Substring(100, $ZPR_W)

    # PERFORM IMPRES THRU FIIMPRES
    $ctrli = [long]0

    # WRITE ZP1 BEFORE 1
    $outLines.Add((Trim-Right $zp1))
    $ctrli += 100
    if ($ctrli -ge 120) {
        # RAZ
        $outLines.Add('*' * $ZPR_W); continue
    }
    # WRITE ZP2 BEFORE 1
    $outLines.Add((Trim-Right $zp2))
    $ctrli += 100
    if ($ctrli -ge 120) {
        # RAZ
        $outLines.Add('*' * $ZPR_W); continue
    }
    # (ZP3-ZP20 not reached for 120-char records with our fixtures — CTRLI would be 300+ after ZP3)
    $outLines.Add('*' * $ZPR_W)
}

# FIN: WRITE ZPRINT(spaces) BEFORE SAUT -> blank line
$outLines.Add('')

[IO.File]::WriteAllText($OutFile, (($outLines -join "`r`n") + "`r`n"))
