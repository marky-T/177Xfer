<#
  Generate-Release-Wrappers.ps1  (AMT177 release, portable)

  Regenerates the live Control Center wrappers (Wrappers\<KEY>-LIVE.ps1) from the per-program
  SGS seeds (SgsSeeds\<KEY>.sgs-values.json) and the converted bodies (Bodies\<KEY>.ps1).

  Each wrapper wraps its converted SSG body in a real ECL skeleton:
      Set-Jobname -> Initialize -> seed SGS -> & <body> -> Fin
  and resolves the body at run time from the CC-configured Script basepath
  (Control Center > System Configuration > System Setup > Basepaths > Script path),
  captured by Initialize into $global:AmtPath.ScriptPath.

  Runtime library + settings are taken from environment variables set by the installer
  (AMT_RT, AMT_SETTINGS), falling back to the documented relative deployment layout.

  Idempotent: re-running reproduces byte-identical wrappers.
#>
[CmdletBinding()]
param(
  # Root of the 1_ConvertedScripts folder. Defaults to this script's own folder.
  [string]$Root = $PSScriptRoot,
  # Default first value passed to each body's -Parameters (SSG "record length" convention).
  [string]$ParamDefault = '80'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$seedDir    = Join-Path $Root 'SgsSeeds'
$bodyDir    = Join-Path $Root 'Bodies'
$wrapperDir = Join-Path $Root 'Wrappers'

if (-not (Test-Path $seedDir)) { throw "SgsSeeds folder not found: $seedDir" }
New-Item -ItemType Directory -Path $wrapperDir -Force | Out-Null

# Convert a flat sgs-values.json (keys like "LABEL,occ,?,field": "value") into AddTo-SgsList lines,
# grouped per label / per occurrence / per field (same scheme the Tier-1 harness seeds from).
function ConvertTo-SgsLines {
  param([Parameter(Mandatory)][object]$Json)

  # Use .PSBase.* throughout: a seed label can literally be "KEYS"/"COUNT"/etc, which otherwise
  # shadows the real Hashtable member via PowerShell's ETS adapter (see tracker issue T3-007).
  $byLabel = [ordered]@{}
  foreach ($prop in $Json.PSObject.Properties) {
    if ($prop.Name -eq '_source') { continue }
    $parts = $prop.Name -split ','
    $label = $parts[0]
    if ($parts.Length -eq 1) { $occ = 1; $field = 1 }
    else { $occ = [int]$parts[1]; $field = [int]$parts[-1] }
    if (-not $byLabel.PSBase.Contains($label))        { $byLabel[$label] = @{} }
    if (-not $byLabel[$label].PSBase.Contains($occ))  { $byLabel[$label][$occ] = @{} }
    $byLabel[$label][$occ][$field] = [string]$prop.Value
  }

  $lines = New-Object System.Collections.Generic.List[string]
  foreach ($label in $byLabel.PSBase.Keys) {
    $occs = $byLabel[$label].PSBase.Keys | Sort-Object
    $occParts = foreach ($occ in $occs) {
      $fields = $byLabel[$label][$occ].PSBase.Keys | Sort-Object
      ($fields | ForEach-Object { $byLabel[$label][$occ][$_] }) -join ','
    }
    $lines.Add("$label $($occParts -join ' ')")
  }
  return $lines
}

$seeds = Get-ChildItem $seedDir -Filter '*.sgs-values.json' | Sort-Object Name
$count = 0

foreach ($seed in $seeds) {
  $key = $seed.BaseName -replace '\.sgs-values$', ''

  $bodyFile = Join-Path $bodyDir "$key.ps1"
  if (-not (Test-Path $bodyFile)) { Write-Warning "Skip $key - no body at $bodyFile"; continue }

  $json     = Get-Content $seed.FullName -Raw | ConvertFrom-Json
  $sgsLines = ConvertTo-SgsLines -Json $json
  $sgsCalls = ($sgsLines | ForEach-Object { "AddTo-SgsList '$_'" }) -join "`r`n"

  $jobName = "T3_20_$($key -replace '[^A-Za-z0-9_]','_')_LIVE"

  $content = @"
<#
  $key-LIVE.ps1 - AMT177 release wrapper (portable, basepath-driven).
  Wraps the converted SSG body '$key.ps1' in a real ECL skeleton and runs it under Control Center.
  The body is resolved at run time from the CC-configured Script basepath
  (System Configuration > System Setup > Basepaths > Script path).
  Seeded from SgsSeeds\$key.sgs-values.json - the same SGS values proven in the Tier-1 harness.
#>

# AMT runtime library + settings. Set by the installer (see README); relative fallback = CC Script layout.
`$rt              = if (`$env:AMT_RT)       { `$env:AMT_RT }       else { Join-Path `$PSScriptRoot '..\..\Libraries' }
`$AmtSettingsFile = if (`$env:AMT_SETTINGS) { `$env:AMT_SETTINGS } else { Join-Path `$PSScriptRoot '..\..\Settings\AmtSettings.xml' }

Import-Module (Join-Path `$rt 'AmtPsEclLib.psm1')  -Force -DisableNameChecking -ErrorAction Stop
Import-Module (Join-Path `$rt 'AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction SilentlyContinue

Trap {
  HandleTrapAndAbort "Error trapped:" `$_
}

Set-Jobname "$jobName"
Initialize `$AmtSettingsFile
Write-Host "=== Initialize OK - live Connect-Application succeeded ===" -ForegroundColor Green

`$global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
$sgsCalls

# Converted SSG body, resolved from the CC Basepaths > Script path (captured by Initialize).
`$scriptPath = Join-Path `$global:AmtPath.ScriptPath '$key.ps1'

Write-Host "=== Running $key.ps1 body ===" -ForegroundColor Green
& `$scriptPath -Parameters @('$ParamDefault')
Write-Host "=== Body completed without a thrown exception ===" -ForegroundColor Green

Fin
"@

  $wrapperPath = Join-Path $wrapperDir "$key-LIVE.ps1"
  Set-Content -Path $wrapperPath -Value $content -Encoding UTF8
  Write-Host "Generated $wrapperPath (job: $jobName)"
  $count++
}

Write-Host "`nDone - $count wrapper(s) written to $wrapperDir" -ForegroundColor Green
