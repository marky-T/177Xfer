# BABA step 0: edge cases in the real cards that the generic program must handle. Prints counts and examples.
param([String]$Environment = 'CC-Trial')
. "$(Split-Path (Split-Path $PSScriptRoot))\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$calls = Import-Csv "$($ge.WorkRoot)\allcalls\expanded\BABA_ASCII-expansion.csv"
$unordered = [System.Collections.Generic.List[String]]::new(); $overlap = [System.Collections.Generic.List[String]]::new()
$maxk = 0; $maxlen = 0
foreach ($c in $calls) {
  $k = Get-Content (Join-Path $ge.SgsCards $c.CardFile) | Where-Object { $_ -match '^\s*KEYS\s' } | Select-Object -First 1
  if (-not $k) { continue }
  $p = @($k.Trim() -split '\s+')
  $spans = [System.Collections.Generic.List[int[]]]::new()
  for ($j = 2; $j -lt $p.Count; $j++) { $s = $p[$j] -split ','; $spans.Add([int[]]@([int]$s[0], [int]$s[1])) }
  $maxk = [Math]::Max($maxk, $spans.Count)
  $tot = 0; foreach ($s in $spans) { $tot += $s[1] }; $maxlen = [Math]::Max($maxlen, $tot)
  for ($i = 1; $i -lt $spans.Count; $i++) { if ($spans[$i][0] -lt $spans[$i - 1][0]) { $unordered.Add($c.Call); break } }
  $sorted = @($spans.ToArray() | Sort-Object { $_[0] })
  for ($i = 1; $i -lt $sorted.Count; $i++) { if ($sorted[$i][0] -lt $sorted[$i - 1][0] + $sorted[$i - 1][1]) { $overlap.Add($c.Call); break } }
}
"key fields not in position order: $($unordered.Count)  $($unordered -join ', ')"
"overlapping key fields: $($overlap.Count)  $($overlap -join ', ')"
"max key fields per card: $maxk; max total key length: $maxlen"
foreach ($id in 'CLOA43_L277', 'SOCM02_D1_L83', 'SINM05_L211', 'VGPJ02_L425', 'PAIJ01_PP_L69') {
  $c = $calls | Where-Object Call -eq $id
  "$id :: " + ((Get-Content (Join-Path $ge.SgsCards $c.CardFile) | Where-Object { $_ -match 'KEYS|INPUT|OUTPUT' } | ForEach-Object { $_.Trim() }) -join ' || ')
}
