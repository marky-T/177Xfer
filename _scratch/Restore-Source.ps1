$ErrorActionPreference = 'Stop'
# Run from an ELEVATED pwsh: puts the verified fixed source (T3-030, T3-031) back into Source.
$good = 'E:\Repos\SsgTrial\_scratch\ssgfix2\src\SsgConverter\SymstreamProcessor.cs'
$target = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter\SymstreamProcessor.cs'
Copy-Item $target 'E:\Repos\SsgTrial\SsgConverter\_backup\SymstreamProcessor.cs.vscode-save-20261015' -Force
Copy-Item $good $target -Force
$a = (Get-FileHash $good).Hash; $b = (Get-FileHash $target).Hash
"good   $a"; "source $b"; if ($a -eq $b) { 'RESTORED: identical' } else { throw 'Hashes differ' }
