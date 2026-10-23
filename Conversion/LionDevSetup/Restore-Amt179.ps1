<#
.SYNOPSIS
  Puts the AMT 179 LionDev setup back from a Backup-Amt179.ps1 snapshot. Dry run unless -Apply.
.DESCRIPTION
  1. Refuses while LionDev or its generator is running.
  2. Moves the current E:\Amt aside to E:\Amt_replaced_<time> (kept, never deleted) and copies the snapshot back.
  3. Compares the Y: DOS-device mapping and the LionDev services with the snapshot; fixes them when elevated,
     otherwise prints the exact elevated commands. A reboot is needed after the Y: change.
  Repository databases are never touched. The 179 repository (AMT_REPOS) is unchanged by the 177a plan.
.EXAMPLE
  pwsh -NoProfile -File Restore-Amt179.ps1            # show what would happen
  pwsh -NoProfile -File Restore-Amt179.ps1 -Apply     # do it
#>
param(
  [String]$Snapshot = 'E:\AMT_Backup\Amt179-clean',
  [String]$Root = 'E:\Amt',
  [Switch]$Apply
)
$ErrorActionPreference = 'Stop'
$statePath = Join-Path $Snapshot 'state.json'
if (-not (Test-Path $statePath)) { throw "No snapshot at $Snapshot (state.json missing)." }
$state = Get-Content $statePath -Raw | ConvertFrom-Json
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$mode = if ($Apply) { 'APPLY' } else { 'DRY RUN (add -Apply to do it)' }
"Mode     : $mode   (elevated: $isAdmin)"
"Snapshot : $Snapshot   taken $($state.Created), LionDev $($state.LionDevVersion), $($state.Files) files"

$running = Get-Process LionDev, LionDevGenNet -ErrorAction SilentlyContinue
if ($running) { "Running  : $(($running.Name | Sort-Object -Unique) -join ', ') - close it first"; if ($Apply) { throw 'Close LionDev and the generator window, then run again.' } }

# 1. folder
$aside = "${Root}_replaced_" + (Get-Date -Format 'yyyyMMdd-HHmmss')
"Folder   : contents of $Root moved to $aside, then snapshot copied back to $Root"
if ($Apply) {
  # E:\Amt itself may not be renameable (something can hold it as a working directory): move its contents instead
  New-Item -ItemType Directory -Path $aside | Out-Null
  if (Test-Path $Root) { foreach ($item in Get-ChildItem $Root -Force) { Move-Item $item.FullName (Join-Path $aside $item.Name) } }
  else { New-Item -ItemType Directory -Path $Root | Out-Null }
  robocopy (Join-Path $Snapshot 'Amt') $Root /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
  if ($LASTEXITCODE -ge 8) { throw "robocopy failed ($LASTEXITCODE). The previous folder is still at $aside." }
  foreach ($h in $state.Hashes) {
    $p = Join-Path $Root $h.File
    $ok = (Test-Path $p) -and ((Get-FileHash $p -Algorithm SHA256).Hash -eq $h.Sha256)
    '  {0,-6} {1}' -f $(if ($ok) { 'ok' } else { 'DIFF' }), $h.File
  }
}

# 2. Y: mapping
$key = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices'
$now = (Get-ItemProperty $key).'Y:'
$want = @($state.YDosDevice)
$same = (@($now) -join '|') -eq ($want -join '|')
"Y:       : now '$(@($now) -join ' ')'  wanted '$($want -join ' ')'  -> $(if ($same) { 'already correct' } else { 'must change (needs elevation + reboot)' })"
if (-not $same) {
  if ($Apply -and $isAdmin) { Set-ItemProperty -Path $key -Name 'Y:' -Value ([string[]]$want) -Type MultiString; '  Y: restored. REBOOT to apply.' }
  else { '  Elevated command:'; "  Set-ItemProperty -Path '$key' -Name 'Y:' -Value ([string[]]@('$($want -join "','")')) -Type MultiString   # then reboot" }
}

# 3. services
foreach ($s in $state.Services) {
  $cur = Get-CimInstance Win32_Service -Filter "Name='$($s.Name)'"
  $match = $cur -and $cur.PathName -eq $s.PathName
  "Service  : $($s.Name)  path $(if ($match) { 'already correct' } else { 'must change' })"
  if (-not $match) {
    if ($Apply -and $isAdmin) { sc.exe config $s.Name binPath= $s.PathName | Out-Null; '  re-pointed.' }
    else { "  Elevated command:  sc.exe config $($s.Name) binPath= `"$($s.PathName)`"" }
  }
}
if ($Apply) { "Done. If the Y: line said 'restored', reboot now. The failed 177a folder is kept at $aside." }
