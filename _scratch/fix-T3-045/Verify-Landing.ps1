$ErrorActionPreference = 'Stop'
Set-Location E:\Repos\SsgTrial
$new = 'SsgConverter\Examples\Output'; $bak = 'SsgConverter\_backup\Output-20261021-172259'; $scr = '_scratch\fix-T3-045\out'
$rows = foreach ($f in Get-ChildItem $new -Filter *.ps1) {
  $b = Join-Path $bak $f.Name; $s = Join-Path $scr $f.Name; $h = (Get-FileHash $f.FullName).Hash
  [pscustomobject]@{ Program = $f.BaseName; Changed = (-not (Test-Path $b)) -or ((Get-FileHash $b).Hash -ne $h); TestedSame = (Test-Path $s) -and ((Get-FileHash $s).Hash -eq $h) }
}
'changed vs backup: ' + (($rows | Where-Object Changed).Program -join ', ')
'not identical to the tested scratch output: ' + (($rows | Where-Object { -not $_.TestedSame }).Program -join ', ')
$o = 'E:\Repos\ssg4-work\allcalls\expanded-landed2'
& pwsh -NoProfile -File Conversion\Pipeline\Expand-AllCalls.ps1 -Program SCAN_ASCII -Out $o 2>&1 | Select-Object -Last 2
& pwsh -NoProfile -File _scratch\spike-scan\check\Test-ScanParm.ps1 -Expanded $o *> _scratch\spike-scan\check\run-landed.txt
Get-Content _scratch\spike-scan\check\run-landed.txt | Select-Object -First 3 | ForEach-Object { if ($_.Length -gt 200) { $_.Substring(0, 200) } else { $_ } }
