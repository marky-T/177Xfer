$dll = 'E:\AMT_Work\Apps\Binaries\Programs\Asysco.Amt.Libs.dll'
$asm = [System.Reflection.Assembly]::LoadFrom($dll)
try { $types = $asm.GetTypes() } catch [System.Reflection.ReflectionTypeLoadException] { $types = $_.Exception.Types | Where-Object { $_ } }
foreach ($n in 'AmtSysFileController') {
  $t = $types | Where-Object { $_.Name -eq $n } | Select-Object -First 1
  "{0}: base={1}" -f $n, $t.BaseType.Name
  $t.GetProperties([System.Reflection.BindingFlags]'Public,Instance,DeclaredOnly') | ForEach-Object { '  {0} {1} set={2}' -f $_.PropertyType.Name, $_.Name, $_.CanWrite }
  $b = $t.BaseType
  while ($b -and $b.Name -notin 'Object') {
    "-- {0}" -f $b.Name
    $b.GetProperties([System.Reflection.BindingFlags]'Public,Instance,DeclaredOnly') | ForEach-Object { '  {0} {1} set={2}' -f $_.PropertyType.Name, $_.Name, $_.CanWrite }
    $b = $b.BaseType
  }
  $t.GetMethods([System.Reflection.BindingFlags]'Public,Instance,DeclaredOnly') | Where-Object { $_.Name -match 'Select|Add|Change' } | ForEach-Object { '  method {0}({1})' -f $_.Name, (($_.GetParameters() | ForEach-Object { $_.ParameterType.Name }) -join ',') }
}
