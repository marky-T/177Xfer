<#
.SYNOPSIS
  CONDIS2 step G7 (extra): the parameter writer on every test case (TEST DATA): items must equal the reference model's item list
  (cases\<name>\expected\items.txt); the cases the skeleton's own checks reject (result ABORT Vn) must make the hand-off Abort with that check.
  Writes <Out>\cases-check.csv.
#>
param(
  [String]$Repo = 'E:\Repos\SsgTrial',
  [String]$Cases = "$PSScriptRoot\cases",
  [String]$Out = 'E:\Repos\ssg4-work\redo\CONDIS2-261105_sonnet\evidence'
)
$ErrorActionPreference = 'Stop'
$enc = [Text.Encoding]::GetEncoding(1252)
. "$Repo\Conversion\Pipeline\SgsCardChecks.ps1"
. "$Repo\Conversion\Pipeline\Generic\GnHandoff.ps1"
. "$PSScriptRoot\..\gen\CondisParm.ps1"
$ast = [System.Management.Automation.Language.Parser]::ParseFile("$Repo\SsgConverter\Trials\RealRuntime\AmtPsEclLib.psm1", [ref]$null, [ref]$null)
$defs = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
foreach ($name in 'AddTo-SgsList', 'GetSgsValue', 'Get-NextSgsPart', 'IpfSf-Substring', 'CompareTypeSafe') {
  $def = $defs | Where-Object Name -eq $name | Select-Object -First 1
  . ([ScriptBlock]::Create(($def.Extent.Text -replace "^function\s+$([regex]::Escape($name))", "function global:$name")))
}
function global:Add-ErrorMsg { param([String]$Msg) throw "AMT error: $Msg" }
function global:Add-WarningMsg { param([String]$Msg) }
function global:Abort { param([String]$Msg) throw "ABORT: $Msg" }
function Norm([String]$s) { $s -replace '\s+\]$', ']' }
function Read-ParmItems([String[]]$Lines) {
  foreach ($l in $Lines) {
    switch ($l.Substring(0, 2)) {
      'CD' { Norm ('C {0} {1} [{2}]' -f [Int32]$l.Substring(2, 5), [Int32]$l.Substring(7, 5), $l.Substring(12, 200)) }
      'MV' { 'M {0} {1} {2} [{3}]' -f [Int32]$l.Substring(2, 5), [Int32]$l.Substring(7, 5), [Int32]$l.Substring(12, 5), $l.Substring(17, 4).Trim() }
      'KT' { Norm ('K {0} {1} [{2}]' -f [Int32]$l.Substring(2, 5), [Int32]$l.Substring(7, 5), $l.Substring(12, 200)) }
      'TL' { 'T {0} {1}' -f $l.Substring(2, 1), [Int32]$l.Substring(3, 5) }
    }
  }
}

$rows = foreach ($dir in Get-ChildItem $Cases -Directory | Sort-Object Name) {
  $card = "$($dir.FullName)\cards.sgs"
  $res = (Get-Content "$($dir.FullName)\expected\result.txt" -Encoding 1252 -TotalCount 1).Trim()
  $global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
  foreach ($raw in [IO.File]::ReadAllLines($card, $enc)) { $r = ConvertTo-AmtSgsCard $raw; if ($r.Card -ne '') { AddTo-SgsList $r.Card } }
  $script:SgsFilePath = $card
  $verdict = ''; $note = ''
  try {
    $lines = [String[]](& { Set-StrictMode -Version 2; Get-CondisParmLines })
    if ($res -ne 'OK') { $verdict = 'FAIL: model says ' + $res + ' but the hand-off built lines' }
    else {
      $exp = @(Get-Content "$($dir.FullName)\expected\items.txt" -Encoding 1252 | ForEach-Object { Norm $_ })
      $got = @(Read-ParmItems $lines)
      $d = ''
      if ($exp.Count -ne $got.Count) { $d = "item count exp[$($exp.Count)] parm[$($got.Count)]" }
      else { for ($i = 0; $i -lt $exp.Count; $i++) { if ($exp[$i] -ne $got[$i]) { $d = "item $($i + 1) exp[$($exp[$i])] parm[$($got[$i])]"; break } } }
      $verdict = if ($d) { "FAIL: $d" } else { 'MATCH' }
    }
  } catch {
    $msg = $_.Exception.Message
    if ($res -like 'ABORT*') {
      $codes = ($res -split ' ')[1..9]
      $hit = $codes | Where-Object { $_ -and $msg -match "skeleton check $_\)" }
      $verdict = if ($hit) { 'REJECTED-AS-EXPECTED' } else { "FAIL: aborted without any of [$($codes -join ' ')]" }
    } else { $verdict = 'FAIL: unexpected ' + $msg }
    $note = $msg
  }
  [pscustomobject]@{ Case = $dir.Name; Model = $res; Result = $verdict; Note = $note }
}
$rows | Export-Csv "$Out\cases-check.csv" -NoTypeInformation -Encoding UTF8
'Writer vs model on cases (TEST DATA): ' + (($rows | Group-Object { ($_.Result -split ':')[0] } | Sort-Object Name | ForEach-Object { "$($_.Name) $($_.Count)" }) -join ', ')
$rows | Where-Object { $_.Result -notin 'MATCH', 'REJECTED-AS-EXPECTED' } | ForEach-Object { '  {0}: {1}' -f $_.Case, $_.Result }
