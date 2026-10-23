$ex = 'E:\Repos\SsgTrial\SsgConverter\Examples\Input'
'== *COPY / *ADD / *PROCESS SKEL$ / @ADD / @SSG in the 20 inputs (file: count)'
foreach ($pat in '^\*\s*COPY\b', '^\*\s*ADD\b', '^\*\s*PROCESS\b', '^@ADD', '^@SSG', '^\*\s*DEFINE\b') {
  $hits = Get-ChildItem $ex -File | Select-String -Pattern $pat
  '{0,-14} total {1,4}   {2}' -f $pat, @($hits).Count, ((@($hits) | Group-Object Filename | ForEach-Object { '{0}:{1}' -f $_.Name, $_.Count }) -join ', ')
}
'== what the processor does with *COPY and *ADD'
$l = [IO.File]::ReadAllLines('E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter\SymstreamProcessor.cs')
foreach ($d in 'Copy', 'Add') {
  for ($i = 0; $i -lt $l.Count; $i++) {
    if ($l[$i] -match "case DirectiveId\.$d\b") { "--- $d at line $($i + 1)"; $l[($i)..($i + 14)] | ForEach-Object { '    ' + $_.Trim().Substring(0, [Math]::Min(140, $_.Trim().Length)) }; break }
  }
}
'== the 20 *PROCESS calls: names'
Get-ChildItem $ex -File | Select-String -Pattern '^\*\s*PROCESS\s+(\S+)' | ForEach-Object { '{0}: {1}' -f $_.Filename, $_.Matches[0].Groups[1].Value } | Select-Object -First 30
