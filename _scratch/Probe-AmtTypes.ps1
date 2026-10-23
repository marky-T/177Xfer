$dll = 'E:\AMT_Work\Apps\Binaries\Programs\Asysco.Amt.Libs.dll'
$asm = [System.Reflection.Assembly]::LoadFrom($dll)
try { $types = $asm.GetTypes() } catch [System.Reflection.ReflectionTypeLoadException] { $types = $_.Exception.Types | Where-Object { $_ } }
$want = 'AmtConfiguration','AmtDbsList','AmtApplicationSettings','AmtConstShared','AmtSysApplication','AmtSysBasePath','AmtSysConfig','AmtSysLogging','AmtSysSystem','AmtDatabase','AmtSysRtBehaviour','AmtSysRuntimeBehaviour','AmtSysLionRuntimeConfig'
foreach ($n in $want) {
  $t = $types | Where-Object { $_.Name -eq $n } | Select-Object -First 1
  if ($t) { '{0}  public={1}  ns={2}' -f $n, $t.IsPublic, $t.Namespace } else { "$n  NOT FOUND" }
}
'--- rt behaviour candidates'
$types | Where-Object { $_.Name -match 'RtBehav|RuntimeBehav' } | ForEach-Object { '{0} public={1}' -f $_.FullName, $_.IsPublic }
'--- AmtSysBasePath members'
($types | Where-Object { $_.Name -eq 'AmtSysBasePath' }).GetProperties() | ForEach-Object { '{0} {1}' -f $_.PropertyType.Name, $_.Name }
'--- AmtSysRtBehaviour-like props (first 40)'
$rt = $types | Where-Object { $_.Name -match '^AmtSys.*(RtBehav|RuntimeBehav)' } | Select-Object -First 1
if ($rt) { $rt.FullName; $rt.GetProperties() | Select-Object -First 40 | ForEach-Object { '{0} {1}' -f $_.PropertyType.Name, $_.Name } }
