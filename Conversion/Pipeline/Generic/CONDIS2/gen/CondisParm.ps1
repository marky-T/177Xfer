# SSG-4 (MT-043): parameter file for the generic CONDIS2 program, written from the call's SGS cards (spec.md).
# FILEIN/FILEOUT come from GetSgsValue; the PG cards are read from the raw card file (Invoke-Ssg's $SgsFilePath, GnHandoff's Get-GnSgsCards), because
# AddTo-SgsList splits double-quoted subfields at their spaces (PG CASE 74,2,''  '', T3-028). Fixed-column lines:
#   FI<len 5>  FO<len 5>  NG | CA | OT (group: none / case / otherwise)
#   TS<pos 5><len 5><value>  MV<in 5><in-len 5><out 5><out-len 5><date code 4>  CO<pos 5><len 5><value>

$script:CondisDateOut = @{ D42 = 2; D24 = 4; D22A = 2; D22B = 2; D66A = 6; D66B = 6; D86 = 6; D68 = 8 }
$script:CondisDateIn = @{ D42 = 4; D24 = 2; D22A = 2; D22B = 2; D66A = 6; D66B = 6; D86 = 8; D68 = 6 }

function Format-CondisValue([String]$Text, [Int32]$Len) {
  if ($Text.Length -gt $Len) {
    if ($Text.Substring($Len).Trim()) { throw "CONDIS2: value '$Text' longer than its field ($Len)" }
    return $Text.Substring(0, $Len)
  }
  $Text.PadRight($Len)
}

function Get-CondisParmLines {
  param([String]$CardFile = (Get-Variable SgsFilePath -ValueOnly -ErrorAction SilentlyContinue))
  if (-not $CardFile -or -not (Test-Path -LiteralPath $CardFile)) { throw "CONDIS2: card file not found ($CardFile)" }
  $inLen = [Int32](GetSgsValue 'FILEIN,1,1,1')
  $outLen = [Int32](GetSgsValue 'FILEOUT,1,1,1')
  $lines = New-Object System.Collections.Generic.List[String]
  $lines.Add('FI' + ('{0:D5}' -f $inLen))
  $lines.Add('FO' + ('{0:D5}' -f $outLen))
  $group = ''; $other = $false
  foreach ($f in (Get-GnSgsCards $CardFile 'PG')) {
    $kind = if ($f.Count -gt 1) { $f[1][0].ToUpper() } else { '' }
    $items = @()
    if ($f.Count -gt 2) { $items = $f[2..($f.Count - 1)] }
    if ($other -and $kind -in 'CASE', 'OTHERWISE') { throw "CONDIS2: PG $kind after OTHERWISE is not supported" }
    switch ($kind) {
      'CASE' {
        $lines.Add('CA'); $group = 'C'
        foreach ($s in $items) {
          $len = [Int32]$s[1]
          $lines.Add('TS' + ('{0:D5}{1:D5}' -f [Int32]$s[0], $len) + (Format-CondisValue ($s[2..($s.Count - 1)] -join ',') $len))
        }
      }
      'OTHERWISE' { $lines.Add('OT'); $group = 'O'; $other = $true }
      { $_ -in 'MOVE', 'CONST' } {
        if (-not $group) { $lines.Add('NG'); $group = 'N' }
        foreach ($s in $items) {
          $pos = [Int32]$s[0]; $len = [Int32]$s[1]
          if ($kind -eq 'CONST') { $lines.Add('CO' + ('{0:D5}{1:D5}' -f $pos, $len) + (Format-CondisValue ($s[2..($s.Count - 1)] -join ',') $len)); continue }
          $code = if ($s.Count -gt 3) { $s[3].ToUpper() } else { '' }
          $outL = $len
          if ($code) {
            if (-not $script:CondisDateIn.ContainsKey($code)) { throw "CONDIS2: unknown date code $code" }
            if ($script:CondisDateIn[$code] -ne $len) { throw "CONDIS2: $code needs a $($script:CondisDateIn[$code])-byte field, not $len" }
            $outL = $script:CondisDateOut[$code]
          }
          if ($pos + $len - 1 -gt $inLen -or [Int32]$s[2] + $outL - 1 -gt $outLen) { throw "CONDIS2: MOVE $($s -join ',') outside the records ($inLen/$outLen)" }
          $lines.Add('MV' + ('{0:D5}{1:D5}{2:D5}{3:D5}' -f $pos, $len, [Int32]$s[2], $outL) + $code.PadRight(4))
        }
      }
      default { throw "CONDIS2: PG card '$kind' is not CASE/MOVE/CONST/OTHERWISE" }
    }
  }
  return , $lines
}

# Called at the top of the converted CONDIS2 skeleton, inside R&D's Invoke-Ssg, before the runstream's @XQT TPF$.CONDIS2.
# Needs GnHandoff.inc. The program opens the skeleton's own names FILEIN / FILEOUT, so no aliases.
function Invoke-CondisHandoff {
  param([String]$Program = 'ASSURFED_UTILIT_CONDIS2_GN', [String]$XqtName = 'CONDIS2', [String]$ParmFile = 'CONPARM')
  $lines = Get-CondisParmLines
  $files = @(@{ Fixed = 'FILEIN'; Call = 'FILEIN' }, @{ Fixed = 'FILEOUT'; Call = 'FILEOUT'; RecSize = [Int32](GetSgsValue 'FILEOUT,1,1,1') })
  Invoke-GnHandoff -Program $Program -XqtName $XqtName -ParmFile $ParmFile -ParmRecLen 250 -ParmLines $lines -Files $files -Label 'CONDIS2'
}
