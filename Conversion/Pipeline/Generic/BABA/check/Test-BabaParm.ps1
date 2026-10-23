<#
.SYNOPSIS
  BABA step 2 check (no LionDev): parameter files for all 122 BABA calls from their cards, cross-checked against each
  call's own expansion, plus a PowerShell model of the generic program (spec.md) for later byte-level comparisons.
.DESCRIPTION
  1. Cards -> AMT's own SGS functions -> Get-BabaParmLines (under StrictMode 2, as in the job session) -> parm\<call>.parm.
  2. From <WorkRoot>\allcalls\expanded\BABA_ASCII__<call>.cob, independently: record lengths, file names, key
     layout (REC-IN-1 field positions, COMPARE-1 order), value sets (REQUIREMENTS-n VALUEs), mode (the SEPARATION
     section's branches) and sequence handling (SEQ-COMPARE / SWITCHA). Compare. Writes crosscheck.csv; prints a summary.
#>
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path "$PSScriptRoot\..\..\..\..\..").Path
. "$repo\Conversion\Pipeline\Generic\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$Cards = $ge.SgsCards
$Expanded = "$($ge.WorkRoot)\allcalls\expanded"
$Out = "$($ge.GenericWork)\BABA"
New-Item -ItemType Directory -Force "$Out\parm" | Out-Null
. "$repo\Conversion\Pipeline\SgsCardChecks.ps1"
. "$PSScriptRoot\..\gen\BabaParm.ps1"
$ast = [System.Management.Automation.Language.Parser]::ParseFile("$repo\SsgConverter\Trials\RealRuntime\AmtPsEclLib.psm1", [ref]$null, [ref]$null)
$defs = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
foreach ($name in 'AddTo-SgsList', 'GetSgsValue', 'Get-NextSgsPart', 'IpfSf-Substring', 'CompareTypeSafe') {
  $def = $defs | Where-Object Name -eq $name | Select-Object -First 1
  . ([ScriptBlock]::Create(($def.Extent.Text -replace "^function\s+$([regex]::Escape($name))", "function global:$name")))
}
function global:Add-ErrorMsg { param([String]$Msg) throw "AMT error: $Msg" }
function global:Add-WarningMsg { param([String]$Msg) }

# COBOL alphanumeric literal: '' inside is one quote.
function Read-Literal([String]$s) { if ($s -match "^'(.*)'$") { $Matches[1].Replace("''", "'") } else { $s } }

function Read-Expansion([String]$path) {
  $j = ((Get-Content $path) -join ' ') -replace '\s+', ' '
  $r = [ordered]@{ InName = ''; In = 0; Outs = @(); Mode = 'ALL'; Seq = 'N'; Keys = @(); Sets = @() }
  $r.InName = [regex]::Match($j, 'SELECT TAPEIN1 ASSIGN TO DISC (\S+?)\.').Groups[1].Value
  $r.In = [Int32]('0' + [regex]::Match($j, 'FD TAPEIN1 .*?RECORD CONTAINS (\d+) CHARACTERS').Groups[1].Value)
  foreach ($m in [regex]::Matches($j, 'SELECT TAPEOUT(\d) ASSIGN TO DISC (\S+?)\.')) {
    $len = [regex]::Match($j, "FD TAPEOUT$($m.Groups[1].Value) .*?RECORD CONTAINS (\d+) CHARACTERS").Groups[1].Value
    $r.Outs += , @($m.Groups[2].Value, [Int32]$len)
  }
  # REC-IN-1 layout: walk FILLER / COMPARE-FILE-1-FIELD-k in order to get each key field's position.
  $rec = [regex]::Match($j, '01 REC-IN-1\. (.*?) (FD|WORKING-STORAGE)').Groups[1].Value
  $pos = 1; $fld = @{}
  foreach ($m in [regex]::Matches($rec, '03 (FILLER|COMPARE-FILE-1-FIELD-(\d+)) PIC X\((\d+)\)')) {
    if ($m.Groups[2].Success) { $fld[[Int32]$m.Groups[2].Value] = @($pos, [Int32]$m.Groups[3].Value) }
    $pos += [Int32]$m.Groups[3].Value
  }
  foreach ($k in ($fld.Keys | Sort-Object)) { $r.Keys += , $fld[$k] }
  foreach ($m in [regex]::Matches($j, "01 REQUIREMENTS-(\d+)\. (.*?)(?= 01 )")) {
    $set = ''
    foreach ($f in [regex]::Matches($m.Groups[2].Value, "03 REQ-ALT-\d+-FLD-\d+ PIC X\((\d+)\)(?: VALUE (SPACE|'(?:[^']|'')*'(?:'*)))?")) {
      $len = [Int32]$f.Groups[1].Value
      $v = if (-not $f.Groups[2].Success -or $f.Groups[2].Value -eq 'SPACE') { '' } else { Read-Literal $f.Groups[2].Value }
      $set += (($(if ($v.Length -ge $len) { $v.Substring(0, $len) } else { $v.PadRight($len) })).Replace('<', ';'))
    }
    $r.Sets += $set
  }
  $sep = [regex]::Match($j, 'SEPARATION SECTION\.(.*?)ENDING-ROUTINES SECTION').Groups[1].Value
  if ($sep -match 'GO TO TOTOK') { $r.Mode = 'R' } elseif ($sep -match 'NEXT SENTENCE ELSE GO TO ALFRED') { $r.Mode = 'E' }
  if ($j -match 'SWITCHA') { $r.Seq = 'M' } elseif ($j -match 'SEQ-COMPARE-1 <') { $r.Seq = 'O' }
  [pscustomobject]$r
}

