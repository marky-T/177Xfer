<#
.SYNOPSIS
  Spike step 2/3 check (no LionDev): parameter files for all CFH-COPY calls from their cards, cross-checked against the
  skeleton's own expansion, and a PowerShell model of the generic program run on the two independent references.
.DESCRIPTION
  1. For every exported CFH-COPY call: cards -> AMT's own SGS functions -> Get-CfhCopyParmLines -> parm\<call>.parm.
  2. Cross-check each parm against <WorkRoot>\allcalls\expanded\CFH-COPY_ASCII__<call>.cob (record lengths,
     every move's in/out position and length, every constant's position, length and text, the STARTREC skip).
  3. Model: the generic program's logic (spec.md) in PowerShell on AFPH12_L427 and VIRM01_CO_L484, byte-compared with the
     independent references. Writes everything under <GenericWork>\CFH-COPY; prints a summary.
#>
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path "$PSScriptRoot\..\..\..\..\..").Path
. "$repo\Conversion\Pipeline\Generic\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$Cards = $ge.SgsCards
$Expanded = "$($ge.WorkRoot)\allcalls\expanded"
$Mock = $ge.MockRoot
$Out = "$($ge.GenericWork)\CFH-COPY"
New-Item -ItemType Directory -Force "$Out\parm", "$Out\model" | Out-Null
. "$repo\Conversion\Pipeline\SgsCardChecks.ps1"
. "$PSScriptRoot\..\gen\CfhCopyParm.ps1"
$ast = [System.Management.Automation.Language.Parser]::ParseFile("$repo\SsgConverter\Trials\RealRuntime\AmtPsEclLib.psm1", [ref]$null, [ref]$null)
$defs = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
foreach ($name in 'AddTo-SgsList', 'GetSgsValue', 'Get-NextSgsPart', 'IpfSf-Substring', 'CompareTypeSafe') {
  $def = $defs | Where-Object Name -eq $name | Select-Object -First 1
  . ([ScriptBlock]::Create(($def.Extent.Text -replace "^function\s+$([regex]::Escape($name))", "function global:$name")))
}
function global:Add-ErrorMsg { param([String]$Msg) throw "AMT error: $Msg" }
function global:Add-WarningMsg { param([String]$Msg) }

function Read-Expansion([String]$path) {
  $t = Get-Content $path
  $j = ($t -join "`n") -replace '\s+', ' '
  $r = [ordered]@{ In = [Int32]([regex]::Match($j, 'RECIN PIC X\((\d+)\)').Groups[1].Value); Out = [Int32]([regex]::Match($j, 'RECOUT PIC X\((\d+)\)').Groups[1].Value); Moves = @(); Fixe = @(); Skip = 0 }
  $zone = @{}; $zono = @{}; $fix = @{}; $fixv = @{}
  foreach ($m in [regex]::Matches($j, '01 REC1(\d+)\. (?:06 FILLER PIC X\((\d+)\)\. )?06 ZONE\1 PIC X\((\d+)\)')) { $s1 = [Int32]('0' + $m.Groups[2].Value) + 1; $zone[[Int32]$m.Groups[1].Value] = @($s1, [Int32]$m.Groups[3].Value) }
  foreach ($m in [regex]::Matches($j, '01 REC2(\d+)\. (?:06 FILLER PIC X\((\d+)\)\. )?06 ZONO\1 PIC X\((\d+)\)')) { $s1 = [Int32]('0' + $m.Groups[2].Value) + 1; $zono[[Int32]$m.Groups[1].Value] = @($s1, [Int32]$m.Groups[3].Value) }
  foreach ($m in [regex]::Matches($j, '01 REC3(\d+)\. (?:06 FILLER PIC X\((\d+)\)\. )?06 FIXDATA\1 PIC X\((\d+)\)')) { $s1 = [Int32]('0' + $m.Groups[2].Value) + 1; $fix[[Int32]$m.Groups[1].Value] = @($s1, [Int32]$m.Groups[3].Value) }
  foreach ($m in [regex]::Matches($j, "06 FIXED(\d+) PIC X\((\d+)\) VALUE '([^']*)'")) { $fixv[[Int32]$m.Groups[1].Value] = $m.Groups[3].Value }
  foreach ($m in [regex]::Matches($j, '06 FIXED(\d+) PIC X\((\d+)\) VALUE (SPACES|ZEROES)\.')) { $fixv[[Int32]$m.Groups[1].Value] = if ($m.Groups[3].Value -eq 'ZEROES') { '0' * [Int32]$m.Groups[2].Value } else { '' } }
  foreach ($m in [regex]::Matches($j, 'MOVE ZONE(\d+) TO ZONO(\d+)')) { $k = [Int32]$m.Groups[1].Value; $r.Moves += , @($zone[$k][0], $zone[$k][1], $zono[$k][0], $zono[$k][1]) }
  foreach ($m in [regex]::Matches($j, 'MOVE FIXED(\d+) TO FIXDATA(\d+)')) { $k = [Int32]$m.Groups[2].Value; $v = [Int32]$m.Groups[1].Value; $txt = "$($fixv[$v])"; $len = $fix[$k][1]; $txt = if ($txt.Length -ge $len) { $txt.Substring(0, $len) } else { $txt.PadRight($len) }; $r.Fixe += , @($fix[$k][0], $len, $txt) }
  $s = [regex]::Match($j, 'IF NB-LUS < (\d+)'); if ($s.Success) { $r.Skip = [Int32]$s.Groups[1].Value }
  $r.Procedure = $j -match 'PROCEDURE DIVISION'
  [pscustomobject]$r
}

