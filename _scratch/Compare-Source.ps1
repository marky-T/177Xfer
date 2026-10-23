$disk = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter\SymstreamProcessor.cs'
$good = 'E:\Repos\SsgTrial\_scratch\ssgfix2\src\SsgConverter\SymstreamProcessor.cs'
"disk $((Get-Item $disk).Length) bytes, good $((Get-Item $good).Length) bytes"
"disk  sha256 " + (Get-FileHash $disk -Algorithm SHA256).Hash
"good  sha256 " + (Get-FileHash $good -Algorithm SHA256).Hash
git diff --no-index --unified=1 $good $disk | Select-Object -Skip 4 -First 120
