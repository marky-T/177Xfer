$src  = 'E:\Repos\Federale_InternalRelease\AFBUS_AMT\Binaries\Programs'
$dest = 'E:\Repos\AMT\Apps\AFBUS_2200COBOL_AMT\Binaries\Programs'
# The runtime/support DLLs the first release carried beside its program DLLs (listing of z-old Programs, 2026-10-20).
$names = 'AmtComScriptService','Asysco.Amt.AmtSharedDataModel','Asysco.Amt.Ftp','Asysco.Amt.Libs','Asysco.Amt.Pdf','Asysco.Amt.RestApi',
  'Asysco.Amt.Runtime','Asysco.Amt.Screens.Common','Asysco.Amt.SerializerWrappers','Asysco.Amt.WebServices','Asysco.Amt.Windows',
  'BCrypt.Net-Next-StrongName','ComScript','DSNUPROC','DSNUTILB','FluentFtp','Grpc.Core.Api','Grpc.Net.Client','Newtonsoft.Json',
  'protobuf-net','protobuf-net.Grpc','Renci.SshNet','System.ServiceModel.Primitives'
$copied = 0; $existing = 0; $missing = @()
foreach ($n in $names) {
  $s = Join-Path $src "$n.dll"; $d = Join-Path $dest "$n.dll"
  if (-not (Test-Path $s)) { $missing += $n; continue }
  if (Test-Path $d) { $existing++; continue }
  Copy-Item $s $d; $copied++
}
$log = 'E:\Repos\SsgTrial\_scratch\runtime-dll-copy.txt'
"copied $copied, already present $existing, missing in Federale: $($missing -join ', ')" | Tee-Object $log
$v = (Get-Item "$dest\Asysco.Amt.Runtime.dll").VersionInfo.FileVersion
"Asysco.Amt.Runtime.dll in our Programs folder: $v"
