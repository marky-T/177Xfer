<#
.SYNOPSIS
  Snapshot of everything the AMT 179 LionDev setup depends on, so that replacing it with 177a can be undone.
.DESCRIPTION
  Copies E:\Amt (LionDev, tools, Setup, licence, Lion.ini) and records the machine settings the change would touch:
  the Y: DOS-device mapping, the LionDev services and file hashes. Writes state.json next to the copy and verifies
  the copy against the source. Read-only on the live system; only writes under -BackupRoot.
  Not covered here (untouched by the plan, so no backup needed): the AMT_REPOS database (use Backup-RepositoryDb.sql
  for a belt-and-braces copy), E:\AMT_Y\CSharpNet (the 179 source stays; 177 source goes to its own folder),
  E:\AMT_Work\Apps (177 generates into a different folder), Federale's tree and databases.
.EXAMPLE
  pwsh -NoProfile -File Backup-Amt179.ps1
#>
param(
  [String]$Root = 'E:\Amt',
  [String]$BackupRoot = 'E:\AMT_Backup',
  [String]$Label = 'Amt179'
)
$ErrorActionPreference = 'Stop'
$dest = Join-Path $BackupRoot $Label
if (Test-Path $dest) { throw "$dest already exists. Pick another -Label or remove it on purpose." }
if (Get-Process LionDev, LionDevGenNet -ErrorAction SilentlyContinue) { Write-Warning 'LionDev is running; open files may copy in an inconsistent state. Close it and re-run for a clean snapshot.' }

$bytes = (Get-ChildItem $Root -Recurse -File -Force | Measure-Object Length -Sum).Sum
$free = (Get-PSDrive ([IO.Path]::GetPathRoot($BackupRoot).Substring(0, 1))).Free
if ($free -lt 2 * $bytes) { throw 'Not enough free space for the backup.' }

New-Item -ItemType Directory -Path "$dest\Amt" -Force | Out-Null
robocopy $Root "$dest\Amt" /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy failed ($LASTEXITCODE)" }

# machine settings the change would touch
$dos = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices').'Y:'
$services = Get-CimInstance Win32_Service | Where-Object { $_.Name -like 'LionDev*' } |
  Select-Object Name, State, StartMode, StartName, PathName
$hashFiles = 'Lion\LionDev.exe', 'Lion\LionDevGenNet.exe', 'Lion\Lion.ini', 'Setup\Setup.exe', 'Setup\AMT_179.dat', 'License\Lion.Lic'
$hashes = foreach ($h in $hashFiles) {
  $p = Join-Path $Root $h
  if (Test-Path $p) { [pscustomobject]@{ File = $h; Bytes = (Get-Item $p).Length; Sha256 = (Get-FileHash $p -Algorithm SHA256).Hash } }
}
$state = [ordered]@{
  Created = (Get-Date).ToString('s'); Root = $Root; Files = (Get-ChildItem "$dest\Amt" -Recurse -File -Force | Measure-Object).Count; Bytes = $bytes
  LionDevVersion = (Get-Item (Join-Path $Root 'Lion\LionDev.exe')).VersionInfo.ProductVersion
  YDosDevice = @($dos); Services = @($services); Hashes = @($hashes)
}
$state | ConvertTo-Json -Depth 5 | Set-Content "$dest\state.json" -Encoding utf8

# verify the copy: nothing differs between source and copy
$diff = robocopy $Root "$dest\Amt" /E /L /NJH /NJS /NP /NDL /XO | Where-Object { $_ -match '\S' }
"Backup : $dest"
"Files  : {0}   Bytes: {1:N0}   LionDev {2}" -f $state.Files, $state.Bytes, $state.LionDevVersion
"Y:     : $($state.YDosDevice)"
"Verify : " + $(if ($diff) { "DIFFERENCES FOUND:`n" + ($diff -join "`n") } else { 'copy matches the live folder' })
