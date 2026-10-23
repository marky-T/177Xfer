<#
.SYNOPSIS
  SSG-4: refresh the generated parts of Utilities\PROGRAM-SUMMARY.md for a release.
.DESCRIPTION
  The summary is hand-written except the blocks between <!-- GEN:<name> --> and <!-- /GEN:<name> -->:
    release     release name, application, and the as-at date of the call list
    scope       coverage counts and pie chart
    notcovered  SSG scripts called from the runstreams that no generic program serves
    appendix    Appendix A: every call site per program (runstream, run-id, line, script, cards)
  Counts come from the call inventory (Export-SgsCards.ps1) and utilities.json, so they follow the data.
  Text outside the blocks is kept as it is; re-runs with the same inputs give byte-identical output.
.PARAMETER AsAt
  Date the call list is as at. Default: the newest file date in -RunstreamDir (the source pack).
.EXAMPLE
  pwsh -NoProfile -File Update-GnProgramSummary.ps1 -Release release20261022-rc.02
#>
param(
  [Parameter(Mandatory)][String]$Release,
  [String]$Summary = 'E:\Repos\Federale_InternalRelease-wt-ssg4\BSP_AMT\Development\Utilities\PROGRAM-SUMMARY.md',
  [String]$CallsCsv = 'E:\Repos\ssg4-work\sgs-cards\sgs-calls.csv',
  [String]$RunstreamDir = 'E:\Repos\ssg4-source\01-RunsPrd',
  [Nullable[DateTime]]$AsAt
)
$ErrorActionPreference = 'Stop'
$catalog = Get-Content "$PSScriptRoot\utilities.json" -Raw | ConvertFrom-Json
$packFiles = @(Get-ChildItem $RunstreamDir -File)
if (-not $AsAt) { $AsAt = ($packFiles | Measure-Object LastWriteTime -Maximum).Maximum }
$asAtText = $AsAt.ToString('d MMMM yyyy', [Globalization.CultureInfo]::InvariantCulture)
$short = { param($p) $p -replace '^ASSURFED_UTILIT_', '' }

$progOf = @{}
foreach ($u in $catalog.utilities) { foreach ($s in $u.skeletons) { $progOf[$s.skeleton -replace '^UTILIT_', ''] = $u.program } }
$calls = @(Import-Csv $CallsCsv)
$rows = @($calls | Where-Object { $progOf.ContainsKey($_.ProgramKey) } | ForEach-Object {
    [pscustomobject]@{ Program = $progOf[$_.ProgramKey]; Script = $_.ProgramKey
      Runstream = $_.Runstream -replace '\(P\)', '' -replace '\.TXT$', ''; RunId = $_.RunId; Line = [int]$_.Line; Cards = $_.Cards; Labels = $_.Labels } } |
  Sort-Object Program, Runstream, Line)
$other = @($calls | Where-Object { -not $progOf.ContainsKey($_.ProgramKey) })
$runstreams = @($rows.Runstream | Select-Object -Unique).Count
$calledScripts = @($calls.ProgramKey | Where-Object { $_ } | Select-Object -Unique).Count
$dbCalls = @($other | Where-Object ProgramKey -in 'RECAP', 'TABAN_ASCII').Count

$blocks = [ordered]@{}
$blocks.release = @(
  '| | |', '|---|---|'
  "| **Release** | ``$Release`` |"
  '| **Application** | BSP (`BSP_AMT`, namespace `Federale.BSP.BusinessLogic`) |'
  '| **Audience** | Developers, testers, Federale |'
  "| **Call list (Appendix A) as at** | $asAtText — runstream source pack of $($packFiles.Count) runstreams |"
)
$blocks.scope = @(
  '| | Count |', '|---|---|'
  "| Generic programs delivered | **$(@($rows.Program | Select-Object -Unique).Count)** |"
  "| SSG scripts (skeletons) covered | **$($progOf.Count)** of the $calledScripts called from the runstreams |"
  "| Runstream call sites covered | **$($rows.Count)** of $($calls.Count) ($([math]::Round(100 * $rows.Count / $calls.Count)) %) |"
  "| Converted runstreams that use them | **$runstreams** |"
  ''
  '```mermaid'
  "pie showData title Runstream call sites ($($calls.Count))"
  "    `"Covered by the generic programs`" : $($rows.Count)"
  "    `"RECAP / TABAN (database statements)`" : $dbCalls"
  "    `"Other not covered`" : $($other.Count - $dbCalls)"
  '```'
)
$reason = @{
  'RECAP' = 'Embedded database statements; needs a different approach'
  'TABAN_ASCII' = 'Embedded database statements; needs a different approach'
  'LECTIS_ASCII' = 'No generic program built yet'
  'EXTEUR' = 'Uses a table from the old LINC repository'
}
$blocks.notcovered = @('| Script | Call sites | Reason |', '|---|---|---|') + @($other | Group-Object ProgramKey | Sort-Object { -$_.Count }, Name | ForEach-Object {
    $name = if ($_.Name) { $_.Name } else { '(skeleton not identified)' }
    $why = if ($reason[$_.Name]) { $reason[$_.Name] } else { 'To analyse' }
    "| $name | $($_.Count) | $why |" }) + '| ARCHIFORMAT, ARCHISEPARE, ARCHIFUSION | 0 | Archive utilities; no calling runstream in the source pack |'

$app = @(
  '## Appendix A. Calls by program'
  ''
  "**As at $asAtText** — taken from the runstream source pack ($($packFiles.Count) runstreams). " +
  "$($rows.Count) call sites in $runstreams runstreams. *Line* is the line of the ``@SSG`` statement in the original runstream; " +
  '*Cards* is the number of parameter cards and their keywords.'
)
$n = 0
foreach ($g in $rows | Group-Object Program | Sort-Object Name) {
  $n++
  $rs = @($g.Group.Runstream | Select-Object -Unique).Count
  $app += '', "### A.$n $(& $short $g.Name) — $($g.Count) calls in $rs runstreams", ''
  $app += '| Runstream | Run-id | Line | Script | Cards |', '|---|---|---:|---|---|'
  $app += $g.Group | ForEach-Object { "| $($_.Runstream) | $($_.RunId) | $($_.Line) | $($_.Script) | $($_.Cards): $($_.Labels) |" }
}
$blocks.appendix = $app

$text = [IO.File]::ReadAllText($Summary) -replace '\r?\n', "`r`n"
foreach ($k in $blocks.Keys) {
  $re = "(?s)(<!-- GEN:$k -->\r\n).*?(<!-- /GEN:$k -->)"
  if ($text -notmatch $re) { throw "marker GEN:$k not found in $Summary" }
  $body = ($blocks[$k] -join "`r`n") + "`r`n"
  $text = [regex]::Replace($text, $re, { param($m) $m.Groups[1].Value + $body + $m.Groups[2].Value })
}
[IO.File]::WriteAllText($Summary, $text, [Text.UTF8Encoding]::new($false))
"PROGRAM-SUMMARY.md: $Release, as at $asAtText; $($rows.Count) of $($calls.Count) call sites, $runstreams runstreams"
