<#
.SYNOPSIS
  Tier-1 reference oracle for ARCHIFORMAT.
  Archive formatter: reads RSA schema report + column descriptions + unload
  data, writes fixed-size archive records (types 0,1,2,3,4,9) to fic-format.

  Combined output written to $OutFile:
    fic-format records (69-char each, CRLF)
    printer lines (CRLF)

  Trial-13. Simplified: key=CLE-TABLE/N/10, rsz=55, ncols=2, [*a]=69.
  Params: [table,1,1,3]=ARCHIS, [table,1,1,2]=TABLE-ARCH, [table,1,2,1]=2.
  Date pinned to run date; Tier-2 must mask dt-ach + dt-maj + date-fr.

  fic-report format (132-char fixed records):
    - Scans for 'DD-PROCESS-TIME-STAMP' at pos 4-24 → next line has date
      (pos7-8=yy, pos10-11=mm, pos13-14=dd, 2-digit year; ss=20 if yy<=90)
    - Scans for 'Columns' at pos 1-7 → reads header lines, finds 'Allowed'
      position (i_buf), then loops ncols times reading null+desc per column
    - Scans for 'Primary Key :' at pos 1-13 → reads PK_ name then column
      lines until blank (pos 1-10 = spaces)

  fic-descript format (132-char fixed records):
    - Positions: 6:7=type, 13:10=length, 'TION.' marks column-name offset
      (name starts at TION. pos + 6, 30 chars)
