# SSG-4 (MT-043): parameter file for the generic BABA program, written from the call's SGS cards (spec.md).
# Needs AMT's GetSgsValue in scope (the job session inside Invoke-Ssg, or the test harness). Fixed-column lines:
#   IN<name 30><len 5>    OU<name 30><len 5> (1 or 2)    MD<mode 3: 'R  ', 'E  ', 'ALL'><seq: N none, O order, M multi>
#   KF<pos 5><len 5> (key fields, card order)            RQ<len 5><value set> (one per KEYS card, fields concatenated)

function Get-BabaKeyValue([String]$Value, [Int32]$Len) {
  if ($Value -eq 'BLANC') { $Value = '' }
  elseif ($Value.Length -ge 2 -and $Value.StartsWith("'") -and $Value.EndsWith("'")) { $Value = $Value.Substring(1, $Value.Length - 2) }
  $Value = if ($Value.Length -ge $Len) { $Value.Substring(0, $Len) } else { $Value.PadRight($Len) }
  $Value.Replace('<', ';')
}

function Get-BabaParmLines {
  param([String]$InName = ([String](GetSgsValue 'INPUT,1,1,1')), [String[]]$OutNames)
  $lines = New-Object System.Collections.Generic.List[String]
  $lines.Add('IN' + $InName.PadRight(30) + ('{0:D5}' -f [Int32](GetSgsValue 'INPUT,1,1,2')))
  $nOut = [Int32](GetSgsValue 'OUTPUT,1')
  for ($o = 1; $o -le $nOut; $o++) {
    $name = if ($OutNames -and $OutNames.Count -ge $o) { $OutNames[$o - 1] } else { [String](GetSgsValue "OUTPUT,1,$o,1") }
    $lines.Add('OU' + $name.PadRight(30) + ('{0:D5}' -f [Int32](GetSgsValue "OUTPUT,1,$o,2")))
  }
  $nKeys = [Int32](GetSgsValue 'KEYS')
  $mode = if ($nKeys -eq 0) { 'ALL' } else { ([String](GetSgsValue 'KEYS,1,1,1')).Trim().ToUpperInvariant() }
  $seqVal = if ([Int32](GetSgsValue 'SEQERROR') -gt 0) { ([String](GetSgsValue 'SEQERROR,1,1,1')).Trim().ToUpperInvariant() } else { '' }
  $seq = switch ($seqVal) { 'MULTI' { 'M' } { $_ -in 'YES', 'OUI', 'YA' } { 'O' } default { 'N' } }
  if ($mode -notin 'R', 'E', 'ALL') { throw "BABA: unsupported KEYS mode '$mode'" }
  $lines.Add('MD' + $mode.PadRight(3) + $seq)
  if ($nKeys -gt 0) {
    for ($f = 2; $f -le [Int32](GetSgsValue 'KEYS,1'); $f++) {
      $lines.Add('KF' + ('{0:D5}{1:D5}' -f [Int32](GetSgsValue "KEYS,1,$f,1"), [Int32](GetSgsValue "KEYS,1,$f,2")))
    }
    if ($mode -ne 'ALL') {
      for ($c = 1; $c -le $nKeys; $c++) {
        $set = ''
        for ($f = 2; $f -le [Int32](GetSgsValue "KEYS,$c"); $f++) {
          $set += Get-BabaKeyValue ([String](GetSgsValue "KEYS,$c,$f,3")) ([Int32](GetSgsValue "KEYS,$c,$f,2"))
        }
        $lines.Add('RQ' + ('{0:D5}' -f $set.Length) + $set)
      }
    }
  }
  return , $lines
}

# Called at the top of the converted BABA skeleton, inside R&D's Invoke-Ssg, before the runstream's Xqt. Needs
# GnHandoff.inc. The program opens only BABIN/BABOUT1/BABOUT2; the call's files are mapped onto them.
function Invoke-BabaHandoff {
  param([String]$Program = 'ASSURFED_UTILIT_BABA_GN', [String]$XqtName = 'BABA', [String]$ParmFile = 'BABPARM')
  $nOut = [Int32](GetSgsValue 'OUTPUT,1')
  $fixedOut = @(for ($o = 1; $o -le $nOut; $o++) { "BABOUT$o" })
  $files = @(@{ Fixed = 'BABIN'; Call = ([String](GetSgsValue 'INPUT,1,1,1')).Trim() }) +
    @(for ($o = 1; $o -le $nOut; $o++) { @{ Fixed = $fixedOut[$o - 1]; Call = ([String](GetSgsValue "OUTPUT,1,$o,1")).Trim(); RecSize = [Int32](GetSgsValue "OUTPUT,1,$o,2") } })
  $lines = Get-BabaParmLines -InName 'BABIN' -OutNames $fixedOut
  Invoke-GnHandoff -Program $Program -XqtName $XqtName -ParmFile $ParmFile -ParmRecLen 400 -ParmLines $lines -Files $files -Label 'BABA'
}
