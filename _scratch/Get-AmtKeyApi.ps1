param([String]$Lib = 'E:\AMT_Work\Rebuild177a-spike\lib')
$ErrorActionPreference = 'Continue'
$asms = foreach ($n in 'Asysco.Amt.Libs', 'Asysco.Amt.Runtime') { [Reflection.Assembly]::LoadFrom("$Lib\$n.dll") }
$all = New-Object System.Collections.Generic.List[Type]
foreach ($a in $asms) {
  try { foreach ($t in $a.GetTypes()) { $all.Add($t) } }
  catch [Reflection.ReflectionTypeLoadException] { foreach ($t in $_.Exception.Types) { if ($t) { $all.Add($t) } } }
}
"types loaded: $($all.Count)"
foreach ($tn in 'AmtVarAlpha', 'AmtIndexFile', 'AmtVar') {
  foreach ($t in ($all | Where-Object { $_.Name -eq $tn })) {
    "== $($t.FullName)  (base $($t.BaseType.Name))"
    foreach ($c in $t.GetConstructors()) { '  ctor(' + (($c.GetParameters() | ForEach-Object { "$($_.ParameterType.Name) $($_.Name)" }) -join ', ') + ')' }
    $ms = $t.GetMethods([Reflection.BindingFlags]'Public,Instance,DeclaredOnly') | Where-Object { $_.Name -match 'Key|Offset|Index|Parent|Position|Redefine|Sub' -and -not $_.IsSpecialName } | Select-Object -First 25
    foreach ($m in $ms) { '  ' + $m.ReturnType.Name + ' ' + $m.Name + '(' + (($m.GetParameters() | ForEach-Object { "$($_.ParameterType.Name) $($_.Name)" }) -join ', ') + ')' }
  }
}
