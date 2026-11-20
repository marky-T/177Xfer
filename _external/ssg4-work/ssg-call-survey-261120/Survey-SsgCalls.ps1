$ours = 'ARCHIFORMAT','ARCHISEPARE','BABA_ASCII','CFH-COPY_ASCII','CFH-COPY','CHAB100_ASCII','CHABAN_ASCII','CONDIS2_ASCII','EXTEUR','FUSBA_ASCII','FUSBA2_ASCII','LECTIS_ASCII','LOADIS_ASCII','LOADIS_MULTI','RECAP','SCAN_ASCII','TABAN_ASCII','TAPELD_ASCII','UNLOADIS_ASCII','UNLOADIS_MULTI'
$out = 'E:\Repos\ssg4-work\ssg-call-survey-261120'
New-Item -ItemType Directory -Force $out | Out-Null

'== 03-SSG-Prd (skeleton sources in the pack)'
Get-ChildItem 'E:\Repos\ssg4-source\03-SSG-Prd' -File | ForEach-Object { $_.Name } | Sort-Object

'== Invoke-Ssg calls in Federale Scripts (R&D converted runstreams)'
$rows = foreach ($f in [IO.Directory]::EnumerateFiles('E:\Repos\Federale_InternalRelease\Scripts', '*.ps1', [IO.SearchOption]::AllDirectories)) {
    $n = 0
    foreach ($line in [IO.File]::ReadLines($f)) {
        $n++
        if ($line -match 'Invoke-Ssg\b') {
            $sk = if ($line -match '-Skeleton\s+"([^"]+)"') { $Matches[1] } else { '(none)' }
            $sg = if ($line -match '-SgsFile\s+"([^"]+)"') { $Matches[1] } else { '' }
            $leaf = ($sk -split '[\\/]')[-1] -replace '^UTILIT_', ''
            [pscustomobject]@{ Script = $f.Substring(46); Line = $n; Skeleton = $sk; Leaf = $leaf; Ours = ($leaf -in $ours); SgsFile = $sg; Text = $line.Trim() }
        }
    }
}
$rows | Export-Csv "$out\invoke-ssg-calls.csv" -NoTypeInformation
"calls: $(@($rows).Count) in $(@($rows.Script | Select-Object -Unique).Count) scripts; ours: $(@($rows | Where-Object Ours).Count); not ours: $(@($rows | Where-Object { -not $_.Ours }).Count)"
'-- not ours, by skeleton'
$rows | Where-Object { -not $_.Ours } | Group-Object Skeleton | Sort-Object Count -Descending | ForEach-Object { '{0,5}  {1}' -f $_.Count, $_.Name }
'-- SgsFile forms (all calls)'
$rows | Group-Object { $_.SgsFile -replace '\\[^\\]+$', '\<run>' } | Sort-Object Count -Descending | Select-Object -First 8 | ForEach-Object { '{0,5}  {1}' -f $_.Count, $_.Name }
'-- P$SGS files on disk'
foreach ($p in 'E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Extracts\P$SGS', 'E:\Repos\Federale_InternalRelease\Scripts\P$SGS') { "$p exists: $(Test-Path -LiteralPath $p)" }
