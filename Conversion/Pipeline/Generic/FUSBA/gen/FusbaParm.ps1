# SSG-4 (MT-043): parameter file for the generic FUSBA program, written from the call's SGS cards (spec.md).
# Needs AMT's GetSgsValue in scope (the job session inside Invoke-Ssg, or the test harness). Fixed-column lines:
#   IN<name 30><len 5> (2: update file, master)     OU<name 30><len 5> (1 or 2)     MD<mode 1: C, D, U, M>
#   K1<pos 5><len 5> (UPDATE fields, card order)    K2<pos 5><len 5> (KEYS fields, card order)
#   FM<in pos 5><in len 5><out pos 5><out len 5> (FIELDIN i -> FIELDOUT i)

function Get-FusbaFields([String]$Label) {
  $f = @()
  if ([Int32](GetSgsValue $Label) -gt 0) {
    for ($i = 1; $i -le [Int32](GetSgsValue "$Label,1"); $i++) { $f += , @([Int32](GetSgsValue "$Label,1,$i,1"), [Int32](GetSgsValue "$Label,1,$i,2")) }
  }
  return , $f
}

function Get-FusbaParmLines {
  param([String[]]$InNames, [String[]]$OutNames, [ValidateSet('FUSBA', 'FUSBA2')][String]$Variant = 'FUSBA')
  $lines = New-Object System.Collections.Generic.List[String]
  if ([Int32](GetSgsValue 'INPUT,1') -ne 2) { throw "FUSBA: $([Int32](GetSgsValue 'INPUT,1')) input files; only 2 are supported" }
  for ($i = 1; $i -le 2; $i++) {
    $name = if ($InNames -and $InNames.Count -ge $i) { $InNames[$i - 1] } else { [String](GetSgsValue "INPUT,1,$i,1") }
    $lines.Add('IN' + $name.PadRight(30) + ('{0:D5}' -f [Int32](GetSgsValue "INPUT,1,$i,2")))
  }
  $nOut = [Int32](GetSgsValue 'OUTPUT,1')
  for ($o = 1; $o -le $nOut; $o++) {
    $name = if ($OutNames -and $OutNames.Count -ge $o) { $OutNames[$o - 1] } else { [String](GetSgsValue "OUTPUT,1,$o,1") }
    $lines.Add('OU' + $name.PadRight(30) + ('{0:D5}' -f [Int32](GetSgsValue "OUTPUT,1,$o,2")))
  }
  $upd = Get-FusbaFields 'UPDATE'
  $keys = Get-FusbaFields 'KEYS'
  if ($upd.Count -eq 0) { throw 'FUSBA: no UPDATE card (plain merge) is not supported' }
  $fin = Get-FusbaFields 'FIELDIN'
  $fout = Get-FusbaFields 'FIELDOUT'
  if ($fin.Count -ne $fout.Count) { throw "FUSBA: FIELDIN has $($fin.Count) fields, FIELDOUT $($fout.Count)" }
  $mode = if ($Variant -eq 'FUSBA2') { 'M' }
  elseif ([Int32](GetSgsValue 'ANNUL') -gt 0) { if (([String](GetSgsValue 'ANNUL,1,1,1')).Trim() -eq 'COPY') { 'C' } else { 'D' } }
  else { 'U' }
  if ($mode -eq 'C' -and $nOut -lt 2) { throw 'FUSBA: ANNUL COPY needs 2 outputs' }
  $lines.Add('MD' + $mode)
  foreach ($f in $upd) { $lines.Add('K1' + ('{0:D5}{1:D5}' -f $f[0], $f[1])) }
  foreach ($f in $keys) { $lines.Add('K2' + ('{0:D5}{1:D5}' -f $f[0], $f[1])) }
  if ($mode -in 'U', 'M') {
    for ($i = 0; $i -lt $fin.Count; $i++) { $lines.Add('FM' + ('{0:D5}{1:D5}{2:D5}{3:D5}' -f $fin[$i][0], $fin[$i][1], $fout[$i][0], $fout[$i][1])) }
  }
  return , $lines
}

# Called at the top of the converted FUSBA / FUSBA2 skeleton, inside R&D's Invoke-Ssg, before the runstream's
# @XQT TPF$.FUSBA. Needs GnHandoff.inc. The program opens only FUSIN1/FUSIN2/FUSOUT1/FUSOUT2.
function Invoke-FusbaHandoff {
  param([ValidateSet('FUSBA', 'FUSBA2')][String]$Variant = 'FUSBA', [String]$Program = 'ASSURFED_UTILIT_FUSBA_GN',
    [String]$XqtName = 'FUSBA', [String]$ParmFile = 'FUSPARM')
  $nOut = [Int32](GetSgsValue 'OUTPUT,1')
  $fixedIn = @('FUSIN1', 'FUSIN2')
  $fixedOut = @(for ($o = 1; $o -le $nOut; $o++) { "FUSOUT$o" })
  $files = @(for ($i = 1; $i -le 2; $i++) { @{ Fixed = $fixedIn[$i - 1]; Call = ([String](GetSgsValue "INPUT,1,$i,1")).Trim() } }) +
    @(for ($o = 1; $o -le $nOut; $o++) { @{ Fixed = $fixedOut[$o - 1]; Call = ([String](GetSgsValue "OUTPUT,1,$o,1")).Trim(); RecSize = [Int32](GetSgsValue "OUTPUT,1,$o,2") } })
  $lines = Get-FusbaParmLines -InNames $fixedIn -OutNames $fixedOut -Variant $Variant
  Invoke-GnHandoff -Program $Program -XqtName $XqtName -ParmFile $ParmFile -ParmRecLen 80 -ParmLines $lines -Files $files -Label $Variant
}
