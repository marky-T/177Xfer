# Run elevated (the SsgTrial .git is ACL-restricted).
# Backs up the SsgTrial working state plus the SSG-4 folders outside it as one commit on a 177Xfer branch.
# SsgTrial's branch, index and files are not changed: the commit is built with temporary index files.
$ErrorActionPreference = 'Stop'
$repo = 'E:\Repos\SsgTrial'
$gitDir = "$repo\.git"
$branch = 'ssg4-backup-20261023'
$remote = 'https://github.com/marky-T/177Xfer.git'
$extra = [ordered]@{
  '_external/ssg4-source'        = 'E:\Repos\ssg4-source'
  '_external/ssg4-work'          = 'E:\Repos\ssg4-work'
  '_external/release_candidates' = 'E:\Repos\release_candidates'
}
$tmp = Join-Path $env:TEMP "ssg4-backup-$PID"
New-Item -ItemType Directory $tmp | Out-Null
function Assert-Git([String]$What) { if ($LASTEXITCODE) { throw "$What failed ($LASTEXITCODE)" } }

try {
  $env:GIT_INDEX_FILE = "$tmp\main.idx"
  git -C $repo read-tree HEAD; Assert-Git 'read-tree HEAD'
  git -C $repo add -A 2>$null; Assert-Git 'add SsgTrial'

  $n = 0
  foreach ($prefix in $extra.Keys) {
    $dir = $extra[$prefix]; $n++
    $env:GIT_INDEX_FILE = "$tmp\x$n.idx"
    git -C $dir --git-dir=$gitDir --work-tree=$dir add -A --force . 2>$null; Assert-Git "add $dir"
    $t = git -C $dir --git-dir=$gitDir --work-tree=$dir write-tree; Assert-Git "write-tree $dir"
    $env:GIT_INDEX_FILE = "$tmp\main.idx"
    git -C $repo read-tree --prefix="$prefix/" $t; Assert-Git "read-tree $prefix"
  }

  $tree = git -C $repo write-tree; Assert-Git 'write-tree'
  $msg = "SSG-4 backup 2026-10-23: SsgTrial working state (incl. _scratch, _backup, docs) + ssg4-source, ssg4-work, release_candidates under _external/. Not pruned."
  $commit = git -C $repo commit-tree $tree -p HEAD -m $msg; Assert-Git 'commit-tree'
}
finally {
  Remove-Item Env:GIT_INDEX_FILE -ErrorAction SilentlyContinue
  Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

git -C $repo update-ref "refs/backup/$branch" $commit; Assert-Git 'update-ref'
git -C $repo push $remote "${commit}:refs/heads/$branch"; Assert-Git 'push'
"backup commit $commit pushed to $remote branch $branch"
git -C $repo ls-tree -r --name-only $commit | Measure-Object | ForEach-Object { "files in backup: $($_.Count)" }
