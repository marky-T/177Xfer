$srcRoot = 'E:\Repos\Federale_InternalRelease'
$dstRoot = 'E:\Repos\OLD Federale_Internal'

# Curated list of small text/config/script/csproj files worth keeping as reference after the env rebuild.
# Deliberately NO dlls / .dat / binaries / whole trees.
$candidates = @(
  'AmtTools\Sys.ini',
  'AmtTools\AmtFileController\Sys.ini',
  'Lion\Lion.ini',
  'Lion\Default_Lion.ini',
  'Scripts\Settings\AmtSettings.xml',
  'AmtTools\Basepaths\Scripts\Settings\AmtSettings.xml',
  'AFBUS_2200COBOL\Source\Cobol_AMT\Development\Programs\Assurfed_Utilit_Cfh_Copy\Assurfed_Utilit_Cfh_Copy.csproj'
)

# Also grab any deployed CFH-COPY wrapped script(s) + the AFBUS_2200COBOL AmtSettings.xml, wherever they live.
$discovered = @()
$discovered += Get-ChildItem -LiteralPath $srcRoot -Recurse -File -Filter 'cfh-copy.ps1' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
$discovered += Get-ChildItem -LiteralPath (Join-Path $srcRoot 'AFBUS_2200COBOL') -Recurse -File -Filter 'AmtSettings.xml' -ErrorAction SilentlyContinue | Select-Object -First 3 -ExpandProperty FullName

$all = New-Object System.Collections.Generic.List[string]
foreach ($c in $candidates) { $all.Add((Join-Path $srcRoot $c)) }
foreach ($d in $discovered) { if ($all -notcontains $d) { $all.Add($d) } }

$log = New-Object System.Collections.Generic.List[string]
foreach ($src in ($all | Sort-Object -Unique)) {
  if (Test-Path -LiteralPath $src -PathType Leaf) {
    $rel = $src.Substring($srcRoot.Length).TrimStart('\')
    $dst = Join-Path $dstRoot $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $dst -Parent) | Out-Null
    Copy-Item -LiteralPath $src -Destination $dst -Force
    $len = (Get-Item -LiteralPath $dst).Length
    $log.Add(('COPIED  {0}  ({1} bytes)' -f $rel, $len))
  } else {
    $log.Add(('SKIP (not found)  {0}' -f $src.Substring($srcRoot.Length).TrimStart('\')))
  }
}
$log | ForEach-Object { Write-Output $_ }
Write-Output ''
Write-Output ('Total copied to: ' + $dstRoot)
