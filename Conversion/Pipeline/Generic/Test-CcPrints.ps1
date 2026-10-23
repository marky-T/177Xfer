<#
.SYNOPSIS
  SSG-4: check the print files (Basepaths\Prints\<date>\*.PRN, UTF-16) a Control Center job wrote after -After.
.DESCRIPTION
  -Cases: JSON list, in job step order, of { Case, Ref (true if a static reference program printed right after the
  generic one), Model (text file of the expected non-blank lines) }. The job's PRN files are taken in time order and
  assigned to the cases in that order (generic, then reference when Ref). Per case:
    generic PRN == reference PRN byte for byte (exact layout, page and line control), and
    generic PRN's non-blank lines (trailing spaces removed, form feeds dropped) == the model lines.
  Copies the PRN files to -Evidence and writes check.txt there. Exit code = number of failures.
.EXAMPLE
  Test-CcPrints.ps1 -After 'SSG4_SCANGRP_PRINTS: started 2026-10-21 10:00:00' -Cases <GenericWork>\SCANGROUP\cc-prints.json -Evidence <GenericWork>\SCANGROUP\cc-runs
#>
param(
  [Parameter(Mandatory)][String]$After,
  [Parameter(Mandatory)][String]$Cases,
  [Parameter(Mandatory)][String]$Evidence,
  [String]$Environment = 'CC-Trial',
  [String]$Prints,
  # Folder the job copied its PRN files to (a script job's unprinted PRN files are deleted at job end); default Prints\<date>.
  [String]$Folder
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\GnEnvironment.ps1"
if (-not $Prints) { $Prints = (Get-GnEnvironment $Environment).PrintPath }
$m = [regex]::Match($After, '\d{4}-\d{2}-\d{2} \d{2}:\d{2}(:\d{2})?')
if (-not $m.Success) { throw "-After: no time in '$After'" }
$since = [DateTime]::Parse($m.Value).AddSeconds(-2)
New-Item -ItemType Directory -Force $Evidence | Out-Null
$list = @(Get-Content $Cases -Raw | ConvertFrom-Json)
if (-not $Folder) { $Folder = Join-Path $Prints ('{0:yyyyMMdd}' -f $since) }
$prn = @(Get-ChildItem $Folder -Filter *.PRN -File -ErrorAction SilentlyContinue | Where-Object LastWriteTime -ge $since | Sort-Object LastWriteTime, Name)
$need = ($list | ForEach-Object { if ($_.Ref) { 2 } else { 1 } } | Measure-Object -Sum).Sum
$report = [System.Collections.Generic.List[String]]::new()
$fail = 0
$report.Add("PRN files since $($since.ToString('HH:mm:ss')): $($prn.Count), expected $need")
if ($prn.Count -ne $need) { $fail++; $prn | ForEach-Object { $report.Add("  $($_.Name)") } }
# A page break is written as CR FF before the line (no LF), so CR, LF and FF all end a line.
function Get-PrintLines([String]$f) { @([IO.File]::ReadAllText($f, [System.Text.Encoding]::Unicode) -split "[\r\n\f]" | ForEach-Object { $_.TrimEnd() } | Where-Object { $_ }) }
$k = 0
foreach ($c in $list) {
  if ($k -ge $prn.Count) { $report.Add("$($c.Case): no print file"); $fail++; continue }
  $gn = $prn[$k++]; Copy-Item $gn.FullName (Join-Path $Evidence "$($c.Case)-GN-$($gn.Name)") -Force
  $res = @()
  if ($c.Ref) {
    if ($k -ge $prn.Count) { $res += 'reference: no print file'; $fail++ }
    else {
      $ref = $prn[$k++]; Copy-Item $ref.FullName (Join-Path $Evidence "$($c.Case)-REF-$($ref.Name)") -Force
      if ([Linq.Enumerable]::SequenceEqual([IO.File]::ReadAllBytes($gn.FullName), [IO.File]::ReadAllBytes($ref.FullName))) { $res += "== reference ($($gn.Length) bytes)" }
      else { $res += "DIFFERS from reference ($($gn.Name) $($gn.Length) / $($ref.Name) $($ref.Length) bytes)"; $fail++ }
    }
  }
  if ($c.Model) {
    $a = Get-PrintLines $gn.FullName; $e = @(Get-Content $c.Model -Encoding Latin1)
    $d = @(for ($i = 0; $i -lt [Math]::Max($a.Count, $e.Count); $i++) { $x = if ($i -lt $e.Count) { $e[$i] } else { '<none>' }; $y = if ($i -lt $a.Count) { $a[$i] } else { '<none>' }; if ($x -cne $y) { "line $($i + 1): model [$x] print [$y]" } })
    if ($d) { $res += "model: $($d.Count) line(s) differ; first $($d[0])"; $fail++ } else { $res += "model: $($a.Count) lines match" }
  }
  $report.Add("$($c.Case): $($res -join '; ')")
}
$report.Add("=== prints: $(if ($fail) { "$fail problem(s)" } else { 'all checks passed' })")
$report | Set-Content (Join-Path $Evidence 'check.txt')
$report
exit $fail
