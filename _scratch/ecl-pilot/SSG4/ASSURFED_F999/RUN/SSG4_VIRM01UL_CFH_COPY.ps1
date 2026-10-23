# SSG-4 ECL pilot (MT-043): step LAB110 (CFH-COPY) of R&D's converted ASSURFED_F999RUN_VIRM01_UL.ps1, run as a Script job in AFBUS_2200COBOL_AMT.
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
$AmtSettingsFile = Join-Path $PSScriptRoot '..\..\Settings\AmtSettings.xml'

Set-Jobname "VIRM01UL"
Initialize $AmtSettingsFile

Try {
  Qual "" "ASSURFED"
  Asy-Label "LAB110"
  Msg "" ("110. CFH-COPY SUR SORTIE FICHIER BABA")
  Asg "A" ("I006KTMAJ1")
  Delete "C" ("F006KTMAJ3")
  Asg "P, U" ("F006KTMAJ3")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_CFH-COPY_ASCII" -SgsFile "P`$SGS\VIRM01UL"
  Xqt "" ("TPF`$.CFH-COPY")
  Free "" ("I006KTMAJ1")
  Free "" ("F006KTMAJ3")
  Time
  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " $_
} Finally {
  Cleanup $false
}
