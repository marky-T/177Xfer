$rows = Import-Csv E:\Repos\ssg4-work\generic\regress-results-unicode.csv | Where-Object { $_.Time -like '2026-11-19*' }
foreach ($g in ($rows | Group-Object Key)) {
    $r = $g.Group[-1]
    $d = $r.Detail -replace '\(full report[^)]*\)', ''
    if ($d.Length -gt 330) { $d = $d.Substring(0, 330) }
    "$($r.Key) :: $d"
}
