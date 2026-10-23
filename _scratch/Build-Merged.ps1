$m = 'E:\Repos\SsgTrial\_scratch\ssgmerge2'
$f = "$m\SymstreamProcessor.cs"
$l = [System.IO.File]::ReadAllLines($f)
$res = New-Object System.Collections.Generic.List[string]
$mode = 'normal'
foreach ($line in $l) {
  if ($line -like '<<<<<<< ours') { $mode = 'ours'; continue }
  if ($line -like '=======' -and $mode -eq 'ours') { $mode = 'theirs'; continue }
  if ($line -like '>>>>>>> rd') { $mode = 'normal'; continue }
  if ($mode -ne 'theirs') { $res.Add($line) }
}
[System.IO.File]::WriteAllText("$m\SymstreamProcessor.resolved.cs", (($res -join "`n") + "`n"))
'resolved lines: ' + $res.Count

# stage a scratch source tree (copy of the fixed scratch build tree) with merged files
$stage = 'E:\Repos\SsgTrial\_scratch\ssgmerged'
Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue
Copy-Item 'E:\Repos\SsgTrial\_scratch\ssgfix\Source' "$stage\Source" -Recurse
Copy-Item 'E:\Repos\SsgTrial\_scratch\ssgfix\Console' "$stage\Console" -Recurse
$lib = "$stage\Source\SsgConverter"
Copy-Item "$m\SymstreamProcessor.resolved.cs" "$lib\SymstreamProcessor.cs" -Force
Copy-Item "$m\SymstreamExpressionMigrator.cs" "$lib\SymstreamExpressionMigrator.cs" -Force
Copy-Item "$m\SymstreamExpressionParser.cs" "$lib\SymstreamExpressionParser.cs" -Force
Get-ChildItem $lib -Filter *.csproj | Select-Object -ExpandProperty Name
dotnet build "$lib\SsgConverter.csproj" -c Debug --nologo 2>&1 | Select-Object -Last 6
