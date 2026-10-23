$p = 'E:\Repos\SsgTrial\SsgConverter\Trials\New-RnDPackage.ps1'
$t = [IO.File]::ReadAllText($p)
$t = $t.Replace('a patch against R&D develop, and SHA256SUMS.', 'and a patch against R&D develop.')
[IO.File]::WriteAllText($p, $t)
Select-String -Path $p -Pattern 'SHA256SUMS|SYNOPSIS' -Context 0,1 | ForEach-Object { '{0}: {1}' -f $_.LineNumber, $_.Line }
'mentions left: ' + ([regex]::Matches($t, 'SHA256SUMS')).Count
