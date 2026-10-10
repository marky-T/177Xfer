<#  Creates archiformat Tier-1 proof fixtures. Run once to (re)generate data files. #>
$dir = $PSScriptRoot
$enc = New-Object System.Text.UTF8Encoding($false)

# ── fic-report.dat  12 lines × 132 chars ─────────────────────────────────────
$rlines = @(
    '   DD-PROCESS-TIME-STAMP'.PadRight(132),   # Line  1 – trigger 100-type0
    '      26 01 15'.PadRight(132),             # Line  2 – date  (pos 7-8=yy, 10-11=mm, 13-14=dd)
    'Columns'.PadRight(132),                    # Line  3 – trigger 102-type2
    ' Col  Name                   Type     Length   Null'.PadRight(132),  # Line  4 – discard
    (' ' * 39 + 'Allowed').PadRight(132),       # Line  5 – Allowed header (i_buf=39)
    (' ' * 41 + 'YES').PadRight(132),           # Line  6 – COL1 null=YES  (pos 42='Y',43='E')
    (' ' * 41 + 'NO ').PadRight(132),           # Line  7 – COL2 null=NO   (pos 42='N')
    ''.PadRight(132),                           # Line  8 – discard after type2 loop
    'Primary Key : PK_TABLE-ARCH'.PadRight(132),# Line  9 – trigger 103-type3; PK_ at pos 15
    '  Column     Direction'.PadRight(132),     # Line 10 – discard (2-times read)
    '    CLE-TABLE , Asc'.PadRight(132),        # Line 11 – PK entry: col=pos5:10, tri=pos17:3
    ''.PadRight(132)                            # Line 12 – blank terminator (lgn-rep(1:10)=sp)
)
[System.IO.File]::WriteAllText((Join-Path $dir 'fic-report.dat'),
    ($rlines -join "`r`n") + "`r`n", $enc)

# ── fic-descript.dat  4 lines × 132 chars ────────────────────────────────────
# Layout per data line: pos1-5=seq, pos6-12=type(7), pos13-22=len(10),
#   pos23-33=spaces(11), pos34-44=COLLECTION.(11), pos45-74=name(30), pos75-132=spaces
$col1n = 'COL-NAME-1'.PadRight(30); $col2n = 'COL-NAME-2'.PadRight(30)
$dlines = @(
    'DESCRIPTION DES CHAMPS DE TABLE-ARCH'.PadRight(132),
    ('     CHARVAR0000000010           COLLECTION.' + $col1n).PadRight(132),
    ('     INTEGER0000000004           COLLECTION.' + $col2n).PadRight(132),
    'END DESCRIPTION'.PadRight(132)
)
[System.IO.File]::WriteAllText((Join-Path $dir 'fic-descript.dat'),
    ($dlines -join "`r`n") + "`r`n", $enc)

# ── fic-unload.dat  2 records × 68 chars ─────────────────────────────────────
# Layout: key(10) + data(55) + filler(1) + nullflags(2) = 68
$ulines = @(
    '1234567890' + 'DATA1'.PadRight(55) + 'X  ',
    '0000000042' + 'DATA2'.PadRight(55) + 'X  '
)
[System.IO.File]::WriteAllText((Join-Path $dir 'fic-unload.dat'),
    ($ulines -join "`r`n") + "`r`n", $enc)

# ── assign.json ───────────────────────────────────────────────────────────────
$aj = @'
{
  "jobname": "ARCHIFORMAT",
  "fileAssignments": {
    "FICREPORT":   "fic-report.dat",
    "FICDESCRIPT": "fic-descript.dat",
    "FICUNLOAD":   "fic-unload.dat",
    "FICFORMAT":   "output.dat"
  }
}
'@
[System.IO.File]::WriteAllText((Join-Path $dir 'assign.json'), $aj, $enc)

# ── report sizes ──────────────────────────────────────────────────────────────
Get-ChildItem $dir -File | Where-Object { $_.Name -ne 'Create-Fixtures.ps1' } |
    Select-Object Name, Length | Format-Table -AutoSize
