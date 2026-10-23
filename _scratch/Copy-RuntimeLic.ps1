$src = 'C:\Amt\lic\AmtRuntime.lic'
$dst = 'E:\Amt\AmtRuntime.lic'
if (-not (Test-Path $src)) { throw "Not found: $src" }
if (Test-Path $dst) { throw "Already exists: $dst" }
Copy-Item $src $dst
$a = (Get-FileHash $src).Hash; $b = (Get-FileHash $dst).Hash
'{0} -> {1}: {2}' -f $src, $dst, $(if ($a -eq $b) { 'copied, hashes match ' + $a.Substring(0, 10) } else { 'HASH MISMATCH' })
# the old install's copy, for the record
$old = 'E:\Repos\z-old\AMT\AmtRuntime.lic'
if (Test-Path $old) { 'old install copy identical: ' + ((Get-FileHash $old).Hash -eq $a) }
