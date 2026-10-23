$j = 'E:\Repos\SsgTrial\_scratch\rd-jul27\SsgConverter\SsgConverter'
$o = 'E:\Repos\SsgTrial\SsgConverter\Source\SsgConverter'
$r = 'E:\Repos\amt-go-net-ref\Migration Tools\SsgConverter\SsgConverter'
function FileHash2($p) { [BitConverter]::ToString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes(((Get-Content $p -Raw) -replace "`r`n", "`n")))) }
'files differing from the 27 July base:'
foreach ($f in Get-ChildItem $j -Recurse -File | Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' }) {
  $rel = $f.FullName.Substring($j.Length + 1); $hj = FileHash2 $f.FullName
  $a = if (Test-Path "$o\$rel") { if ((FileHash2 "$o\$rel") -eq $hj) { '=' } else { 'DIFF' } } else { 'missing' }
  $b = if (Test-Path "$r\$rel") { if ((FileHash2 "$r\$rel") -eq $hj) { '=' } else { 'DIFF' } } else { 'missing' }
  if ($a -ne '=' -or $b -ne '=') { '{0,-50} ours:{1,-8} rd:{2}' -f $rel, $a, $b }
}
'files only in ours / rd (excluding bin, obj):'
foreach ($d in $o, $r) { Get-ChildItem $d -Recurse -File | Where-Object { $_.FullName -notmatch '\\(bin|obj)\\' } | ForEach-Object { $rel = $_.FullName.Substring($d.Length + 1); if (-not (Test-Path "$j\$rel")) { "$d :: $rel" } } }

