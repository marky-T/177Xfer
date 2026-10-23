# User strings (#US heap) of an assembly that match a pattern: finds runtime messages without a decompiler.
param([String]$Dll = 'E:\AMT_Work\Rebuild177a-spike\lib\Asysco.Amt.Runtime.dll', [String]$Pattern = 'index|key')
Add-Type -AssemblyName System.Reflection.Metadata
$fs = [IO.File]::OpenRead($Dll)
try {
  $pe = [System.Reflection.PortableExecutable.PEReader]::new($fs)
  $md = [System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($pe)
  $h = [System.Reflection.Metadata.Ecma335.MetadataTokens]::UserStringHandle(1)
  $seen = @{}
  while (-not $h.IsNil) {
    $s = $md.GetUserString($h)
    if ($s -match $Pattern -and -not $seen.ContainsKey($s)) { $seen[$s] = 1; $s }
    $h = [System.Reflection.Metadata.Ecma335.MetadataReaderExtensions]::GetNextHandle($md, $h)
  }
} finally { $fs.Dispose() }
