$ours = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter'
$theirs = 'E:\Repos\amt-go-net-ref\Migration Tools\SsgConverter\SsgConverter'
function Get-Rel($root) {
  Get-ChildItem $root -Recurse -File -Include *.cs, *.csproj | Where-Object { $_.FullName -notmatch '\\(obj|bin)\\' } |
    ForEach-Object { [pscustomobject]@{ Rel = $_.FullName.Substring($root.Length + 1); Hash = (Get-FileHash $_.FullName -Algorithm SHA256).Hash; Path = $_.FullName } }
}
$o = Get-Rel $ours; $t = Get-Rel $theirs
$ot = @{}; $o | ForEach-Object { $ot[$_.Rel] = $_ }
$tt = @{}; $t | ForEach-Object { $tt[$_.Rel] = $_ }
foreach ($k in ($ot.Keys + $tt.Keys | Sort-Object -Unique)) {
  $state = if (-not $tt.ContainsKey($k)) { 'ONLY-OURS' } elseif (-not $ot.ContainsKey($k)) { 'ONLY-RND' } elseif ($ot[$k].Hash -eq $tt[$k].Hash) { 'same' } else { 'DIFFERENT' }
  $d = ''
  if ($state -eq 'DIFFERENT') {
    $a = Get-Content $ot[$k].Path; $b = Get-Content $tt[$k].Path
    $diff = Compare-Object $b $a
    $d = '  lines R&D={0} ours={1} changed-lines={2}' -f $b.Count, $a.Count, $diff.Count
  }
  '{0,-10} {1}{2}' -f $state, $k, $d
}
