<#
.SYNOPSIS
  Reference tests for the non-copy programs, with expected output worked out independently of the generated C#.
.DESCRIPTION
  FUSBA2_ASCII (call VIRD03 line 766): an update merge of two key-sorted files. The expected file is made by a model of the skeleton's COBOL
  control flow (not of our C#): MAJ record keys from UPDATE (else KEYS), INP keys from KEYS; for every INP record write it padded to the output length;
  where a MAJ record has the same key, copy the FIELDIN ranges of the MAJ record to the FIELDOUT ranges; a MAJ record is consumed when the INP key advances.
  Round trips (TestCatalog.psd1 RoundTrips): a LOADIS-type program loads records with unique, ascending keys into an indexed file and its
  UNLOADIS partner reads that file back sequentially, so the output must be the input records in key order. Add a pair to the catalog to test it.
  CHAB100_ASCII (call EUPD01 line 15): card file creation. With NUMB 1,1 / MOD 0 / FLDSEL 0 the expanded COBOL does PERFORM PAR1 0 TIMES and then
  falls through into PAR1: it reads ONE data card into the output record (ZT1, the whole 100-byte record) and writes it. Expected: the first data card
  of the run stream, as one record of the OUTPUT length.
  Each case gets a fresh mock file controller. Data is generated with a fixed seed, so a rerun gives the same files.
.EXAMPLE
  pwsh -NoProfile -File Run-ReferenceTests.ps1
#>
param(
  [String]$Binaries = 'E:\AMT_Work\Rebuild177a\AFBUS_2200COBOL\Binaries\Programs',
  [String]$Calls = 'E:\Repos\ssg4-work\sgs-cards\calls',
  [String]$Work = 'E:\AMT_Work\MockTest\Ref',
  [Int32]$Seed = 1957
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'MockTestLib.psm1') -Force -DisableNameChecking
$run = Join-Path $PSScriptRoot 'Run-ProgramCase.ps1'
$catalog = Import-PowerShellDataFile (Join-Path $PSScriptRoot 'TestCatalog.psd1')
New-Item -ItemType Directory -Force $Work | Out-Null
$set = @{}; foreach ($c in Get-SetCalls -Binaries $Binaries) { $set[$c.Key] = $c }

$results = @()

# ---- FUSBA2_ASCII, call VIRD03 line 766
$cards = Get-SgsCards (Join-Path $Calls 'ASSURFED_F999RUN-d_VIRD03__L766.sgs')
$majLen = ($cards.Input | Where-Object Name -eq 'MAJ').Len; $inpLen = ($cards.Input | Where-Object Name -eq 'INP').Len; $outLen = $cards.Output[0].Len
$majPairs = if ($cards.Update.Count) { $cards.Update } else { $cards.Keys }; $inpPairs = $cards.Keys
$rnd = [Random]::new($Seed)
$pool = 1..30 | ForEach-Object { 'K' + ('{0:D5}' -f ($_ * 3)) + 'x' } | ForEach-Object { $_ }   # 7 characters, ascending
$inp = foreach ($k in $pool) { $n = $rnd.Next(0, 4); if ($n -eq 3) { $n = 2 }; for ($i = 0; $i -lt $n; $i++) { $r = New-Text $rnd $inpLen; $pos = 0; foreach ($p in $inpPairs) { $r = Set-At $r $p.Start $k.Substring($pos, $p.Len); $pos += $p.Len }; $r } }
$majKeys = @('A00001x') + ($pool | Where-Object { $rnd.Next(0, 3) -eq 0 }) + @('K00004x', 'K00046x', 'K00091x') + @('Z99999x')
$majKeys = Sort-Ordinal ($majKeys | Select-Object -Unique)
$maj = foreach ($k in $majKeys) { $r = New-Text $rnd $majLen; $pos = 0; foreach ($p in $majPairs) { $r = Set-At $r $p.Start $k.Substring($pos, $p.Len); $pos += $p.Len }; $r }
# model of the COBOL loop
$HIGH = [String][char]255 * 7
$i = 0; $j = 0
$k1 = if ($maj.Count) { Get-Key $maj[0] $majPairs } else { $HIGH }
$k2 = if ($inp.Count) { Get-Key $inp[0] $inpPairs } else { $HIGH }
$prev2 = ' ' * 7
$out = New-Object System.Collections.Generic.List[String]
$guard = 0
while ($true) {
  if (++$guard -gt 100000) { throw 'model did not end' }
  $c = [String]::CompareOrdinal($k1, $k2)
  if ($c -lt 0) { $i++; $k1 = if ($i -lt $maj.Count) { Get-Key $maj[$i] $majPairs } else { $HIGH } }
  elseif ($c -gt 0) { $out.Add($inp[$j].PadRight($outLen)); $prev2 = $k2; $j++; $k2 = if ($j -lt $inp.Count) { Get-Key $inp[$j] $inpPairs } else { $HIGH } }
  elseif ($k1 -eq $HIGH -and $k2 -eq $HIGH) { break }
  else {
    $r = $inp[$j].PadRight($outLen)
    for ($f = 0; $f -lt $cards.FieldIn.Count; $f++) { $r = Set-At $r $cards.FieldOut[$f].Start $maj[$i].Substring($cards.FieldIn[$f].Start - 1, $cards.FieldIn[$f].Len) }
    $out.Add($r); $prev2 = $k2; $j++; $k2 = if ($j -lt $inp.Count) { Get-Key $inp[$j] $inpPairs } else { $HIGH }
    if ([String]::CompareOrdinal($k2, $prev2) -gt 0) { $i++; $k1 = if ($i -lt $maj.Count) { Get-Key $maj[$i] $majPairs } else { $HIGH } }
  }
}
$d = Join-Path $Work 'FUSBA2_L766'; New-Item -ItemType Directory -Force $d | Out-Null
Write-Records "$d\MAJ.bin" $maj; Write-Records "$d\INP.bin" $inp; Write-Records "$d\OUT.expected" $out
$matched = @($out | Where-Object { $_.Substring($cards.FieldOut[0].Start - 1, $cards.FieldOut[0].Len).Trim() -ne '' }).Count
Start-MockFc
$r = & $run -Case 'REF_FUSBA2_L766' -Dll 'ASSURFED_UTILIT_FUSBA2_ASCII.dll' -Inputs @{ MAJ = "$d\MAJ.bin"; INP = "$d\INP.bin" } -ExpectedName 'OUT' -ExpectedFile "$d\OUT.expected" -Binaries $Binaries
$r.Detail = "MAJ $($maj.Count), INP $($inp.Count), OUT $($out.Count) records ($matched with a MAJ update). " + $r.Detail
$results += $r

# ---- round trips from the catalog
foreach ($pair in $catalog.RoundTrips) {
  $load = $set[$pair.Load]; $unload = $set[$pair.Unload]
  if (-not $load -or -not $unload) { $results += [pscustomobject]@{ Case = "REF_$($pair.Load)"; Result = 'SKIP'; Exit = ''; Detail = "not in the generated set: $($pair.Load) / $($pair.Unload)" }; continue }
  $results += Invoke-IndexedRoundTrip -Load $load -Unload $unload -Work $Work -Binaries $Binaries -Seed ($Seed + 1)
}

# observation, not a pass/fail: keys out of order. For a sequential load into an indexed file COBOL raises INVALID KEY (status 21) and this program then aborts.
if ($set['LOADIS_ASCII']) {
  $cl = Get-SgsCards $set['LOADIS_ASCII'].Cards
  $len = $cl.Input[0].Len; $ko = $cl.KeyIs[0].Offset; $kl = $cl.KeyIs[0].Len
  $rnd = [Random]::new($Seed + 2)
  $keys = 1..40 | ForEach-Object { 'R' + ('{0:D7}' -f $rnd.Next(1, 9999999)) } | Sort-Object -Unique
  $bad = @(foreach ($k in ($keys | Sort-Object { $rnd.Next() })) { Set-At (New-Text $rnd $len) ($ko + 1) $k.Substring(0, $kl) })
  $d = Join-Path $Work 'LOADIS_UNSORTED'; New-Item -ItemType Directory -Force $d | Out-Null
  Write-Records "$d\shuffled.bin" $bad
  Start-MockFc
  $r3 = & $run -Case 'OBS_LOADIS_UNSORTED' -Dll $set['LOADIS_ASCII'].Dll -Inputs @{ $cl.Input[0].Name = "$d\shuffled.bin" } -KeepOutputAs $cl.Output[0].Name -KeepOutputTo "$d\loaded-unsorted.dat" -Binaries $Binaries
  $written = if (Test-Path "$d\loaded-unsorted.dat") { [Math]::Floor((Get-Item "$d\loaded-unsorted.dat").Length / ($len + 2)) } else { 0 }
  $r3.Result = 'NOTE'
  $r3.Detail = "keys in random order: exit $($r3.Exit), $written of $($bad.Count) records written. COBOL would raise INVALID KEY on the first out-of-order key (error message, then abort); this runtime accepts the call and silently skips them."
  $results += $r3
}

# ---- CHAB100_ASCII, call EUPD01 line 15: one data card -> one output record
if ($set['CHAB100_ASCII']) {
  $c = $set['CHAB100_ASCII']; $cc = Get-SgsCards $c.Cards
  $d = Join-Path $Work 'CHAB100'; New-Item -ItemType Directory -Force $d | Out-Null
  $reader = New-CardReaderInput $c $d
  $dataCards = @(Get-DataCards $c.Runstream $c.Line)
  if (-not $reader.Count -or -not $dataCards.Count) { $results += [pscustomobject]@{ Case = 'REF_CHAB100_ASCII'; Result = 'SKIP'; Exit = ''; Detail = 'no card reader or no data cards found' } }
  else {
    Write-Records "$d\expected.bin" @(Set-Length $dataCards[0] $cc.Output[0].Len)
    Start-MockFc
    $r4 = & $run -Case 'REF_CHAB100_ASCII' -Dll $c.Dll -Inputs $reader -ExpectedName $cc.Output[0].Name -ExpectedFile "$d\expected.bin" -Binaries $Binaries
    $r4.Detail = "data card '$($dataCards[0])' from the run stream; expected one $($cc.Output[0].Len)-byte record. " + $r4.Detail
    # T3-032: the card reader has no external name, and the mock runtime does not read <name>.DAT for it, so no card arrives
    if ($r4.Result -eq 'FAIL' -and $r4.Detail -match 'actual 0 bytes') { $r4.Result = 'BLOCKED'; $r4.Detail += ' No card was read: card-reader input is not supplied by the mock (T3-032).' }
    $results += $r4
  }
}
Stop-MockFc

$results | ForEach-Object { '{0,-22} {1,-6} {2}' -f $_.Case, $_.Result, $_.Detail }
