# SSG-4 generic program: parameter file + hand-off for CONDIS2, written from the call's SGS cards (spec.md).
# Deployed as CondisParm.inc next to the converted skeleton; runs inside R&D's Invoke-Ssg (AmtPsEclLib, StrictMode 2).
# Needs AMT's GetSgsValue in scope and GnHandoff.inc (Invoke-GnHandoff, Get-GnSgsCards).
# SGSPARM (250): RL in(5) out(5) nCase(5) | CD pos(5) len(5) value(200) | MV ip(5) il(5) op(5) code(4) | KT op(5) len(5) value(200) | TL kind(1) k(5)
# One record per item of the list the skeleton generates (spec "Behaviour" step 3), in card order.

# AMT's label store is case-sensitive (T3-054) and GetSgsValue returns strings, $null when missing (T3-048, T3-050).
function Get-CondisSgs([String]$Name, [Switch]$Number) {
  $v = [String](GetSgsValue $Name.ToUpperInvariant())
  if ($v.Trim() -eq '') { Abort "SSG-4 hand-off (CONDIS2): no SGS value for [$Name]" }
  if ($Number) { if ($v.Trim() -notmatch '^\d+$') { Abort "SSG-4 hand-off (CONDIS2): [$Name] = '$v' is not a number" }; return [Int32]$v.Trim() }
  $v.Trim()
}

# The call's PG cards as objects { Type; Fields } (Fields = one string[] of sub-fields per card field).
# Raw card file first ($SgsFilePath of Invoke-Ssg): AddTo-SgsList splits a card at every space, which loses quoted values
# with spaces (T3-028); without the file, AMT's label store.
function Get-CondisPgCards {
  $cards = New-Object System.Collections.Generic.List[Object]
  $file = Get-Variable SgsFilePath -ValueOnly -ErrorAction SilentlyContinue
  if ($file -and (Test-Path -LiteralPath $file)) {
    $pg = Get-GnSgsCards $file 'PG'
    $i = 0
    foreach ($f in $pg) {
      $i++
      if ($f.Count -lt 2) { Abort "SSG-4 hand-off (CONDIS2): PG card $i has no type word" }
      $fields = New-Object System.Collections.Generic.List[Object]
      for ($j = 2; $j -lt $f.Count; $j++) { $fields.Add(@($f[$j])) }
      $cards.Add([pscustomobject]@{ Type = ([String]$f[1][0]).ToUpperInvariant(); Fields = $fields.ToArray() })
    }
    return , $cards.ToArray()
  }
  $n = 0
  if ($global:SgsLabels.ContainsKey('PG')) { $n = [Int32](GetSgsValue 'PG') }
  for ($i = 1; $i -le $n; $i++) {
    $cnt = [Int32](GetSgsValue "PG,$i")
    $type = ([String](GetSgsValue "PG,$i,1,1")).Trim().ToUpperInvariant()
    $fields = New-Object System.Collections.Generic.List[Object]
    for ($j = 2; $j -le $cnt; $j++) {
      $subs = New-Object System.Collections.Generic.List[String]
      $max = if ($type -eq 'MOVE') { 4 } else { 3 }
      for ($s = 1; $s -le $max; $s++) { $subs.Add([String](GetSgsValue "PG,$i,$j,$s")) }
      if ($subs.Count -eq 4 -and $subs[3].Trim() -eq '') { $subs.RemoveAt(3) }
      $fields.Add($subs.ToArray())
    }
    $cards.Add([pscustomobject]@{ Type = $type; Fields = $fields.ToArray() })
  }
  return , $cards.ToArray()
}

function ConvertTo-CondisInt([String]$Text, [String]$What) {
  if ($Text.Trim() -notmatch '^\d+$') { Abort "SSG-4 hand-off (CONDIS2): $What = '$Text' is not a number" }
  [Int32]$Text.Trim()
}

