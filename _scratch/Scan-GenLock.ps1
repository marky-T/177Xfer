# Scan LionDev binaries for UTF-16 strings near the "Another process is generating" message and for SQL touching generation state.
$files = Get-ChildItem E:\Amt\Lion -Filter *.dll | Where-Object { $_.Name -match 'Lion|Gen|Repos' }
foreach ($f in $files) {
  $b = [IO.File]::ReadAllBytes($f.FullName)
  $s = [Text.Encoding]::Unicode.GetString($b)
  $hits = [regex]::Matches($s, '[\x20-\x7E]{6,}') | ForEach-Object Value
  $sel = $hits | Where-Object { $_ -match 'Another process|is generating|GENERATING|GENLOCK|GENSTATUS|GENREQ|GENERATIONREQ|UPDATE .*GEN|DELETE .*GEN|FROM .*GEN|INSERT .*GEN|Generat.*(lock|busy|running)' }
  if ($sel) { "== $($f.Name)"; $sel | Select-Object -Unique | Select-Object -First 40 }
}
