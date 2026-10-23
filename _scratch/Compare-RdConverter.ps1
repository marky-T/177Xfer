$r = 'E:\Repos\amt-go-net-ref\Migration Tools\SsgConverter\SsgConverter'
$o = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter'
'R&D files: ' + (Get-ChildItem $r -Recurse -File -Exclude *.dll,*.pdb | Where-Object FullName -notmatch '\\(bin|obj)\\' | Measure-Object).Count
'Our files: ' + (Get-ChildItem $o -Recurse -File | Where-Object FullName -notmatch '\\(bin|obj)\\' | Measure-Object).Count
$rel = { param($root) Get-ChildItem $root -Recurse -File | Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' -and $_.Extension -notin '.dll', '.pdb' } | ForEach-Object { $_.FullName.Substring($root.Length + 1) } }
$rf = & $rel $r; $of = & $rel $o
'only in R&D: ' + (($rf | Where-Object { $_ -notin $of }) -join ', ')
'only in ours: ' + (($of | Where-Object { $_ -notin $rf }) -join ', ')
foreach ($f in $rf | Where-Object { $_ -in $of -and $_ -match '\.cs$' }) {
  $a = Get-Content (Join-Path $r $f) -Raw; $b = Get-Content (Join-Path $o $f) -Raw
  $na = ($a -replace '\r\n', "`n"); $nb = ($b -replace '\r\n', "`n")
  $d = @(Compare-Object ($na -split "`n") ($nb -split "`n"))
  '{0,-45} {1}  (R&D {2:N0} B, ours {3:N0} B, {4} differing lines)' -f $f, $(if ($d.Count) { 'DIFFERENT' } else { 'same' }), (Get-Item (Join-Path $r $f)).Length, (Get-Item (Join-Path $o $f)).Length, $d.Count
}
'--- git history of our copy (first commits touching the converter source)'
Set-Location E:\Repos\SsgTrial
git log --format='%h %ad %s' --date=short --diff-filter=A -- 'SsgConverter/Source/SsgConverter/SymstreamProcessor.cs' 2>&1 | Select-Object -First 3
