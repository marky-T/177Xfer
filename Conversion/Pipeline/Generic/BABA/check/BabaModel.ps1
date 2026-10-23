# PowerShell model of the generic BABA program (spec.md), driven by a parameter file. Used to make expected outputs
# and to check the real program. Records are line-sequential, ISO-8859-1, CRLF; each is padded/cut to the input length.
function Read-BabaParm([String[]]$Lines) {
  $p = [ordered]@{ InName = ''; In = 0; Outs = @(); Mode = ''; Seq = ''; Keys = @(); Sets = @() }
  foreach ($l in $Lines) {
    switch ($l.Substring(0, 2)) {
      'IN' { $p.InName = $l.Substring(2, 30).Trim(); $p.In = [Int32]$l.Substring(32, 5) }
      'OU' { $p.Outs += , @($l.Substring(2, 30).Trim(), [Int32]$l.Substring(32, 5)) }
      'MD' { $p.Mode = $l.Substring(2, 3).Trim(); $p.Seq = $l.Substring(5, 1) }
      'KF' { $p.Keys += , @([Int32]$l.Substring(2, 5), [Int32]$l.Substring(7, 5)) }
      'RQ' { $p.Sets += $l.Substring(7, [Int32]$l.Substring(2, 5)) }
    }
  }
  [pscustomobject]$p
}

# Returns @{ Written = counts per output; Dropped; Abort = $null or the record number }; writes one file per output.
function Invoke-BabaModel($P, [String]$InFile, [String[]]$OutFiles) {
  $latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
  $text = $latin1.GetString([IO.File]::ReadAllBytes($InFile))
  $recs = @($text -split "`r`n"); if ($recs.Count -and $recs[-1] -eq '') { $recs = @($recs[0..($recs.Count - 2)]) }
  $sb = @($P.Outs | ForEach-Object { [System.Text.StringBuilder]::new() })
  $written = @(0) * $P.Outs.Count; $dropped = 0; $abort = $null; $prev = $null; $n = 0
  foreach ($r in $recs) {
    $n++
    if ($n -ge 99999999) { break }
    $rec = if ($r.Length -ge $P.In) { $r.Substring(0, $P.In) } else { $r.PadRight($P.In) }
    $key = -join ($P.Keys | ForEach-Object { $rec.Substring($_[0] - 1, $_[1]) })
    $dup = $false
    if ($P.Seq -ne 'N' -and $null -ne $prev) {
      if ([String]::CompareOrdinal($key, $prev) -lt 0) { $abort = $n; break }
      $dup = ($P.Seq -eq 'M') -and ($key -ceq $prev)
    }
    $prev = $key
    $target = 1
    if ($P.Seq -eq 'M') { if ($dup) { $target = 2 } }
    elseif ($P.Mode -eq 'R') { if (-not ($P.Sets -ccontains $key)) { $target = 2 } }
    elseif ($P.Mode -eq 'E') { if ($P.Sets -ccontains $key) { $target = 2 } }
    if ($target -gt $P.Outs.Count) { $dropped++; continue }
    $len = $P.Outs[$target - 1][1]
    $out = if ($rec.Length -ge $len) { $rec.Substring(0, $len) } else { $rec.PadRight($len) }
    [void]$sb[$target - 1].Append($out).Append("`r`n"); $written[$target - 1]++
  }
  for ($o = 0; $o -lt $P.Outs.Count; $o++) { [IO.File]::WriteAllBytes($OutFiles[$o], $latin1.GetBytes($sb[$o].ToString())) }
  @{ Written = $written; Dropped = $dropped; Abort = $abort }
}
