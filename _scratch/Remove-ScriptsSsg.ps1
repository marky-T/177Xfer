# Run elevated (the Federale_InternalRelease .git is ACL-restricted).
$ErrorActionPreference = 'Stop'
$repo = 'E:\Repos\Federale_InternalRelease'
$wt = 'E:\Repos\Federale_InternalRelease-wt-rmssg'
$branch = 'feature/federale/remove-scripts-ssg'
$env:GCM_MSAUTH_FLOW = 'devicecode'

git -C $repo fetch origin main
git -C $repo worktree add $wt -b $branch origin/main
if ($LASTEXITCODE) { throw 'worktree add failed' }
git -C $wt rm -r -q Scripts_SSG
git -C $wt commit -m 'Remove Scripts_SSG (SSG-3 converted report bundle)' -m @'
Scripts_SSG (PR 14791) held the SSG-3 bundle: SSG skeletons converted to PowerShell that emit COBOL text.
They parse cleanly but do not run the utility, so they are not functional in the application.

Replaced by the SSG-4 generic programs, branch feature/federale/ssg4-generic-rc02 (PR 15867):
https://dev.azure.com/avanade-lt-coe/Federale/_git/Federale_InternalRelease?version=GBfeature/federale/ssg4-generic-rc02
'@
if ($LASTEXITCODE) { throw 'commit failed' }
git -C $wt push -u origin $branch
git -C $wt log --oneline -1
git -C $wt show --stat --format= HEAD | Select-Object -Last 1
