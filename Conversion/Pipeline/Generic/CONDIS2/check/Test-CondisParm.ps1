<#
.SYNOPSIS
  CONDIS2 step 2 check: parameter files for all 18 CONDIS2 calls from their cards (AMT's SGS functions + the raw card
  file, StrictMode 2), cross-checked against each call's own expansion, rebuilt into the same parameter lines from the
  expansion's REDEFINES layouts and its procedure (CASE tests, MOVE / date MOVE, CONST). Writes parm\, crosscheck.csv.
#>
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path "$PSScriptRoot\..\..\..\..\..").Path
. "$repo\Conversion\Pipeline\Generic\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$Cards = $ge.SgsCards
$Expanded = "$($ge.WorkRoot)\allcalls\expanded-fix"
$Out = "$($ge.GenericWork)\CONDIS2"
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
New-Item -ItemType Directory -Force "$Out\parm" | Out-Null
. "$repo\Conversion\Pipeline\SgsCardChecks.ps1"
. "$repo\Conversion\Pipeline\Generic\GnHandoff.ps1"
. "$PSScriptRoot\..\gen\CondisParm.ps1"
$ast = [System.Management.Automation.Language.Parser]::ParseFile("$repo\SsgConverter\Trials\RealRuntime\AmtPsEclLib.psm1", [ref]$null, [ref]$null)
$defs = $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
foreach ($name in 'AddTo-SgsList', 'GetSgsValue', 'Get-NextSgsPart', 'IpfSf-Substring', 'CompareTypeSafe') {
  $def = $defs | Where-Object Name -eq $name | Select-Object -First 1
  . ([ScriptBlock]::Create(($def.Extent.Text -replace "^function\s+$([regex]::Escape($name))", "function global:$name")))
}
function global:Add-ErrorMsg { param([String]$Msg) throw "AMT error: $Msg" }
function global:Add-WarningMsg { param([String]$Msg) }

$dateCode = @{ '2-4' = 'D24'; '4-2' = 'D42'; '22A' = 'D22A'; '22B' = 'D22B'; '66A' = 'D66A'; '66B' = 'D66B'; '68' = 'D68'; '86' = 'D86' }
function Read-Expansion([String]$path) {
  $t = ([IO.File]::ReadAllLines($path, $latin1) | Where-Object { $_.Trim() -and $_ -notmatch '^\s{6}\*' } | ForEach-Object { $_.Trim() }) -join ' '
  $lines = New-Object System.Collections.Generic.List[String]
  $lines.Add('FI' + ('{0:D5}' -f [Int32][regex]::Match($t, 'FD\s+FILEIN\s.*?PIC\s+X\((\d+)\)').Groups[1].Value))
  $lines.Add('FO' + ('{0:D5}' -f [Int32][regex]::Match($t, 'FD\s+FILEOUT\s.*?PIC\s+X\((\d+)\)').Groups[1].Value))
  $lay = @{}
  foreach ($m in [regex]::Matches($t, '01\s+(ENR-CASE|ENRIN-MOVE|ENROUT-MOVE|ENROUT-CONST)-(\d+)-(\d+)\s+REDEFINES\s+\S+\.\s+(?:03\s+FILLER\s+PIC\s+X\((\d+)\)\.\s+)?03\s+\S+\s+PIC\s+X\((\d+)\)')) {
    $pos = if ($m.Groups[4].Success) { [Int32]$m.Groups[4].Value + 1 } else { 1 }
    $lay["$($m.Groups[1].Value)-$($m.Groups[2].Value)-$($m.Groups[3].Value)"] = @($pos, [Int32]$m.Groups[5].Value)
  }
  $a = $t.LastIndexOf('ADD 1 TO NB-REC-LU.'); $b = $t.IndexOf('CASE-NON-PREVU.')
  $proc = $t.Substring($a, $b - $a)
  $pat = "(?<case>(?<![\w-])CASE-(?<n>\d+)\.)|(?<oth>(?<![\w-])OTHER\.)|(?<ts>IF\s+CASE-(?<n>\d+)-(?<k>\d+)\s+=\s+'(?<v>(?:[^']|'')*)')" +
    "|(?<dt>MOVE\s+MOVEIN-(?<n>\d+)-(?<k>\d+)\s+TO\s+WS-A\d\s+PERFORM\s+TRANSFO-DATE-(?<d>\S+)\s+THRU)" +
    "|(?<mv>MOVE\s+MOVEIN-(?<n>\d+)-(?<k>\d+)\s+TO\s+MOVEOUT-)|(?<co>MOVE\s+'(?<v>(?:[^']|'')*)'\s+TO\s+CONST-(?<n>\d+)-(?<k>\d+))"
  $group = ''
  foreach ($m in [regex]::Matches($proc, $pat)) {
    $key = "$($m.Groups['n'].Value)-$($m.Groups['k'].Value)"
    if ($m.Groups['case'].Success) { $lines.Add('CA'); $group = 'C'; continue }
    if ($m.Groups['oth'].Success) { $lines.Add('OT'); $group = 'O'; continue }
    if ($m.Groups['ts'].Success) { $l = $lay["ENR-CASE-$key"]; $lines.Add('TS' + ('{0:D5}{1:D5}' -f $l[0], $l[1]) + (Format-CondisValue $m.Groups['v'].Value.Replace("''", "'").Replace('~', ' ') $l[1])); continue }
    if (-not $group) { $lines.Add('NG'); $group = 'N' }
    if ($m.Groups['co'].Success) { $l = $lay["ENROUT-CONST-$key"]; $lines.Add('CO' + ('{0:D5}{1:D5}' -f $l[0], $l[1]) + (Format-CondisValue $m.Groups['v'].Value.Replace("''", "'") $l[1])); continue }
    $i = $lay["ENRIN-MOVE-$key"]; $o = $lay["ENROUT-MOVE-$key"]
    $code = if ($m.Groups['dt'].Success) { $dateCode[$m.Groups['d'].Value] } else { '' }
    $lines.Add('MV' + ('{0:D5}{1:D5}{2:D5}{3:D5}' -f $i[0], $i[1], $o[0], $o[1]) + $code.PadRight(4))
  }
  return , $lines
}

