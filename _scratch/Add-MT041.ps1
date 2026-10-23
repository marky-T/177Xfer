$ErrorActionPreference = 'Stop'
$file = 'E:\Repos\SsgTrial\docs\SSG-PowerShell-Trial-Progress.html'
$bytes = [IO.File]::ReadAllBytes($file)
$bom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
$text = [IO.File]::ReadAllText($file)
if ($text.Contains('id="MT-041"')) { throw 'MT-041 already present' }
$nl = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
$row = '        <tr id="MT-041"><td><strong>MT-041</strong></td><td>261015</td><td><strong>Convert the next three programs: UNLOADIS_MULTI, LOADIS_MULTI, CHAB100_ASCII (all with real cards, one call each).</strong> Chosen as the simplest left in the ranking that have exported calls (ARCHISEPARE and ARCHIFORMAT have no calls in <code>sgs-calls.csv</code>, CHABAN_ASCII has 30). Run: <code>Invoke-Ssg4Release.ps1 -Stage Prepare</code> for the 6 delivered/generated programs plus these 3 (<code>_scratch\Prepare-Next3.ps1</code>; pass <code>-Programs</code> as an array, not through <code>pwsh -File</code>). First result: the COBOL converter stopped with 7 errors, caused by two converter defects, <a href="#T3-030">T3-030</a> (lone period lines dropped) and <a href="#T3-031">T3-031</a> (<code>*DIVIDE</code>). Both are fixed in a scratch build (<code>_scratch\ssgfix2</code>, 20 of 20 parse 0, Tier-1 20 of 20 OK; only intended lines change). <strong>Next:</strong> user runs <code>_scratch\Land-Fix2.ps1</code> from an elevated shell (lands the source, rebuilds, refreshes the DLLs, regenerates the goldens), then re-run Prepare, LionDev import and generate, Verify. The R&amp;D pull request 15584 does not contain these two fixes; add them as the next update (C-20, C-21) after landing.</td><td><span class="badge badge-prog">in progress</span></td></tr>'
$i = $text.IndexOf('<tr id="MT-040">')
if ($i -lt 0) { throw 'MT-040 row not found' }
$eol = $text.IndexOf("`n", $i)
$text = $text.Substring(0, $eol + 1) + $row + $nl + $text.Substring($eol + 1)
[IO.File]::WriteAllText($file, $text, (New-Object Text.UTF8Encoding($bom)))
'inserted MT-041'
