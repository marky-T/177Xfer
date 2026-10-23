<#
.SYNOPSIS
  Stage input for, and check output of, a run of an SSG-4 program through the real Control Center (Step 8 of PROCESS.md).
.DESCRIPTION
  -Pilot  one of the 13 delivered programs (see the ValidateSet).
  -Action Stage    put the program's input files into the real Extracts folder (<NAME>.DAT). Refuses if any target or output already exists:
                   a leftover file would give a false result.
          Compare  print the Control Center status of the job (last BatchController lines, and any bug report written since it started),
                   copy the outputs to the evidence folder, then judge the output:
                     reference programs  byte-compare with the expected file (the basis is printed: independent reference, or only an earlier mock run)
                     smoke programs      no reference output exists, so only report the output sizes; a clean Done and no bug report is the result
          Clean    remove this pilot's own input and output files from Extracts (fixed names, plus their .Index files; nothing else is touched).
  Round trips: UNLOADIS_ASCII takes the indexed file the LOADIS_ASCII job wrote, UNLOADIS_MULTI the one LOADIS_MULTI wrote: run the LOADIS first.
  Names and files come from the mock tests (E:\AMT_Work\MockTest), so the real run uses exactly the data the mock run used.
.EXAMPLE
  pwsh -NoProfile -File Invoke-CcPilot.ps1 -Pilot FUSBA2_ASCII -Action Stage
  pwsh -NoProfile -File Invoke-CcPilot.ps1 -Pilot FUSBA2_ASCII -Action Compare
#>
param(
  [Parameter(Mandatory)][ValidateSet('CFH-COPY_ASCII', 'LOADIS_ASCII', 'UNLOADIS_ASCII', 'LOADIS_MULTI', 'UNLOADIS_MULTI', 'FUSBA2_ASCII', 'CHAB100_ASCII',
    'BABA_ASCII', 'CHABAN_ASCII', 'CONDIS2_ASCII', 'FUSBA_ASCII', 'LECTIS_ASCII', 'TABAN_ASCII')][String]$Pilot,
  [Parameter(Mandatory)][ValidateSet('Stage', 'Compare', 'Clean')][String]$Action,
  [String]$Extracts = 'E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Extracts',
  [String]$Logs = 'E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Logs',
  [String]$Mock = 'E:\AMT_Work\MockTest',
  [String]$Evidence = 'E:\Repos\SsgTrial\_scratch\cc-runs'
)
$ErrorActionPreference = 'Stop'
$rt = Join-Path $Mock 'Ref\LOADIS_ASCII-UNLOADIS_ASCII'
$mu = Join-Path $Mock 'Ref\LOADIS_MULTI-UNLOADIS_MULTI'
$fu = Join-Path $Mock 'Ref\FUSBA2_L766'
$ch = Join-Path $Mock 'Ref\CHAB100'
$X = { param($n) Join-Path $Extracts $n }
$indep = 'independent reference (worked out from the cards, not from the generated C#)'

