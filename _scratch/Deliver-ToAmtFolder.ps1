$src  = 'E:\AMT_Work\Delivery\AFBUS_2200COBOL_AMT-20261019-1743\Binaries'
$dest = 'E:\Repos\AMT\Apps\AFBUS_2200COBOL_AMT\Binaries'
New-Item -ItemType Directory -Force "$dest\Application", "$dest\Programs" | Out-Null
robocopy "$src\Application" "$dest\Application" /E /NFL /NDL /NJH /NJS /NP | Out-Null
robocopy "$src\Programs" "$dest\Programs" /E /NFL /NDL /NJH /NJS /NP | Out-Null
$a = @(Get-ChildItem "$dest\Application" -File).Count
$p = @(Get-ChildItem "$dest\Programs" -Filter *.dll -File).Count
"Application files: $a   Programs dlls: $p   (dest: $dest)"
