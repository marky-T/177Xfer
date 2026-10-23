<#
.SYNOPSIS
  Tests the SGS card rules (the deliberate changes) against the SSG manual's own examples and real cards.
.DESCRIPTION
  Part 1: ConvertTo-AmtSgsCard on single cards. Part 2: Export-SgsCards on a small runstream built from
  the manual's continuation examples (78311784-010 s3.1.1, examples 1 to 3).
  Exit code 0 = every case as expected.
#>
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'SgsCardChecks.ps1')

$cases = @(
  # name, card, expected card, expected changes, expected unfixable
  @('manual ex.5: spaces after comma, then period', 'LABEL5 Leading,          spaces in a subfield are ignored.', 'LABEL5 Leading,spaces in a subfield are ignored', 'SGS-PERIOD-CUT SGS-SPACE-AFTER-COMMA-REMOVED', ''),
  @('manual ex.6: null subfields with quote pairs', "LABEL6 These,,are,'''',three ,examples of null subfields", 'LABEL6 These,,are,,three ,examples of null subfields', 'SGS-DOUBLE-QUOTE-STRIPPED', ''),
  @('real: period starts a comment (INDIC)', 'INDIC      5,3  8,3  1,4        .TOTAUX PAR BRANCHE/DIVISION/ANNEE', 'INDIC      5,3  8,3  1,4', 'SGS-PERIOD-CUT', ''),
  @('real: period after spaces (KEYS)', 'KEYS       E 3288,1,D                      . CD-ETA-GST-TRM', 'KEYS       E 3288,1,D', 'SGS-PERIOD-CUT', ''),
  @('real: plain card unchanged', 'FIXE 1,10,TAX-CLASIQ', 'FIXE 1,10,TAX-CLASIQ', '', ''),
  @('period inside quotes is kept', "FIXE 2,6,'SUF.'", "FIXE 2,6,'SUF.'", '', ''),
  @('single-quoted subfield keeps its quotes', "FIXE 2,6,'POLICE' 10,7,'BRANCHE'", "FIXE 2,6,'POLICE' 10,7,'BRANCHE'", '', ''),
  @('real: quote pair around digits', "PG CASE 74,2,''0000''", 'PG CASE 74,2,0000', 'SGS-DOUBLE-QUOTE-STRIPPED', ''),
  @('NOT FIXABLE: quoted subfield with spaces', "FIXE 31,27,'MULTIPLES COUCHE HIST 31/12'", "FIXE 31,27,'MULTIPLES COUCHE HIST 31/12'", '', 'SGS-QUOTED-SPECIAL'),
  @('NOT FIXABLE: quote pair around blanks', "PG CASE 74,2,''  '' 81,5", "PG CASE 74,2,''  '' 81,5", '', 'SGS-QUOTED-SPECIAL')
)

$fail = 0
foreach ($c in $cases) {
  $r = ConvertTo-AmtSgsCard $c[1]
  $ok = ($r.Card -ceq $c[2]) -and ((@($r.Changes | Sort-Object) -join ' ') -ceq $c[3]) -and ((@($r.Unfixable) -join ' ') -ceq $c[4])
  if (-not $ok) { $fail++ }
  "{0,-5} {1}" -f $(if ($ok) { 'ok' } else { 'FAIL' }), $c[0]
  if (-not $ok) { "        got card     : $($r.Card)"; "        got changes  : $($r.Changes -join ' ')"; "        got unfixable: $($r.Unfixable -join ' ')" }
}

# Part 2: continuation, through the export script
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) 'ssg4-card-rules-test'
if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
New-Item -ItemType Directory -Path "$tmp\in" | Out-Null
$runstream = @(
  '@RUN,M/T   TESTRUN,ACCT,PROJ,S8000',
  '@SSG,IA  *UTILIT.CFH-COPY/ASCII',
  'SGS',
  'LABEL1 This SGS will be continued ;',
  'to the next line because of the trailing semicolon',
  'LABEL2 This SGS will be continued,;',
  '   to the next line because of the trailing semicolon',
  'LABEL3 This SGS will not be continued; because the semicolon is',
  'embedded',
  'LABEL4 last card ;',
  '@EOF'
)
[System.IO.File]::WriteAllLines("$tmp\in\TESTRUN(P).TXT", $runstream, [System.Text.Encoding]::GetEncoding(1252))
& pwsh -NoProfile -File (Join-Path $PSScriptRoot 'Export-SgsCards.ps1') -RunstreamDir "$tmp\in" -OutDir "$tmp\out" | Out-Null
$got = @(Get-Content (Get-ChildItem "$tmp\out\calls" -Filter *.sgs | Select-Object -First 1).FullName)
$want = @(
  'LABEL1 This SGS will be continued to the next line because of the trailing semicolon',
  'LABEL2 This SGS will be continued,to the next line because of the trailing semicolon',
  'LABEL3 This SGS will not be continued; because the semicolon is',
  'embedded'
)
$ok = (($got -join "`n") -ceq ($want -join "`n"))
$codes = @(Import-Csv "$tmp\out\sgs-warnings.csv" | ForEach-Object Code | Sort-Object -Unique) -join ' '
$ok2 = ($codes -ceq 'SGS-CONTINUED SGS-LAST-CONTINUED-DROPPED')
if (-not $ok) { $fail++ }; if (-not $ok2) { $fail++ }
"{0,-5} {1}" -f $(if ($ok) { 'ok' } else { 'FAIL' }), 'manual ex.1-3: continuation joined, embedded semicolon kept, last " ;" card dropped'
"{0,-5} {1}" -f $(if ($ok2) { 'ok' } else { 'FAIL' }), "changes reported: $codes"
if (-not $ok) { "        got: " + ($got -join ' | ') }
Remove-Item $tmp -Recurse -Force

if ($fail) { "RESULT: $fail FAILED"; exit 1 } else { 'RESULT: PASS'; exit 0 }
