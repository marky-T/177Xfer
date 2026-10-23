$dir = 'E:\AMT_Work\MockSystem\Run177'
foreach ($f in Get-ChildItem $dir -Filter 'Asysco.Amt*.dll') {
  $s = [Text.Encoding]::Unicode.GetString([IO.File]::ReadAllBytes($f.FullName))
  $hits = [regex]::Matches($s, '[\x20-\x7E]{4,}') | ForEach-Object Value | Where-Object { $_ -match 'CARD|SYSIN|READER|DATACARD|CardReader|card reader|\.CRD|RUNSTREAM|InlineData|DataImages' } | Select-Object -Unique
  if ($hits) { "== $($f.Name)"; $hits | Select-Object -First 30 }
}
