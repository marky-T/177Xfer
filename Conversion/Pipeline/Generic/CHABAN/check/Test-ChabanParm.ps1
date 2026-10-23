<#
.SYNOPSIS
  CHABAN step 2 check: parameter files for all 31 CHABAN/CHAB100 calls from their cards (AMT's SGS functions, StrictMode 2),
  cross-checked against each call's own expansion: card length (ZIN), output name and length (FIC/ZFIC), records
  (PAR1 present; NBFOIS + 1) and cards per record (READ CAR statements in PAR1). Writes parm\, crosscheck.csv.
#>
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path "$PSScriptRoot\..\..\..\..\..").Path
. "$repo\Conversion\Pipeline\Generic\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$Cards = $ge.SgsCards
$Expanded = "$($ge.WorkRoot)\allcalls\expanded"
$Out = "$($ge.GenericWork)\CHABAN"
New-Item -ItemType Directory -Force "$Out\parm" | Out-Null
. "$repo\Conversion\Pipeline\SgsCardChecks.ps1"
. "$PSScriptRoot\..\gen\ChabanParm.ps1"
$ast = [System.Management.Automation.Language.Parser]::ParseFile("$repo\SsgConverter\Trials\RealRuntime\AmtPsEclLib.psm1", [ref]$null, [ref]$null)
$defs = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
foreach ($name in 'AddTo-SgsList', 'GetSgsValue', 'Get-NextSgsPart', 'IpfSf-Substring', 'CompareTypeSafe') {
  $def = $defs | Where-Object Name -eq $name | Select-Object -First 1
  . ([ScriptBlock]::Create(($def.Extent.Text -replace "^function\s+$([regex]::Escape($name))", "function global:$name")))
}
function global:Add-ErrorMsg { param([String]$Msg) throw "AMT error: $Msg" }
function global:Add-WarningMsg { param([String]$Msg) }

function Read-Expansion([String]$path) {
  $t = Get-Content $path | Where-Object { $_.Trim() } | ForEach-Object { ($_ -replace '\s+', ' ').Trim() }
  $j = $t -join ' '
  $pd = [Array]::IndexOf($t, 'PROCEDURE DIVISION.'); $st = [Array]::IndexOf($t, 'STATIS.')
  $proc = ($t[$pd..$st] -join ' ')
  $par = [regex]::Match($proc, 'PAR1\. (.*?) PERFORM ECRIOUT').Groups[1].Value
  $records = 0
  if ($proc -match 'PAR1\.') { $m = [regex]::Match($proc, 'MOVE (\d+) TO NBFOIS'); $records = if ($m.Success) { [Int32]$m.Groups[1].Value + 1 } else { 1 } }
  [pscustomobject]@{
    Card = [Int32][regex]::Match($j, '01 ZIN PIC X\((\d+)\)').Groups[1].Value
    OutName = [regex]::Match($j, 'SELECT FIC ASSIGN TO DISC (\S+?)\.').Groups[1].Value
    Len = [Int32][regex]::Match($j, '01 ZFIC PIC X\((\d+)\)').Groups[1].Value
    Records = $records
    PerRecord = if ($records) { [regex]::Matches($par, 'READ CAR INTO').Count } else { 0 }
  }
}

$results = foreach ($sk in 'CHABAN_ASCII', 'CHAB100_ASCII') {
  $variant = $sk -replace '_ASCII$'
  foreach ($c in Import-Csv "$Expanded\$sk-expansion.csv") {
    $global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
    $note = ''; $p = $null
    try {
      foreach ($raw in [IO.File]::ReadAllLines((Join-Path $Cards $c.CardFile), [System.Text.Encoding]::GetEncoding(1252))) { $r = ConvertTo-AmtSgsCard $raw; if ($r.Card -ne '') { AddTo-SgsList $r.Card } }
      $lines = & { Set-StrictMode -Version 2; Get-ChabanParmLines -Variant $variant }
      [IO.File]::WriteAllLines("$Out\parm\$variant`_$($c.Call).parm", [String[]]$lines, [System.Text.Encoding]::GetEncoding('iso-8859-1'))
      $p = [pscustomobject]@{ Card = [Int32]$lines[0].Substring(32, 5); OutName = $lines[1].Substring(2, 30).Trim(); Len = [Int32]$lines[1].Substring(32, 5); Records = [Int32]$lines[2].Substring(2, 5); PerRecord = [Int32]$lines[2].Substring(7, 5) }
    } catch { $note = 'parm: ' + $_.Exception.Message }
    $verdict = 'NO-PARM'
    if ($p) {
      $e = Read-Expansion "$Expanded\$sk`__$($c.Call).cob"
      $d = foreach ($k in 'Card', 'OutName', 'Len', 'Records') { if ("$($e.$k)" -ne "$($p.$k)") { "$k exp[$($e.$k)] parm[$($p.$k)]" } }
      if ($e.Records -and $e.PerRecord -ne $p.PerRecord) { $d += "PerRecord exp[$($e.PerRecord)] parm[$($p.PerRecord)]" }
      $verdict = if ($d) { 'DIFF: ' + ($d -join '; ') } else { 'MATCH' }
    }
    [pscustomobject]@{ Skeleton = $variant; Call = $c.Call; Records = $p.Records; PerRecord = $p.PerRecord; Len = $p.Len; Result = $verdict; Note = $note }
  }
}
$results | Export-Csv "$Out\crosscheck.csv" -NoTypeInformation
'Cross-check parm vs expansion: ' + (($results | Group-Object { ($_.Result -split ':')[0] } | ForEach-Object { "$($_.Name) $($_.Count)" }) -join ', ')
'By records/cards-per-record: ' + (($results | Group-Object { "$($_.Records)x$($_.PerRecord)" } | ForEach-Object { "$($_.Name) $($_.Count)" }) -join ', ')
$results | Where-Object { $_.Result -ne 'MATCH' } | ForEach-Object { '  {0}: {1} {2}' -f $_.Call, $_.Result, $_.Note }
