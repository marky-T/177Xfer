# SSG-4 (MT-069): the generic TABAN program on 12 cases that never call EUU003, one runstream-style step each (Prepare-TabanCc.ps1).
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
$AmtSettingsFile = Join-Path $PSScriptRoot '..\..\Settings\AmtSettings.xml'

# Msg ends the pending Xqt (End-Xqt runs at the next statement). A program's print goes to Prints\<date>\<Xqt name>__<time>.<FD>.PRN
# and Cleanup deletes the unprinted ones at job end (RemoveNonPrintedFiles), so copy each new one now.
function Save-GnPrints([String]$Tag) {
  Msg "" ("prints after $Tag")
  $cap = 'E:\Repos\ssg4-work\generic\TABAN\dryrun\Extracts\PRINTCAP'
  New-Item -ItemType Directory -Force $cap | Out-Null
  foreach ($f in @(Get-ChildItem ('E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Prints\' + (Get-Date -Format yyyyMMdd)) -Filter *.PRN -File -ErrorAction SilentlyContinue)) {
    if (Test-Path (Join-Path $cap $f.Name)) { continue }
    Copy-Item $f.FullName $cap
    Msg "" ("  print $Tag $($f.Name) $($f.Length)")
  }
}

Set-Jobname "TABTEST"
Initialize $AmtSettingsFile

Try {
  Qual "" "TABTEST"
  Msg "" ("TABAN case cc-ccta08-neuro-all")
  Qual "D" "TAB01"
  Asg "A" ("INACCTA08")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TAB1"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'cc-ccta08-neuro-all'
  Free "" ("INACCTA08")

  Msg "" ("TABAN case cc-depm01-neuro-all")
  Qual "D" "TAB02"
  Asg "A" ("FDEPMENS")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TAB2"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'cc-depm01-neuro-all'
  Free "" ("FDEPMENS")

  Msg "" ("TABAN case cc-depm01-seq-error")
  Qual "D" "TAB03"
  Asg "A" ("FDEPMENS")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TAB3"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'cc-depm01-seq-error'
  Free "" ("FDEPMENS")

  Msg "" ("TABAN case cc-paij01-neuro-all")
  Qual "D" "TAB04"
  Asg "A" ("R0091ML120DA")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TAB4"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'cc-paij01-neuro-all'
  Free "" ("R0091ML120DA")

  Msg "" ("TABAN case cc-pbga01-neuro-all")
  Qual "D" "TAB05"
  Asg "A" ("IPBVGRTOTN")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TAB5"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'cc-pbga01-neuro-all'
  Free "" ("IPBVGRTOTN")

  Msg "" ("TABAN case cc-vira32-neuro-all")
  Qual "D" "TAB06"
  Asg "A" ("I006TERMNXT")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TAB6"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'cc-vira32-neuro-all'
  Free "" ("I006TERMNXT")

  Msg "" ("TABAN case t-all-spaces")
  Qual "D" "TAB07"
  Asg "A" ("INACCTA08")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TAB7"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 't-all-spaces'
  Free "" ("INACCTA08")

  Msg "" ("TABAN case t-empty-noindic")
  Qual "D" "TAB08"
  Asg "A" ("INACCTA08")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TAB8"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 't-empty-noindic'
  Free "" ("INACCTA08")

  Msg "" ("TABAN case t-long-records")
  Qual "D" "TAB09"
  Asg "A" ("FDEPMENS")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TAB9"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 't-long-records'
  Free "" ("FDEPMENS")

  Msg "" ("TABAN case t-short-records")
  Qual "D" "TAB10"
  Asg "A" ("I006TERMNXT")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TAB10"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 't-short-records'
  Free "" ("I006TERMNXT")

  Msg "" ("TABAN case t-spaces-embedded")
  Qual "D" "TAB11"
  Asg "A" ("INACCTA08")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TAB11"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 't-spaces-embedded'
  Free "" ("INACCTA08")

  Msg "" ("TABAN case t-zero-totals")
  Qual "D" "TAB12"
  Asg "A" ("FDEPMENS")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TAB12"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 't-zero-totals'
  Free "" ("FDEPMENS")

  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " $_
} Finally {
  Cleanup $false
}