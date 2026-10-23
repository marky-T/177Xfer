<#
.SYNOPSIS
  Runs the Tier-1 mock harness for ONE program and writes a machine-readable verdict.
.DESCRIPTION
  Release-gate helper for Build-Release.ps1 (MT-017). There is no stored Tier-1 pass/fail record in
  this repo - the authoritative status is hand-written prose in the progress tracker, which can drift
  from reality. So the release build re-proves each program at build time instead of trusting a record.

  Designed to be invoked as a CHILD process (one per program) so converted bodies - which define
  arbitrary functions and globals - cannot contaminate each other or the caller's session.
.PARAMETER Program
  Program key (Examples/Output/<Program>.ps1 base name).
.PARAMETER ResultPath
  Where to write the JSON verdict.
.EXAMPLE
  pwsh -NoProfile -File Invoke-Tier1Check.ps1 -Program CFH-COPY -ResultPath C:\temp\r.json
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$Program,
  [Parameter(Mandatory)][string]$ResultPath
)

$ErrorActionPreference = 'Stop'

$releaseRoot = $PSScriptRoot
$trialsRoot  = Split-Path $releaseRoot -Parent
$runner      = Join-Path $trialsRoot 'Tier1Mock\Run-SsgPsTrial.ps1'

$verdict = [ordered]@{
  program    = $Program
  ran        = $false
  passed     = $false
  lineCount  = $null
  unmocked   = $null
  error      = $null
}

try {
  if (-not (Test-Path $runner)) { throw "Tier-1 harness not found: $runner" }

  # Harness writes progress to the host; we only need its returned object + the mock globals.
  $r = & $runner -Program $Program 6>$null

  $verdict.ran       = $true
  $verdict.lineCount = $r.LineCount
  $verdict.unmocked  = @($global:SgsMockWarnings).Count
  $verdict.passed    = (-not $r.Failed)
  if ($r.Failed) { $verdict.error = [string]$r.Error }
}
catch {
  $verdict.error = $_.Exception.Message
}

$dir = Split-Path $ResultPath -Parent
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
[IO.File]::WriteAllText($ResultPath, ([pscustomobject]$verdict | ConvertTo-Json -Depth 4))
