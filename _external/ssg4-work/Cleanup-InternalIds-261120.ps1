param([Switch]$WhatIf)
# Rule 12 cleanup 261120: internal register ids in delivered sources -> board lines / plain words.
$root = 'E:\Repos\SsgTrial\Conversion\Pipeline\Generic'
$C = '      * '   # COBOL comment prefix (indicator in column 7)
$story119 = 'User story: 119872'; $story121 = 'User story: 121355'
$cs = "AMT's SGS labels were case-sensitive before its 11 Nov 2026 fix; the hand-offs use upper case either way"
$R = @(
  # ---- COBOL headers
  @('BABA\gen\BABA-GN.cob',         "$C`SSG-4 (MT-043): one BABA for every call. Key fields, mode,",   "$C$story119`n$C`SSG-4: one BABA for every call. Key fields, mode,")
  @('CFH-COPY\gen\CFH-COPY-GN.cob', "$C`SSG-4 spike (MT-043): one CFH-COPY for every call. Record shapes,", "$C$story119`n$C`SSG-4: one CFH-COPY for every call. Record shapes,")
  @('CHABAN\gen\CHABAN-GN.cob',     "$C`SSG-4 (MT-043): one CHABAN for every CHABAN and CHAB100 call.", "$C$story119`n$C`SSG-4: one CHABAN for every CHABAN and CHAB100 call.")
  @('CONDIS2\gen\CONDIS2-GN.cob',   "$C`SSG-4 (MT-043): one CONDIS2 for every call. Conditions",       "$C$story119`n$C`SSG-4: one CONDIS2 for every call. Conditions")
  @('FUSBA\gen\FUSBA-GN.cob',       "$C`SSG-4 (MT-043): one FUSBA for every FUSBA and FUSBA2 call.",   "$C$story119`n$C`SSG-4: one FUSBA for every FUSBA and FUSBA2 call.")
  @('SCAN\gen\SCAN-GN.cob',         "$C`SSG-4 (MT-043): one SCAN for every call. Record length, the",  "$C$story119`n$C`SSG-4: one SCAN for every call. Record length, the")
  @('TAPELD\gen\TAPELD-GN.cob',     "$C`SSG-4 (MT-043): one TAPELD (CFH-COPY to PRINTER with page",    "$C$story119`n$C`SSG-4: one TAPELD (CFH-COPY to PRINTER with page")
  @('LECTIS\gen\LECTIS-GN.cob',     "$C`SSG-4 (MT-056): one LECTIS for every call. Record length, key", "$C$story119`n$C`SSG-4: one LECTIS for every call. Record length, key")
  @('ARCHISEPARE\gen\ARCHISEPARE-GN.cob', "$C`SSG-4 archive work (MT-050): one ARCHISEPARE for every call. Key", "$C$story119`n$C`SSG-4 archive work: one ARCHISEPARE for every call. Key")
  @('ARCHIFORMAT\gen\ARCHIFORMAT-GN.cob', "$C`SSG-4 archive work (MT-050): one ARCHIFORMAT for all calls. Key,", "$C$story119`n$C`SSG-4 archive work: one ARCHIFORMAT for all calls. Key,")
  @('ARCHIFORMAT\gen\ARCHIFORMAT-GN.cob', "$C(T3-040); the areas keep their last record at end of file.", "${C}bytes, as AMT's line reader can merge short lines; the areas`n${C}keep their last record at end of file.")
  @('RECAP\gen\RECAP-GN.cob',       "$C`SSG-4 (MT-069): one RECAP for every call. Field, amount, key",  "$C$story121`n$C`SSG-4: one RECAP for every call. Field, amount, key")
  @('TABAN\gen\TABAN-GN.cob',       "$C`SSG-4 (MT-069): one TABAN for every call. Amount fields, key",  "$C$story121`n$C`SSG-4: one TABAN for every call. Amount fields, key")
  @('EXTEUR\gen\EXTEUR-GN.cob',     "$C`SSG-4 (MT-069): one EXTEUR for every call. Record length,",     "$C$story121`n$C`SSG-4: one EXTEUR for every call. Record length,")
  # ---- hand-off headers
  @('BABA\gen\BabaParm.ps1',     '# SSG-4 (MT-043): parameter file for the generic BABA program', "# $story119`n# SSG-4: parameter file for the generic BABA program")
  @('CFH-COPY\gen\CfhCopyParm.ps1', '# SSG-4 spike (MT-043): parameter file for the generic CFH-COPY program', "# $story119`n# SSG-4: parameter file for the generic CFH-COPY program")
  @('CHABAN\gen\ChabanParm.ps1', '# SSG-4 (MT-043): parameter file for the generic CHABAN program', "# $story119`n# SSG-4: parameter file for the generic CHABAN program")
  @('CONDIS2\gen\CondisParm.ps1', '# SSG-4 (MT-043): parameter file for the generic CONDIS2 program', "# $story119`n# SSG-4: parameter file for the generic CONDIS2 program")
  @('FUSBA\gen\FusbaParm.ps1',   '# SSG-4 (MT-043): parameter file for the generic FUSBA program', "# $story119`n# SSG-4: parameter file for the generic FUSBA program")
  @('SCAN\gen\ScanParm.ps1',     '# SSG-4 (MT-043): parameter file for the generic SCAN program', "# $story119`n# SSG-4: parameter file for the generic SCAN program")
  @('TAPELD\gen\TapeldParm.ps1', '# SSG-4 (MT-043): parameter file for the generic TAPELD program', "# $story119`n# SSG-4: parameter file for the generic TAPELD program")
  @('LOADIS\gen\LoadisParm.ps1', '# SSG-4 (MT-043): LOADIS / UNLOADIS without a program of their own.', "# $story119`n# SSG-4: LOADIS / UNLOADIS without a program of their own.")
  @('LECTIS\gen\LectisParm.ps1', '# SSG-4 (MT-056): parameter file + hand-off for the generic LECTIS program', "# $story119`n# SSG-4: parameter file + hand-off for the generic LECTIS program")
  @('ARCHISEPARE\gen\ArchisepareParm.ps1', '# SSG-4 archive work (MT-050): parameter file for the generic ARCHISEPARE program', "# $story119`n# SSG-4 archive work: parameter file for the generic ARCHISEPARE program")
  @('ARCHIFORMAT\gen\ArchiformatHandoff.ps1', '# SSG-4 archive work (MT-050): parameter file + hand-off for the generic ARCHIFORMAT program.', "# $story119`n# SSG-4 archive work: parameter file + hand-off for the generic ARCHIFORMAT program.")
  @('RECAP\gen\RecapParm.ps1',   '# SSG-4 (MT-069): parameter file + hand-off for the generic RECAP program', "# $story121`n# SSG-4: parameter file + hand-off for the generic RECAP program")
  @('TABAN\gen\TabanParm.ps1',   '# SSG-4 (MT-069): parameter file + hand-off for the generic TABAN program', "# $story121`n# SSG-4: parameter file + hand-off for the generic TABAN program")
  @('EXTEUR\gen\ExteurParm.ps1', '# SSG-4 (MT-069): parameter file + hand-off for the generic EXTEUR program', "# $story121`n# Issue: 121357`n# SSG-4: parameter file + hand-off for the generic EXTEUR program")
  @('GnHandoff.ps1',             '# SSG-4 (MT-043): shared skeleton hand-off for the generic programs', "# $story119`n# SSG-4: shared skeleton hand-off for the generic programs")
  # ---- T3-028 -> Bug 121376
  @('GnHandoff.ps1', "# The call's SGS images from the raw card file (Invoke-Ssg's `$SgsFilePath), for cards AddTo-SgsList cannot split`n# (quoted subfields with spaces, T3-028).", "# Bug: 121376`n# The call's SGS images from the raw card file (Invoke-Ssg's `$SgsFilePath), for cards AddTo-SgsList cannot split`n# (quoted subfields with spaces).")
  @('CFH-COPY\gen\CfhCopyParm.ps1', "  # AddTo-SgsList splits a card at every space,", "  # Bug: 121376`n  # AddTo-SgsList splits a card at every space,")
  @('CFH-COPY\gen\CfhCopyParm.ps1', 'is in scope (T3-028).', 'is in scope.')
  @('CONDIS2\gen\CondisParm.ps1', "# FILEIN/FILEOUT come from GetSgsValue; the PG cards", "# Bug: 121376`n# FILEIN/FILEOUT come from GetSgsValue; the PG cards")
  @('CONDIS2\gen\CondisParm.ps1', "(PG CASE 74,2,''  '', T3-028).", "(PG CASE 74,2,''  '').")
  @('TAPELD\gen\TapeldParm.ps1', "# call's SGS cards (spec.md). INPUT/OUTPUT/FIELDIN/FIELDOUT", "# Bug: 121376`n# call's SGS cards (spec.md). INPUT/OUTPUT/FIELDIN/FIELDOUT")
  @('TAPELD\gen\TapeldParm.ps1', 'quoted titles at their spaces (T3-028).', 'quoted titles at their spaces.')
  @('LECTIS\gen\LectisParm.ps1', "  # a quoted word: AMT's card parser keeps the quotes of a plain 'text' and cannot keep a blank inside it (T3-028)", "  # Bug: 121376`n  # a quoted word: AMT's card parser keeps the quotes of a plain 'text' and cannot keep a blank inside it")
  # ---- our own fixes (no ticket): plain words
  @('GnHandoff.ps1', '  # T3-040: lines padded to the record length,', '  # Lines padded to the record length,')
  @('GnHandoff.ps1', '  # T3-041: an earlier call (another qualifier)', '  # An earlier call (another qualifier)')
  @('GnHandoff.ps1', '  # MT-044: the Xqt name -> program map', "  # Task: 119872/120437`n  # The Xqt name -> program map")
  @('CONDIS2\gen\CondisParm.ps1', 'reset at each CASE/OTHERWISE (T3-057).', 'reset at each CASE/OTHERWISE.')
  @('CONDIS2\gen\CondisParm.ps1', "  # Not reproduced: the [*CASE] = 0 test on OTHERWISE (unset SGS variable; T3-056, unresolved).", "  # User story: 120439`n  # Not reproduced: the [*CASE] = 0 test on OTHERWISE (it tests an SGS variable that is never set).")
  @('ARCHISEPARE\gen\ArchisepareParm.ps1', "# AMT's GetSgsValue returns `$null for a missing label, silently (T3-050): stop instead.", "# AMT's GetSgsValue returns `$null for a missing label, silently: stop instead.")
  @('ARCHISEPARE\gen\ArchisepareParm.ps1', "  # AMT's SgsLabels dictionary is case-sensitive (AmtPsEclLib StartSSG) and real cards use upper-case labels (T3-054).", "  # $cs.")
  @('ARCHIFORMAT\gen\ArchiformatHandoff.ps1', "  # AMT's SgsLabels dictionary is case-sensitive (AmtPsEclLib StartSSG) and real cards use upper-case labels (T3-054).", "  # $cs.")
  @('ARCHIFORMAT\gen\ArchiformatEcl.ps1', '   # case-sensitive labels in AMT (T3-054)', '   # upper-case labels, as on the cards')
  @('EXTEUR\gen\ExteurParm.ps1', "# AMT's label store is case-sensitive (T3-054); GetSgsValue returns strings, `$null when missing (T3-048, T3-050).", "# $cs; GetSgsValue returns strings, `$null when missing.")
  @('RECAP\gen\RecapParm.ps1',   "# AMT's label store is case-sensitive (T3-054); GetSgsValue returns strings, `$null when missing (T3-048, T3-050).", "# $cs; GetSgsValue returns strings, `$null when missing.")
  @('TABAN\gen\TabanParm.ps1',   "# AMT's label store is case-sensitive (T3-054); GetSgsValue returns strings, `$null when missing (T3-048, T3-050).", "# $cs; GetSgsValue returns strings, `$null when missing.")
  @('LECTIS\gen\LectisParm.ps1', "# AMT's label store is case-sensitive (T3-054); GetSgsValue returns strings, `$null for a missing label (T3-048).", "# $cs; GetSgsValue returns strings, `$null for a missing label.")
  @('EXTEUR\gen\ExteurParm.ps1', '(rule 10; column aliased, T3-055).', '(column aliased: OpenQuery rejects duplicate column names).')
  @('ARCHIVE\ArchiveSqlLib.ps1', '(T3-055).', '.')
  # ---- ARCHIFORMAT ECL steps: Bug 118384 (converter lost the SGS references), User story 120443 (UnloadSql target)
  @('ARCHIVE\ArchiveSqlLib.ps1', "# SQL Server stand-ins for ARCHIFORMAT's two ECL processor steps (owner decisions 261103, plan Q2/Q7, T3-053):", "# User story: 120443`n# SQL Server stand-ins for ARCHIFORMAT's two ECL processor steps (owner decisions 261103):")
  @('ARCHIVE\ArchiveSqlLib.ps1', '# Target, not done yet (MT-052): AMT', '# Target, not done yet: AMT')
  @('ARCHIFORMAT\gen\ArchiformatEcl.ps1', "# ARCHIFORMAT skeleton lines 1-35 (its ECL), route B of T3-052 (owner decision 261103): the AmtPsEclLib calls the ECL converter", "# Bug: 118384`n# User story: 120443`n# ARCHIFORMAT skeleton lines 1-35 (its ECL), written by hand (owner decision 261103): the AmtPsEclLib calls the ECL converter")
  @('ARCHIFORMAT\gen\ArchiformatEcl.ps1', "# (target: AMT's UnloadSql -WithDescription + an adapter, MT-052 / T3-053). Route A (the converter does this itself) = MT-051.", "# (target: AMT's UnloadSql -WithDescription + an adapter). Once a converter build with the fix keeps the references, its output can replace these lines.")
)
$changed = @{}
if ($R.Count % 3) { throw "replacement list is not in triples ($($R.Count))" }
# @(...) flattens the nested arrays, so $R is a flat list of (file, old, new) triples.
for ($k = 0; $k -lt $R.Count; $k += 3) {
  $one = $R[$k..($k + 2)]
  $f = Join-Path $root $one[0]
  # COBOL sources are Latin-1 (single-byte accents); reading them as UTF-8 destroys those bytes.
  $enc = if ($f -like '*.cob') { [Text.Encoding]::GetEncoding('iso-8859-1') } else { New-Object System.Text.UTF8Encoding($false) }
  if (-not $changed.ContainsKey($f)) { $changed[$f] = [IO.File]::ReadAllText($f, $enc) }
  $t = $changed[$f]; $eol = if ($t.Contains("`r`n")) { "`r`n" } else { "`n" }
  $old = $one[1].Replace("`n", $eol); $new = $one[2].Replace("`n", $eol)
  $n = ([regex]::Matches($t, [regex]::Escape($old))).Count
  if ($n -ne 1) { throw "$($one[0]): expected 1 match, found $n for: $($one[1])" }
  $changed[$f] = $t.Replace($old, $new)
}
foreach ($f in $changed.Keys) {
  $left = [regex]::Matches($changed[$f], '\b(T3|MT)-\d{3}\b') | ForEach-Object Value
  if ($left) { Write-Warning "$f still has: $($left -join ', ')" }
  if ($f -like '*.cob') { $long = $changed[$f] -split "`r?`n" | Where-Object { $_.Length -gt 72 -and $_ -match '^\s{6}\*' }; if ($long) { throw "$f comment beyond column 72: $long" } }
  if (-not $WhatIf) { $enc = if ($f -like '*.cob') { [Text.Encoding]::GetEncoding('iso-8859-1') } else { New-Object System.Text.UTF8Encoding($false) }; [IO.File]::WriteAllText($f, $changed[$f], $enc) }
}
"$($R.Count / 3) replacements in $($changed.Count) files" + $(if ($WhatIf) { ' (WhatIf: nothing written)' } else { ' written' })
