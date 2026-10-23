<#
  Repair-SqlServerWrapperClosure.ps1  —  Area D / MT-009 Stage B support

  Diagnoses (and, with -Repair, fixes) AmtTools component folders whose *.deps.json references
  Microsoft.Data.SqlClient but whose folder is missing the physical assembly + native SNI closure
  -- the root cause of the CFH-COPY Control Center run failing with:
    "Failed creating database connection, is the wrapper for MsSql configured correctly?
     Exception:[Microsoft.Data.SqlClient is not supported on this platform.]"

  Default (no -Repair): READ-ONLY scan. Lists every AmtTools\**\*.deps.json mentioning
  Microsoft.Data.SqlClient and flags folders missing Microsoft.Data.SqlClient.dll or the
  runtimes\win-x64\native\Microsoft.Data.SqlClient.SNI.dll native companion.

  With -Repair: for each gap folder (or just -WrapperFolder if -TargetOnly is set), backs up the
  folder's current contents to SsgConverter\_backup\SqlServerWrapper-<timestamp>\, then copies the
  Microsoft.Data.SqlClient* assemblies + runtimes\ subtree from -SourceFolder (a verified-working
  sibling AmtTools component folder) into the gap folder. Never deletes/overwrites the component's
  own DLLs (Asysco.Amt.*) - only adds the missing SqlClient closure files.

  Idempotent: re-running with -Repair on an already-fixed folder is a no-op (files already present,
  same version) unless -Force is given.

  Guardrails: only ever touches AmtTools component folders (shared infra), never FEDERALE_APP's own
  config/catalog/DB rows. Read-only by default; -Repair is required to write anything.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
  [string]$FederaleRoot   = 'E:\Repos\Federale_InternalRelease',
  [string]$AmtToolsPath   = 'E:\Repos\Federale_InternalRelease\AmtTools',
  [string]$SourceFolder   = 'E:\Repos\Federale_InternalRelease\AmtTools\AmtBatchController\PowerShellHost',
  [string]$WrapperFolder  = 'E:\Repos\Federale_InternalRelease\AmtTools\SqlServerWrapper',
  [switch]$Repair,
  [switch]$TargetOnly,
  [switch]$Force,
  [string]$BackupRoot     = 'E:\Repos\SsgTrial\SsgConverter\_backup'
)
$ErrorActionPreference = 'Stop'

function Test-SqlClientClosure {
  param([string]$Folder)
  [PSCustomObject]@{
    Folder      = $Folder
    HasDll      = Test-Path -LiteralPath (Join-Path $Folder 'Microsoft.Data.SqlClient.dll')
    HasNativeSni = Test-Path -LiteralPath (Join-Path $Folder 'runtimes\win-x64\native\Microsoft.Data.SqlClient.SNI.dll')
  }
}

# 1) Scan: every deps.json under AmtTools mentioning Microsoft.Data.SqlClient
Write-Host "=== Scanning $AmtToolsPath for Microsoft.Data.SqlClient closures ==="
$gaps = New-Object System.Collections.Generic.List[object]
Get-ChildItem -LiteralPath $AmtToolsPath -Recurse -File -Filter '*.deps.json' -ErrorAction SilentlyContinue | ForEach-Object {
  $content = Get-Content -LiteralPath $_.FullName -Raw -ErrorAction SilentlyContinue
  if ($content -match 'Microsoft.Data.SqlClient') {
    $status = Test-SqlClientClosure -Folder $_.DirectoryName
    $flag = if ($status.HasDll -and $status.HasNativeSni) { 'OK' } else { 'GAP' }
    Write-Host ("[{0}] {1}" -f $flag, $_.FullName)
    if ($flag -eq 'GAP') { $gaps.Add($status) }
  }
}

if ($gaps.Count -eq 0) {
  Write-Host "`nNo gaps found - every referenced folder already has the SqlClient closure."
  if (-not $Repair) { return }
}
else {
  Write-Host ("`nFound {0} gap folder(s):" -f $gaps.Count)
  $gaps | ForEach-Object { Write-Host "  - $($_.Folder)" }
}

if (-not $Repair) {
  Write-Host "`n(Scan only - re-run with -Repair to copy the closure from $SourceFolder into the gap(s) above.)"
  return
}

# 2) Repair: copy the closure from the verified source into each gap folder (or just -WrapperFolder)
$targets = if ($TargetOnly) { @($WrapperFolder) } else { $gaps.Folder }

if (-not (Test-Path -LiteralPath $SourceFolder)) { throw "Source folder not found: $SourceFolder" }
$srcCheck = Test-SqlClientClosure -Folder $SourceFolder
if (-not ($srcCheck.HasDll -and $srcCheck.HasNativeSni)) {
  throw "Source folder itself is missing the SqlClient closure - pick a different -SourceFolder: $SourceFolder"
}

foreach ($target in $targets) {
  $status = Test-SqlClientClosure -Folder $target
  if ($status.HasDll -and $status.HasNativeSni -and -not $Force) {
    Write-Host "SKIP (already OK): $target"
    continue
  }

  if (-not $PSCmdlet.ShouldProcess($target, "Copy Microsoft.Data.SqlClient closure from $SourceFolder")) { continue }

  # Backup first (idempotent-safe: timestamped, never overwrites a prior backup)
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $leaf = Split-Path $target -Leaf
  $backupDir = Join-Path $BackupRoot "SqlClientClosure-$leaf-$stamp"
  New-Item -ItemType Directory -Force -Path $backupDir | Out-Null
  Copy-Item -Path (Join-Path $target '*') -Destination $backupDir -Recurse -Force
  Write-Host "Backed up $target -> $backupDir"

  # Copy the managed assemblies (top level only - don't touch the component's own Asysco.Amt.*.dll)
  Get-ChildItem -LiteralPath $SourceFolder -File -Filter 'Microsoft.Data.SqlClient*.dll' | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $target -Force
  }
  # Copy the native/runtime closure subtree wholesale
  $srcRuntimes = Join-Path $SourceFolder 'runtimes'
  if (Test-Path -LiteralPath $srcRuntimes) {
    Copy-Item -LiteralPath $srcRuntimes -Destination $target -Recurse -Force
  }

  $after = Test-SqlClientClosure -Folder $target
  Write-Host ("REPAIRED {0} -> HasDll={1} HasNativeSni={2}" -f $target, $after.HasDll, $after.HasNativeSni)
}
