<#
.SYNOPSIS
  FUSBA step 2 check (no LionDev): parameter files for all 36 FUSBA/FUSBA2 calls from their cards, cross-checked
  against each call's own expansion.
.DESCRIPTION
  1. Cards -> AMT's own SGS functions -> Get-FusbaParmLines (StrictMode 2, as in the job session) -> parm\<call>.parm.
  2. From <WorkRoot>\allcalls\expanded\<skeleton>__<call>.cob, independently: file names and record lengths,
     key layout of REC-IN-1 / REC-IN-2 (field positions, COMPARE-n order), field moves (REC-IN-1-1 ZONEn and
     REC-OUT-11 ZONOn positions), mode (the match branch). Compare. Writes crosscheck.csv; prints a summary.
#>
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path "$PSScriptRoot\..\..\..\..\..").Path
. "$repo\Conversion\Pipeline\Generic\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$Cards = $ge.SgsCards
$Expanded = "$($ge.WorkRoot)\allcalls\expanded"
$Out = "$($ge.GenericWork)\FUSBA"
New-Item -ItemType Directory -Force "$Out\parm" | Out-Null
. "$repo\Conversion\Pipeline\SgsCardChecks.ps1"
. "$PSScriptRoot\..\gen\FusbaParm.ps1"
$ast = [System.Management.Automation.Language.Parser]::ParseFile("$repo\SsgConverter\Trials\RealRuntime\AmtPsEclLib.psm1", [ref]$null, [ref]$null)
$defs = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
foreach ($name in 'AddTo-SgsList', 'GetSgsValue', 'Get-NextSgsPart', 'IpfSf-Substring', 'CompareTypeSafe') {
  $def = $defs | Where-Object Name -eq $name | Select-Object -First 1
  . ([ScriptBlock]::Create(($def.Extent.Text -replace "^function\s+$([regex]::Escape($name))", "function global:$name")))
}
function global:Add-ErrorMsg { param([String]$Msg) throw "AMT error: $Msg" }
function global:Add-WarningMsg { param([String]$Msg) }

# Walk a record layout (level-03 or level-06 items) and return @{ name = @(pos, len) } for the named items.
function Get-Layout([String]$rec, [String]$level, [String]$pattern) {
  $pos = 1; $fld = @{}
  foreach ($m in [regex]::Matches($rec, "$level (FILLER|$pattern) PIC X\((\d+)\)")) {
    if ($m.Groups[2].Success) { $fld[[Int32]$m.Groups[2].Value] = @($pos, [Int32]$m.Groups[3].Value) }
    $pos += [Int32]$m.Groups[3].Value
  }
  return , @($fld.Keys | Sort-Object | ForEach-Object { , $fld[$_] })
}

function Read-Expansion([String]$path, [String]$variant) {
  $j = ((Get-Content $path) -join ' ') -replace '\s+', ' '
  $r = [ordered]@{ Ins = @(); Outs = @(); Mode = ''; K1 = @(); K2 = @(); FM = @() }
  foreach ($k in 1, 2) {
    $n = [regex]::Match($j, "SELECT TAPEIN$k ASSIGN TO DISC (\S+?)\.").Groups[1].Value
    $len = [regex]::Match($j, "FD TAPEIN$k .*?RECORD CONTAINS (\d+) CHARACTERS").Groups[1].Value
    $r.Ins += , @($n, [Int32]$len)
  }
  foreach ($m in [regex]::Matches($j, 'SELECT TAPEOUT(\d) ASSIGN TO DISC (\S+?)\.')) {
    $len = [regex]::Match($j, "FD TAPEOUT$($m.Groups[1].Value) .*?RECORD CONTAINS (\d+) CHARACTERS").Groups[1].Value
    $r.Outs += , @($m.Groups[2].Value, [Int32]$len)
  }
  $r.K1 = Get-Layout ([regex]::Match($j, '01 REC-IN-1\. (.*?) 01 ').Groups[1].Value) '03' 'COMPARE-FILE-1-FIELD-(\d+)'
  $r.K2 = Get-Layout ([regex]::Match($j, '01 REC-IN-2\. (.*?) (FD|01|WORKING-STORAGE) ').Groups[1].Value) '03' 'COMPARE-FILE-2-FIELD-(\d+)'
  # One 01 redefinition per field: 01 REC-IN-1-n. [06 FILLER PIC X(a).] 06 ZONEn PIC X(b).  (same for REC-OUT-1n / ZONOn)
  $zi = @{}; $zo = @{}
  foreach ($m in [regex]::Matches($j, '01 REC-IN-1-\d+\. (?:06 FILLER PIC X\((\d+)\)\. )?06 ZONE(\d+) PIC X\((\d+)\)')) {
    $zi[[Int32]$m.Groups[2].Value] = @((1 + [Int32]('0' + $m.Groups[1].Value)), [Int32]$m.Groups[3].Value) }
  foreach ($m in [regex]::Matches($j, '01 REC-OUT-1\d+\. (?:06 FILLER PIC X\((\d+)\)\. )?06 ZONO(\d+) PIC X\((\d+)\)')) {
    $zo[[Int32]$m.Groups[2].Value] = @((1 + [Int32]('0' + $m.Groups[1].Value)), [Int32]$m.Groups[3].Value) }
  # Moves of the (first) match branch, in order (FUSBA2 has no FIELD1 label: its single branch).
  $seg = [regex]::Match($j, 'FIELD1\. (.*?) WRITE REC-OUT-1\.').Groups[1].Value
  if (-not $seg) { $seg = [regex]::Match($j, 'MOVE REC-IN-2 TO REC-OUT-1\. (.*?) PERFORM WRITE-FROM-FILE').Groups[1].Value }
  $moves = @([regex]::Matches($seg, 'MOVE ZONE(\d+) TO ZONO(\d+)') | ForEach-Object { [Int32]$_.Groups[1].Value })
  foreach ($i in $moves) { $r.FM += , @($zi[$i][0], $zi[$i][1], $zo[$i][0], $zo[$i][1]) }
  $r.Mode = if ($variant -eq 'FUSBA2') { 'M' }
  elseif ($j -match 'WRITE REC-OUT-2 FROM REC-IN-2') { 'C' }
  elseif ($j -match "IF SWITCHA = '=' MOVE ' ' TO SWITCHA GO TO READ-FILE-2") { 'U' }
  elseif ($j -match "IF SWITCHA = '=' GO TO READ-FILE-2") { 'D' }
  else { '?' }
  [pscustomobject]$r
}

