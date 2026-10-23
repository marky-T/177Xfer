$ErrorActionPreference = 'Stop'
$out = New-Object System.Collections.Generic.List[string]

$mlcDll  = 'C:\Program Files\dotnet\sdk\10.0.400\System.Reflection.MetadataLoadContext.dll'
Add-Type -Path $mlcDll

$dll177  = 'E:\Repos\Federale_InternalRelease\AFBUS_2200COBOL\Source\Cobol_AMT\Binaries\Programs\Asysco.Amt.Runtime.dll'
$dll177a = 'E:\Repos\Federale_InternalRelease\AmtTools\AmtBatchController\BatchControllerAgentCore\Asysco.Amt.Runtime.dll'
$report  = 'E:\Repos\Federale_InternalRelease\AFBUS_2200COBOL\Binaries\Programs\Assurfed_Utilit_Cfh_Copy.dll'

function New-Mlc {
  param([string]$PrimaryFolder)
  $runtimeDir = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
  $paths = New-Object System.Collections.Generic.List[string]
  foreach ($f in @($PrimaryFolder, $runtimeDir, (Split-Path $mlcDll))) {
    if (Test-Path $f) { Get-ChildItem -LiteralPath $f -Filter '*.dll' -File -ErrorAction SilentlyContinue | ForEach-Object { $paths.Add($_.FullName) } }
  }
  $resolver = [System.Reflection.PathAssemblyResolver]::new([string[]]($paths | Sort-Object -Unique))
  [System.Reflection.MetadataLoadContext]::new($resolver)
}

function Dump-RuntimeCtors {
  param([string]$AssemblyPath, [string]$Label)
  $out.Add("===== $Label =====")
  $fi = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($AssemblyPath)
  $out.Add("$AssemblyPath | $($fi.FileVersion) | $($fi.ProductVersion)")
  $mlc = New-Mlc (Split-Path $AssemblyPath)
  try {
    $asm = $mlc.LoadFromAssemblyPath($AssemblyPath)
    $type = $asm.GetType('Asysco.Amt.Runtime.Skeleton.AmtBaseCobolProgram')
    if (-not $type) { $out.Add('  AmtBaseCobolProgram NOT FOUND'); return }
    foreach ($c in $type.GetConstructors([System.Reflection.BindingFlags]'Public,NonPublic,Instance')) {
      $ps = ($c.GetParameters() | ForEach-Object { $_.ParameterType.FullName }) -join ', '
      $vis = if ($c.IsPublic) {'public'} elseif ($c.IsFamily) {'protected'} elseif ($c.IsAssembly) {'internal'} else {'private'}
      $out.Add("  [$vis] .ctor($ps)")
    }
  } finally { $mlc.Dispose() }
  $out.Add('')
}

Dump-RuntimeCtors $dll177  '177  (generation-tree Runtime)'
Dump-RuntimeCtors $dll177a '177a (deployed Runtime)'

# What ctor does the compiled report actually CALL? Inspect its base type chain + the base ctor it was compiled against.
$out.Add('===== REPORT: Assurfed_Utilit_Cfh_Copy =====')
$mlc = New-Mlc (Split-Path $report)
try {
  $asm = $mlc.LoadFromAssemblyPath($report)
  foreach ($t in $asm.GetTypes()) {
    $bt = $t.BaseType
    if ($bt -and $bt.Name -match 'AmtBaseCobolProgram|CobolProgram') {
      $out.Add("  Type $($t.FullName) : base $($bt.FullName)")
      foreach ($c in $t.GetConstructors([System.Reflection.BindingFlags]'Public,NonPublic,Instance')) {
        $ps = ($c.GetParameters() | ForEach-Object { $_.ParameterType.FullName }) -join ', '
        $out.Add("    own .ctor($ps)")
      }
    }
  }
  $rtRef = $asm.GetReferencedAssemblies() | Where-Object { $_.Name -eq 'Asysco.Amt.Runtime' }
  if ($rtRef) { $out.Add("  Report references Asysco.Amt.Runtime version: $($rtRef.Version)") }
} finally { $mlc.Dispose() }

[IO.File]::WriteAllLines('E:\Repos\SsgTrial\docs\_decompile-ctor.txt', $out)
Write-Output 'DONE'
