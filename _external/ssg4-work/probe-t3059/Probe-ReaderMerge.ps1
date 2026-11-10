<#
.SYNOPSIS
  T3-059 probe: how does AMT's line-sequential reader split an input file into records for a generic program
  (input FD RECORD VARYING 1 TO 4001)? Runs the released CONDIS2_GN in the mock runtime as a plain copy and shows,
  per record read, which input lines it contains.
.DESCRIPTION
  -Lengths  the input file's line lengths, in order (e.g. 8,8,8,4,2). Line i is filled with one letter (A, B, C, ...),
            so a record that holds two lines shows two letters with the CR LF between them.
  -RecLen   FILEIN / FILEOUT length on the parameter lines (the program copies bytes 1..RecLen).
  Output: one line per record read: its content with CR/LF shown as \r \n; a summary row appended to results.csv.
#>
param([Int32[]]$Lengths = @(8, 8, 8, 8, 4, 2), [Int32]$RecLen = 8, [String]$Name = 'probe',
  [String]$Dll = 'ASSURFED_UTILIT_CONDIS2_GN.dll',
  [String]$Binaries = 'E:\AMT_Work\Rebuild177a-spike\AFBUS_2200COBOL\Binaries\Programs',
  [String]$Work = 'E:\Repos\ssg4-work\probe-t3059')
$ErrorActionPreference = 'Continue'
# A relative -Work (e.g. from mis-bound pwsh -File arguments) once wrote probe files into the repo (Trial3\8).
if (-not [IO.Path]::IsPathRooted($Work)) { throw "-Work must be an absolute path (got '$Work'). Call the script with & rather than pwsh -File when passing arrays." }
$mt = 'E:\Repos\SsgTrial\Conversion\Pipeline\MockTest'
. "$mt\MockFc.ps1"
$latin1 = [Text.Encoding]::GetEncoding('iso-8859-1')
$tmp = "$Work\$Name"; New-Item -ItemType Directory -Force $tmp | Out-Null
$letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
$in = -join (0..($Lengths.Count - 1) | ForEach-Object { ([String]$letters[$_ % 26] * $Lengths[$_]) + "`r`n" })
[IO.File]::WriteAllText("$tmp\input", $in, $latin1)
# Released CONDIS2 parameter lines (CondisParm.ps1 format), padded to 250: no condition, one plain MOVE of the whole record.
$parm = @(('FI{0:D5}' -f $RecLen), ('FO{0:D5}' -f $RecLen), 'NG', ('MV{0:D5}{1:D5}{2:D5}{3:D5}    ' -f 1, $RecLen, 1, $RecLen))
[IO.File]::WriteAllLines("$tmp\parm", [String[]]($parm | ForEach-Object { $_.PadRight(250) }), $latin1)
try {
  Start-MockFc
  $r = & "$mt\Run-ProgramCase.ps1" -Case "T3059_$Name" -Dll $Dll -Inputs @{ SGSPARM = "$tmp\parm"; FILEIN = "$tmp\input" } -KeepOutputAs FILEOUT -KeepOutputTo "$tmp\output" -Binaries $Binaries
} finally { try { Stop-MockFc } catch { } }
if (-not (Test-Path "$tmp\output")) { "no output ($($r.Result) $($r.Detail))"; return }
$out = $latin1.GetString([IO.File]::ReadAllBytes("$tmp\output"))
$bytes = $out.Length
$recs = @()
# Output record size: RecLen in CC (RECSIZE task value), 4000 in the mock (no task value, the FD size). Records can hold CR LF, so split by size.
$size = @(4000, $RecLen) | Where-Object { $bytes -gt 0 -and $bytes % ($_ + 2) -eq 0 } | Select-Object -First 1
$fixed = [Boolean]$size
if ($fixed) { for ($o = 0; $o -lt $bytes; $o += $size + 2) { $recs += $out.Substring($o, $size).TrimEnd() } } else { $recs = @($out -split "`r`n" | Select-Object -SkipLast 1) }
'{0}: lines {1} [{2}], RecLen {3}; output {4} B, records read {5} ({6}) [{7}]' -f $Name, $Lengths.Count, ($Lengths -join ','), $RecLen, $bytes, $recs.Count, $(if ($fixed) { "fixed $size+2" } else { 'split on CRLF' }), $r.Result
for ($i = 0; $i -lt $recs.Count; $i++) { '  rec {0,3}: [{1}]' -f ($i + 1), ($recs[$i] -replace "`r", '\r' -replace "`n", '\n') }
[pscustomobject]@{ Name = $Name; Lines = $Lengths.Count; Lengths = ($Lengths -join ','); RecLen = $RecLen; Records = $recs.Count; Merged = ($recs.Count -ne $Lengths.Count) } | Export-Csv "$Work\results.csv" -Append -NoTypeInformation
