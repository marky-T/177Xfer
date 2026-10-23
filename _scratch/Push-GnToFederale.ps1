# Run ELEVATED (Federale_InternalRelease\.git is ACL-restricted). Commits one GN package to a new branch off origin/main
# in a separate worktree, so the main clone's checked-out branch and its uncommitted changes are not touched.
# Without -Push it stops after the commit and shows what would be pushed.
param(
  [String]$Package = 'E:\Repos\release_candidates\release20261022-rc.02',
  [String]$RepoDir = 'E:\Repos\Federale_InternalRelease',
  [String]$Worktree = 'E:\Repos\Federale_InternalRelease-wt-ssg4',
  [String]$Branch = 'feature/federale/ssg4-generic-rc02',
  [String]$TargetFolder = 'SSG4_Generic',
  [Switch]$Push
)
$ErrorActionPreference = 'Stop'
function Invoke-Git { & git.exe -C $args[0] @($args[1..($args.Count - 1)]); if ($LASTEXITCODE) { throw "git $($args[1..($args.Count - 1)] -join ' ') failed ($LASTEXITCODE)" } }

$name = git.exe -C $RepoDir config user.name; $mail = git.exe -C $RepoDir config user.email
if (-not $name -or -not $mail -or $mail -notmatch '@') { throw "git identity missing or placeholder: '$name' <$mail>" }
"identity: $name <$mail>"
if (-not (Test-Path "$Package\manifest.csv")) { throw "no manifest in $Package" }
$bad = @(Import-Csv "$Package\manifest.csv" | Where-Object { (Get-FileHash "$Package\$($_.Path)").Hash -ne $_.Sha256 })
if ($bad) { throw "package files differ from manifest: $($bad.Path -join ', ')" }
'package manifest: OK'

Invoke-Git $RepoDir fetch origin
"origin/main: $(git.exe -C $RepoDir log -1 --format='%h %cd %s' --date=short origin/main)"
if (Test-Path $Worktree) { throw "$Worktree already exists - remove it (git worktree remove) or pick another -Worktree" }
Invoke-Git $RepoDir worktree add -b $Branch $Worktree origin/main

$dest = Join-Path $Worktree "$TargetFolder\$(Split-Path $Package -Leaf)"
New-Item -ItemType Directory -Force $dest | Out-Null
# Only what the manifest lists: an IDE opening the package leaves .vs/obj folders that must not be committed.
foreach ($p in @(Import-Csv "$Package\manifest.csv").Path + 'manifest.csv') {
  $to = Join-Path $dest $p; New-Item -ItemType Directory -Force (Split-Path $to) | Out-Null; Copy-Item (Join-Path $Package $p) $to -Force
}
# Binaries/*.dll may be ignored by the repo's .gitignore; add the package folder by force so the DLL travels too.
Invoke-Git $Worktree add --force -- "$TargetFolder"
$staged = @(git.exe -C $Worktree diff --cached --name-only)
$outside = @($staged | Where-Object { $_ -notlike "$TargetFolder/*" })
if ($outside) { throw "staged files outside $TargetFolder : $($outside -join ', ')" }
"staged: $($staged.Count) files, all under $TargetFolder/"
Invoke-Git $Worktree commit -m "SSG-4 generic utility programs for FEDERALE_APP ($(Split-Path $Package -Leaf))" -m "7 generic programs (CFH-COPY, BABA, FUSBA, CHABAN, CONDIS2, SCAN, TAPELD) generated in LionDev application AFBUS (namespace Federale.AFBUS.BusinessLogic), rebuilt for the 177a runtime, with 13 hand-off skeletons and 9 includes. CFH-COPY proven in Control Center under FEDERALE_APP (jobs 1084/1085, byte-identical); the same COBOL passed the 14-job CC regression in the trial application. See RELEASE-NOTES.txt and INSTALL.txt."
git.exe -C $Worktree log -1 --stat --format='%h %an <%ae>%n%s' | Select-Object -First 12
if (-not $Push) { "NOT pushed. Check the commit, then push: git -C $Worktree push -u origin $Branch"; return }
Invoke-Git $Worktree push -u origin $Branch
"remote tip: $(git.exe -C $RepoDir ls-remote origin "refs/heads/$Branch")"