function Read-Parm([String[]]$lines) {
  $p = [ordered]@{ Ins = @(); Outs = @(); Mode = ''; K1 = @(); K2 = @(); FM = @() }
  foreach ($l in $lines) {
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

function Show([Object[]]$a) { ($a | ForEach-Object { $_ -join ',' }) -join ' ' }

$results = foreach ($sk in 'FUSBA_ASCII', 'FUSBA2_ASCII') {
  $variant = $sk -replace '_ASCII$'
  foreach ($c in Import-Csv "$Expanded\$sk-expansion.csv") {
    $global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
    $note = ''; $p = $null
    try {
      foreach ($raw in [IO.File]::ReadAllLines((Join-Path $Cards $c.CardFile), [System.Text.Encoding]::GetEncoding(1252))) { $r = ConvertTo-AmtSgsCard $raw; if ($r.Card -ne '') { AddTo-SgsList $r.Card } }
      $lines = & { Set-StrictMode -Version 2; Get-FusbaParmLines -Variant $variant }
      [IO.File]::WriteAllLines("$Out\parm\$variant`_$($c.Call).parm", [String[]]$lines, [System.Text.Encoding]::GetEncoding('iso-8859-1'))
      $p = Read-Parm $lines
    } catch { $note = 'parm: ' + $_.Exception.Message }
    $verdict = 'NO-PARM'
    if ($p) {
      $e = Read-Expansion "$Expanded\$sk`__$($c.Call).cob" $variant
      $d = @()
      foreach ($k in 'Ins', 'Outs', 'K1', 'K2', 'FM') {
        $es = Show $e.$k; $ps = Show $p.$k
        if ($es -ne $ps) { $d += "$k exp[$es] parm[$ps]" }
      }
      if ($e.Mode -ne $p.Mode) { $d += "mode exp[$($e.Mode)] parm[$($p.Mode)]" }
      $verdict = if ($d) { 'DIFF: ' + ($d -join '; ') } else { 'MATCH' }
    }
    [pscustomobject]@{ Skeleton = $variant; Call = $c.Call; Mode = $p.Mode; Outs = $p.Outs.Count; K1 = $p.K1.Count; FM = $p.FM.Count; Result = $verdict; Note = $note }
  }
}
$results | Export-Csv "$Out\crosscheck.csv" -NoTypeInformation
'Cross-check parm vs expansion: ' + (($results | Group-Object { ($_.Result -split ':')[0] } | ForEach-Object { "$($_.Name) $($_.Count)" }) -join ', ')
'By mode: ' + (($results | Group-Object Mode | ForEach-Object { "$($_.Name) $($_.Count)" }) -join ', ')
$results | Where-Object { $_.Result -ne 'MATCH' } | ForEach-Object { '  {0}: {1} {2}' -f $_.Call, ($_.Result.Substring(0, [Math]::Min(260, $_.Result.Length))), $_.Note }
