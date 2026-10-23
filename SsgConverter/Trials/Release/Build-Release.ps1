<#
.SYNOPSIS
  Assembles a client release of the converted SSG -> PowerShell programs (MT-017).
.DESCRIPTION
  Repeatable, idempotent release builder. For each REQUESTED program (there is deliberately no
  "ship everything" default - decision 2 of the MT-017 plan) it verifies the program is fit to ship,
  then assembles the release folder:

      <Dest>/
        README.md  RELEASE-NOTES.md  VALIDATION-PROMPT.md
        1_ConvertedScripts/{Bodies,Wrappers,SgsSeeds,Generate-Release-Wrappers.ps1}
        2_OriginalSource/

  Pre-flight (MT-022): aborts if the converter has drifted from Examples/Output - either the C#
  source was edited without a rebuild, or the DLL was rebuilt without regenerating Examples/Output.
  Run SsgConverter/Trials/Reconvert-And-Verify.ps1 -Rebuild -RefreshDll -UpdateGoldens first if so.

  Fitness gate per program (decision 3) - a program failing ANY check is EXCLUDED and reported,
  never silently shipped:
    * converted body exists            (Examples/Output/<KEY>.ps1)
    * SGS seed exists                  (Trials/<KEY>/sgs-values.json)
    * original source exists           (Examples/Input/<KEY>.*)
    * body parses with 0 errors
    * body PASSES the Tier-1 harness, re-run inline here (not a stored status - see
      Invoke-Tier1Check.ps1 for why)

  Other programs still ship if one fails; the run only aborts if a generated WRAPPER fails to parse
  (that would be a generator defect, not a per-program data issue).
.PARAMETER Programs
  Program keys to include, e.g. -Programs CFH-COPY,ARCHIFORMAT. Either this or -All is required.
.PARAMETER All
  Include every converted program found in Examples/Output. Explicit opt-in - there is deliberately
  no "all" DEFAULT, so a release is never assembled from whatever happens to be lying in the output
  folder. Safe to use because every program still passes the same fitness gate below; anything unfit
  is excluded and reported rather than shipped.
.PARAMETER Dest
  Release folder to create. Defaults to E:\Repos\release_candidates\release<yyyyMMdd>-rc.NN
  (auto-incrementing NN if the folder already exists).
.PARAMETER SkipTier1
  Diagnostic escape hatch only - skips the inline Tier-1 re-proof. Not for real releases.
.EXAMPLE
  .\Build-Release.ps1 -Programs CFH-COPY,UNLOADIS_ASCII
.EXAMPLE
  .\Build-Release.ps1 -All
#>
[CmdletBinding()]
param(
  [string[]]$Programs,
  [switch]$All,
  [string]$Dest,
  [switch]$SkipTier1
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$releaseRoot   = $PSScriptRoot
$trialsRoot    = Split-Path $releaseRoot -Parent
$converterRoot = Split-Path $trialsRoot -Parent
$bodySrc       = Join-Path $converterRoot 'Examples\Output'
$inputSrc      = Join-Path $converterRoot 'Examples\Input'

# --- resolve the program set ----------------------------------------------------------------------
# -All is an explicit opt-in, never a default: a release must always be an intentional choice.
if ($All) {
  if ($Programs) { throw 'Specify -Programs or -All, not both.' }
  $Programs = Get-ChildItem $bodySrc -Filter '*.ps1' -EA SilentlyContinue | ForEach-Object { $_.BaseName }
  if (-not $Programs) { throw "No converted programs found in $bodySrc" }
  Write-Host "-All: discovered $($Programs.Count) converted program(s) in Examples/Output" -ForegroundColor Cyan
}
if (-not $Programs) { throw 'Specify -Programs <keys> or -All.' }

# --- converter-staleness pre-flight -----------------------------------------------------------------
# A release must never silently ship Examples/Output bodies that predate the converter that's
# supposed to have produced them. Two drift directions, both fatal:
#   (a) converter SOURCE changed but the DLL was never rebuilt (DLL older than newest .cs)
#   (b) the DLL was rebuilt/changed but Examples/Output was never regenerated from it
# Either means Build-Release would ship stale bodies. Fix: run Reconvert-And-Verify.ps1 first.
$dllPath = Join-Path $converterRoot 'Build\Console\SsgConverter.dll'
if (Test-Path $dllPath) {
  $dllTime = (Get-Item $dllPath).LastWriteTime
  $srcRoot = Join-Path $converterRoot 'Source\SsgConverter'
  $newestSrc = Get-ChildItem $srcRoot -Recurse -Filter '*.cs' -EA SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\obj\\|\\bin\\' } |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($newestSrc -and $newestSrc.LastWriteTime -gt $dllTime) {
    throw "Converter source '$($newestSrc.Name)' ($($newestSrc.LastWriteTime)) is newer than the built DLL ($dllTime) - the converter was edited but never rebuilt. Run Reconvert-And-Verify.ps1 -Rebuild -RefreshDll -UpdateGoldens before releasing."
  }
  $staleBodies = foreach ($key in $Programs) {
    $bf = Join-Path $bodySrc "$key.ps1"
    if ((Test-Path $bf) -and (Get-Item $bf).LastWriteTime -lt $dllTime) { $key }
  }
  if ($staleBodies) {
    throw "Examples/Output is stale relative to the current converter DLL ($dllTime) for: $($staleBodies -join ', '). Run Reconvert-And-Verify.ps1 -Rebuild -RefreshDll -UpdateGoldens before releasing (MT-022)."
  }
} else {
  Write-Warning "Converter DLL not found at $dllPath - skipping staleness check (cannot confirm Examples/Output reflects the current converter)."
}

