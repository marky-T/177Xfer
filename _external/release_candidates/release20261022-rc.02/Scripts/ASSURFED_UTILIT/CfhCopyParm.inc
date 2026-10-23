# SSG-4 spike (MT-043): parameter file for the generic CFH-COPY program, written from the call's SGS cards.
# Needs AMT's GetSgsValue in scope (the job session inside Invoke-Ssg, or the test harness).
# Fixed-column lines, one item each (see ASSURFED-UTILIT-CFH-COPY-G.cob):
#   IN<name 30><len 5>  OU<name 30><len 5>  MV<in-start 5><in-len 5><out-start 5><out-len 5>
#   FX<out-start 5><len 5><text>            SK<startrec 5>

function Get-CfhPairs([String]$Label) {
  $pairs = @()
  if (-not $global:SgsLabels.ContainsKey($Label)) { return , $pairs }
  for ($l = 1; $l -le [Int32](GetSgsValue $Label); $l++) {
    for ($f = 1; $f -le [Int32](GetSgsValue "$Label,$l"); $f++) {
      $pairs += , @([Int32](GetSgsValue "$Label,$l,$f,1"), [Int32](GetSgsValue "$Label,$l,$f,2"))
    }
  }
  return , $pairs
}

# Unquoted FIXE value: SPACE/SPACES and ZERO/ZEROS/ZEROES are figurative (VALUE SPACES / ZEROES in the skeleton).
function Get-CfhFigurative([String]$Text, [Int32]$Len) {
  if ($Text -in 'SPACE', 'SPACES') { return '' }
  if ($Text -in 'ZERO', 'ZEROS', 'ZEROES') { return '0' * $Len }
  $Text
}

function Get-CfhCopyParmLines {
  param([String]$InName = ([String](GetSgsValue 'INPUT,1,1,1')), [String]$OutName = ([String](GetSgsValue 'OUTPUT,1,1,1')))
  $lines = New-Object System.Collections.Generic.List[String]
  $lines.Add('IN' + $InName.PadRight(30) + ('{0:D5}' -f [Int32](GetSgsValue 'INPUT,1,1,2')))
  $lines.Add('OU' + $OutName.PadRight(30) + ('{0:D5}' -f [Int32](GetSgsValue 'OUTPUT,1,1,2')))
  $in = Get-CfhPairs 'FIELDIN'
  $out = Get-CfhPairs 'FIELDOUT'
  if ($in.Count -ne $out.Count) { throw "FIELDIN has $($in.Count) fields, FIELDOUT $($out.Count)" }
  for ($k = 0; $k -lt $in.Count; $k++) {
    $lines.Add('MV' + ('{0:D5}{1:D5}{2:D5}{3:D5}' -f $in[$k][0], $in[$k][1], $out[$k][0], $out[$k][1]))
  }
  # AddTo-SgsList splits a card at every space, so a quoted constant with spaces (FIXE 71,8,'        ') is lost there;
  # read FIXE from the raw card file instead when Invoke-Ssg's $SgsFilePath is in scope (T3-028).
  $cardFile = Get-Variable SgsFilePath -ValueOnly -ErrorAction SilentlyContinue
  if ($cardFile -and (Test-Path $cardFile)) {
    foreach ($card in [IO.File]::ReadAllLines($cardFile, [System.Text.Encoding]::GetEncoding(1252))) {
      if ($card -notmatch '^\s*FIXE\s') { continue }
      foreach ($m in [regex]::Matches($card.Substring($card.IndexOf('FIXE') + 4), "(\d+),(\d+),('(?:[^']|'')*'|[^\s']+)")) {
        $len = [Int32]$m.Groups[2].Value
        $text = $m.Groups[3].Value
        if ($text.StartsWith("'")) { $text = $text.Substring(1, $text.Length - 2).Replace("''", "'") } else { $text = Get-CfhFigurative $text $len }
        $text = if ($text.Length -ge $len) { $text.Substring(0, $len) } else { $text.PadRight($len) }
        $lines.Add('FX' + ('{0:D5}{1:D5}' -f [Int32]$m.Groups[1].Value, $len) + $text)
      }
    }
  } elseif ($global:SgsLabels.ContainsKey('FIXE')) {
    for ($c = 1; $c -le [Int32](GetSgsValue 'FIXE'); $c++) {
      for ($d = 1; $d -le [Int32](GetSgsValue "FIXE,$c"); $d++) {
        $len = [Int32](GetSgsValue "FIXE,$c,$d,2")
        $text = [String](GetSgsValue "FIXE,$c,$d,3")
        if ($text.Length -ge 2 -and $text.StartsWith("'") -and $text.EndsWith("'")) { $text = $text.Substring(1, $text.Length - 2) } else { $text = Get-CfhFigurative $text $len }
        $text = if ($text.Length -ge $len) { $text.Substring(0, $len) } else { $text.PadRight($len) }
        $lines.Add('FX' + ('{0:D5}{1:D5}' -f [Int32](GetSgsValue "FIXE,$c,$d,1"), $len) + $text)
      }
    }
  }
  if ($global:SgsLabels.ContainsKey('STARTREC')) { $lines.Add('SK' + ('{0:D5}' -f [Int32](GetSgsValue 'STARTREC,1,1,1'))) }
  return , $lines
}

# Called at the top of the converted CFH-COPY skeleton, inside R&D's Invoke-Ssg, before the runstream's Xqt. Needs
# GnHandoff.inc. -FixedNames: the program opens only CFHIN/CFHOUT (the -GN build); the call's own names are mapped onto them.
function Invoke-CfhCopyHandoff {
  param([String]$Program = 'ASSURFED_UTILIT_CFH_COPY_G', [String]$XqtName = 'CFH_COPY', [String]$ParmFile = 'CFHPARM', [Switch]$FixedNames)
  $callIn = ([String](GetSgsValue 'INPUT,1,1,1')).Trim()
  $callOut = ([String](GetSgsValue 'OUTPUT,1,1,1')).Trim()
  if ($FixedNames) { $inName = 'CFHIN'; $outName = 'CFHOUT' } else { $inName = $callIn; $outName = $callOut }
  $lines = Get-CfhCopyParmLines -InName $inName -OutName $outName
  $files = @(@{ Fixed = $inName; Call = $callIn }, @{ Fixed = $outName; Call = $callOut; RecSize = [Int32](GetSgsValue 'OUTPUT,1,1,2') })
  Invoke-GnHandoff -Program $Program -XqtName $XqtName -ParmFile $ParmFile -ParmRecLen 250 -ParmLines $lines -Files $files -Label 'CFH-COPY'
}