# Stage: From is a file path, or a name already in Extracts when FromExtracts is set. Needs: names that must already be in Extracts (a LOADIS output).
# Smoke: made-up input files (same as the mock smoke runs). Check: Actual name in Extracts vs Expected file. Outputs: names reported only.
$defs = @{
  'CFH-COPY_ASCII' = @{
    Job   = 'ASSURFED_UTILIT_CFH_COPY_ASCII'
    Stage = @(@{ From = "$Mock\AFPH12_L427\input\INASC"; To = 'INASC.DAT' })
    Check = @{ Actual = 'OUTASC.DAT'; Expected = "$Mock\AFPH12_L427\expected\OUTASC"; Basis = $indep }
    Clean = @('INASC.DAT', 'OUTASC.DAT')
  }
  'LOADIS_ASCII' = @{
    Job   = 'ASSURFED_UTILIT_LOADIS_ASCII'
    Stage = @(@{ From = "$rt\B010SINAUTCL.bin"; To = 'B010SINAUTCL.DAT' })
    Check = @{ Actual = 'OUTCLOA49.DAT'; Expected = "$rt\loaded.dat"; Basis = 'the output of the earlier mock run (a cross-check, NOT an independent reference)' }
    Clean = @('B010SINAUTCL.DAT', 'OUTCLOA49.DAT')
  }
  'UNLOADIS_ASCII' = @{
    Job   = 'ASSURFED_UTILIT_UNLOADIS_ASCII'
    Stage = @(@{ From = 'OUTCLOA49.DAT'; FromExtracts = $true; To = 'FSCR001ATO.DAT' }, @{ From = 'OUTCLOA49.DAT.Index'; FromExtracts = $true; To = 'FSCR001ATO.DAT.Index' })
    Check = @{ Actual = 'OUT.DAT'; Expected = "$rt\expected.bin"; Basis = 'independent reference (the loaded records unchanged, in key order)' }
    Clean = @('FSCR001ATO.DAT', 'OUT.DAT')
  }
  'LOADIS_MULTI' = @{
    Job   = 'ASSURFED_UTILIT_LOADIS_MULTI'
    Stage = @(@{ From = "$mu\INVIGA50.bin"; To = 'INVIGA50.DAT' })
    Check = @{ Actual = 'F006GRS.DAT'; Expected = "$mu\loaded.dat"; Basis = 'the output of the earlier mock run (a cross-check, NOT an independent reference)' }
    Clean = @('INVIGA50.DAT', 'F006GRS.DAT')
  }
  'UNLOADIS_MULTI' = @{
    Job   = 'ASSURFED_UTILIT_UNLOADIS_MULTI'
    Needs = @('F006GRS.DAT', 'F006GRS.DAT.Index')
    Stage = @()
    Check = @{ Actual = 'OUTVIGA50.DAT'; Expected = "$mu\expected.bin"; Basis = 'independent reference (the loaded records unchanged, in key order)' }
    Clean = @('OUTVIGA50.DAT', 'F006GRS.DAT')
  }
  'FUSBA2_ASCII' = @{
    Job   = 'ASSURFED_UTILIT_FUSBA2_ASCII'
    Stage = @(@{ From = "$fu\MAJ.bin"; To = 'MAJ.DAT' }, @{ From = "$fu\INP.bin"; To = 'INP.DAT' })
    Check = @{ Actual = 'OUT.DAT'; Expected = "$fu\OUT.expected"; Basis = 'independent reference (a model of the skeleton control flow, not of the C#)' }
    Clean = @('MAJ.DAT', 'INP.DAT', 'OUT.DAT')
  }
  'CHAB100_ASCII' = @{
    Job   = 'ASSURFED_UTILIT_CHAB100_ASCII'
    Stage = @(@{ From = "$ch\CAR.cards"; To = 'CAR.DAT' })
    Check = @{ Actual = 'FILEIN.DAT'; Expected = "$ch\expected.bin"; Basis = 'expected file of the mock reference test (Ref\CHAB100); the mock run FAILED it (T3-032)' }
    Clean = @('CAR.DAT', 'FILEIN.DAT')
  }
  'BABA_ASCII'    = @{ Job = 'ASSURFED_UTILIT_BABA_ASCII';    Smoke = @(@{ Name = 'I001MSG054'; Len = 366 }); Outputs = @('I006MSG054.DAT'); Clean = @('I001MSG054.DAT', 'I006MSG054.DAT') }
  'CHABAN_ASCII'  = @{ Job = 'ASSURFED_UTILIT_CHABAN_ASCII';  Smoke = @(); Outputs = @('OUT.DAT'); Clean = @('OUT.DAT') }
  'CONDIS2_ASCII' = @{ Job = 'ASSURFED_UTILIT_CONDIS2_ASCII'; Smoke = @(); Outputs = @('FILEOUT.DAT'); Clean = @('FILEOUT.DAT') }
  'FUSBA_ASCII'   = @{ Job = 'ASSURFED_UTILIT_FUSBA_ASCII';   Smoke = @(@{ Name = 'CLE'; Len = 29 }, @{ Name = 'UNL'; Len = 296 }); Outputs = @('LOA.DAT', 'SUP.DAT'); Clean = @('CLE.DAT', 'UNL.DAT', 'LOA.DAT', 'SUP.DAT') }
  'LECTIS_ASCII'  = @{ Job = 'ASSURFED_UTILIT_LECTIS_ASCII';  Smoke = @(@{ Name = 'I008TSTA696'; Len = 80 }); Outputs = @(); Clean = @('I008TSTA696.DAT') }
  'TABAN_ASCII'   = @{ Job = 'ASSURFED_UTILIT_TABAN_ASCII';   Smoke = @(@{ Name = 'ICCS9GCL2'; Len = 300 }); Outputs = @(); Clean = @('ICCS9GCL2.DAT') }
}
$d = $defs[$Pilot]
if (-not (Test-Path $Extracts)) { throw "Not found: $Extracts" }
$smoke = @($d.Smoke | Where-Object { $_ })
$stageTo = @(@($d.Stage | Where-Object { $_ }) | ForEach-Object { $_.To }) + @($smoke | ForEach-Object { "$($_.Name).DAT" })
$outNames = @(if ($d.Check) { $d.Check.Actual }) + @($d.Outputs)

