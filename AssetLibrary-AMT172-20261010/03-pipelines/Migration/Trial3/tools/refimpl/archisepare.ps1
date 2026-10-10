<#
.SYNOPSIS
  Tier-1 reference oracle for ARCHISEPARE.
  Sorted-merge separator: routes ficunload records matching a chercheuse key to
  ficarchi (as type4 archive records), remainder to ficnarchi. Appends a type9
  trailer to ficarchi.  Emits the DISPLAY rapport to printer.

  Combined output written to $OutFile:
    ficarchi records (72-char each, CRLF)
    ficnarchi records (40-char each, CRLF)
    printer lines (CRLF)

  Trial-12. Simplified: key at position 0 (key,1,2,1=0), key-size=10, rsz=40.
  Date is pinned to the run date (same as ARCHITAB1 pattern; Tier-2 must mask).
#>
param(
    [string]$InFile,   # chercheuse.dat  (search keys, 10-char CRLF records)
    [string]$OutFile   # combined output (ficarchi + ficnarchi + printer)
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$dir       = Split-Path $InFile -Parent
$unloadFile = Join-Path $dir 'ficunload.dat'

$RSZ = 40   # ficunload / ficnarchi record size   ([rsz,1,1,1]=40)
$ARC = 72   # ficarchi record size                ([*c] = 32+40 = 72)
$KEYSZ = 10 # key size in both files              ([key,1,2,2]=10)

$rcherche = [System.IO.File]::ReadAllLines($InFile)
$runload  = [System.IO.File]::ReadAllLines($unloadFile)

$ficarchi  = [System.Collections.Generic.List[string]]::new()
$ficnarchi = [System.Collections.Generic.List[string]]::new()
$printer   = [System.Collections.Generic.List[string]]::new()

$cptlu = 0; $cptarchi = 0; $cptnarchi = 0

# ── pointer state ────────────────────────────────────────────────────────────
$rchIdx = 0; $unlIdx = 0
$lecrchf = 0; $lecunloadf = 0
$cleChercheuse = ''; $cleUnload = ''; $ligneUnload = ''

function Read-Chercheuse {
    if ($script:rchIdx -lt $script:rcherche.Count) {
        $script:cleChercheuse = $script:rcherche[$script:rchIdx].PadRight($script:KEYSZ).Substring(0,$script:KEYSZ)
        $script:rchIdx++
    } else { $script:lecrchf = 1 }
}
function Read-Unload {
    if ($script:unlIdx -lt $script:runload.Count) {
        $script:ligneUnload = $script:runload[$script:unlIdx].PadRight($script:RSZ).Substring(0,$script:RSZ)
        $script:unlIdx++
        $script:cptlu++
        $script:cleUnload = $script:ligneUnload.Substring(0,$script:KEYSZ)
    } else { $script:lecunloadf = 1 }
}

# ── 100 + 101: first reads ───────────────────────────────────────────────────
Read-Chercheuse
Read-Unload

# ── 102-separe ───────────────────────────────────────────────────────────────
while ($lecunloadf -eq 0) {
    if ($lecrchf -ne 1) {
        if ($cleChercheuse -eq $cleUnload) {
            # archive record (type4: cd-don='4', cd-ach='A', tl-cle, tl-don)
            $type4 = ('4' + 'A' + $cleUnload + $ligneUnload).PadRight($ARC)
            $ficarchi.Add($type4)
            $cptarchi++
            Read-Unload
            if ($lecunloadf -eq 0 -and $cleUnload -ne $cleChercheuse) {
                Read-Chercheuse
            }
        } elseif ($cleChercheuse -gt $cleUnload) {
            # not to archive
            $ficnarchi.Add($ligneUnload.PadRight($RSZ))
            $cptnarchi++
            Read-Unload
        } else {
            # advance chercheuse
            Read-Chercheuse
        }
    } else {
        # chercheuse exhausted — remainder goes to narchi
        $ficnarchi.Add($ligneUnload.PadRight($RSZ))
        $cptnarchi++
        Read-Unload
    }
}

# ── type9 trailer (written at end of 102-separe) ─────────────────────────────
$today  = Get-Date -Format 'yyyyMMdd'
$nmBas9 = 'ARCHIS'.PadRight(6)
$nmTab9 = 'CHERCHEUSE-TABLE-ARCH'.PadRight(30)
$cptSgn = '+' + $cptarchi.ToString('D11')   # PIC S9(11) SIGN LEADING SEPARATE
$type9  = ('9' + $nmBas9 + $nmTab9 + $today + $cptSgn + $cptSgn).PadRight($ARC)
$ficarchi.Add($type9)

# ── 103-date ─────────────────────────────────────────────────────────────────
$now    = [datetime]::Now
$jourFr = $now.Day.ToString('D2')
$moisFr = $now.Month.ToString('D2')
$anneFr = $now.Year.ToString()
$dateFr = "$jourFr/$moisFr/$anneFr"

# ── 104-rapport (PIC z(6)9 = PadLeft(7)) ────────────────────────────────────
$cptluf     = $cptlu.ToString().PadLeft(7)
$cptarchif  = $cptarchi.ToString().PadLeft(7)
$cptnarchif = $cptnarchi.ToString().PadLeft(7)

$printer.Add('Archisepare              Rapport             ' + $dateFr)
$printer.Add(' ')
$printer.Add('Enregistrement lu : ' + $cptluf)
$printer.Add('Enregistrement ecrit dans ECL-FICARCHI : ' + $cptarchif)
$printer.Add('Enregistrement ecrit dans ECL-FICNARCHI : ' + $cptnarchif)

# ── Write combined output (ficarchi + ficnarchi + printer, CRLF) ─────────────
$all = [System.Collections.Generic.List[string]]::new()
foreach ($r in $ficarchi)  { $all.Add($r) }
foreach ($r in $ficnarchi) { $all.Add($r) }
foreach ($r in $printer)   { $all.Add($r) }

$enc = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutFile, ($all -join "`r`n") + "`r`n", $enc)
