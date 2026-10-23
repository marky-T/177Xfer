# T3-038 bisection probe: AFPH12 pilot steps cut off at a stage given in CC's "Commandline (script) parameter".
#   0 = Initialize + Fin   1 = + Invoke-Ssg   2 = + Asg/Use (no Xqt)   3 = full AFPH12 step (+ Xqt)
#   suffix F = Initialize with the shared Scripts\Settings (AppName FEDERALE_APP) instead of the SSG4 copy
param([string]$Stage = '0')
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
$AmtSettingsFile = Join-Path $PSScriptRoot '..\..\Settings\AmtSettings.xml'
if ($Stage -match 'F') { $AmtSettingsFile = Join-Path $PSScriptRoot '..\..\..\Settings\AmtSettings.xml' }
[int]$s = 0; [void][int]::TryParse(($Stage -replace '\D', ''), [ref]$s)

Set-Jobname "AFPH12"
Initialize $AmtSettingsFile

Try {
  Msg "" ("T3-038 probe stage [$Stage] settings $AmtSettingsFile")
  if ($s -ge 1) {
    Qual "" "ASSURFED"
    Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_CFH-COPY_ASCII" -SgsFile "P`$SGS\AFPH12"
  }
  if ($s -ge 2) {
    Asg "A" ("IAFB011FAI")
    Use ("INASC") "IAFB011FAI"
    Delete "C" ("IAFB012FAI")
    Asg "P, U" ("IAFB012FAI")
    Use ("OUTASC") "IAFB012FAI"
  }
  if ($s -ge 3) {
    Xqt "" (".CFH-COPY")
  }
  if ($s -ge 2) {
    Free "" ("IAFB011FAI")
    Free "" ("IAFB012FAI")
  }
  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " $_
} Finally {
  Cleanup $false
}
