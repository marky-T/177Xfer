# Spike: result of the last SSG4_<call>_CFH_COPY script job: BatchController lines, job log essentials, byte-compare with the reference.
param([ValidateSet('AFPH12', 'VIRM01', 'NEWNAME', 'VIRM01UL')][String]$Call = 'AFPH12', [String]$Environment = 'CC-Trial')
. "$(Split-Path (Split-Path $PSScriptRoot))\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$day = Get-Date -Format 'yyyyMMdd'
$logs = "$($ge.LogPath)\$day"
$x = "$($ge.ExtractPath)\ASSURFED"
$m = $ge.MockRoot
$c = @{
  AFPH12 = @{ Out = 'IAFB012FAI.DAT'; Exp = "$m\AFPH12_L427\expected\OUTASC" }
  VIRM01 = @{ Out = 'I006VRM01ATC.DAT'; Exp = "$m\VIRM01\expected\INC" }
  NEWNAME = @{ Out = 'ZZTESTOUT.DAT'; Exp = "$m\AFPH12_L427\expected\OUTASC" }
  VIRM01UL = @{ Out = 'F006KTMAJ3.DAT'; Exp = "$m\VIRM01_UL\expected\F006KTMAJ3" }
}[$Call]
'--- BatchController'
Get-Content "$logs\FederaleBatchController.Log" | Where-Object { $_ -match "SSG4_${Call}|CFH_COPY" } | Select-Object -Last 5 | ForEach-Object { ($_ -replace '\s+', ' ').Trim() }
$log = Get-ChildItem $logs -Filter "${Call}_*.log" | Sort-Object LastWriteTime | Select-Object -Last 1
"--- $($log.Name)"
Get-Content $log.FullName | Where-Object { $_ -match 'hand-off|Invoke-Ssg|XQT:|Starting Cobol|NB-ENREG|Error|Abort|Script Done|not found' } | ForEach-Object { ($_ -replace '\s+', ' ').Trim() }
$bug = Get-ChildItem $logs -Filter '*BugReport.Log' | Where-Object LastWriteTime -ge $log.CreationTime
if ($bug) { '--- new bug reports: ' + (($bug | ForEach-Object { '{0} {1:HH:mm:ss}' -f $_.Name, $_.LastWriteTime }) -join ', ') }
$p = Get-ChildItem $x -Filter ($c.Out -replace '\.DAT$', '*') | Sort-Object LastWriteTime | Select-Object -Last 1
if (-not $p) { "--- output $($c.Out): not written"; return }
$a = [IO.File]::ReadAllBytes($p.FullName); $b = [IO.File]::ReadAllBytes($c.Exp)
$same = $a.Length -eq $b.Length -and [System.Linq.Enumerable]::SequenceEqual([byte[]]$a, [byte[]]$b)
'--- {0} {1:N0} B ({2:HH:mm:ss}) vs reference {3:N0} B: {4}' -f $p.Name, $a.Length, $p.LastWriteTime, $b.Length, $(if ($same) { 'PASS byte-identical' } else { 'FAIL' })
$ev = "$($ge.GenericWork)\CFH-COPY\cc-runs\$Call"
New-Item -ItemType Directory -Force $ev | Out-Null
Copy-Item $p.FullName, $log.FullName "$ev\" -Force
