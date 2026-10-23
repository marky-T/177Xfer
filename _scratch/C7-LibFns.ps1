$lib = 'E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Scripts\Libraries\AmtPsEclLib.psm1'
$t = Get-Content $lib
$out = foreach ($fn in 'Check-AddFileName', 'Add-Sgs', 'Asg', 'Get-PhysicalFilename', 'Get-Fullfilename') {
  $n = ($t | Select-String "^\s*function\s+$fn\b" | Select-Object -First 1).LineNumber
  if ($n) { "=== $fn @ $n"; $t[($n - 1)..($n + 70)] | Where-Object { $_ -notmatch '^\s*(#|\.[A-Z]|$)' } | Select-Object -First 45 } else { "=== $fn not found" }
}
$out | Out-File E:\Repos\SsgTrial\_scratch\c7-survey\lib-fns.txt -Width 200
"lines: $($out.Count)"
Get-ChildItem E:\Repos\Federale_InternalRelease\Scripts\ASSURFED_UTILIT -Filter '*CFH*' | ForEach-Object { '{0} {1} {2}' -f $_.Name, $_.Length, $_.LastWriteTime }
