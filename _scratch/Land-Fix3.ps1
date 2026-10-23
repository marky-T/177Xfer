$ErrorActionPreference = 'Stop'
# Run from an ELEVATED pwsh: lands T3-018 (NOT before a relation) and T3-033 (variable names in SGS references) into Source,
# rebuilds, refreshes the DLLs and regenerates the goldens.
$repo = 'E:\Repos\SsgTrial'
$patched = "$repo\_scratch\ssgfix3\src\SsgConverter\SymstreamExpressionMigrator.cs"
$target = "$repo\SsgConverter\Source\SsgConverter\SymstreamExpressionMigrator.cs"
if (-not (Test-Path $patched)) { throw "Run Build-Fix3.ps1 first: $patched" }
Copy-Item $target "$repo\SsgConverter\_backup\SymstreamExpressionMigrator.cs.before-T3-018-033" -Force
Copy-Item $patched $target -Force
if ((Get-FileHash $patched).Hash -ne (Get-FileHash $target).Hash) { throw 'Source copy did not land.' }
"Source updated: $((Get-Item $target).Length) bytes"
& "$repo\SsgConverter\Trials\Reconvert-And-Verify.ps1" -Rebuild -RefreshDll -UpdateGoldens