#>
param(
    [string]$InFile,    # fic-report.dat (first fileAssignment in fixture dir)
    [string]$OutFile    # combined output: fic-format records + printer
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$dir       = Split-Path $InFile -Parent
$descript  = Join-Path $dir 'fic-descript.dat'
$unload    = Join-Path $dir 'fic-unload.dat'

# ── *SET computed values ──────────────────────────────────────────────────────
$KEY_SZ  = 10   # [key,1,1,3]
$RSZ     = 55   # [rsz,1,1,1]
$NCOLS   = 2    # [table,1,2,1]
$SZ_A    = 2 + $KEY_SZ + $RSZ + $NCOLS   # [*a] = 69  (lgn-for record size)
$SZ_B    = $KEY_SZ + $RSZ + 1 + $NCOLS   # [*b] = 68  (lgn-unl record size)
$SZ_C    = 2 + $KEY_SZ + $RSZ            # [*c] = 67
$SZ_D    = 1 + $KEY_SZ + $RSZ            # [*d] = 66
$SZ_E    = $KEY_SZ + $RSZ                # [*e] = 65

# ── WS VALUE initialisations ──────────────────────────────────────────────────
$NM_BASE  = 'ARCHIS'      # [table,1,1,3] PIC x(6)
$NM_TABLE = 'TABLE-ARCH'  # [table,1,1,2] PIC x(30)
$KEY_NAME = 'CLE-TABLE'   # [key,1,1,1]  PIC x(30)
$KEY_TYPE = 'N'            # [key,1,1,2]  PIC x(1)
$KEY_LEN  = $KEY_SZ        # [key,1,1,3]  numeric

# ── Read input files ──────────────────────────────────────────────────────────
$repLines = [System.IO.File]::ReadAllLines($InFile)
$desLines = [System.IO.File]::ReadAllLines($descript)
$unlLines = [System.IO.File]::ReadAllLines($unload)

$repIdx = 0; $desIdx = 0; $unlIdx = 0
$finUnload = $false

$lgn_rep = ' ' * 132
$lgn_des = ' ' * 132

function Read-Report {
    if ($script:repIdx -lt $script:repLines.Count) {
        $script:lgn_rep = $script:repLines[$script:repIdx].PadRight(132).Substring(0,132)
        $script:repIdx++
    }
    # AT END: lgn_rep retains last value (COBOL FD behaviour)
}
function Read-Descript {
    if ($script:desIdx -lt $script:desLines.Count) {
        $script:lgn_des = $script:desLines[$script:desIdx].PadRight(132).Substring(0,132)
        $script:desIdx++
    }
}
function Read-Unload {
    # Returns $true on success, $false at EOF. Populates $script:ws4_don.
    if ($script:unlIdx -lt $script:unlLines.Count) {
        $line = $script:unlLines[$script:unlIdx].PadRight($script:SZ_B).Substring(0,$script:SZ_B)
        $script:unlIdx++
        # 202-lec-unload NOT AT END processing:
        # ws-4-don(1:[*e]) <- lgn-unl(1:[*e])  copy first SZ_E=65 bytes
        $ws = $line.Substring(0,$script:SZ_E).PadRight($script:SZ_B)
        # ws-4-don([*d]:[ncols]) <- lgn-unl([*c]:[ncols])  copy null flags
        # lgn-unl([*c]:NCOLS) = idx SZ_C-1=66, len NCOLS=2
        $flags = $line.Substring($script:SZ_C - 1, $script:NCOLS)
        # ws-4-don([*d]:NCOLS) = idx SZ_D-1=65, len NCOLS=2
        $script:ws4_don = $ws.Substring(0,$script:SZ_D-1) + $flags + $ws.Substring($script:SZ_D-1+$script:NCOLS)
        $script:cpt_lu++
        return $true
    }
    $script:finUnload = $true
    return $false
}

$today     = Get-Date -Format 'yyyyMMdd'   # PIC 9(8) accept from date yyyymmdd
$fmtLines  = [System.Collections.Generic.List[string]]::new()
$printer   = [System.Collections.Generic.List[string]]::new()
$cpt_lu    = 0
$cpt_ach   = 0
$ws4_don   = ' ' * $SZ_B

function Write-Fmt([string]$ws_don) {
    # Simulate WRITE lgn-for FROM ws_don: truncate/pad to SZ_A
    $script:fmtLines.Add($ws_don.PadRight($script:SZ_A).Substring(0,$script:SZ_A))
}

# ── 100-type0 ─────────────────────────────────────────────────────────────────
# accept ws-0-dt-ach from date yyyymmdd
$ws0_dt_ach = $today
# perform 200-lec-report until lgn-rep(4:21) = 'DD-PROCESS-TIME-STAMP'
while ($lgn_rep.Substring(3,21) -ne 'DD-PROCESS-TIME-STAMP') { Read-Report }
# perform 200-lec-report (read date line)
Read-Report
# extract date components (COBOL 1-indexed pos → PS 0-indexed)
$ws0_dt_maj_aa = $lgn_rep.Substring(6,2)   # lgn-rep(7:2)
$ws0_dt_maj_ss = if ([int]$ws0_dt_maj_aa -gt 90) { '19' } else { '20' }
$ws0_dt_maj_mm = $lgn_rep.Substring(9,2)   # lgn-rep(10:2)
$ws0_dt_maj_jj = $lgn_rep.Substring(12,2)  # lgn-rep(13:2)
$ws0_dt_maj    = $ws0_dt_maj_ss + $ws0_dt_maj_aa + $ws0_dt_maj_mm + $ws0_dt_maj_jj
$ws_don_0 = '0' + $NM_BASE.PadRight(6) + $NM_TABLE.PadRight(30) + $ws0_dt_ach + $ws0_dt_maj
Write-Fmt $ws_don_0

# ── 101-type1 ─────────────────────────────────────────────────────────────────
# move [key,1,1,3] to ws-1-lg-cle (PIC 99.99: e.g. 10 -> "10.00")
$ws1_lg_cle = $KEY_LEN.ToString('00') + '.00'
$ws_don_1 = '1' + $KEY_NAME.PadRight(30) + $KEY_TYPE + $ws1_lg_cle
Write-Fmt $ws_don_1

# ── 102-type2 ─────────────────────────────────────────────────────────────────
# perform until lgn-rep(1:7) = 'Columns'
while ($lgn_rep.Substring(0,7) -ne 'Columns') { Read-Report }
# perform 200-lec-report 2 times
Read-Report ; Read-Report
# inspect lgn-rep for chars before 'Allowed' -> i_buf (0-indexed = COBOL count-before)
$i_buf = $lgn_rep.IndexOf('Allowed')
# perform 200-lec-report (pre-loads first column's null-check line)
Read-Report
# perform 201-lec-descript 2 times
Read-Descript ; Read-Descript
# inspect lgn-des for 'TION.' -> column-name start offset
$tion_idx  = $lgn_des.IndexOf('TION.')      # COBOL cpt-char (count before 'TION.')
$name_idx  = $tion_idx + 5                  # COBOL cpt-char+6, PS idx = COBOL-1

for ($col = 0; $col -lt $NCOLS; $col++) {
    # ws-2-nm-chp = lgn-des(cpt-char:30)
    $ws2_nm_chp  = $lgn_des.Substring($name_idx, 30)
    # ws-2-typ-chp = lgn-des(6:7)
    $ws2_typ_chp = $lgn_des.Substring(5, 7)
    # ws-2-lg-chp = lgn-des(13:10)
    $ws2_lg_chp  = $lgn_des.Substring(12, 10)
    # null check: i = i_buf + 3 (COBOL), i_tot = i + 2
    # check lgn-rep(i:1)='Y' and lgn-rep(i+1:1)='E'
    $fl_null = 0
    $i     = $i_buf + 3          # COBOL 1-indexed position
    $i_tot = $i + 2
    while ($i -lt $i_tot) {
        if ($lgn_rep[$i - 1] -eq 'Y') {
            $i++
            if ($lgn_rep[$i - 1] -eq 'E') { $fl_null = 1 }
        }
        $i++
    }
    $ws2_null = if ($fl_null -eq 1) { 'NULL    ' } else { '        ' }
    $ws_don_2 = '2' + $ws2_nm_chp + $ws2_typ_chp + $ws2_lg_chp + $ws2_null
    Write-Fmt $ws_don_2
    Read-Report
    Read-Descript
}

# ── 103-type3 ─────────────────────────────────────────────────────────────────
# perform until lgn-rep(1:13) = 'Primary Key :'
while ($lgn_rep.Substring(0,13) -ne 'Primary Key :') { Read-Report }
# inspect for 'PK_', add 1 -> COBOL start of idx name (1-indexed)
$pk_idx     = $lgn_rep.IndexOf('PK_')         # COBOL chars-before; PS idx = pk_idx
$ws3_nm_idx = $lgn_rep.Substring($pk_idx, 30) # lgn-rep(cpt+1:30), PS Substring(pk_idx,30)
# perform 200-lec-report 2 times
Read-Report ; Read-Report
# loop until lgn-rep(1:10) = spaces
while ($lgn_rep.Substring(0,10) -ne '          ') {
    $comma_idx     = $lgn_rep.IndexOf(',')       # COBOL chars-before-comma
    $cpt_sub4      = $comma_idx - 4              # subtract 4 -> name length
    $ws3_nm_chp    = $lgn_rep.Substring(4, $cpt_sub4)  # lgn-rep(5:cpt-char)
    # add 7: COBOL cpt-char = comma_idx+3; PS lgn-rep(cpt-char:3) -> Substring(comma_idx+2,3)
    $ws3_tri       = $lgn_rep.Substring($comma_idx + 2, 3)
    $ws_don_3 = '3' + $ws3_nm_idx.PadRight(30) + $ws3_nm_chp.PadRight(30) + $ws3_tri.PadRight(8)
    Write-Fmt $ws_don_3
    Read-Report
}

# ── 104-type4 ─────────────────────────────────────────────────────────────────
while ($true) {
    $ok = Read-Unload
    if (-not $ok) { break }
    # ws-don-4 = '4A' + ws-4-don (SZ_B=68 chars) = SZ_A+1=70 chars total
    # WRITE lgn-for FROM ws-don-4: truncates to SZ_A=69
    Write-Fmt ('4A' + $ws4_don)
    $cpt_ach++
}

# ── 105-type9 ─────────────────────────────────────────────────────────────────
$ws9_dt_ach  = $today
$ws9_cpt_ach = '+' + $cpt_ach.ToString('D11')   # PIC s9(11) sign leading separate
$ws_don_9 = '9' + $NM_BASE.PadRight(6) + $NM_TABLE.PadRight(30) +
            $ws9_dt_ach + $ws9_cpt_ach + '+00000000000'
Write-Fmt $ws_don_9

# ── 106-tot ───────────────────────────────────────────────────────────────────
# move ws-0-dt-ach to dt-i -> extract yyyy, mm, dd for dt-fr
$dt_aa   = $today.Substring(0,4)
$dt_mm   = $today.Substring(4,2)
$dt_jj   = $today.Substring(6,2)
$dt_fr   = "$dt_jj/$dt_mm/$dt_aa"
# PIC z(10)9: PadLeft(11) with spaces (leading-zero suppressed, last digit always shown)
$cpt_luf  = $cpt_lu.ToString().PadLeft(11)
$cpt_achf = $cpt_ach.ToString().PadLeft(11)
$printer.Add("ARCHIFORMAT          RAPPORT          $dt_fr")
$printer.Add("Enregistrements lus:$cpt_luf")
$printer.Add("Enregistrements 4 ecrits:$cpt_achf")

# ── Combine and write output ───────────────────────────────────────────────────
$all = [System.Collections.Generic.List[string]]::new()
foreach ($r in $fmtLines) { $all.Add($r) }
foreach ($r in $printer)  { $all.Add($r) }

$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutFile, ($all -join "`r`n") + "`r`n", $enc)
