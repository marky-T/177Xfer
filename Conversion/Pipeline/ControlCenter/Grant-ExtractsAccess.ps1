<#
.SYNOPSIS
  Run ONCE from an elevated shell: let the user MTRUMAN modify files in the Control Center Extracts folder, including files the jobs create later.
.DESCRIPTION
  Jobs write their outputs as the service account, so an unelevated shell cannot delete them, which blocks re-runs. This grants Modify on the
  Extracts folder only (inherited by files created afterwards, and applied to the files already there). Nothing else is changed.
#>
param(
  [String]$Extracts = 'E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Extracts',
  [String]$Account = 'VMFEDPE08\MTRUMAN'
)
$ErrorActionPreference = 'Stop'
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrators')) { throw 'Run this from an elevated shell.' }
icacls $Extracts /grant "${Account}:(OI)(CI)M" /T /C | Select-Object -Last 3
'Done. New files created by the jobs in this folder are now modifiable by ' + $Account