function Parse-Parm([String[]]$lines) {
  $p = [ordered]@{ InName = ''; In = 0; OutName = ''; Out = 0; Moves = @(); Fixe = @(); Skip = 0 }
  foreach ($l in $lines) {
    switch ($l.Substring(0, 2)) {
      'IN' { $p.InName = $l.Substring(2, 30).Trim(); $p.In = [Int32]$l.Substring(32, 5) }
      'OU' { $p.OutName = $l.Substring(2, 30).Trim(); $p.Out = [Int32]$l.Substring(32, 5) }
      'MV' { $p.Moves += , @([Int32]$l.Substring(2, 5), [Int32]$l.Substring(7, 5), [Int32]$l.Substring(12, 5), [Int32]$l.Substring(17, 5)) }
      'FX' { $len = [Int32]$l.Substring(7, 5); $p.Fixe += , @([Int32]$l.Substring(2, 5), $len, $l.Substring(12, $len)) }
      'SK' { $p.Skip = [Int32]$l.Substring(2, 5) }
    }
  }
  [pscustomobject]$p
}

function Set-Slice([char[]]$buf, [Int32]$start1, [Int32]$len, [String]$src) {
  $s = if ($src.Length -ge $len) { $src.Substring(0, $len) } else { $src.PadRight($len) }
  for ($i = 0; $i -lt $len; $i++) { $buf[$start1 - 1 + $i] = $s[$i] }
}

# The generic program's logic (spec.md), as a model to run before the real build.
function Invoke-CfhModel($p, [String]$inFile, [String]$outFile) {
  $latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
  $text = $latin1.GetString([IO.File]::ReadAllBytes($inFile))
  $recs = $text -split "`r`n"; if ($recs[-1] -eq '') { $recs = $recs[0..($recs.Count - 2)] }
  $sb = [System.Text.StringBuilder]::new(); $n = 0
  foreach ($rec in $recs) {
    $win = ($(if ($rec.Length -gt $p.In) { $rec.Substring(0, $p.In) } else { $rec })).PadRight(4000)
    $wout = (' ' * 4000).ToCharArray()
    if ($p.Moves.Count -eq 0) { Set-Slice $wout 1 $p.Out $win.Substring(0, $p.In) }
    foreach ($m in $p.Moves) { Set-Slice $wout $m[2] $m[3] $win.Substring($m[0] - 1, $m[1]) }
    foreach ($f in $p.Fixe) { Set-Slice $wout $f[0] $f[1] $f[2].Replace('<', ';') }
    $n++
    if ($n -lt $p.Skip) { continue }
    [void]$sb.Append((-join $wout[0..($p.Out - 1)])).Append("`r`n")
  }
  [IO.File]::WriteAllBytes($outFile, $latin1.GetBytes($sb.ToString()))
}

