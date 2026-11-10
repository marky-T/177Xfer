# SSG-4 (MT-056): parameter file + hand-off for the generic LECTIS program, written from the call's SGS cards (spec.md).
# Deployed as LectisParm.inc next to the converted skeleton; runs inside R&D's Invoke-Ssg (AmtPsEclLib, StrictMode 2).
# Needs AMT's GetSgsValue in scope and GnHandoff.inc (Invoke-GnHandoff).
# SGSPARM (250), one line per item, fixed columns:
#   IN<len 5>   KY<offset 5><key length 5>   MD<keys 1><nolist 1><y2k 1>
#   CD<operand 1 (C = CTR, K = SYMK)><relation 2 (EQ NE GT LT GE LE)><literal length 3><literal 100; for C the first 9 digits>
#   YD<dates 2><card length Z5 3><date positions 3 each>      (KEYS and Y2K only)
# Every check below carries the code of spec.md ("Card checks", E1..E4, limits L1..L4); the code is in the Abort message.

function Stop-Lectis([String]$Code, [String]$Msg) { Abort "SSG-4 hand-off (LECTIS) [$Code]: $Msg" }

# AMT's label store is case-sensitive (T3-054); GetSgsValue returns strings, $null for a missing label (T3-048).
function Get-LectisSgs([String]$Name) { [String](GetSgsValue $Name.ToUpperInvariant()) }
function Get-LectisCount([String]$Label) { $v = (Get-LectisSgs $Label).Trim(); if ($v -match '^\d+$') { [Int32]$v } else { 0 } }
function ConvertTo-LectisNumber([String]$v) { $t = $v.Trim(); if ($t -match '^\d{1,9}$') { [Int64]$t } else { $null } }

# One simple COND: <CTR|SYMK> [IS] [NOT] (= | EQUAL [TO] | > | GREATER [THAN] | < | LESS [THAN] | >= | <=) <literal>; $null if outside the subset (L3).
function Read-LectisCondition([String[]]$Tokens) {
  $t = @($Tokens | ForEach-Object { $_.ToUpperInvariant() }); $i = 1
  if ($t.Count -lt 3) { return $null }
  if ($t[0] -eq 'CTR') { $op = 'C' } elseif ($t[0] -eq 'SYMK') { $op = 'K' } else { return $null }
  if ($t[$i] -eq 'IS') { $i++ }
  $not = $false
  if ($i -lt $t.Count -and $t[$i] -eq 'NOT') { $not = $true; $i++ }
  if ($i -ge $t.Count) { return $null }
  $rel = ''
  switch ($t[$i]) {
    '=' { $rel = 'EQ'; $i++ }
    'EQUAL' { $rel = 'EQ'; $i++; if ($i -lt $t.Count -and $t[$i] -eq 'TO') { $i++ } }
    '>' { $rel = 'GT'; $i++ }
    'GREATER' { $rel = 'GT'; $i++; if ($i -lt $t.Count -and $t[$i] -eq 'THAN') { $i++ } }
    '<' { $rel = 'LT'; $i++ }
    'LESS' { $rel = 'LT'; $i++; if ($i -lt $t.Count -and $t[$i] -eq 'THAN') { $i++ } }
    '>=' { $rel = 'GE'; $i++ }
    '<=' { $rel = 'LE'; $i++ }
    default { return $null }
  }
  if ($not) {
    if ($rel -eq 'EQ') { $rel = 'NE' } elseif ($rel -eq 'GT') { $rel = 'LE' } elseif ($rel -eq 'LT') { $rel = 'GE' } else { return $null }
  }
  if ($t.Count - $i -ne 1) { return $null }
  $lit = $Tokens[$i]
  if ($op -eq 'C') {
    if ($lit -notmatch '^\d{1,9}$') { return $null }
    return [pscustomobject]@{ Op = 'C'; Rel = $rel; Text = ('{0:D9}' -f [Int64]$lit) }
  }
  # a quoted word: AMT's card parser keeps the quotes of a plain 'text' and cannot keep a blank inside it (T3-028)
  if ($lit.Length -lt 3 -or $lit.Length -gt 102) { return $null }
  $q = $lit[0]
  if (($q -ne "'" -and $q -ne '"') -or $lit[$lit.Length - 1] -ne $q) { return $null }
  [pscustomobject]@{ Op = 'K'; Rel = $rel; Text = $lit.Substring(1, $lit.Length - 2) }
}

