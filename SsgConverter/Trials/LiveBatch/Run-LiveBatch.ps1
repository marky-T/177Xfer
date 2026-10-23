<#
  Run-LiveBatch.ps1  —  MT-025 single-job live-execution batch runner.

  Reads a flat file list of SSG program KEYs and runs each one's already-deployed <KEY>-LIVE.ps1
  wrapper, in turn, as its own child process. One CC job registration ("the same job repeats for
  each script") drives any subset simply by editing RunList.txt before Start Job.

  Why each program gets its own OS process (not one shared Initialize/loop/Fin session): AmtPsEclLib's
  Abort unconditionally ends in a hard Exit (not a catchable exception) and is called directly from
  166+ ordinary call sites in the runtime itself (file not found, invalid option, etc.) - entirely
  routine conditions a converted report can hit. A failing program's Exit would kill a whole shared
  session; isolating each in its own process means only that child dies, and the next program still
  runs. See .github/Copilot_Plans/261006-live-batch-runner.md for the full design/rationale.

  This orchestrator registers as a real AMT job (Set-Jobname -> Initialize -> ... -> Fin), the same
  lifecycle every working CC job uses. It never writes to the console (MT-023: BatchController echoes
  ANY console output verbatim as "the error" and sets Status=Error) - everything goes to progress.log
  on disk instead.

  Usage (as a CC Script job, or directly):
    pwsh -NoProfile -File Run-LiveBatch.ps1
    pwsh -NoProfile -File Run-LiveBatch.ps1 -ListFile .\RunList-subset.txt
    pwsh -NoProfile -File Run-LiveBatch.ps1 -ListFile 'CFH-COPY,EXTEUR'   # inline key list, not a file

  CC's Start Job "Commandline (script) parameter" field binds positionally to -ListFile (confirmed
  261006: typing a bare key there, e.g. "CFH-COPY", attempts to open a FILE of that name and fails -
  "Run list not found: CFH-COPY"). To make that field actually useful instead of a footgun, a value
  that is not an existing file path is treated as an inline, comma/semicolon/whitespace-separated key
  list rather than a file. Use the keyword ALL to mean "use RunList.txt as-is".
#>
[CmdletBinding()]
param(
  [string]$ListFile        = (Join-Path $PSScriptRoot 'RunList.txt'),
  [string]$ConfigFile      = (Join-Path $PSScriptRoot 'BatchConfig.json'),
  [string]$KnownIssuesFile = (Join-Path $PSScriptRoot 'KnownIssues.json'),
  # Where to search for per-program joblogs (Basepaths\Logs\<yyyymmdd>\). Relative fallback assumes
  # this script sits at the documented depth (Scripts\SSGTRIAL\RUN\, 3 levels below Basepaths) -
  # same depth-sensitivity caveat as the wrapper's AMT_RT/AMT_SETTINGS fallback. Prefer the env var.
  [string]$LogsRoot        = $(if ($env:AMT_LOGS_ROOT) { $env:AMT_LOGS_ROOT } else { Join-Path $PSScriptRoot '..\..\..\Logs' })
)

