$files = Get-ChildItem 'E:\Repos\SsgTrial\Conversion\Pipeline' -Filter *.ps1 -Recurse
$hits = Select-String -Path $files.FullName -Pattern 'Control Center|BatchController|Start Job|AmtPowershellHost|Set-Jobname|Connect-Application' -List
$out = 'E:\Repos\SsgTrial\_scratch\cc-check.txt'
if ($hits) { $hits | Select-Object Path, LineNumber, Line | Format-Table -AutoSize | Out-File $out }
else { 'No matches' | Out-File $out }
"files scanned: $($files.Count)"
