$rd = 'E:\Repos\amt-go-net-ref'
$p = 'Migration Tools/SsgConverter/SsgConverter'
Set-Location $rd
'--- R&D history of the converter folder'
git log --format='%h %ad %an | %s' --date=short -- $p 2>&1 | Select-Object -First 12
$base = 'E:\Repos\SsgTrial\_scratch\ssgbase'
New-Item -ItemType Directory -Force $base | Out-Null
Set-Location E:\Repos\SsgTrial
foreach ($f in 'SymstreamProcessor.cs', 'SymstreamExpressionMigrator.cs', 'SymstreamExpressionParser.cs') {
  git show "b786f7c:SsgConverter/Source/SsgConverter/$f" > "$base\$f" 2>$null
  $r = "$rd\Migration Tools\SsgConverter\SsgConverter\$f"
  $o = "E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter\$f"
  $n = { param($x) (Get-Content $x -Raw) -replace '\r\n', "`n" -split "`n" }
  $b = & $n "$base\$f"; $rr = & $n $r; $oo = & $n $o
  '{0}: base->R&D {1} lines differ; base->ours {2} lines differ; base==R&D? {3}' -f $f, @(Compare-Object $b $rr).Count, @(Compare-Object $b $oo).Count, (@(Compare-Object $b $rr).Count -eq 0)
}
'--- R&D-only changes vs base (SymstreamProcessor.cs), first 30'
$b = (Get-Content "$base\SymstreamProcessor.cs" -Raw) -replace '\r\n', "`n" -split "`n"
$rr = (Get-Content "$rd\Migration Tools\SsgConverter\SsgConverter\SymstreamProcessor.cs" -Raw) -replace '\r\n', "`n" -split "`n"
Compare-Object $b $rr | Select-Object -First 30 | ForEach-Object { '{0} {1}' -f $_.SideIndicator, $_.InputObject.Trim().Substring(0, [Math]::Min(120, $_.InputObject.Trim().Length)) }
