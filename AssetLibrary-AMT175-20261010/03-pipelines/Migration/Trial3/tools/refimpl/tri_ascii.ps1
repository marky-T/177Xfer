<#
.SYNOPSIS
  Tier-1 PowerShell reference oracle for SSG-COBOL program SORT-FICHOUT-1 (TRI_ASCII).

.DESCRIPTION
  Faithful stand-in for the converted TRI_ASCII logic used as the Tier-1 golden
  executor in the SSG-COBOL -> C# proof harness. No AMT runtime required.

  Cleaned COBOL (candidates/trial-06-tri-ascii/SORT-FICHOUT-1.TXT) semantics:
    * Input:  TAPE-1 assigned to FICHIN-1, 80-char fixed records, CRLF-delimited.
    * Output: TAPEOUT assigned to FICHOUT-1, 80-char fixed records, CRLF-delimited.
    * Sort key: SORT-KEY-1 PIC X(8) at columns 1-8, ASCENDING ASCII order.
    * The AMT runtime uses SortFiles(Sortfile, Tuple<AmtVariable,AmtOrder>[], false)
      — NOT AmtAfcSortInfo (IBM DFSORT only).
    * DISPLAY ... UPON PRINTER -> sysout, not written to output file.

.PARAMETER InFile
  Path to the assigned FICHIN-1 data file (80-char fixed records, CRLF-delimited).

.PARAMETER OutFile
  Path to write the FICHOUT-1 data file (sorted, 80-char fixed records, CRLF-delimited).
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$InFile,
    [Parameter(Mandatory)][string]$OutFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RECLEN  = 80
$KEY_OFF = 0    # SORT-KEY-1 at columns 1-8 (0-based index 0)
$KEY_LEN = 8

$lines   = [IO.File]::ReadAllLines($InFile)
$records = foreach ($raw in $lines) {
    if ($raw.Length -eq 0) { continue }
    $raw.PadRight($RECLEN).Substring(0, $RECLEN)
}
$sorted  = $records | Sort-Object { $_.Substring($KEY_OFF, $KEY_LEN) }

[IO.File]::WriteAllText($OutFile, (($sorted -join "`r`n") + "`r`n"))
