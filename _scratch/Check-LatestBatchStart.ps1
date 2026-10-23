$f = 'E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Logs\' + (Get-Date -Format 'yyyyMMdd') + '\FederaleBatchController.Log'
$out = 'E:\Repos\SsgTrial\_scratch\bc-latest-start.txt'
$all = Get-Content $f
$starts = @(); for ($i = 0; $i -lt $all.Count; $i++) { if ($all[$i] -match 'AmtService started at') { $starts += $i } }
$from = $starts[-1]
$lines = $all[$from..($all.Count - 1)] | Where-Object { $_ -match '^\d{8}|started at|Unhandled|Queued' } | ForEach-Object { ($_ -replace '\s+', ' ').Trim() }
"log: $f  (last write $((Get-Item $f).LastWriteTime))" | Out-File $out
$lines | Out-File $out -Append -Width 300
"Unhandled-job lines in the latest start: $(@($lines | Where-Object { $_ -match 'Unhandled' }).Count)"
"Services:"
Get-Service Federale* | Sort-Object Name | ForEach-Object { '{0,-28} {1}' -f $_.Name, $_.Status }
