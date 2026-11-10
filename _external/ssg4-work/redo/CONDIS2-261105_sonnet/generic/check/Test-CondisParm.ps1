<#
.SYNOPSIS
  CONDIS2 step G7: parameter lines for all real calls from their cards (AMT's SGS functions, case-sensitive labels, StrictMode 2),
  cross-checked against each call's own expansion, and against the reference model's item list. Writes crosscheck.csv + parm\*.parm.
.DESCRIPTION
  Result per call: MATCH (parm items = items read from the call's expansion), DIFF: <what>, NO-EXPANSION (the per-call expansion fails, T3-028:
  nothing to compare with, parm built and compared with the model only), REJECTED (the hand-off Aborts, expected only for invalid cards).
  Columns Model (writer items = reference model items from the same cards) and SgsPath (same lines when the cards come from AMT's label
  store instead of the raw card file) are extra evidence. The counts are the catalog baseline (utilities.json check.crosscheck).
  Reads expansions from <Expanded> (Expand-AllCalls.ps1 -Out), writes to <Out>.
#>
param(
  [String]$Repo = 'E:\Repos\SsgTrial',
  [String]$Cards = 'E:\Repos\ssg4-work\sgs-cards',
  [String]$Expanded = 'E:\Repos\ssg4-work\redo\CONDIS2-261105_sonnet\percall\allcalls',
  [String]$Out = 'E:\Repos\ssg4-work\redo\CONDIS2-261105_sonnet\evidence',
  [String]$Skeleton = 'CONDIS2_ASCII'
)
$ErrorActionPreference = 'Stop'
$enc = [Text.Encoding]::GetEncoding(1252)
New-Item -ItemType Directory -Force "$Out\parm" | Out-Null
. "$Repo\Conversion\Pipeline\SgsCardChecks.ps1"
. "$Repo\Conversion\Pipeline\Generic\GnHandoff.ps1"
. "$PSScriptRoot\..\gen\CondisParm.ps1"
. "$PSScriptRoot\CondisModel.ps1" -LibraryOnly
# AMT's own SGS code, unchanged, from the isolated library copy
$ast = [System.Management.Automation.Language.Parser]::ParseFile("$Repo\SsgConverter\Trials\RealRuntime\AmtPsEclLib.psm1", [ref]$null, [ref]$null)
$defs = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
foreach ($name in 'AddTo-SgsList', 'GetSgsValue', 'Get-NextSgsPart', 'IpfSf-Substring', 'CompareTypeSafe') {
  $def = $defs | Where-Object Name -eq $name | Select-Object -First 1
  . ([ScriptBlock]::Create(($def.Extent.Text -replace "^function\s+$([regex]::Escape($name))", "function global:$name")))
}
function global:Add-ErrorMsg { param([String]$Msg) throw "AMT error: $Msg" }
function global:Add-WarningMsg { param([String]$Msg) }
function global:Abort { param([String]$Msg) throw "ABORT: $Msg" }

function Format-Item([String]$t, $a, $b, $c, $d) {
  switch ($t) {
    'C' { "C $a $b [$("$c".TrimEnd())]" }
    'M' { "M $a $b $c [$d]" }
    'K' { "K $a $b [$("$c".TrimEnd())]" }
    'T' { "T $a $b" }
  }
}

# What the skeleton generated for this call: the item list read back from its expanded COBOL.
function Read-Expansion([String]$Path) {
  $all = (Get-Content $Path -Encoding 1252) | Where-Object { -not ($_.Length -ge 7 -and $_[6] -eq '*') }
  $j = $all -join ' ' -replace '\s+', ' '
  $r = [ordered]@{
    InLen = [Int32]([regex]::Match($j, 'FD FILEIN .*?RECORD CONTAINS (\d+) CHARACTERS').Groups[1].Value)
    OutLen = [Int32]([regex]::Match($j, 'FD FILEOUT .*?RECORD CONTAINS (\d+) CHARACTERS').Groups[1].Value)
    NCase = @([regex]::Matches($j, '01 NB-REC-CASE-([1-9]\d*) PIC')).Count
    Items = @()
  }
  $map = @{}; $cur = $false; $off = 0
  $iProc = [Array]::FindIndex([String[]]$all, [Predicate[String]]{ param($s) $s -match 'PROCEDURE DIVISION' })
  for ($i = 0; $i -lt $iProc; $i++) {
    $l = $all[$i]
    if ($l -match '^\s*01\s+(ENR-CASE|ENRIN-MOVE|ENROUT-MOVE|ENROUT-CONST)-\d+-\d+\s+REDEFINES') { $cur = $true; $off = 0 }
    elseif ($l -match '^\s*01\s') { $cur = $false }
    elseif ($cur -and $l -match '^\s*03\s+FILLER\s+PIC X\((\d+)\)') { $off += [Int32]$Matches[1] }
    elseif ($cur -and $l -match '^\s*03\s+((?:CASE|MOVEIN|MOVEOUT|CONST)-\d+-\d+)\s+PIC X\((\d+)\)') { $map[$Matches[1]] = @(($off + 1), [Int32]$Matches[2]); $off += [Int32]$Matches[2] }
  }
  $codeOf = @{ '2-4' = 'D24'; '4-2' = 'D42'; '22A' = 'D22A'; '22B' = 'D22B'; '66A' = 'D66A'; '66B' = 'D66B'; '68' = 'D68'; '86' = 'D86' }
  $start = [Array]::FindIndex([String[]]$all, [Predicate[String]]{ param($s) $s -match 'ADD 1 TO NB-REC-LU' })
  $end = [Array]::FindIndex([String[]]$all, [Predicate[String]]{ param($s) $s -match '^\s*CASE-NON-PREVU\.' })
  $code = ''
  for ($i = $start; $i -lt $end; $i++) {
    $l = $all[$i]
    if ($l -match "^\s*IF CASE-(\d+-\d+) = '(.*)'\s*$") { $p = $map["CASE-$($Matches[1])"]; $r.Items += Format-Item 'C' $p[0] $p[1] $Matches[2] }
    elseif ($l -match '^\s*MOVE MOVEIN-(\d+-\d+) TO MOVEOUT-(\d+-\d+)\s*$') { $a = $map["MOVEIN-$($Matches[1])"]; $b = $map["MOVEOUT-$($Matches[2])"]; $r.Items += Format-Item 'M' $a[0] $a[1] $b[0] '' }
    elseif ($l -match '^\s*MOVE MOVEIN-(\d+-\d+) TO WS-A\d\s*$') { $code = '' }
    elseif ($l -match '^\s*PERFORM TRANSFO-DATE-(\S+)\s+THRU') { $code = $codeOf[$Matches[1]] }
    elseif ($l -match '^\s*MOVE WS-A\d TO MOVEOUT-(\d+-\d+)\s*$') {
      $k = $Matches[1]; $a = $map["MOVEIN-$k"]; $b = $map["MOVEOUT-$k"]
      $r.Items += Format-Item 'M' $a[0] $a[1] $b[0] $code
    }
    elseif ($l -match "^\s*MOVE '(.*)' TO CONST-(\d+-\d+)\s*$") { $p = $map["CONST-$($Matches[2])"]; $r.Items += Format-Item 'K' $p[0] $p[1] $Matches[1] }
    elseif ($l -match '^\s*ADD 1 TO NB-REC-CASE-(\d+)\s*$') { $r.Items += Format-Item 'T' 'C' ([Int32]$Matches[1]) }
    elseif ($l -match '^\s*ADD 1 TO NB-REC-OTHER\s*$') { $r.Items += Format-Item 'T' 'O' 0 }
  }
  [pscustomobject]$r
}
# The same values from the parameter lines.
function Read-Parm([String[]]$Lines) {
  $p = [ordered]@{ InLen = 0; OutLen = 0; NCase = 0; Items = @() }
  foreach ($l in $Lines) {
    switch ($l.Substring(0, 2)) {
      'RL' { $p.InLen = [Int32]$l.Substring(2, 5); $p.OutLen = [Int32]$l.Substring(7, 5); $p.NCase = [Int32]$l.Substring(12, 5) }
      'CD' { $p.Items += Format-Item 'C' ([Int32]$l.Substring(2, 5)) ([Int32]$l.Substring(7, 5)) $l.Substring(12, 200) }
      'MV' { $p.Items += Format-Item 'M' ([Int32]$l.Substring(2, 5)) ([Int32]$l.Substring(7, 5)) ([Int32]$l.Substring(12, 5)) $l.Substring(17, 4).Trim() }
      'KT' { $p.Items += Format-Item 'K' ([Int32]$l.Substring(2, 5)) ([Int32]$l.Substring(7, 5)) $l.Substring(12, 200) }
      'TL' { $p.Items += Format-Item 'T' $l.Substring(2, 1) ([Int32]$l.Substring(3, 5)) }
    }
  }
  [pscustomobject]$p
}
function Compare-Items([String[]]$Exp, [String[]]$Got) {
  if ($Exp.Count -ne $Got.Count) { return "item count exp[$($Exp.Count)] parm[$($Got.Count)]" }
  for ($i = 0; $i -lt $Exp.Count; $i++) { if ($Exp[$i] -ne $Got[$i]) { return "item $($i + 1) exp[$($Exp[$i])] parm[$($Got[$i])]" } }
  ''
}
function Invoke-Writer([String]$CardFile, [Switch]$RawFile) {
  $global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'   # case-sensitive, as AMT
  foreach ($raw in [IO.File]::ReadAllLines($CardFile, $enc)) { $r = ConvertTo-AmtSgsCard $raw; if ($r.Card -ne '') { AddTo-SgsList $r.Card } }
  if ($RawFile) { $script:SgsFilePath = $CardFile } else { Remove-Variable SgsFilePath -Scope Script -ErrorAction SilentlyContinue }
  & { Set-StrictMode -Version 2; Get-CondisParmLines }
}

$results = foreach ($c in Import-Csv "$Expanded\$Skeleton-expansion.csv") {
  $card = Join-Path $Cards $c.CardFile
  $verdict = 'NO-PARM'; $note = ''; $model = ''; $sgsPath = ''
  try {
    $lines = [String[]](Invoke-Writer $card -RawFile)
    [IO.File]::WriteAllLines("$Out\parm\$($c.Call).parm", [String[]]$lines, $enc)
    $p = Read-Parm $lines
    $exp = "$Expanded\${Skeleton}__$($c.Call).cob"
    if ($c.Procedure -eq 'True' -and (Test-Path $exp)) {
      $e = Read-Expansion $exp
      $d = @()
      foreach ($k in 'InLen', 'OutLen', 'NCase') { if ("$($e.$k)" -ne "$($p.$k)") { $d += "$k exp[$($e.$k)] parm[$($p.$k)]" } }
      $di = Compare-Items $e.Items $p.Items; if ($di) { $d += $di }
      $verdict = if ($d) { 'DIFF: ' + ($d -join '; ') } else { 'MATCH' }
    } else { $verdict = 'NO-EXPANSION'; $note = 'the per-call expansion fails (' + (($c.Error -replace '\s+', ' ').Substring(0, [Math]::Min(60, ($c.Error -replace '\s+', ' ').Length))) + '...); cards with quoted spaces, T3-028' }
    # reference model: its own parser and item list, from the same cards
    $mc = Read-CondisCards $card
    $mItems = Get-CondisItems $mc; $mi = @(foreach ($x in $mItems) { switch ($x.T) { 'C' { Format-Item 'C' $x.Pos $x.Len $x.Val } 'M' { Format-Item 'M' $x.IP $x.IL $x.OP $x.Code } 'K' { Format-Item 'K' $x.OP $x.Len $x.Val } 'T' { Format-Item 'T' $x.Kind $x.K } } })
    $dm = Compare-Items $mi $p.Items; $model = if ($dm) { "DIFF: $dm" } else { 'MATCH' }
    # the same cards from AMT's label store only (no raw card file)
    try { $l2 = [String[]](Invoke-Writer $card); $sgsPath = if (-not (Compare-Object $lines $l2)) { 'SAME' } else { 'DIFFERENT' } } catch { $sgsPath = 'ERROR: ' + ($_.Exception.Message -replace '\s+', ' ').Substring(0, 60) }
  } catch { if ($_.Exception.Message -like 'ABORT:*') { $verdict = 'REJECTED' }; $note = $_.Exception.Message }
  [pscustomobject]@{ Call = $c.Call; Result = $verdict; Model = $model; SgsPath = $sgsPath; Note = $note }
}
$results | Export-Csv "$Out\crosscheck.csv" -NoTypeInformation -Encoding UTF8
$counts = ($results | Group-Object { ($_.Result -split ':')[0] } | Sort-Object Name | ForEach-Object { "$($_.Name) $($_.Count)" }) -join ', '
'Cross-check parm vs expansion: ' + $counts
'Parm vs reference model:       ' + (($results | Group-Object { ($_.Model -split ':')[0] } | Sort-Object Name | ForEach-Object { "$($_.Name) $($_.Count)" }) -join ', ')
'Parm from raw card file vs AMT label store: ' + (($results | Group-Object { ($_.SgsPath -split ':')[0] } | Sort-Object Name | ForEach-Object { "$($_.Name) $($_.Count)" }) -join ', ')
$results | Where-Object { $_.Result -ne 'MATCH' -or $_.Model -ne 'MATCH' -or $_.SgsPath -ne 'SAME' } | ForEach-Object { '  {0}: {1} | model {2} | sgs-path {3} {4}' -f $_.Call, $_.Result, $_.Model, $_.SgsPath, $_.Note }
