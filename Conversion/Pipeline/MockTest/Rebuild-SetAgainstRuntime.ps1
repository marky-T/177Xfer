<#
.SYNOPSIS
  Rebuilds a whole LionDev 177 generated application against Federale's 177a runtime (workaround, scratch copy only).
.DESCRIPTION
  LionDev 177 (8.0.26230.0) generates base(name, descr, ver, rev, genDate, genTime) calls, but Federale's 177a runtime
  (8.0.26230.50) only has the constructor without genDate/genTime (confirmed in Federale_InternalRelease main, 2026-10-13).
  This copies the generated projects to a scratch folder, swaps the Y:\ project references for the runtime's DLLs,
  drops the two generation-stamp arguments from every program's base(...) call and builds each program in turn.
  Nothing under E:\AMT_Work\Apps177 or the Federale folders is changed. Output: <OutRoot>\<Application>\Binaries\Programs.
.EXAMPLE
  pwsh -NoProfile -File Rebuild-SetAgainstRuntime.ps1 -Application AFBUS_2200COBOL
#>
param(
  [Parameter(Mandatory)][String]$Application,
  [String]$Development = 'E:\AMT_Work\Apps177\Development',
  [String]$RuntimeDir = 'E:\Repos\Federale_InternalRelease\AFBUS_AMT\Binaries\Programs',
  [String]$SecurityServerDir = 'E:\Repos\Federale_InternalRelease\AFBUS_AMT\Binaries\Application',
  [String]$OutRoot = 'E:\AMT_Work\Rebuild177a',
  [String]$NewtonsoftFrom = 'E:\AMT_Work\Apps177\Binaries\Application\Newtonsoft.Json.dll',
  # Only these program folders (e.g. Assurfed_Utilit_Fusba_Gn); the other programs already built in OutRoot are kept.
  [String[]]$Programs
)
$ErrorActionPreference = 'Stop'
if ($OutRoot -notlike 'E:\AMT_Work\*') { throw 'OutRoot must be under E:\AMT_Work.' }
$out = Join-Path $OutRoot $Application
$lib = Join-Path $OutRoot 'lib'
if ((Test-Path $out) -and -not $Programs) { Remove-Item $out -Recurse -Force }
New-Item -ItemType Directory -Force $lib, "$out\Development", "$out\Binaries\Application", "$out\Binaries\Programs" | Out-Null

foreach ($n in 'Asysco.Amt.Libs', 'Asysco.Amt.AmtSharedDataModel', 'Asysco.Amt.Runtime', 'ComScript', 'AmtComScriptService', 'Asysco.Amt.Ftp',
               'Asysco.Amt.SerializerWrappers', 'Asysco.Amt.Screens.Common', 'Asysco.Amt.Windows') {
  Copy-Item (Join-Path $RuntimeDir "$n.dll") $lib -Force
}
Copy-Item (Join-Path $SecurityServerDir 'Asysco.Amt.Security.Server.dll') $lib -Force
Copy-Item $NewtonsoftFrom "$out\Binaries\Application" -Force

$folders = @('Application', 'Database') + (Get-ChildItem (Join-Path $Development 'Programs') -Directory | Where-Object { -not $Programs -or $Programs -contains $_.Name } | ForEach-Object { "Programs\$($_.Name)" })
if ($Programs -and @($folders | Where-Object { $_ -like 'Programs\*' }).Count -ne $Programs.Count) { throw "Program folder(s) not found under $Development\Programs: $($Programs -join ', ')" }
foreach ($rel in $folders) {
  if (Test-Path (Join-Path "$out\Development" $rel)) { Remove-Item (Join-Path "$out\Development" $rel) -Recurse -Force }
  Copy-Item (Join-Path $Development $rel) (Join-Path "$out\Development" $rel) -Recurse -Force -Exclude bin, obj
}

