# One-shot generator for TRI_ASCII Tier-1 fixtures.
# PROGRAM-ID: SORT-FICHOUT-1 (from SSG [OUTPUT,1,1,1]=FICHOUT-1).
# Logic: SORT SORTFILE ON ASCENDING KEY SORT-KEY-1 (PIC X(8), cols 1-8).
#        Input FICHIN-1, output FICHOUT-1. Pure ASCII ascending sort on first 8 chars.
# Input:  ZZZ.../AAA.../MMM... (80-char, Phase-14 cross-check: FICHIN-1.DAT in Extracts)
# Output: sorted ascending by first 8 chars: AAA... / MMM... / ZZZ...
$ErrorActionPreference = 'Stop'
$dir = $PSScriptRoot
function Rec([string]$s) { $s.PadRight(80) }
$in  = @( (Rec 'ZZZ'), (Rec 'AAA'), (Rec 'MMM') )
$exp = @( (Rec 'AAA'), (Rec 'MMM'), (Rec 'ZZZ') )
[IO.File]::WriteAllText((Join-Path $dir 'input.dat'),    (($in  -join "`r`n") + "`r`n"))
[IO.File]::WriteAllText((Join-Path $dir 'expected.dat'), (($exp -join "`r`n") + "`r`n"))
Write-Host ("input.dat    bytes=" + (Get-Item (Join-Path $dir 'input.dat')).Length)
Write-Host ("expected.dat bytes=" + (Get-Item (Join-Path $dir 'expected.dat')).Length)
