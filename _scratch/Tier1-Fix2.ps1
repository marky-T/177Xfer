$ssg = 'E:\Repos\SsgTrial\SsgConverter'
$out = 'E:\Repos\SsgTrial\_scratch\ssgfix2\out'
$harness = "$ssg\Trials\Tier1Mock\Run-SsgPsTrial.ps1"
foreach ($f in Get-ChildItem $out -Filter *.ps1 | Sort-Object Name) {
  $p = $f.BaseName
  $values = "$ssg\Trials\$p\sgs-values.json"
  if (-not (Test-Path $values)) { '{0,-18} no sgs-values' -f $p; continue }
  $r = & $harness -Program $p -ScriptPath $f.FullName -OutDir "E:\Repos\SsgTrial\_scratch\ssgfix2\tier1\$p" 6>$null
  '{0,-18} {1} lines={2}' -f $p, $(if ($r.Failed) { 'THREW' } else { 'OK' }), $r.LineCount
}
