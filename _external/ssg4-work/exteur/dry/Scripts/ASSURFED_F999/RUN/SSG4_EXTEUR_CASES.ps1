# SSG-4 (MT-069): the generic EXTEUR program on 6 cases, phase 400, one runstream-style step each (Prepare-ExteurCc.ps1).

Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
$AmtSettingsFile = Join-Path $PSScriptRoot '..\..\Settings\AmtSettings.xml'

Set-Jobname "EXTTEST"
Initialize $AmtSettingsFile

Try {
  Qual "" "EXTTEST"
  Msg "" ("EXTEUR case real-VIRJ01_UL_L146")
  Qual "D" "EXT01"
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_EXTEUR" -SgsFile "P`$SGS\EXT1"
  Asg "A" ("I006FINVESTB")
  Delete "C" ("I006FINVESTC")
  Asg "P, U" ("I006FINVESTC")
  Delete "C" ("I006ANOFINVS")
  Asg "P, U" ("I006ANOFINVS")
  Use ("INA") "I006FINVESTB"
  Use ("OUTA") "I006FINVESTC"
  Use ("ANOA") "I006ANOFINVS"
  Xqt "R, W" ("TPF`$.EXTEUR")
  Free "" ("I006FINVESTB")
  Free "" ("I006FINVESTC")
  Free "" ("I006ANOFINVS")

  Msg "" ("EXTEUR case t-empty-input")
  Qual "D" "EXT02"
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_EXTEUR" -SgsFile "P`$SGS\EXT2"
  Asg "A" ("I006FINVESTB")
  Delete "C" ("I006FINVESTC")
  Asg "P, U" ("I006FINVESTC")
  Delete "C" ("I006ANOFINVS")
  Asg "P, U" ("I006ANOFINVS")
  Use ("INA") "I006FINVESTB"
  Use ("OUTA") "I006FINVESTC"
  Use ("ANOA") "I006ANOFINVS"
  Xqt "R, W" ("TPF`$.EXTEUR")
  Free "" ("I006FINVESTB")
  Free "" ("I006FINVESTC")
  Free "" ("I006ANOFINVS")

  Msg "" ("EXTEUR case t-short-records")
  Qual "D" "EXT03"
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_EXTEUR" -SgsFile "P`$SGS\EXT3"
  Asg "A" ("I006FINVESTB")
  Delete "C" ("I006FINVESTC")
  Asg "P, U" ("I006FINVESTC")
  Delete "C" ("I006ANOFINVS")
  Asg "P, U" ("I006ANOFINVS")
  Use ("INA") "I006FINVESTB"
  Use ("OUTA") "I006FINVESTC"
  Use ("ANOA") "I006ANOFINVS"
  Xqt "R, W" ("TPF`$.EXTEUR")
  Free "" ("I006FINVESTB")
  Free "" ("I006FINVESTC")
  Free "" ("I006ANOFINVS")

  Msg "" ("EXTEUR case t-long-records")
  Qual "D" "EXT04"
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_EXTEUR" -SgsFile "P`$SGS\EXT4"
  Asg "A" ("I006FINVESTB")
  Delete "C" ("I006FINVESTC")
  Asg "P, U" ("I006FINVESTC")
  Delete "C" ("I006ANOFINVS")
  Asg "P, U" ("I006ANOFINVS")
  Use ("INA") "I006FINVESTB"
  Use ("OUTA") "I006FINVESTC"
  Use ("ANOA") "I006ANOFINVS"
  Xqt "R, W" ("TPF`$.EXTEUR")
  Free "" ("I006FINVESTB")
  Free "" ("I006FINVESTC")
  Free "" ("I006ANOFINVS")

  Msg "" ("EXTEUR case t-small-values")
  Qual "D" "EXT05"
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_EXTEUR" -SgsFile "P`$SGS\EXT5"
  Asg "A" ("I006FINVESTB")
  Delete "C" ("I006FINVESTC")
  Asg "P, U" ("I006FINVESTC")
  Delete "C" ("I006ANOFINVS")
  Asg "P, U" ("I006ANOFINVS")
  Use ("INA") "I006FINVESTB"
  Use ("OUTA") "I006FINVESTC"
  Use ("ANOA") "I006ANOFINVS"
  Xqt "R, W" ("TPF`$.EXTEUR")
  Free "" ("I006FINVESTB")
  Free "" ("I006FINVESTC")
  Free "" ("I006ANOFINVS")

  Msg "" ("EXTEUR case t-two-amounts")
  Qual "D" "EXT06"
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_EXTEUR" -SgsFile "P`$SGS\EXT6"
  Asg "A" ("I006FINVESTB")
  Delete "C" ("I006FINVESTC")
  Asg "P, U" ("I006FINVESTC")
  Delete "C" ("I006ANOFINVS")
  Asg "P, U" ("I006ANOFINVS")
  Use ("INA") "I006FINVESTB"
  Use ("OUTA") "I006FINVESTC"
  Use ("ANOA") "I006ANOFINVS"
  Xqt "R, W" ("TPF`$.EXTEUR")
  Free "" ("I006FINVESTB")
  Free "" ("I006FINVESTC")
  Free "" ("I006ANOFINVS")

  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " $_
} Finally {
  Cleanup $false
}