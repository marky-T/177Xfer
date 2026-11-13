# SSG-4 (MT-043): parameter file for the generic SCAN program, written from the call's SGS cards (spec.md).
# Needs AMT's GetSgsValue in scope. Fixed-column lines:
#   IN<record length 5>   MN<'RECORDS READ FROM <input> = ' as the skeleton's PIC X(37)>   MX<n 10> (IF R < n)

function Get-ScanParmLines {
  foreach ($l in 'Y2K', 'NOCONT', 'INDIC') { if ($global:SgsLabels.ContainsKey($l) -and [Int32](GetSgsValue $l) -gt 0) { throw "SCAN: $l cards are not supported" } }
  $name = ([String](GetSgsValue 'INPUT,1,1,1')).Trim()
  $len = [Int32](GetSgsValue 'INPUT,1,1,2')
  if ($len -lt 1 -or $len -gt 4000) { throw "SCAN: record length $len" }
  $lines = New-Object System.Collections.Generic.List[String]
  $lines.Add('IN' + ('{0:D5}' -f $len))
  $m = "RECORDS READ FROM $name = "
  $lines.Add('MN' + $(if ($m.Length -ge 37) { $m.Substring(0, 37) } else { $m.PadRight(37) }))
  # The skeleton's only IF form in use: IF R|RECORD < n -> records 1..n-1 printed, all read (TEST-FIELDS).
  $ifs = if ($global:SgsLabels.ContainsKey('IF')) { [Int32](GetSgsValue 'IF') } else { 0 }
  if ($ifs -gt 1) { throw 'SCAN: more than one IF card is not supported' }
  if ($ifs -eq 1) {
    $f1 = ([String](GetSgsValue 'IF,1,1,1')).ToUpper(); $op = [String](GetSgsValue 'IF,1,2,1'); $n = [String](GetSgsValue 'IF,1,3,1')
    if ([Int32](GetSgsValue 'IF,1') -ne 3 -or $f1 -notin 'R', 'RECORD' -or $op -ne '<' -or $n -notmatch '^\d+$') { throw "SCAN: IF card '$f1 $op $n' is not supported (only IF R < n)" }
    $lines.Add('MX' + ('{0:D10}' -f [Int64]$n))
  }
  return , $lines
}

# Called at the top of the converted SCAN skeleton, inside R&D's Invoke-Ssg, before the runstream's @XQT TPF$.SCAN.
# Needs GnHandoff.inc. The program reads SCANIN (the call's INPUT file) and prints to PRINTER.
function Invoke-ScanHandoff {
  param([String]$Program = 'SCAN_GN', [String]$XqtName = 'SCAN', [String]$ParmFile = 'SCANPARM')
  $files = @(@{ Fixed = 'SCANIN'; Call = ([String](GetSgsValue 'INPUT,1,1,1')).Trim() })
  Invoke-GnHandoff -Program $Program -XqtName $XqtName -ParmFile $ParmFile -ParmRecLen 80 -ParmLines (Get-ScanParmLines) -Files $files -Label 'SCAN'
}
