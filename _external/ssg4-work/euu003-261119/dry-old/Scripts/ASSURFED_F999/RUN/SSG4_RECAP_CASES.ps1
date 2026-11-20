# SSG-4 (MT-069): the generic RECAP program on 6 cases that never call EUU003, one runstream-style step each (Prepare-RecapCc.ps1).
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
$AmtSettingsFile = Join-Path $PSScriptRoot '..\..\Settings\AmtSettings.xml'

# Msg ends the pending Xqt (End-Xqt runs at the next statement). A program's print goes to Prints\<date>\<Xqt name>__<time>.<FD>.PRN
# and Cleanup deletes the unprinted ones at job end (RemoveNonPrintedFiles), so copy each new one now.
function Save-GnPrints([String]$Tag) {
  Msg "" ("prints after $Tag")
  $cap = 'E:\Repos\ssg4-work\euu003-261119\dry-old\Extracts\PRINTCAP'
  New-Item -ItemType Directory -Force $cap | Out-Null
  foreach ($f in @(Get-ChildItem ('E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Prints\' + (Get-Date -Format yyyyMMdd)) -Filter *.PRN -File -ErrorAction SilentlyContinue)) {
    if (Test-Path (Join-Path $cap $f.Name)) { continue }
    Copy-Item $f.FullName $cap
    Msg "" ("  print $Tag $($f.Name) $($f.Length)")
  }
}

Set-Jobname "RECTEST"
Initialize $AmtSettingsFile

Try {
  Qual "" "RECTEST"
  Msg "" ("RECAP case real-RISH02_L284")
  Qual "D" "RCP01"
  Asg "A" ("ENTREE")
  Delete "C" ("SORTIE")
  Asg "P, U" ("SORTIE")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCP1"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-RISH02_L284'
  Free "" ("ENTREE")
  Free "" ("SORTIE")

  Msg "" ("RECAP case cc-ccta08-neuro-all")
  Qual "D" "RCP02"
  Asg "A" ("INACCTA08")
  Delete "C" ("OUTCCTA08")
  Asg "P, U" ("OUTCCTA08")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCP2"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'cc-ccta08-neuro-all'
  Free "" ("INACCTA08")
  Free "" ("OUTCCTA08")

  Msg "" ("RECAP case cc-cocm03-neuro-all")
  Qual "D" "RCP03"
  Asg "A" ("INA")
  Delete "C" ("OUTA")
  Asg "P, U" ("OUTA")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCP3"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'cc-cocm03-neuro-all'
  Free "" ("INA")
  Free "" ("OUTA")

  Msg "" ("RECAP case cc-mpmm03-neuro-all")
  Qual "D" "RCP04"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCP4"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'cc-mpmm03-neuro-all'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Msg "" ("RECAP case cc-vira12-neuro-all")
  Qual "D" "RCP05"
  Asg "A" ("INA")
  Delete "C" ("OUTA")
  Asg "P, U" ("OUTA")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCP5"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'cc-vira12-neuro-all'
  Free "" ("INA")
  Free "" ("OUTA")

  Msg "" ("RECAP case cc-lrst12-neuro-all")
  Qual "D" "RCP06"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCP6"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'cc-lrst12-neuro-all'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " $_
} Finally {
  Cleanup $false
}