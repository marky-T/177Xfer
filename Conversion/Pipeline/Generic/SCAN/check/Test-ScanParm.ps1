<#
.SYNOPSIS
  SCAN step 2 check: parameter files for all 19 SCAN calls from their cards (AMT's SGS functions, StrictMode 2),
  cross-checked against each call's expansion (record length, the end line's input name) and, for the IF R < n limit,
  against the raw IF card: the converter drops the skeleton's *EDIT ON & ... *EDIT OFF block that builds the IF
  statement (T3-045), so every expansion prints all records. Writes parm\, crosscheck.csv.
#>
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path "$PSScriptRoot\..\..\..\..\..").Path
. "$repo\Conversion\Pipeline\Generic\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$Cards = $ge.SgsCards
$Expanded = $ge.Expanded
$Out = "$($ge.GenericWork)\SCAN"
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
New-Item -ItemType Directory -Force "$Out\parm" | Out-Null
. "$repo\Conversion\Pipeline\SgsCardChecks.ps1"
. "$repo\Conversion\Pipeline\Generic\GnHandoff.ps1"
. "$PSScriptRoot\..\gen\ScanParm.ps1"
$ast = [System.Management.Automation.Language.Parser]::ParseFile("$repo\SsgConverter\Trials\RealRuntime\AmtPsEclLib.psm1", [ref]$null, [ref]$null)
$defs = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
foreach ($name in 'AddTo-SgsList', 'GetSgsValue', 'Get-NextSgsPart', 'IpfSf-Substring', 'CompareTypeSafe') {
  $def = $defs | Where-Object Name -eq $name | Select-Object -First 1
  . ([ScriptBlock]::Create(($def.Extent.Text -replace "^function\s+$([regex]::Escape($name))", "function global:$name")))
}
function global:Add-ErrorMsg { param([String]$Msg) throw "AMT error: $Msg" }
function global:Add-WarningMsg { param([String]$Msg) }

$results = foreach ($c in Import-Csv "$Expanded\SCAN_ASCII-expansion.csv") {
  $global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
  $cardFile = Join-Path $Cards $c.CardFile
  $note = ''; $lines = $null
  try {
    foreach ($raw in [IO.File]::ReadAllLines($cardFile, $latin1)) { $r = ConvertTo-AmtSgsCard $raw; if ($r.Card -ne '') { AddTo-SgsList $r.Card } }
    $lines = & { Set-StrictMode -Version 2; Get-ScanParmLines }
    [IO.File]::WriteAllLines("$Out\parm\$($c.Call).parm", [String[]]$lines, $latin1)
  } catch { $note = 'parm: ' + $_.Exception.Message }
  $verdict = 'NO-PARM'
  if ($lines) {
    $t = ([IO.File]::ReadAllLines("$Expanded\SCAN_ASCII__$($c.Call).cob", $latin1) | ForEach-Object { $_.Trim() }) -join ' '
    $m = [regex]::Match($t, "VALUE\s+'(RECORDS READ FROM [^']*)'\.")
    $exp = @(('IN' + ('{0:D5}' -f [Int32][regex]::Match($t, '01\s+REC-IN\s+PIC\s+X\((\d+)\)').Groups[1].Value)),
      ('MN' + $(if ($m.Groups[1].Value.Length -ge 37) { $m.Groups[1].Value.Substring(0, 37) } else { $m.Groups[1].Value.PadRight(37) })))
    $ifCard = @([IO.File]::ReadAllLines($cardFile, $latin1) | Where-Object { $_ -match '^\s*IF\s' })
    foreach ($l in $ifCard) { if ($l -match '^\s*IF\s+(R|RECORD)\s+<\s+(\d+)\s*$') { $exp += 'MX' + ('{0:D10}' -f [Int64]$Matches[2]) } else { $exp += "IF? $l" } }
    $d = @(for ($i = 0; $i -lt [Math]::Max($exp.Count, $lines.Count); $i++) {
        $a = if ($i -lt $exp.Count) { $exp[$i] } else { '<none>' }; $b = if ($i -lt $lines.Count) { $lines[$i] } else { '<none>' }
        if ($a -ne $b) { "line $($i + 1) exp[$($a.TrimEnd())] parm[$($b.TrimEnd())]" } })
    $verdict = if ($d) { 'DIFF: ' + (($d | Select-Object -First 2) -join '; ') } else { 'MATCH' }
    if ($ifCard -and $t -notmatch 'IF\s+REC-IN-CT\s+<') { $note = 'expansion has no IF (T3-045)' }
  }
  [pscustomobject]@{ Call = $c.Call; Len = if ($lines) { [Int32]$lines[0].Substring(2, 5) } else { 0 }; Max = if ($lines -and $lines.Count -gt 2) { [Int64]$lines[2].Substring(2) } else { 0 }; Result = $verdict; Note = $note }
}
$results | Export-Csv "$Out\crosscheck.csv" -NoTypeInformation
'Cross-check parm vs expansion + IF card: ' + (($results | Group-Object { ($_.Result -split ':')[0] } | ForEach-Object { "$($_.Name) $($_.Count)" }) -join ', ')
'By length / limit: ' + (($results | Group-Object { "$($_.Len)/$($_.Max)" } | ForEach-Object { "$($_.Name) x$($_.Count)" }) -join ', ')
'Expansions without the IF statement (T3-045): ' + @($results | Where-Object Note -match 'T3-045').Count
$results | Where-Object { $_.Result -ne 'MATCH' } | ForEach-Object { '  {0}: {1} {2}' -f $_.Call, $_.Result, $_.Note }
