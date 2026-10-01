<#
  Generate-T3-Live-Wrappers.ps1

  Generates a skeleton-wrapped *-LIVE.ps1 for every T3 bundle program that doesn't already have
  one, using the proven CFH-COPY-LIVE.ps1 pattern (Set-Jobname -> Initialize -> seed SGS from
  Tier1Mock/sgs-values/<KEY>.sgs-values.json -> invoke body -> Fin), and drops it directly into
  Binaries\Scripts\ so BatchController auto-registers it as a CC job.
#>

$sgsDir     = 'C:\Amt\Migration\T3ConvertedSSG\ConvertedSSG\Tier1Mock\sgs-values'
$scriptsDir = 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts'
$rt         = 'C:\Amt\Migration\T3ConvertedSSG\ConvertedSSG\RealRuntime'
$settings   = 'C:\Amt\Migration\Trial3\run\AmtSettings-AFBUS2200COBOL.xml'

# KEY -> default first Parameters value (mirrors CFH-COPY's '80'; most SSG programs take one
# numeric "record length" style parameter, default to '80' unless a program needs otherwise).
$paramDefault = '80'

$keys = Get-ChildItem $sgsDir -Filter '*.sgs-values.json' | ForEach-Object { $_.BaseName -replace '\.sgs-values$','' }

foreach ($key in $keys) {
  if ($key -eq 'CFH-COPY') { continue }  # already has a hand-built live wrapper

  $bodyPath = Join-Path $scriptsDir "$key.ps1"
  if (-not (Test-Path $bodyPath)) { Write-Warning "Skip $key - no body script at $bodyPath"; continue }

  $json = Get-Content (Join-Path $sgsDir "$key.sgs-values.json") -Raw | ConvertFrom-Json
  # Group flat "LABEL,occ,?,field" keys (ignore _source) into per-label, per-occurrence, per-field values.
  $byLabel = [ordered]@{}
  foreach ($prop in $json.PSObject.Properties) {
    if ($prop.Name -eq '_source') { continue }
    $parts = $prop.Name -split ','
    $label = $parts[0]
    if ($parts.Length -eq 1) {
      # bare label, e.g. "ASCII": "1" -> single occurrence, single field
      $occ = 1; $field = 1
    } else {
      $occ   = [int]$parts[1]
      $field = [int]$parts[-1]
    }
    if (-not $byLabel.Contains($label)) { $byLabel[$label] = @{} }
    if (-not $byLabel[$label].Contains($occ)) { $byLabel[$label][$occ] = @{} }
    $byLabel[$label][$occ][$field] = [string]$prop.Value
  }

  $sgsLines = New-Object System.Collections.Generic.List[string]
  foreach ($label in $byLabel.Keys) {
    $occs = $byLabel[$label].Keys | Sort-Object
    $occParts = foreach ($occ in $occs) {
      $fields = $byLabel[$label][$occ].Keys | Sort-Object
      ($fields | ForEach-Object { $byLabel[$label][$occ][$_] }) -join ','
    }
    $sgsLines.Add("$label $($occParts -join ' ')")
  }

  $wrapperName = "$key-LIVE.ps1"
  $wrapperPath = Join-Path $scriptsDir $wrapperName
  $jobName     = "T3_20_$($key -replace '[^A-Za-z0-9_]','_')_LIVE"

  $sgsCalls = ($sgsLines | ForEach-Object { "AddTo-SgsList '$_'" }) -join "`r`n"

  $content = @"
<#
  $wrapperName - auto-generated live Tier-3 wrapper (Generate-T3-Live-Wrappers.ps1).
  Wraps Binaries\Scripts\$key.ps1 in a real ECL skeleton, seeding SGS from
  Tier1Mock\sgs-values\$key.sgs-values.json (same values used for the Tier-1 mock run).
#>

`$rt = '$rt'
`$AmtSettingsFile = '$settings'
`$scriptPath = '$bodyPath'

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

Write-Host "=== Running $key.ps1 body ===" -ForegroundColor Green
& `$scriptPath -Parameters @('$paramDefault')
Write-Host "=== Body completed without a thrown exception ===" -ForegroundColor Green

Fin
"@

  Set-Content -Path $wrapperPath -Value $content -Encoding UTF8
  Write-Host "Generated $wrapperPath (job: $jobName)"
}
