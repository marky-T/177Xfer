<#
.SYNOPSIS
  CONDIS2 step G1: group the real calls by shape (from the call's cards, cross-checked with its expansion) and write
  <Out>\shapes.md and <Out>\shapes.csv. Reads only: cards, the expansions of Expand-AllCalls.ps1, the shared GnHandoff.ps1 splitter.
#>
param(
  [String]$Cards = 'E:\Repos\ssg4-work\sgs-cards',
  [String]$Expanded = 'E:\Repos\ssg4-work\redo\CONDIS2-261105_sonnet\percall\allcalls',
  [String]$Out = 'E:\Repos\ssg4-work\redo\CONDIS2-261105_sonnet\evidence'
)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path "$PSScriptRoot\..\..\..\..\..\SsgTrial").Path
. "$repo\Conversion\Pipeline\Generic\GnHandoff.ps1"
$enc = [Text.Encoding]::GetEncoding(1252)
$prog = 'CONDIS2_ASCII'

$rows = foreach ($c in (Import-Csv "$Cards\sgs-calls.csv" | Where-Object ProgramKey -eq $prog)) {
  $id = $c.CardFile -replace '^calls\\ASSURFED_F999RUN', '' -replace '\.sgs$', '' -replace '__', '_' -replace '^_', ''
  $file = Join-Path $Cards $c.CardFile
  $images = @((Read-GnSgsImages $file) | Where-Object { $_ -ne '' })
  $inLen = 0; $outLen = 0; $inBlk = 0; $outBlk = 0
  $case = 0; $oth = 0; $mv = 0; $cn = 0; $mvF = 0; $cnF = 0; $caseF = 0; $quoted = 0; $maxF = 0
  $codes = @{}; $order = New-Object System.Collections.Generic.List[String]; $cardCount = 0
  $badLen = @()
  foreach ($img in $images) {
    $f = Split-GnSgsImage $img
    $lab = $f[0][0].ToUpperInvariant()
    if ($lab -eq 'FILEIN') { $inLen = [Int32]$f[1][0]; $inBlk = [Int32]$f[1][1] }
    elseif ($lab -eq 'FILEOUT') { $outLen = [Int32]$f[1][0]; $outBlk = [Int32]$f[1][1] }
    elseif ($lab -eq 'PG') {
      $cardCount++
      $t = $f[1][0].ToUpperInvariant(); $order.Add($t)
      $n = $f.Count - 2; if ($n -gt $maxF) { $maxF = $n }
      switch ($t) { 'CASE' { $case++; $caseF += $n } 'OTHERWISE' { $oth++ } 'MOVE' { $mv++; $mvF += $n } 'CONST' { $cn++; $cnF += $n } }
      for ($j = 2; $j -lt $f.Count; $j++) {
        if ($f[$j].Count -ge 3 -and $f[$j][2] -match '^\s*$|\s') { $quoted++ }
        if ($t -eq 'MOVE' -and $f[$j].Count -ge 4) { $codes[$f[$j][3]] = 1 + [Int32]$codes[$f[$j][3]] }
      }
    }
  }
  # the skeleton's own checks (lines 4-96) and the layouts it cannot express, per call
  $nc = 0; $no = 0; $nm = 0; $nk = 0; $viol = @(); $edge = @(); $seenCase = $false; $seenOth = $false; $seenAct = $false
  $okCombo = @{ D42 = 4; D24 = 2; D22A = 2; D22B = 2; D66A = 6; D66B = 6; D86 = 8; D68 = 6 }
  foreach ($g in $pgc) {
    switch ($g.T) {
      'CASE' { $nc++; $seenCase = $true; if ($seenOth) { $edge += 'CASE after OTHERWISE' }; if ($nc -ne 1 -and $nm -eq 0 -and $nk -eq 0) { $viol += 'V1' } else { $nm = 0; $nk = 0 } }
      'OTHERWISE' { $no++; if (-not $seenCase) { $edge += 'OTHERWISE before any CASE' }; $seenOth = $true; if ($g.N -gt 1) { $edge += 'OTHERWISE with fields' }; if ($no -gt 1) { $viol += 'V2' }; if ($nm -eq 0 -and $nk -eq 0) { $viol += 'V3' }; $nm = 0; $nk = 0 }
      'MOVE' { $nm++; if (-not $seenCase) { $seenAct = $true }; if ($nm -gt 1) { $viol += 'V4' }
        foreach ($fl in $g.F) { if ($fl.Count -ge 4 -and $fl[3] -ne '') { $cd = $fl[3].ToUpperInvariant(); if (-not $okCombo.ContainsKey($cd) -or $okCombo[$cd] -ne [Int32]$fl[1]) { $viol += 'V7' } } } }
      'CONST' { $nk++; if (-not $seenCase) { $seenAct = $true }; if ($nk -gt 1) { $viol += 'V5' } }
      default { $viol += 'V6' }
    }
  }
  if ($seenCase -and $seenAct) { $edge += 'MOVE/CONST before the first CASE' }
  $shape = if ($case -eq 0 -and $oth -eq 0) { 'A: no CASE' } elseif ($oth -eq 0) { 'B: CASE, no OTHERWISE' } else { 'C: CASE + OTHERWISE' }
  $expCob = Join-Path $Expanded "${prog}__$id.cob"
  $exp = if ((Test-Path $expCob) -and (Select-String $expCob -Pattern 'PROCEDURE DIVISION' -Quiet)) { 'expanded' } else { 'EXPANSION FAILED' }
  [pscustomobject]@{
    Call = $id; Runstream = $c.RunId; Shape = $shape; InLen = $inLen; OutLen = $outLen; InBlock = $inBlk; OutBlock = $outBlk
    PgCards = $cardCount; Case = $case; Otherwise = $oth; MoveCards = $mv; ConstCards = $cn
    CaseFields = $caseF; MoveFields = $mvF; ConstFields = $cnF
    DateCodes = (($codes.Keys | Sort-Object | ForEach-Object { "$_=$($codes[$_])" }) -join ' ')
    Violations = (($viol | Select-Object -Unique) -join ' '); Edge = (($edge | Select-Object -Unique) -join '; '); MaxFieldsOnCard = $maxF; QuotedSpaceValues = $quoted; Order = ($order -join ' '); Expansion = $exp
  }
}
New-Item -ItemType Directory -Force $Out | Out-Null
$rows | Export-Csv "$Out\shapes.csv" -NoTypeInformation

