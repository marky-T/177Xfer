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
function global:Add-ErrorMsg { param([String]$Msg) "AMT Add-ErrorMsg: $Msg" }
function global:Add-WarningMsg { param([String]$Msg) "AMT Add-WarningMsg: $Msg" }
$global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
foreach ($raw in [IO.File]::ReadAllLines("$($ge.SgsCards)\calls\ASSURFED_F999RUN_PBDA04__L339.sgs")) {
  try { AddTo-SgsList $raw; "ok   [$raw]" } catch { "FAIL [$raw]: $($_.Exception.Message)" }
}
'labels: ' + ($global:SgsLabels.Keys -join ', ')