# The item list as { T; ... } hashtables, validated as the skeleton does (its checks V1-V7, spec) and against the generic program's limits.
# Nothing else is rejected: OTHERWISE before CASE, CASE after OTHERWISE, MOVE/CONST before the first CASE ... run as the generated text would.
function Get-CondisHandoffItems([Object[]]$Cards) {
  $items = New-Object System.Collections.Generic.List[Object]
  $width = @{ D42 = 4; D24 = 2; D22A = 2; D22B = 2; D66A = 6; D66B = 6; D86 = 8; D68 = 6 }
  $outW = @{ D42 = 2; D24 = 4; D22A = 2; D22B = 2; D66A = 6; D66B = 6; D86 = 6; D68 = 8 }
  $n = 0; $nCase = 0; $nOther = 0; $nm = 0; $nk = 0; $i = 0
  foreach ($card in $Cards) {
    $i++
    $where = "PG card $i ($($card.Type))"
    switch ($card.Type) {
      'CASE' {
        $n++; $nCase++
        if ($n -ne 1 -and $nm -eq 0 -and $nk -eq 0) { Abort "SSG-4 hand-off (CONDIS2): $where is not preceded by a MOVE or CONST card after the previous condition (skeleton check V1)" }
        $nm = 0; $nk = 0
        if ($n -ne 1) { $items.Add(@{ T = 'T'; Kind = 'C'; K = $n - 1 }) }
        $f = 0
        foreach ($fld in $card.Fields) {
          $f++
          if ($fld.Count -lt 3) { Abort "SSG-4 hand-off (CONDIS2): $where field $f needs position,length,value" }
          $pos = ConvertTo-CondisInt $fld[0] "$where field $f position"; $len = ConvertTo-CondisInt $fld[1] "$where field $f length"
          if ($pos -lt 1 -or $len -lt 1 -or $len -gt 200 -or $pos + $len - 1 -gt 4000 -or ([String]$fld[2]).Length -gt 200) { Abort "SSG-4 hand-off (CONDIS2): $where field $f ($pos,$len) is outside the generic program's limits (position 1..4000, length 1..200, value <= 200)" }
          $items.Add(@{ T = 'C'; Pos = $pos; Len = $len; Val = [String]$fld[2] })
        }
      }
      'OTHERWISE' {
        $n++; $nOther++
        if ($nOther -gt 1) { Abort "SSG-4 hand-off (CONDIS2): ${where}: more than one OTHERWISE card (skeleton check V2)" }
        if ($nm -eq 0 -and $nk -eq 0) { Abort "SSG-4 hand-off (CONDIS2): $where is not preceded by a MOVE or CONST card after the previous condition (skeleton check V3)" }
        $nm = 0; $nk = 0
        # the skeleton's test 'NOCASE <> 1' (bare word) is taken as written: always true
        $items.Add(@{ T = 'T'; Kind = 'C'; K = $n - 1 })
      }
      'MOVE' {
        $nm++
        if ($nm -gt 1) { Abort "SSG-4 hand-off (CONDIS2): ${where}: more than one MOVE card after the previous condition (skeleton check V4)" }
        $f = 0
        foreach ($fld in $card.Fields) {
          $f++
          if ($fld.Count -lt 3) { Abort "SSG-4 hand-off (CONDIS2): $where field $f needs inpos,length,outpos[,code]" }
          $ip = ConvertTo-CondisInt $fld[0] "$where field $f input position"; $il = ConvertTo-CondisInt $fld[1] "$where field $f length"; $op = ConvertTo-CondisInt $fld[2] "$where field $f output position"
          $code = ''
          if ($fld.Count -ge 4 -and ([String]$fld[3]).Trim() -ne '') {
            $code = ([String]$fld[3]).Trim().ToUpperInvariant()
            if (-not $width.ContainsKey($code) -or $width[$code] -ne $il) { Abort "SSG-4 hand-off (CONDIS2): $where field ${f}: date code $code does not fit length $il (skeleton check V7)" }
          }
          $ow = if ($code) { $outW[$code] } else { $il }
          if ($ip -lt 1 -or $il -lt 1 -or $op -lt 1 -or $ip + $il - 1 -gt 4000 -or $op + $ow - 1 -gt 4000) { Abort "SSG-4 hand-off (CONDIS2): $where field $f ($ip,$il,$op) is outside the generic program's 4000-byte record area" }
          $items.Add(@{ T = 'M'; IP = $ip; IL = $il; OP = $op; Code = $code })
        }
      }
      'CONST' {
        $nk++
        if ($nk -gt 1) { Abort "SSG-4 hand-off (CONDIS2): ${where}: more than one CONST card after the previous condition (skeleton check V5)" }
        $f = 0
        foreach ($fld in $card.Fields) {
          $f++
          if ($fld.Count -lt 3) { Abort "SSG-4 hand-off (CONDIS2): $where field $f needs outpos,length,value" }
          $op = ConvertTo-CondisInt $fld[0] "$where field $f output position"; $len = ConvertTo-CondisInt $fld[1] "$where field $f length"
          if ($op -lt 1 -or $len -lt 1 -or $len -gt 200 -or $op + $len - 1 -gt 4000 -or ([String]$fld[2]).Length -gt 200) { Abort "SSG-4 hand-off (CONDIS2): $where field $f ($op,$len) is outside the generic program's limits (position 1..4000, length 1..200, value <= 200)" }
          $items.Add(@{ T = 'K'; OP = $op; Len = $len; Val = [String]$fld[2] })
        }
      }
      default { Abort "SSG-4 hand-off (CONDIS2): ${where}: PG card is not CASE, MOVE, CONST or OTHERWISE (skeleton check V6)" }
    }
  }
  if ($nCase -gt 200 -or $n -gt 200) { Abort "SSG-4 hand-off (CONDIS2): $nCase CASE cards > 200 (generic program limit)" }
  if ($nOther -eq 0) { $items.Add(@{ T = 'T'; Kind = 'C'; K = $n }) } else { $items.Add(@{ T = 'T'; Kind = 'O'; K = 0 }) }
  if ($items.Count -gt 2000) { Abort "SSG-4 hand-off (CONDIS2): $($items.Count) items > 2000 (generic program limit)" }
  return , $items.ToArray()
}

