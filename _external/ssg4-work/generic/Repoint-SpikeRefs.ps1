# One-off: repoint references to the archived spike folders (promoted files -> Generic\<UTILITY>, probes -> the archive zip).
$ErrorActionPreference = 'Stop'
$repo = 'E:\Repos\SsgTrial'
$u = @{ baba = 'BABA'; cfh = 'CFH-COPY'; chaban = 'CHABAN'; condis = 'CONDIS2'; fusba = 'FUSBA'; loadis = 'LOADIS'; scan = 'SCAN'; tapeld = 'TAPELD'; scangroup = 'SCANGROUP' }
$files = 'docs\SSG-PowerShell-Trial-Progress.html', 'docs\SSG4-ControlCenter-Runbook.html', '.github\Copilot_Plans\261020-mt043-cfh-copy-generic-spike.md',
  'Conversion\Pipeline\Generic\SCAN\spec.md', 'Conversion\Pipeline\Generic\TAPELD\spec.md', 'Conversion\Pipeline\Generic\SCANGROUP\cc\PrintModels.ps1'
$enc = [Text.UTF8Encoding]::new($false)
foreach ($f in $files) {
  $p = Join-Path $repo $f
  $bytes = [IO.File]::ReadAllBytes($p)
  $bom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
  $t = [IO.File]::ReadAllText($p)
  $o = $t
  $t = [regex]::Replace($t, '_scratch\\spike-(\w+)\\spec\.md', { param($m) 'Conversion\Pipeline\Generic\' + $u[$m.Groups[1].Value] + '\spec.md' })
  $t = [regex]::Replace($t, '_scratch\\spike-(\w+)\\gen\\(\w+Parm\.ps1)', { param($m) 'Conversion\Pipeline\Generic\' + $u[$m.Groups[1].Value] + '\gen\' + $m.Groups[2].Value })
  $t = $t.Replace('..\spike-scangroup\Prepare-ScanGroupCc.ps1', '..\SCANGROUP\cc\Prepare-ScanGroupCc.ps1').Replace('..\spike-scangroup\PrintModels.ps1', '..\SCANGROUP\cc\PrintModels.ps1').Replace('(`..\spike-scangroup`)', '(`..\SCANGROUP`)')
  $t = $t.Replace('(spike-scan / spike-tapeld spec.md)', '(SCAN / TAPELD spec.md)')
  # what is left are one-off probes and inventories: they live in the archive
  $t = [regex]::Replace($t, '_scratch\\spike-(\w+)\\([\w\\\.-]+)', { param($m) 'archive\spikes-20261021.zip (spike-' + $m.Groups[1].Value + '\' + $m.Groups[2].Value + ')' })
  if ($t -ne $o) { [IO.File]::WriteAllText($p, $t, [Text.UTF8Encoding]::new($bom)); "{0}: updated (BOM {1})" -f $f, $bom }
}
