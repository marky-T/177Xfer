$out = New-Object System.Collections.Generic.List[string]
$out.Add('=== Skeleton DLL copies under Federale_InternalRelease (excluding bin/obj dev output) ===')
Get-ChildItem -LiteralPath 'E:\Repos\Federale_InternalRelease' -Recurse -File -Filter 'Asysco.Amt.Runtime.Skeleton.dll' -ErrorAction SilentlyContinue | ForEach-Object {
  $vi = $_.VersionInfo
  $out.Add(('{0} | FileVersion={1} | LastWriteTime={2}' -f $_.FullName, $vi.FileVersion, $_.LastWriteTime))
}
$out.Add('')
$out.Add('=== Report deps.json reference to the skeleton assembly ===')
Get-ChildItem -LiteralPath 'E:\Repos\Federale_InternalRelease\AFBUS_2200COBOL' -Recurse -File -Filter '*Cfh_Copy*.deps.json' -ErrorAction SilentlyContinue | ForEach-Object {
  $out.Add('--- ' + $_.FullName + ' ---')
  $content = Get-Content -LiteralPath $_.FullName -Raw
  if ($content -match '"Asysco\.Amt\.Runtime\.Skeleton[^"]*"\s*:\s*"([^"]+)"') {
    $out.Add('Referenced version: ' + $Matches[1])
  } else {
    $out.Add('No direct "Asysco.Amt.Runtime.Skeleton" version key found - searching nearby text:')
    ($content -split "`n") | Select-String -Pattern 'Skeleton' | ForEach-Object { $out.Add($_.ToString().Trim()) }
  }
}
$out.Add('')
$out.Add('=== Programs folder contents (where AmtCobolProgram job loads the dll from) ===')
Get-ChildItem -LiteralPath 'E:\Repos\Federale_InternalRelease\AFBUS_2200COBOL\Binaries\Programs' -File -ErrorAction SilentlyContinue | ForEach-Object { $out.Add($_.Name + '  (' + $_.LastWriteTime + ')') }
[IO.File]::WriteAllLines('E:\Repos\SsgTrial\docs\_skeleton-version-audit.txt', $out)
Write-Output 'DONE'
