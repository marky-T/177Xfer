$ErrorActionPreference = 'Stop'
# Run from an ELEVATED pwsh: lands the two fixes (T3-030, T3-031) into Source, rebuilds, refreshes the DLLs and regenerates the goldens.
$repo = 'E:\Repos\SsgTrial'
$patched = "$repo\_scratch\ssgfix2\src\SsgConverter\SymstreamProcessor.cs"
$target = "$repo\SsgConverter\Source\SsgConverter\SymstreamProcessor.cs"
if (-not (Test-Path $patched)) { throw "Run Build-Fix2.ps1 first: $patched" }
if (-not (Test-Path "$repo\SsgConverter\_backup")) { New-Item -ItemType Directory "$repo\SsgConverter\_backup" | Out-Null }
Copy-Item $target "$repo\SsgConverter\_backup\SymstreamProcessor.cs.before-T3-030-031" -Force
Copy-Item $patched $target -Force
"Source updated: $((Get-Item $target).Length) bytes"
& "$repo\SsgConverter\Trials\Reconvert-And-Verify.ps1" -Rebuild -RefreshDll -UpdateGoldens
