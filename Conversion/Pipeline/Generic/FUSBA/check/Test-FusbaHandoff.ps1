# Dry run of Invoke-FusbaHandoff under StrictMode 2 with AMT's job functions stubbed (Asg/Use/task object/Msg),
# on the cards of a C case and an M case: catches PowerShell errors before a CC run.
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path "$PSScriptRoot\..\..\..\..\..").Path
. "$repo\Conversion\Pipeline\Generic\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
. "$repo\Conversion\Pipeline\SgsCardChecks.ps1"
$ast = [System.Management.Automation.Language.Parser]::ParseFile("$repo\SsgConverter\Trials\RealRuntime\AmtPsEclLib.psm1", [ref]$null, [ref]$null)
$defs = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
foreach ($name in 'AddTo-SgsList', 'GetSgsValue', 'Get-NextSgsPart', 'IpfSf-Substring', 'CompareTypeSafe') {
  $def = $defs | Where-Object Name -eq $name | Select-Object -First 1
  . ([ScriptBlock]::Create(($def.Extent.Text -replace "^function\s+$([regex]::Escape($name))", "function global:$name")))
}
function global:Add-ErrorMsg { param([String]$Msg) throw "AMT error: $Msg" }
function global:Add-WarningMsg { param([String]$Msg) }
$global:log = New-Object System.Collections.Generic.List[String]
function global:Asg { param($o, $n) $global:log.Add("Asg $o $n") }
function global:Free { param($o, $n) $global:log.Add("Free $n") }
function global:Use { param($u, $n) $global:log.Add("Use $u $n") }
function global:Msg { param($o, $t) $global:log.Add("Msg $t") }
function global:Get-TaskObject { param($x) [pscustomobject]@{} | Add-Member -MemberType ScriptMethod -Name SetTVCustom -Value { param($k, $v) $global:log.Add("TV $k=$v") } -PassThru }
function global:Check-ClearTaskObject { param($TaskObj) }
. "$repo\Conversion\Pipeline\Generic\GnHandoff.ps1"
function global:Add-GnUseAlias { param($f, $c) $global:log.Add("Alias $f=$c") }
. "$PSScriptRoot\..\gen\FusbaParm.ps1"
$tmp = Join-Path $env:TEMP 'fusba-dry'; New-Item -ItemType Directory -Force "$tmp\Q" | Out-Null
$global:AmtPath = [pscustomobject]@{ ExtractPath = $tmp }; $global:DefaultQual = 'Q'
# the entries Deploy-GnScriptSet writes into AmtSettings.xml (MT-044)
$global:CloneReports = @([pscustomobject]@{ Name = 'ASSURFED_UTILIT_FUSBA_GN'; Clone = 'FUSBA' })
foreach ($c in @(@('C1', 'calls\ASSURFED_F999RUN_COMA16_U1__L113.sgs', 'FUSBA'), @('M1', 'calls\ASSURFED_F999RUN-d_VIRD03__L766.sgs', 'FUSBA2'))) {
  $global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
  foreach ($raw in [IO.File]::ReadAllLines("$($ge.SgsCards)\$($c[1])", [System.Text.Encoding]::GetEncoding(1252))) { $r = ConvertTo-AmtSgsCard $raw; if ($r.Card -ne '') { AddTo-SgsList $r.Card } }
  $global:log.Clear()
  & { Set-StrictMode -Version 2; Invoke-FusbaHandoff -Variant $c[2] }
  "== $($c[0]) ($($c[2]))"
  $global:log | ForEach-Object { "  $_" }
  Get-Content "$tmp\Q\FUSPARM" | ForEach-Object { "  | $($_.TrimEnd()) ($($_.Length))" }
  "  CloneReports: " + (($global:CloneReports | ForEach-Object { "$($_.Clone)->$($_.Name)" }) -join ', ')
}
