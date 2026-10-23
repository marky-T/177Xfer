$a = 'E:\Repos\ssg4-work\app2\cobol\out\AFBUS_2200COBOL.LionSource'
$b = 'E:\Repos\ssg4-work\release\cobol\out\AFBUS_2200COBOL.LionSource'
git diff --no-index --ignore-space-at-eol -U2 $a $b 2>$null | Select-Object -Skip 4 | ForEach-Object { $_.Substring(0, [Math]::Min(200, $_.Length)) }
'--- sizes'
(Get-Item $a).Length; (Get-Item $b).Length
