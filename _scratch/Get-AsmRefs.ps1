param([String[]]$Dll)
Add-Type -AssemblyName System.Reflection.Metadata
foreach ($d in $Dll) {
  $fs = [System.IO.File]::OpenRead($d)
  $pe = [System.Reflection.PortableExecutable.PEReader]::new($fs)
  $md = [System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($pe)
  "== $(Split-Path $d -Leaf)   (self: $($md.GetAssemblyDefinition().Version))"
  foreach ($h in $md.AssemblyReferences) {
    $r = $md.GetAssemblyReference($h)
    $n = $md.GetString($r.Name)
    if ($n -match '^(Asysco|protobuf|Newtonsoft)') { '   {0,-42} {1}' -f $n, $r.Version }
  }
  $pe.Dispose(); $fs.Dispose()
}
