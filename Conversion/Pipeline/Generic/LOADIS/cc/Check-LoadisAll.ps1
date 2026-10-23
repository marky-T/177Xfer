# After SSG4_LOADIS_ALL: each case's output data file vs the expected one; for LOADIS also an independent parse of the
# .Index (header fields vs the KEYIS card and the data file, every entry's key vs the record it points to, key order).
param([String]$Environment = 'CC-Trial', [String]$Evidence)
. "$(Split-Path (Split-Path $PSScriptRoot))\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$Work = "$($ge.GenericWork)\LOADIS"
if (-not $Evidence) { $Evidence = "$Work\cc-runs\ALL" }
$x = $ge.ExtractPath
$enc = [Text.Encoding]::GetEncoding(28591)
New-Item -ItemType Directory -Force $Evidence | Out-Null
function Test-Index([String]$Dat, $C) {
  if (-not (Test-Path "$Dat.Index")) { return 'no .Index' }
  $b = [IO.File]::ReadAllBytes("$Dat.Index"); $d = [IO.File]::ReadAllBytes($Dat)
  $err = @()
  if ($enc.GetString($b, 0, 4) -ne '=W*2') { $err += 'magic' }
  if ([BitConverter]::ToInt32($b, 4) -ne 6) { $err += 'version' }
  if ([BitConverter]::ToInt64($b, 8) -ne $d.Length) { $err += "DAT length $([BitConverter]::ToInt64($b, 8)) vs $($d.Length)" }
  if ($b[0x10F] -ne 1 -or $b[0x110] -ne 1 -or [BitConverter]::ToInt32($b, 0x111) -ne 1) { $err += 'key count/flags' }
  if ([BitConverter]::ToInt32($b, 0x115) -ne $C.KeyOff -or [BitConverter]::ToInt32($b, 0x119) -ne $C.KeyLen) { $err += 'key offset/length' }
  $cnt = [BitConverter]::ToInt32($b, 0x123)
  if ($cnt -ne $C.Records) { $err += "entries $cnt vs $($C.Records)" }
  $ent = $C.KeyLen + 8
  if ($b.Length -ne 0x127 + $cnt * $ent) { $err += "index length $($b.Length)" }
  $prev = $null
  for ($i = 0; $i -lt $cnt -and $err.Count -lt 5; $i++) {
    $o = 0x127 + $i * $ent
    $k = $enc.GetString($b, $o, $C.KeyLen); $rn = [BitConverter]::ToInt64($b, $o + $C.KeyLen)
    $rk = $enc.GetString($d, [Int32]($rn * ($C.Len + 2)) + $C.KeyOff, $C.KeyLen)
    if ($k -ne $rk) { $err += "entry $i key [$k] vs record $rn [$rk]" }
    if ($null -ne $prev -and [String]::CompareOrdinal($k, $prev) -le 0) { $err += "entry $i not ascending" }
    $prev = $k
  }
  if ($err.Count) { $err -join '; ' } else { 'ok' }
}
$cases = Get-Content "$Work\all-cases.json" -Raw | ConvertFrom-Json
$bad = 0
$lines = foreach ($c in $cases) {
  $out = @("$x\$($c.Qual)\$($c.Out).DAT", "$x\$($c.Qual)\$($c.Out)") | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $out) { $bad++; '{0} {1,-8} {2,-12} FAIL no output' -f $c.Case, $c.Mode, $c.Call; continue }
  Copy-Item $out (Join-Path $Evidence "$($c.Case)_$(Split-Path $out -Leaf)") -Force
  $same = (Get-FileHash $out).Hash -eq (Get-FileHash $c.Expected).Hash
  $ix = if ($c.Mode -eq 'LOADIS') { Copy-Item "$out.Index" $Evidence -ErrorAction SilentlyContinue; Test-Index $out $c } else { 'n/a' }
  $ok = $same -and $ix -in 'ok', 'n/a'
  if (-not $ok) { $bad++ }
  '{0} {1,-8} {2,-12} {3} data {4} ({5} B) | index {6}' -f $c.Case, $c.Mode, $c.Call, $(if ($ok) { 'PASS' } else { 'FAIL' }), $(if ($same) { 'same' } else { 'DIFF' }), (Get-Item $out).Length, $ix
}
$lines += "$($cases.Count - $bad)/$($cases.Count) pass"
$lines | Set-Content "$Evidence\check-all.txt"
$lines
exit $bad
