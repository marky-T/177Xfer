$out = 'E:\Repos\ssg4-work\ssg-call-survey-261120'
$rows = Import-Csv "$out\invoke-ssg-calls.csv" | Where-Object { $_.Ours -eq 'False' }
$pack = Get-ChildItem 'E:\Repos\ssg4-source\01-RunsPrd' -File | ForEach-Object { ($_.BaseName -replace '\(P\)$', '').ToUpper() }
$idx = 'E:\Repos\ssg4-source\RunsPrd-INDEX.csv'
"index present: $(Test-Path $idx)"
$res = foreach ($r in $rows) {
    $base = [IO.Path]::GetFileNameWithoutExtension($r.Script).ToUpper()
    [pscustomobject]@{ Skeleton = ($r.Skeleton -split '[\\/]')[-1]; Script = $r.Script; Line = $r.Line; InPack = ($base -in $pack); SgsFile = $r.SgsFile }
}
$res | Export-Csv "$out\not-ours.csv" -NoTypeInformation
'-- not-ours calls: source runstream in our pack (cards readable)?'
$res | Group-Object Skeleton | Sort-Object Count -Descending | ForEach-Object {
    '{0,-34} calls {1,3}  scripts {2,3}  in pack {3,3}' -f $_.Name, $_.Count, @($_.Group.Script | Select-Object -Unique).Count, @($_.Group | Where-Object InPack).Count
}
'-- script folders of not-ours calls'
$res | Group-Object { ($_.Script -split '\\')[1] } | Sort-Object Count -Descending | ForEach-Object { '{0,5}  {1}' -f $_.Count, $_.Name }
'-- sample: lines around one DBASSG and one ARCHIFUSION call'
foreach ($k in 'DBASSG_EGUNL', 'UTILIT_ARCHIFUSION', 'repssg_ctltot') {
    $s = $res | Where-Object { $_.Skeleton -eq $k } | Select-Object -First 1
    if (-not $s) { continue }
    $p = 'E:\Repos\Federale_InternalRelease\' + $s.Script
    "== $k : $($s.Script) L$($s.Line)"
    $l = Get-Content -LiteralPath $p
    $i = [int]$s.Line - 1
    $l[[Math]::Max(0, $i - 6)..[Math]::Min($l.Count - 1, $i + 3)] | ForEach-Object { '   ' + $_.Substring(0, [Math]::Min(150, $_.Length)) }
}
