<#
.SYNOPSIS
  Repeatable builder for the MT-010 AMT177->AMT172 handoff bundle (20 SSG->PowerShell programs).
.DESCRIPTION
  Assembles SsgConverter/Trials/DiscDesignators.json + GoldenReconciliation.json (Phase 1/2 outputs)
  plus the live Examples/Input, Examples/Output, Trials/<Program>/sgs-values.json into a per-program
  folder layout under the target 177Xfer clone's ConvertedSSG/Programs/<Program>/, and writes a
  top-level manifest.json. Idempotent: safe to re-run, always overwrites destination files.
.PARAMETER BundleRoot
  Path to the ConvertedSSG folder inside the 177Xfer clone (e.g. E:\Repos\177Xfer\ConvertedSSG).
#>
param(
  [Parameter(Mandatory=$true)][String]$BundleRoot
)

$ErrorActionPreference = "Stop"
$ssgRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent   # .../SsgTrial
$trialsRoot = $PSScriptRoot                                        # .../SsgConverter/Trials

$discPath = Join-Path $trialsRoot "DiscDesignators.json"
$goldPath = Join-Path $trialsRoot "GoldenReconciliation.json"
$disc = Get-Content $discPath -Raw | ConvertFrom-Json
$gold = Get-Content $goldPath -Raw | ConvertFrom-Json

# program key -> source input filename (exact, as under SsgConverter/Examples/Input)
$sourceFileMap = [ordered]@{
  "ARCHIFORMAT"    = "ARCHIFORMAT.TXT"
  "ARCHISEPARE"    = "ARCHISEPARE"
  "BABA_ASCII"     = "BABA_ASCII.TXT"
  "CFH-COPY"       = "CFH-COPY.TXT"
  "CFH-COPY_ASCII" = "CFH-COPY_ASCII.TXT"
  "CHAB100_ASCII"  = "CHAB100_ASCII.TXT"
  "CHABAN_ASCII"   = "CHABAN_ASCII.TXT"
  "CONDIS2_ASCII"  = "CONDIS2_ASCII.TXT"
  "EXTEUR"         = "EXTEUR.TXT"
  "FUSBA2_ASCII"   = "FUSBA2_ASCII.TXT"
  "FUSBA_ASCII"    = "FUSBA_ASCII.TXT"
  "LECTIS_ASCII"   = "LECTIS_ASCII.TXT"
  "LOADIS_ASCII"   = "LOADIS_ASCII.TXT"
  "LOADIS_MULTI"   = "LOADIS_MULTI.TXT"
  "RECAP"          = "RECAP.TXT"
  "SCAN_ASCII"     = "SCAN_ASCII.TXT"
  "TABAN_ASCII"    = "TABAN_ASCII.TXT"
  "TAPELD_ASCII"   = "TAPELD_ASCII.TXT"
  "UNLOADIS_ASCII" = "UNLOADIS_ASCII.TXT"
  "UNLOADIS_MULTI" = "UNLOADIS_MULTI.txt"
}

# program key -> execution status (see copilot-instructions Current status / MT-005)
$execStatus = @{}
foreach ($k in $sourceFileMap.Keys) { $execStatus[$k] = "tier1-only" }
$execStatus["CFH-COPY"] = "tier1+stagea"

$manifestPrograms = New-Object System.Collections.Generic.List[Object]

