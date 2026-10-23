$f = 'E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Logs\20261020\FederaleBatchController.Log'
$out = 'E:\Repos\SsgTrial\_scratch\bc-tail.txt'
"{0} bytes, last write {1}" -f (Get-Item $f).Length, (Get-Item $f).LastWriteTime | Out-File $out
Get-Content $f -Tail 25 | ForEach-Object { ($_ -replace '\s+', ' ').Trim() } | Out-File $out -Append -Width 300
Get-Content $out | Select-Object -First 1
