# SSG-4 (MT-043): parameter file for the generic CHABAN program, written from the call's SGS cards (spec.md).
# Needs AMT's GetSgsValue in scope. Fixed-column lines:
#   IN<name 30><card length 5>   OU<name 30><len 5>   NB<records 5><cards per record 5>

function Get-ChabanParmLines {
  param([String]$InName = 'CHAIN', [String]$OutName, [ValidateSet('CHABAN', 'CHAB100')][String]$Variant = 'CHABAN')
  $card = if ($Variant -eq 'CHAB100') { 100 } else { 80 }
  $len = [Int32](GetSgsValue 'OUTPUT,1,1,2')
  if (-not $OutName) { $OutName = ([String](GetSgsValue 'OUTPUT,1,1,1')).Trim() }
  $records = 0
  if ([Int32](GetSgsValue 'NUMB') -gt 0) {
    $records = if ([Int32](GetSgsValue 'NUMB,1,1') -gt 1) { [Int32](GetSgsValue 'NUMB,1,1,2') } else { 1 }
    if ([Int32](GetSgsValue 'NUMB') -gt 1) { throw 'CHABAN: more than one NUMB card is not supported' }
    foreach ($l in 'FLDSEL', 'MOD') { if ([Int32](GetSgsValue $l) -gt 0 -and [Int32](GetSgsValue "$l,1,1,1") -ne 0) { throw "CHABAN: $l other than 0 is not supported" } }
  }
  $lines = New-Object System.Collections.Generic.List[String]
  $lines.Add('IN' + $InName.PadRight(30) + ('{0:D5}' -f $card))
  $lines.Add('OU' + $OutName.PadRight(30) + ('{0:D5}' -f $len))
  $lines.Add('NB' + ('{0:D5}{1:D5}' -f $records, [Int32][Math]::Ceiling($len / $card)))
  return , $lines
}

# Called at the top of the converted CHABAN / CHAB100 skeleton, inside R&D's Invoke-Ssg, before the runstream's
# @XQT .CHABAN. Needs GnHandoff.inc. The program reads CHAIN (the run's data images) and writes CHAOUT.
function Invoke-ChabanHandoff {
  param([ValidateSet('CHABAN', 'CHAB100')][String]$Variant = 'CHABAN', [String]$Program = 'CHABAN_GN',
    [String]$XqtName = 'CHABAN', [String]$ParmFile = 'CHAPARM')
  $files = @(@{ Fixed = 'CHAIN'; Call = '*ACCEPT*' },
    @{ Fixed = 'CHAOUT'; Call = ([String](GetSgsValue 'OUTPUT,1,1,1')).Trim(); RecSize = [Int32](GetSgsValue 'OUTPUT,1,1,2') })
  $lines = Get-ChabanParmLines -OutName 'CHAOUT' -Variant $Variant
  Invoke-GnHandoff -Program $Program -XqtName $XqtName -ParmFile $ParmFile -ParmRecLen 80 -ParmLines $lines -Files $files -Label $Variant
}