foreach ($key in $sourceFileMap.Keys) {
  $progDir = Join-Path $BundleRoot "Programs\$key"
  New-Item -ItemType Directory -Force -Path $progDir | Out-Null

  $srcFile = Join-Path $ssgRoot "SsgConverter\Examples\Input\$($sourceFileMap[$key])"
  $scriptFile = Join-Path $ssgRoot "SsgConverter\Examples\Output\$key.ps1"
  Copy-Item $srcFile (Join-Path $progDir "source.txt") -Force
  Copy-Item $scriptFile (Join-Path $progDir "script.ps1") -Force

  $goldEntry = $gold.programs.$key
  $goldenCopied = $false
  $goldenNote = "No Trial3 fixture applies to this program (no-manifest-entry)."
  if ($goldEntry -and $goldEntry.paramMatchStatus -eq "confirmed-seeded-from-manifest" -and $goldEntry.expectedFile) {
    $expectedSrc = Join-Path $ssgRoot ($goldEntry.expectedFile -replace '^Trial3/', 'Trial3\' -replace '/', '\')
    if (Test-Path $expectedSrc) {
      Copy-Item $expectedSrc (Join-Path $progDir "expected-output.dat") -Force
      $goldenCopied = $true
      $goldenNote = "expected-output.dat copied from $($goldEntry.expectedFile) - CONFIRMED same SGS parameters as our seed (see GoldenReconciliation.json caveat: different execution engine, not a byte-diff proof)."
    }
  } elseif ($goldEntry -and $goldEntry.paramMatchStatus -eq "cross-checked-partial-overlap") {
    $goldenNote = "A Trial3 fixture exists ($($goldEntry.fixtureDir)) with an OVERLAPPING but not fully-matched parameter set - not copied here to avoid implying a confirmed golden. See GoldenReconciliation.json."
  } elseif ($goldEntry -and $goldEntry.paramMatchStatus -like "parameter-mismatch*") {
    $goldenNote = "GAP: a same-named Trial3 fixture exists ($($goldEntry.fixtureDir)) but uses DIFFERENT SGS parameters than our seed - deliberately NOT copied here. See GoldenReconciliation.json."
  }

  $discEntry = $disc.programs.$key
  $discLines = New-Object System.Collections.Generic.List[String]
  if ($discEntry) {
    foreach ($f in $discEntry.files) {
      $assign = $f.assignRaw
      if ($f.assignResolved) { $assign = "$($f.assignRaw)  ->  $($f.assignResolved)" }
      $len = $f.recordLengthResolved
      if (-not $len) { $len = "$($f.recordLengthRaw) (unresolved)" }
      $discLines.Add("- **$($f.logicalName)** ($($f.direction)): ASSIGN $assign; LABEL RECORD $($f.labelRecord); record length $len" + $(if ($f.notes) { " - $($f.notes)" } else { "" }))
    }
  }

  $readme = @"
# $key

- **SSG source:** ``source.txt`` (from ``SsgConverter/Examples/Input/$($sourceFileMap[$key])``)
- **Converted PowerShell:** ``script.ps1`` (from ``SsgConverter/Examples/Output/$key.ps1``)
- **Execution status:** $($execStatus[$key]) $(if ($execStatus[$key] -eq "tier1+stagea") { "- ran to completion in the Tier-1 mock harness AND against the real (isolated-copy) AmtPsEclLib with no COM/live app (Stage A); never a live Connect-Application run." } else { "- ran to completion in the Tier-1 mock-shell harness only; never run against a real AmtPsEclLib or live Connect-Application." })
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See ``Tier1Mock/sgs-values/$key.sgs-values.json`` for the parameter values used instead.
- **expected-output.*:** $goldenNote

## DISC designators (see ../../DiscDesignators.json for the full structured version)
$($discLines -join "`n")
"@
  Set-Content -Path (Join-Path $progDir "README.md") -Value $readme -Encoding UTF8

  $manifestPrograms.Add([ordered]@{
    key = $key
    sourceFile = $sourceFileMap[$key]
    scriptFile = "$key.ps1"
    executionStatus = $execStatus[$key]
    overlapsWithT3ConvertedSSG10 = @("ARCHIFORMAT","ARCHISEPARE","BABA_ASCII","CFH-COPY","CHAB100_ASCII","CHABAN_ASCII","LOADIS_ASCII","LOADIS_MULTI","UNLOADIS_ASCII","UNLOADIS_MULTI") -contains $key
    goldenStatus = $(if ($goldEntry) { $goldEntry.paramMatchStatus } else { "no-manifest-entry" })
    goldenCopied = $goldenCopied
    folder = "Programs/$key"
  })
}

$manifest = [ordered]@{
  _readme = "MT-010 handoff bundle manifest. 20 SSG->PowerShell programs, converted by SsgConverter from SSG-COBOL source. All Tier-1 mock-shell verified (0 parse errors); see per-program README.md for real-runtime status. Mirrors the Trial3/manifest/programs.manifest.json + fixtures/<key>/ shape per AMT172's request."
  bundleDate = (Get-Date -Format "yyyy-MM-dd")
  programCount = $manifestPrograms.Count
  programs = $manifestPrograms
}
$manifest | ConvertTo-Json -Depth 8 | Set-Content -Path (Join-Path $BundleRoot "manifest.json") -Encoding UTF8

Copy-Item $discPath (Join-Path $BundleRoot "DiscDesignators.json") -Force
Copy-Item $goldPath (Join-Path $BundleRoot "GoldenReconciliation.json") -Force

Write-Output "Bundle assembled at $BundleRoot ($($manifestPrograms.Count) programs)."