# --- resolve destination (auto-increment rc.NN) ---------------------------------------------------
if (-not $Dest) {
  $stamp = Get-Date -Format 'yyyyMMdd'
  $base  = 'E:\Repos\release_candidates'
  $n = 1
  do { $Dest = Join-Path $base ('release{0}-rc.{1:D2}' -f $stamp, $n); $n++ } while (Test-Path $Dest)
}
if ((Test-Path $Dest) -and @(Get-ChildItem $Dest -Force -EA SilentlyContinue).Count -gt 0) {
  throw "Destination is not empty: $Dest"
}

$cs      = Join-Path $Dest '1_ConvertedScripts'
$bodies  = Join-Path $cs 'Bodies'
$seeds   = Join-Path $cs 'SgsSeeds'
$wrappers= Join-Path $cs 'Wrappers'
$orig    = Join-Path $Dest '2_OriginalSource'
foreach ($d in @($bodies,$seeds,$wrappers,$orig)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }

$inputFiles = Get-ChildItem $inputSrc -File -EA SilentlyContinue

$included = New-Object System.Collections.Generic.List[object]
$excluded = New-Object System.Collections.Generic.List[object]
$tmp      = Join-Path ([IO.Path]::GetTempPath()) ('ssgrel-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp -Force | Out-Null

Write-Host "=== Build-Release: $($Programs.Count) program(s) requested ===" -ForegroundColor Cyan
Write-Host "Destination: $Dest`n"

foreach ($key in ($Programs | Sort-Object -Unique)) {

  $why = New-Object System.Collections.Generic.List[string]

  $bodyFile = Join-Path $bodySrc "$key.ps1"
  $seedFile = Join-Path $trialsRoot "$key\sgs-values.json"
  $origFile = $inputFiles | Where-Object {
                [IO.Path]::GetFileNameWithoutExtension($_.Name).ToUpperInvariant() -eq $key.ToUpperInvariant()
              } | Select-Object -First 1

  if (-not (Test-Path $bodyFile)) { $why.Add('no converted body in Examples/Output') }
  if (-not (Test-Path $seedFile)) { $why.Add('no sgs-values.json seed') }
  if (-not $origFile)             { $why.Add('no original source in Examples/Input') }

  # parse-check the body
  if ($why.Count -eq 0) {
    $perr = $null
    [System.Management.Automation.Language.Parser]::ParseFile($bodyFile, [ref]$null, [ref]$perr) | Out-Null
    if ($perr -and $perr.Count -gt 0) { $why.Add("body has $($perr.Count) parse error(s)") }
  }

  # inline Tier-1 re-proof (child process: converted bodies must not contaminate each other)
  $t1 = $null
  if ($why.Count -eq 0 -and -not $SkipTier1) {
    $resPath = Join-Path $tmp "$key.tier1.json"
    & pwsh -NoProfile -File (Join-Path $releaseRoot 'Invoke-Tier1Check.ps1') -Program $key -ResultPath $resPath *>$null
    if (Test-Path $resPath) {
      $t1 = Get-Content $resPath -Raw | ConvertFrom-Json
      if (-not $t1.passed) { $why.Add('FAILED Tier-1: ' + ($t1.error -replace '\s+',' ')) }
    } else {
      $why.Add('Tier-1 check produced no result')
    }
  }

  if ($why.Count -gt 0) {
    $excluded.Add([pscustomobject]@{ Program = $key; Reasons = ($why -join '; ') })
    Write-Host ("  EXCLUDED {0,-16} {1}" -f $key, ($why -join '; ')) -ForegroundColor Yellow
    continue
  }

  Copy-Item $bodyFile (Join-Path $bodies "$key.ps1") -Force
  Copy-Item $seedFile (Join-Path $seeds  "$key.sgs-values.json") -Force
  Copy-Item $origFile.FullName (Join-Path $orig $origFile.Name) -Force

  $included.Add([pscustomobject]@{
    Program   = $key
    Original  = $origFile.Name
    LineCount = if ($t1) { $t1.lineCount } else { $null }
    Unmocked  = if ($t1) { $t1.unmocked }  else { $null }
    Tier1     = if ($t1) { 'pass' } else { 'skipped' }
  })
  Write-Host ("  included {0,-16} tier1={1} lines={2} unmocked={3}" -f `
              $key, $(if($t1){'pass'}else{'skipped'}), $(if($t1){$t1.lineCount}else{'-'}), $(if($t1){$t1.unmocked}else{'-'})) -ForegroundColor Green
}

Remove-Item $tmp -Recurse -Force -EA SilentlyContinue

if ($included.Count -eq 0) { throw 'No programs passed the fitness gate - nothing to release.' }

# --- wrappers -------------------------------------------------------------------------------------
Copy-Item (Join-Path $releaseRoot 'Generate-Release-Wrappers.ps1') (Join-Path $cs 'Generate-Release-Wrappers.ps1') -Force
Copy-Item (Join-Path $releaseRoot 'VALIDATION-PROMPT.md') (Join-Path $Dest 'VALIDATION-PROMPT.md') -Force

Write-Host "`nGenerating wrappers..." -ForegroundColor Cyan
& (Join-Path $cs 'Generate-Release-Wrappers.ps1') -Root $cs | Out-Null

# a wrapper that doesn't parse is a GENERATOR defect - fail the whole build, don't ship it
$badWrappers = @()
foreach ($w in Get-ChildItem $wrappers -Filter '*-LIVE.ps1') {
  $werr = $null
  [System.Management.Automation.Language.Parser]::ParseFile($w.FullName, [ref]$null, [ref]$werr) | Out-Null
  if ($werr -and $werr.Count -gt 0) { $badWrappers += "$($w.Name): $($werr.Count)" }
}
if ($badWrappers.Count -gt 0) { throw "Generated wrapper(s) failed parse-check: $($badWrappers -join ', ')" }

# --- manifest (feeds the RELEASE-NOTES per-program table) -----------------------------------------
$manifest = [ordered]@{
  releaseLabel = Split-Path $Dest -Leaf
  builtUtc     = (Get-Date).ToUniversalTime().ToString('o')
  included     = $included
  excluded     = $excluded
}
[IO.File]::WriteAllText((Join-Path $Dest 'build-manifest.json'), ([pscustomobject]$manifest | ConvertTo-Json -Depth 6))

Write-Host "`n=== Build complete ===" -ForegroundColor Green
Write-Host ("Included : {0}" -f $included.Count)
Write-Host ("Excluded : {0}" -f $excluded.Count)
Write-Host ("Wrappers : {0} (all parse 0)" -f @(Get-ChildItem $wrappers -Filter '*-LIVE.ps1').Count)
Write-Host ("Manifest : {0}" -f (Join-Path $Dest 'build-manifest.json'))
Write-Host "`nNext: populate README.md / RELEASE-NOTES.md from the templates, then run Mock-Install-Dryrun.ps1."

return [pscustomobject]@{
  Dest = $Dest; Included = $included; Excluded = $excluded
}
