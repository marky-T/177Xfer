param([String]$Dll, [String]$Type = 'AmtBaseCobolProgram')
Add-Type -AssemblyName System.Reflection.Metadata
$fs = [System.IO.File]::OpenRead($Dll)
$pe = [System.Reflection.PortableExecutable.PEReader]::new($fs)
$md = [System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($pe)
foreach ($th in $md.TypeDefinitions) {
  $t = $md.GetTypeDefinition($th)
  if ($md.GetString($t.Name) -ne $Type) { continue }
  foreach ($mh in $t.GetMethods()) {
    $m = $md.GetMethodDefinition($mh)
    if ($md.GetString($m.Name) -ne '.ctor') { continue }
    $sig = $md.GetBlobReader($m.Signature).ReadBytes($md.GetBlobReader($m.Signature).Length) -join ' '
    $ps = foreach ($ph in $m.GetParameters()) { $md.GetString($md.GetParameter($ph).Name) }
    '{0} ctor({1})' -f [System.IO.Path]::GetFileName($Dll), ($ps -join ', ')
  }
}
$pe.Dispose(); $fs.Dispose()
