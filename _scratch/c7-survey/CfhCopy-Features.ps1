# CFH-COPY spike prep: which SGS labels the 47 real CFH-COPY calls use, and the skeleton's own label references. Read-only.
$root = 'E:\Repos\ssg4-work\sgs-cards'
$calls = Import-Csv "$root\sgs-calls.csv" | Where-Object ProgramKey -eq 'CFH-COPY_ASCII'
$labels = foreach ($c in $calls) { Get-Content (Join-Path $root $c.CardFile) | ForEach-Object { ($_.Trim() -split '\s+')[0].ToUpperInvariant() } | Where-Object { $_ } | Select-Object -Unique }
"CFH-COPY calls: $($calls.Count)"
$labels | Group-Object | Sort-Object Count -Descending | ForEach-Object { '  {0,-12} in {1,2} calls' -f $_.Name, $_.Count }
$src = Get-ChildItem 'E:\Repos\SsgTrial\SsgConverter\Examples\Input' -Filter 'CFH-COPY_ASCII*' | Select-Object -First 1
"Skeleton source: $($src.Name) $($src.Length) B, $((Get-Content $src.FullName).Count) lines"
$refs = Select-String -Path $src.FullName -Pattern '\[([A-Z0-9$]+)[,\]]' -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Groups[1].Value } | Group-Object | Sort-Object Name
'Labels referenced in the skeleton: ' + (($refs | ForEach-Object { "$($_.Name)($($_.Count))" }) -join ' ')
'Directives: ' + ((Select-String -Path $src.FullName -Pattern '^\*([A-Z]+)' | ForEach-Object { $_.Matches[0].Groups[1].Value } | Group-Object | ForEach-Object { "$($_.Name)($($_.Count))" }) -join ' ')
$v = 'E:\AMT_Work\MockTest\VIRM01'; 'VIRM01 cards: ' + ((Get-Content "$root\calls\ASSURFED_F999RUN_VIRM01_CO__L484.sgs") -join ' | ')
