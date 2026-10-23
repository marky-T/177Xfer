$ErrorActionPreference = 'SilentlyContinue'
'=== 177Xfer clone'
git -C E:\Repos\177Xfer branch --show-current
git -C E:\Repos\177Xfer log -1 --format='%h %ad %s' --date=short
'--- files in 8.0.26230.0'; Get-ChildItem E:\Repos\177Xfer\8.0.26230.0 -File | ForEach-Object { '{0} {1}' -f $_.Name, $_.Length }
'--- Lion folder (LionDev 177)'; (Get-ChildItem E:\Repos\177Xfer\Lion -File | Measure-Object).Count; Get-ChildItem E:\Repos\177Xfer\Lion -File | Where-Object { $_.Name -match 'LionDev|Lion\.ini|Sample' } | ForEach-Object { '{0} {1}' -f $_.Name, $_.Length }
''
'=== Does Federale''s AmtFramework tree match the Y:\ layout the generated projects use?'
$af = 'E:\Repos\Federale_InternalRelease\AmtFramework'
$need = 'Amt.Net\Libraries\Libs\Asysco.Amt.Libs.csproj', 'Amt.Net\Libraries\Asysco.Amt.AmtSharedDataModel\Asysco.Amt.AmtSharedDataModel.csproj',
        'Amt.Net\Libraries\Runtime\Asysco.Amt.Runtime.csproj', 'Amt.Net\ComScript\ComScript\AmtComScript.csproj',
        'Amt.Net\ComScript\AmtComScriptService\AmtComScriptService.csproj', 'Amt.Net\Libraries\FTP\Asysco.Amt.Ftp.csproj',
        'Amt.Net\Libraries\serializerwrappers\Asysco.Amt.SerializerWrappers.csproj', 'Amt.Net\AmtScreens\Common\Asysco.Amt.Screens.Common.csproj',
        'Amt.Net\Security\Asysco.Amt.Security.Server\Asysco.Amt.Security.Server.csproj'
foreach ($n in $need) { '{0,-8} {1}' -f $(if (Test-Path (Join-Path $af $n)) { 'present' } else { 'MISSING' }), $n }
'--- size of AmtFramework (GB)'; '{0:N1}' -f ((Get-ChildItem $af -Recurse -File | Measure-Object Length -Sum).Sum / 1GB)
'--- the 179 source we use now (Y:)'; Get-ChildItem E:\AMT_Y\CSharpNet -Directory | ForEach-Object Name
'--- Y: today'; (Get-PSDrive Y -ErrorAction SilentlyContinue).Root; cmd /c "subst" 2>$null
''
'=== E:\Amt size (GB) and Lion.ini present'
'{0:N2}' -f ((Get-ChildItem E:\Amt -Recurse -File | Measure-Object Length -Sum).Sum / 1GB)
Test-Path E:\Amt\Lion\Lion.ini
