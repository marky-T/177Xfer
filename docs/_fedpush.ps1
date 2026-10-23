<#  _fedpush.ps1 (scratch) — commit Scripts_SSG onto the feature branch and push for PR review.
    Re-runnable. Requires git identity to be configured (commit authorship).
    RUN FROM AN ELEVATED PowerShell (repo .git is ACL-restricted for non-admins).
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repo   = 'E:\Repos\Federale_InternalRelease'
$branch = 'feature/federale/ssg-scripts-release'
Set-Location $repo

$log = @()

# 0. identity must be set or git commit makes no commit
$name  = (git config user.name)
if (-not $name)  { $name  = git config --global user.name }
$email = (git config user.email)
if (-not $email) { $email = git config --global user.email }
if (-not $name -or -not $email) {
  $log += "ABORT: git identity not set. In this elevated terminal run these, then re-run this script:"
  $log += '  git config --global user.name  "Your Name"'
  $log += '  git config --global user.email "you@avanade.com"'
  [IO.File]::WriteAllText('E:\Repos\SsgTrial\docs\_fedpush.txt', ($log -join "`r`n"))
  Write-Host ($log -join "`n"); return
}
$log += "identity: $name <$email>"

# 1. on the feature branch
git checkout $branch 2>&1 | Out-Null
$cur = git rev-parse --abbrev-ref HEAD
if ($cur -ne $branch) { throw "not on $branch (on $cur)" }

# 2. stage ONLY Scripts_SSG
git add -- 'Scripts_SSG' 2>&1 | Out-Null
$stagedOther = @(git diff --cached --name-only | Where-Object { $_ -notlike 'Scripts_SSG/*' })
$stagedSSG   = @(git diff --cached --name-only | Where-Object { $_ -like 'Scripts_SSG/*' })
$log += "stagedSSG=$($stagedSSG.Count) stagedOther=$($stagedOther.Count)"
if ($stagedOther.Count -gt 0) {
  $log += 'ABORT: non-Scripts_SSG staged'; $log += ($stagedOther | Select-Object -First 10)
  [IO.File]::WriteAllText('E:\Repos\SsgTrial\docs\_fedpush.txt', ($log -join "`r`n")); return
}

# 3. commit if anything staged
if ($stagedSSG.Count -gt 0) {
  git commit -m "Add Scripts_SSG: SSG->PowerShell converted report bundle (20 programs: bodies + CC wrappers + original source + README/notes). Live-validated for CFH-COPY on AMT172 (JobId 1085, exit 0)." 2>&1 | ForEach-Object { $log += "commit: $_" }
}
$log += 'HEAD now: ' + (git log -1 --oneline)
$log += 'Scripts_SSG files in HEAD: ' + ((git ls-tree -r --name-only HEAD | Where-Object { $_ -like 'Scripts_SSG/*' }).Count)

# 4. push (fast-forward; branch already exists on remote at the old tip)
$push = git push origin $branch 2>&1
$log += 'push:'; $log += ($push | ForEach-Object { "$_" })
$log += 'remote tip: ' + (git ls-remote --heads origin $branch)

[IO.File]::WriteAllText('E:\Repos\SsgTrial\docs\_fedpush.txt', ($log -join "`r`n"))
Write-Host "done - see _fedpush.txt"
