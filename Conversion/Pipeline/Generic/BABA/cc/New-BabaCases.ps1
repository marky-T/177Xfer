# BABA (MT-043): synthetic test cases for the generic program, one per shape, each from a real call's cards.
# Data hits every branch (value matches, non-matches, duplicates in ascending key order); expected outputs come from
# BabaModel.ps1, which matched the real static BABA program byte for byte (Test-BabaReference.ps1).
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$utility = Split-Path $PSScriptRoot
. "$(Split-Path $utility)\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = "$($ge.GenericWork)\BABA"
. "$utility\check\BabaModel.ps1"
$root = "$work\cases"
$cardsDir = $ge.SgsCards
$calls = Import-Csv "$($ge.WorkRoot)\allcalls\expanded\BABA_ASCII-expansion.csv"
$cases = [ordered]@{ E1 = '2PPJ11_L74'; R2 = '-d_AFID01_L76'; AM1 = '-d_AFPD03_L94'; RM2 = '-d_EXPD05_OP_L54'; C2 = '-d_VIRD13_MJ_L48'; RB2 = 'PAIJ01_PP_L69'; E19 = 'SINM05_L211' }
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
$chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-/'
foreach ($case in $cases.Keys) {
  $call = $cases[$case]
  $p = Read-BabaParm (Get-Content "$work\parm\$call.parm")
  # String.GetHashCode differs per process in .NET, so derive the seed from the case name
  $rnd = [Random]::new(20261020 + ([Linq.Enumerable]::Sum([Int32[]][char[]]$case) % 1000))
  $dir = "$root\$case"
  New-Item -ItemType Directory -Force "$dir\input", "$dir\expected" | Out-Null
  Copy-Item (Join-Path $cardsDir ($calls | Where-Object Call -eq $call).CardFile) "$dir\cards.sgs" -Force
  $keyLen = 0; foreach ($k in $p.Keys) { $keyLen += $k[1] }
  $recs = [System.Collections.Generic.List[String]]::new()
  $n = 30
  for ($i = 0; $i -lt $n; $i++) {
    $b = (-join (1..$p.In | ForEach-Object { $chars[$rnd.Next($chars.Length)] })).ToCharArray()
    if ($keyLen -gt 0) {
      if ($p.Seq -eq 'M') {
        # ascending keys, each value twice in a row (first -> output 1, duplicate -> output 2 or dropped)
        $kv = ([String]([Math]::Floor($i / 2))).PadLeft([Math]::Min($keyLen, 9), '0').PadRight($keyLen, '0')
      } elseif ($p.Sets.Count -and $rnd.Next(2) -eq 0) {
        $kv = $p.Sets[$rnd.Next($p.Sets.Count)].Replace(';', '<')
      } else {
        $kv = -join (1..$keyLen | ForEach-Object { $chars[$rnd.Next($chars.Length)] })
      }
      $o = 0
      foreach ($k in $p.Keys) { for ($j = 0; $j -lt $k[1]; $j++) { $b[$k[0] - 1 + $j] = $kv[$o + $j] }; $o += $k[1] }
    }
    $recs.Add((-join $b))
  }
  $inName = $p.InName
  [IO.File]::WriteAllText("$dir\input\$inName", ($recs -join "`r`n") + "`r`n", $latin1)
  $outFiles = @($p.Outs | ForEach-Object { "$dir\expected\$($_[0])" })
  $m = Invoke-BabaModel $p "$dir\input\$inName" $outFiles
  '{0,-4} {1,-18} mode {2,-3} seq {3} keys {4} sets {5,2} in {6,4}  outs {7,-9} written {8,-7} dropped {9,2}{10}' -f $case, $call, $p.Mode, $p.Seq, $p.Keys.Count, $p.Sets.Count, $p.In, (($p.Outs | ForEach-Object { $_[1] }) -join '/'), ($m.Written -join '/'), $m.Dropped, $(if ($m.Abort) { "  ABORT at $($m.Abort)" } else { '' })
}
