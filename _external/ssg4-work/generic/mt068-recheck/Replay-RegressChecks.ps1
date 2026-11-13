# MT-068 Phase 2 proof: re-run each regress step's checks (as Invoke-GnPipeline -Stage Regress -Job does) against the job logs and
# outputs of the last recorded run, without CC; evidence to -Out. Run before and after a check change; the reports must match.
param([Parameter(Mandatory)][String]$Out, [String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$gn = 'E:\Repos\SsgTrial\Conversion\Pipeline\Generic'
. "$gn\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = $ge.GenericWork
$catalog = Get-Content "$gn\utilities.json" -Raw | ConvertFrom-Json
$last = @{}; foreach ($r in Import-Csv "$work\regress-results.csv") { $last[$r.Key] = $r }
New-Item -ItemType Directory -Force $Out | Out-Null
$summary = foreach ($step in $catalog.regress) {
  $k = if ($step.param) { "$($step.job) [$($step.param)]" } else { $step.job }
  $start = $last[$k].Started
  $ev = "$Out\$($k -replace '[^\w-]+', '_')"
  New-Item -ItemType Directory -Force $ev | Out-Null
  $codes = @()
  $a = @('-Job', $step.job, '-LogPrefix', $step.logPrefix, '-After', $start, '-Evidence', $ev, '-TimeoutSeconds', '5')
  if ($step.cases) { $a += @('-Cases', "$work\$($step.cases)") }
  & pwsh -NoProfile -File "$gn\Test-CcJob.ps1" @a -Environment $Environment *> "$ev\job.txt"; $codes += "job=$LASTEXITCODE"
  if ($step.prints) {
    & pwsh -NoProfile -File "$gn\Test-CcPrints.ps1" -After $start -Cases "$work\$($step.prints)" -Evidence "$ev\prints" -Folder "$($ge.ExtractPath)\PRINTCAP" -Environment $Environment *> "$ev\prints.txt"; $codes += "prints=$LASTEXITCODE"
  }
  if ($step.check) {
    $c = @($step.check.args | Where-Object { $_ }); if ($step.check.after) { $c += @('-After', $start) }
    if ($step.check.script -match 'Check-(LoadisAll|ArchiveCc)') { $c += @('-Evidence', "$ev\own") }
    & pwsh -NoProfile -File "$gn\$($step.check.script)" @c -Environment $Environment *> "$ev\check.txt"; $codes += "check=$LASTEXITCODE"
  }
  '{0,-30} {1}' -f $k, ($codes -join ' ')
}
$summary | Set-Content "$Out\summary.txt"
$summary
