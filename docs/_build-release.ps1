<#
  _build-release.ps1  (scratch orchestrator - not part of the release payload)
  Assembles the Federale SSG->PowerShell release candidate from the workspace.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ws      = 'E:\Repos\SsgTrial'
$outRoot = 'E:\Repos\release_candidates\release20261002-rc.01'
$bodySrc = Join-Path $ws 'SsgConverter\Examples\Output'
$inpSrc  = Join-Path $ws 'SsgConverter\Examples\Input'
$trials  = Join-Path $ws 'SsgConverter\Trials'

$cs      = Join-Path $outRoot '1_ConvertedScripts'
$bodies  = Join-Path $cs 'Bodies'
$seeds   = Join-Path $cs 'SgsSeeds'
$wrappers= Join-Path $cs 'Wrappers'
$orig    = Join-Path $outRoot '2_OriginalSource'

foreach ($d in @($bodies,$seeds,$wrappers,$orig)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }

# Canonical program set = the converted outputs.
$keys = Get-ChildItem $bodySrc -Filter '*.ps1' | ForEach-Object { $_.BaseName } | Sort-Object

$report = New-Object System.Collections.Generic.List[string]
$report.Add("KEY,Body,Seed,Original")

$inputFiles = Get-ChildItem $inpSrc -File

foreach ($key in $keys) {
  # body
  Copy-Item (Join-Path $bodySrc "$key.ps1") (Join-Path $bodies "$key.ps1") -Force
  $hasBody = 'yes'

  # seed
  $seedSrc = Join-Path $trials "$key\sgs-values.json"
  if (Test-Path $seedSrc) { Copy-Item $seedSrc (Join-Path $seeds "$key.sgs-values.json") -Force; $hasSeed = 'yes' }
  else { $hasSeed = 'MISSING' }

  # original (match basename, any extension / case)
  $match = $inputFiles | Where-Object { [IO.Path]::GetFileNameWithoutExtension($_.Name).ToUpper() -eq $key.ToUpper() } | Select-Object -First 1
  if ($match) { Copy-Item $match.FullName (Join-Path $orig $match.Name) -Force; $origName = $match.Name }
  else { $origName = 'MISSING' }

  $report.Add("$key,$hasBody,$hasSeed,$origName")
}

[IO.File]::WriteAllText((Join-Path $outRoot '_assembly-report.csv'), ($report -join "`r`n"))

# Generate the portable wrappers from the copied seeds + bodies.
& (Join-Path $cs 'Generate-Release-Wrappers.ps1') -Root $cs

# Summary counts
$bCount = (Get-ChildItem $bodies -Filter '*.ps1').Count
$sCount = (Get-ChildItem $seeds -Filter '*.sgs-values.json').Count
$wCount = (Get-ChildItem $wrappers -Filter '*-LIVE.ps1').Count
$oCount = (Get-ChildItem $orig -File).Count
[IO.File]::WriteAllText((Join-Path $outRoot '_counts.txt'),
  "Bodies=$bCount`r`nSeeds=$sCount`r`nWrappers=$wCount`r`nOriginals=$oCount")
Write-Host "Bodies=$bCount Seeds=$sCount Wrappers=$wCount Originals=$oCount"
