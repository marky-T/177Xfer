<#
.SYNOPSIS
  CONDIS2 step G3: reference model, written from generic\spec.md only (never from converter output).
  For every case folder <Cases>\<name>\ (cards.sgs + input.dat) it writes <Cases>\<name>\expected\{output.dat, printer.txt, items.txt, result.txt}.
.DESCRIPTION
  input.dat   : Windows-1252 text, one record per line (a line shorter/longer than FILEIN length = short/long record, spec "Claims").
  output.dat  : one record per written output, FILEOUT length bytes, CRLF terminated.
  printer.txt : the report lines (spec "Printer report").
  items.txt   : the item list of spec "Behaviour" step 3 (C pos len value | M ip il op code | K op len value | T C k / T O).
  result.txt  : OK, or ABORT <violations V1..V7> (the skeleton's own card checks; nothing else is produced then).
  Deterministic: no dates, no random numbers; run twice -> byte-identical (Test in generic\check\Run-CondisModel.ps1).
#>
param([String]$Cases = "$PSScriptRoot\cases", [Switch]$LibraryOnly)
$ErrorActionPreference = 'Stop'
$enc = [Text.Encoding]::GetEncoding(1252)

# ---- cards (own small parser: image = label then fields; field = sub-fields separated by commas; ''x'' keeps spaces, quotes removed) ----
function Split-CondisImage([String]$Image) {
  $fields = New-Object System.Collections.Generic.List[Object]
  $subs = New-Object System.Collections.Generic.List[String]
  $b = New-Object System.Text.StringBuilder
  $pair = $false; $any = $false
  for ($i = 0; $i -lt $Image.Length; $i++) {
    $c = $Image[$i]
    if ($c -eq "'" -and $i + 1 -lt $Image.Length -and $Image[$i + 1] -eq "'") { $pair = -not $pair; $any = $true; $i++; continue }
    if (-not $pair -and ($c -eq ' ' -or $c -eq ',')) {
      if ($c -eq ',') { $subs.Add($b.ToString()); [void]$b.Clear(); $any = $true; continue }
      if ($any -or $b.Length) { $subs.Add($b.ToString()); [void]$b.Clear(); $fields.Add($subs.ToArray()); $subs.Clear(); $any = $false }
      continue
    }
    [void]$b.Append($c); $any = $true
  }
  if ($any -or $b.Length) { $subs.Add($b.ToString()) }
  if ($subs.Count) { $fields.Add($subs.ToArray()) }
  , $fields.ToArray()
}
function Read-CondisCards([String]$Path) {
  $c = [ordered]@{ InLen = 0; OutLen = 0; Pg = New-Object System.Collections.Generic.List[Object] }
  foreach ($line in [IO.File]::ReadAllLines($Path, $enc)) {
    if ($line.Trim() -eq '') { continue }
    $f = Split-CondisImage $line.Trim()
    switch ($f[0][0].ToUpperInvariant()) {
      'FILEIN' { $c.InLen = [Int32]$f[1][0] }
      'FILEOUT' { $c.OutLen = [Int32]$f[1][0] }
      'PG' { $c.Pg.Add([pscustomobject]@{ Type = $f[1][0].ToUpperInvariant(); Fields = @($f | Select-Object -Skip 2) }) }
    }
  }
  [pscustomobject]$c
}

# ---- the skeleton's own checks (spec "Checks of the card set") ----
function Test-CondisCards($Cards) {
  $v = New-Object System.Collections.Generic.List[String]
  $nc = 0; $no = 0; $nm = 0; $nk = 0
  $width = @{ D42 = 4; D24 = 2; D22A = 2; D22B = 2; D66A = 6; D66B = 6; D86 = 8; D68 = 6 }
  foreach ($g in $Cards.Pg) {
    switch ($g.Type) {
      'CASE' { $nc++; if ($nc -ne 1 -and $nm -eq 0 -and $nk -eq 0) { $v.Add('V1') } else { $nm = 0; $nk = 0 } }
      'OTHERWISE' { $no++; if ($no -gt 1) { $v.Add('V2') }; if ($nm -eq 0 -and $nk -eq 0) { $v.Add('V3') }; $nm = 0; $nk = 0 }
      'MOVE' {
        $nm++; if ($nm -gt 1) { $v.Add('V4') }
        foreach ($f in $g.Fields) { if ($f.Count -ge 4 -and $f[3] -ne '') { $d = $f[3].ToUpperInvariant(); if (-not $width.ContainsKey($d) -or $width[$d] -ne [Int32]$f[1]) { $v.Add('V7') } } }
      }
      'CONST' { $nk++; if ($nk -gt 1) { $v.Add('V5') } }
      default { $v.Add('V6') }
    }
  }
  @($v | Select-Object -Unique)
}

# ---- the item list the skeleton generates (spec Behaviour step 3) ----
function Get-CondisItems($Cards) {
  $items = New-Object System.Collections.Generic.List[Object]
  $n = 0; $nOther = @($Cards.Pg | Where-Object Type -eq 'OTHERWISE').Count
  foreach ($g in $Cards.Pg) {
    switch ($g.Type) {
      'CASE' {
        $n++; if ($n -ne 1) { $items.Add(@{ T = 'T'; Kind = 'C'; K = $n - 1 }) }
        foreach ($f in $g.Fields) { $items.Add(@{ T = 'C'; Pos = [Int32]$f[0]; Len = [Int32]$f[1]; Val = $f[2] }) }
      }
      'OTHERWISE' { $n++; $items.Add(@{ T = 'T'; Kind = 'C'; K = $n - 1 }) }
      'MOVE' {
        foreach ($f in $g.Fields) {
          $code = if ($f.Count -ge 4) { $f[3].ToUpperInvariant() } else { '' }
          $items.Add(@{ T = 'M'; IP = [Int32]$f[0]; IL = [Int32]$f[1]; OP = [Int32]$f[2]; Code = $code })
        }
      }
      'CONST' { foreach ($f in $g.Fields) { $items.Add(@{ T = 'K'; OP = [Int32]$f[0]; Len = [Int32]$f[1]; Val = $f[2] }) } }
    }
  }
  if ($nOther -eq 0) { $items.Add(@{ T = 'T'; Kind = 'C'; K = $n }) } else { $items.Add(@{ T = 'T'; Kind = 'O'; K = 0 }) }
  , $items.ToArray()
}
function Format-CondisItem($i) {
  switch ($i.T) {
    'C' { 'C {0} {1} [{2}]' -f $i.Pos, $i.Len, $i.Val }
    'M' { 'M {0} {1} {2} [{3}]' -f $i.IP, $i.IL, $i.OP, $i.Code }
    'K' { 'K {0} {1} [{2}]' -f $i.OP, $i.Len, $i.Val }
    'T' { 'T {0} {1}' -f $i.Kind, $i.K }
  }
}

# ---- helpers on fixed-width text (1-based positions as in the spec) ----
function Get-Part([String]$s, [Int32]$pos, [Int32]$len) {
  $r = New-Object System.Text.StringBuilder
  for ($i = 0; $i -lt $len; $i++) { $p = $pos - 1 + $i; [void]$r.Append($(if ($p -ge 0 -and $p -lt $s.Length) { $s[$p] } else { ' ' })) }
  $r.ToString()
}
function Set-Part([Char[]]$buf, [Int32]$pos, [String]$text) {
  for ($i = 0; $i -lt $text.Length; $i++) { $p = $pos - 1 + $i; if ($p -ge 0 -and $p -lt $buf.Length) { $buf[$p] = $text[$i] } }
}
function Compare-Ord([String]$a, [String]$b) { [String]::CompareOrdinal($a, $b) }
$script:Sym = @{ 0 = ';'; 1 = '_'; 2 = '|'; 3 = '~' }
$script:Dig = @{ ';' = 0; '_' = 1; '|' = 2; '~' = 3 }
function Test-AllDigits([String]$s) { $s -match '^[0-9]+$' }

# Returns @{ Out = result text; Flag = flag name or $null }; spec "Date codes"
function Convert-CondisDate([String]$Code, [String]$In) {
  switch ($Code) {
    'D42' {
      $a2 = $In.Substring(2, 2)
      if ((Compare-Ord $In '1999') -gt 0 -and (Compare-Ord $In '2010') -lt 0) { $a2 = ';' + $a2.Substring(1) }
      if ((Compare-Ord $In '2009') -gt 0 -and (Compare-Ord $In '2020') -lt 0) { $a2 = '_' + $a2.Substring(1) }
      if ((Compare-Ord $In '2019') -gt 0 -and (Compare-Ord $In '2030') -lt 0) { $a2 = '|' + $a2.Substring(1) }
      if ((Compare-Ord $In '2029') -gt 0 -and (Compare-Ord $In '2040') -lt 0) { $a2 = '~' + $a2.Substring(1) }
      return @{ Out = $a2; Flag = $null }
    }
    'D24' {
      if ($In -eq '00') { return @{ Out = '0000'; Flag = $null } }
      if ($In -eq '  ') { return @{ Out = '    '; Flag = $null } }
      if ($script:Dig.ContainsKey([String]$In[0])) { return @{ Out = ('20' + $script:Dig[[String]$In[0]] + $In[1]); Flag = $null } }
      return @{ Out = '19' + $In; Flag = $null }
    }
    'D22A' {
      if ($In[0] -match '[0-3]') { $d = [Int32][String]$In[0]; return @{ Out = $script:Sym[$d] + $In.Substring(1); Flag = "22A-20${d}X" } }
      return @{ Out = $In; Flag = $null }
    }
    'D22B' {
      if ($script:Dig.ContainsKey([String]$In[0])) { $d = $script:Dig[[String]$In[0]]; return @{ Out = [String]$d + $In.Substring(1); Flag = "22B-20${d}X" } }
      return @{ Out = $In; Flag = $null }
    }
    'D66A' {
      $mm = $In.Substring(2, 2); $jj = $In.Substring(4, 2)
      if (-not (Test-AllDigits $In)) { return @{ Out = $In; Flag = $null } }
      if ((Compare-Ord $mm '15') -gt 0 -or $mm -eq '00') { return @{ Out = $In; Flag = $null } }
      if ((Compare-Ord $jj '35') -gt 0 -or $jj -eq '00') { return @{ Out = $In; Flag = $null } }
      if ($In[0] -match '[0-3]') { $d = [Int32][String]$In[0]; return @{ Out = $script:Sym[$d] + $In.Substring(1); Flag = "66A-20${d}X" } }
      return @{ Out = $In; Flag = $null }
    }
    'D66B' {
      if ($script:Dig.ContainsKey([String]$In[0])) { $d = $script:Dig[[String]$In[0]]; return @{ Out = [String]$d + $In.Substring(1); Flag = "66B-20${d}X" } }
      return @{ Out = $In; Flag = $null }
    }
    'D68' {
      if ($In -eq '      ') { return @{ Out = '        '; Flag = $null } }
      if ($In -eq '000000') { return @{ Out = '00000000'; Flag = $null } }
      if ($script:Dig.ContainsKey([String]$In[0])) { return @{ Out = ('20' + $script:Dig[[String]$In[0]] + $In.Substring(1)); Flag = $null } }
      return @{ Out = '19' + $In; Flag = $null }
    }
    'D86' {
      $a6 = $In.Substring(2, 6)
      $mm = $In.Substring(4, 2); $jj = $In.Substring(6, 2)
      if (-not (Test-AllDigits $In)) { return @{ Out = $a6; Flag = $null } }
      if ((Compare-Ord $mm '15') -gt 0 -or $mm -eq '00') { return @{ Out = $a6; Flag = $null } }
      if ((Compare-Ord $jj '35') -gt 0 -or $jj -eq '00') { return @{ Out = $a6; Flag = $null } }
      $yyy = $In.Substring(0, 3)
      if ($yyy -in '200', '201', '202', '203') { return @{ Out = $script:Sym[[Int32]$yyy.Substring(2)] + $In.Substring(3); Flag = $null } }
      return @{ Out = $a6; Flag = $null }
    }
  }
  throw "no such date code $Code"
}

function Invoke-CondisModel($Cards, [String[]]$Records) {
  $items = Get-CondisItems $Cards
  $nCase = @($Cards.Pg | Where-Object Type -eq 'CASE').Count
  $cnt = New-Object 'Int32[]' ($nCase + 2)   # NB-REC-CASE-0 .. -N (index = k)
  $other = 0; $lu = 0; $ecrit = 0
  $flagCount = @{}
  foreach ($c in 'A', 'B') { }
  $outRecs = New-Object System.Collections.Generic.List[String]
  foreach ($rec in $Records) {
    $lu++
    $in = if ($rec.Length -ge $Cards.InLen) { $rec.Substring(0, $Cards.InLen) } else { $rec.PadRight($Cards.InLen) }
    $out = New-Object 'Char[]' 4000; for ($i = 0; $i -lt 4000; $i++) { $out[$i] = ' ' }
    $flags = @{}
    $active = $true; $written = $false
    foreach ($it in $items) {
      switch ($it.T) {
        'C' { if ($active) { $f = Get-Part $in $it.Pos $it.Len; $w = [Math]::Max($it.Len, $it.Val.Length); if ($f.PadRight($w) -cne $it.Val.PadRight($w)) { $active = $false } } }
        'M' {
          if ($active) {
            $src = Get-Part $in $it.IP $it.IL
            if ($it.Code -eq '') { Set-Part $out $it.OP $src }
            else { $r = Convert-CondisDate $it.Code $src; Set-Part $out $it.OP $r.Out; if ($r.Flag) { $flags[$r.Flag] = $true } }
          }
        }
        'K' { if ($active) { $v = if ($it.Val.Length -ge $it.Len) { $it.Val.Substring(0, $it.Len) } else { $it.Val.PadRight($it.Len) }; Set-Part $out $it.OP $v } }
        'T' {
          if ($active) {
            if ($it.Kind -eq 'C') { $cnt[$it.K]++ } else { $other++ }
            $ecrit++; foreach ($k in $flags.Keys) { $flagCount[$k] = 1 + [Int32]$flagCount[$k] }
            $outRecs.Add((-join $out[0..($Cards.OutLen - 1)])); $written = $true
          } else { $active = $true }
          if ($written) { break }
        }
      }
      if ($written) { break }
    }
  }
  # report (spec "Printer report")
  $d6 = { param($n) ('{0:D6}' -f $n) }
  $rep = New-Object System.Collections.Generic.List[String]
  $rep.Add('NB ENREGISTREMENTS LUS    = ' + (& $d6 $lu)); $rep.Add('NB ENREGISTREMENTS ECRITS = ' + (& $d6 $ecrit))
  if ($lu - $ecrit -gt 0) {
    $rep.Add('*******************************'); $rep.Add('*   attention                 *'); $rep.Add('*   certains records ne       *')
    $rep.Add('*   respectent aucun case     *'); $rep.Add('*   et ne figurent donc pas   *'); $rep.Add('*   sur le fichier output     *'); $rep.Add('*******************************')
  }
  for ($n = 1; $n -le $nCase; $n++) { $rep.Add("NB ENREGISTREMENTS CONDITION NO $n = " + (& $d6 $cnt[$n])) }
  $rep.Add('NB ENREGISTREMENTS OTHER = ' + (& $d6 $other))
  1..4 | ForEach-Object { $rep.Add(' ') }
  foreach ($code in '22A', '22B', '66A', '66B') {
    foreach ($d in 0..3) {
      $s = $script:Sym[$d]
      $txt = if ($code.EndsWith('A')) { "${d}X --> ${s}X" } else { "${s}X --> ${d}X" }
      $rep.Add("NB RECORDS AYANT SUBI TRANSFO ($code) $txt    = " + (& $d6 ([Int32]$flagCount["$code-20${d}X"])))
    }
  }
  @{ Out = $outRecs; Report = $rep; Items = $items }
}

if ($LibraryOnly) { return }

foreach ($dir in Get-ChildItem $Cases -Directory | Sort-Object Name) {
  $cards = Read-CondisCards "$($dir.FullName)\cards.sgs"
  $exp = New-Item -ItemType Directory -Force "$($dir.FullName)\expected"
  $viol = Test-CondisCards $cards
  $items = Get-CondisItems $cards
  [IO.File]::WriteAllText("$exp\items.txt", ((($items | ForEach-Object { Format-CondisItem $_ }) -join "`r`n") + "`r`n"), $enc)
  if ($viol.Count) {
    [IO.File]::WriteAllText("$exp\result.txt", "ABORT $($viol -join ' ')`r`n", $enc)
    foreach ($f in 'output.dat', 'printer.txt') { Remove-Item "$exp\$f" -ErrorAction SilentlyContinue }
    continue
  }
  $recs = [IO.File]::ReadAllLines("$($dir.FullName)\input.dat", $enc)
  $m = Invoke-CondisModel $cards $recs
  [IO.File]::WriteAllText("$exp\result.txt", "OK`r`n", $enc)
  [IO.File]::WriteAllText("$exp\output.dat", ((@($m.Out) | ForEach-Object { $_ + "`r`n" }) -join ''), $enc)
  [IO.File]::WriteAllText("$exp\printer.txt", ((@($m.Report) | ForEach-Object { $_ + "`r`n" }) -join ''), $enc)
}
