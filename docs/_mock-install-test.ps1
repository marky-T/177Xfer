<#
  _mock-install-test.ps1  (scratch) — dry-run the release install per README/RELEASE-NOTES,
  for 1-2 programs, on this VM (no real AMT app). Validates layout, path resolution, Unblock-File,
  wrapper/body syntax and the run sequence. NOT a live AMT test.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$rel     = 'E:\Repos\release_candidates\release20261002-rc.01'
$cs      = Join-Path $rel '1_ConvertedScripts'
$ws      = 'E:\Repos\SsgTrial'
$inst    = 'E:\Repos\_mock_amt_install\Scripts'
$libs    = Join-Path $inst 'Libraries'
$setd    = Join-Path $inst 'Settings'
$rundir  = Join-Path $inst 'SSGTRIAL\RUN'

$programs = @('CFH-COPY','UNLOADIS_ASCII')

foreach ($d in @($libs,$setd,$rundir)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }

# --- Install step: runtime deps (mock lib already authored in Libraries; add the real Tier-1 mock + settings)
Copy-Item (Join-Path $ws 'SsgConverter\Trials\Tier1Mock\SsgPsMockLib.psm1') (Join-Path $libs 'SsgPsMockLib.psm1') -Force
Copy-Item (Join-Path $ws 'SsgConverter\Trials\RealRuntime\AmtSettings.xml') (Join-Path $setd 'AmtSettings.xml') -Force

# --- README Step 1: deploy bodies to the CC Script basepath (= $inst root here)
# --- README Step 2: deploy wrappers to the RUN folder under the Script path
foreach ($p in $programs) {
  Copy-Item (Join-Path $cs "Bodies\$p.ps1")           (Join-Path $inst "$p.ps1")          -Force
  Copy-Item (Join-Path $cs "Wrappers\$p-LIVE.ps1")    (Join-Path $rundir "$p-LIVE.ps1")   -Force
}

# --- README Step 4: Windows hygiene
Get-ChildItem $inst -Recurse -Include *.ps1,*.psm1 | Unblock-File

# --- Run each wrapper exactly as CC would (pwsh -File), AMT_RT/AMT_SETTINGS UNSET -> exercise relative fallback
$log = New-Object System.Collections.Generic.List[string]
foreach ($p in $programs) {
  $wrapper = Join-Path $rundir "$p-LIVE.ps1"
  $seed    = Join-Path $cs "SgsSeeds\$p.sgs-values.json"
  $log.Add("######## $p ########")
  $env:AMT_SCRIPTBASE = $inst
  $env:AMT_MOCK_SEED  = $seed
  Remove-Item Env:\AMT_RT, Env:\AMT_SETTINGS -ErrorAction SilentlyContinue
  $out = & pwsh -NoProfile -File $wrapper *>&1
  $log.Add(($out | Out-String))
  $log.Add("EXITCODE=$LASTEXITCODE")
  $log.Add("")
}
Remove-Item Env:\AMT_SCRIPTBASE, Env:\AMT_MOCK_SEED -ErrorAction SilentlyContinue
[IO.File]::WriteAllText('E:\Repos\SsgTrial\docs\_mock-install.out.txt', ($log -join "`r`n"))
Write-Host "WROTE _mock-install.out.txt"