function Read-Parm([String[]]$lines) {
  $p = [ordered]@{ InName = ''; In = 0; Outs = @(); Mode = ''; Seq = ''; Keys = @(); Sets = @() }
  foreach ($l in $lines) {
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

$calls = Import-Csv "$Expanded\BABA_ASCII-expansion.csv"
$results = foreach ($c in $calls) {
  $global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
  $note = ''; $p = $null
  try {
    foreach ($raw in [IO.File]::ReadAllLines((Join-Path $Cards $c.CardFile), [System.Text.Encoding]::GetEncoding(1252))) { $r = ConvertTo-AmtSgsCard $raw; if ($r.Card -ne '') { AddTo-SgsList $r.Card } }
    if (-not $global:SgsLabels.ContainsKey('INPUT')) { throw 'no INPUT card' }
    $lines = & { Set-StrictMode -Version 2; Get-BabaParmLines }
    [IO.File]::WriteAllLines("$Out\parm\$($c.Call).parm", [String[]]$lines, [System.Text.Encoding]::GetEncoding('iso-8859-1'))
    $p = Read-Parm $lines
  } catch { $note = 'parm: ' + $_.Exception.Message }
  $verdict = 'NO-PARM'
  if ($p) {
    $e = Read-Expansion "$Expanded\BABA_ASCII__$($c.Call).cob"
    $d = @()
    if ($e.InName -ne $p.InName -or $e.In -ne $p.In) { $d += "in exp[$($e.InName),$($e.In)] parm[$($p.InName),$($p.In)]" }
    $eo = ($e.Outs | ForEach-Object { $_ -join ',' }) -join ' '; $po = ($p.Outs | ForEach-Object { $_ -join ',' }) -join ' '
    if ($eo -ne $po) { $d += "outs exp[$eo] parm[$po]" }
    if ($e.Mode -ne $p.Mode) { $d += "mode exp[$($e.Mode)] parm[$($p.Mode)]" }
    if ($e.Seq -ne $p.Seq) { $d += "seq exp[$($e.Seq)] parm[$($p.Seq)]" }
    $ek = ($e.Keys | ForEach-Object { $_ -join ',' }) -join ' '; $pk = ($p.Keys | ForEach-Object { $_ -join ',' }) -join ' '
    if ($p.Mode -ne 'ALL' -or $p.Keys.Count -gt 0) { if ($ek -ne $pk) { $d += "keys exp[$ek] parm[$pk]" } }
    # Values only matter where the R/E test is reached (not with MULTI).
    if ($p.Mode -in 'R', 'E' -and $p.Seq -ne 'M') {
      $es = $e.Sets -join '|'; $ps = $p.Sets -join '|'
      if ($es -ne $ps) { $d += "sets exp[$es] parm[$ps]" }
    }
    $verdict = if ($d) { 'DIFF: ' + ($d -join '; ') } else { 'MATCH' }
  }
  [pscustomobject]@{ Call = $c.Call; Mode = $p.Mode; Seq = $p.Seq; Outs = $p.Outs.Count; Keys = $p.Keys.Count; Sets = $p.Sets.Count; Result = $verdict; Note = $note }
}
$results | Export-Csv "$Out\crosscheck.csv" -NoTypeInformation
'Cross-check parm vs expansion: ' + (($results | Group-Object { ($_.Result -split ':')[0] } | ForEach-Object { "$($_.Name) $($_.Count)" }) -join ', ')
$results | Where-Object { $_.Result -ne 'MATCH' } | ForEach-Object { '  {0}: {1} {2}' -f $_.Call, ($_.Result.Substring(0, [Math]::Min(220, $_.Result.Length))), $_.Note }