# Last BatchController lines for the job, and any bug report written at or after its last start.
function Show-JobStatus {
  $bc = Join-Path (Join-Path $Logs (Get-Date -Format 'yyyyMMdd')) 'FederaleBatchController.Log'
  $lines = @()
  if (Test-Path $bc) { $lines = @(Get-Content $bc | Where-Object { $_ -match [regex]::Escape($d.Job) -and $_ -match '(Running|Done|Fail|Abort|Error)' }) }
  if (-not $lines) { 'No BatchController line for this job today.'; return }
  $lines | Select-Object -Last 3 | ForEach-Object { ($_ -replace '\s+', ' ').Trim() }
  $startLine = @($lines | Where-Object { $_ -match 'Running Id' }) | Select-Object -Last 1
  $started = if ($startLine -match '^(\d{8})\s+(\d\d:\d\d:\d\d\.\d{3})') { [datetime]::ParseExact("$($Matches[1]) $($Matches[2])", 'yyyyMMdd HH:mm:ss.fff', $null) } else { [datetime]::MinValue }
  $rep = Join-Path (Join-Path $Logs (Get-Date -Format 'yyyyMMdd')) "$($d.Job)_BugReport.Log"
  if ((Test-Path $rep) -and (Get-Item $rep).LastWriteTime -ge $started) {
    $first = Get-Content $rep | Where-Object { $_ -match 'Exception|Message|Error' } | Select-Object -First 1
    "BUG REPORT written at {0:HH:mm:ss}: {1}" -f (Get-Item $rep).LastWriteTime, (($first -replace '\s+', ' ').Trim())
  } else { 'No new bug report.' }
}

switch ($Action) {
  'Stage' {
    $stages = @($d.Stage | Where-Object { $_ })
    $sources = @(foreach ($s in $stages) { if ($s.FromExtracts) { & $X $s.From } else { $s.From } })
    $missing = @($sources | Where-Object { -not (Test-Path $_) }) + @(@($d.Needs) | Where-Object { $_ -and -not (Test-Path (& $X $_)) } | ForEach-Object { & $X $_ })
    if ($missing) { throw "Source missing (run the LOADIS job for this round trip first): $($missing -join ', ')" }
    $stale = @(@($stageTo) + @($outNames) | Where-Object { $_ } | ForEach-Object { & $X $_ } | Where-Object { Test-Path $_ })
    if ($stale) { throw "Already in Extracts (run -Action Clean first): $($stale -join ', ')" }
    for ($i = 0; $i -lt $stages.Count; $i++) {
      Copy-Item $sources[$i] (& $X $stages[$i].To)
      '{0}: {1:N0} bytes' -f $stages[$i].To, (Get-Item (& $X $stages[$i].To)).Length
    }
    $latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
    foreach ($s in $smoke) {
      $sb = [System.Text.StringBuilder]::new()
      for ($i = 1; $i -le 5; $i++) { $sb.Append((('{0:D8}' -f $i) * [Math]::Ceiling($s.Len / 8)).Substring(0, $s.Len)).Append("`r`n") | Out-Null }
      [IO.File]::WriteAllBytes((& $X "$($s.Name).DAT"), $latin1.GetBytes($sb.ToString()))
      '{0}.DAT: made-up, 5 records of {1}' -f $s.Name, $s.Len
    }
    "Staged for $Pilot. Start job $($d.Job) in Control Center (Jobs > Start Job), then run -Action Compare."
  }
  'Compare' {
    Show-JobStatus
    $ev = Join-Path $Evidence $Pilot; New-Item -ItemType Directory -Force $ev | Out-Null
    foreach ($n in $outNames) { foreach ($f in @(Get-ChildItem $Extracts -Filter "$n*" -ErrorAction SilentlyContinue)) { Copy-Item $f.FullName $ev -Force } }
    if (-not $d.Check) {
      if (-not $outNames) { 'SMOKE: this program writes no output file; the result is the status above.'; return }
      foreach ($n in $outNames) { $p = & $X $n; if (Test-Path $p) { 'output {0}: {1:N0} bytes (no reference to compare with)' -f $n, (Get-Item $p).Length } else { "output ${n}: not written" } }
      return
    }
    $out = & $X $d.Check.Actual
    if (-not (Test-Path $out)) { "FAIL: $($d.Check.Actual) was not written to Extracts."; exit 1 }
    if (-not (Test-Path $d.Check.Expected)) { throw "Expected file missing: $($d.Check.Expected)" }
    $a = [IO.File]::ReadAllBytes($out); $b = [IO.File]::ReadAllBytes($d.Check.Expected)
    $same = ($a.Length -eq $b.Length) -and ([System.Linq.Enumerable]::SequenceEqual([byte[]]$a, [byte[]]$b))
    if ($same) { 'PASS: {0} is byte-identical ({1:N0} bytes) to the {2}.' -f $d.Check.Actual, $a.Length, $d.Check.Basis }
    else {
      $at = 0; $n = [Math]::Min($a.Length, $b.Length); while ($at -lt $n -and $a[$at] -eq $b[$at]) { $at++ }
      'FAIL: {0} is {1:N0} bytes, expected {2:N0}, first difference at byte {3}. Basis: {4}.' -f $d.Check.Actual, $a.Length, $b.Length, $at, $d.Check.Basis
      exit 1
    }
  }
  'Clean' {
    foreach ($n in $d.Clean) {
      foreach ($f in @(Get-ChildItem $Extracts -Filter "$n*" -ErrorAction SilentlyContinue)) {
        try { Remove-Item $f.FullName -Force -ErrorAction Stop; "removed $($f.Name)" } catch { "CANNOT remove $($f.Name): $($_.Exception.Message)" }
      }
    }
  }
}
