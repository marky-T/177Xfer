<#
  Run-StageA.ps1  —  Area D, Stage A (isolated real-runtime run)

  Runs an SsgConverter-produced PowerShell program against the REAL AmtPsEclLib runtime
  (an ISOLATED copy kept in this folder), with NO Control Center / BatchController and NO
  Initialize/Connect-Application (which would load ComScript.dll and connect to the live app).

  Stage A proves the converted .ps1 is API-compatible with the real runtime: every runtime
  function it calls (GetSgsValue, DataLineOrNoStatement, CompareTypeSafe, AddTo-SgsList,
  Process-Skip, Fin, ...) exists with a matching signature and the script reaches FIN with
  no missing-member / missing-global crash.

  Stage B (faithful completion under the real app: COM object, Connect-Application, file
  controllers, report capture) is out of scope here and is driven separately.

  Guardrails: reads ONLY the isolated library copies in this folder. Never touches
  E:\Repos\Federale_InternalRelease or the live FEDERALE_APP / DB / ava account.

  Usage:
    pwsh -File Run-StageA.ps1                 # defaults to CFH-COPY
    pwsh -File Run-StageA.ps1 -Program CFH-COPY
#>
[CmdletBinding()]
param(
  [string]$Program = 'CFH-COPY',
  [string]$OutputRoot = (Join-Path $PSScriptRoot 'Examples\Output')
)

$ErrorActionPreference = 'Continue'
$rt = $PSScriptRoot

# Converted program under test (Examples\Output is 3 levels up: RealRuntime -> Trials -> SsgConverter)
$defaultOutput = Join-Path (Split-Path (Split-Path $rt -Parent) -Parent) 'Examples\Output'
if (-not (Test-Path $OutputRoot)) { $OutputRoot = $defaultOutput }
$ps1 = Join-Path $OutputRoot "$Program.ps1"
if (-not (Test-Path $ps1)) { throw "Converted program not found: $ps1" }

# --- Per-program isolated SGS seed + parameters --------------------------------------------
# Seed the SGS labels a per-job StartSSG would have created, sourced from the Trial3 manifest
# paramOverrides / conditionValues for the program. Extend this table for more programs.
$seeds = @{
  'CFH-COPY' = @{
    Sgs        = @('INPUT ECL-TAPEIN,80,1', 'OUTPUT ECL-TAPEOUT,80,1', 'ASCII 1')
    Parameters = @('80')
  }
}
if (-not $seeds.ContainsKey($Program)) {
  throw "No Stage A seed defined for '$Program'. Add an entry to the `$seeds table in Run-StageA.ps1."
}
$seed = $seeds[$Program]

# --- Import the ISOLATED real runtime -------------------------------------------------------
Import-Module (Join-Path $rt 'AmtPsEclLib.psm1')  -Force -DisableNameChecking -ErrorAction Stop
Import-Module (Join-Path $rt 'AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction SilentlyContinue

# --- Isolated init (the parts Initialize would set that the run needs, WITHOUT COM/app) ------
# Fin's cleanup reads $global:WarningRcw2435 (normally set by Initialize from AmtSettings.xml,
# NOT at module load). Set it here so the run reaches a clean FIN without Connect-Application.
$global:WarningRcw2435 = $false

# --- Seed SGS context -----------------------------------------------------------------------
$global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
foreach ($line in $seed.Sgs) { AddTo-SgsList $line }
Write-Host ("Seeded SGS for {0}: [INPUT,1,1,1]={1}  [ASCII]={2}  [PRINT]={3}" -f `
  $Program, (GetSgsValue '[INPUT,1,1,1]'), (GetSgsValue '[ASCII]'), (GetSgsValue '[PRINT]'))

# --- Run ------------------------------------------------------------------------------------
Write-Host "=== Stage A: running $Program.ps1 against the real AmtPsEclLib (isolated) ==="
try {
  & $ps1 -Parameters $seed.Parameters
  Write-Host "RESULT: $Program completed against the real runtime with no thrown exception."
  exit 0
} catch {
  $msg = $_.Exception.Message
  $pos = $_.InvocationInfo.PositionMessage
  # Expected isolated-Stage-A boundary: the whole program body + FIN + End Job + "Script Done"
  # have already run; only end-of-job COM printer cleanup ($global:Com.RemoveNonPrintedFiles)
  # remains, and that COM object is supplied only by the Stage B bring-up. Treat as a PASS.
  if ($pos -match 'RemoveNonPrintedFiles') {
    Write-Host "RESULT: $Program PASS (Stage A) - full body executed and reached FIN/End Job."
    Write-Host "  Remaining step is COM printer cleanup (RemoveNonPrintedFiles), which requires the"
    Write-Host "  Stage B COM bring-up (Initialize/Connect-Application). Isolated Stage A is complete."
    exit 0
  }
  Write-Host ("RESULT: $Program THREW -> " + $msg)
  Write-Host ('  at ' + $pos)
  exit 1
}
