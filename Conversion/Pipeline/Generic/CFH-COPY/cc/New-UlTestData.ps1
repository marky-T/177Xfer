# Test data for the UL CFH-COPY layout (no static program could be built for it, T3-028, so there is no reference run):
# 25 synthetic 900-byte records; the reference applies the cards by hand (copy the record, spaces at 71..78).
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
. "$(Split-Path (Split-Path $PSScriptRoot))\GnEnvironment.ps1"
$root = "$((Get-GnEnvironment $Environment).MockRoot)\VIRM01_UL"
New-Item -ItemType Directory -Force "$root\input", "$root\expected" | Out-Null
$rnd = [Random]::new(20261020)
$chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,-/<>'
$in = foreach ($n in 1..25) { 'KTMAJ' + $n.ToString('D4') + (-join (1..891 | ForEach-Object { $chars[$rnd.Next($chars.Length)] })) }
$exp = foreach ($r in $in) { $r.Substring(0, 70) + (' ' * 8) + $r.Substring(78) }
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
[IO.File]::WriteAllText("$root\input\I006KTMAJ1", ($in -join "`r`n") + "`r`n", $latin1)
[IO.File]::WriteAllText("$root\expected\F006KTMAJ3", ($exp -join "`r`n") + "`r`n", $latin1)
Get-ChildItem $root -Recurse -File | ForEach-Object { '{0} {1:N0} B' -f $_.FullName, $_.Length }
'records 900 B: ' + (@($in | Where-Object Length -eq 900).Count) + ' / 25; bytes 71-78 differ in ' + (@(0..24 | Where-Object { $in[$_].Substring(70, 8) -ne $exp[$_].Substring(70, 8) }).Count) + ' records'
