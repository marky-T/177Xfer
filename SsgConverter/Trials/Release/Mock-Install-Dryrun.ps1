<#
.SYNOPSIS
  Dry-runs the documented install procedure for a release, with no real AMT application (MT-017).
.DESCRIPTION
  Validates INSTALL MECHANICS before shipping - not program correctness (Tier-1 covers that).
  It lays out a throwaway copy of the documented deployment shape:

      <staging>/Scripts/                 <- stands in for the CC "Script path" basepath
        <KEY>.ps1                        <- bodies, FLAT at the root (per README required-setup #1)
        Libraries/{AmtPsEclLib,AmtPsSortLib,SsgPsMockLib}.psm1
        Settings/AmtSettings.xml
        SSGTRIAL/RUN/<KEY>-LIVE.ps1      <- wrappers, 2 levels down (exercises the relative fallback)

  then runs each wrapper exactly as Control Center would (pwsh -File), with AMT_RT/AMT_SETTINGS
  deliberately UNSET so the depth-sensitive relative fallback is the thing under test.

  This is the step that caught the two "Required runtime setup" risks on 2026-10-02:
  flat body placement, and preferring explicit env vars over the relative fallback.

  NOT a live AMT test - Initialize/Connect-Application are mocked (see MockRuntime/AmtPsEclLib.psm1).
.PARAMETER ReleaseDir
  The release folder produced by Build-Release.ps1.
.PARAMETER Programs
  Which programs to dry-run. Default: first 2 wrappers found (representative sample).
.PARAMETER StagingDir
  Throwaway install root. Default: a temp folder, removed unless -KeepStaging.
.EXAMPLE
  .\Mock-Install-Dryrun.ps1 -ReleaseDir E:\Repos\release_candidates\release20261005-rc.01
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$ReleaseDir,
  [string[]]$Programs,
  [string]$StagingDir,
  [switch]$KeepStaging
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$releaseRoot   = $PSScriptRoot
$trialsRoot    = Split-Path $releaseRoot -Parent
$cs            = Join-Path $ReleaseDir '1_ConvertedScripts'
$bodiesSrc     = Join-Path $cs 'Bodies'
$wrappersSrc   = Join-Path $cs 'Wrappers'
$seedsSrc      = Join-Path $cs 'SgsSeeds'

if (-not (Test-Path $wrappersSrc)) { throw "Not a release folder (no Wrappers): $ReleaseDir" }

if (-not $Programs) {
  $Programs = Get-ChildItem $wrappersSrc -Filter '*-LIVE.ps1' |
              Sort-Object Name | Select-Object -First 2 |
              ForEach-Object { $_.BaseName -replace '-LIVE$','' }
}
if (-not $StagingDir) {
  $StagingDir = Join-Path ([IO.Path]::GetTempPath()) ('ssg-mockinstall-' + [Guid]::NewGuid().ToString('N'))
}

$scripts = Join-Path $StagingDir 'Scripts'
$libs    = Join-Path $scripts 'Libraries'
$setd    = Join-Path $scripts 'Settings'
$rundir  = Join-Path $scripts 'SSGTRIAL\RUN'
foreach ($d in @($libs,$setd,$rundir)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }

# runtime deps: mock AMT libs + the real Tier-1 mock (supplies the body primitives) + settings
Copy-Item (Join-Path $releaseRoot 'MockRuntime\AmtPsEclLib.psm1')  (Join-Path $libs 'AmtPsEclLib.psm1')  -Force
Copy-Item (Join-Path $releaseRoot 'MockRuntime\AmtPsSortLib.psm1') (Join-Path $libs 'AmtPsSortLib.psm1') -Force
Copy-Item (Join-Path $trialsRoot  'Tier1Mock\SsgPsMockLib.psm1')   (Join-Path $libs 'SsgPsMockLib.psm1')  -Force
Copy-Item (Join-Path $trialsRoot  'RealRuntime\AmtSettings.xml')   (Join-Path $setd 'AmtSettings.xml')    -Force

# README step 1: bodies FLAT at the Script-path root. README step 2: wrappers in the RUN folder.
foreach ($p in $Programs) {
  Copy-Item (Join-Path $bodiesSrc   "$p.ps1")        (Join-Path $scripts "$p.ps1")        -Force
  Copy-Item (Join-Path $wrappersSrc "$p-LIVE.ps1")   (Join-Path $rundir  "$p-LIVE.ps1")   -Force
}

# README step 4: Windows mark-of-the-web hygiene
Get-ChildItem $scripts -Recurse -Include *.ps1,*.psm1 | Unblock-File

$results = New-Object System.Collections.Generic.List[object]
Write-Host "=== Mock install dry-run ===" -ForegroundColor Cyan
Write-Host "Staging: $scripts`n"

foreach ($p in $Programs) {
  $wrapper = Join-Path $rundir "$p-LIVE.ps1"
  $env:AMT_SCRIPTBASE = $scripts                               # mock-only: what Initialize would expose
  $env:AMT_MOCK_SEED  = Join-Path $seedsSrc "$p.sgs-values.json"
  Remove-Item Env:\AMT_RT, Env:\AMT_SETTINGS -EA SilentlyContinue   # force the relative fallback

  $out  = & pwsh -NoProfile -File $wrapper *>&1
  $code = $LASTEXITCODE
  $text = ($out | Out-String)
  $ok   = ($code -eq 0) -and ($text -match 'Body completed without a thrown exception')

  $results.Add([pscustomobject]@{ Program = $p; ExitCode = $code; Passed = $ok; Output = $text })
  Write-Host ("  {0,-16} exit={1} {2}" -f $p, $code, $(if($ok){'PASS'}else{'FAIL'})) `
             -ForegroundColor $(if($ok){'Green'}else{'Red'})
  if (-not $ok) { Write-Host $text -ForegroundColor DarkYellow }
}

Remove-Item Env:\AMT_SCRIPTBASE, Env:\AMT_MOCK_SEED -EA SilentlyContinue
if (-not $KeepStaging) { Remove-Item $StagingDir -Recurse -Force -EA SilentlyContinue }

$failed = @($results | Where-Object { -not $_.Passed })
Write-Host ("`nDry-run: {0} passed / {1} failed" -f ($results.Count - $failed.Count), $failed.Count) `
           -ForegroundColor $(if($failed.Count){'Red'}else{'Green'})
if ($failed.Count) { Write-Host 'STOP - install mechanics issue. Do not ship until resolved.' -ForegroundColor Red }

return [pscustomobject]@{ Passed = ($failed.Count -eq 0); Results = $results; StagingDir = $StagingDir }
