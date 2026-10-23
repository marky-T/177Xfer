$hits = Select-String -Path 'E:\Repos\SsgTrial\docs\Reference Docs\*.md' -Pattern '_AMT\b' -SimpleMatch
$out = 'E:\Repos\SsgTrial\_scratch\amt-suffix-manual.txt'
if ($hits) { $hits | Select-Object Path, LineNumber, Line | Format-Table -AutoSize | Out-File $out -Width 300 }
else { 'No matches for literal _AMT in the manuals' | Out-File $out }
"done"
