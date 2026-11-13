# SSG-4 archive work (MT-050): parameter file for the generic ARCHISEPARE program, written from the call's SGS cards.
# Needs AMT's GetSgsValue in scope (the job session inside Invoke-Ssg, or the test harness). Fixed-column lines (250):
#   KY<chercheuse key length 5><key offset 5><unload key length 5><rsz 5>
#   TN<base 6><table 30>          FN<archive file name 30><not-archived file name 30>   (names for the report text)
# See ARCHISEPARE-GN.cob and Generic\ARCHISEPARE\spec.md.

# AMT's GetSgsValue returns $null for a missing label, silently (T3-050): stop instead.
function Get-ArcSgs([String]$Name, [Switch]$Number) {
  # AMT's SgsLabels dictionary is case-sensitive (AmtPsEclLib StartSSG) and real cards use upper-case labels (T3-054).
  $v = [String](GetSgsValue $Name.ToUpperInvariant())
  if ($v.Trim() -eq '') { Abort "SSG-4 hand-off (ARCHI): no SGS value for [$Name]" }
  if ($Number) { if ($v.Trim() -notmatch '^\d+$') { Abort "SSG-4 hand-off (ARCHI): [$Name] = '$v' is not a number" }; return [Int32]$v.Trim() }
  $v.Trim()
}

function Get-ArchisepareParmLines {
  $k1 = Get-ArcSgs 'key,1,1,2' -Number; $off = Get-ArcSgs 'key,1,2,1' -Number; $k2 = Get-ArcSgs 'key,1,2,2' -Number; $rsz = Get-ArcSgs 'rsz,1,1,1' -Number
  # the skeleton's *set b = rsz - k2 - offset would be negative: pic x(-n) in the source (case S10)
  if ($off + $k2 -gt $rsz) { Abort "SSG-4 hand-off (ARCHISEPARE): key offset $off + key length $k2 > record length $rsz" }
  if ($rsz -gt 3968) { Abort "SSG-4 hand-off (ARCHISEPARE): record length $rsz > 3968 (generic program limit)" }
  if ($k1 -gt 18 -or $k2 -gt 18 -or $k1 -lt 1 -or $k2 -lt 1) { Abort "SSG-4 hand-off (ARCHISEPARE): key lengths $k1 / $k2 outside 1..18" }
  $lines = New-Object System.Collections.Generic.List[String]
  $lines.Add('KY' + ('{0:D5}{1:D5}{2:D5}{3:D5}' -f $k1, $off, $k2, $rsz))
  $lines.Add('TN' + (Get-ArcSgs 'tname,1,1,1').PadRight(6).Substring(0, 6) + (Get-ArcSgs 'tname,1,1,2').PadRight(30).Substring(0, 30))
  $lines.Add('FN' + (Get-ArcSgs 'fileout,1,1,1').PadRight(30).Substring(0, 30) + (Get-ArcSgs 'fileout,1,2,1').PadRight(30).Substring(0, 30))
  return , $lines
}

# Called at the top of the converted ARCHISEPARE skeleton, inside R&D's Invoke-Ssg, before the runstream's Xqt. Needs
# GnHandoff.inc. The program opens ARCKEY / ARCUNL / ARCOUT / ARCNOUT; the call's own names are mapped onto them.
function Invoke-ArchisepareHandoff {
  param([String]$Program = 'ARCHISEPARE_GN', [String]$XqtName = 'ARCHISEPARE', [String]$ParmFile = 'ARSPARM')
  $lines = Get-ArchisepareParmLines
  $rsz = Get-ArcSgs 'rsz,1,1,1' -Number
  $files = @(
    @{ Fixed = 'ARCKEY'; Call = (Get-ArcSgs 'filein,1,1,1') },
    @{ Fixed = 'ARCUNL'; Call = (Get-ArcSgs 'filein,1,2,1') },
    @{ Fixed = 'ARCOUT'; Call = (Get-ArcSgs 'fileout,1,1,1'); RecSize = 32 + $rsz },
    @{ Fixed = 'ARCNOUT'; Call = (Get-ArcSgs 'fileout,1,2,1'); RecSize = $rsz }
  )
  Invoke-GnHandoff -Program $Program -XqtName $XqtName -ParmFile $ParmFile -ParmRecLen 250 -ParmLines $lines -Files $files -Label 'ARCHISEPARE'
}
