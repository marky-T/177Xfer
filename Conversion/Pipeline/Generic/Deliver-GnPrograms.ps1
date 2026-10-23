<#
.SYNOPSIS
  SSG-4: rebuild and deliver named generated programs to the AFBUS_2200COBOL_AMT application, with checks.
.DESCRIPTION
  For each program (e.g. ASSURFED_UTILIT_FUSBA_GN):
    1. the LionDev-generated source exists and was written after -Since (catches a LionDev round that skipped it);
    2. T3-040 rule: every variable-length input (VariableRecordSize) has a 4001-byte record in the generated code;
    3. rebuild only those programs against the 177a runtime (Rebuild-SetAgainstRuntime -Programs);
    4. the built DLL is new (written during this run).
  Only if every program passes, all DLLs are copied to the application and the copies are hash-checked.
  -CheckOnly stops after the pre-build checks. Run it in the foreground to completion; a whole rebuild moved to the background was once killed silently.
.EXAMPLE
  Deliver-GnPrograms.ps1 -Programs ASSURFED_UTILIT_CHABAN_GN, ASSURFED_UTILIT_BABA_GN, ASSURFED_UTILIT_CFH_COPY_GN -Since '2026-10-21 09:00'
#>
param(
  [Parameter(Mandatory)][String[]]$Programs,
  [Parameter(Mandatory)][DateTime]$Since,
  [String]$Environment = 'CC-Trial',
  [String]$Development,
  [String]$OutRoot,
  [String]$Deliver,
  [String]$Log,
  [Switch]$CheckOnly,
  [Switch]$SkipInputCheck
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
if (-not $Development) { $Development = $ge.LionDevelopment }
if (-not $OutRoot) { $OutRoot = $ge.RebuildRoot }
if (-not $Deliver) { $Deliver = $ge.ProgramsPath }
if (-not $Log) { $Log = "$($ge.GenericWork)\deliver" }
$start = Get-Date
New-Item -ItemType Directory -Force $Log | Out-Null
$logFile = Join-Path $Log ('deliver-{0:yyyyMMdd-HHmmss}.txt' -f $start)
$folderOf = { param($n) ($n.ToLowerInvariant() -split '_' | ForEach-Object { $_.Substring(0, 1).ToUpperInvariant() + $_.Substring(1) }) -join '_' }

$rows = foreach ($p in $Programs) {
  $f = & $folderOf $p
  $dir = Join-Path $Development "Programs\$f"
  $r = [ordered]@{ Program = $p; Folder = $f; Generated = $null; Check = ''; Built = $null; Delivered = '' }
  if (-not (Test-Path $dir)) { $r.Check = "FAIL no generated folder $dir"; [pscustomobject]$r; continue }
  $gen = (Get-ChildItem $dir -Filter *.cs | Sort-Object LastWriteTime | Select-Object -Last 1).LastWriteTime
  $r.Generated = $gen
  $files = Get-Content (Join-Path $dir "$f.Files.cs") -Raw
  $varying = @([regex]::Matches($files, 'm_(\w+)\.VariableRecordSize = true') | ForEach-Object { $_.Groups[1].Value })
  # The FD class is named after the record, which is usually <file>-REC; otherwise count the primary 4001 records.
  $primary4001 = @(Get-ChildItem $dir -Filter 'Fd_*.cs' | Where-Object { (Get-Content $_.FullName -Raw) -match 'new AmtVarAlpha\(4001, m_DataRecord\)' })
  $unnamed = 0
  $bad = @(foreach ($v in $varying) {
      $fd = Get-ChildItem $dir -Filter "Fd_$($v)_*.cs" | Select-Object -First 1
      if (-not $fd) { $unnamed++; continue }
      $len = [regex]::Match((Get-Content $fd.FullName -Raw), 'new AmtVarAlpha\((\d+), m_DataRecord\)').Groups[1].Value
      if ($len -ne '4001') { "$v=$len" } })
  if ($unnamed -gt $primary4001.Count) { $bad += "$unnamed input(s) without a <file>-REC record, $($primary4001.Count) record(s) of 4001" }
  $r.Check = if ($gen -lt $Since) { "FAIL generated $($gen.ToString('HH:mm')) before -Since (not regenerated?)" }
  elseif ($SkipInputCheck) { 'ok (static reference: T3-040 input check skipped)' }
  elseif ($bad) { "FAIL T3-040: varying input record not 4001 ($($bad -join ', '))" }
  else { "ok ($($varying.Count) varying input(s) at 4001)" }
  [pscustomobject]$r
}
if ($rows | Where-Object { $_.Check -like 'FAIL*' }) {
  $rows | Format-Table Program, Generated, Check -AutoSize | Out-String -Width 220 | Tee-Object $logFile
  throw 'Nothing delivered: a pre-build check failed.'
}
if ($CheckOnly) {
  $rows | Format-Table Program, Generated, Check -AutoSize | Out-String -Width 220 | Tee-Object $logFile
  return
}

& (Join-Path $PSScriptRoot '..\MockTest\Rebuild-SetAgainstRuntime.ps1') -Application $ge.LionApp -Development $Development -OutRoot $OutRoot -Programs @($rows | ForEach-Object Folder) *> "$logFile.rebuild.log"
$bin = Join-Path $OutRoot "$($ge.LionApp)\Binaries\Programs"
foreach ($r in $rows) {
  $dll = Get-Item (Join-Path $bin "$($r.Program).dll") -ErrorAction SilentlyContinue
  $r.Built = if ($dll) { $dll.LastWriteTime } else { $null }
  if (-not $dll -or $dll.LastWriteTime -lt $start) { $r.Check = "FAIL not rebuilt (see $logFile.rebuild.log)" }
}
if ($rows | Where-Object { $_.Check -like 'FAIL*' }) {
  $rows | Format-Table Program, Generated, Built, Check -AutoSize | Out-String -Width 220 | Tee-Object $logFile
  throw 'Nothing delivered: a build failed.'
}
foreach ($r in $rows) {
  $src = Join-Path $bin "$($r.Program).dll"
  Copy-Item $src $Deliver -Force
  $same = (Get-FileHash $src).Hash -eq (Get-FileHash (Join-Path $Deliver "$($r.Program).dll")).Hash
  $r.Delivered = if ($same) { 'yes, hash ok' } else { 'FAIL hash differs' }
}
$rows | Format-Table Program, Generated, Built, Check, Delivered -AutoSize | Out-String -Width 220 | Tee-Object $logFile
