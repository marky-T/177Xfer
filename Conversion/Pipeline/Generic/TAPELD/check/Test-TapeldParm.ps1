<#
.SYNOPSIS
  TAPELD step 2 check: parameter files for all 14 TAPELD calls (AMT's SGS functions + raw FIXE card, StrictMode 2),
  cross-checked against an expansion of each call. The real cards cannot be expanded (T3-028: AddTo-SgsList splits the
  quoted titles at their spaces), so each call is expanded with a copy of its cards where spaces inside quotes are '~';
  the expansion's titles are read back with '~' -> ' '. Compared: input/output lengths, field moves (REC1/REC2 layouts and
  MOVE ZONEn TO ZONOn), title items (REC3 layouts, TAB1 VALUEs), STITRE. Writes parm\, expanded\, crosscheck.csv.
#>
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path "$PSScriptRoot\..\..\..\..\..").Path
. "$repo\Conversion\Pipeline\Generic\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$Cards = $ge.SgsCards
$Out = "$($ge.GenericWork)\TAPELD"
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
New-Item -ItemType Directory -Force "$Out\parm", "$Out\expanded", "$Out\cards" | Out-Null
. "$repo\Conversion\Pipeline\SgsCardChecks.ps1"
. "$repo\Conversion\Pipeline\Generic\GnHandoff.ps1"
. "$PSScriptRoot\..\gen\TapeldParm.ps1"
$ast = [System.Management.Automation.Language.Parser]::ParseFile("$repo\SsgConverter\Trials\RealRuntime\AmtPsEclLib.psm1", [ref]$null, [ref]$null)
$defs = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
foreach ($name in 'AddTo-SgsList', 'GetSgsValue', 'Get-NextSgsPart', 'IpfSf-Substring', 'CompareTypeSafe') {
  $def = $defs | Where-Object Name -eq $name | Select-Object -First 1
  . ([ScriptBlock]::Create(($def.Extent.Text -replace "^function\s+$([regex]::Escape($name))", "function global:$name")))
}
function global:Add-ErrorMsg { param([String]$Msg) throw "AMT error: $Msg" }
function global:Add-WarningMsg { param([String]$Msg) }

function Read-Expansion([String]$path) {
  $t = ([IO.File]::ReadAllLines($path, $latin1) | Where-Object { $_.Trim() -and $_ -notmatch '^\s{6}\*' } | ForEach-Object { $_.Trim() }) -join ' '
  $lay = @{}
  foreach ($m in [regex]::Matches($t, '01\s+(REC[123])(\d+)\.\s+(?:06\s+FILLER\s+PIC\s+X\((\d+)\)\.\s+)?06\s+(ZONE|ZONO|FIXDATA)\d+\s+PIC\s+X\((\d+)\)')) {
    $lay["$($m.Groups[1].Value)-$($m.Groups[2].Value)"] = @($(if ($m.Groups[3].Success) { [Int32]$m.Groups[3].Value + 1 } else { 1 }), [Int32]$m.Groups[5].Value)
  }
  $lines = New-Object System.Collections.Generic.List[String]
  $lines.Add('IN' + ('{0:D5}' -f [Int32][regex]::Match($t, '01\s+RECIN\s+PIC\s+X\((\d+)\)').Groups[1].Value))
  $lines.Add('OU' + ('{0:D5}' -f [Int32][regex]::Match($t, '01\s+RECOUT\s+PIC\s+X\((\d+)\)').Groups[1].Value))
  foreach ($m in [regex]::Matches($t, 'MOVE\s+ZONE(\d+)\s+TO\s+ZONO(\d+)\.')) {
    $i = $lay["REC1-$($m.Groups[1].Value)"]; $o = $lay["REC2-$($m.Groups[2].Value)"]
    $lines.Add('MV' + ('{0:D5}{1:D5}{2:D5}{3:D5}' -f $i[0], $i[1], $o[0], $o[1]))
  }
  $vals = @{}
  foreach ($m in [regex]::Matches($t, "06\s+FIXED(\d+)\s+PIC\s+X\((\d+)\)\s+VALUE\s+(SPACES|'(?:[^']|'')*'|\S+?)\s*;?\s*\.")) {
    $v = $m.Groups[3].Value
    $vals[$m.Groups[1].Value] = Get-TapeldFixeText $(if ($v -eq 'SPACES') { 'SPACES' } else { $v.Replace('~', ' ') }) ([Int32]$m.Groups[2].Value)
  }
  $titles = [regex]::Match($t, 'IF\s+LNCTR\s+>\s+57(.*?)WRITE\s+RECOUT\s+AFTER\s+PAGE').Groups[1].Value
  foreach ($m in [regex]::Matches($titles, 'MOVE\s+FIXED(\d+)\s+TO\s+FIXDATA(\d+)')) {
    $f = $lay["REC3-$($m.Groups[2].Value)"]
    $lines.Add('FX' + ('{0:D5}{1:D5}' -f $f[0], $f[1]) + $vals[$m.Groups[1].Value])
  }
  if ($titles) { $lines.Add('ST') }
  return , $lines
}