function Get-LectisParmLines {
  # INPUT name,len,blk
  if ((Get-LectisCount 'INPUT') -lt 1) { Stop-Lectis 'E1' 'no INPUT card' }
  $name = (Get-LectisSgs 'INPUT,1,1,1').Trim()
  $len = ConvertTo-LectisNumber (Get-LectisSgs 'INPUT,1,1,2')
  if ($name -eq '' -or $null -eq $len -or $len -lt 1) { Stop-Lectis 'E1' "INPUT card needs a file name and a record length (INPUT name,len,blk)" }
  # LKEY off,klen,rest (off may be empty = 0)
  if ((Get-LectisCount 'LKEY') -lt 1) { Stop-Lectis 'E2' 'no LKEY card' }
  $offText = (Get-LectisSgs 'LKEY,1,1,1').Trim()
  $off = if ($offText -eq '') { 0 } else { ConvertTo-LectisNumber $offText }
  $klen = ConvertTo-LectisNumber (Get-LectisSgs 'LKEY,1,1,2')
  $rest = ConvertTo-LectisNumber (Get-LectisSgs 'LKEY,1,1,3')
  if ($null -eq $off -or $null -eq $klen -or $null -eq $rest -or $klen -lt 1 -or $rest -lt 1) { Stop-Lectis 'E2' 'LKEY card needs offset,key length,rest (LKEY off,klen,rest) with key length and rest of 1 or more' }
  if ($len -gt 4001) { Stop-Lectis 'L1' "record length $len > 4001 (generic program limit)" }
  if ($off + $klen -gt $len) { Stop-Lectis 'L4' "key (offset $off + length $klen) is beyond the record length $len" }
  $keys = (Get-LectisCount 'KEYS') -gt 0
  $nolist = (Get-LectisCount 'NOLIST') -gt 0
  $y2k = (Get-LectisCount 'Y2K') -gt 0
  $dates = @(); $z5 = 0
  if ($y2k) {
    $nf = [Int32](Get-LectisCount 'Y2K,1')
    if ($nf -lt 2) { Stop-Lectis 'E4' 'Y2K card needs at least 2 fields (the date positions start at field 2)' }
    for ($a = 2; $a -le $nf; $a++) {
      $v = ConvertTo-LectisNumber (Get-LectisSgs "Y2K,1,$a,1")
      if ($null -eq $v -or $v -lt 1) { Stop-Lectis 'E4' "Y2K field $a is not a position" }
      $dates += [Int32]$v
    }
    $z5 = $klen + 2 * $dates.Count
  }
  $cond = $null
  if (-not $keys) {
    if (-not $nolist) {
      $nt = Get-LectisCount 'COND,1'
      $tok = @()
      for ($i = 1; $i -le $nt; $i++) {
        $ns = [Int32](Get-LectisCount "COND,1,$i")
        $tok += ((1..[Math]::Max($ns, 1) | ForEach-Object { (Get-LectisSgs "COND,1,$i,$_") }) -join ',')
      }
      if ((Get-LectisCount 'COND') -lt 1 -or ($tok -join '') -eq '') { Stop-Lectis 'E3' 'no COND card (the skeleton would write IF NEXT SENTENCE)' }
      $cond = Read-LectisCondition $tok
      if ($null -eq $cond) { Stop-Lectis 'L3' "COND '$($tok -join ' ')' is outside the supported form: CTR|SYMK [IS] [NOT] =|>|<|>=|<=|EQUAL|GREATER|LESS [TO|THAN] number|'word'" }
    }
  } elseif ($y2k) {
    if ($dates.Count -gt 40 -or $z5 -gt $len -or $len -gt 90 -or $klen -gt $len - 2) { Stop-Lectis 'L2' "Y2K needs the card length $z5 <= record length $len <= 90, key length <= record length - 2, at most 40 dates" }
    for ($a = 0; $a -lt $dates.Count; $a++) {
      if ($dates[$a] + 3 -gt $z5) { Stop-Lectis 'L2' "Y2K position $($dates[$a]): the 4-digit year does not fit the card length $z5" }
      $cnt = if ($a -eq $dates.Count - 1) { $klen - $dates[$a] + 2 } else { $dates[$a + 1] - $dates[$a] - 4 }
      if ($cnt -lt 0) { Stop-Lectis 'L2' "Y2K position $($dates[$a]): the next date is closer than 4 characters or the key is too short" }
    }
    if ($z5 -gt 80) { Stop-Lectis 'L4' "key card length $z5 > 80 columns" }
  } elseif ($klen -gt 80) { Stop-Lectis 'L4' "key length $klen > 80 columns of a key card" }

  $lines = New-Object System.Collections.Generic.List[String]
  $lines.Add('IN' + ('{0:D5}' -f $len))
  $lines.Add('KY' + ('{0:D5}{1:D5}' -f $off, $klen))
  $lines.Add('MD' + [Int32]$keys + [Int32]$nolist + [Int32]$y2k)
  if ($null -ne $cond) {
    $litLen = if ($cond.Op -eq 'C') { 9 } else { $cond.Text.Length }
    $lines.Add('CD' + $cond.Op + $cond.Rel + ('{0:D3}' -f $litLen) + $cond.Text.PadRight(100))
  }
  if ($keys -and $y2k) { $lines.Add('YD' + ('{0:D2}{1:D3}' -f $dates.Count, $z5) + (($dates | ForEach-Object { '{0:D3}' -f $_ }) -join '')) }
  return , $lines
}

# Called at the top of the converted LECTIS skeleton (Deploy-GnSkeleton inserts the call and a 'return'), before the runstream's
# @XQT TPF$.LECTIS. The program reads LECIN (the call's INPUT file) and, in key mode, LECCRD (the run's data images = the Accept file).
function Invoke-LectisHandoff {
  param([String]$Program = 'ASSURFED_UTILIT_LECTIS_GN', [String]$XqtName = 'LECTIS', [String]$ParmFile = 'LECPARM')
  $lines = Get-LectisParmLines
  $files = @(@{ Fixed = 'LECIN'; Call = (Get-LectisSgs 'INPUT,1,1,1').Trim() })
  if ((Get-LectisCount 'KEYS') -gt 0) { $files += @{ Fixed = 'LECCRD'; Call = '*ACCEPT*' } }
  Invoke-GnHandoff -Program $Program -XqtName $XqtName -ParmFile $ParmFile -ParmRecLen 250 -ParmLines $lines -Files $files -Label 'LECTIS'
}
