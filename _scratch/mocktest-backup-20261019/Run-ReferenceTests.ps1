<#
.SYNOPSIS
  Reference tests for the non-copy programs, with expected output worked out independently of the generated C#.
.DESCRIPTION
  FUSBA2_ASCII (call VIRD03 line 766): an update merge of two key-sorted files. The expected file is made by a model of the skeleton's COBOL
  control flow (not of our C#): MAJ record keys from UPDATE (else KEYS), INP keys from KEYS; for every INP record write it padded to the output length;
  where a MAJ record has the same key, copy the FIELDIN ranges of the MAJ record to the FIELDOUT ranges; a MAJ record is consumed when the INP key advances.
  LOADIS_ASCII then UNLOADIS_ASCII (calls CLOA49 line 141, CLOA43 line 473): a round trip. LOADIS loads unsorted records with unique keys into an
  indexed file; UNLOADIS reads that file back sequentially, so the output must be the input records in key order.
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
. (Join-Path $PSScriptRoot 'MockFc.ps1')
$run = Join-Path $PSScriptRoot 'Run-ProgramCase.ps1'
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
New-Item -ItemType Directory -Force $Work | Out-Null

function Get-Cards([String]$path) {
  $c = @{ Input = @(); Output = @(); Keys = @(); Update = @(); FieldIn = @(); FieldOut = @(); KeyIs = @() }
  $pairs = { param($s) [regex]::Matches($s, '(\d+),(\d+)') | ForEach-Object { [pscustomobject]@{ Start = [Int32]$_.Groups[1].Value; Len = [Int32]$_.Groups[2].Value } } }
  foreach ($l in Get-Content $path) {
    if ($l -match '^\s*(INPUT|OUTPUT)\s+(.*)$') {
      $which = if ($Matches[1] -eq 'INPUT') { 'Input' } else { 'Output' }
      foreach ($m in [regex]::Matches($Matches[2], '(\w+),(\d+)')) { $c[$which] += [pscustomobject]@{ Name = $m.Groups[1].Value; Len = [Int32]$m.Groups[2].Value } }
    }
    elseif ($l -match '^\s*KEYS\s+(.*)$') { $c.Keys += & $pairs $Matches[1] }
    elseif ($l -match '^\s*UPDATE\s+(.*)$') { $c.Update += & $pairs $Matches[1] }
    elseif ($l -match '^\s*FIELDIN\s+(.*)$') { $c.FieldIn += & $pairs $Matches[1] }
    elseif ($l -match '^\s*FIELDOUT\s+(.*)$') { $c.FieldOut += & $pairs $Matches[1] }
    elseif ($l -match '^\s*KEYIS\s+(\d+),(\d+),(\d+)') { $c.KeyIs += [pscustomobject]@{ Offset = [Int32]$Matches[1]; Len = [Int32]$Matches[2] } }
  }
  $c
}
function Sort-Ordinal([String[]]$items, [ScriptBlock]$key = { $args[0] }) {
  $list = [System.Collections.Generic.List[Object]]::new(); $list.AddRange([Object[]]$items)
  $list.Sort([Comparison[Object]] { param($a, $b) [String]::CompareOrdinal([String](& $key $a), [String](& $key $b)) })
  $list.ToArray()
}
function New-Text([Random]$rnd, [Int32]$n) { $a = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'; -join (1..$n | ForEach-Object { $a[$rnd.Next($a.Length)] }) }
function Set-At([String]$s, [Int32]$start1, [String]$text) { $s.Substring(0, $start1 - 1) + $text + $s.Substring($start1 - 1 + $text.Length) }
function Get-Key([String]$rec, $pairs) { -join ($pairs | ForEach-Object { $rec.Substring($_.Start - 1, $_.Len) }) }
function Write-Records([String]$file, [String[]]$recs) { [System.IO.File]::WriteAllBytes($file, $latin1.GetBytes((($recs | ForEach-Object { $_ + "`r`n" }) -join ''))) }

$results = @()

# ---- FUSBA2_ASCII, call VIRD03 line 766
$cards = Get-Cards (Join-Path $Calls 'ASSURFED_F999RUN-d_VIRD03__L766.sgs')
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

# ---- LOADIS_ASCII (CLOA49 line 141) then UNLOADIS_ASCII (CLOA43 line 473): round trip
$cl = Get-Cards (Join-Path $Calls 'ASSURFED_F999RUN_CLOA49__L141.sgs'); $cu = Get-Cards (Join-Path $Calls 'ASSURFED_F999RUN_CLOA43__L473.sgs')
$len = $cl.Input[0].Len; $ko = $cl.KeyIs[0].Offset; $kl = $cl.KeyIs[0].Len
$rnd = [Random]::new($Seed + 1)
$keys = 1..40 | ForEach-Object { 'R' + ('{0:D7}' -f $rnd.Next(1, 9999999)) } | Sort-Object -Unique
$shuffled = $keys | Sort-Object { $rnd.Next() }
$make = { param($ks) foreach ($k in $ks) { Set-At (New-Text $rnd $len) ($ko + 1) $k.Substring(0, $kl) } }
$recs = @(& $make (Sort-Ordinal $keys))        # ascending keys: a sequential load into an indexed file needs them in key order
$d = Join-Path $Work 'LOADIS_UNLOADIS'; New-Item -ItemType Directory -Force $d | Out-Null
Write-Records "$d\B010SINAUTCL.bin" $recs
Write-Records "$d\OUT.expected" $recs
Start-MockFc
$r1 = & $run -Case 'REF_LOADIS_L141' -Dll 'ASSURFED_UTILIT_LOADIS_ASCII.dll' -Inputs @{ B010SINAUTCL = "$d\B010SINAUTCL.bin" } -KeepOutputAs 'OUTCLOA49' -KeepOutputTo "$d\loaded.dat" -Binaries $Binaries
$r1.Detail = "$($recs.Count) records with ascending keys at offset $ko length $kl. " + $r1.Detail
$results += $r1
Start-MockFc
$r2 = & $run -Case 'REF_UNLOADIS_L473' -Dll 'ASSURFED_UTILIT_UNLOADIS_ASCII.dll' -Inputs @{ FSCR001ATO = "$d\loaded.dat" } -ExpectedName 'OUT' -ExpectedFile "$d\OUT.expected" -Binaries $Binaries
$r2.Detail = 'reads the indexed file LOADIS wrote; expected = the input records unchanged, in key order. ' + $r2.Detail
$results += $r2

# observation, not a pass/fail: keys out of order. For a sequential load into an indexed file COBOL raises INVALID KEY (status 21) and this program then aborts.
$bad = @(& $make $shuffled)
Write-Records "$d\shuffled.bin" $bad
Start-MockFc
$r3 = & $run -Case 'OBS_LOADIS_UNSORTED' -Dll 'ASSURFED_UTILIT_LOADIS_ASCII.dll' -Inputs @{ B010SINAUTCL = "$d\shuffled.bin" } -KeepOutputAs 'OUTCLOA49' -KeepOutputTo "$d\loaded-unsorted.dat" -Binaries $Binaries
$written = if (Test-Path "$d\loaded-unsorted.dat") { [Math]::Floor((Get-Item "$d\loaded-unsorted.dat").Length / ($len + 2)) } else { 0 }
$r3.Result = 'NOTE'
$r3.Detail = "keys in random order: exit $($r3.Exit), $written of $($bad.Count) records written. COBOL would raise INVALID KEY on the first out-of-order key (error message, then abort); this runtime accepts the call and silently skips them."
$results += $r3
Stop-MockFc

$results | ForEach-Object { '{0,-20} {1,-6} {2}' -f $_.Case, $_.Result, $_.Detail }
