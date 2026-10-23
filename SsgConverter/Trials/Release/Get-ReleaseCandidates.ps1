<#
.SYNOPSIS
  Lists the releasable SSG programs and the next release-candidate label (MT-017).
.DESCRIPTION
  Backs the /ssg-release interactive flow: when the user runs the prompt without -Programs or -All,
  the prompt shows this inventory so they can pick, and tells them the RC label that will be used.

  Reports per program whether the three required inputs exist (converted body, SGS seed, original
  source). It deliberately does NOT run Tier-1 here - that is the release build's job
  (Build-Release.ps1 re-proves each program inline). This is a fast inventory, not a gate.
.PARAMETER AsJson
  Emit JSON instead of a formatted table.
.EXAMPLE
  .\Get-ReleaseCandidates.ps1
#>
[CmdletBinding()]
param([switch]$AsJson)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$releaseRoot   = $PSScriptRoot
$trialsRoot    = Split-Path $releaseRoot -Parent
$converterRoot = Split-Path $trialsRoot -Parent
$bodySrc       = Join-Path $converterRoot 'Examples\Output'
$inputSrc      = Join-Path $converterRoot 'Examples\Input'

$inputFiles = Get-ChildItem $inputSrc -File -EA SilentlyContinue

$rows = foreach ($b in (Get-ChildItem $bodySrc -Filter '*.ps1' -EA SilentlyContinue | Sort-Object Name)) {
  $key  = $b.BaseName
  $seed = Join-Path $trialsRoot "$key\sgs-values.json"
  $orig = $inputFiles | Where-Object {
            [IO.Path]::GetFileNameWithoutExtension($_.Name).ToUpperInvariant() -eq $key.ToUpperInvariant()
          } | Select-Object -First 1

  [pscustomobject]@{
    Program  = $key
    Seed     = [bool](Test-Path $seed)
    Original = [bool]$orig
    Ready    = ((Test-Path $seed) -and $orig)
  }
}

# Next RC label: same scheme Build-Release.ps1 uses, so what we show is what gets built.
$stamp = Get-Date -Format 'yyyyMMdd'
$base  = 'E:\Repos\release_candidates'
$n = 1
do { $label = 'release{0}-rc.{1:D2}' -f $stamp, $n; $n++ } while (Test-Path (Join-Path $base $label))

$result = [pscustomobject]@{
  NextReleaseLabel = $label
  Destination      = Join-Path $base $label
  TotalConverted   = @($rows).Count
  ReadyCount       = @($rows | Where-Object Ready).Count
  Programs         = $rows
}

if ($AsJson) { return ($result | ConvertTo-Json -Depth 5) }

Write-Host "`nNext release candidate : $label" -ForegroundColor Cyan
Write-Host "Destination            : $($result.Destination)"
Write-Host ("Converted programs     : {0} ({1} ready to release)`n" -f $result.TotalConverted, $result.ReadyCount)
$rows | Format-Table Program, Seed, Original, Ready -AutoSize
Write-Host "'Ready' = body + seed + original all present. Tier-1 is re-proven at build time, not here.`n" -ForegroundColor DarkGray

return $result
