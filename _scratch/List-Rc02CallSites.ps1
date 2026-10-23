$c = Import-Csv 'E:\Repos\ssg4-work\sgs-cards\sgs-calls.csv'
$keys = 'CFH-COPY_ASCII','LOADIS_ASCII','LOADIS_MULTI','UNLOADIS_ASCII','UNLOADIS_MULTI','BABA_ASCII','FUSBA_ASCII','FUSBA2_ASCII','CHABAN_ASCII','CHAB100_ASCII','CONDIS2_ASCII','SCAN_ASCII','TAPELD_ASCII'
$prog = @{ 'CFH-COPY_ASCII'='CFH_COPY_GN'; 'LOADIS_ASCII'='CFH_COPY_GN'; 'LOADIS_MULTI'='CFH_COPY_GN'; 'UNLOADIS_ASCII'='CFH_COPY_GN'; 'UNLOADIS_MULTI'='CFH_COPY_GN'; 'BABA_ASCII'='BABA_GN'; 'FUSBA_ASCII'='FUSBA_GN'; 'FUSBA2_ASCII'='FUSBA_GN'; 'CHABAN_ASCII'='CHABAN_GN'; 'CHAB100_ASCII'='CHABAN_GN'; 'CONDIS2_ASCII'='CONDIS2_GN'; 'SCAN_ASCII'='SCAN_GN'; 'TAPELD_ASCII'='TAPELD_GN' }
$all = @($c | Where-Object { $_.ProgramKey -in $keys })
$rows = $all | ForEach-Object { [pscustomobject]@{ Program = $prog[$_.ProgramKey]; Script = $_.ProgramKey; Runstream = ($_.Runstream -replace '\(P\)', '' -replace '\.TXT$', ''); RunId = $_.RunId; Line = [int]$_.Line; Cards = $_.Cards; Labels = $_.Labels } } | Sort-Object Program, Script, Runstream, Line
$rows | Export-Csv 'E:\Repos\ssg4-work\rc02-call-sites.csv' -NoTypeInformation
$o = @("total rows: $($c.Count); covered call sites: $($rows.Count)")
$o += $rows | Group-Object Script | ForEach-Object { '{0,-16} {1,4}' -f $_.Name, $_.Count }
$o += '--- by program'
$o += $rows | Group-Object Program | ForEach-Object { '{0,-14} {1,4}  runstreams {2}' -f $_.Name, $_.Count, @($_.Group.Runstream | Select-Object -Unique).Count }
$o += "distinct runstreams: $(@($rows.Runstream | Select-Object -Unique).Count)"
$o += '--- not covered (other keys in the csv)'
$o += $c | Where-Object { $_.ProgramKey -notin $keys } | Group-Object ProgramKey | ForEach-Object { '{0,-16} {1,4}' -f $_.Name, $_.Count }
$o | Set-Content 'E:\Repos\ssg4-work\rc02-call-sites-summary.txt'
