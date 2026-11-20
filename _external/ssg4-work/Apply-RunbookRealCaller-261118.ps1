<#
.SYNOPSIS
  Owner, ELEVATED window: insert the section "How the conversion decides what to support: real calls, and what is left for
  Federale to prove" (id g-real-caller) into docs\SSG4-ControlCenter-Runbook.html, tab 6, right after "Design rules"
  (id g-rules). The runbook is admin-only. Idempotent: does nothing if the section is already there.
#>
$ErrorActionPreference = 'Stop'
$rb = 'E:\Repos\SsgTrial\docs\SSG4-ControlCenter-Runbook.html'
$sec = 'E:\Repos\ssg4-work\runbook-real-caller-section-261118.html'
$t = [IO.File]::ReadAllText($rb)
if ($t.Contains('id="g-real-caller"')) { 'already there: nothing to do'; return }
$nl = if ($t -match "`r`n") { "`r`n" } else { "`n" }
$start = $t.IndexOf('<div class="section-card" id="g-rules">')
if ($start -lt 0) { throw 'section g-rules not found' }
$end = $t.IndexOf('</div>', $start)
if ($end -lt 0) { throw 'end of g-rules not found' }
$at = $end + '</div>'.Length
$add = ([IO.File]::ReadAllText($sec) -replace "`r?`n", $nl).TrimEnd()
$t = $t.Substring(0, $at) + $nl + $nl + $add + $t.Substring($at)
[IO.File]::WriteAllText($rb, $t, [Text.UTF8Encoding]::new($false))
$check = [IO.File]::ReadAllText($rb)
if (-not $check.Contains('id="g-real-caller"')) { throw 'insert did not reach disk' }
"inserted after g-rules: $((Select-String $rb -Pattern 'id="g-real-caller"').LineNumber)"
