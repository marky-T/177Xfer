Add-Type -AssemblyName System.Reflection.Metadata
$out = 'E:\Repos\SsgTrial\_scratch\reo-refs.txt'
function Get-Refs([string]$path) {
  $fs = [IO.File]::OpenRead($path)
  try {
    $pe = New-Object System.Reflection.PortableExecutable.PEReader($fs)
    $md = [System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($pe)
    foreach ($h in $md.AssemblyReferences) { $r = $md.GetAssemblyReference($h); $n = $md.GetString($r.Name); if ($n -match '^Asysco\.Amt\.(Runtime|Libs|AmtSharedDataModel)$') { '{0} {1}' -f $n, $r.Version } }
  } finally { $fs.Dispose() }
}
$lines = @()
foreach ($d in 'E:\Repos\AMT\Apps\AFBUS_2200COBOL_AMT\Binaries\Application', 'E:\AMT_Work\Apps177\Binaries\Application', 'E:\AMT_Work\Rebuild177a\AFBUS_2200COBOL\Binaries\Application') {
  $lines += "=== $d"
  if (-not (Test-Path $d)) { $lines += '   (missing)'; continue }
  foreach ($f in Get-ChildItem $d -Filter 'AFBUS_2200COBOL.*.dll') { $lines += "   $($f.Name)  $($f.Length) B  $($f.LastWriteTime.ToString('yyyy-MM-dd HH:mm'))"; Get-Refs $f.FullName | ForEach-Object { $lines += "      ref $_" } }
}
$reo = 'E:\Amt\AMTTools\Reorganize'
$lines += "=== Reorganize tool folder: $reo"
foreach ($n in 'Asysco.Amt.Runtime.dll', 'Asysco.Amt.Libs.dll', 'AmtReorganize.dll') {
  $p = Join-Path $reo $n
  $lines += if (Test-Path $p) { "   $n present, file version $((Get-Item $p).VersionInfo.FileVersion)" } else { "   $n NOT in the Reorganize folder" }
}
$lines += "=== runtime DLL versions elsewhere"
foreach ($p in 'E:\Amt\AMTTools\Asysco.Amt.Runtime.dll', 'E:\Repos\Federale_InternalRelease\AmtTools\Asysco.Amt.Runtime.dll', 'E:\Repos\AMT\Apps\AFBUS_2200COBOL_AMT\Binaries\Programs\Asysco.Amt.Runtime.dll') {
  $lines += if (Test-Path $p) { "   $p : $((Get-Item $p).VersionInfo.FileVersion)" } else { "   $p : (none)" }
}
$lines | Out-File $out -Width 300
$lines
