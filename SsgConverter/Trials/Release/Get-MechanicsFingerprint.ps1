<#
.SYNOPSIS
  Decides whether a release needs a fresh AMT172 live install test-proof (MT-017 decision 7).
.DESCRIPTION
  Hashes the files that determine INSTALL/RUNTIME MECHANICS (not program content) and compares the
  result to the fingerprint recorded at the last successful live validation.

      Mismatch -> mechanics changed; a live test-proof is REQUIRED (not skippable).
      Match    -> mechanics unchanged; there is genuine discretion, so the caller should ASK the user
                  whether to cite the prior proof or re-run it anyway.

  The computed result frames the question; it does not silently decide it. Use -Update after a
  confirmed live validation to record the new state.
.PARAMETER Update
  Record a successful live validation: writes date/jobId/programKey + the current fingerprint.
.EXAMPLE
  .\Get-MechanicsFingerprint.ps1
.EXAMPLE
  .\Get-MechanicsFingerprint.ps1 -Update -JobId 1085 -ProgramKey CFH-COPY
#>
[CmdletBinding()]
param(
  [switch]$Update,
  [string]$JobId,
  [string]$ProgramKey
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$releaseRoot = $PSScriptRoot
$statePath   = Join-Path $releaseRoot 'LastLiveValidation.json'

# Files whose content changes how a SHIPPED release installs or resolves its runtime.
#
# Scope note (narrowed vs. the MT-017 plan draft, deliberately): the plan also listed the mock libs
# and Mock-Install-Dryrun.ps1. Those are LOCAL pre-ship test scaffolding - they never reach the
# client, so editing them cannot invalidate what AMT172 proved. Including them would force an
# expensive cross-machine re-validation every time we tweak our own harness. What AMT172 actually
# validated is the generated wrapper, so the generator alone defines the fingerprint.
# Program bodies/seeds are excluded too - new program content doesn't change install mechanics.
$mechanicsFiles = @(
  'Generate-Release-Wrappers.ps1'
) | ForEach-Object { Join-Path $releaseRoot $_ }

$missing = @($mechanicsFiles | Where-Object { -not (Test-Path $_) })
if ($missing.Count) { throw "Mechanics file(s) missing: $($missing -join ', ')" }

# Hash of hashes, order-stable, path-independent.
$sb = New-Object System.Text.StringBuilder
foreach ($f in ($mechanicsFiles | Sort-Object)) {
  [void]$sb.AppendLine((Split-Path $f -Leaf) + ':' + (Get-FileHash $f -Algorithm SHA256).Hash)
}
$bytes       = [Text.Encoding]::UTF8.GetBytes($sb.ToString())
$sha         = [Security.Cryptography.SHA256]::Create()
$fingerprint = -join ($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString('x2') })

$prior = $null
if (Test-Path $statePath) { $prior = Get-Content $statePath -Raw | ConvertFrom-Json }

if ($Update) {
  $state = [ordered]@{
    date                = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd')
    jobId               = $JobId
    programKey          = $ProgramKey
    mechanicsFingerprint= $fingerprint
  }
  [IO.File]::WriteAllText($statePath, ([pscustomobject]$state | ConvertTo-Json -Depth 4))
  Write-Host "Recorded live validation: $ProgramKey (JobId $JobId) fingerprint $($fingerprint.Substring(0,12))..." -ForegroundColor Green
  return [pscustomobject]@{ Fingerprint = $fingerprint; Changed = $false; Prior = [pscustomobject]$state }
}

$changed = $true
if ($prior -and $prior.mechanicsFingerprint -eq $fingerprint) { $changed = $false }

if (-not $prior) {
  Write-Host 'No prior live validation recorded - a live install test-proof is REQUIRED.' -ForegroundColor Yellow
} elseif ($changed) {
  Write-Host 'Install/runtime MECHANICS CHANGED since the last live validation - test-proof REQUIRED.' -ForegroundColor Yellow
  Write-Host ("  last validated: {0} (JobId {1}, {2})" -f $prior.date, $prior.jobId, $prior.programKey)
} else {
  Write-Host 'Mechanics UNCHANGED since the last live validation.' -ForegroundColor Green
  Write-Host ("  last validated: {0} (JobId {1}, {2})" -f $prior.date, $prior.jobId, $prior.programKey)
  Write-Host '  -> discretionary: cite that proof, or re-run the test-proof anyway (ask the user).'
}

return [pscustomobject]@{
  Fingerprint = $fingerprint
  Changed     = $changed
  Prior       = $prior
}
