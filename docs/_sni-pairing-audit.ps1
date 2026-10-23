$out = New-Object System.Collections.Generic.List[string]
$targets = @(
  'E:\Repos\Federale_InternalRelease\AmtTools\AmtBatchController',
  'E:\Repos\Federale_InternalRelease\AmtTools\AmtBatchController\BatchControllerAgentCore',
  'E:\Repos\Federale_InternalRelease\AmtTools\AmtBatchController\PowerShellHost',
  'E:\Repos\Federale_InternalRelease\AmtTools\AmtFileController',
  'E:\Repos\Federale_InternalRelease\AmtTools\ComScript',
  'E:\Repos\Federale_InternalRelease\AmtTools\ComModule'
)
foreach ($t in $targets) {
  $dll = Join-Path $t 'Microsoft.Data.SqlClient.dll'
  $sni = Join-Path $t 'runtimes\win-x64\native\Microsoft.Data.SqlClient.SNI.dll'
  $dllTime = if (Test-Path -LiteralPath $dll) { (Get-Item -LiteralPath $dll).LastWriteTime } else { 'MISSING' }
  $sniTime = if (Test-Path -LiteralPath $sni) { (Get-Item -LiteralPath $sni).LastWriteTime } else { 'MISSING' }
  $out.Add("$t`n  dll: $dllTime`n  sni: $sniTime")
}
[IO.File]::WriteAllLines('E:\Repos\SsgTrial\docs\_sni-pairing-audit.txt', $out)
Write-Output 'DONE'
