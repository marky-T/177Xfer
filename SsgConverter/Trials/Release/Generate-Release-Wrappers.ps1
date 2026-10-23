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

# Convert a flat sgs-values.json (keys like "LABEL,1,occ,field": "value") into AddTo-SgsList lines.
#
# Real SGS keys are addressed at up to 4 depths: bare "LABEL" (whole-label scalar/count), "LABEL,1"
# / "LABEL,1,occ" (selector/count values the converted body reads directly - segment[1] is a
# constant "1" list-selector, not an occurrence), and "LABEL,1,occ,field" (the real positional field
# data, where segment[2] is the true occurrence index and segment[3] the field number).
#
# T3-012 (EXTEUR, 261005): bucketing every depth by (parts[1], parts[-1]) - as this function used to
# - collapses a label's real occurrences (parts[2]) into one, since parts[1] is always the constant
# "1". It also lets a 3-segment selector key (e.g. "DEVISE,1,1") collide with a 4-segment field key
# at the same (occ,field) slot (e.g. "DEVISE,1,1,1"), with whichever is processed last in the JSON
# silently winning - fragile, since it depends on property insertion order rather than an explicit
# rule. For EXTEUR this put occurrence 3's literal "NONE" into occurrence 1's field 1 slot instead
# of "0", which crashed a raw (no CompareTypeSafe) "- 1" cast on the real runtime (line 158).
#
# Fix (redesigned, not just patched - this generator is meant to generalize beyond this one client's
# seed shapes): only true 4-segment "LABEL,1,occ,field" keys carry positional field data, bucketed
# explicitly by the real parts[2]/parts[3]; bare/depth-2/depth-3 selector keys are never folded into
# that bucket. A bare depth-1 scalar is only emitted on its own when the label has no depth-4 fields
# - matching the one proven-live hand-written wrapper (CFH-COPY's Stage A runbook, Job 1060:
# "INPUT ECL-TAPEIN,80,1"), which carries only field data, no separate selector/count entry.
# Deviation from the later Job-1085 generated wrapper's "FIXE 0,0" (which merged a bare scalar into
# the field list by accident of the old bucketing, not by design): under this fix "FIXE" serializes
# as a bare "FIXE 0" line can't currently coexist with its own depth-4 field in a single AddTo-SgsList
# call, so the depth-4 field wins (closer, in spirit, to the proven minimal-wrapper pattern) - this
# needs live re-validation, not just Tier-1 (see MT-021). The Tier-1 harness is unaffected either way
# (it reads the flat JSON directly, never this serialization), so Tier-1 passing can't catch this
# class of bug - only a live run can (see MT-020).
function ConvertTo-SgsLines {
  param([Parameter(Mandatory)][object]$Json)

  # Use .PSBase.* throughout: a seed label can literally be "KEYS"/"COUNT"/etc, which otherwise
  # shadows the real Hashtable member via PowerShell's ETS adapter (see tracker issue T3-007).
  # Inner (occ/field) levels are plain @{} Hashtables, not [ordered]@{} - OrderedDictionary's
  # indexer treats an [int] key as a *positional* index, not a key lookup, throwing "argument out
  # of range" on assignment; order doesn't matter there anyway since occ/field are Sort-Object'd
  # before serializing.
  $scalars = [ordered]@{}   # label -> bare (depth-1) value
  $fields  = [ordered]@{}   # label -> occ -> field -> value (depth-4 only)

  foreach ($prop in $Json.PSObject.Properties) {
    if ($prop.Name -eq '_source') { continue }
    $parts = $prop.Name -split ','
    $label = $parts[0]
    if ($parts.Length -eq 1) {
      $scalars[$label] = [string]$prop.Value
    } elseif ($parts.Length -eq 4) {
      $occ = [int]$parts[2]; $field = [int]$parts[3]
      if (-not $fields.PSBase.Contains($label))        { $fields[$label] = @{} }
      if (-not $fields[$label].PSBase.Contains($occ))  { $fields[$label][$occ] = @{} }
      $fields[$label][$occ][$field] = [string]$prop.Value
    }
    # depth-2 ("LABEL,1") and depth-3 ("LABEL,1,occ") keys are selector/count values consumed
    # directly from the JSON by the Tier-1 mock; intentionally not serialized (see note above).
  }

  $labelsSeen = [ordered]@{}
  foreach ($label in $scalars.PSBase.Keys) { $labelsSeen[$label] = $true }
  foreach ($label in $fields.PSBase.Keys)  { $labelsSeen[$label] = $true }

  $lines = New-Object System.Collections.Generic.List[string]
  foreach ($label in $labelsSeen.PSBase.Keys) {
    if ($fields.PSBase.Contains($label)) {
      $occs = $fields[$label].PSBase.Keys | Sort-Object
      $occParts = foreach ($occ in $occs) {
        $fieldNums = $fields[$label][$occ].PSBase.Keys | Sort-Object
        ($fieldNums | ForEach-Object { $fields[$label][$occ][$_] }) -join ','
      }
      $lines.Add("$label $($occParts -join ' ')")
    } else {
      $lines.Add("$label $($scalars[$label])")
    }
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
# Write-JobLog, not Write-Host: BatchController echoes any console output verbatim as the job's
# error and sets Status=Error (MT-023) - Write-JobLog stays silent on console under Station=BATCH.
Write-JobLog "=== Initialize OK - live Connect-Application succeeded ==="

`$global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
$sgsCalls

# Converted SSG body, resolved from the CC Basepaths > Script path (captured by Initialize).
`$scriptPath = Join-Path `$global:AmtPath.ScriptPath '$key.ps1'

Write-JobLog "=== Running $key.ps1 body ==="
& `$scriptPath -Parameters @('$ParamDefault')
Write-JobLog "=== Body completed without a thrown exception ==="

Fin
"@

  $wrapperPath = Join-Path $wrapperDir "$key-LIVE.ps1"
  Set-Content -Path $wrapperPath -Value $content -Encoding UTF8
  Write-Host "Generated $wrapperPath (job: $jobName)"
  $count++
}

Write-Host "`nDone - $count wrapper(s) written to $wrapperDir" -ForegroundColor Green
