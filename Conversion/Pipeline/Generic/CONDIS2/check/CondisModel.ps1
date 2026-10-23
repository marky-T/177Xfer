# PowerShell model of the generic CONDIS2 program (spec.md), with the skeleton's own date transforms. ISO-8859-1, CRLF.
function Read-CondisParm([String[]]$Lines) {
  $p = [pscustomobject]@{ In = 0; Out = 0; Groups = New-Object System.Collections.Generic.List[Object] }
  foreach ($l in $Lines) {
    $t = $l.Substring(0, 2)
    switch ($t) {
      'FI' { $p.In = [Int32]$l.Substring(2, 5) }
      'FO' { $p.Out = [Int32]$l.Substring(2, 5) }
      { $_ -in 'CA', 'OT', 'NG' } { $p.Groups.Add([pscustomobject]@{ Kind = $t.Substring(0, 1); Tests = New-Object System.Collections.Generic.List[Object]; Ops = New-Object System.Collections.Generic.List[Object] }) }
      'TS' { $n = [Int32]$l.Substring(7, 5); $p.Groups[$p.Groups.Count - 1].Tests.Add(@([Int32]$l.Substring(2, 5), $n, $l.PadRight(12 + $n).Substring(12, $n))) }
      'MV' { $p.Groups[$p.Groups.Count - 1].Ops.Add(@('M', [Int32]$l.Substring(2, 5), [Int32]$l.Substring(7, 5), [Int32]$l.Substring(12, 5), [Int32]$l.Substring(17, 5), $l.PadRight(26).Substring(22, 4).Trim())) }
      'CO' { $n = [Int32]$l.Substring(7, 5); $p.Groups[$p.Groups.Count - 1].Ops.Add(@('K', 0, 0, [Int32]$l.Substring(2, 5), $n, $l.PadRight(12 + $n).Substring(12, $n))) }
    }
  }
  $p
}

function Test-CondisNumeric([String]$s) { $s -match '^[0-9]+$' }
function Test-CondisBetween([String]$s, [String]$lo, [String]$hi) { [String]::CompareOrdinal($s, $lo) -gt 0 -and [String]::CompareOrdinal($s, $hi) -lt 0 }

# One date MOVE, as the skeleton's TRANSFO-DATE-* paragraphs. $f: input field; returns the output field.
function Convert-CondisDate([String]$Code, [String]$f) {
  $up = @{ '0' = ';'; '1' = '_'; '2' = '|'; '3' = '~' }
  $down = @{ ';' = '0'; '_' = '1'; '|' = '2'; '~' = '3' }
  switch ($Code) {
    'D42' {
      $a2 = $f.Substring(2, 2)
      foreach ($r in @(@('1999', '2010', ';'), @('2009', '2020', '_'), @('2019', '2030', '|'), @('2029', '2040', '~'))) {
        if (Test-CondisBetween $f $r[0] $r[1]) { $a2 = $r[2] + $a2.Substring(1) }
      }
      return $a2
    }
    'D24' {
      if ($f -eq '00') { return '0000' }
      if ($f -eq '  ') { return '    ' }
      if ($down.ContainsKey([String]$f[0])) { return '20' + $down[[String]$f[0]] + $f[1] }
      return '19' + $f
    }
    'D22A' { if ($up.ContainsKey([String]$f[0])) { return $up[[String]$f[0]] + $f[1] }; return $f }
    'D22B' { if ($down.ContainsKey([String]$f[0])) { return $down[[String]$f[0]] + $f[1] }; return $f }
    'D66A' {
      if (-not (Test-CondisNumeric $f)) { return $f }
      $mm = $f.Substring(2, 2); $jj = $f.Substring(4, 2)
      if ([String]::CompareOrdinal($mm, '15') -gt 0 -or $mm -eq '00' -or [String]::CompareOrdinal($jj, '35') -gt 0 -or $jj -eq '00') { return $f }
      if ($up.ContainsKey([String]$f[0])) { return $up[[String]$f[0]] + $f.Substring(1) }
      return $f
    }
    'D66B' { if ($down.ContainsKey([String]$f[0])) { return $down[[String]$f[0]] + $f.Substring(1) }; return $f }
    'D68' {
      if ($f -eq '      ') { return '        ' }
      if ($f -eq '000000') { return '00000000' }
      if ($down.ContainsKey([String]$f[0])) { return '20' + $down[[String]$f[0]] + $f.Substring(1) }
      return '19' + $f
    }
    'D86' {
      $a6 = $f.Substring(2, 6)
      if (-not (Test-CondisNumeric $f)) { return $a6 }
      $mm = $f.Substring(4, 2); $jj = $f.Substring(6, 2)
      if ([String]::CompareOrdinal($mm, '15') -gt 0 -or $mm -eq '00' -or [String]::CompareOrdinal($jj, '35') -gt 0 -or $jj -eq '00') { return $a6 }
      $yyy = $f.Substring(0, 3)
      if ($yyy -in '200', '201', '202', '203') { return $up[[String]$yyy[2]] + $f.Substring(3) }
      return $a6
    }
  }
  throw "CONDIS2 model: date code $Code"
}

function Invoke-CondisModel($P, [String]$InFile, [String]$OutFile) {
  $latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
  $text = $latin1.GetString([IO.File]::ReadAllBytes($InFile))
  $recs = @($text -split "`r`n")
  if ($recs.Count -and $recs[-1] -eq '') { $recs = if ($recs.Count -gt 1) { $recs[0..($recs.Count - 2)] } else { @() } }
  $hasCond = @($P.Groups | Where-Object { $_.Kind -ne 'N' }).Count -gt 0
  $sb = [System.Text.StringBuilder]::new(); $written = 0; $dropped = 0
  foreach ($rec in $recs) {
    $win = $(if ($rec.Length -gt $P.In) { $rec.Substring(0, $P.In) } else { $rec }).PadRight($P.In)
    $out = [char[]](' ' * $P.Out)
    $done = $false
    foreach ($g in $P.Groups) {
      if ($g.Kind -eq 'C') {
        $ok = $true
        foreach ($t in $g.Tests) { if ($win.Substring($t[0] - 1, $t[1]) -cne $t[2]) { $ok = $false; break } }
        if (-not $ok) { continue }
      }
      foreach ($o in $g.Ops) {
        $v = if ($o[0] -eq 'K') { $o[5] } elseif ($o[5]) { Convert-CondisDate $o[5] $win.Substring($o[1] - 1, $o[2]) } else { $win.Substring($o[1] - 1, $o[2]) }
        for ($i = 0; $i -lt $o[4]; $i++) { $out[$o[3] - 1 + $i] = $v[$i] }
      }
      if ($g.Kind -ne 'N') { $done = $true; break }
    }
    if ($done -or -not $hasCond) { [void]$sb.Append((-join $out)).Append("`r`n"); $written++ } else { $dropped++ }
  }
  [IO.File]::WriteAllBytes($OutFile, $latin1.GetBytes($sb.ToString()))
  [pscustomobject]@{ Read = $recs.Count; Written = $written; Dropped = $dropped }
}
