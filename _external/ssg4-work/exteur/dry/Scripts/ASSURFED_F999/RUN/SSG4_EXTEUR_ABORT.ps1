# SSG-4 (MT-069): EXTEUR abort cases (currency error, overflow); the job must end in error (Prepare-ExteurCc.ps1).
param([ValidateSet('CURRENCY', 'OVERFLOW')][String]$Case = 'CURRENCY')
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
$AmtSettingsFile = Join-Path $PSScriptRoot '..\..\Settings\AmtSettings.xml'

Set-Jobname "EXTABRT"
Initialize $AmtSettingsFile

Try {
  Qual "" "EXTABRT"
  if ($Case -eq 'CURRENCY') {
    Msg "" ("EXTEUR-ABORT case CURRENCY")
    Qual "D" "EXAC"
    Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_EXTEUR" -SgsFile "P`$SGS\EXAC"
    Asg "A" ("I006FINVESTB")
    Delete "C" ("I006FINVESTC")
    Asg "P, U" ("I006FINVESTC")
    Delete "C" ("I006ANOFINVS")
    Asg "P, U" ("I006ANOFINVS")
    Use ("INA") "I006FINVESTB"
    Use ("OUTA") "I006FINVESTC"
    Use ("ANOA") "I006ANOFINVS"
    Xqt "R, W" ("TPF`$.EXTEUR")
  }
  if ($Case -eq 'OVERFLOW') {
    Msg "" ("EXTEUR-ABORT case OVERFLOW")
    Qual "D" "EXAO"
    Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_EXTEUR" -SgsFile "P`$SGS\EXAO"
    Asg "A" ("I006FINVESTB")
    Delete "C" ("I006FINVESTC")
    Asg "P, U" ("I006FINVESTC")
    Delete "C" ("I006ANOFINVS")
    Asg "P, U" ("I006ANOFINVS")
    Use ("INA") "I006FINVESTB"
    Use ("OUTA") "I006FINVESTC"
    Use ("ANOA") "I006ANOFINVS"
    Xqt "R, W" ("TPF`$.EXTEUR")
  }
  Msg "" ("EXTEUR-ABORT case $Case NOT STOPPED")
  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " $_
} Finally {
  Cleanup $false
}