$results = foreach ($c in Import-Csv "$Expanded\CONDIS2_ASCII-expansion.csv") {
  $global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
  $note = ''; $lines = $null
  $cardFile = Join-Path $Cards $c.CardFile
  try {
    foreach ($raw in [IO.File]::ReadAllLines($cardFile, $latin1)) { $r = ConvertTo-AmtSgsCard $raw; if ($r.Card -ne '') { try { AddTo-SgsList $r.Card } catch { $note = 'AddTo-SgsList: ' + $_.Exception.Message } } }
    $SgsFilePath = $cardFile
    $lines = & { Set-StrictMode -Version 2; Get-CondisParmLines }
    [IO.File]::WriteAllLines("$Out\parm\$($c.Call).parm", [String[]]$lines, $latin1)
  } catch { $note = 'parm: ' + $_.Exception.Message }
  $verdict = 'NO-PARM'
  if ($lines) {
    $protectedExp = "$Out\expanded\$($c.Call).cob"   # T3-028: spaces inside '' '' protected as ~
    if ($c.Procedure -ne 'True' -and -not (Test-Path $protectedExp)) { $verdict = 'NO-EXPANSION' }
    else {
      $e = Read-Expansion $(if (Test-Path $protectedExp) { $protectedExp } else { "$Expanded\CONDIS2_ASCII__$($c.Call).cob" })
      $d = @(for ($i = 0; $i -lt [Math]::Max($e.Count, $lines.Count); $i++) {
          $x = if ($i -lt $e.Count) { $e[$i] } else { '<none>' }; $y = if ($i -lt $lines.Count) { $lines[$i] } else { '<none>' }
          if ($x -ne $y) { "line $($i + 1) exp[$($x.TrimEnd())] parm[$($y.TrimEnd())]" } })
      $verdict = if ($d) { 'DIFF: ' + ($d | Select-Object -First 3) -join '; ' } else { 'MATCH' }
    }
  }
  [pscustomobject]@{ Call = $c.Call; Lines = if ($lines) { $lines.Count } else { 0 }; Groups = if ($lines) { @($lines | Where-Object { $_ -in 'CA', 'OT', 'NG' }).Count } else { 0 }
    Dates = if ($lines) { (@($lines | Where-Object { $_.StartsWith('MV') -and $_.Substring(22).Trim() } | ForEach-Object { $_.Substring(22).Trim() } | Sort-Object -Unique) -join '/') } else { '' }
    Result = $verdict; Note = $note }
}
$results | Export-Csv "$Out\crosscheck.csv" -NoTypeInformation
'Cross-check parm vs expansion: ' + (($results | Group-Object { ($_.Result -split ':')[0] } | ForEach-Object { "$($_.Name) $($_.Count)" }) -join ', ')
$results | Where-Object { $_.Result -ne 'MATCH' -or $_.Note } | ForEach-Object { '  {0}: {1} {2}' -f $_.Call, $_.Result, $_.Note }
