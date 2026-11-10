<#
.SYNOPSIS
  CONDIS2 step G3: writes the seeded test cases <Out>\<case>\{cards.sgs, input.dat, case.json} and <Out>\cases.json.
  ALL DATA HERE IS TEST DATA (synthetic records; cards are either copies of the real calls' cards or invented). No client data.
  Deterministic: fixed seeds, no clock. Run again -> identical files.
#>
param(
  [String]$Out = "$PSScriptRoot\cases",
  [String]$CardsDir = 'E:\Repos\ssg4-work\sgs-cards'
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\CondisModel.ps1" -LibraryOnly
$enc = [Text.Encoding]::GetEncoding(1252)
New-Item -ItemType Directory -Force $Out | Out-Null

$pool = @{
  D42  = '1985', '1999', '2000', '2005', '2009', '2010', '2015', '2019', '2020', '2029', '2030', '2039', '2040', '1900', '    ', '0000', 'ABCD'
  D24  = '00', '  ', '85', ';5', '_3', '|7', '~9', 'A1', '05'
  D22A = '05', '15', '25', '35', '95', '  ', 'AB', '00'
  D22B = ';5', '_5', '|5', '~5', '05', '  ', ';;'
  D66A = '050630', '150630', '250115', '350101', '450101', '051301', '050631', '050600', '05AB30', '      ', '000000', '151535'
  D66B = ';50630', '_50630', '|50630', '~50630', '050630', '      ', ';50631'
  D68  = '      ', '000000', '850630', ';50101', '_30415', '|10101', '~91231', 'XYZ123', '991231', '051301'
  D86  = '20050630', '20150630', '20250115', '20350101', '19990101', '20451231', '20051301', '20050631', '20050600', '200506AB', '        ', '00000000', '20450101'
}
$alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789   '

function New-Records($Cards, [Int32]$Count, [Int32]$Seed, [Switch]$Ragged) {
  $rnd = New-Object System.Random $Seed
  $groups = @($Cards.Pg | Where-Object Type -eq 'CASE')
  $recs = New-Object System.Collections.Generic.List[String]
  for ($r = 0; $r -lt $Count; $r++) {
    $c = New-Object 'Char[]' $Cards.InLen
    for ($i = 0; $i -lt $c.Length; $i++) { $c[$i] = $alphabet[$rnd.Next($alphabet.Length)] }
    foreach ($g in $Cards.Pg) {
      if ($g.Type -ne 'MOVE') { continue }
      foreach ($f in $g.Fields) {
        if ($f.Count -ge 4 -and $pool.ContainsKey($f[3].ToUpperInvariant())) {
          $v = $pool[$f[3].ToUpperInvariant()][$rnd.Next($pool[$f[3].ToUpperInvariant()].Count)]
          Set-Part $c ([Int32]$f[0]) $v
        }
      }
    }
    if ($groups.Count -and $rnd.Next(100) -lt 80) {
      $g = $groups[$rnd.Next($groups.Count)]
      foreach ($f in $g.Fields) { Set-Part $c ([Int32]$f[0]) ($f[2].PadRight([Int32]$f[1]).Substring(0, [Int32]$f[1])) }
    }
    $s = -join $c
    if ($Ragged -and $r % 7 -eq 3) { $s = $s.Substring(0, $rnd.Next($s.Length)) }
    $recs.Add($s.TrimEnd("`r", "`n"))
  }
  $recs
}

$index = New-Object System.Collections.Generic.List[Object]
function Add-Case([String]$Name, [String[]]$CardLines, [String[]]$Records, [String]$Source, [String]$Expectation, [String]$Note) {
  $d = New-Item -ItemType Directory -Force (Join-Path $Out $Name)
  [IO.File]::WriteAllText("$d\cards.sgs", (($CardLines -join "`r`n") + "`r`n"), $enc)
  [IO.File]::WriteAllText("$d\input.dat", ((@($Records) | ForEach-Object { $_ + "`r`n" }) -join ''), $enc)
  $meta = [ordered]@{ case = $Name; label = 'TEST DATA'; cards = $Source; expectedClass = $Expectation; records = @($Records).Count; note = $Note }
  $meta | ConvertTo-Json | Set-Content "$d\case.json" -Encoding UTF8
  $index.Add([pscustomobject]$meta)
}

# --- real calls' cards (copies), synthetic records ---
$seed = 261105
foreach ($c in (Import-Csv "$CardsDir\sgs-calls.csv" | Where-Object ProgramKey -eq 'CONDIS2_ASCII')) {
  $id = $c.CardFile -replace '^calls\\ASSURFED_F999RUN', '' -replace '\.sgs$', '' -replace '__', '_' -replace '^_', '' -replace '^-d_', ''
  $lines = [IO.File]::ReadAllLines("$CardsDir\$($c.CardFile)", $enc)
  $tmp = Join-Path $env:TEMP "condis-$id.sgs"; [IO.File]::WriteAllLines($tmp, $lines, $enc)
  $cards = Read-CondisCards $tmp; Remove-Item $tmp
  $n = if (@($cards.Pg | Where-Object Type -eq 'CASE').Count -gt 10) { 120 } else { 40 }
  Add-Case "real-$id" $lines (New-Records $cards $n (++$seed)) "real call $($c.RunId) line $($c.Line)" 'OBSERVED_IN_FEDERALE_SOURCE (cards); records are test data' 'cards of a real call, synthetic records with injected date values and CASE hits'
}

# --- invented cards ---
$alldates = @('ASCII', 'FILEIN 50,10', 'FILEOUT 50,10',
  'PG MOVE 1,4,1,D42 5,2,3,D24 7,2,7,D22A 9,2,9,D22B 11,6,11,D66A 17,6,17,D66B 23,6,23,D68 31,8,31,D86 39,10,37 45,2,47,D22A')
$t = Join-Path $env:TEMP 'condis-t.sgs'; [IO.File]::WriteAllLines($t, $alldates, $enc)
Add-Case 'syn-all-date-codes' $alldates (New-Records (Read-CondisCards $t) 80 (++$seed)) 'invented' 'DERIVED_WORKING_MODEL' 'every date code D24 D42 D22A D22B D66A D66B D68 D86 (the last five are not used by real calls); two D22A fields in one record'

$caseOnly = @('FILEIN 30,10', 'FILEOUT 20,10', 'PG CASE 1,1,A', 'PG MOVE 2,5,1', 'PG CASE 1,1,B 7,2,xy', 'PG MOVE 9,10,6', 'PG CONST 20,1,Z')
[IO.File]::WriteAllLines($t, $caseOnly, $enc)
Add-Case 'syn-case-no-otherwise' $caseOnly (New-Records (Read-CondisCards $t) 60 (++$seed)) 'invented' 'DERIVED_WORKING_MODEL' 'two CASE groups (the second with two AND fields), no OTHERWISE: records matching none are not written (box in the report)'

$constOverlap = @('FILEIN 20,10', 'FILEOUT 20,10', 'PG MOVE 1,10,1 3,4,8', 'PG CONST 5,3,abcdef 18,5,Q')
[IO.File]::WriteAllLines($t, $constOverlap, $enc)
Add-Case 'syn-const-overlap' $constOverlap (New-Records (Read-CondisCards $t) 20 (++$seed)) 'invented' 'DERIVED_WORKING_MODEL' 'later fields overwrite earlier ones; CONST value longer than its length is cut, shorter is space padded; field running past the output record is cut'

$quoted = @('FILEIN 12,10', 'FILEOUT 12,10', "PG CASE 1,3,''A B'' 5,2,''  ''", 'PG MOVE 1,12,1', 'PG CASE 1,2,a', 'PG CONST 12,1,Y', 'PG OTHERWISE', 'PG CONST 1,3,---')
$recQ = @('A B  xxxxxxx', 'A B1 xxxxxxx', 'A B   xxxxxx', 'a b  xxxxxxx', 'ab  zzzzzzzz', 'aB  zzzzzzzz', 'a   zzzzzzzz', 'Qq  zzzzzzzz')
Add-Case 'syn-quoted-spaces' $quoted $recQ 'invented' 'DERIVED_WORKING_MODEL' 'values with spaces (method 2 quoting), case-sensitive value compare, OTHERWISE with CONST only'

$d42 = @('FILEIN 8,10', 'FILEOUT 8,10', 'PG MOVE 1,4,1,D42 5,4,5')
$recD = '1899abcd', '1900abcd', '1999abcd', '2000abcd', '2009abcd', '2010abcd', '2019abcd', '2020abcd', '2029abcd', '2030abcd', '2039abcd', '2040abcd', '    abcd', '0000abcd', 'A999abcd', '2A10abcd', '19 9abcd', '~~~~abcd', '2000', '20'
Add-Case 'syn-d42-boundaries' $d42 $recD 'invented' 'DERIVED_WORKING_MODEL' 'D42 range edges and non-digit years (UNKNOWN 6: ASCII collation assumed); last two records are short (UNKNOWN 3)'

$shortLong = @('FILEIN 20,10', 'FILEOUT 20,10', 'PG MOVE 1,20,1')
$recS = '', 'a', 'abcde', '1234567890123456789', '12345678901234567890', '123456789012345678901', '123456789012345678901234567890'
Add-Case 'syn-short-long-records' $shortLong $recS 'invented' 'DERIVED_WORKING_MODEL' 'records shorter and longer than FILEIN length (UNKNOWN 3): padded with spaces / cut'

$prelude = @('FILEIN 30,10', 'FILEOUT 30,10', 'PG MOVE 1,5,1', 'PG CONST 6,1,P', 'PG CASE 7,1,A', 'PG MOVE 8,5,10', 'PG OTHERWISE', 'PG MOVE 8,2,20')
$recP = 'abcdeXAfghij', 'abcdeXBfghij', 'abcdeXAklmno', 'zzzzzzzzzzzz'
Add-Case 'odd-prelude-move' $prelude $recP 'invented' 'DERIVED_WORKING_MODEL' 'MOVE/CONST before the first CASE (runs for every record), then CASE + OTHERWISE; no real call'
$othFirst = @('FILEIN 20,10', 'FILEOUT 20,10', 'PG MOVE 1,3,1', 'PG OTHERWISE', 'PG MOVE 4,3,5')
Add-Case 'odd-otherwise-first' $othFirst @('abcdefgh', 'ABCDEFGH', 'x') 'invented' 'UNRESOLVED_UNISYS_SEMANTIC (T3-056: the skeleton''s [*CASE] test on OTHERWISE; what 2200 does with it is not known)' 'OTHERWISE before any CASE; expectation = the source text as written, not a known 2200 result. OTHERWISE as first condition: as written (bare NOCASE <> 1 true) it always starts with a TAIL; the actions after it never run; no real call'
$caseAfter = @('FILEIN 20,10', 'FILEOUT 20,10', 'PG CASE 1,1,A', 'PG MOVE 2,3,1', 'PG OTHERWISE', 'PG MOVE 5,3,1', 'PG CASE 1,1,B', 'PG MOVE 9,3,1')
Add-Case 'odd-case-after-otherwise' $caseAfter @('Abcdefghijkl', 'Bbcdefghijkl', 'Cbcdefghijkl') 'invented' 'DERIVED_WORKING_MODEL' 'CASE after OTHERWISE: as written the OTHERWISE actions catch every record that is not the first CASE, counted in NB-REC-CASE-2; no real call'

$neg = [ordered]@{
  'abort-v1-case-without-move' = @('FILEIN 10,10', 'FILEOUT 10,10', 'PG CASE 1,1,A', 'PG CASE 1,1,B', 'PG MOVE 1,5,1')
  'abort-v2v3-two-otherwise'   = @('FILEIN 10,10', 'FILEOUT 10,10', 'PG CASE 1,1,A', 'PG MOVE 1,5,1', 'PG OTHERWISE', 'PG OTHERWISE')
  'abort-v4-two-move'          = @('FILEIN 10,10', 'FILEOUT 10,10', 'PG MOVE 1,5,1', 'PG MOVE 6,5,6')
  'abort-v5-two-const'         = @('FILEIN 10,10', 'FILEOUT 10,10', 'PG CONST 1,1,A', 'PG CONST 2,1,B')
  'abort-v6-unknown-card'      = @('FILEIN 10,10', 'FILEOUT 10,10', 'PG MOVEX 1,5,1')
  'abort-v7-date-length'       = @('FILEIN 10,10', 'FILEOUT 10,10', 'PG MOVE 1,3,1,D42')
  'abort-v7-unknown-code'      = @('FILEIN 10,10', 'FILEOUT 10,10', 'PG MOVE 1,4,1,D99')
}
foreach ($k in $neg.Keys) { Add-Case $k $neg[$k] @() 'invented' 'OBSERVED_IN_FEDERALE_SOURCE' 'the skeleton''s own card check fails: the hand-off must Abort before the Xqt; nothing is produced' }

Remove-Item $t -ErrorAction SilentlyContinue
$index | ConvertTo-Json | Set-Content "$Out\cases.json" -Encoding UTF8
"cases written: $($index.Count) in $Out (all labelled TEST DATA)"
