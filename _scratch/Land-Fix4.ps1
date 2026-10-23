$ErrorActionPreference = 'Stop'
# Run from an ELEVATED pwsh: lands T3-034 (*CREATE SGS image as literal text) into Source, rebuilds, refreshes the DLLs and regenerates the goldens.
$repo = 'E:\Repos\SsgTrial'
$patched = "$repo\_scratch\ssgfix4\src\SsgConverter\SymstreamProcessor.cs"
$target = "$repo\SsgConverter\Source\SsgConverter\SymstreamProcessor.cs"
if (-not (Test-Path $patched)) { throw "Run Build-Fix4.ps1 first: $patched" }
Copy-Item $target "$repo\SsgConverter\_backup\SymstreamProcessor.cs.before-T3-034" -Force
Copy-Item $patched $target -Force
if ((Get-FileHash $patched).Hash -ne (Get-FileHash $target).Hash) { throw 'Source copy did not land.' }
"Source updated: $((Get-Item $target).Length) bytes"
& "$repo\SsgConverter\Trials\Reconvert-And-Verify.ps1" -Rebuild -RefreshDll -UpdateGoldens
