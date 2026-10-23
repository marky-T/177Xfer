$ErrorActionPreference = 'Continue'
"== time"; Get-Date
"== source file state"
$src = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter\SymstreamProcessor.cs'
$good = 'E:\Repos\SsgTrial\_scratch\ssgfix2\src\SsgConverter\SymstreamProcessor.cs'
'{0} {1}' -f (Get-Item $src).LastWriteTime, $(if ((Get-FileHash $src).Hash -eq (Get-FileHash $good).Hash) { 'MATCHES verified fix' } else { 'DIFFERS from verified fix' })
"== Lion processes"
Get-CimInstance Win32_Process | Where-Object { $_.Name -match 'Lion|AmtFileController' } | Select-Object ProcessId, Name, CreationDate, CommandLine | Format-Table -AutoSize | Out-String -Width 250
"== Lion services"
Get-Service | Where-Object { $_.Name -match 'Lion' -or $_.DisplayName -match 'Lion' } | Select-Object Name, Status, StartType | Format-Table -AutoSize | Out-String
"== Lion.ini (passwords hidden)"
Get-Content E:\Amt\Lion\Lion.ini | ForEach-Object { if ($_ -match 'PSSW|PASSWORD') { ($_ -replace '=.*', '=<hidden>') } else { $_ } } | Select-Object -First 60
"== Lion folder: newest files"
Get-ChildItem E:\Amt\Lion -File | Sort-Object LastWriteTime -Descending | Select-Object -First 15 Name, Length, LastWriteTime | Format-Table -AutoSize | Out-String
"== Lion log folders"
Get-ChildItem E:\Amt\Lion -Directory | Select-Object Name, LastWriteTime | Format-Table -AutoSize | Out-String
"== Apps177 Development owners (sample)"
foreach ($p in 'E:\AMT_Work\Apps177', 'E:\AMT_Work\Apps177\Development', 'E:\AMT_Work\Apps177\Development\Database\QueryObjects\QueryObjects.cs', 'E:\AMT_Work\Apps177\Binaries\Programs') {
  if (Test-Path $p) { '{0}  owner={1}  write-for-Users={2}  {3}' -f $p, (Get-Acl $p).Owner, [bool]((Get-Acl $p).Access | Where-Object { $_.IdentityReference -match 'Users|MTRUMAN' -and $_.FileSystemRights -match 'Write|Modify|FullControl' }), (Get-Item $p).LastWriteTime }
}
"== generated program DLLs"
Get-ChildItem E:\AMT_Work\Apps177\Binaries\Programs -Filter 'ASSURFED_UTILIT_*.dll' -ErrorAction SilentlyContinue | Select-Object Name, LastWriteTime | Format-Table -AutoSize | Out-String
"== LionSource"
Get-Item E:\Repos\ssg4-work\release\cobol\out\AFBUS_2200COBOL.LionSource | Select-Object LastWriteTime
