<#
.SYNOPSIS
  Tier-1 refimpl for TAPELD_DISTRIB (PROGRAM-ID: CFH-COPY).
  Reads TAPEIN (fixed-length CRLF records), copies bytes verbatim to TAPEOUT.

.DESCRIPTION
  TAPELD_DISTRIB is a tape load/distribution file copy utility sharing the same
  COBOL template as CFH-COPY. In the simplified trial-17 variant (ASCII=1, DISC
  I/O, all optional params=0: FIELDIN/FIELDOUT/FIXE/PRINT/MAXCOPY/SUPCOM/REPSIM/
  STARTFIELD/STARTREC/STITRE=0) the program reduces to a pure record-for-record
  copy: READ TAPEIN -> MOVE RECIN TO RECOUT -> WRITE RECOUT AFTER 2.
  No field transforms, no FIXE, no FIELDIN/FIELDOUT — output bytes are identical
  to input bytes.
  The FINW DISPLAY statements go UPON PRINTER (stdout), not to the output file.

.PARAMETER InFile
  Path to the TAPEIN fixture file (input.dat).

.PARAMETER OutFile
  Path to write the TAPEOUT output (output.dat — must not exist before run).
#>
param(
    [Parameter(Mandatory)][string]$InFile,
    [Parameter(Mandatory)][string]$OutFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path $InFile)) {
    Write-Error "InFile not found: $InFile"
    exit 1
}

# Pure byte-for-byte copy: READ TAPEIN -> WRITE TAPEOUT (RECIN MOVE to RECOUT, no transforms).
$bytes = [System.IO.File]::ReadAllBytes($InFile)
[System.IO.File]::WriteAllBytes($OutFile, $bytes)

Write-Host "TAPELD_DISTRIB refimpl: copied $($bytes.Length) bytes from '$InFile' to '$OutFile'."
