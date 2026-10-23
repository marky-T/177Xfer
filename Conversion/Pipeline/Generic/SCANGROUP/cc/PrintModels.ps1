# Text models of the SCAN and TAPELD print files (SCAN / TAPELD spec.md): the printed lines in order, each
# cut to the print record and trimmed; blank lines and line/page control are left out (Test-CcPrints.ps1 compares
# these with the PRN file's non-blank lines; exact layout is checked against the static reference programs).
function Read-PrintModelInput([String]$File) {
  $t = [System.Text.Encoding]::GetEncoding('iso-8859-1').GetString([IO.File]::ReadAllBytes($File))
  $r = @($t -split "`r`n")
  if ($r.Count -and $r[-1] -eq '') { $r = if ($r.Count -gt 1) { $r[0..($r.Count - 2)] } else { @() } }
  return , $r
}
function Fit([String]$s, [Int32]$n) { if ($s.Length -ge $n) { $s.Substring(0, $n) } else { $s.PadRight($n) } }

# SCAN parm lines (ScanParm.ps1) + input file -> print lines (PRT-LINE is 100 bytes).
function Get-ScanModelLines([String[]]$Parm, [String]$InFile) {
  $len = [Int32]($Parm | Where-Object { $_.StartsWith('IN') }).Substring(2, 5)
  $name = ($Parm | Where-Object { $_.StartsWith('MN') }).PadRight(39).Substring(2, 37)
  $mx = @($Parm | Where-Object { $_.StartsWith('MX') }); $max = if ($mx) { [Int64]$mx[0].Substring(2, 10) } else { 0 }
  $chunks = [Math]::Ceiling($len / 100)
  $ruler = '........' + '2.........3.........4.........5.........6.........7.........8.........9.........0.........1.........2.........' + '3..'
  $out = New-Object System.Collections.Generic.List[String]
  $n = 0; $found = 0; $five = 6
  foreach ($rec in (Read-PrintModelInput $InFile)) {
    $n++
    if ($max -gt 0 -and $n -ge $max) { continue }
    $found++; $five++
    if ($five -gt 9) { $out.Add((Fit ('**' + ('{0,7}' -f $n) + '**' + $ruler) 100)); $five = 1 } else { $out.Add('**' + ('{0,7}' -f $n) + '**') }
    $area = Fit (Fit $rec $len) ($chunks * 100)
    for ($k = 0; $k -lt $chunks; $k++) { $out.Add($area.Substring($k * 100, 100)) }
  }
  $out.Add('** END SCAN **      ' + $name + ('{0,11}' -f $n) + ' RECORD MATCHING = ' + ('{0,11}' -f $found))
  return , @($out | ForEach-Object { $_.TrimEnd() } | Where-Object { $_ })
}

# TAPELD parm lines (TapeldParm.ps1) + input file -> print lines (RECOUT is the OUTPUT length).
function Get-TapeldModelLines([String[]]$Parm, [String]$InFile) {
  $in = [Int32]($Parm | Where-Object { $_.StartsWith('IN') }).Substring(2, 5)
  $ol = [Int32]($Parm | Where-Object { $_.StartsWith('OU') }).Substring(2, 5)
  $mv = @($Parm | Where-Object { $_.StartsWith('MV') } | ForEach-Object { , @([Int32]$_.Substring(2, 5), [Int32]$_.Substring(7, 5), [Int32]$_.Substring(12, 5), [Int32]$_.Substring(17, 5)) })
  $fx = @($Parm | Where-Object { $_.StartsWith('FX') } | ForEach-Object { $l = [Int32]$_.Substring(7, 5); , @([Int32]$_.Substring(2, 5), $l, $_.PadRight(12 + $l).Substring(12, $l)) })
  $st = [bool]($Parm | Where-Object { $_.StartsWith('ST') })
  $put = { param([char[]]$r, [Int32]$pos, [Int32]$len, [String]$v) $v = Fit $v $len; for ($i = 0; $i -lt $len; $i++) { $r[$pos - 1 + $i] = $v[$i] } }
  $out = New-Object System.Collections.Generic.List[String]
  $recs = Read-PrintModelInput $InFile
  $lnctr = 58; $i = 0
  while ($true) {
    if ($st -and $fx.Count -and $lnctr -gt 57) {
      $r = [char[]](' ' * $ol); foreach ($f in $fx) { & $put $r $f[0] $f[1] $f[2] }
      $out.Add(-join $r); $lnctr = 5
    }
    if ($i -ge $recs.Count) { break }
    $w = Fit $recs[$i++] $in
    $r = [char[]](' ' * $ol)
    if (-not $mv.Count) { & $put $r 1 $ol $w }
    foreach ($m in $mv) { & $put $r $m[2] $m[3] $w.Substring($m[0] - 1, $m[1]) }
    $out.Add(-join $r); $lnctr++
  }
  return , @($out | ForEach-Object { $_.TrimEnd() } | Where-Object { $_ })
}
