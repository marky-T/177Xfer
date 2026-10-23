$ErrorActionPreference = 'SilentlyContinue'
'=== LionDev.exe / Setup.exe versions on this box'
$roots = 'E:\Amt\Lion', 'E:\Amt\Setup', 'E:\Repos\z-old\AMT', 'E:\Repos\Federale_InternalRelease\AmtLion', 'E:\Repos\Federale_InternalRelease\AmtTools', 'E:\Repos\177Xfer'
foreach ($r in $roots) {
  if (Test-Path $r) {
    Get-ChildItem $r -Recurse -Depth 4 -Include LionDev.exe, Setup.exe, AMT_*.dat -File | ForEach-Object {
      '{0,-95} {1,12}  file={2} product={3}' -f $_.FullName, $_.Length, $_.VersionInfo.FileVersion, $_.VersionInfo.ProductVersion }
  } else { "(missing) $r" }
}
'=== Recycle Bin items (name, original location, size)'
$sh = New-Object -ComObject Shell.Application
$rb = $sh.NameSpace(10)
foreach ($i in $rb.Items()) {
  '{0,-60} {1,-45} {2}' -f $i.Name, $rb.GetDetailsOf($i, 1), $rb.GetDetailsOf($i, 3)
}
