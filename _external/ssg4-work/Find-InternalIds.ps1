$g = 'E:\Repos\SsgTrial\Conversion\Pipeline\Generic'
$files = @(
    Get-ChildItem $g -Recurse -File -Include '*-GN.cob' | Where-Object FullName -notmatch '\\(EUU003STUB|CONDIS2S)\\'
    Get-ChildItem $g -Recurse -File -Filter '*Parm.ps1' | Where-Object { $_.Directory.Name -eq 'gen' -and $_.FullName -notmatch '\\CONDIS2S\\' }
    Get-Item "$g\GnHandoff.ps1"
    Get-ChildItem "$g\skeletons" -File -ErrorAction SilentlyContinue
)
$hits = foreach ($f in $files) {
    $n = 0
    foreach ($line in [IO.File]::ReadLines($f.FullName)) {
        $n++
        foreach ($m in [regex]::Matches($line, '\b(T3|MT)-\d{3}\b')) { [pscustomobject]@{ File = $f.FullName.Substring($g.Length + 1); Line = $n; Id = $m.Value; Text = $line.Trim() } }
    }
}
"files scanned: $($files.Count); hits: $(@($hits).Count) in $(@($hits.File | Select-Object -Unique).Count) files"
$hits | Group-Object File | Sort-Object Count -Descending | ForEach-Object { '{0,4}  {1}' -f $_.Count, $_.Name }
'-- ids'
($hits | Group-Object Id | Sort-Object Count -Descending | ForEach-Object { "$($_.Name) x$($_.Count)" }) -join ', '
$hits | Export-Csv 'E:\Repos\ssg4-work\internal-ids-in-code-261120.csv' -NoTypeInformation
'-- generated C# in the BSP generation (comments carry the COBOL text?)'
$cs = Get-ChildItem 'E:\AMT_Work\AppsBSP177\Development\Programs' -Recurse -File -Filter '*.cs' | Where-Object { $_.FullName -match '_Gn\\' -and $_.FullName -notmatch 'Assurfed_Utilit' }
$csHits = @($cs | Select-String -Pattern '\b(T3|MT)-\d{3}\b')
"generated C# files: $($cs.Count); hits: $($csHits.Count) in $(@($csHits.Path | Select-Object -Unique).Count) files"
