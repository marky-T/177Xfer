<#
.SYNOPSIS
  SSG-4: wait for a Control Center job, scan its job log for known failure signs, byte-compare its outputs.
.DESCRIPTION
  1. Waits until the BatchController log has "<Job> Done|Error|Abort|Fail" stamped at or after -After.
  2. Finds the job log (<LogPrefix>_*.log written after -After) and flags lines matching known failure signs:
     "already assigned. Ignored" (T3-041), Error, Abort, "Error trapped".
  3. Compares each case in -Cases (JSON list of { Case, Actual, Expected }; Actual = the job's file without extension,
     NAME and NAME.DAT are both tried) byte for byte, and copies outputs and the job log to -Evidence.
  Prints a short summary; the full report goes to <Evidence>\check.txt. Returns the number of failures as exit code.
.EXAMPLE
  Test-CcJob.ps1 -Job SSG4_FUSBA_CASES -LogPrefix FUSBATEST -After '2026-10-20 22:25' -Cases <GenericWork>\FUSBA\cc-cases.json -Evidence <GenericWork>\FUSBA\cc-runs
#>
param(
  [Parameter(Mandatory)][String]$Job,
  [Parameter(Mandatory)][String]$LogPrefix,
  # A time, or ccStartJob's result line as is ("<JOB>: started yyyy-MM-dd HH:mm:ss"): pass it unchanged, never re-type it.
  [Parameter(Mandatory)][String]$After,
  [String]$Cases,
  [Parameter(Mandatory)][String]$Evidence,
  [String]$ShowLines = 'case|hand-off|RECORDS',
  [Int32]$TimeoutSeconds = 600,
  [String]$Environment = 'CC-Trial',
  [String]$Logs
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\GnEnvironment.ps1"
if (-not $Logs) { $Logs = (Get-GnEnvironment $Environment).LogPath }
$m = [regex]::Match($After, '\d{4}-\d{2}-\d{2} \d{2}:\d{2}(:\d{2})?')
if (-not $m.Success) { throw "-After: no time in '$After'" }
$since = [DateTime]::Parse($m.Value).AddSeconds(-2)
New-Item -ItemType Directory -Force $Evidence | Out-Null
$report = [System.Collections.Generic.List[String]]::new()
$say = { param($s) $report.Add($s) }
$bc = Join-Path $Logs ('{0:yyyyMMdd}\FederaleBatchController.Log' -f $since)
$stamp = { param($line) $m = [regex]::Match($line, '^(\d{8})\s+(\d{2}:\d{2}:\d{2})'); if ($m.Success) { [DateTime]::ParseExact("$($m.Groups[1].Value) $($m.Groups[2].Value)", 'yyyyMMdd HH:mm:ss', $null) } }
$end = $null; $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
while (-not $end -and (Get-Date) -lt $deadline) {
  if (Test-Path $bc) {
    $end = Get-Content $bc | Where-Object { $_ -match "\s$([regex]::Escape($Job))\s+(Done|Error|Abort|Fail)" } | Where-Object { (& $stamp $_) -ge $since } | Select-Object -Last 1
  }
  if (-not $end) { Start-Sleep -Seconds 3 }
}
if (-not $end) { "TIMEOUT: no end of $Job after $since in $bc"; exit 99 }
$status = ($end -replace '\s+', ' ').Trim()
& $say "--- BatchController: $status"
$fail = 0
if ($status -notmatch ' Done ') { $fail++ }

$log = Get-ChildItem (Split-Path $bc) -Filter "$($LogPrefix)_*.log" | Where-Object { $_.LastWriteTime -ge $since } | Sort-Object LastWriteTime | Select-Object -Last 1
if ($log) {
  $lines = Get-Content $log.FullName
  & $say "--- $($log.Name)"
  $lines | Where-Object { $_ -match $ShowLines -and $_ -notmatch ' Msg: ' } | ForEach-Object { & $say ('  ' + ($_ -replace '\s+', ' ').Trim()) }
  $signs = @($lines | Where-Object { $_ -match 'already assigned\. Ignored|Error trapped|\bAbort\b|\bError:' })
  foreach ($s in $signs) { & $say ('  FLAG ' + ($s -replace '\s+', ' ').Trim()) }
  $fail += $signs.Count
  Copy-Item $log.FullName $Evidence -Force
} else { & $say "--- no job log $($LogPrefix)_*.log after $since"; $fail++ }

$pass = 0; $total = 0
if ($Cases) {
  foreach ($c in (Get-Content $Cases -Raw | ConvertFrom-Json)) {
    $total++
    $act = Get-Item "$($c.Actual).DAT", $c.Actual -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer } | Select-Object -First 1
    $exp = [IO.File]::ReadAllBytes($c.Expected)
    if (-not $act) { & $say ('{0,-6} {1,-12} not written (expected {2:N0} B)' -f $c.Case, (Split-Path $c.Actual -Leaf), $exp.Length); $fail++; continue }
    if ($act.LastWriteTime -lt $since) { & $say ('{0,-6} {1,-12} STALE (written {2:HH:mm:ss}, before the job)' -f $c.Case, $act.Name, $act.LastWriteTime); $fail++; continue }
    $bytes = [IO.File]::ReadAllBytes($act.FullName)
    $same = $bytes.Length -eq $exp.Length -and [System.Linq.Enumerable]::SequenceEqual([byte[]]$bytes, [byte[]]$exp)
    Copy-Item $act.FullName (Join-Path $Evidence "$($c.Case)-$($act.Name)") -Force
    if ($same) { $pass++ } else { $fail++ }
    & $say ('{0,-6} {1,-12} {2,9:N0} B vs expected {3,9:N0} B: {4}' -f $c.Case, $act.Name, $bytes.Length, $exp.Length, $(if ($same) { 'PASS byte-identical' } else { 'FAIL' }))
  }
  & $say "--- $pass of $total outputs byte-identical"
}
$report | Set-Content (Join-Path $Evidence 'check.txt')
$report | Where-Object { $_ -match '^---|FLAG|FAIL|STALE|not written' }
"=== $Job : $(if ($fail) { "$fail problem(s)" } else { 'all checks passed' }) (full report: $(Join-Path $Evidence 'check.txt'))"
exit $fail
