<#
  AmtPsEclLib.psm1  — MOCK runtime for the release install dry-run ONLY.

  This is NOT the real AMT runtime. It stands in for AmtPsEclLib just enough to execute a release
  *wrapper* end-to-end on a machine with no AMT application, so we can validate the install layout,
  path resolution, wrapper/body syntax and step sequence before shipping to a real AMT box.

  It provides the skeleton primitives a wrapper calls (Set-Jobname, Initialize, Abort,
  HandleTrapAndAbort, Connect-Application) and imports the real Tier-1 mock library globally for the
  body primitives (GetSgsValue, AddTo-SgsList, Fin, Hdg, DataLineOrNoStatement, Call-ExternalProgram, ...).

  Mock-only inputs (set by the test runner, never used in the real runtime):
    $env:AMT_SCRIPTBASE  = folder the real Initialize would expose as the CC Script basepath
                           ($global:AmtPath.ScriptPath); where the bodies live.
    $env:AMT_MOCK_SEED    = path to the program's <KEY>.sgs-values.json, so GetSgsValue has values
                           (the real runtime seeds from the live SGS store via AddTo-SgsList).
#>

Import-Module (Join-Path $PSScriptRoot 'SsgPsMockLib.psm1') -Global -Force -DisableNameChecking

function Set-Jobname {
  param([Parameter(Mandatory)][string]$Name)
  $global:Jobname = $Name
  $global:AppName = 'MOCK_AFBUS_2200COBOL'
  Write-Host "[mock] Set-Jobname $Name"
}

function Connect-Application { Write-Host "[mock] Connect-Application (no-op)" }

function Initialize {
  param([string]$SettingsFile)

  if (-not (Test-Path $SettingsFile)) { throw "[mock] AmtSettings not found: $SettingsFile" }
  Write-Host "[mock] Initialize - settings: $SettingsFile"

  # Real Initialize populates $global:AmtPath.ScriptPath from the CC Basepaths config set.
  $base = $env:AMT_SCRIPTBASE
  if ([string]::IsNullOrWhiteSpace($base)) { throw "[mock] AMT_SCRIPTBASE not set" }
  $global:AmtPath = [pscustomobject]@{ ScriptPath = $base }

  # Seed the SGS table the Tier-1 way (values proven in the mock harness).
  $seedValues = @{}
  if ($env:AMT_MOCK_SEED -and (Test-Path $env:AMT_MOCK_SEED)) {
    $json = Get-Content $env:AMT_MOCK_SEED -Raw | ConvertFrom-Json
    foreach ($p in $json.PSObject.Properties) {
      if ($p.Name -eq '_source') { continue }
      $seedValues[$p.Name] = [string]$p.Value
    }
  }
  Reset-SgsMock -Values $seedValues
  Write-Host "[mock] Initialize OK - ScriptPath=$base ; seeded $($seedValues.PSBase.Count) SGS keys"
}

function Abort {
  param([Parameter(Mandatory)][string]$Message)
  Write-Host "[mock] ABORT: $Message" -ForegroundColor Red
  throw "MockAbort: $Message"
}

function HandleTrapAndAbort {
  param([Parameter(Mandatory)][string]$Message, [object]$ErrorObject)
  Write-Host "[mock] TRAP: $Message $($ErrorObject)" -ForegroundColor Red
  if ($ErrorObject -and $ErrorObject.ScriptStackTrace) { Write-Host $ErrorObject.ScriptStackTrace }
  throw "MockTrapAbort: $Message"
}
