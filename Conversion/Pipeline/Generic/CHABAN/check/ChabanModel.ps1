# PowerShell model of the generic CHABAN program (spec.md): data images -> records. Writes ISO-8859-1, CRLF.
function Read-ChabanParm([String[]]$Lines) {
  [pscustomobject]@{ Card = [Int32]$Lines[0].Substring(32, 5); OutName = $Lines[1].Substring(2, 30).Trim(); Len = [Int32]$Lines[1].Substring(32, 5)
    Records = [Int32]$Lines[2].Substring(2, 5); PerRecord = [Int32]$Lines[2].Substring(7, 5) }
}

function Invoke-ChabanModel($P, [String[]]$Cards, [String]$OutFile) {
  $sb = [System.Text.StringBuilder]::new(); $i = 0; $written = 0
  for ($r = 0; $r -lt $P.Records; $r++) {
    if ($i + $P.PerRecord -gt $Cards.Count) { break }
    $rec = -join (0..($P.PerRecord - 1) | ForEach-Object { $c = $Cards[$i + $_]; if ($c.Length -ge $P.Card) { $c.Substring(0, $P.Card) } else { $c.PadRight($P.Card) } })
    $i += $P.PerRecord
    $rec = if ($rec.Length -ge $P.Len) { $rec.Substring(0, $P.Len) } else { $rec.PadRight($P.Len) }
    [void]$sb.Append($rec).Append("`r`n"); $written++
  }
  [IO.File]::WriteAllBytes($OutFile, [System.Text.Encoding]::GetEncoding('iso-8859-1').GetBytes($sb.ToString()))
  $written
}
