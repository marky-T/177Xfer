# CONDIS2 step G3: run the reference model twice over all cases; the expected outputs must be byte-identical (evidence\model-repeat.txt).
param([String]$Evidence = 'E:\Repos\ssg4-work\redo\CONDIS2-261105_sonnet\evidence')
$ErrorActionPreference = 'Stop'
function Get-Hashes { Get-ChildItem "$PSScriptRoot\cases" -Recurse -File -Filter * | Where-Object { $_.FullName -match '\\expected\\' } | Sort-Object FullName | ForEach-Object { '{0} {1}' -f (Get-FileHash $_.FullName -Algorithm SHA256).Hash, $_.FullName.Substring($PSScriptRoot.Length) } }
& "$PSScriptRoot\CondisModel.ps1"
$h1 = @(Get-Hashes)
& "$PSScriptRoot\CondisModel.ps1"
$h2 = @(Get-Hashes)
$same = ($h1.Count -eq $h2.Count) -and -not (Compare-Object $h1 $h2)
$msg = "Model run twice: $($h1.Count) expected files, byte-identical: $same"
$h1 | Set-Content "$Evidence\model-hashes.txt"
$msg | Set-Content "$Evidence\model-repeat.txt"
$msg
if (-not $same) { exit 1 }
