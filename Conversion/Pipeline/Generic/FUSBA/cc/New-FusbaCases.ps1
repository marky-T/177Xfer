# FUSBA (MT-043): synthetic test cases for the generic program, 2 per mode, each from a real call's cards.
# Data hits every branch: update keys with and without masters, masters with 0-3 records per key, keys before/after the
# other file. Expected outputs come from FusbaModel.ps1 (matched the static FUSBA program and the FUSBA2 reference).
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$utility = Split-Path $PSScriptRoot
. "$(Split-Path $utility)\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = "$($ge.GenericWork)\FUSBA"
. "$utility\check\FusbaModel.ps1"
$root = "$work\cases"
$cardsDir = $ge.SgsCards
$calls = @(Import-Csv "$($ge.WorkRoot)\allcalls\expanded\FUSBA_ASCII-expansion.csv") + @(Import-Csv "$($ge.WorkRoot)\allcalls\expanded\FUSBA2_ASCII-expansion.csv")
. "$PSScriptRoot\FusbaCases.ps1"
$cases = $FusbaCases
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
$chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,-/'
function Put([String]$s, $fields, [String]$kv) { $o = 0; foreach ($k in $fields) { $s = $s.Substring(0, $k[0] - 1) + $kv.Substring($o, $k[1]) + $s.Substring($k[0] - 1 + $k[1]); $o += $k[1] }; $s }
$n = 0
foreach ($case in $cases.Keys) {
  $n++
  $parmName = $cases[$case]
  $call = $parmName -replace '^FUSBA2?_'
  $p = Read-FusbaParm (Get-Content "$work\parm\$parmName.parm")
  $rnd = [Random]::new(20261021 + 97 * $n)
  $dir = "$root\$case"
  New-Item -ItemType Directory -Force "$dir\input", "$dir\expected" | Out-Null
  Copy-Item (Join-Path $cardsDir ($calls | Where-Object Call -eq $call | Select-Object -First 1).CardFile) "$dir\cards.sgs" -Force
  $kl = 0; foreach ($k in $p.K2) { $kl += $k[1] }
  $pool = 1..40 | ForEach-Object { ('{0:D9}' -f (100 + $_ * 7)).Substring(9 - [Math]::Min(9, $kl)).PadRight($kl, '0') }
  $text = { param($len) -join (1..$len | ForEach-Object { $chars[$rnd.Next($chars.Length)] }) }
  # masters (file 2): 0-3 per key
  $f2 = foreach ($kv in $pool) { for ($m = $rnd.Next(0, 4); $m -gt 0; $m--) { Put (& $text $p.Ins[1][1]) $p.K2 $kv } }
  # updates (file 1): about half the keys, plus keys below / between / above every master key; unique, ascending
  $k1 = @($pool | Where-Object { $rnd.Next(0, 2) -eq 0 }) + @(('0' * $kl), ($pool[3].Substring(0, $kl - 1) + '5'), ('9' * $kl))
  $k1 = [String[]]@($k1 | Select-Object -Unique); [Array]::Sort($k1, [StringComparer]::Ordinal)
  $f1 = foreach ($kv in $k1) { Put (& $text $p.Ins[0][1]) $p.K1 $kv }
  [IO.File]::WriteAllText("$dir\input\$($p.Ins[0][0])", ($f1 -join "`r`n") + "`r`n", $latin1)
  [IO.File]::WriteAllText("$dir\input\$($p.Ins[1][0])", ($f2 -join "`r`n") + "`r`n", $latin1)
  $m = Invoke-FusbaModel $p @("$dir\input\$($p.Ins[0][0])", "$dir\input\$($p.Ins[1][0])") @($p.Outs | ForEach-Object { "$dir\expected\$($_[0])" })
  '{0,-3} {1,-22} mode {2} keys {3}/{4} moves {5} in {6} outs {7,-8} read {8,-6} written {9}' -f $case, $call, $p.Mode, $p.K1.Count, $p.K2.Count, $p.FM.Count, (($p.Ins | ForEach-Object { "$($_[0]):$($_[1])" }) -join ','), (($p.Outs | ForEach-Object { $_[1] }) -join '/'), ($m.Read -join '/'), ($m.Written -join '/')
}
