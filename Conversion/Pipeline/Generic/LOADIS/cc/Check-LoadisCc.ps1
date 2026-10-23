# After SSG4_LOADIS_CASES: L (hand-off) vs S (static LOADIS): DAT byte-identical, .Index byte-identical apart from the
# header path; U (UNLOADIS) vs the independent expected files.
param([String]$Environment = 'CC-Trial')
. "$(Split-Path (Split-Path $PSScriptRoot))\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$x = $ge.ExtractPath
$ref = $ge.MockRef
$ev = "$($ge.GenericWork)\LOADIS\cc-runs\CASES"
New-Item -ItemType Directory -Force $ev | Out-Null
$enc = [Text.Encoding]::GetEncoding(28591)
function Find-Out([String]$Dir, [String]$Name) { foreach ($n in $Name, "$Name.DAT") { if (Test-Path "$Dir\$n") { return "$Dir\$n" } }; $null }
$sets = @(
  @{ Tag = 'A'; Out = 'OUTCLOA49'; UOut = 'OUT'; Exp = "$ref\LOADIS_ASCII-UNLOADIS_ASCII\expected.bin" }
  @{ Tag = 'M'; Out = 'F006GRS'; UOut = 'OUTVIGA50'; Exp = "$ref\LOADIS_MULTI-UNLOADIS_MULTI\expected.bin" }
)
$problems = 0
foreach ($t in $sets) {
  $q0 = "LDS$($t['Tag'])0"; $q1 = "LDS$($t['Tag'])1"
  $s = Find-Out "$x\$q0" $t['Out']; $l = Find-Out "$x\$q1" $t['Out']; $u = Find-Out "$x\$q1" $t['UOut']
  if (-not ($s -and $l -and $u)) { "$($t['Tag']): missing output (static $s / load $l / unload $u)"; $problems++; continue }
  Get-Item $s, "$s.Index", $l, "$l.Index", $u -ErrorAction SilentlyContinue | ForEach-Object { Copy-Item $_.FullName (Join-Path $ev ($_.Directory.Name + '_' + $_.Name)) -Force }
  $datOk = (Get-FileHash $s).Hash -eq (Get-FileHash $l).Hash
  $si = [IO.File]::ReadAllBytes("$s.Index"); $li = [IO.File]::ReadAllBytes("$l.Index")
  $sPath = $enc.GetString($si, 16, 255).TrimEnd(); $lPath = $enc.GetString($li, 16, 255).TrimEnd()
  # the runtime's header path holds the job's TPF$ folder name, so the path field (0x10, 255 bytes) is left out
  $cut = { param($b) [Convert]::ToBase64String($b[0..15]) + [Convert]::ToBase64String($b[271..($b.Length - 1)]) }
  $ixOk = (& $cut $si) -eq (& $cut $li)
  $uOk = (Get-FileHash $u).Hash -eq (Get-FileHash $t['Exp']).Hash
  '{0}: DAT L==S {1} ({2} B) | Index L==S {3} ({4} B) | UNLOADIS == expected {5} ({6} B)' -f $t['Tag'], $datOk, (Get-Item $l).Length, $ixOk, $li.Length, $uOk, (Get-Item $u).Length
  "   header S: $sPath"
  "   header L: $lPath"
  if (-not ($datOk -and $ixOk -and $uOk)) { $problems++ }
  foreach ($p in Get-ChildItem "$x\LDS$($t['Tag'])2" -Filter 'PROBE*.DAT' | ForEach-Object FullName) {
    if (-not (Test-Path "$p.Index")) { "   probe $(Split-Path $p -Leaf): no index"; continue }
    $pi = [IO.File]::ReadAllBytes("$p.Index")
    '   probe {0}: DAT == S {1} | Index == S apart from path {2} | key {3},{4} | {5} B' -f (Split-Path $p -Leaf), ((Get-FileHash $p).Hash -eq (Get-FileHash $s).Hash), ((& $cut $pi) -eq (& $cut $si)), [BitConverter]::ToInt32($pi, 0x115), [BitConverter]::ToInt32($pi, 0x119), $pi.Length
    Copy-Item $p, "$p.Index" $ev -Force
  }
}
"problems: $problems (evidence in $ev)"
exit $problems
