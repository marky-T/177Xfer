# CONDIS2 (MT-043) test cases: case -> call (check\parm\<call>.parm) and a generator of the input records.
# Each generator gets the parsed parm ($p, CondisModel.ps1) and a seeded Random ($rnd).
$CondisChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-/'
function New-CondisRec([Int32]$Len, $Rnd) { -join (1..$Len | ForEach-Object { $CondisChars[$Rnd.Next($CondisChars.Length)] }) }
function Set-CondisField([String]$Rec, [Int32]$Pos, [String]$Text) { $Rec.Substring(0, $Pos - 1) + $Text + $Rec.Substring($Pos - 1 + $Text.Length) }
# Puts a value from $Pool into every date-MOVE input field of the call (by code).
function Set-CondisDates([String]$Rec, $P, [Hashtable]$Pools, [Int32]$N) {
  $k = 0
  foreach ($g in $P.Groups) { foreach ($o in $g.Ops) { if ($o[0] -eq 'M' -and $o[5]) { $pool = $Pools[$o[5]]; $Rec = Set-CondisField $Rec $o[1] $pool[($N + $k) % $pool.Count]; $k++ } } }
  $Rec
}
$CondisPools = @{
  D42 = @('1985', '1999', '2000', '2005', '2009', '2010', '2015', '2019', '2020', '2025', '2029', '2035', '2040', '    ', 'ABCD', '200A', '0000')
  D24 = @('00', '  ', '85', ';5', '_3', '|9', '~1', 'A1', '99', '0 ')
  D68 = @('      ', '000000', ';51231', '_00101', '|91231', '~11111', '851231', 'ABCDEF', '0 1231', ';     ')
}

$CondisCases = [ordered]@{
  # no CASE: 4 date MOVEs D42, 408 -> 400; one short record
  D42 = @{ Call = 'AUMH01_D3_L87'; Make = { param($p, $rnd)
      foreach ($n in 0..19) { Set-CondisDates (New-CondisRec $p.In $rnd) $p $CondisPools $n }
      'SHORT RECORD 1999' } }
  # D24 and D68, 204 -> 214
  DT = @{ Call = 'AUPA02_MJ_L68'; Make = { param($p, $rnd) foreach ($n in 0..19) { Set-CondisDates (New-CondisRec $p.In $rnd) $p $CondisPools $n } } }
  # MOVE + CONST, 80 -> 200
  BD = @{ Call = 'PAIJ01_BD_L58'; Make = { param($p, $rnd) foreach ($n in 0..11) { Set-CondisDates (New-CondisRec $p.In $rnd) $p $CondisPools $n } } }
  # 4 CASEs on double-quoted blank values (T3-028) + OTHERWISE, D42
  UL = @{ Call = 'PAIJ01_UL_L85'; Make = { param($p, $rnd)
      foreach ($n in 0..14) {
        $r = Set-CondisDates (New-CondisRec $p.In $rnd) $p $CondisPools $n
        switch ($n % 5) {
          0 { $r = Set-CondisField (Set-CondisField (Set-CondisField $r 74 '  ') 81 '     ') 1 '0000' }
          1 { $r = Set-CondisField (Set-CondisField (Set-CondisField $r 74 '  ') 81 '     ') 1 '1999' }
          2 { $r = Set-CondisField (Set-CondisField (Set-CondisField $r 74 'XX') 76 '  ') 50 '0000' }
          3 { $r = Set-CondisField (Set-CondisField (Set-CondisField $r 74 'XX') 76 '  ') 50 '2015' }
          4 { $r = Set-CondisField $r 74 'XXXX' }
        }
        $r
      } } }
  # 34 one-byte CASEs (incl. ISO-8859-1 bytes) + CONST + OTHERWISE, 132 -> 132
  UE = @{ Call = 'VIRJ01_UE_L850'; Make = { param($p, $rnd)
      $vals = @($p.Groups | ForEach-Object { $_.Tests } | ForEach-Object { $_[2] }) + @('Z', 'x', ' ', 'S')
      foreach ($v in $vals) { Set-CondisField (New-CondisRec $p.In $rnd) 42 $v } } }
  # CASE 214,2,01 + OTHERWISE, 231 -> 231
  VG = @{ Call = '-d_VIGD03_L894'; Make = { param($p, $rnd) foreach ($n in 0..9) { Set-CondisField (New-CondisRec $p.In $rnd) 214 @('01', '02', '1 ', '01', ' 1')[$n % 5] } } }
}
