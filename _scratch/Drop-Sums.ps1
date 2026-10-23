$p = 'E:\Repos\SsgTrial\SsgConverter\Trials\New-RnDPackage.ps1'
$t = [IO.File]::ReadAllText($p)
$nl = if ($t.Contains("`r`n")) { "`r`n" } else { "`n" }
# header: drop the checksum mention
$t = $t -replace '(?m)^\s*CHANGELIST\.md is written by hand into the output folder and is included in SHA256SUMS when present\. Idempotent\.\r?\n', ("  CHANGELIST.md and readme.txt are written by hand into the output folder. Idempotent." + $nl)
# body: drop the checksum block
$i = $t.IndexOf('# checksums of everything shipped')
if ($i -lt 0) { throw 'checksum block not found' }
$j = $t.IndexOf('"Package: $Out"', $i)
if ($j -lt 0) { throw 'package line not found' }
$t = $t.Substring(0, $i) + $t.Substring($j)
[IO.File]::WriteAllText($p, $t)
'patched script; SHA256SUMS mentions left: ' + ([regex]::Matches($t, 'SHA256SUMS')).Count
$o = 'E:\Repos\SsgTrial\SsgConverter\Release-RnD-20261014'
Copy-Item 'E:\Repos\SsgTrial\_scratch\readme.new.txt' "$o\readme.txt" -Force
Remove-Item "$o\SHA256SUMS.txt" -Force -ErrorAction SilentlyContinue
'readme replaced; SHA256SUMS.txt exists: ' + (Test-Path "$o\SHA256SUMS.txt")
