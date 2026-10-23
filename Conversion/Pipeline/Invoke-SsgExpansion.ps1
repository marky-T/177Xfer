<#
.SYNOPSIS
  SSG-4 pipeline step: expand a converted SSG skeleton with real SGS cards, using AMT's own SGS code.
.DESCRIPTION
  Runs SsgConverter output (Examples/Output/<Program>.ps1) the way Invoke-Ssg does: the cards are
  loaded line by line with AMT's real AddTo-SgsList and read back with AMT's real GetSgsValue,
  CompareTypeSafe, RemoveFrom-SgsList and Sort-SgsList, taken unchanged from the isolated
  AmtPsEclLib.psm1 copy. Only the output and job primitives (DataLineOrNoStatement, Fin, ...) come
  from the Tier-1 mock, so no AMT application, database or COM is needed.

  Unlike the Tier-1 harness (flat sgs-values.json lookups), this exercises AMT's card parsing and
  lookup rules, which Tier-1 cannot see (MT-020).

  Writes the expanded COBOL text to -OutFile and returns a summary object.
.EXAMPLE
  pwsh -NoProfile -File Invoke-SsgExpansion.ps1 -Program CFH-COPY_ASCII `
    -CardFile E:\Repos\ssg4-work\sgs-cards\calls\ASSURFED_F999RUN_VIRM01_CO__L484.sgs `
    -OutFile E:\Repos\ssg4-work\expanded\CFH-COPY_ASCII__VIRM01_CO.cob
#>
param(
  [Parameter(Mandatory = $true)][String]$Program,
  [Parameter(Mandatory = $true)][String]$CardFile,
  [Parameter(Mandatory = $true)][String]$OutFile,
  [String]$ScriptPath = (Join-Path $PSScriptRoot "..\..\SsgConverter\Examples\Output\$Program.ps1"),
  [String]$AmtLib = (Join-Path $PSScriptRoot '..\..\SsgConverter\Trials\RealRuntime\AmtPsEclLib.psm1'),
  [String]$MockLib = (Join-Path $PSScriptRoot '..\..\SsgConverter\Trials\Tier1Mock\SsgPsMockLib.psm1'),
  # run-id,account,project from the runstream's @RUN statement; fills INFO$ (SSG manual s3.1.4.4)
  [String]$RunInfo = '',
  # AMT's SgsLabels dictionary is case-sensitive; SSG labels are not (manual s3.1.1). Default: SSG rule.
  [Switch]$AmtCaseSensitiveLabels
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'SgsCardChecks.ps1')
foreach ($p in $ScriptPath, $AmtLib, $MockLib) { if (-not (Test-Path -LiteralPath $p)) { throw "Not found: $p" } }
if (-not (Test-Path -LiteralPath $CardFile)) { throw "Card file not found: $CardFile" }

Import-Module $MockLib -Force -DisableNameChecking
Reset-SgsMock

$realFunctions = 'AddTo-SgsList', 'GetSgsValue', 'Get-NextSgsPart', 'IpfSf-Substring', 'CompareTypeSafe', 'RemoveFrom-SgsList', 'Sort-SgsList'
$ast = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path $AmtLib), [ref]$null, [ref]$null)
$defs = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
foreach ($name in $realFunctions) {
  $def = $defs | Where-Object Name -eq $name | Select-Object -First 1
  if (-not $def) { throw "AMT function $name not found in $AmtLib" }
  # global: so these win over the mock module's same-named functions
  . ([ScriptBlock]::Create(($def.Extent.Text -replace "^function\s+$([regex]::Escape($name))", "function global:$name")))
}

$global:AmtMessages = New-Object System.Collections.Generic.List[string]
function global:Add-ErrorMsg { param([String]$Msg) $global:AmtMessages.Add("ERROR: $Msg") }
function global:Add-WarningMsg { param([String]$Msg) $global:AmtMessages.Add("WARNING: $Msg") }
$global:SsgRunInfo = $RunInfo
function global:Update-InfoSgs {
  # AMT's own version blanks every INFO$ field except run-cond; here run-id, account and project come
  # from @RUN, and the qualifiers are assumed equal to the project.
  if (-not $global:SgsLabels.ContainsKey('INFO$')) {
    $runId, $acct, $proj = ($global:SsgRunInfo -split ',') + @('', '', '')
    AddTo-SgsList "INFO$ $runId,$runId $acct $proj,$proj,$proj ,OFF BATCH, 000000000000 ,,"
    if (-not $global:SsgRunInfo) { $global:AmtMessages.Add('WARNING: INFO$ referenced but no -RunInfo given') }
  }
}

# Same state StartSSG + Add-Sgs set up, without the job-scope file or command-line overrides.
$global:SgsLabels = if ($AmtCaseSensitiveLabels) {
  New-Object 'System.Collections.Generic.Dictionary[String, Object]'
} else {
  New-Object 'System.Collections.Generic.Dictionary[String, Object]' ([System.StringComparer]::OrdinalIgnoreCase)
}
$global:CommandLineSgsLabels = ''
$global:CmdSgsLabelArray = $null
$cardsChanged = 0
foreach ($raw in [System.IO.File]::ReadAllLines((Resolve-Path -LiteralPath $CardFile), [System.Text.Encoding]::GetEncoding(1252))) {
  # Cards from Export-SgsCards.ps1 are already converted, so this is a no-op for them; it makes a raw card file safe too.
  $r = ConvertTo-AmtSgsCard $raw
  if ($r.Card -ne $raw.TrimEnd()) { $cardsChanged++ }
  foreach ($code in $r.Unfixable) {
    $global:AmtMessages.Add("WARNING: $code - $($script:SgsCardCodes[$code][1]) Card: $($r.Card)")
  }
  if ($r.Card -ne '') { AddTo-SgsList $r.Card }
}

$failed = $false; $errorText = $null
try {
  & (Resolve-Path $ScriptPath) -Parameters @()
} catch {
  $failed = $true
  $errorText = $_.Exception.Message + ' ' + $_.InvocationInfo.PositionMessage
}

$outDir = Split-Path $OutFile -Parent
if ($outDir -and -not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
[System.IO.File]::WriteAllLines($OutFile, [string[]]$global:EmittedLines, [System.Text.Encoding]::GetEncoding(1252))

[pscustomobject]@{
  Program     = $Program
  CardFile    = $CardFile
  Labels      = ($global:SgsLabels.Keys -join ' ')
  Lines       = $global:EmittedLines.Count
  AmtMessages = $global:AmtMessages.Count
  CardsRewritten = $cardsChanged
  Failed      = $failed
  Error       = $errorText
  OutFile     = $OutFile
}
foreach ($m in $global:AmtMessages) { Write-Warning ($m -replace '^(WARNING|ERROR): ', '') }
if ($failed) { exit 1 }
