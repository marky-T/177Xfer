# After one SSG4_LOADIS_ABORT run: the job must end in Error with the ERRDISQ lines for the expected record and key,
# must not reach the Xqt, and must leave no index for the output.
param([Parameter(Mandatory)][ValidateSet('UNSORTED', 'DUPLICATE')][String]$Case, [Parameter(Mandatory)][String]$After, [String]$Environment = 'CC-Trial')
. "$(Split-Path (Split-Path $PSScriptRoot))\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$work = "$($ge.GenericWork)\LOADIS"
$c = Get-Content "$work\abort-cases.json" -Raw | ConvertFrom-Json | Where-Object Case -eq $Case
$logs = $ge.LogPath
$t = [DateTime]::ParseExact(($After -replace '^.*started\s+'), 'yyyy-MM-dd HH:mm:ss', $null)
$log = Get-ChildItem "$logs\$($t.ToString('yyyyMMdd'))" -Filter 'LOADABRT_*.log' | Where-Object LastWriteTime -ge $t | Sort-Object LastWriteTime | Select-Object -Last 1
if (-not $log) { "$Case FAIL: no job log after $t"; exit 1 }
$text = Get-Content $log.FullName -Raw
$ev = "$work\cc-runs\ABORT"
New-Item -ItemType Directory -Force $ev | Out-Null
Copy-Item $log.FullName $ev -Force
$checks = [ordered]@{
  'IS.ERROR key'          = $text.Contains("IS.ERROR         : $($c.Key)")
  'record number'         = $text.Contains("RECORD EN ERREUR : $($c.Record) EME")
  'job aborted'           = $text -match 'Script aborted|INVALID KEY'
  'program not started'   = -not ($text -match 'Starting Cobol program')
  'not past the Xqt'      = -not $text.Contains('NOT STOPPED')
  'no index left'         = -not (Test-Path "$($ge.ExtractPath)\$($c.Qual)\OUTCLOA49.DAT.Index")
}
$bad = @($checks.Keys | Where-Object { -not $checks[$_] })
'{0} {1}: {2}' -f $Case, $(if ($bad.Count) { 'FAIL' } else { 'PASS' }), (($checks.Keys | ForEach-Object { "$_=$($checks[$_])" }) -join ', ')
"log: $($log.Name)"
exit $bad.Count
