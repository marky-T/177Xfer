$app    = 'E:\Repos\AMT\Apps\AFBUS_2200COBOL_AMT\Binaries\Application'
$keep   = 'E:\Repos\AMT\Apps\AFBUS_2200COBOL_AMT\Binaries\Application.rebuilt-177a'
$orig   = 'E:\AMT_Work\Apps177\Binaries\Application'
$names  = 'AFBUS_2200COBOL.Application.dll', 'AFBUS_2200COBOL.Application.deps.json', 'AFBUS_2200COBOL.Database.dll', 'AFBUS_2200COBOL.Database.deps.json'
if (Test-Path $keep) { throw "Backup folder already exists, not overwriting: $keep" }
New-Item -ItemType Directory $keep | Out-Null
$log = foreach ($n in $names) {
  $cur = Join-Path $app $n; $src = Join-Path $orig $n
  if (Test-Path $cur) { Copy-Item $cur (Join-Path $keep $n) }
  if (Test-Path $src) { Copy-Item $src $cur -Force; 'replaced {0,-42} with the 177 original ({1:N0} B)' -f $n, (Get-Item $cur).Length }
  else { 'no 177 original for {0} (left as is)' -f $n }
}
$log
'Backup of the 177a rebuilds: ' + $keep
