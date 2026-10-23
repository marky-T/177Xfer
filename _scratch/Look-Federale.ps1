$ErrorActionPreference = 'SilentlyContinue'
$fed = 'E:\Repos\Federale_InternalRelease'
'=== compiled programs already in the FEDERALE_APP binaries whose name looks like our SSG programs'
$prog = "$fed\AFBUS_AMT\Binaries\Programs"
(Get-ChildItem $prog -Filter *.dll | Measure-Object).Count | ForEach-Object { "total dlls in Programs: $_" }
Get-ChildItem $prog -Filter *.dll | Where-Object { $_.Name -match 'CFH|COPY|UTILIT|LOADIS|UNLOADIS|FUSBA|LECTIS|CHABAN|TABAN|TAPELD|RECAP|EXTEUR|SCAN_|CONDIS|BABA|ARCHI' } |
  Select-Object -First 40 | ForEach-Object { '{0,-52} {1,9}  {2}' -f $_.Name, $_.Length, $_.LastWriteTime.ToString('yyyy-MM-dd') }
''
'=== top of the programs list (non-AMT dlls), to see the naming convention'
Get-ChildItem $prog -Filter *.dll | Where-Object { $_.Name -notmatch '^(Asysco|System|Microsoft|protobuf|Grpc|Newtonsoft|BCrypt|Renci|FluentFtp|ComScript|AmtComScript|Azure|Google)' } |
  Sort-Object Name | Select-Object -First 25 | ForEach-Object { '{0,-52} {1,9}' -f $_.Name, $_.Length }
''
'=== Scripts_SSG (our first release of the converted SSG)'
$ss = "$fed\Scripts_SSG"
Get-ChildItem $ss -Directory | ForEach-Object { '{0}  ({1} files)' -f $_.Name, (Get-ChildItem $_.FullName -Recurse -File | Measure-Object).Count }
Get-ChildItem $ss -File | ForEach-Object { '{0}  {1}' -f $_.Name, $_.Length }
''
'=== git state of Federale_InternalRelease (read-only)'
git -C $fed branch --show-current
git -C $fed log -3 --format='%h %ad %s' --date=short -- Scripts_SSG
git -C $fed remote -v | Select-Object -First 1
