# SSG-4 spike (MT-043): AFPH12's CFH-COPY step with file and use names no program knows, to prove a new name needs no rebuild.
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
$AmtSettingsFile = Join-Path $PSScriptRoot '..\..\Settings\AmtSettings.xml'

Set-Jobname "NEWNAME"
Initialize $AmtSettingsFile

Try {
  Qual "" "ASSURFED"
  Msg "" ("CFH-COPY with unknown names ZZNEWIN/ZZNEWOUT")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_CFH-COPY_ASCII" -SgsFile "P`$SGS\NEWNAME"
  Asg "A" ("ZZTESTIN")
  Use ("ZZNEWIN") "ZZTESTIN"
  Delete "C" ("ZZTESTOUT")
  Asg "P, U" ("ZZTESTOUT")
  Use ("ZZNEWOUT") "ZZTESTOUT"
  Xqt "" (".CFH-COPY")
  Free "" ("ZZTESTIN")
  Free "" ("ZZTESTOUT")
  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " $_
} Finally {
  Cleanup $false
}
