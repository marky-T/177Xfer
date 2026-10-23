$ErrorActionPreference = 'Stop'
$work = 'E:\Repos\ssg4-work\release\cobol\out\AFBUS_2200COBOL.LionSource'
$prev = 'E:\Repos\ssg4-work\release\AFBUS_2200COBOL.LionSource.imported-20261014'
if (-not (Test-Path $prev)) { Copy-Item $work $prev -Recurse }
$programs = 'CFH-COPY_ASCII', 'FUSBA2_ASCII', 'LECTIS_ASCII', 'LOADIS_ASCII', 'RECAP', 'UNLOADIS_ASCII', 'UNLOADIS_MULTI', 'LOADIS_MULTI', 'CHAB100_ASCII'
& E:\Repos\SsgTrial\Conversion\Pipeline\Invoke-Ssg4Release.ps1 -Stage Prepare -Programs $programs -Previous $prev
