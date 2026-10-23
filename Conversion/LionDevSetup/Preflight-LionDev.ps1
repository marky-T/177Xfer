<#
.SYNOPSIS
  Read-only preflight for the LionDev-only AMT install at E:\Amt (decision D9). Changes nothing.
.DESCRIPTION
  Checks the installer files against amt179-manifest.csv, that E:\Amt holds only the Setup folder
  (Setup does a clean install of its root), that the generator service is not running, the stale
  LionDev service registrations, the Y: drive and E:\AMT_Y, and the build prerequisites LionDev needs.
  Prints OK / WARN / FAIL per check; exit code 1 if any FAIL.
.EXAMPLE
  pwsh -NoProfile -File Preflight-LionDev.ps1
#>
param(
  [String]$Root = 'E:\Amt',
  [String]$YRoot = 'E:\AMT_Y',
  [String]$Manifest = (Join-Path $PSScriptRoot 'amt179-manifest.csv')
)

$fail = 0
function Report($level, $text) {
  if ($level -eq 'FAIL') { $script:fail++ }
  "{0,-5} {1}" -f $level, $text
}

"== installer files ($Root\Setup)"
foreach ($m in Import-Csv $Manifest) {
  $p = Join-Path "$Root\Setup" $m.file
  if (-not (Test-Path -LiteralPath $p)) { Report 'FAIL' "missing $($m.file)"; continue }
  $ok = ((Get-Item -LiteralPath $p).Length -eq [int64]$m.bytes) -and ((Get-FileHash -LiteralPath $p).Hash -eq $m.sha256)
  Report $(if ($ok) { 'OK' } else { 'FAIL' }) "$($m.file) size and SHA-256 $(if ($ok) { 'match the manifest' } else { 'DO NOT match the manifest' })"
}

"== install root"
$extra = @(Get-ChildItem -LiteralPath $Root -Force -ErrorAction SilentlyContinue | Where-Object Name -ne 'Setup')
if ($extra) { Report 'WARN' "$Root holds more than Setup ($($extra.Name -join ', ')); Setup does a clean install and may remove it" } else { Report 'OK' "$Root holds only Setup" }
$free = [Math]::Round((Get-PSDrive ($Root.Substring(0, 1))).Free / 1GB, 0)
Report $(if ($free -ge 20) { 'OK' } else { 'WARN' }) "$free GB free on $($Root.Substring(0, 2))"

"== LionDev services and processes"
$running = @(Get-Process -ErrorAction SilentlyContinue | Where-Object Name -match '^LionDev')
if ($running) { Report 'FAIL' "running: $($running.Name -join ', '). Setup refuses to update while LionDevGenNet runs" } else { Report 'OK' 'no LionDev process running' }
foreach ($name in 'LionDevGenNet', 'LionDevNet_Generator') {
  $svc = Get-CimInstance Win32_Service -Filter "Name='$name'"
  if (-not $svc) { Report 'OK' "$name not registered"; continue }
  $exe = ($svc.PathName -replace '^"?([^"]+?\.exe).*$', '$1')
  $note = if (Test-Path -LiteralPath $exe) { 'target exists' } else { "STALE: target $exe is missing; re-point or remove before use" }
  Report $(if ($svc.State -eq 'Running') { 'FAIL' } else { 'WARN' }) "$name is $($svc.State), $note"
}

"== Y: drive"
$ydir = Join-Path $YRoot 'CSharpNet'
if (Test-Path (Join-Path $ydir 'Amt.Net')) { Report 'OK' "$ydir\Amt.Net present" } else { Report 'WARN' "$YRoot not extracted yet (YDrive_C#.7z)" }
$yd = Get-PSDrive Y -ErrorAction SilentlyContinue
if ($yd) { Report 'OK' "Y: is mapped to $($yd.Root); generated C# projects use Y:\Amt.Net\..." } else { Report 'WARN' "Y: not mapped. Needs to point at $ydir; a persistent mapping is needed for the generator service" }

"== build prerequisites"
$rel = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction SilentlyContinue).Release
Report $(if ($rel -ge 528040) { 'OK' } else { 'FAIL' }) ".NET Framework 4.8 (LionDev targets it), release $rel"
$sdks = @(dotnet --list-sdks 2>$null)
Report $(if ($sdks) { 'OK' } else { 'WARN' }) ".NET SDKs: $(if ($sdks) { ($sdks | ForEach-Object { ($_ -split ' ')[0] }) -join ', ' } else { 'none (only runtimes); building generated C# needs an SDK' })"
$vsw = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vs = if (Test-Path $vsw) { & $vsw -all -products * -requires Microsoft.Component.MSBuild -property displayName 2>$null } else { $null }
if ($vs) { Report 'OK' "MSBuild from: $($vs -join '; ')" } else { Report 'WARN' 'no Visual Studio / Build Tools with MSBuild found' }

"== SQL Server"
$sql = Test-NetConnection localhost -Port 1433 -WarningAction SilentlyContinue
Report $(if ($sql.TcpTestSucceeded) { 'OK' } else { 'FAIL' }) "SQL Server port 1433 reachable: $($sql.TcpTestSucceeded)"
Report 'INFO' 'database creation rights are not checked here; run the ava test yourself (it asks for the password)'

"== Federale snapshot (compare after Setup)"
Get-Service Federale* | ForEach-Object { Report 'INFO' ("{0,-27} {1}" -f $_.Name, $_.Status) }

if ($fail) { "RESULT: $fail FAIL"; exit 1 } else { 'RESULT: no blocking problems'; exit 0 }
