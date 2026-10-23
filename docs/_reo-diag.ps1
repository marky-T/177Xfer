$out = New-Object System.Collections.Generic.List[string]
$amt = 'E:\Repos\AMT'

$out.Add('=== 1. AMT top-level ===')
Get-ChildItem -LiteralPath $amt -Directory -ErrorAction SilentlyContinue | ForEach-Object { $out.Add($_.Name) }

$out.Add(''); $out.Add('=== 2. App base path layout (AFBUS_2200COBOL_AMT) ===')
$app = Join-Path $amt 'Apps\AFBUS_2200COBOL_AMT'
if (Test-Path $app) { Get-ChildItem -LiteralPath $app -Directory -ErrorAction SilentlyContinue | ForEach-Object { $out.Add($_.FullName) } } else { $out.Add("NOT FOUND: $app") }

$out.Add(''); $out.Add('=== 3. Application.dll / Database.dll files under AMT (name + path + version) ===')
Get-ChildItem -LiteralPath $amt -Recurse -File -Include '*.Application.dll','*.Database.dll' -ErrorAction SilentlyContinue | ForEach-Object {
  $out.Add(('{0} | {1} | {2}' -f $_.Name, $_.DirectoryName, $_.LastWriteTime))
}

$out.Add(''); $out.Add('=== 4. Sys.ini (base path + DB) ===')
foreach ($s in @('AMTTools\Sys.ini','AMTTools\AmtFileController\Sys.ini')) {
  $p = Join-Path $amt $s
  if (Test-Path $p) { $out.Add("--- $p ---"); Get-Content -LiteralPath $p | Where-Object { $_ -match 'ENVIRONMENT|SYSTEMBASEPATH|SERVER NAME|DATABASE NAME|DBUSER' } | ForEach-Object { $out.Add($_.Trim()) } }
}

$out.Add(''); $out.Add('=== 5. Reorganize folder present? ===')
$reo = Join-Path $amt 'AMTTools\Reorganize'
if (Test-Path $reo) { Get-ChildItem -LiteralPath $reo -File -Filter '*.exe' | ForEach-Object { $out.Add($_.FullName) } } else { $out.Add("NOT FOUND: $reo") }

$out.Add(''); $out.Add('=== 6. Any lingering FEDERALE_AFBUS_2200COBOL refs in AMT config (json/xml/ini) ===')
Get-ChildItem -LiteralPath $amt -Recurse -File -Include '*.json','*.xml','*.ini','*.config' -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' } | Select-String -Pattern 'FEDERALE_AFBUS_2200COBOL' -List -ErrorAction SilentlyContinue | Select-Object -First 25 | ForEach-Object { $out.Add(('{0}:{1}' -f $_.Path, $_.LineNumber)) }

[IO.File]::WriteAllLines('E:\Repos\SsgTrial\docs\_reo-diag.txt', $out)
Write-Output 'DONE'
