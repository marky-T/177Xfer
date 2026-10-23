# Shared routines for the AFBUS_2200COBOL mock tests (smoke and reference). Import with: Import-Module (Join-Path $PSScriptRoot 'MockTestLib.psm1') -Force
# Everything is driven by the exported @SSG calls (sgs-calls.csv) and the generated set, so a newly generated program gets a smoke case without edits.

$script:Latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
. (Join-Path $PSScriptRoot 'MockFc.ps1')

function Get-SgsCards([String]$Path) {
  $c = @{ Input = @(); Output = @(); Keys = @(); Update = @(); FieldIn = @(); FieldOut = @(); KeyIs = @() }
  $pairs = { param($s) [regex]::Matches($s, '(\d+),(\d+)') | ForEach-Object { [pscustomobject]@{ Start = [Int32]$_.Groups[1].Value; Len = [Int32]$_.Groups[2].Value } } }
  foreach ($l in Get-Content -LiteralPath $Path) {
    if ($l -match '^\s*(INPUT|OUTPUT)\s+(.*)$') {
      $which = if ($Matches[1] -eq 'INPUT') { 'Input' } else { 'Output' }
      foreach ($m in [regex]::Matches($Matches[2], '(\w+),(\d+)')) { $c[$which] += [pscustomobject]@{ Name = $m.Groups[1].Value; Len = [Int32]$m.Groups[2].Value } }
    }
    elseif ($l -match '^\s*KEYS\s+(.*)$') { $c.Keys += & $pairs $Matches[1] }
    elseif ($l -match '^\s*UPDATE\s+(.*)$') { $c.Update += & $pairs $Matches[1] }
    elseif ($l -match '^\s*FIELDIN\s+(.*)$') { $c.FieldIn += & $pairs $Matches[1] }
    elseif ($l -match '^\s*FIELDOUT\s+(.*)$') { $c.FieldOut += & $pairs $Matches[1] }
    elseif ($l -match '^\s*KEYIS\s+(\d+),(\d+)') { $c.KeyIs += [pscustomobject]@{ Offset = [Int32]$Matches[1]; Len = [Int32]$Matches[2] } }
  }
  $c
}