# Spaces inside quotes -> '~' (method 1 and 2), so AddTo-SgsList keeps each title in one subfield.
function Protect-Quoted([String]$line) {
  $sb = New-Object System.Text.StringBuilder; $q = $false
  foreach ($c in $line.ToCharArray()) { if ($c -eq "'") { $q = -not $q }; [void]$sb.Append($(if ($q -and $c -eq ' ') { '~' } else { $c })) }
  $sb.ToString()
}

$calls = Import-Csv "$Cards\sgs-calls.csv" | Where-Object ProgramKey -eq 'TAPELD_ASCII'
$results = foreach ($c in $calls) {
  $id = $c.CardFile -replace '^calls\\ASSURFED_F999RUN', '' -replace '\.sgs$', '' -replace '__', '_' -replace '^_', ''
  $cardFile = Join-Path $Cards $c.CardFile
  $global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
  $note = ''; $lines = $null
  try {
    foreach ($raw in [IO.File]::ReadAllLines($cardFile, $latin1)) { $r = ConvertTo-AmtSgsCard $raw; if ($r.Card -ne '') { try { AddTo-SgsList $r.Card } catch { } } }
    $SgsFilePath = $cardFile
    $lines = & { Set-StrictMode -Version 2; Get-TapeldParmLines }
    [IO.File]::WriteAllLines("$Out\parm\$id.parm", [String[]]$lines, $latin1)
  } catch { $note = 'parm: ' + $_.Exception.Message }
  $prot = "$Out\cards\$id.sgs"
  [IO.File]::WriteAllLines($prot, [String[]]([IO.File]::ReadAllLines($cardFile, $latin1) | ForEach-Object { Protect-Quoted $_ }), $latin1)
  $cob = "$Out\expanded\$id.cob"
  $x = pwsh -NoProfile -File "$repo\Conversion\Pipeline\Invoke-SsgExpansion.ps1" -Program TAPELD_ASCII -CardFile $prot -OutFile $cob 2>&1 | Out-String
  $verdict = 'NO-PARM'
  if (-not (Test-Path $cob) -or -not (Select-String $cob -Pattern 'PROCEDURE DIVISION' -Quiet)) { $verdict = 'NO-EXPANSION'; $note += ' ' + (($x -replace '\e\[[0-9;]*m', '' -replace '\s+', ' ').Trim() | ForEach-Object { $_.Substring(0, [Math]::Min(160, $_.Length)) }) }
  elseif ($lines) {
    $e = Read-Expansion $cob
    $d = @(for ($i = 0; $i -lt [Math]::Max($e.Count, $lines.Count); $i++) {
        $a = if ($i -lt $e.Count) { $e[$i] } else { '<none>' }; $b = if ($i -lt $lines.Count) { $lines[$i] } else { '<none>' }
        if ($a -ne $b) { "line $($i + 1) exp[$($a.TrimEnd())] parm[$($b.TrimEnd())]" } })
    $verdict = if ($d) { 'DIFF: ' + (($d | Select-Object -First 2) -join '; ') } else { 'MATCH' }
  }
  [pscustomobject]@{ Call = $id; Lines = if ($lines) { $lines.Count } else { 0 }; Titles = if ($lines) { @($lines | Where-Object { $_.StartsWith('FX') }).Count } else { 0 }; Result = $verdict; Note = $note.Trim() }
}
$results | Export-Csv "$Out\crosscheck.csv" -NoTypeInformation
'Cross-check parm vs expansion: ' + (($results | Group-Object { ($_.Result -split ':')[0] } | ForEach-Object { "$($_.Name) $($_.Count)" }) -join ', ')
$results | Where-Object { $_.Result -ne 'MATCH' -or $_.Note } | ForEach-Object { '  {0}: {1} {2}' -f $_.Call, $_.Result, $_.Note }
