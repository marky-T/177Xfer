# MT-053 review: the existing (rc.02) CONDIS2 writer + model run on the Sonnet blind run's 34 cases.
# For each case: cards -> AMT SGS store (isolated AmtPsEclLib functions) -> existing Get-CondisParmLines -> existing model,
# then compare with Sonnet's expected output (its independent model). Writes old-on-sonnet.csv next to this script.
param([String]$Cases = 'E:\Repos\ssg4-work\redo\CONDIS2-261105_sonnet\generic\check\cases',
  [String]$Work = "$PSScriptRoot\old-on-sonnet")
$ErrorActionPreference = 'Stop'
$repo = 'E:\Repos\SsgTrial'
$latin1 = [Text.Encoding]::GetEncoding('iso-8859-1')
. "$repo\Conversion\Pipeline\SgsCardChecks.ps1"
. "$repo\Conversion\Pipeline\Generic\GnHandoff.ps1"
. "$repo\Conversion\Pipeline\Generic\CONDIS2\gen\CondisParm.ps1"
. "$repo\Conversion\Pipeline\Generic\CONDIS2\check\CondisModel.ps1"
$ast = [System.Management.Automation.Language.Parser]::ParseFile("$repo\SsgConverter\Trials\RealRuntime\AmtPsEclLib.psm1", [ref]$null, [ref]$null)
$defs = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
foreach ($name in 'AddTo-SgsList', 'GetSgsValue', 'Get-NextSgsPart', 'IpfSf-Substring', 'CompareTypeSafe') {
  $def = $defs | Where-Object Name -eq $name | Select-Object -First 1
  . ([ScriptBlock]::Create(($def.Extent.Text -replace "^function\s+$([regex]::Escape($name))", "function global:$name")))
}
function global:Add-ErrorMsg { param([String]$Msg) throw "AMT error: $Msg" }
function global:Add-WarningMsg { param([String]$Msg) }
function global:Abort { param([String]$Msg) throw "ABORT: $Msg" }
if (Test-Path $Work) { Remove-Item $Work -Recurse -Force }
New-Item -ItemType Directory -Force $Work | Out-Null

$rows = foreach ($d in Get-ChildItem $Cases -Directory | Sort-Object Name) {
  $case = $d.Name
  $cls = (Get-Content "$($d.FullName)\case.json" -Raw | ConvertFrom-Json).expectedClass
  $sonnet = (Get-Content "$($d.FullName)\expected\result.txt" -TotalCount 1)
  $global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
  $cardFile = "$($d.FullName)\cards.sgs"
  $old = ''; $note = ''; $same = ''
  try {
    foreach ($raw in [IO.File]::ReadAllLines($cardFile, $latin1)) { $r = ConvertTo-AmtSgsCard $raw; if ($r.Card -ne '') { try { AddTo-SgsList $r.Card } catch { $note = 'AddTo-SgsList: ' + $_.Exception.Message } } }
    $SgsFilePath = $cardFile
    $lines = & { Set-StrictMode -Version 2; Get-CondisParmLines }
    $p = Read-CondisParm $lines
    $out = "$Work\$case.out"
    Invoke-CondisModel $p "$($d.FullName)\input.dat" $out | Out-Null
    $old = 'OK'
    if (Test-Path "$($d.FullName)\expected\output.dat") {
      $same = ((Get-FileHash $out).Hash -eq (Get-FileHash "$($d.FullName)\expected\output.dat").Hash)
      if (-not $same) {
        $a = [IO.File]::ReadAllBytes($out); $b = [IO.File]::ReadAllBytes("$($d.FullName)\expected\output.dat")
        $i = 0; while ($i -lt [Math]::Min($a.Length, $b.Length) -and $a[$i] -eq $b[$i]) { $i++ }
        $note = "old $($a.Length) bytes, sonnet $($b.Length); first difference at byte $i"
      }
    }
  } catch { $old = 'REJECTED'; $note = $_.Exception.Message }
  [pscustomobject]@{ Case = $case; Class = $cls; Sonnet = $sonnet; Old = $old; OutputSame = $same; Note = $note }
}
$rows | Export-Csv "$PSScriptRoot\old-on-sonnet.csv" -NoTypeInformation
$rows
