$out = 'E:\Repos\ssg4-work\ssg-call-survey-261120'
$res = Import-Csv "$out\not-ours.csv"
'-- index columns'
$idx = Import-Csv 'E:\Repos\ssg4-source\RunsPrd-INDEX.csv'
($idx[0].psobject.Properties.Name) -join ', '
"index rows: $($idx.Count)"
$idx | Select-Object -First 2 | Format-List | Out-String -Width 200
'-- samples around calls (fixed path)'
foreach ($k in 'DBASSG_EGUNL', 'UTILIT_ARCHIFUSION', 'repssg_ctltot', 'RUNS_FILE_SSG') {
    $s = $res | Where-Object { $_.Skeleton -eq $k } | Select-Object -First 1
    if (-not $s) { continue }
    $p = 'E:\Repos\Federale_InternalRelease\Scripts\ASSU' + $s.Script
    if (-not (Test-Path -LiteralPath $p)) { $p = 'E:\Repos\Federale_InternalRelease\Scripts\' + $s.Script }
    "== $k : $p L$($s.Line)"
    $l = Get-Content -LiteralPath $p
    $i = [int]$s.Line - 1
    $l[[Math]::Max(0, $i - 8)..[Math]::Min($l.Count - 1, $i + 2)] | ForEach-Object { '   ' + $_.Substring(0, [Math]::Min(150, $_.Length)) }
}
'-- original runstream sources on this VM for not-ours scripts?'
$names = $res | ForEach-Object { [IO.Path]::GetFileNameWithoutExtension($_.Script) } | Select-Object -Unique
"distinct scripts: $($names.Count)"
$roots = 'E:\Repos\ssg4-source', 'E:\Repos\177Xfer-ssg4backup\_external', 'E:\Repos\SsgTrial', 'E:\Repos\Federale_InternalRelease\Valtab', 'E:\Repos\z-old', 'C:\Amt', 'E:\Amt'
$found = @{}
foreach ($r in $roots | Where-Object { Test-Path $_ }) {
    foreach ($f in [IO.Directory]::EnumerateFiles($r, '*.TXT', [IO.SearchOption]::AllDirectories)) {
        $b = ([IO.Path]::GetFileNameWithoutExtension($f) -replace '\(P\)$', '').ToUpper()
        if ($b -in $names) { $found[$b] = $f }
    }
}
"sources found: $($found.Count)"
$found.GetEnumerator() | Select-Object -First 10 | ForEach-Object { "  $($_.Key) -> $($_.Value)" }
