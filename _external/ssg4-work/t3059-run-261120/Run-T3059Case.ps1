param([Parameter(Mandatory)][ValidateSet('Stage', 'Collect')][String]$Action, [Parameter(Mandatory)][ValidateRange(1, 4)][Int32]$Case)
# T3-059 repro run in CC-Trial: program job T3059_READREC reads Extracts\RDIN.DAT and writes Extracts\RDOUT.DAT.
$ErrorActionPreference = 'Stop'
$x = 'E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Extracts'
$src = Get-ChildItem 'E:\Repos\SsgTrial\docs\RnD-Tickets\T3-059-repro' -Filter "in$Case-*.txt" | Select-Object -First 1
$ev = "E:\Repos\ssg4-work\t3059-run-261120\$($src.BaseName)"
if ($Action -eq 'Stage') {
  Remove-Item "$x\RDOUT.DAT", "$x\RDIN.DAT" -ErrorAction SilentlyContinue
  Copy-Item $src.FullName "$x\RDIN.DAT"
  "staged $($src.Name) -> RDIN.DAT ($((Get-Item "$x\RDIN.DAT").Length) bytes, $(@(Get-Content "$x\RDIN.DAT").Count) lines)"
} else {
  if (-not (Test-Path "$x\RDOUT.DAT")) { throw 'RDOUT.DAT not written' }
  New-Item -ItemType Directory -Force $ev | Out-Null
  Copy-Item "$x\RDIN.DAT", "$x\RDOUT.DAT" $ev -Force
  $lines = @(Get-Content "$x\RDIN.DAT").Count
  $bytes = [IO.File]::ReadAllBytes("$x\RDOUT.DAT"); $enc = if ($bytes.Length -gt 1 -and $bytes[1] -eq 0) { [Text.Encoding]::Unicode } else { [Text.Encoding]::GetEncoding('iso-8859-1') }
  # A merged record carries CR LF inside it: split at each record number, not at line ends.
  $recs = @([regex]::Split($enc.GetString($bytes), '(?m)(?=^\d{6} \d{5} )') | Where-Object { $_ -match '^\d{6} ' } | ForEach-Object { $_.TrimEnd("`r", "`n", ' ') })
  "$($src.Name): input lines $lines, records read $($recs.Count)$(if ($recs.Count -ne $lines) { '  <-- MERGED' })"
  $recs | ForEach-Object { '  ' + ($_ -replace "`r", '<CR>' -replace "`n", '<LF>').TrimEnd() }
}
