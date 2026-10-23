<#
.SYNOPSIS
  Rebuilds a LionDev-generated C# program set against a different AMT runtime (for example Federale's 177a) without touching it.
.DESCRIPTION
  The generated projects reference the AMT libraries as Y:\ source projects, so the DLLs come out stamped with the
  version LionDev was built from (179 = 8.0.26273.0). The .NET loader rejects a strong-named reference to a higher
  version than the runtime has (177a = 8.0.26230.50), so such DLLs cannot run in a 177a environment as they are.
  This copies the generated sources to a scratch folder, swaps the Y:\ project references for the runtime's DLLs
  (copied, never edited in place) and builds. Output: <OutDir>\Binaries\Programs and \Application.
  Known 179 to 177a source difference (found 2026-10-13): ApplicationRt.cs sets AmtApplicationOptions.FunctionKeyForm,
  which 177a does not have; -DropLinePattern removes that line in the scratch copy only. Anything else that differs
  shows up as a compile error, which is the point of building.
.EXAMPLE
  pwsh -NoProfile -File Rebuild-AgainstRuntime.ps1 -Application CFHCOPYASCIIPBDA04L545 -ProgramFolder Cfh_Copy
#>
param(
  [Parameter(Mandatory)][String]$Application,
  [Parameter(Mandatory)][String]$ProgramFolder,
  [String]$Development = 'E:\AMT_Work\Apps\Development',
  [String]$RuntimeDir = 'E:\Repos\Federale_InternalRelease\AFBUS_AMT\Binaries\Programs',
  [String]$SecurityServerDir = 'E:\Repos\Federale_InternalRelease\AFBUS_AMT\Binaries\Application',
  [String]$OutRoot = 'E:\AMT_Work\Rebuild177a',
  [String]$NewtonsoftFrom = 'E:\AMT_Work\Apps\Binaries\Application\Newtonsoft.Json.dll',
  [String]$DropLinePattern = 'options\.FunctionKeyForm'
)
$ErrorActionPreference = 'Stop'
if ($OutRoot -notlike 'E:\AMT_Work\*') { throw 'OutRoot must be under E:\AMT_Work.' }
$out = Join-Path $OutRoot $Application
$lib = Join-Path $OutRoot 'lib'
if (Test-Path $out) { Remove-Item $out -Recurse -Force }
New-Item -ItemType Directory -Force $lib, "$out\Development", "$out\Binaries\Application", "$out\Binaries\Programs" | Out-Null

# copy the runtime DLLs once (read-only use of the source folders)
foreach ($n in 'Asysco.Amt.Libs', 'Asysco.Amt.AmtSharedDataModel', 'Asysco.Amt.Runtime', 'ComScript', 'AmtComScriptService', 'Asysco.Amt.Ftp',
               'Asysco.Amt.SerializerWrappers', 'Asysco.Amt.Screens.Common', 'Asysco.Amt.Windows') {
  Copy-Item (Join-Path $RuntimeDir "$n.dll") $lib -Force
}
Copy-Item (Join-Path $SecurityServerDir 'Asysco.Amt.Security.Server.dll') $lib -Force
Copy-Item $NewtonsoftFrom "$out\Binaries\Application" -Force

# the generated projects of this application
foreach ($rel in 'Application', 'Database', "Programs\$ProgramFolder") {
  Copy-Item (Join-Path $Development $rel) (Join-Path "$out\Development" $rel) -Recurse -Force -Exclude bin, obj
}

# Y:\ project references -> the runtime's DLLs
$dllName = @{ 'AmtComScript' = 'ComScript'; 'Asysco.Amt.Windows' = 'Asysco.Amt.Windows' }
Get-ChildItem "$out\Development" -Recurse -Filter *.csproj | ForEach-Object {
  $t = Get-Content $_.FullName -Raw
  $t = [regex]::Replace($t, '<ProjectReference Include="Y:\\[^"]*\\([^\\"]+)\.csproj">\s*</ProjectReference>', {
      param($m) $n = $m.Groups[1].Value; if ($dllName.ContainsKey($n)) { $n = $dllName[$n] }
      "<Reference Include=`"$n`"><HintPath>$lib\$n.dll</HintPath><Private>false</Private></Reference>" })
  if ($t -match 'Y:\\') { throw "Unconverted Y:\ reference left in $($_.Name)" }
  Set-Content $_.FullName $t -Encoding utf8
}

# 177a lacks one property that 179 generates; drop that line in the scratch copy, then build the program project
$rt = Join-Path $out 'Development\Application\ApplicationRt.cs'
if ($DropLinePattern -and (Test-Path $rt)) { (Get-Content $rt) | Where-Object { $_ -notmatch $DropLinePattern } | Set-Content $rt -Encoding utf8 }
$log = Join-Path $out 'build.log'
$proj = Get-ChildItem "$out\Development\Programs\$ProgramFolder" -Filter *.csproj | Select-Object -First 1
dotnet build $proj.FullName -c Release -p:BaseIntermediateOutputPath="$out\obj\" 2>&1 | Tee-Object $log | Select-String 'error|Build succeeded|Warn.*\d+ Warning' | Select-Object -First 15 | ForEach-Object { $_.Line }
'Output:'; Get-ChildItem "$out\Binaries" -Recurse -Filter "*.dll" | Where-Object { $_.Name -match "^($Application\.|CFH_COPY)" } | ForEach-Object { '  {0}  {1}' -f $_.FullName.Replace("$out\",''), $_.Length }

# the program is looked up by the name inside the class (base("CFH_COPY", ...)), so ship it as <NAME>.dll
$cs = Get-ChildItem "$out\Development\Programs\$ProgramFolder" -Filter '*.cs' | Where-Object { $_.Name -notmatch '\.(Core|Files)\.cs$|^Fd_|Definitions|_Info' } | Select-Object -First 1
$name = [regex]::Match((Get-Content $cs.FullName -Raw), 'base\("([^"]+)"').Groups[1].Value
$built = Get-ChildItem "$out\Binaries\Programs" -Filter "$ProgramFolder.dll" | Select-Object -First 1
if ($name -and $built -and $built.Name -cne "$name.dll") {
  # names that differ only by case are the same file on Windows: go through a temporary name
  $tmp = Join-Path $built.DirectoryName ("tmp_" + $built.Name)
  Move-Item $built.FullName $tmp -Force; Move-Item $tmp (Join-Path $built.DirectoryName "$name.dll") -Force
}
if ($name) { "Program DLL: $name.dll" }