$md = New-Object System.Collections.Generic.List[String]
$md.Add('# CONDIS2 - G1 shapes of the real calls'); $md.Add('')
$md.Add("Source: ``sgs-calls.csv`` (ProgramKey = $prog), cards in ``$Cards\calls``, expansions in ``percall\allcalls``. Script: ``generic\check\Classify-CondisCalls.ps1``. Calls: $(@($rows).Count).")
$md.Add('')
$md.Add('## Per call'); $md.Add('')
$md.Add('| Call | Shape | In len | Out len | CASE | OTHERWISE | MOVE cards (fields) | CONST cards (fields) | Date codes | Quoted/space values | Expansion |')
$md.Add('|---|---|---|---|---|---|---|---|---|---|---|')
foreach ($r in $rows) { $md.Add("| $($r.Call) | $($r.Shape) | $($r.InLen) | $($r.OutLen) | $($r.Case) | $($r.Otherwise) | $($r.MoveCards) ($($r.MoveFields)) | $($r.ConstCards) ($($r.ConstFields)) | $($r.DateCodes) | $($r.QuotedSpaceValues) | $($r.Expansion) |") }
$md.Add(''); $md.Add('## Groups'); $md.Add('')
$md.Add('| Calls | Shape | Calls (ids) |'); $md.Add('|---|---|---|')
foreach ($g in ($rows | Group-Object Shape | Sort-Object Name)) { $md.Add("| $($g.Count) | $($g.Name) | $(($g.Group.Call) -join ', ') |") }
$md.Add(''); $md.Add('## Date codes used by the real calls'); $md.Add('')
$all = @{}; foreach ($r in $rows) { foreach ($p in ($r.DateCodes -split ' ' | Where-Object { $_ })) { $k, $v = $p -split '='; $all[$k] = $all[$k] + [Int32]$v } }
$md.Add('| Code | Fields over all calls |'); $md.Add('|---|---|')
foreach ($k in ($all.Keys | Sort-Object)) { $md.Add("| $k | $($all[$k]) |") }
$md.Add(''); $md.Add('Codes in the skeleton not used by any real call: ' + ((@('D24', 'D42', 'D22A', 'D22B', 'D66A', 'D66B', 'D68', 'D86') | Where-Object { -not $all.ContainsKey($_) }) -join ', '))
$md.Add(''); $md.Add('## Extremes'); $md.Add('')
$md.Add("- Input record length: $(($rows | Measure-Object InLen -Minimum -Maximum | ForEach-Object { "$($_.Minimum)..$($_.Maximum)" })); output record length: $(($rows | Measure-Object OutLen -Minimum -Maximum | ForEach-Object { "$($_.Minimum)..$($_.Maximum)" }))")
$md.Add("- PG cards per call: $(($rows | Measure-Object PgCards -Minimum -Maximum | ForEach-Object { "$($_.Minimum)..$($_.Maximum)" })); CASE cards per call: max $(($rows | Measure-Object Case -Maximum).Maximum); fields on one PG card: max $(($rows | Measure-Object MaxFieldsOnCard -Maximum).Maximum)")
$md.Add("- Input length differs from output length in: $(($rows | Where-Object { $_.InLen -ne $_.OutLen } | ForEach-Object { $_.Call }) -join ', ')")
$md.Add(''); $md.Add('## Card-set checks (skeleton lines 4-96, V1-V7) and unusual layouts per call'); $md.Add('')
$md.Add('| Call | Skeleton check violations | Unusual layout (no skeleton check) |'); $md.Add('|---|---|---|')
foreach ($r in $rows) { $md.Add("| $($r.Call) | $(if ($r.Violations) { $r.Violations } else { 'none' }) | $(if ($r.Edge) { $r.Edge } else { 'none' }) |") }
$md.Add(''); $md.Add("Calls with OTHERWISE: $(@($rows | Where-Object { $_.Otherwise -gt 0 }).Count); of these with OTHERWISE before any CASE: $(@($rows | Where-Object { $_.Edge -match 'OTHERWISE before any CASE' }).Count); with a CASE after OTHERWISE: $(@($rows | Where-Object { $_.Edge -match 'CASE after OTHERWISE' }).Count); with MOVE/CONST before the first CASE: $(@($rows | Where-Object { $_.Edge -match 'before the first CASE' }).Count); OTHERWISE with fields: $(@($rows | Where-Object { $_.Edge -match 'with fields' }).Count); calls violating a skeleton check: $(@($rows | Where-Object { $_.Violations }).Count).")
$md.Add(''); $md.Add('## Notes'); $md.Add('')
$md.Add('- Field order inside a PG card is significant: MOVE fields are applied in card order, so a later field overwrites an earlier one where output ranges overlap.')
$md.Add('- Every real call has FILEIN and FILEOUT records of a fixed length (FILEIN,1,1,1 / FILEOUT,1,1,1); the input and output lengths differ in most calls (the date codes D24/D42/D68 change the field width).')
$md.Add('- Only D24, D42 and D68 occur in real calls. D22A, D22B, D66A, D66B and D86 are in the skeleton only (test data needed).')
$md.Add('- PAIJ01_UL_L85 (the only call with quoted space values, 6 of them in CASE conditions): the per-call expansion fails (the shared SGS code splits a card at every space, so PG,I,J,1 is empty; T3-028). The cards are parsed here with the shared raw-card splitter (GnHandoff.ps1), which keeps the quoted spaces.')
$md.Add('- CASE values in VIRJ01_UE_L850 include non-ASCII Windows-1252 characters (e-acute, e-grave) and punctuation (`{ } ! ?`): the parameter file must be Windows-1252.')
[IO.File]::WriteAllLines("$Out\shapes.md", $md, [Text.UTF8Encoding]::new($false))
$rows | Group-Object Shape | ForEach-Object { "{0}: {1}" -f $_.Name, $_.Count }
