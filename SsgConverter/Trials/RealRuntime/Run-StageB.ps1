<#
  Run-StageB.ps1  —  Area D, Stage B (real AMT job against the live services)

  Runs an SsgConverter-produced PowerShell report against the REAL, RUNNING AMT stack on this
  isolated VM, using the documented AMT PowerShell job skeleton:

      Set-Jobname -> Initialize <AmtSettings.xml> -> (seed SGS) -> <report body> -> Fin

  Initialize (AmtPsEclLib L585-618) loads ComScript, creates the COM object, calls
  Connect-Application against the TransactionServer (Grpc:localhost:8031), and creates the real
  joblog under AmtTools\Basepaths\Logs\<date>\. The report body's trailing Fin then performs the
  real end-of-job COM cleanup that isolated Stage A could not.

  This is a DIRECT-CONNECT harness (the documented "start from WP-ISE" model, Exercise 1 §12.4),
  NOT a BatchController/Control Center-submitted job (that wrapper is a separate step).

  Guardrails: isolated AMT177 VM, our own AMT/CC copy. Reads only the isolated library copies in
  this folder + the settings file here. Requires pwsh 7.6+ / .NET 10 (NOT Windows PowerShell 5.1).

  Usage:
    pwsh -NoProfile -File Run-StageB.ps1                # defaults to CFH-COPY
    pwsh -NoProfile -File Run-StageB.ps1 -Program CFH-COPY
#>
[CmdletBinding()]
param(
  [string]$Program = 'CFH-COPY',
  [string]$SettingsFile = (Join-Path $PSScriptRoot 'AmtSettings.xml')
)

$ErrorActionPreference = 'Continue'
$rt = $PSScriptRoot

if ($PSVersionTable.PSVersion.Major -lt 7) {
  throw "Run-StageB requires pwsh 7.6+ / .NET 10 (ComScript.dll will not load under Windows PowerShell 5.1)."
}

# Converted program under test (Examples\Output is 2 levels up from RealRuntime).
$outRoot = Join-Path (Split-Path (Split-Path $rt -Parent) -Parent) 'Examples\Output'
$ps1 = Join-Path $outRoot "$Program.ps1"
if (-not (Test-Path $ps1))          { throw "Converted program not found: $ps1" }
if (-not (Test-Path $SettingsFile)) { throw "AmtSettings.xml not found: $SettingsFile" }

# Per-program SGS seed + parameters (same source as Stage A).
$seeds = @{
  'CFH-COPY' = @{
    Sgs        = @('INPUT ECL-TAPEIN,80,1', 'OUTPUT ECL-TAPEOUT,80,1', 'ASCII 1')
    Parameters = @('80')
  }
}
if (-not $seeds.ContainsKey($Program)) {
  throw "No Stage B seed defined for '$Program'. Add an entry to the `$seeds table in Run-StageB.ps1."
}
$seed = $seeds[$Program]

# --- Import the ISOLATED real runtime -------------------------------------------------------
Import-Module (Join-Path $rt 'AmtPsEclLib.psm1')  -Force -DisableNameChecking -ErrorAction Stop
Import-Module (Join-Path $rt 'AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction SilentlyContinue

$jobName = "$($Program -replace '[^A-Za-z0-9]','_')_STAGEB"

Write-Host "=== Stage B: $Program as a real AMT job (settings: $SettingsFile) ==="
try {
  # Documented job skeleton: name the job, then bring up the full AMT context.
  Set-Jobname $jobName
  Initialize $SettingsFile
  Write-Host "Initialize OK - connected to the application. JobName=$($global:JobName) BatchId=$($global:BatchId) RequestId=$($global:RequestId)"

  # Seed the SGS context the report reads (after Initialize so it isn't reset).
  $global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
  foreach ($line in $seed.Sgs) { AddTo-SgsList $line }

  # Run the report body. Its trailing Fin performs the real end-of-job cleanup.
  & $ps1 -Parameters $seed.Parameters

  Write-Host "RESULT: $Program Stage B completed as a real AMT job."
  exit 0
} catch {
  Write-Host ("RESULT: $Program Stage B THREW -> " + $_.Exception.Message)
  Write-Host ('  at ' + $_.InvocationInfo.PositionMessage)
  exit 1
}
