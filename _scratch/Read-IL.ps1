param([String]$Dll = 'E:\Amt\Lion\LionGeneratorBusinessLogic.dll', [String]$Match = 'LIONGENERATES|Another process|at the moment|is waiting', [String]$Method = '')
# Lists, for every method whose IL loads a matching string, the strings it loads and the members it calls, in IL order.
Add-Type -AssemblyName System.Reflection.Metadata
$stream = [IO.File]::OpenRead($Dll)
$pe = [System.Reflection.PortableExecutable.PEReader]::new($stream)
$md = [System.Reflection.Metadata.PEReaderExtensions]::GetMetadataReader($pe)

function MemberName([int]$token) {
  $handle = [System.Reflection.Metadata.Ecma335.MetadataTokens]::EntityHandle($token)
  switch ($handle.Kind) {
    'MethodDefinition' { $m = $md.GetMethodDefinition([System.Reflection.Metadata.MethodDefinitionHandle]$handle); $t = $md.GetTypeDefinition($m.GetDeclaringType()); return $md.GetString($t.Name) + '.' + $md.GetString($m.Name) }
    'MemberReference' {
      $r = $md.GetMemberReference([System.Reflection.Metadata.MemberReferenceHandle]$handle); $p = $r.Parent; $pn = ''
      if ($p.Kind -eq 'TypeReference') { $pn = $md.GetString($md.GetTypeReference([System.Reflection.Metadata.TypeReferenceHandle]$p).Name) }
      elseif ($p.Kind -eq 'TypeDefinition') { $pn = $md.GetString($md.GetTypeDefinition([System.Reflection.Metadata.TypeDefinitionHandle]$p).Name) }
      return $pn + '.' + $md.GetString($r.Name)
    }
    'MethodSpecification' { $s = $md.GetMethodSpecification([System.Reflection.Metadata.MethodSpecificationHandle]$handle); return MemberName ([System.Reflection.Metadata.Ecma335.MetadataTokens]::GetToken($s.Method)) + '<>' }
    'FieldDefinition' { $f = $md.GetFieldDefinition([System.Reflection.Metadata.FieldDefinitionHandle]$handle); return 'field ' + $md.GetString($f.Name) }
    default { return "$($handle.Kind)" }
  }
}

# opcode sizes (operand bytes) for single-byte opcodes; 0xFE prefix handled separately
$size = @{}
foreach ($op in 0x00..0xFF) { $size[[int]$op] = 0 }
$ErrorActionPreference = 'Stop'
foreach ($op in @(0x0E, 0x0F, 0x10, 0x11, 0x12, 0x13, 0x1F, 0xDE) + @(0x2B..0x37)) { $size[[int]$op] = 1 }
foreach ($op in @(0x20, 0x22, 0x28, 0x29, 0x6F, 0x70, 0x72, 0x73, 0x74, 0x75, 0x79, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F, 0x80, 0x81, 0x8C, 0x8D, 0x8F, 0xA3, 0xA4, 0xA5, 0xC2, 0xC6, 0xD0, 0xD5, 0xDD) + @(0x38..0x44)) { $size[[int]$op] = 4 }
foreach ($op in 0x21,0x23) { $size[$op] = 8 }

foreach ($mh in $md.MethodDefinitions) {
  $m = $md.GetMethodDefinition($mh)
  if ($m.RelativeVirtualAddress -eq 0) { continue }
  $body = [System.Reflection.Metadata.PEReaderExtensions]::GetMethodBody($pe, $m.RelativeVirtualAddress)
  $il = $body.GetILBytes()
  $events = New-Object System.Collections.Generic.List[String]
  $hit = $false
  $i = 0
  while ($i -lt $il.Length) {
    $op = $il[$i]; $i++
    if ($op -eq 0xFE) { $op2 = $il[$i]; $i++; if ($op2 -in 0x06,0x07,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x15,0x16,0x1C,0x1D) { $i += 4 } elseif ($op2 -eq 0x12) { $i += 1 } elseif ($op2 -eq 0x19) { $i += 1 }; continue }
    if ($op -eq 0x45) { $n = [BitConverter]::ToInt32($il, $i); $i += 4 + 4 * $n; continue }
    if ($op -eq 0x72) {
      $tok = [BitConverter]::ToInt32($il, $i)
      $s = $md.GetUserString([System.Reflection.Metadata.Ecma335.MetadataTokens]::UserStringHandle($tok -band 0xFFFFFF))
      $events.Add('  str  "' + $s + '"'); if ($s -match $Match) { $hit = $true }
    } elseif ($op -in 0x28, 0x6F, 0x73) {
      $tok = [BitConverter]::ToInt32($il, $i)
      try { $events.Add('  call ' + (MemberName $tok)) } catch { }
    } elseif ($op -in 0x7B, 0x7E) {
      $tok = [BitConverter]::ToInt32($il, $i)
      try { $events.Add('  fld  ' + (MemberName $tok)) } catch { }
    }
    $i += $size[[int]$op]
  }
  if ($hit -or ($Method -and $md.GetString($m.Name) -match $Method)) {
    $t = $md.GetTypeDefinition($m.GetDeclaringType())
    "==== $($md.GetString($t.Namespace)).$($md.GetString($t.Name)).$($md.GetString($m.Name))"
    $events
  }
}
