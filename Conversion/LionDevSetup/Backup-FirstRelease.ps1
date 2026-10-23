<#
.SYNOPSIS
  Backs up our first release of the converted SSG before it is replaced: the AFBUS_2200COBOL_AMT application folder
  (16 generated programs, 8 compiled, LionDev 178a build of 2026-09-25) and the Scripts_SSG PowerShell release.
.DESCRIPTION
  Copy only; the sources are not modified. Writes a manifest (path, size, SHA-256) and a registration note so the
  Control Center entry can be re-created. The Control Center row and the application database are NOT in the copy:
  see Backup-FirstReleaseDb.sql for the database, and registration.txt for the application record.
.EXAMPLE
  pwsh -NoProfile -File Backup-FirstRelease.ps1
#>
param(
  [String]$AppFolder = 'E:\Repos\z-old\AMT\Apps\AFBUS_2200COBOL_AMT',
  [String]$ScriptsSsg = 'E:\Repos\Federale_InternalRelease\Scripts_SSG',
  [String]$BackupRoot = 'E:\AMT_Backup',
  [String]$Label = 'FirstRelease-20261013'
)
$ErrorActionPreference = 'Stop'
$dest = Join-Path $BackupRoot $Label
if (Test-Path $dest) { throw "$dest already exists." }
New-Item -ItemType Directory -Path "$dest\AFBUS_2200COBOL_AMT", "$dest\Scripts_SSG" -Force | Out-Null
robocopy $AppFolder "$dest\AFBUS_2200COBOL_AMT" /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy (application) failed: $LASTEXITCODE" }
robocopy $ScriptsSsg "$dest\Scripts_SSG" /E /COPY:DAT /DCOPY:DAT /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
if ($LASTEXITCODE -ge 8) { throw "robocopy (Scripts_SSG) failed: $LASTEXITCODE" }

$manifest = foreach ($root in "$dest\AFBUS_2200COBOL_AMT", "$dest\Scripts_SSG") {
  Get-ChildItem $root -Recurse -File -Force | ForEach-Object {
    [pscustomobject]@{ Path = $_.FullName.Substring($dest.Length + 1); Bytes = $_.Length; Sha256 = (Get-FileHash $_.FullName -Algorithm SHA256).Hash }
  }
}
$manifest | Export-Csv "$dest\manifest.csv" -NoTypeInformation -Encoding utf8

# verify: copies equal their sources
$d1 = robocopy $AppFolder "$dest\AFBUS_2200COBOL_AMT" /E /L /NJH /NJS /NP /NDL /XO | Where-Object { $_ -match '\S' }
$d2 = robocopy $ScriptsSsg "$dest\Scripts_SSG" /E /L /NJH /NJS /NP /NDL /XO | Where-Object { $_ -match '\S' }
$gitHead = (git -C (Split-Path $ScriptsSsg -Parent) log -1 --format='%h %ad %s' --date=short -- Scripts_SSG)
@"
First release of the converted SSG, backed up $(Get-Date -Format s)

Application folder : $AppFolder
  copied to        : $dest\AFBUS_2200COBOL_AMT
Scripts_SSG        : $ScriptsSsg (git: $gitHead)
  copied to        : $dest\Scripts_SSG

Control Center registration read from FEDERALE_SYSTEM on 2026-10-13 (AMTSYSAPPLICATION):
  APPNAME AFBUS_2200COBOL_AMT, APPID 6, APPLICATIONTYPE 0, CONFIGID 1, DATABASEID 5,
  APPBASEPATH E:\Repos\AMT\Apps\AFBUS_2200COBOL_AMT, GUIADDRESS http://localhost:5121/,
  DESCRIPTION SSG ECL TRIAL - COBOL OS2200, AUTOSTART F, LOGINACCOUNTID 0, APPLICATIONKIND 4096 (Cobol OS 2200)
  Database definition 5: server VMFEDPE08, database AFBUS_2200COBOL_AMT, SQL Server (user and password encrypted, not copied here).
  Configuration 1 (default) is shared with FEDERALE_APP and is not part of this backup.
"@ | Set-Content "$dest\registration.txt" -Encoding utf8

"Backup   : $dest"
"Files    : {0} ({1:N1} MB)" -f @($manifest).Count, (($manifest | Measure-Object Bytes -Sum).Sum / 1MB)
"Verify   : application " + $(if ($d1) { "DIFFERENCES`n$($d1 -join "`n")" } else { 'matches' }) + ' / Scripts_SSG ' + $(if ($d2) { "DIFFERENCES`n$($d2 -join "`n")" } else { 'matches' })
