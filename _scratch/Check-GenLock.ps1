$p = 'E:\AMT_Work\Apps177\Development\Database\QueryObjects\QueryObjects.cs'
"== file"
Get-Item $p | Select-Object FullName, Length, LastWriteTime, IsReadOnly, Attributes | Format-List
"== acl"
(Get-Acl $p).AccessToString
"== folder owner"
(Get-Acl (Split-Path $p)).Owner
"== processes that may hold files"
Get-Process | Where-Object { $_.ProcessName -match 'dotnet|VBCSCompiler|MSBuild|AmtFileController|AmtFC|MockSystem|LionDev|devenv|Code|explorer|MsMpEng|csc|Rider|testhost|CFH|ASSURFED' } |
  Select-Object Id, ProcessName, StartTime, Path | Sort-Object ProcessName | Format-Table -AutoSize | Out-String -Width 220
"== whoami"
whoami; whoami /groups | Select-String 'Administrators|Mandatory Label'
