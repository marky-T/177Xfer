# PowerShell model of the generic FUSBA program (spec.md), driven by a parameter file. Used to make expected outputs
# and to check the real programs. Records are line-sequential, ISO-8859-1, CRLF; each is padded/cut to its file length.
function Read-FusbaParm([String[]]$Lines) {
  $p = [ordered]@{ Ins = @(); Outs = @(); Mode = ''; K1 = @(); K2 = @(); FM = @() }
  foreach ($l in $Lines) {
    switch ($l.Substring(0, 2)) {
      'IN' { $p.Ins += , @($l.Substring(2, 30).Trim(), [Int32]$l.Substring(32, 5)) }
      'OU' { $p.Outs += , @($l.Substring(2, 30).Trim(), [Int32]$l.Substring(32, 5)) }
      'MD' { $p.Mode = $l.Substring(2, 1) }
      'K1' { $p.K1 += , @([Int32]$l.Substring(2, 5), [Int32]$l.Substring(7, 5)) }
      'K2' { $p.K2 += , @([Int32]$l.Substring(2, 5), [Int32]$l.Substring(7, 5)) }
      'FM' { $p.FM += , @([Int32]$l.Substring(2, 5), [Int32]$l.Substring(7, 5), [Int32]$l.Substring(12, 5), [Int32]$l.Substring(17, 5)) }
    }
  }
  [pscustomobject]$p
}

function Read-FusbaRecords([String]$File, [Int32]$Len) {
  $text = [System.Text.Encoding]::GetEncoding('iso-8859-1').GetString([IO.File]::ReadAllBytes($File))
  $recs = @($text -split "`r`n"); if ($recs.Count -and $recs[-1] -eq '') { $recs = @($recs[0..($recs.Count - 2)]) }
  if ($text -eq '') { $recs = @() }
  return , @($recs | ForEach-Object { if ($_.Length -ge $Len) { $_.Substring(0, $Len) } else { $_.PadRight($Len) } })
}

function Fit([String]$s, [Int32]$len) { if ($s.Length -ge $len) { $s.Substring(0, $len) } else { $s.PadRight($len) } }

# Returns @{ Written = counts per output; Read = counts per input }; writes one file per output.
function Invoke-FusbaModel($P, [String[]]$InFiles, [String[]]$OutFiles) {
  $f1 = Read-FusbaRecords $InFiles[0] $P.Ins[0][1]
  $f2 = Read-FusbaRecords $InFiles[1] $P.Ins[1][1]
  $kl = [Math]::Max(($P.K1 | ForEach-Object { $_[1] } | Measure-Object -Sum).Sum, ($P.K2 | ForEach-Object { $_[1] } | Measure-Object -Sum).Sum)
  $high = [String][char]255 * $kl
  $sb = @($P.Outs | ForEach-Object { [System.Text.StringBuilder]::new() })
  $written = @(0) * $P.Outs.Count
  $i = 0; $j = 0
  while ($true) {
    $k1 = if ($i -lt $f1.Count) { Fit (-join ($P.K1 | ForEach-Object { $f1[$i].Substring($_[0] - 1, $_[1]) })) $kl } else { $high }
    $k2 = if ($j -lt $f2.Count) { Fit (-join ($P.K2 | ForEach-Object { $f2[$j].Substring($_[0] - 1, $_[1]) })) $kl } else { $high }
    $c = [String]::CompareOrdinal($k1, $k2)
    $out = -1; $rec = $null; $adv1 = $false; $adv2 = $false
    if ($c -lt 0) { $adv1 = $true }
    elseif ($c -gt 0) { $out = 0; $rec = $f2[$j]; $adv2 = $true }
    elseif ($k1 -ceq $high) { break }
    else {
      switch ($P.Mode) {
        'C' { $out = 1; $rec = $f2[$j]; $adv2 = $true }
        'D' { $adv2 = $true }
        default {
          $rec = Fit $f2[$j] $P.Outs[0][1]
          foreach ($m in $P.FM) {
            $v = Fit ($f1[$i].Substring($m[0] - 1, $m[1])) $m[3]
            $rec = $rec.Substring(0, $m[2] - 1) + $v + $rec.Substring($m[2] - 1 + $m[3])
          }
          $out = 0; $adv2 = $true
          if ($P.Mode -eq 'U') { $adv1 = $true }
          else {
            # M: read file 1 only when the next master key is greater than this one (or file 2 ends).
            $n2 = if ($j + 1 -lt $f2.Count) { Fit (-join ($P.K2 | ForEach-Object { $f2[$j + 1].Substring($_[0] - 1, $_[1]) })) $kl } else { $high }
            $adv1 = [String]::CompareOrdinal($n2, $k2) -gt 0
          }
        }
      }
    }
    if ($out -ge 0) { [void]$sb[$out].Append((Fit $rec $P.Outs[$out][1])).Append("`r`n"); $written[$out]++ }
    if ($adv1) { $i++ }
    if ($adv2) { $j++ }
  }
  $latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
  for ($o = 0; $o -lt $P.Outs.Count; $o++) { [IO.File]::WriteAllBytes($OutFiles[$o], $latin1.GetBytes($sb[$o].ToString())) }
  @{ Written = $written; Read = @($f1.Count, $f2.Count) }
}
