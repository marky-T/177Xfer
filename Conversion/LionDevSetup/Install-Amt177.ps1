<#
.SYNOPSIS
  Switches LionDev from AMT 179 to AMT 177a by a clean install into E:\Amt, with the 179 folder parked for instant undo.
.DESCRIPTION
  Stage   : refuses while LionDev / the generator run; moves the contents of E:\Amt into E:\Amt_179_parked (same volume,
            instant), creates E:\Amt\Setup, copies Setup.exe + AMT_177.dat from the Xfer clone and checks their SHA-256.
  -Install: runs Setup.exe BATCHINSTALL QUIET from E:\Amt\Setup (the same way the 179 clean install ran) and reports Setup.log.
  Undo    : Restore-Amt179.ps1 -Apply (from the snapshot), or: empty the new E:\Amt and move the contents of
            E:\Amt_179_parked back.
  Does not touch Lion.ini (created afterwards from Default_Lion.ini), the repository databases, Y:, Federale, or the services.
.EXAMPLE
  pwsh -NoProfile -File Install-Amt177.ps1            # stage only
  pwsh -NoProfile -File Install-Amt177.ps1 -Install   # stage if needed, then install
#>
param(
  [String]$Root = 'E:\Amt',
  [String]$Parked = 'E:\Amt_179_parked',
  [String]$Media = 'E:\Repos\177Xfer\8.0.26230.0',
  [Switch]$Install
)
$ErrorActionPreference = 'Stop'
$wantHash = @{
  'Setup.exe'   = 'B947D788EAC2526EA432F1E34571F5AD991CA06F01F58C3964CEDDFABBE1C602'
  'AMT_177.dat' = '143AC42A2E463E437971555CA95FE4B5275C73B167EA7DD6F2FD62E7D2BB2DC5'
}
if (Get-Process LionDev, LionDevGenNet -ErrorAction SilentlyContinue) { throw 'Close LionDev and the generator first.' }

$state = if (-not (Test-Path $Root)) { 'empty' } elseif (Test-Path (Join-Path $Root 'Lion\LionDev.exe')) { 'installed' } else { 'staged' }
$ver = if ($state -eq 'installed') { (Get-Item (Join-Path $Root 'Lion\LionDev.exe')).VersionInfo.ProductVersion } else { '' }
"State    : $Root is $state $ver"

if ($state -eq 'installed' -and $ver -like '*179*') {
  if (Test-Path $Parked) { throw "$Parked already exists; resolve that first." }
  if (-not (Test-Path 'E:\AMT_Backup\Amt179-clean\state.json')) { throw 'No clean 179 snapshot found; run Backup-Amt179.ps1 first.' }
  # E:\Amt itself cannot be renamed (something holds it as a working directory); moving its contents is the same on one volume
  New-Item -ItemType Directory -Path $Parked | Out-Null
  foreach ($item in Get-ChildItem $Root -Force) { Move-Item $item.FullName (Join-Path $Parked $item.Name) }
  "Parked   : contents of $Root moved to $Parked"
  $state = 'empty'
}
if ($state -eq 'empty') { New-Item -ItemType Directory -Path "$Root\Setup" -Force | Out-Null }
foreach ($f in $wantHash.Keys) {
  $dst = Join-Path "$Root\Setup" $f
  if (-not (Test-Path $dst)) { Copy-Item (Join-Path $Media $f) $dst }
  $h = (Get-FileHash $dst -Algorithm SHA256).Hash
  '{0,-12} {1}' -f $f, $(if ($h -eq $wantHash[$f]) { 'staged, SHA-256 ok' } else { throw "$f hash mismatch ($h)" })
}

if ($Install) {
  $log = "$Root\Setup\Setup.log"
  "Install  : Setup.exe BATCHINSTALL QUIET (from $Root\Setup) ..."
  $p = Start-Process -FilePath "$Root\Setup\Setup.exe" -ArgumentList 'BATCHINSTALL', 'QUIET' -WorkingDirectory "$Root\Setup" -PassThru -Wait
  "Exit code: $($p.ExitCode)"
  if (Test-Path $log) { '--- Setup.log (tail)'; Get-Content $log -Tail 14 }
  $lion = Join-Path $Root 'Lion\LionDev.exe'
  "LionDev  : " + $(if (Test-Path $lion) { (Get-Item $lion).VersionInfo.ProductVersion } else { 'NOT FOUND - install did not complete' })
}
