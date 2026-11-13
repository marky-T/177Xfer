# SSG-4 (MT-043): parameter file for the generic TAPELD program (a CFH-COPY to PRINTER with page titles), written from the
# call's SGS cards (spec.md). INPUT/OUTPUT/FIELDIN/FIELDOUT via GetSgsValue; FIXE from the raw card file (GnHandoff's
# Get-GnSgsCards), because AddTo-SgsList splits quoted titles at their spaces (T3-028). Fixed-column lines:
#   IN<len 5>  OU<len 5>  MV<in 5><in-len 5><out 5><out-len 5>  FX<out 5><len 5><text>  ST (STITRE: FIXE is a page title)

# One FIXE value as the skeleton's VALUE clause: 'x' -> x ('' -> '; anything after the closing quote, like the
# ';' of PBDA04_L339, is a COBOL separator); SPACE/SPACES -> VALUE SPACES; ZERO/ZEROS/ZEROES -> zeros.
function Get-TapeldFixeText([String]$Raw, [Int32]$Len) {
  if ($Raw.StartsWith("'")) { $t = $Raw.Substring(1, $Raw.LastIndexOf("'") - 1).Replace("''", "'") }
  elseif ($Raw -in 'SPACE', 'SPACES') { $t = '' }
  elseif ($Raw -in 'ZERO', 'ZEROS', 'ZEROES') { $t = '0' * $Len }
  elseif ($Raw -in 'NUM', 'ZONE') { throw "TAPELD: FIXE $Raw is not supported" }
  else { $t = $Raw }
  if ($t.Length -ge $Len) { $t.Substring(0, $Len) } else { $t.PadRight($Len) }
}

function Get-TapeldParmLines {
  param([String]$CardFile = (Get-Variable SgsFilePath -ValueOnly -ErrorAction SilentlyContinue))
  foreach ($l in 'Y2K', 'EURO', 'PRINT', 'SUPCOM', 'REPSIM', 'STARTFIELD', 'STARTREC', 'MAXCOPY') {
    if ($global:SgsLabels.ContainsKey($l) -and [Int32](GetSgsValue $l) -gt 0) { throw "TAPELD: $l cards are not supported" }
  }
  if (([String](GetSgsValue 'OUTPUT,1,1,1')).Trim() -ne 'PRINTER') { throw 'TAPELD: only OUTPUT PRINTER is supported' }
  if (([String](GetSgsValue 'INPUT,1,1,1')).Trim() -eq 'CARDREADER') { throw 'TAPELD: INPUT CARDREADER is not supported' }
  $inLen = [Int32](GetSgsValue 'INPUT,1,1,2'); $outLen = [Int32](GetSgsValue 'OUTPUT,1,1,2')
  if ($inLen -lt 1 -or $inLen -gt 4000 -or $outLen -lt 1 -or $outLen -gt 132) { throw "TAPELD: record lengths $inLen / $outLen" }
  $lines = New-Object System.Collections.Generic.List[String]
  $lines.Add('IN' + ('{0:D5}' -f $inLen))
  $lines.Add('OU' + ('{0:D5}' -f $outLen))
  $nIn = if ($global:SgsLabels.ContainsKey('FIELDIN')) { [Int32](GetSgsValue 'FIELDIN,1') } else { 0 }
  $nOut = if ($global:SgsLabels.ContainsKey('FIELDOUT')) { [Int32](GetSgsValue 'FIELDOUT,1') } else { 0 }
  if ($nIn -gt $nOut) { throw "TAPELD: FIELDIN has $nIn fields, FIELDOUT $nOut" }
  for ($i = 1; $i -le $nIn; $i++) {
    if ([Int32](GetSgsValue "FIELDIN,1,$i") -gt 2 -or [Int32](GetSgsValue "FIELDOUT,1,$i") -gt 2) { throw "TAPELD: numeric field $i (3 subfields) is not supported" }
    $is = [Int32](GetSgsValue "FIELDIN,1,$i,1"); $il = [Int32](GetSgsValue "FIELDIN,1,$i,2")
    $os = [Int32](GetSgsValue "FIELDOUT,1,$i,1"); $ol = [Int32](GetSgsValue "FIELDOUT,1,$i,2")
    if ($is + $il - 1 -gt $inLen -or $os + $ol - 1 -gt $outLen) { throw "TAPELD: field $i outside the records" }
    $lines.Add('MV' + ('{0:D5}{1:D5}{2:D5}{3:D5}' -f $is, $il, $os, $ol))
  }
  # FIXE,1 only (the skeleton's [FIXE,1,I]); with STITRE it is the page title, without it a per-record constant.
  if ($global:SgsLabels.ContainsKey('FIXE') -and [Int32](GetSgsValue 'FIXE') -gt 0) {
    if (-not ($global:SgsLabels.ContainsKey('STITRE') -and [Int32](GetSgsValue 'STITRE') -gt 0)) { throw 'TAPELD: FIXE without STITRE is not supported' }
    if (-not $CardFile -or -not (Test-Path -LiteralPath $CardFile)) { throw "TAPELD: card file not found ($CardFile)" }
    $cards = Get-GnSgsCards $CardFile 'FIXE'
    if (-not $cards.Count) { throw 'TAPELD: FIXE card not found in the card file' }
    $card = $cards[0]
    for ($k = 1; $k -lt $card.Count; $k++) {
      $s = $card[$k]
      $os = [Int32]$s[0]; $len = [Int32]$s[1]
      if ($os + $len - 1 -gt $outLen) { throw "TAPELD: FIXE $os,$len outside the output record" }
      $lines.Add('FX' + ('{0:D5}{1:D5}' -f $os, $len) + (Get-TapeldFixeText ($s[2..($s.Count - 1)] -join ',') $len))
    }
    $lines.Add('ST')
  }
  return , $lines
}

# Called at the top of the converted TAPELD skeleton, inside R&D's Invoke-Ssg, before the runstream's @XQT TPF$.
# (Check-ReportName: 'TPF$'). Needs GnHandoff.inc. The program reads TAPLIN (the call's INPUT file), prints to PRINTER.
function Invoke-TapeldHandoff {
  param([String]$Program = 'TAPELD_GN', [String]$XqtName = 'TPF$', [String]$ParmFile = 'TAPPARM')
  $files = @(@{ Fixed = 'TAPLIN'; Call = ([String](GetSgsValue 'INPUT,1,1,1')).Trim() })
  Invoke-GnHandoff -Program $Program -XqtName $XqtName -ParmFile $ParmFile -ParmRecLen 250 -ParmLines (Get-TapeldParmLines) -Files $files -Label 'TAPELD'
}
