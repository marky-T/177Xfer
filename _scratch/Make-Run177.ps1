$ErrorActionPreference = 'Stop'
$sys = 'E:\AMT_Work\MockSystem'
$r177 = "$sys\Run177_PBDA04"
$fed = 'E:\Repos\Federale_InternalRelease\AFBUS_AMT\Binaries\Programs'
$reb = 'E:\AMT_Work\Rebuild177a\CFHCOPYASCIIPBDA04L545'
# runner = copy of the 179 runner, AMT assemblies replaced by Federale's 177a copies, our program set rebuilt against 177a
robocopy "$sys\Run" $r177 /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
Get-ChildItem $r177 -Filter *.dll | Where-Object { $_.Name -match '^(Asysco\.|ComScript|AmtComScriptService)' } | ForEach-Object {
  $src = Join-Path $fed $_.Name
  if (Test-Path $src) { Copy-Item $src $_.FullName -Force; '177a  ' + $_.Name }
}
Copy-Item "$reb\Binaries\Application\Asysco.Amt.Security.Server.dll" $r177 -ErrorAction SilentlyContinue
Remove-Item "$r177\CFH_COPY.dll", "$r177\CFHCOPYASCIIPBDA04L545.*.dll", "$r177\CFHCOPYASCII.*.dll" -ErrorAction SilentlyContinue
Copy-Item "$reb\Binaries\Programs\Cfh_Copy.dll" "$r177\CFH_COPY.dll" -Force
Copy-Item "$reb\Binaries\Programs\CFHCOPYASCIIPBDA04L545.*.dll" $r177 -Force
# the tool itself, built against the 177a libraries now in that folder
Set-Location E:\Repos\SsgTrial\Conversion\Pipeline\MockTest\MockSystemTool
dotnet build -c Release -o $r177 -p:AmtBin=$r177 -p:BaseIntermediateOutputPath=E:\AMT_Work\MockSystem\obj177\ -p:UseAppHost=false 2>&1 | Select-String 'error|Build succeeded' | Select-Object -Unique -First 8 | ForEach-Object { $_.Line.Substring(0, [Math]::Min(250, $_.Line.Length)) }
