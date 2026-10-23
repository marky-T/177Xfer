<#
.SYNOPSIS
  Spike fallback (MT-043): generate ASSURFED-UTILIT-CFH-COPY-GF, the generic CFH-COPY with one SELECT per known file name
  (the closed list used by the 47 real calls) instead of a run-time ASSIGN. Same logic as -G; it only differs in how the
  input and output files are opened. Built in the same LionDev round so a failing data-name ASSIGN does not cost a second round.
  -InNames CFHIN -OutNames CFHOUT -ProgramId ASSURFED-UTILIT-CFH-COPY-GN gives the name-free program: the hand-off maps
  the call's real files onto those two names at run time, so a new file name needs no rebuild.
#>
param(
  [String]$Environment = 'CC-Trial',
  [String]$Inventory,
  [String]$Template = "$PSScriptRoot\ASSURFED-UTILIT-CFH-COPY-G.cob",
  [String]$OutFile = "$PSScriptRoot\ASSURFED-UTILIT-CFH-COPY-GN.cob",
  [String]$ProgramId = 'ASSURFED-UTILIT-CFH-COPY-GN',
  [String[]]$InNames = @('CFHIN'),
  [String[]]$OutNames = @('CFHOUT')
)
$ErrorActionPreference = 'Stop'
if (-not $Inventory) { . "$(Split-Path (Split-Path $PSScriptRoot))\GnEnvironment.ps1"; $Inventory = "$((Get-GnEnvironment $Environment).GenericWork)\CFH-COPY\inventory.csv" }
$inv = Import-Csv $Inventory
$ins = @(if ($InNames) { $InNames } else { $inv.InName | Where-Object { $_ } | Sort-Object -Unique })
$outs = @(if ($OutNames) { $OutNames } else { $inv.OutName | Where-Object { $_ } | Sort-Object -Unique })
$t = Get-Content $Template

$sel = @(); $fd = @(); $openIn = @(); $openOut = @(); $readIn = @(); $writeOut = @(); $closeIn = @(); $closeOut = @()
for ($k = 0; $k -lt $ins.Count; $k++) {
  $n = $k + 1
  $sel += "           SELECT FI$n ASSIGN TO DISC $($ins[$k])."
  $fd += "       FD  FI$n", '           LABEL RECORD STANDARD', '           RECORD VARYING IN SIZE FROM 1 TO 4001', '           DEPENDING ON WS-IN-LEN.', "       01  FI$n-REC PIC X(4001)."
  $openIn += "       OI-$n.", "           OPEN INPUT FI$n.", '           GO TO OI-END.'
  $readIn += "       RD-$n.", "           READ FI$n INTO RECIN AT END GO TO FINW.", '           GO TO RD-END.'
  $closeIn += "       CI-$n.", "           CLOSE FI$n.", '           GO TO CI-END.'
}
for ($k = 0; $k -lt $outs.Count; $k++) {
  $n = $k + 1
  $sel += "           SELECT FO$n ASSIGN TO DISC $($outs[$k])."
  # Output length comes from task value RECSIZE<name> set by the hand-off; a VARYING FD would override it with the layout size.
  $fd += "       FD  FO$n", '           LABEL RECORD STANDARD.', "       01  FO$n-REC PIC X(4000)."
  $openOut += "       OO-$n.", "           OPEN OUTPUT FO$n.", '           GO TO OO-END.'
  $writeOut += "       WR-$n.", "           WRITE FO$n-REC FROM RECOUT.", '           GO TO WR-END.'
  $closeOut += "       CO-$n.", "           CLOSE FO$n.", '           GO TO CO-END.'
}
function GoDep([String]$prefix, [Int32]$count, [String]$var) {
  $names = @(1..$count | ForEach-Object { "$prefix$_" })
  $lines = @("           GO TO")
  for ($i = 0; $i -lt $names.Count; $i += 5) { $lines += '                 ' + ($names[$i..([Math]::Min($i + 4, $names.Count - 1))] -join ' ') }
  $lines += "             DEPENDING ON $var."
  $lines
}
$nameTab = @('       01  IN-NAMES-V.') + ($ins | ForEach-Object { "           03 FILLER PIC X(30) VALUE '$($_)'." }) +
  @("       01  IN-NAMES REDEFINES IN-NAMES-V.", "           03 IN-NM PIC X(30) OCCURS $($ins.Count).") +
  @('       01  OUT-NAMES-V.') + ($outs | ForEach-Object { "           03 FILLER PIC X(30) VALUE '$($_)'." }) +
  @("       01  OUT-NAMES REDEFINES OUT-NAMES-V.", "           03 OUT-NM PIC X(30) OCCURS $($outs.Count).",
    '       77  IX-IN              PIC 9(3) COMP VALUE 0.', '       77  IX-OUT             PIC 9(3) COMP VALUE 0.')

