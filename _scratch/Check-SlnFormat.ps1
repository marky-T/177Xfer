$w = 'E:\Repos\Federale_InternalRelease-wt-ssg4'
$o = 'E:\Repos\ssg4-work\sln-format.txt'
$r = @()
$sln = git -C $w show HEAD:BSP_AMT/Development/_All_.sln
$raw = [string]::Join("`n", $sln)
$bytes = [byte[]](git -C $w cat-file -p HEAD:BSP_AMT/Development/_All_.sln | Select-Object -First 0)
$r += "HEAD lines: $($sln.Count)"
$ab = @($sln | Select-String -Pattern 'Abrdms' | ForEach-Object { "$($_.LineNumber): $($_.Line)" })
$r += $ab
$i = ($sln | Select-String -Pattern '^Global$' | Select-Object -First 1).LineNumber
$r += "Global at $i; lines before:"; $r += $sln[($i - 4)..($i - 1)]
$cfg = ($sln | Select-String -Pattern 'GlobalSection\(ProjectConfigurationPlatforms\)' | Select-Object -First 1).LineNumber
$r += "ProjectConfigurationPlatforms at $cfg"
$nest = ($sln | Select-String -Pattern 'GlobalSection\(NestedProjects\)' | Select-Object -First 1).LineNumber
$r += "NestedProjects at $nest; first 2:"; $r += $sln[$nest..($nest + 1)]
$r += 'solution platforms:'; $sp = ($sln | Select-String -Pattern 'GlobalSection\(SolutionConfigurationPlatforms\)' | Select-Object -First 1).LineNumber; $r += $sln[$sp..($sp + 8)]
$r += 'Programs folder GUID line:'; $r += ($sln | Select-String -Pattern '= "Programs", "Programs"' | ForEach-Object Line)
$set = git -C $w show HEAD:Scripts/Settings/AmtSettings.xml
$r += "settings HEAD lines: $($set.Count); last 3:"; $r += $set | Select-Object -Last 3
$crlf = (git -C $w ls-files --eol -- BSP_AMT/Development/_All_.sln Scripts/Settings/AmtSettings.xml)
$r += $crlf
$r | Set-Content $o
