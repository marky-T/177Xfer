$ErrorActionPreference = 'Stop'
$rc = 'E:\Repos\release_candidates\release20261002-rc.01'
$cs = Join-Path $rc '1_ConvertedScripts'
$fmt = 'yyyy-MM-dd HH:mm'
$rows = foreach ($b in Get-ChildItem (Join-Path $cs 'Bodies') -Filter *.ps1 | Sort-Object Name) {
  $k = $b.BaseName
  $w = Get-Item (Join-Path $cs "Wrappers\$k-LIVE.ps1") -ErrorAction SilentlyContinue
  $s = Get-Item (Join-Path $cs "SgsSeeds\$k.sgs-values.json") -ErrorAction SilentlyContinue
  $src = Get-ChildItem (Join-Path $rc '2_OriginalSource') -Filter "$k*" -File | Select-Object -First 1
  '| `{0}` | `{1}.ps1` | {2} | `{0}-LIVE.ps1` | {3} | `{0}.sgs-values.json` | {4} |' -f $k, $k, $b.LastWriteTime.ToString($fmt), $(if ($w) { $w.LastWriteTime.ToString($fmt) } else { 'missing' }), $(if ($s) { $s.LastWriteTime.ToString($fmt) } else { 'missing' })
}
$gen = Get-Item (Join-Path $cs 'Generate-Release-Wrappers.ps1')
$note = Join-Path $rc 'WITHDRAWN.md'
$t = [IO.File]::ReadAllText($note)
$marker = '## Scripts that are redundant'
if ($t.Contains($marker)) { $t = $t.Substring(0, $t.IndexOf($marker)).TrimEnd() + "`r`n" }
$t = $t.Replace('Contents of this folder are unchanged from 2026-10-02; this note is the only file added.', 'Contents of this folder are unchanged since the dates below; this note is the only file added.')
$add = @"

## Scripts that are redundant (all of ``1_ConvertedScripts``)

Dates are the files' last-modified times (the build dates of this release). The release was labelled 2026-10-02.
Per RELEASE-NOTES.md every body was produced by one SsgConverter build: ``SsgConverter.dll`` (Console), 51 200 bytes, SHA-256 ``C586C60A39F167DA670E2F4F7BD3809C14590449147151470122E4C3D344C1DA``.
That build predates the converter fixes of October (for example T3-018, T3-025/026, T3-030/031, T3-033 to T3-036, T3-043, T3-045), so these bodies are also out of date against the current converter.

| Program | Body | Body built | Wrapper | Wrapper built | SGS seed | Seed built |
|---|---|---|---|---|---|---|
$($rows -join "`r`n")

| Other file | Built |
|---|---|
| ``1_ConvertedScripts/Generate-Release-Wrappers.ps1`` | $($gen.LastWriteTime.ToString($fmt)) |

Total: 20 bodies, 20 wrappers, 20 SGS seeds, 1 generator script.

Not redundant (kept as reference): ``2_OriginalSource/`` (the 20 original SSG source files, dated 2026-09-08), README.md, RELEASE-NOTES.md and VALIDATION-PROMPT.md.
"@
[IO.File]::WriteAllText($note, $t.TrimEnd() + "`r`n" + $add + "`r`n")
"rows: $(@($rows).Count); missing: " + @($rows | Where-Object { $_ -match 'missing' }).Count