$dllName = @{ 'AmtComScript' = 'ComScript' }
Get-ChildItem "$out\Development" -Recurse -Filter *.csproj | ForEach-Object {
  $t = Get-Content $_.FullName -Raw
  $t = [regex]::Replace($t, '<ProjectReference Include="Y:\\[^"]*\\([^\\"]+)\.csproj">\s*</ProjectReference>', {
      param($m) $n = $m.Groups[1].Value; if ($dllName.ContainsKey($n)) { $n = $dllName[$n] }
      "<Reference Include=`"$n`"><HintPath>$lib\$n.dll</HintPath><Private>false</Private></Reference>" })
  # 177 writes absolute project paths into the original tree; point them at the scratch copy
  $t = $t.Replace($Development, "$out\Development")
  if ($t -match 'Y:\\') { throw "Unconverted Y:\ reference left in $($_.Name)" }
  Set-Content $_.FullName $t -Encoding utf8
}

# the one source difference found so far: drop ", <ccyymmdd>, <hhmm>" from the base(...) call
$changed = 0
$manifest = [System.Collections.Generic.List[Object]]::new()
Get-ChildItem "$out\Development\Programs" -Recurse -Filter *.cs | ForEach-Object {
  $t = Get-Content $_.FullName -Raw
  $m = [regex]::Match($t, '(base\("([^"]+)",\s*"[^"]*",\s*"[^"]*",\s*"[^"]*"),\s*(\d{8}),\s*(\d{3,4})\)')
  if (-not $m.Success) { return }
  $flag = "// REBUILT-FOR-177A: genDate $($m.Groups[3].Value) / genTime $($m.Groups[4].Value) removed from base(); the GenDate/GenTime system items are NOT set in this build."
  $n = $t.Replace($m.Value, $m.Groups[1].Value + ')')
  $n = [regex]::Replace($n, '(?m)^(\s*)(: base\(")', "`$1$flag`r`n`$1`$2")
  Set-Content $_.FullName $n -Encoding utf8 -NoNewline; $changed++
  $manifest.Add([pscustomobject]@{ Program = $m.Groups[2].Value; DroppedGenDate = $m.Groups[3].Value; DroppedGenTime = $m.Groups[4].Value; Rebuilt = (Get-Date -Format s) })
}
"base(...) calls rewritten in $changed file(s)"
$manifest | Export-Csv "$out\Binaries\Programs\REBUILT-FOR-177A.csv" -NoTypeInformation -Append:([bool]$Programs)
@("Rebuilt from LionDev 177 (8.0.26230.0) source against Federale 177a (8.0.26230.50) runtime.",
  "The generation date/time arguments of base(...) were removed because the 177a runtime has no such constructor.",
  "Effect: the GenDate/GenTime system items are not set. Dropped values are listed in REBUILT-FOR-177A.csv.",
  "Not LionDev's own output: regenerate with a matching 177a LionDev when one exists.") | Set-Content "$out\Binaries\Programs\REBUILT-FOR-177A.txt"

$results = foreach ($rel in $folders | Where-Object { $_ -like 'Programs\*' }) {
  $pf = Split-Path $rel -Leaf
  $log = Join-Path $out "build_$pf.log"
  $proj = Get-ChildItem "$out\Development\$rel" -Filter *.csproj | Select-Object -First 1
  dotnet build $proj.FullName -c Release -p:BaseIntermediateOutputPath="$out\obj\$pf\" 2>&1 | Tee-Object $log | Out-Null
  $errs = (Select-String -Path $log -Pattern ': error ' | Select-Object -First 3 | ForEach-Object { $_.Line.Trim() })
  # the program is looked up by the name inside the class, so ship it as <NAME>.dll
  $cs = Get-ChildItem "$out\Development\$rel" -Filter '*.cs' | Where-Object { $_.Name -notmatch '\.(Core|Files)\.cs$|^Fd_|Definitions|_Info' } | Select-Object -First 1
  $name = [regex]::Match((Get-Content $cs.FullName -Raw), 'base\("([^"]+)"').Groups[1].Value
  $built = Get-ChildItem "$out\Binaries\Programs" -Filter "$pf.dll" | Select-Object -First 1
  if ($name -and $built -and $built.Name -cne "$name.dll") {
    $tmp = Join-Path $built.DirectoryName ("tmp_" + $built.Name)
    Move-Item $built.FullName $tmp -Force; Move-Item $tmp (Join-Path $built.DirectoryName "$name.dll") -Force
  }
  [pscustomobject]@{ Program = $name; Built = [bool]($name -and (Test-Path "$out\Binaries\Programs\$name.dll")); FirstError = ($errs -join ' | ') }
}
$results | Format-Table -AutoSize | Out-String
'Output: ' + "$out\Binaries\Programs"
