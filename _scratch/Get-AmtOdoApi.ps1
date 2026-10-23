param([String]$Lib = 'E:\AMT_Work\Rebuild177a-spike\lib')
$ErrorActionPreference = 'Continue'
$asms = foreach ($n in 'Asysco.Amt.Libs', 'Asysco.Amt.Runtime') { [Reflection.Assembly]::LoadFrom("$Lib\$n.dll") }
$all = New-Object System.Collections.Generic.List[Type]
foreach ($a in $asms) {
  try { foreach ($t in $a.GetTypes()) { $all.Add($t) } }
  catch [Reflection.ReflectionTypeLoadException] { foreach ($t in $_.Exception.Types) { if ($t) { $all.Add($t) } } }
}
'--- types/members mentioning Depend / Occurs / Offset (Vars namespace)'
foreach ($t in ($all | Where-Object { $_.Namespace -match 'Vars' })) {
  $hits = @($t.GetMembers([Reflection.BindingFlags]'Public,Instance,DeclaredOnly') | Where-Object { $_.Name -match 'Depend|Occurs|Offset|Variable(Length|Size)' })
  if ($hits.Count) { "$($t.Name): " + (($hits | ForEach-Object { $_.Name } | Sort-Object -Unique) -join ', ') }
}
'--- AmtStructure ctors/methods'
foreach ($t in ($all | Where-Object { $_.Name -eq 'AmtStructure' })) {
  foreach ($c in $t.GetConstructors()) { '  ctor(' + (($c.GetParameters() | ForEach-Object { "$($_.ParameterType.Name) $($_.Name)" }) -join ', ') + ')' }
  foreach ($m in $t.GetMethods([Reflection.BindingFlags]'Public,Instance,DeclaredOnly') | Where-Object { -not $_.IsSpecialName } | Select-Object -First 30) { '  ' + $m.ReturnType.Name + ' ' + $m.Name + '(' + (($m.GetParameters() | ForEach-Object { "$($_.ParameterType.Name) $($_.Name)" }) -join ', ') + ')' }
}
