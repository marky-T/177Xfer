Import-Module E:\Repos\SsgTrial\Conversion\Pipeline\MockTest\MockTestLib.psm1 -Force -DisableNameChecking
$out = foreach ($c in Get-SetCalls -Binaries 'E:\AMT_Work\Rebuild177a\AFBUS_2200COBOL\Binaries\Programs') {
  $io = (Get-Content -LiteralPath $c.Cards | Where-Object { $_ -match '^\s*(INPUT|OUTPUT|KEYS|UPDATE|CARD|READER)\b' } | ForEach-Object { $_.Trim() }) -join ' | '
  '{0,-16} {1,-14} {2}' -f $c.Key, $c.Case, $io
}
$out | Set-Content E:\Repos\SsgTrial\_scratch\setcalls.txt
$out
