<#
.SYNOPSIS
  T3-059: the reader rule derived from the probe, as a simulator. Predicts the records AMT's line-sequential reader returns
  for a file of given line lengths, and compares with the mock results in results.csv.
.DESCRIPTION
  Rule (derived, not from AMT source; the file controller's source is not in the R&D clone):
  - Start: L = the FD's maximum record size M (4001 for the generic programs); "uniform" = true.
  - Each READ, while uniform: if the next L bytes are followed by CR LF, or are exactly the rest of the file and end in CR LF,
    they are one record (CR LFs inside kept; a trailing CR LF at end of file dropped).
  - Otherwise: a plain line up to the next CR LF.
  - After each record: if it is the first record, L = its length; if its length differs from L, uniform = false (plain lines
    from then on).
  With M = 4000 the same rule gives T3-040 ("a CR LF exactly at byte M+1": the first read takes 4000 bytes).
#>
param([String]$Results = "$PSScriptRoot\results.csv", [Int32]$M = 4001)
function Get-ReaderRecords([Int32[]]$Lengths, [Int32]$Max) {
  $letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  $f = -join (0..($Lengths.Count - 1) | ForEach-Object { ([String]$letters[$_ % 26] * $Lengths[$_]) + "`r`n" })
  $pos = 0; $L = $Max; $uniform = $true; $first = $true; $recs = @()
  while ($pos -lt $f.Length) {
    $rec = $null
    if ($uniform -and $pos + $L -le $f.Length) {
      $after = if ($pos + $L + 2 -le $f.Length) { $f.Substring($pos + $L, 2) } else { '' }
      if ($after -eq "`r`n") { $rec = $f.Substring($pos, $L); $pos += $L + 2 }
      elseif ($pos + $L -eq $f.Length -and $f.EndsWith("`r`n") -and $L -ge 2) { $rec = $f.Substring($pos, $L - 2); $pos = $f.Length }
    }
    if ($null -eq $rec) { $i = $f.IndexOf("`r`n", $pos); if ($i -lt 0) { $i = $f.Length }; $rec = $f.Substring($pos, $i - $pos); $pos = [Math]::Min($f.Length, $i + 2) }
    $recs += $rec
    if ($first) { $L = $rec.Length; $first = $false } elseif ($rec.Length -ne $L) { $uniform = $false }
  }
  , $recs
}
$ok = 0; $bad = 0
foreach ($r in Import-Csv $Results | Where-Object { $_.RecordsRead -ne 'n/a' }) {
  $pred = (Get-ReaderRecords ([Int32[]]($r.Lengths -split ',')) $M).Count
  $match = [Int32][Double]$r.RecordsRead -eq $pred
  if ($match) { $ok++ } else { $bad++ }
  '{0,-22} {1,-40} mock {2,2}  rule {3,2}  {4}' -f $r.Case, $r.Lengths, [Int32][Double]$r.RecordsRead, $pred, $(if ($match) { 'OK' } else { 'MISMATCH' })
}
"rule vs mock: $ok match, $bad mismatch"
