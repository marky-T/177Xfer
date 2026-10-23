$d = 'E:\Repos\SsgTrial\docs\Reference Docs'
foreach ($f in Get-ChildItem $d -Filter *.md) {
  $t = [IO.File]::ReadAllText($f.FullName)
  $c1 = ([regex]::Matches($t, 'SSG|Symbiont|Symstream|Stream Generator')).Count
  '{0,-60} {1,9} chars  ssg-hits={2}  first: {3}' -f $f.Name, $t.Length, $c1, ($t.Substring(0, [Math]::Min(80, $t.Length)) -replace '\s+', ' ')
}
'--- the root of the SsgTrial docs for an SSG manual'
Get-ChildItem 'E:\Repos\SsgTrial' -Recurse -Include *.md, *.txt -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notmatch '\\(_scratch|node_modules|\.git|bin|obj)\\' -and $_.Length -gt 200000 } | ForEach-Object { $t = [IO.File]::ReadAllText($_.FullName); $c = ([regex]::Matches($t, '\*INCREMENT|\*DEFINE')).Count; if ($c -gt 5) { '{0}  *INCREMENT/*DEFINE hits={1}' -f $_.FullName, $c } }
