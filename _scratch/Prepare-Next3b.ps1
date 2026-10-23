$ErrorActionPreference = 'Stop'
$work = 'E:\Repos\ssg4-work\release\cobol\out\AFBUS_2200COBOL.LionSource'
$prev = 'E:\Repos\ssg4-work\release\AFBUS_2200COBOL.LionSource.imported-20261019'
if (-not (Test-Path $prev)) { Copy-Item $work $prev }
$programs = 'CFH-COPY_ASCII', 'FUSBA2_ASCII', 'LECTIS_ASCII', 'LOADIS_ASCII', 'RECAP', 'UNLOADIS_ASCII', 'UNLOADIS_MULTI', 'LOADIS_MULTI', 'CHAB100_ASCII',
  'CHABAN_ASCII', 'BABA_ASCII', 'FUSBA_ASCII'
& E:\Repos\SsgTrial\Conversion\Pipeline\Invoke-Ssg4Release.ps1 -Stage Prepare -Programs $programs -Previous $prev
