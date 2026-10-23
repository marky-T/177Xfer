Import-Module E:\Repos\SsgTrial\Conversion\Pipeline\MockTest\MockTestLib.psm1 -Force -DisableNameChecking
$c = Get-SetCalls | Where-Object Key -eq 'CHAB100_ASCII'
$d = 'E:\AMT_Work\MockTest\Ref\CHAB100'
$card = "$d\CAR.cards"
$sys = 'E:\AMT_Work\MockSystem'; $extract = 'E:\AMT_Work\MockTest\Extracts'
Start-MockFc
try {
  # stage the card file under every name the runtime might derive from an empty external name
  $runner = "$sys\Run_TRY_CHAB100_NAMES"
  Remove-Item $runner -Recurse -Force -ErrorAction SilentlyContinue
  robocopy "$sys\Run177" $runner /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
  Copy-Item "E:\AMT_Work\Rebuild177a\AFBUS_2200COBOL\Binaries\Programs\$($c.Dll)" $runner -Force
  Get-ChildItem 'E:\AMT_Work\Rebuild177a\AFBUS_2200COBOL\Binaries\Programs' -Filter 'AFBUS_2200COBOL.*.dll' | Copy-Item -Destination $runner -Force
  dotnet "$runner\MockSystemTool.dll" seed-app --app AFBUS_2200COBOL --ini "$runner\Sys.ini" | Out-Null
  foreach ($n in 'CAR', 'CAR.DAT', 'CAR.TXT') { Copy-Item $card "$extract\$n" -Force; Copy-Item $card "$runner\$n" -Force }
  $before = Get-ChildItem $extract, $runner -File | ForEach-Object { $_.FullName + '|' + $_.LastAccessTime.Ticks }
  $o = dotnet "$runner\MockSystemTool.dll" run --app AFBUS_2200COBOL --ini "$runner\Sys.ini" --dll "$runner\$($c.Dll)" 2>&1
  $o | Select-Object -Last 6
  '--- extract after'; Get-ChildItem $extract | Select-Object Name, Length, LastWriteTime | Format-Table -AutoSize | Out-String
  '--- newest files anywhere under MockSystem\Run_TRY and MockTest'
  Get-ChildItem $runner, 'E:\AMT_Work\MockTest' -Recurse -File | Where-Object LastWriteTime -gt (Get-Date).AddMinutes(-2) | Select-Object FullName, Length | Format-Table -AutoSize | Out-String -Width 200
  '--- Sys.ini paths'; Get-Content "$runner\Sys.ini" | Select-String -Pattern 'PATH|DIR|EXTRACT|TEMP' -SimpleMatch:$false
} finally { Stop-MockFc }
