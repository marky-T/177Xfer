<#  _fixauthor.ps1 (scratch) — set real git identity and re-author the Scripts_SSG branch as ONE clean commit.
    RUN FROM AN ELEVATED PowerShell.  Example:
      pwsh -File 'E:\Repos\SsgTrial\docs\_fixauthor.ps1' -Name "Mark Truman" -Email "mark.truman@avanade.com"
#>
param(
  [Parameter(Mandatory)][string]$Name,
  [Parameter(Mandatory)][string]$Email
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repo   = 'E:\Repos\Federale_InternalRelease'
$branch = 'feature/federale/ssg-scripts-release'
$base   = '82883357f05d5ada7340466947d687e42bee4c76'   # commit the branch started from
Set-Location $repo
$log = @()

git config --global user.name  $Name
git config --global user.email $Email
$log += "identity: $(git config --global user.name) <$(git config --global user.email)>"

git checkout $branch 2>&1 | Out-Null
if ((git rev-parse --abbrev-ref HEAD) -ne $branch) { throw "not on $branch" }

# Collapse the branch's commits into one, authored by the new identity, with the CURRENT tree (83 files).
git reset --soft $base 2>&1 | Out-Null
$staged = @(git diff --cached --name-only)
$other  = @($staged | Where-Object { $_ -notlike 'Scripts_SSG/*' })
$log += "staged=$($staged.Count) outsideScripts_SSG=$($other.Count)"
if ($other.Count -gt 0) { $log += 'ABORT: changes outside Scripts_SSG staged'; $log += ($other | Select-Object -First 10); [IO.File]::WriteAllText('E:\Repos\SsgTrial\docs\_fixauthor.txt', ($log -join "`r`n")); return }

git commit -m "Add Scripts_SSG: SSG->PowerShell converted report bundle (20 programs: bodies + CC wrappers + original source + README/notes). Live-validated for CFH-COPY on AMT172 (JobId 1085, exit 0)." 2>&1 | ForEach-Object { $log += "commit: $_" }
$log += 'HEAD: ' + (git log -1 --pretty=format:'%h  %an <%ae>  %s')
$log += 'Scripts_SSG files in HEAD: ' + (@(git ls-tree -r --name-only HEAD | Where-Object { $_ -like 'Scripts_SSG/*' }).Count)
$log += 'VALIDATION-PROMPT present: ' + (@(git ls-tree -r --name-only HEAD | Where-Object { $_ -eq 'Scripts_SSG/VALIDATION-PROMPT.md' }).Count)

git fetch origin 2>&1 | Out-Null
$push = git push --force-with-lease origin $branch 2>&1
$log += 'push:'; $log += ($push | ForEach-Object { "$_" })
$log += 'remote tip: ' + (git ls-remote --heads origin $branch)

[IO.File]::WriteAllText('E:\Repos\SsgTrial\docs\_fixauthor.txt', ($log -join "`r`n"))
Write-Host 'done - see _fixauthor.txt'