$r = New-Object System.Collections.Generic.List[String]
$mode = ''
foreach ($line in $t) {
  if ($line -match "PROGRAM-ID") { $r.Add("       PROGRAM-ID. '$ProgramId'."); continue }
  if ($line -match 'SELECT TAPEIN ASSIGN') { $sel | ForEach-Object { $r.Add($_) }; continue }
  if ($line -match 'SELECT TAPEOUT ASSIGN') { continue }
  if ($line -match '^\s+FD\s+TAPEIN') { $mode = 'skipfd'; $fd | ForEach-Object { $r.Add($_) }; continue }
  if ($mode -eq 'skipfd') { if ($line -match 'WORKING-STORAGE') { $mode = ''; $r.Add($line); $r.Add('       01  RECIN              PIC X(4001).'); $r.Add('       01  RECOUT             PIC X(4000).'); $nameTab | ForEach-Object { $r.Add($_) } }; continue }
  if ($line -match '^\s+OPEN INPUT TAPEIN\.') {
    'MOVE 1 TO IX-IN.', 'MOVE 1 TO IX-OUT.' | ForEach-Object { $r.Add("           $_") }
    $r.Add('       FIND-IN.'); $r.Add("           IF IX-IN > $($ins.Count) GO TO FINW."); $r.Add('           IF IN-NM (IX-IN) = WS-INNAME GO TO FIND-OUT.'); $r.Add('           ADD 1 TO IX-IN.'); $r.Add('           GO TO FIND-IN.')
    $r.Add('       FIND-OUT.'); $r.Add("           IF IX-OUT > $($outs.Count) GO TO FINW."); $r.Add('           IF OUT-NM (IX-OUT) = WS-OUTNAME GO TO OPEN-FILES.'); $r.Add('           ADD 1 TO IX-OUT.'); $r.Add('           GO TO FIND-OUT.')
    $r.Add('       OPEN-FILES.'); GoDep 'OI-' $ins.Count 'IX-IN' | ForEach-Object { $r.Add($_) }; $openIn | ForEach-Object { $r.Add($_) }; $r.Add('       OI-END.')
    GoDep 'OO-' $outs.Count 'IX-OUT' | ForEach-Object { $r.Add($_) }; $openOut | ForEach-Object { $r.Add($_) }; $r.Add('       OO-END.')
    continue
  }
  if ($line -match '^\s+OPEN OUTPUT TAPEOUT\.') { continue }
  if ($line -match '^\s+READ TAPEIN AT END GO TO FINW\.') { GoDep 'RD-' $ins.Count 'IX-IN' | ForEach-Object { $r.Add($_) }; $readIn | ForEach-Object { $r.Add($_) }; $r.Add('       RD-END.'); continue }
  if ($line -match '^\s+WRITE RECOUT\.') { GoDep 'WR-' $outs.Count 'IX-OUT' | ForEach-Object { $r.Add($_) }; $writeOut | ForEach-Object { $r.Add($_) }; $r.Add('       WR-END.'); continue }
  if ($line -match '^\s+MOVE WS-OUT TO RECOUT\.') { $r.Add($line); continue }
  if ($line -match '^\s+CLOSE\s+TAPEIN\.') { $r.Add('           IF IX-IN > ' + $ins.Count + ' GO TO CI-END.'); GoDep 'CI-' $ins.Count 'IX-IN' | ForEach-Object { $r.Add($_) }; $closeIn | ForEach-Object { $r.Add($_) }; $r.Add('       CI-END.'); continue }
  if ($line -match '^\s+CLOSE\s+TAPEOUT\.') { $r.Add('           IF IX-OUT > ' + $outs.Count + ' GO TO CO-END.'); GoDep 'CO-' $outs.Count 'IX-OUT' | ForEach-Object { $r.Add($_) }; $closeOut | ForEach-Object { $r.Add($_) }; $r.Add('       CO-END.'); continue }
  $r.Add($line)
}
[IO.File]::WriteAllLines($OutFile, $r)
"written $OutFile ($($r.Count) lines): $($ins.Count) input names, $($outs.Count) output names"
