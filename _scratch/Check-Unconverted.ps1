$p = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter\SymstreamProcessor.cs'
$l = [IO.File]::ReadAllLines($p)
'== the 10 "not used in STA sources" branches: what each does'
for ($i = 0; $i -lt $l.Count; $i++) {
  if ($l[$i] -match 'not used in STA sources') {
    $j = $i; while ($j -gt 0 -and $l[$j] -notmatch 'case DirectiveId\.') { $j-- }
    '{0,5} {1,-34} -> {2}' -f ($i + 1), $l[$j].Trim(), $l[$i + 1].Trim()
  }
}
'== directives in the DirectiveId enum with no case in the switch (fall to default = warning + comment)'
$enum = [IO.File]::ReadAllText('E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter\Enums\DirectiveId.cs')
$names = [regex]::Matches($enum, '^\s*([A-Za-z]+)\s*[,=]?', 'Multiline') | ForEach-Object { $_.Groups[1].Value } | Where-Object { $_ -notin 'using', 'namespace', 'public', 'enum', 'Ecl', 'System' }
$cases = $l | Select-String -Pattern 'case DirectiveId\.(\w+)' | ForEach-Object { $_.Matches[0].Groups[1].Value } | Sort-Object -Unique
'enum names : ' + ($names -join ', ')
'cases      : ' + ($cases -join ', ')
'no case    : ' + (($names | Where-Object { $_ -notin $cases }) -join ', ')
'== the end of Convert: what happens to an image that starts with * but is not a known directive'
for ($i = 1960; $i -lt 2090; $i++) { if ($l[$i] -match 'IsDirective|IsComment|StartsWith\("\*"\)|StartsWith\(m_DirectivePrefix\)|else if|else \{|Unexpected|NotImplemented') { '{0,5}: {1}' -f ($i + 1), $l[$i].Trim().Substring(0, [Math]::Min(150, $l[$i].Trim().Length)) } }
