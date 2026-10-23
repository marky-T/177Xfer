# BABA (MT-043): after the SSG4_BABA_CASES job, compare every case's outputs byte for byte with the model's expected files.
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$utility = Split-Path $PSScriptRoot
. "$(Split-Path $utility)\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = "$($ge.GenericWork)\BABA"
. "$utility\check\BabaModel.ps1"
$x = "$($ge.ExtractPath)\BABATEST"
$root = "$work\cases"
$logs = "$($ge.LogPath)\$(Get-Date -Format yyyyMMdd)"
$cases = [ordered]@{ E1 = '2PPJ11_L74'; R2 = '-d_AFID01_L76'; AM1 = '-d_AFPD03_L94'; RM2 = '-d_EXPD05_OP_L54'; C2 = '-d_VIRD13_MJ_L48'; RB2 = 'PAIJ01_PP_L69'; E19 = 'SINM05_L211' }
'--- BatchController'
Get-Content "$logs\FederaleBatchController.Log" | Where-Object { $_ -match 'SSG4_BABA_CASES|\sBABA\s' } | Select-Object -Last 16 | ForEach-Object { ($_ -replace '\s+', ' ').Trim() }
$log = Get-ChildItem $logs -Filter 'BABATEST_*.log' | Sort-Object LastWriteTime | Select-Object -Last 1
"--- $($log.Name)"
Get-Content $log.FullName | Where-Object { $_ -match 'BABA case|Starting Cobol|Error|Abort|Script Done|RECORDS' } | ForEach-Object { ($_ -replace '\s+', ' ').Trim() }
$pass = 0; $total = 0
foreach ($case in $cases.Keys) {
  $p = Read-BabaParm (Get-Content "$work\parm\$($cases[$case]).parm")
  foreach ($o in $p.Outs) {
    $total++
    $exp = [IO.File]::ReadAllBytes("$root\$case\expected\$($o[0])")
    $f = Get-Item "$x\$($o[0]).DAT", "$x\$($o[0])" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $f) { '{0,-4} {1,-14} not written (expected {2:N0} B)' -f $case, $o[0], $exp.Length; continue }
    $act = [IO.File]::ReadAllBytes($f.FullName)
    $same = $act.Length -eq $exp.Length -and [System.Linq.Enumerable]::SequenceEqual([byte[]]$act, [byte[]]$exp)
    if ($same) { $pass++ }
    '{0,-4} {1,-14} {2,7:N0} B vs expected {3,7:N0} B: {4}' -f $case, $o[0], $act.Length, $exp.Length, $(if ($same) { 'PASS byte-identical' } else { 'FAIL' })
  }
}
"--- $pass of $total outputs byte-identical"
New-Item -ItemType Directory -Force "$work\cc-runs" | Out-Null
Copy-Item "$x\*", $log.FullName "$work\cc-runs\" -Force
