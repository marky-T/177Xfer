$ErrorActionPreference = 'Stop'
$out = New-Object System.Collections.Generic.List[string]

$dll177  = 'E:\Repos\Federale_InternalRelease\AFBUS_2200COBOL\Source\Cobol_AMT\Binaries\Programs\Asysco.Amt.Runtime.dll'   # generation tree = 177
$dll177a = 'E:\Repos\Federale_InternalRelease\AmtTools\AmtBatchController\BatchControllerAgentCore\Asysco.Amt.Runtime.dll' # deployed = 177a
$reportPoolRt = 'E:\Repos\Federale_InternalRelease\AFBUS_2200COBOL\Binaries\BatchWorking\FederaleBatchController\ReportPool.1'

function Dump-Ctors {
  param([string]$AssemblyPath, [string]$Label)
  $out.Add("===== $Label =====")
  $out.Add("Path: $AssemblyPath")
  if (-not (Test-Path -LiteralPath $AssemblyPath)) { $out.Add('  NOT FOUND'); return }
  $fi = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($AssemblyPath)
  $out.Add("FileVersion=$($fi.FileVersion)  Product=$($fi.ProductVersion)")

  # MetadataLoadContext: read-only, does not run code. Resolve deps from the assembly's own folder + runtime dir.
  $folder = Split-Path $AssemblyPath -Parent
  $runtimeDir = [System.Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
  $paths = @()
  $paths += (Get-ChildItem -LiteralPath $folder -Filter '*.dll' -File -ErrorAction SilentlyContinue).FullName
  $paths += (Get-ChildItem -LiteralPath $runtimeDir -Filter '*.dll' -File -ErrorAction SilentlyContinue).FullName
  $paths = $paths | Sort-Object -Unique

  Add-Type -AssemblyName 'System.Reflection.MetadataLoadContext' -ErrorAction SilentlyContinue
  $resolver = [System.Reflection.PathAssemblyResolver]::new([string[]]$paths)
  $mlc = [System.Reflection.MetadataLoadContext]::new($resolver)
  try {
    $asm = $mlc.LoadFromAssemblyPath($AssemblyPath)
    $type = $asm.GetType('Asysco.Amt.Runtime.Skeleton.AmtBaseCobolProgram')
    if ($null -eq $type) { $out.Add('  Type AmtBaseCobolProgram NOT FOUND'); return }
    $ctors = $type.GetConstructors([System.Reflection.BindingFlags]'Public,NonPublic,Instance')
    $out.Add("  Constructors ($($ctors.Count)):")
    foreach ($c in $ctors) {
      $ps = ($c.GetParameters() | ForEach-Object { $_.ParameterType.Name }) -join ', '
      $vis = if ($c.IsPublic) { 'public' } elseif ($c.IsFamily) { 'protected' } else { 'private/internal' }
      $out.Add("    [$vis] .ctor($ps)")
    }
  } finally { $mlc.Dispose() }
}

Dump-Ctors -AssemblyPath $dll177  -Label '177 (generation tree)'
$out.Add('')
Dump-Ctors -AssemblyPath $dll177a -Label '177a (deployed runtime)'
$out.Add('')
$out.Add('===== ReportPool.1 own Runtime.dll (what actually loads next to the report) =====')
$rp = Join-Path $reportPoolRt 'Asysco.Amt.Runtime.dll'
if (Test-Path -LiteralPath $rp) {
  $fi = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($rp)
  $out.Add("$rp | FileVersion=$($fi.FileVersion) Product=$($fi.ProductVersion)")
} else { $out.Add("No Asysco.Amt.Runtime.dll in ReportPool.1 (loads from parent/agent core)") }

[IO.File]::WriteAllLines('E:\Repos\SsgTrial\docs\_ctor-diff.txt', $out)
Write-Output 'DONE'
