<#
.SYNOPSIS
  CONDIS2 G7 (extra): does any real call have a field outside its record (input bytes p+l-1 > FILEIN length, output op+width-1 > FILEOUT length)?
  The skeleton does not check this (spec "Record layouts"); evidence that no real call reaches it. Writes <Out>\fit-check.txt.
#>
param([String]$Cards = 'E:\Repos\ssg4-work\sgs-cards', [String]$Out = 'E:\Repos\ssg4-work\redo\CONDIS2-261105_sonnet\evidence')
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\CondisModel.ps1" -LibraryOnly
$w = @{ D42 = 2; D24 = 4; D22A = 2; D22B = 2; D66A = 6; D66B = 6; D86 = 6; D68 = 8 }
$lines = New-Object System.Collections.Generic.List[String]; $bad = 0; $calls = 0
foreach ($c in (Import-Csv "$Cards\sgs-calls.csv" | Where-Object ProgramKey -eq 'CONDIS2_ASCII')) {
  $calls++
  $k = Read-CondisCards "$Cards\$($c.CardFile)"
  $id = $c.CardFile
  foreach ($g in $k.Pg) {
    foreach ($f in $g.Fields) {
      $p = [Int32]$f[0]; $l = [Int32]$f[1]
      switch ($g.Type) {
        'CASE' { if ($g.Type -eq 'CASE' -and $p + $l - 1 -gt $k.InLen) { $bad++; $lines.Add("$id CASE field $p,$l beyond input length $($k.InLen)") } }
        'MOVE' {
          $op = [Int32]$f[2]; $ow = if ($f.Count -ge 4 -and $f[3] -ne '') { $w[$f[3].ToUpperInvariant()] } else { $l }
          if ($p + $l - 1 -gt $k.InLen) { $bad++; $lines.Add("$id MOVE input $p,$l beyond input length $($k.InLen)") }
          if ($op + $ow - 1 -gt $k.OutLen) { $bad++; $lines.Add("$id MOVE output $op,$ow beyond output length $($k.OutLen)") }
          if ($p -lt 1 -or $op -lt 1) { $bad++; $lines.Add("$id MOVE position < 1") }
        }
        'CONST' { if ($p + $l - 1 -gt $k.OutLen) { $bad++; $lines.Add("$id CONST $p,$l beyond output length $($k.OutLen)") } }
      }
    }
  }
}
$summary = "Calls checked: $calls; fields outside their record: $bad"
($summary, $lines) | ForEach-Object { $_ } | Set-Content "$Out\fit-check.txt"
$summary; $lines
