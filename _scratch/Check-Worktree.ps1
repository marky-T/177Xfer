$w = 'E:\Repos\Federale_InternalRelease-wt-ssg4'
$out = 'E:\Repos\ssg4-work\wt-check.txt'
$r = @()
try { $t = "$w\BSP_AMT\Development\_writetest.tmp"; Set-Content $t 'x' -ErrorAction Stop; Remove-Item $t; $r += 'worktree writable: yes' } catch { $r += "worktree writable: NO ($($_.Exception.Message))" }
$r += 'owner: ' + (Get-Acl $w).Owner
$sln = "$w\BSP_AMT\Development\_All_.sln"
$pat = '^Project\x28'
$n = (Select-String -Path $sln -Pattern $pat).Count
$len = (Get-Item $sln).Length
$r += "sln bytes: $len; projects: $n"
$r += (Get-Content $sln -TotalCount 4)
$r += (Select-String -Path $sln -Pattern '^Project\(.*Abrdms' | ForEach-Object Line)
$r += (Select-String -Path $sln -Pattern '^Project\("\{2150E333' | Select-Object -First 6 | ForEach-Object Line)
$r += (Select-String -Path $sln -Pattern 'GlobalSection\(NestedProjects\)' | ForEach-Object { "NestedProjects at line $($_.LineNumber)" })
$r | Set-Content $out