function Sort-Ordinal([String[]]$Items, [ScriptBlock]$Key = { $args[0] }) {
  $list = [System.Collections.Generic.List[Object]]::new(); $list.AddRange([Object[]]$Items)
  $list.Sort([Comparison[Object]] { param($a, $b) [String]::CompareOrdinal([String](& $Key $a), [String](& $Key $b)) })
  $list.ToArray()
}
function New-Text([Random]$Rnd, [Int32]$Length) { $a = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'; -join (1..$Length | ForEach-Object { $a[$Rnd.Next($a.Length)] }) }
function Set-At([String]$Text, [Int32]$Start1, [String]$Value) { $Text.Substring(0, $Start1 - 1) + $Value + $Text.Substring($Start1 - 1 + $Value.Length) }
function Get-Key([String]$Record, $Pairs) { -join ($Pairs | ForEach-Object { $Record.Substring($_.Start - 1, $_.Len) }) }
function Write-Records([String]$File, [String[]]$Records) {
  [System.IO.File]::WriteAllBytes($File, $script:Latin1.GetBytes((($Records | ForEach-Object { $_ + "`r`n" }) -join '')))
}
function Set-Length([String]$Text, [Int32]$Length) { if ($Text.Length -ge $Length) { $Text.Substring(0, $Length) } else { $Text.PadRight($Length) } }

# One row per generated program DLL: the exported call its LionSource was built from (same rule as Build-AppLionSource.ps1: Converted calls, -CallIndex).
function Get-SetCalls {
  param(
    [String]$Binaries = 'E:\AMT_Work\Rebuild177a\AFBUS_2200COBOL\Binaries\Programs',
    [String]$CardsDir = 'E:\Repos\ssg4-work\sgs-cards',
    [String]$SourceDir = 'E:\Repos\ssg4-source',
    [String]$CobolDir = 'E:\Repos\ssg4-work\release\cobol\in\AFBUS_2200COBOL',
    [Int32]$CallIndex = 1
  )
  $norm = { param($s) ($s -replace '[^A-Za-z0-9]', '').ToUpperInvariant() }
  $calls = Import-Csv (Join-Path $CardsDir 'sgs-calls.csv') | Where-Object { $_.Converted -eq 'True' -and $_.ProgramKey }
  foreach ($dll in Get-ChildItem $Binaries -Filter 'ASSURFED_UTILIT_*.dll' | Sort-Object Name) {
    $short = & $norm ($dll.BaseName -replace '^ASSURFED_UTILIT_', '')
    $rows = @($calls | Where-Object { (& $norm $_.ProgramKey) -eq $short })
    if ($rows.Count -lt $CallIndex) { Write-Warning "$($dll.Name): no exported call $CallIndex"; continue }
    $call = $rows[$CallIndex - 1]
    $programId = 'ASSURFED-UTILIT-' + (($call.ProgramKey -replace '_', '-').ToUpperInvariant())
    $runstream = Get-ChildItem $SourceDir -Recurse -File -Filter $call.Runstream -ErrorAction SilentlyContinue | Select-Object -First 1
    [pscustomobject]@{
      Key = $call.ProgramKey; Dll = $dll.Name; ProgramId = $programId
      Case = "$($call.RunId)_L$($call.Line)"; RunId = $call.RunId; Line = [Int32]$call.Line
      Cards = Join-Path $CardsDir $call.CardFile
      Runstream = $(if ($runstream) { $runstream.FullName })
      Cobol = Join-Path $CobolDir "$programId.TXT"
    }
  }
}

# Data cards the program reads from the card reader: the non-@ images after the first @XQT that follows the @SSG call.
function Get-DataCards([String]$Runstream, [Int32]$Line) {
  if (-not $Runstream -or -not (Test-Path -LiteralPath $Runstream)) { return @() }
  $lines = Get-Content -LiteralPath $Runstream
  $i = $Line
  while ($i -lt $lines.Count -and $lines[$i] -notmatch '^@XQT') { $i++ }
  $cards = @()
  for ($j = $i + 1; $j -lt $lines.Count -and $lines[$j] -notmatch '^@'; $j++) { $cards += $lines[$j].TrimEnd() }
  $cards
}

# Logical file name of the program's card reader (SELECT x ASSIGN TO CARD-READER), from the expanded COBOL; $null if it has none.
function Get-CardReaderFile([String]$Cobol) {
  if (-not (Test-Path -LiteralPath $Cobol)) { return $null }
  $m = Select-String -LiteralPath $Cobol -Pattern 'SELECT\s+(\S+)\s+ASSIGN\s+TO\s+CARD-READER' | Select-Object -First 1
  if ($m) { $m.Matches[0].Groups[1].Value }
}

# Writes the data cards as 80-column card images; returns @{ <name> = <file> } for -Inputs / -ExtraInputs, or an empty hashtable.
function New-CardReaderInput($Call, [String]$Folder) {
  $name = Get-CardReaderFile $Call.Cobol
  if (-not $name) { return @{} }
  $cards = @(Get-DataCards $Call.Runstream $Call.Line)
  $file = Join-Path $Folder "$name.cards"
  Write-Records $file ($cards | ForEach-Object { Set-Length $_ 80 })
  @{ $name = $file }
}

# LOADIS-type program (sequential INPUT -> indexed OUTPUT, KEYIS offset,length) followed by its UNLOADIS partner (indexed INPUT -> sequential OUTPUT).
# Expected: the unloaded file holds the loaded records in key order (the loader is given them in key order, as a sequential indexed load needs).
function Invoke-IndexedRoundTrip {
  param([Parameter(Mandatory)]$Load, [Parameter(Mandatory)]$Unload, [Parameter(Mandatory)][String]$Work, [String]$Binaries, [Int32]$Records = 40, [Int32]$Seed = 1958)
  $run = Join-Path $PSScriptRoot 'Run-ProgramCase.ps1'
  $cl = Get-SgsCards $Load.Cards; $cu = Get-SgsCards $Unload.Cards
  $len = $cl.Input[0].Len; $ko = $cl.KeyIs[0].Offset; $kl = $cl.KeyIs[0].Len
  $rnd = [Random]::new($Seed)
  $digits = [Math]::Min($kl - 1, 9)
  $keys = Sort-Ordinal (1..$Records | ForEach-Object { 'R' + $rnd.Next(1, [Int32][Math]::Pow(10, $digits)).ToString().PadLeft($digits, '0') } | Sort-Object -Unique)
  $recs = @(foreach ($k in $keys) { Set-At (New-Text $rnd $len) ($ko + 1) (Set-Length $k $kl) })
  $d = Join-Path $Work "$($Load.Key)-$($Unload.Key)"; New-Item -ItemType Directory -Force $d | Out-Null
  $inName = $cl.Input[0].Name; $midName = $cl.Output[0].Name
  Write-Records "$d\$inName.bin" $recs
  $outLen = $cu.Output[0].Len
  Write-Records "$d\expected.bin" ($recs | ForEach-Object { Set-Length $_ $outLen })
  Start-MockFc
  $r1 = & $run -Case "REF_$($Load.Key)" -Dll $Load.Dll -Inputs @{ $inName = "$d\$inName.bin" } -KeepOutputAs $midName -KeepOutputTo "$d\loaded.dat" -Binaries $Binaries
  $r1.Detail = "$($recs.Count) records, ascending keys at offset $ko length $kl, into $midName. " + $r1.Detail
  $r1
  Start-MockFc
  $r2 = & $run -Case "REF_$($Unload.Key)" -Dll $Unload.Dll -Inputs @{ $cu.Input[0].Name = "$d\loaded.dat" } -ExpectedName $cu.Output[0].Name -ExpectedFile "$d\expected.bin" -Binaries $Binaries
  $r2.Detail = "reads what $($Load.Key) wrote; expected = the records unchanged, in key order. " + $r2.Detail
  $r2
}

Export-ModuleMember -Function *
