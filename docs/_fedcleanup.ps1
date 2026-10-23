<#  _fedcleanup.ps1 (scratch) — remove Scripts_SSG/VALIDATION-PROMPT.md + its references, in ONE commit.
    RUN FROM AN ELEVATED PowerShell (repo .git is ACL-restricted for non-admins).
    The README/RELEASE-NOTES reference edits are already applied in the working tree.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repo   = 'E:\Repos\Federale_InternalRelease'
$branch = 'feature/federale/ssg-scripts-release'
Set-Location $repo
$log = @()

$name  = git config user.name;  if (-not $name)  { $name  = git config --global user.name }
$email = git config user.email; if (-not $email) { $email = git config --global user.email }
if (-not $name -or -not $email) { $log += 'ABORT: git identity not set'; [IO.File]::WriteAllText('E:\Repos\SsgTrial\docs\_fedcleanup.txt', ($log -join "`r`n")); Write-Host ($log -join "`n"); return }
$log += "identity: $name <$email>"

git checkout $branch 2>&1 | Out-Null
$cur = git rev-parse --abbrev-ref HEAD
if ($cur -ne $branch) { throw "not on $branch (on $cur)" }

# remove the file (working-tree delete + stage)
if (Test-Path 'Scripts_SSG/VALIDATION-PROMPT.md') { git rm -- 'Scripts_SSG/VALIDATION-PROMPT.md' 2>&1 | Out-Null }
# stage the README + RELEASE-NOTES reference edits
git add -- 'Scripts_SSG' 2>&1 | Out-Null

$staged = git diff --cached --name-only
$other  = @($staged | Where-Object { $_ -notlike 'Scripts_SSG/*' })
$log += "staged total=$($staged.Count) ; outside Scripts_SSG=$($other.Count)"
$log += 'staged list:'; $log += ($staged | Select-Object -First 15)
if ($other.Count -gt 0) { $log += 'ABORT: changes outside Scripts_SSG staged - not committing'; [IO.File]::WriteAllText('E:\Repos\SsgTrial\docs\_fedcleanup.txt', ($log -join "`r`n")); return }
if ($staged.Count -eq 0) { $log += 'Nothing staged (already clean?)'; [IO.File]::WriteAllText('E:\Repos\SsgTrial\docs\_fedcleanup.txt', ($log -join "`r`n")); return }

git commit -m "Remove VALIDATION-PROMPT.md from Scripts_SSG (internal dev artifact) and drop its references in README/RELEASE-NOTES" 2>&1 | ForEach-Object { $log += "commit: $_" }
$log += 'HEAD: ' + (git log -1 --oneline)
$log += 'VALIDATION-PROMPT.md still in tree: ' + ((git ls-tree -r --name-only HEAD | Where-Object { $_ -eq 'Scripts_SSG/VALIDATION-PROMPT.md' }).Count)
$log += 'Scripts_SSG files in HEAD: ' + ((git ls-tree -r --name-only HEAD | Where-Object { $_ -like 'Scripts_SSG/*' }).Count)

$push = git push origin $branch 2>&1
$log += 'push:'; $log += ($push | ForEach-Object { "$_" })
$log += 'remote tip: ' + (git ls-remote --heads origin $branch)

[IO.File]::WriteAllText('E:\Repos\SsgTrial\docs\_fedcleanup.txt', ($log -join "`r`n"))
Write-Host "done - see _fedcleanup.txt"
