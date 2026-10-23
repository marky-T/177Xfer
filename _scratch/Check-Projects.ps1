$j = 'E:\Repos\SsgTrial\_scratch\rd-jul27\SsgConverter'
$s = 'E:\Repos\SsgTrial\SsgConverter\Source'
$r = 'E:\Repos\amt-go-net-ref\Migration Tools\SsgConverter'
'== our Source top level'; Get-ChildItem $s | Select-Object -ExpandProperty Name
'== R&D develop SsgConverter top level'; Get-ChildItem $r | Select-Object -ExpandProperty Name
function Hash([string]$p) { [BitConverter]::ToString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes(((Get-Content $p -Raw) -replace "`r`n", "`n")))) }
foreach ($proj in 'SsgConverterConsole', 'SsgConverterGui') {
  "== $proj : jul27 vs ours vs R&D develop"
  foreach ($f in Get-ChildItem "$j\$proj" -Recurse -File | Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' }) {
    $rel = $f.FullName.Substring("$j\$proj".Length + 1)
    $hj = Hash $f.FullName
    $a = if (Test-Path "$s\$proj\$rel") { if ((Hash "$s\$proj\$rel") -eq $hj) { '=' } else { 'DIFF' } } else { 'missing' }
    $b = if (Test-Path "$r\$proj\$rel") { if ((Hash "$r\$proj\$rel") -eq $hj) { '=' } else { 'DIFF' } } else { 'missing' }
    '{0,-40} ours:{1,-8} rd:{2}' -f $rel, $a, $b
  }
}
'== EOL of R&D develop and jul27 library files'
foreach ($p in "$r\SsgConverter\SymstreamProcessor.cs", "$j\SsgConverter\SymstreamProcessor.cs") {
  $b = [IO.File]::ReadAllBytes($p); $crlf = 0; $lf = 0
  for ($i = 0; $i -lt $b.Length; $i++) { if ($b[$i] -eq 10) { if ($i -gt 0 -and $b[$i - 1] -eq 13) { $crlf++ } else { $lf++ } } }
  '{0}: CRLF={1} bareLF={2} BOM={3}' -f $p, $crlf, $lf, ($b[0] -eq 0xEF)
}
