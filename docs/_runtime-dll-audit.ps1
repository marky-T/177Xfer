$out = New-Object System.Collections.Generic.List[string]
$out.Add('=== Asysco.Amt.Runtime.dll copies (excluding dev bin/obj) ===')
Get-ChildItem -LiteralPath 'E:\Repos\Federale_InternalRelease' -Recurse -File -Filter 'Asysco.Amt.Runtime.dll' -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' } | ForEach-Object {
  $vi = $_.VersionInfo
  $out.Add(('{0} | FileVersion={1} | ProductVersion={2} | LastWriteTime={3}' -f $_.FullName, $vi.FileVersion, $vi.ProductVersion, $_.LastWriteTime))
}
$out.Add('')
$out.Add('=== AmtBatchControllerAgent / PowerShellHost folder contents relevant to Cobol runtime ===')
foreach ($d in @('E:\Repos\Federale_InternalRelease\AmtTools\AmtBatchController\BatchControllerAgentCore','E:\Repos\Federale_InternalRelease\AmtTools\AmtBatchController')) {
  if (Test-Path -LiteralPath $d) {
    $out.Add("--- $d ---")
    Get-ChildItem -LiteralPath $d -File -Filter 'Asysco.Amt.*' -ErrorAction SilentlyContinue | ForEach-Object {
      $out.Add($_.Name + '  FileVersion=' + $_.VersionInfo.FileVersion)
    }
  }
}
[IO.File]::WriteAllLines('E:\Repos\SsgTrial\docs\_runtime-dll-audit.txt', $out)
Write-Output 'DONE'