$calls = Import-Csv "$Cards\sgs-calls.csv" | Where-Object ProgramKey -eq 'CFH-COPY_ASCII'
$results = foreach ($c in $calls) {
  $id = ($c.CardFile -replace '^calls\\ASSURFED_F999RUN_?', '' -replace '\.sgs$', '' -replace '__', '_')
  $exp = Get-ChildItem $Expanded -Filter "CFH-COPY_ASCII__*.cob" | Where-Object { $_.BaseName.EndsWith('_' + ($c.CardFile -replace '.*__(L\d+)\.sgs$', '$1')) -and $_.BaseName -match [regex]::Escape(($c.CardFile -replace '^calls\\ASSURFED_F999RUN-?d?_?', '' -replace '__L\d+\.sgs$', '')) } | Select-Object -First 1
  $global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
  $note = ''
  try {
    foreach ($raw in [IO.File]::ReadAllLines((Join-Path $Cards $c.CardFile), [System.Text.Encoding]::GetEncoding(1252))) { $r = ConvertTo-AmtSgsCard $raw; if ($r.Card -ne '') { AddTo-SgsList $r.Card } }
    $SgsFilePath = Join-Path $Cards $c.CardFile
    # AmtPsEclLib runs the job session under StrictMode 2; the hand-off must too.
    $lines = & { Set-StrictMode -Version 2; Get-CfhCopyParmLines }
    [IO.File]::WriteAllLines("$Out\parm\$id.parm", [String[]]$lines, [System.Text.Encoding]::GetEncoding('iso-8859-1'))
    $p = Parse-Parm $lines
  } catch { $p = $null; $note = 'parm: ' + $_.Exception.Message }
  $verdict = 'NO-EXPANSION'
  if ($p -and $exp) {
    $e = Read-Expansion $exp.FullName
    if (-not $e.Procedure) { $verdict = 'EXPANSION-INCOMPLETE' }
    else {
      $diff = @()
      if ($e.In -ne $p.In) { $diff += "in $($e.In)/$($p.In)" }
      if ($e.Out -ne $p.Out) { $diff += "out $($e.Out)/$($p.Out)" }
      $em = ($e.Moves | ForEach-Object { $_ -join ',' }) -join ' '; $pm = ($p.Moves | ForEach-Object { $_ -join ',' }) -join ' '
      $ef = ($e.Fixe | ForEach-Object { $_ -join ',' }) -join ' '; $pf = ($p.Fixe | ForEach-Object { $_ -join ',' }) -join ' '
      if ($em -ne $pm) { $diff += "moves exp[$em] parm[$pm]" }
      if ($ef -ne $pf) { $diff += "fixe exp[$ef] parm[$pf]" }
      if ($e.Skip -ne $p.Skip) { $diff += "skip $($e.Skip)/$($p.Skip)" }
      $verdict = if ($diff) { 'DIFF: ' + ($diff -join '; ') } else { 'MATCH' }
    }
  }
  [pscustomobject]@{ Call = $id; Expansion = $exp.Name; Moves = $p.Moves.Count; Fixe = $p.Fixe.Count; Skip = $p.Skip; Result = $verdict; Note = $note }
}
$results | Export-Csv "$Out\crosscheck.csv" -NoTypeInformation
'Cross-check parm vs expansion: ' + (($results | Group-Object { ($_.Result -split ':')[0] } | ForEach-Object { "$($_.Name) $($_.Count)" }) -join ', ')
$results | Where-Object { $_.Result -notin 'MATCH', 'EXPANSION-INCOMPLETE' } | ForEach-Object { '  {0}: {1} {2}' -f $_.Call, $_.Result, $_.Note }

foreach ($t in @(
    @{ Call = 'AFPH12_L427'; In = "$Mock\AFPH12_L427\input\INASC"; Exp = "$Mock\AFPH12_L427\expected\OUTASC" },
    @{ Call = 'VIRM01_CO_L484'; In = "$Mock\VIRM01\input\INB"; Exp = "$Mock\VIRM01\expected\INC" })) {
  $p = Parse-Parm (Get-Content "$Out\parm\$($t.Call).parm")
  $o = "$Out\model\$($t.Call).out"
  Invoke-CfhModel $p $t.In $o
  $a = [IO.File]::ReadAllBytes($o); $b = [IO.File]::ReadAllBytes($t.Exp)
  'Model {0}: {1} B vs reference {2} B -> {3}' -f $t.Call, $a.Length, $b.Length, $(if ([System.Linq.Enumerable]::SequenceEqual([byte[]]$a, [byte[]]$b)) { 'PASS' } else { 'FAIL' })
}