# Register as a REAL AMT job (Set-Jobname -> Initialize), exactly like every working CC job does.
# Evidence (261007): an orchestrator that only set $global:Jobname directly, with no module/Initialize,
# was declared Error by CC in 4.06s; the same orchestrator when it merely IMPORTED AmtPsEclLib lasted
# 8.07s. Neither registers via Initialize's Connect-Application IPC handshake, which is what CC
# appears to actually wait for before treating a Script job as legitimately running - so do it properly
# rather than racing a grace period. Initialize's own output goes to the joblog, not the console, so
# this does not reintroduce MT-023.
$rt = if ($env:AMT_RT) { $env:AMT_RT } else { Join-Path $PSScriptRoot '..\..\Libraries' }
$AmtSettingsFile = if ($env:AMT_SETTINGS) { $env:AMT_SETTINGS } else { Join-Path $PSScriptRoot '..\..\Settings\AmtSettings.xml' }
Import-Module (Join-Path $rt 'AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
# AmtPsSortLib is NOT optional here: Initialize itself calls Sort-Init (AmtPsEclLib L633), which
# lives in this module - omitting it makes Initialize fail with "'Sort-Init' is not recognized".
Import-Module (Join-Path $rt 'AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction SilentlyContinue
Set-Jobname 'RUN_LIVEBATCH'
Initialize $AmtSettingsFile

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------------------------
# Load config (defaults + optional per-program overrides)
# ---------------------------------------------------------------------------------------------
$defaults = [ordered]@{ MaxElapsedSec = 600; MaxCpuSec = 300; StallSec = 120; PollSec = 5 }
$perProgram = @{}
if (Test-Path $ConfigFile) {
  $cfg = Get-Content $ConfigFile -Raw | ConvertFrom-Json
  if ($cfg.PSObject.Properties.Name -contains 'Defaults') {
    foreach ($name in @($defaults.Keys)) {
      if ($cfg.Defaults.PSObject.Properties.Name -contains $name) { $defaults[$name] = [int]$cfg.Defaults.$name }
    }
  }
  if ($cfg.PSObject.Properties.Name -contains 'Programs') {
    foreach ($p in $cfg.Programs.PSObject.Properties) { $perProgram[$p.Name] = $p.Value }
  }
}

function Get-Limits {
  param([string]$Key)
  $limits = [ordered]@{} + $defaults
  if ($perProgram.ContainsKey($Key)) {
    foreach ($p in $perProgram[$Key].PSObject.Properties) {
      if ($limits.Contains($p.Name)) { $limits[$p.Name] = [int]$p.Value }
    }
  }
  return $limits
}

$knownIssues = @{}
if (Test-Path $KnownIssuesFile) {
  $raw = Get-Content $KnownIssuesFile -Raw | ConvertFrom-Json
  foreach ($p in $raw.PSObject.Properties) {
    if ($p.Name -ne '_comment') { $knownIssues[$p.Name] = $p.Value }
  }
}

# ---------------------------------------------------------------------------------------------
# Resolve the run list: an existing file path, the keyword ALL, or an inline key list.
# ---------------------------------------------------------------------------------------------
if ($ListFile.Trim().ToUpperInvariant() -eq 'ALL') {
  $ListFile = Join-Path $PSScriptRoot 'RunList.txt'
}
if (Test-Path $ListFile) {
  $keys = @(Get-Content $ListFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') })
} else {
  # Not a real file - treat the whole string as an inline, comma/semicolon/whitespace-separated list.
  $keys = @($ListFile -split '[,;\s]+' | Where-Object { $_ })
}
if (-not $keys.Count) { throw "No program keys resolved from '$ListFile' (neither a file nor a non-empty inline list)." }

# ---------------------------------------------------------------------------------------------
# Set up the results folder for this run
# ---------------------------------------------------------------------------------------------
$stamp       = Get-Date -Format 'yyyyMMdd-HHmmss'
$runRoot     = Join-Path $PSScriptRoot "LiveBatchRuns\$stamp"
New-Item -ItemType Directory -Path $runRoot -Force | Out-Null
$progressLog = Join-Path $runRoot 'progress.log'
$resultsCsv  = Join-Path $runRoot 'results.csv'

function Write-ProgressLine {
  param([string]$Line)
  $ts = Get-Date -Format 's'
  Add-Content -Path $progressLog -Value "$ts $Line"
}

# ---------------------------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------------------------

# The wrapper's Set-Jobname value is "T3_20_<KEY sanitised>_LIVE" (Generate-Release-Wrappers.ps1);
# the real joblog filename is "<JobName>_<id><timestamp>.log" under Basepaths\Logs\<yyyymmdd>\.
function Find-JobLogForKey {
  param([string]$Key, [datetime]$SinceTime)
  $jobName = "T3_20_$($Key -replace '[^A-Za-z0-9_]','_')_LIVE"
  $dateFolder = Join-Path $LogsRoot (Get-Date -Format 'yyyyMMdd')
  if (-not (Test-Path $dateFolder)) { return $null }
  # ${jobName}_ braces are REQUIRED: "$jobName_*.log" parses as a variable literally named
  # `$jobName_` (underscore is a valid identifier char), which is undefined -> under Set-StrictMode
  # it throws "The variable '$jobName_' cannot be retrieved because it has not been set." That was
  # the real root cause of every RUN-LIVEBATCH failure on 261006-07, repeatedly misread as a
  # BatchController error-formatting quirk.
  $candidates = @(Get-ChildItem -Path $dateFolder -Filter "${jobName}_*.log" -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -ge $SinceTime } | Sort-Object LastWriteTime -Descending)
  if ($candidates.Count) { return $candidates[0].FullName }
  return $null
}

function Stop-ProcessTree {
  param([int]$ProcessId)
  try {
    & taskkill /T /F /PID $ProcessId *> $null
    return $true
  } catch {
    return $false
  }
}

# ---------------------------------------------------------------------------------------------
# Run one program as its own child process, watched for runaway/stall/timeout.
# ---------------------------------------------------------------------------------------------
function Invoke-OneProgram {
  param([string]$Key)

  $limits      = Get-Limits -Key $Key
  $wrapperPath = Join-Path $PSScriptRoot "$Key-LIVE.ps1"
  $outFile     = Join-Path $runRoot "$Key.out.txt"
  $errFile     = Join-Path $runRoot "$Key.err.txt"
  $start       = Get-Date

  if (-not (Test-Path $wrapperPath)) {
    Write-ProgressLine "$Key SKIP - wrapper not found: $wrapperPath"
    return [PSCustomObject]@{
      Key = $Key; StartTime = $start; EndTime = $start; ElapsedSec = 0; CpuSec = 0
      ExitCode = $null; Outcome = 'SkippedMissingWrapper'; Rule = ''
      JobLogBytes = 0; JobLogFile = ''; KnownIssue = ''; ErrorSummary = 'wrapper file not found'
    }
  }

  Write-ProgressLine "$Key START wrapper=$wrapperPath"
  $proc = Start-Process -FilePath 'pwsh' `
            -ArgumentList @('-NoProfile', '-NonInteractive', '-File', $wrapperPath) `
            -RedirectStandardOutput $outFile -RedirectStandardError $errFile `
            -NoNewWindow -PassThru

  $jobLogPath      = $null
  $lastJobLogLen   = -1
  $lastProgressAt  = Get-Date
  $killedRule      = $null

  while (-not $proc.HasExited) {
    Start-Sleep -Seconds $limits.PollSec
    try { $proc.Refresh() } catch { }
    if ($proc.HasExited) { break }

    $elapsedSec = ((Get-Date) - $start).TotalSeconds
    $cpuSec     = 0
    try { $cpuSec = $proc.TotalProcessorTime.TotalSeconds } catch { }

    if (-not $jobLogPath) { $jobLogPath = Find-JobLogForKey -Key $Key -SinceTime $start }
    $jobLogLen = 0
    if ($jobLogPath -and (Test-Path $jobLogPath)) { $jobLogLen = (Get-Item $jobLogPath).Length }
    if ($jobLogLen -ne $lastJobLogLen) { $lastJobLogLen = $jobLogLen; $lastProgressAt = Get-Date }
    $stalledForSec = ((Get-Date) - $lastProgressAt).TotalSeconds

    Write-ProgressLine ("$Key heartbeat elapsed={0:N0}s cpu={1:N0}s joblogBytes=$jobLogLen stalledFor={2:N0}s" -f $elapsedSec, $cpuSec, $stalledForSec)

    # Runaway: a core sustained busy relative to elapsed time, past the CPU cap.
    if (($cpuSec -ge $limits.MaxCpuSec) -and ($elapsedSec -gt 0) -and (($cpuSec / $elapsedSec) -gt 0.6)) {
      $killedRule = 'KilledRunaway'; break
    }
    # Stalled: no joblog growth for a while AND not burning CPU either (a genuine blocking wait).
    if (($stalledForSec -ge $limits.StallSec) -and ($cpuSec -lt ($limits.MaxCpuSec * 0.2))) {
      $killedRule = 'KilledStalled'; break
    }
    # Plain timeout: neither pattern matched cleanly, but the hard wall-clock cap was hit regardless.
    if ($elapsedSec -ge $limits.MaxElapsedSec) {
      $killedRule = 'KilledTimeout'; break
    }
  }

  if ($killedRule) {
    Write-ProgressLine "$Key KILL triggered ($killedRule) pid=$($proc.Id)"
    [void](Stop-ProcessTree -ProcessId $proc.Id)
    Start-Sleep -Seconds 2
    try { $proc.Refresh() } catch { }
    if (-not $proc.HasExited) {
      Write-ProgressLine "$Key KILL FAILED - process $($proc.Id) still alive, stopping the whole batch"
      $killedRule = 'KillFailed'
    }
  }

  # WaitForExit only blocks further if the process genuinely still needs to finish tearing down.
  try { $proc.WaitForExit(30000) | Out-Null } catch { }
  $end = Get-Date
  $exitCode = $null
  try { $exitCode = $proc.ExitCode } catch { }
  $cpuFinal = 0
  try { $cpuFinal = $proc.TotalProcessorTime.TotalSeconds } catch { }

  # A fast program can finish inside the first PollSec interval, before the poll loop body ever
  # runs once - found 261006 on a real 5s CFH-COPY run (joblog existed on disk but was never looked
  # up). Always try once more here regardless of what the loop found.
  if (-not $jobLogPath) { $jobLogPath = Find-JobLogForKey -Key $Key -SinceTime $start }

  $outcome = if ($killedRule) { $killedRule } elseif ($exitCode -eq 0) { 'Ok' } else { 'Failed' }

  $errSummary = ''
  if ($outcome -ne 'Ok') {
    $errSummary = (Get-Content $errFile -ErrorAction SilentlyContinue | Select-Object -Last 1)
    if (-not $errSummary) { $errSummary = (Get-Content $outFile -ErrorAction SilentlyContinue | Select-Object -Last 1) }
    if ($killedRule) { $errSummary = "[$killedRule - process terminated, Fin/Cleanup never ran, environment may be dirty] $errSummary" }
  }
  $known = ''
  if ($knownIssues.ContainsKey($Key)) { $known = $knownIssues[$Key] }

  $finalJobLogBytes = 0
  $jobLogFile = ''
  if ($jobLogPath -and (Test-Path $jobLogPath)) {
    $finalJobLogBytes = (Get-Item $jobLogPath).Length
    $jobLogFile = Split-Path $jobLogPath -Leaf
    Copy-Item $jobLogPath (Join-Path $runRoot $jobLogFile) -Force -ErrorAction SilentlyContinue
  }

  Write-ProgressLine "$Key END outcome=$outcome rule=$killedRule exitCode=$exitCode elapsed=$([int]($end-$start).TotalSeconds)s cpu=$([int]$cpuFinal)s joblog=$finalJobLogBytes"

  [PSCustomObject]@{
    Key = $Key; StartTime = $start; EndTime = $end
    ElapsedSec = [int]($end - $start).TotalSeconds; CpuSec = [int]$cpuFinal
    ExitCode = $exitCode; Outcome = $outcome; Rule = $killedRule
    JobLogBytes = $finalJobLogBytes; JobLogFile = $jobLogFile; KnownIssue = $known; ErrorSummary = $errSummary
  }
}

# ---------------------------------------------------------------------------------------------
# Main loop - continues past any outcome, including a kill, to the next key.
# ---------------------------------------------------------------------------------------------
Write-ProgressLine "BATCH START keys=$($keys.Count) listFile=$ListFile runRoot=$runRoot"
$allResults = New-Object System.Collections.Generic.List[object]

foreach ($key in $keys) {
  $result = Invoke-OneProgram -Key $key
  $allResults.Add($result)

  if ($result.Outcome -eq 'KillFailed') {
    Write-ProgressLine "BATCH ABORTED - KillFailed on $key, refusing to start further programs while a stuck process remains"
    break
  }
}

$allResults | Export-Csv -NoTypeInformation -Path $resultsCsv -Encoding UTF8

$okCount = @($allResults | Where-Object { $_.Outcome -eq 'Ok' }).Count
$notOkCount = $allResults.Count - $okCount
Write-ProgressLine "BATCH DONE total=$($allResults.Count) ok=$okCount notOk=$notOkCount resultsCsv=$resultsCsv"

# ---------------------------------------------------------------------------------------------
# One combined log for the whole batch - per-program AMT joblogs are still written individually
# by the real runtime (vendor behaviour, Set-Jobname/Write-JobLog, cannot be changed from here),
# but reviewing a run should not mean opening N+1 separate files. Stitch everything this batch
# produced (progress.log + each program's copied joblog + non-empty stdout/stderr) into one
# chronological file per run.
$combinedLog = Join-Path $runRoot 'Combined.log'
$combined = New-Object System.Text.StringBuilder
[void]$combined.AppendLine("==================== BATCH: $runRoot ====================")
[void]$combined.AppendLine((Get-Content $progressLog -Raw))
foreach ($r in $allResults) {
  [void]$combined.AppendLine("")
  [void]$combined.AppendLine("==================== $($r.Key) - outcome=$($r.Outcome) exitCode=$($r.ExitCode) ====================")
  if ($r.JobLogFile) {
    $jobLogCopy = Join-Path $runRoot $r.JobLogFile
    if (Test-Path $jobLogCopy) {
      [void]$combined.AppendLine("---- joblog: $($r.JobLogFile) ----")
      [void]$combined.AppendLine((Get-Content $jobLogCopy -Raw))
    }
  } else {
    [void]$combined.AppendLine("---- no joblog found for this key ----")
  }
  $errPath = Join-Path $runRoot "$($r.Key).err.txt"
  $errText = Get-Content $errPath -Raw -ErrorAction SilentlyContinue
  if (-not [String]::IsNullOrWhiteSpace($errText)) {
    [void]$combined.AppendLine("---- stderr: $($r.Key).err.txt ----")
    [void]$combined.AppendLine($errText)
  }
}
[IO.File]::WriteAllText($combinedLog, $combined.ToString())
Write-ProgressLine "BATCH COMBINED LOG WRITTEN combinedLog=$combinedLog"

# Deliberately no console output at all (MT-023). Fin performs the real AMT end-of-job (Cleanup,
# joblog close, COM dispose) and exits - required because we called Initialize above. Per-program
# failures do not make the batch itself a failure; inspect results.csv for those.
Fin
