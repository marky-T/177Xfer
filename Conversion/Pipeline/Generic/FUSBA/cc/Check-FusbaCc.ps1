# FUSBA (MT-043): after the SSG4_FUSBA_CASES job, compare every case's outputs byte for byte with the model's expected files.
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$utility = Split-Path $PSScriptRoot
. "$(Split-Path $utility)\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = "$($ge.GenericWork)\FUSBA"
. "$utility\check\FusbaModel.ps1"
. "$PSScriptRoot\FusbaCases.ps1"
$x = $ge.ExtractPath
$root = "$work\cases"
$logs = "$($ge.LogPath)\$(Get-Date -Format yyyyMMdd)"
$ev = "$work\cc-runs"
'--- BatchController'
Get-Content "$logs\FederaleBatchController.Log" | Where-Object { $_ -match 'SSG4_FUSBA_CASES|\sFUSBA\s' } | Select-Object -Last 12 | ForEach-Object { ($_ -replace '\s+', ' ').Trim() }
$log = Get-ChildItem $logs -Filter 'FUSBATEST_*.log' | Sort-Object LastWriteTime | Select-Object -Last 1
"--- $($log.Name)"
Get-Content $log.FullName | Where-Object { $_ -match 'FUSBA case|hand-off|Starting Cobol|Error|Abort|Script Done|RECORDS' } | ForEach-Object { ($_ -replace '\s+', ' ').Trim() }
New-Item -ItemType Directory -Force $ev | Out-Null
$pass = 0; $total = 0
foreach ($case in $FusbaCases.Keys) {
  $p = Read-FusbaParm (Get-Content "$work\parm\$($FusbaCases[$case]).parm")
  foreach ($o in $p.Outs) {
    $total++
    $exp = [IO.File]::ReadAllBytes("$root\$case\expected\$($o[0])")
    $f = Get-Item "$x\FUSB$case\$($o[0]).DAT", "$x\FUSB$case\$($o[0])" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $f) { '{0,-3} {1,-8} not written (expected {2:N0} B)' -f $case, $o[0], $exp.Length; continue }
    Copy-Item $f.FullName "$ev\$case-$($f.Name)" -Force
    $act = [IO.File]::ReadAllBytes($f.FullName)
    $same = $act.Length -eq $exp.Length -and [System.Linq.Enumerable]::SequenceEqual([byte[]]$act, [byte[]]$exp)
    if ($same) { $pass++ }
    '{0,-3} {1,-8} {2,7:N0} B vs expected {3,7:N0} B: {4}' -f $case, $o[0], $act.Length, $exp.Length, $(if ($same) { 'PASS byte-identical' } else { 'FAIL' })
  }
}
"--- $pass of $total outputs byte-identical"
if ($log) { Copy-Item $log.FullName $ev -Force }
