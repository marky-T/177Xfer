# SSG-4 ECL pilot (MT-043): step LAB146 (CFH-COPY) of R&D's converted ASSURFED_F999RUN_AFPH12.ps1, run as a Script job in AFBUS_2200COBOL_AMT.
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
$AmtSettingsFile = Join-Path $PSScriptRoot '..\..\Settings\AmtSettings.xml'

Set-Jobname "AFPH12"
Initialize $AmtSettingsFile

Try {
  Qual "" "ASSURFED"
  Asy-Label "LAB146"
  Msg "" ("146. CFH-COPY")
  # @ . creation fichier l=22
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_CFH-COPY_ASCII" -SgsFile "P`$SGS\AFPH12"
  Asg "A" ("IAFB011FAI")
  Use ("INASC") "IAFB011FAI"
  Delete "C" ("IAFB012FAI")
  Asg "P, U" ("IAFB012FAI")
  Use ("OUTASC") "IAFB012FAI"
  Xqt "" (".CFH-COPY")
  Free "" ("IAFB011FAI")
  Free "" ("IAFB012FAI")
  Time
  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " $_
} Finally {
  Cleanup $false
}
