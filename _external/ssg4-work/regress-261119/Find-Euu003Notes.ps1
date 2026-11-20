$raw = Get-Content 'E:\Repos\SsgTrial\docs\SSG-PowerShell-Trial-Progress.html' -Raw
$plain = $raw -replace '<[^>]+>', '' -replace '&[a-z]+;', ' ' -replace '\s+', ' '
foreach ($m in [regex]::Matches($plain, '.{0,160}(EUU003|test double|stub).{0,160}')) { '* ' + $m.Value; '' }
'--- EXTEUR spec: EUU003 mentions'
Select-String -Path 'E:\Repos\SsgTrial\Conversion\Pipeline\Generic\EXTEUR\spec.md' -Pattern 'EUU00' | ForEach-Object { "L$($_.LineNumber): $($_.Line.Trim())" }
'--- EXTEUR GN cob: CALL'
Select-String -Path 'E:\Repos\SsgTrial\Conversion\Pipeline\Generic\EXTEUR\gen\EXTEUR-GN.cob' -Pattern 'CALL' | ForEach-Object { "L$($_.LineNumber): $($_.Line.Trim())" }
'--- release notes / doc generator mentions'
Select-String -Path 'E:\Repos\SsgTrial\Conversion\Pipeline\Generic\*.ps1', 'E:\Repos\SsgTrial\Conversion\Pipeline\Generic\utilities.json' -Pattern 'EUU003|releaseNote|knownLimit|limitations' | Select-Object -First 15 | ForEach-Object { "$($_.Filename) L$($_.LineNumber): $($_.Line.Trim().Substring(0,[Math]::Min(180,$_.Line.Trim().Length)))" }
