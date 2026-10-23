# How many different programs would the CFH-COPY calls need? Groups the exported card files per program by content.
$calls = Import-Csv 'E:\Repos\ssg4-work\sgs-cards\sgs-calls.csv'
$root = 'E:\Repos\ssg4-work\sgs-cards'
$calls | Where-Object Converted -eq 'True' | Group-Object ProgramKey | Sort-Object Count -Descending | ForEach-Object {
  $sets = $_.Group | ForEach-Object { ((Get-Content (Join-Path $root $_.CardFile)) -join "`n").ToUpperInvariant() -replace '[ \t]+', ' ' } | Group-Object
  $shapes = $_.Group | ForEach-Object { $c = Get-Content (Join-Path $root $_.CardFile); (($c | Where-Object { $_ -match '^\s*(INPUT|OUTPUT)\b' }) -replace '\s+', ' ') -join ' | ' } | Group-Object
  '{0,-16} calls {1,3}  distinct card sets {2,3}  distinct INPUT/OUTPUT shapes {3,3}' -f $_.Name, $_.Count, @($sets).Count, @($shapes).Count
}
