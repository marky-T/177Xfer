<#
.SYNOPSIS
  Tier-1 refimpl for CFH-COPY.
  Reads TAPEIN (fixed-length CRLF records), copies bytes verbatim to TAPEOUT.

.DESCRIPTION
  CFH-COPY is a general-purpose file copy utility. In the simplified trial-11
  variant (all optional params = 0, ASCII mode, 80-char records) it performs
  a pure record-for-record copy: READ TAPEIN -> MOVE RECIN TO RECOUT -> WRITE RECOUT.
  No field transforms, no FIXE, no FIELDIN/FIELDOUT — output bytes are identical
  to input bytes. The FINW DISPLAY statements go UPON PRINTER (stdout), not to
  the output file.

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

Write-Host "CFH-COPY refimpl: copied $($bytes.Length) bytes from '$InFile' to '$OutFile'."
