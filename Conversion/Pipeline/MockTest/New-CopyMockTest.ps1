<#
.SYNOPSIS
  Mock test for a CFH-COPY style SSG program: makes input data from the SGS cards, works out the expected output
  independently of the generated code, and (with -Actual) compares what the converted program wrote.
.DESCRIPTION
  The expected output comes only from the cards (INPUT/OUTPUT record sizes, FIELDIN/FIELDOUT start,length pairs, FIXE
  constants), not from the COBOL or the C#. '<' in a FIXE text becomes ';' (the skeleton does INSPECT ... '<' BY ';').
  Records are fixed length, ISO-8859-1, followed by -RecordEnding (CRLF is the application's "File record ending").
.EXAMPLE
  pwsh -NoProfile -File New-CopyMockTest.ps1 -Cards ..\WorkingExample-CFH-COPY_ASCII\expected\1-cards\calls\ASSURFED_F999RUN_VIRM01_CO__L4.sgs -OutDir E:\AMT_Work\MockTest\VIRM01
  pwsh -NoProfile -File New-CopyMockTest.ps1 -Cards <same> -OutDir <same> -Actual E:\AMT_Work\MockTest\VIRM01\actual\INC
#>
param(
  [Parameter(Mandatory)][String]$Cards,
  [Parameter(Mandatory)][String]$OutDir,
  [Int32]$Records = 25,
  [Int32]$Seed = 1957,
  [ValidateSet('CRLF', 'LF', 'None')][String]$RecordEnding = 'CRLF',
  [String]$Actual
)

$ErrorActionPreference = 'Stop'
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
$eol = switch ($RecordEnding) { 'CRLF' { "`r`n" } 'LF' { "`n" } default { '' } }

$inLen = 0; $outLen = 0; $inName = ''; $outName = ''
$pairsIn = [System.Collections.Generic.List[Object]]::new()
$pairsOut = [System.Collections.Generic.List[Object]]::new()
$fixed = [System.Collections.Generic.List[Object]]::new()
foreach ($line in Get-Content -LiteralPath $Cards) {
  if ($line -match '^\s*INPUT\s+(\w+),(\d+)') { $inName = $Matches[1]; $inLen = [Int32]$Matches[2]; continue }
  if ($line -match '^\s*OUTPUT\s+(\w+),(\d+)') { $outName = $Matches[1]; $outLen = [Int32]$Matches[2]; continue }
  if ($line -match '^\s*FIELDIN\s+(.*)$') { foreach ($p in $Matches[1] -split '\s+' | Where-Object { $_ }) { $s, $l = $p -split ','; $pairsIn.Add([pscustomobject]@{ Start = [Int32]$s; Len = [Int32]$l }) }; continue }
  if ($line -match '^\s*FIELDOUT\s+(.*)$') { foreach ($p in $Matches[1] -split '\s+' | Where-Object { $_ }) { $s, $l = $p -split ','; $pairsOut.Add([pscustomobject]@{ Start = [Int32]$s; Len = [Int32]$l }) }; continue }
  if ($line -match '^\s*FIXE\s+(\d+),(\d+),(.*)$') { $fixed.Add([pscustomobject]@{ Start = [Int32]$Matches[1]; Len = [Int32]$Matches[2]; Text = $Matches[3].Trim() }); continue }
}
if (-not $inLen -or -not $outLen) { throw "No INPUT/OUTPUT cards found in $Cards" }
if ($pairsIn.Count -ne $pairsOut.Count) { throw "FIELDIN has $($pairsIn.Count) pairs but FIELDOUT has $($pairsOut.Count)" }
for ($i = 0; $i -lt $pairsIn.Count; $i++) {
  if ($pairsIn[$i].Len -ne $pairsOut[$i].Len) { throw "Pair $($i + 1): lengths differ ($($pairsIn[$i].Len) in, $($pairsOut[$i].Len) out)" }
  if ($pairsIn[$i].Start + $pairsIn[$i].Len - 1 -gt $inLen) { throw "Pair $($i + 1) runs past the input record" }
  if ($pairsOut[$i].Start + $pairsOut[$i].Len - 1 -gt $outLen) { throw "Pair $($i + 1) runs past the output record" }
}

# Each record: 'R<nnnnn>' then seeded printable characters (including '<' to show only FIXE text is changed).
if ($Actual) {
  # compare mode: take the records from the saved input file, so the expectation always matches the data the program read
  $raw = $latin1.GetString([System.IO.File]::ReadAllBytes((Join-Path $OutDir "input\$inName")))
  $inRecs = for ($at = 0; $at + $inLen -le $raw.Length; $at += $inLen + $eol.Length) { $raw.Substring($at, $inLen) }
  $Records = @($inRecs).Count
} else {
  $rng = [System.Random]::new($Seed)
  $alphabet = ('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 <>-/.,').ToCharArray()
  $inRecs = for ($n = 1; $n -le $Records; $n++) {
    $sb = [System.Text.StringBuilder]::new('R' + $n.ToString('00000'))
    while ($sb.Length -lt $inLen) { [void]$sb.Append($alphabet[$rng.Next($alphabet.Length)]) }
    $sb.ToString()
  }
}
$expRecs = foreach ($rec in $inRecs) {
  $o = [char[]]::new($outLen); [Array]::Fill($o, [char]' ')
  for ($i = 0; $i -lt $pairsIn.Count; $i++) {
    $v = $rec.Substring($pairsIn[$i].Start - 1, $pairsIn[$i].Len)
    $v.ToCharArray().CopyTo($o, $pairsOut[$i].Start - 1)
  }
  foreach ($f in $fixed) {
    $t = ($f.Text -replace '<', ';').PadRight($f.Len).Substring(0, $f.Len)
    $t.ToCharArray().CopyTo($o, $f.Start - 1)
  }
  -join $o
}

$expPath = Join-Path $OutDir "expected\$outName"
if ($Actual) {
  $exp = $latin1.GetBytes((($expRecs | ForEach-Object { $_ + $eol }) -join ''))
  $act = [System.IO.File]::ReadAllBytes($Actual)
  if ($exp.Length -eq $act.Length -and [System.Linq.Enumerable]::SequenceEqual($exp, $act)) {
    "PASS  $outName matches the independent reference ($Records records, $outLen bytes + $RecordEnding)"
    return
  }
  "FAIL  expected $($exp.Length) bytes, got $($act.Length) bytes"
  $n = [Math]::Min($exp.Length, $act.Length); $first = -1
  for ($i = 0; $i -lt $n; $i++) { if ($exp[$i] -ne $act[$i]) { $first = $i; break } }
  if ($first -ge 0) { $rl = $outLen + $eol.Length; "      first difference at byte $first (record $([Math]::Floor($first / $rl) + 1), column $($first % $rl + 1))" }
  exit 1
}

New-Item -ItemType Directory -Force -Path (Join-Path $OutDir 'input'), (Join-Path $OutDir 'expected') | Out-Null
[System.IO.File]::WriteAllBytes((Join-Path $OutDir "input\$inName"), $latin1.GetBytes((($inRecs | ForEach-Object { $_ + $eol }) -join '')))
[System.IO.File]::WriteAllBytes($expPath, $latin1.GetBytes((($expRecs | ForEach-Object { $_ + $eol }) -join '')))
"Input    $(Join-Path $OutDir "input\$inName")  ($Records x $inLen bytes + $RecordEnding)"
"Expected $expPath  ($Records x $outLen bytes + $RecordEnding)"
