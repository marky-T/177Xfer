# SSG-4 spike (MT-043): step LAB342 of R&D's converted ASSURFED_F999RUN_VIRM01_CO.ps1 (lines 760-770, CFH-COPY 500/135), as a Script job in AFBUS_2200COBOL_AMT.
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
$AmtSettingsFile = Join-Path $PSScriptRoot '..\..\Settings\AmtSettings.xml'

Set-Jobname "VIRM01"
Initialize $AmtSettingsFile

Try {
  Qual "" "ASSURFED"
  Asy-Label "LAB342"
  Msg "" ("RECOPIER LES ENREGISTREMENTS  D'UN FICHIER ASCII.")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_CFH-COPY_ASCII" -SgsFile "P`$SGS\VIRM01"
  Asg "A" ("I006VRM01ATT")
  Use ("INB") "I006VRM01ATT"
  Delete "C" ("I006VRM01ATC")
  Asy-Cat "P" ("I006VRM01ATC") | Out-Null
  Asg "A" ("I006VRM01ATC")
  Use ("INC") "I006VRM01ATC"
  Xqt "R, W" (".CFH-COPY")
  Free "" ("I006VRM01ATC")
  Free "" ("I006VRM01ATT")
  Time
  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " $_
} Finally {
  Cleanup $false
}