function Get-CondisParmLines {
  $inLen = Get-CondisSgs 'FILEIN,1,1,1' -Number
  $outLen = Get-CondisSgs 'FILEOUT,1,1,1' -Number
  if ($inLen -lt 1 -or $inLen -gt 4000 -or $outLen -lt 1 -or $outLen -gt 4000) { Abort "SSG-4 hand-off (CONDIS2): record length $inLen / $outLen outside 1..4000 (generic program limit)" }
  $cards = Get-CondisPgCards
  $items = Get-CondisHandoffItems $cards
  $nCase = @($cards | Where-Object { $_.Type -eq 'CASE' }).Count
  $lines = New-Object System.Collections.Generic.List[String]
  $lines.Add('RL' + ('{0:D5}{1:D5}{2:D5}' -f $inLen, $outLen, $nCase))
  foreach ($it in $items) {
    switch ($it['T']) {
      'C' { $lines.Add('CD' + ('{0:D5}{1:D5}' -f $it['Pos'], $it['Len']) + ([String]$it['Val']).PadRight(200)) }
      'M' { $lines.Add('MV' + ('{0:D5}{1:D5}{2:D5}' -f $it['IP'], $it['IL'], $it['OP']) + ([String]$it['Code']).PadRight(4)) }
      'K' { $lines.Add('KT' + ('{0:D5}{1:D5}' -f $it['OP'], $it['Len']) + ([String]$it['Val']).PadRight(200)) }
      'T' { $lines.Add('TL' + $it['Kind'] + ('{0:D5}' -f $it['K'])) }
    }
  }
  return , $lines
}

# Called at the top of the converted skeleton (Deploy-GnSkeleton inserts the call and a 'return'), before the runstream's Xqt.
# The runstream's @USE FILEIN / @USE FILEOUT are the call's names; the program opens the fixed names CNDIN / CNDOUT.
function Invoke-CondisHandoff {
  param([String]$Program = 'ASSURFED_UTILIT_CONDIS2_GN', [String]$XqtName = 'CONDIS2', [String]$ParmFile = 'CNDPARM')
  $lines = Get-CondisParmLines
  $files = @(
    @{ Fixed = 'CNDIN'; Call = 'FILEIN' },
    @{ Fixed = 'CNDOUT'; Call = 'FILEOUT'; RecSize = (Get-CondisSgs 'FILEOUT,1,1,1' -Number) }
  )
  Invoke-GnHandoff -Program $Program -XqtName $XqtName -ParmFile $ParmFile -ParmRecLen 250 -ParmLines $lines -Files $files -Label 'CONDIS2'
}
