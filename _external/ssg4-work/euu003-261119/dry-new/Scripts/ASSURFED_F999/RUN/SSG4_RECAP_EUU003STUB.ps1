# SSG-4 (MT-069): the generic RECAP program on 33 cases that call EUU003, against the CC-Trial EUU003 TEST DOUBLE, one runstream-style step each (Prepare-RecapCc.ps1).
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
$AmtSettingsFile = Join-Path $PSScriptRoot '..\..\Settings\AmtSettings.xml'

# Msg ends the pending Xqt (End-Xqt runs at the next statement). A program's print goes to Prints\<date>\<Xqt name>__<time>.<FD>.PRN
# and Cleanup deletes the unprinted ones at job end (RemoveNonPrintedFiles), so copy each new one now.
function Save-GnPrints([String]$Tag) {
  Msg "" ("prints after $Tag")
  $cap = 'E:\Repos\ssg4-work\euu003-261119\dry-new\Extracts\PRINTCAP'
  New-Item -ItemType Directory -Force $cap | Out-Null
  foreach ($f in @(Get-ChildItem ('E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Prints\' + (Get-Date -Format yyyyMMdd)) -Filter *.PRN -File -ErrorAction SilentlyContinue)) {
    if (Test-Path (Join-Path $cap $f.Name)) { continue }
    Copy-Item $f.FullName $cap
    Msg "" ("  print $Tag $($f.Name) $($f.Length)")
  }
}

Set-Jobname "RECSTUB"
Initialize $AmtSettingsFile

Try {
  Qual "" "RECSTUB"
  Msg "" ("RECAP case real-CCTA08_L287")
  Qual "D" "RCS01"
  Asg "A" ("INACCTA08")
  Delete "C" ("OUTCCTA08")
  Asg "P, U" ("OUTCCTA08")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS1"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-CCTA08_L287'
  Free "" ("INACCTA08")
  Free "" ("OUTCCTA08")

  Msg "" ("RECAP case real-CLOA35_L221")
  Qual "D" "RCS02"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS2"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-CLOA35_L221'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Msg "" ("RECAP case real-COCH02_D3_L73")
  Qual "D" "RCS03"
  Asg "A" ("INA")
  Delete "C" ("OUT")
  Asg "P, U" ("OUT")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS3"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-COCH02_D3_L73'
  Free "" ("INA")
  Free "" ("OUT")

  Msg "" ("RECAP case real-COCM03_L523")
  Qual "D" "RCS04"
  Asg "A" ("INA")
  Delete "C" ("OUTA")
  Asg "P, U" ("OUTA")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS4"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-COCM03_L523'
  Free "" ("INA")
  Free "" ("OUTA")

  Msg "" ("RECAP case real-COCM03_L585")
  Qual "D" "RCS05"
  Asg "A" ("INA")
  Delete "C" ("OUTA")
  Asg "P, U" ("OUTA")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS5"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-COCM03_L585'
  Free "" ("INA")
  Free "" ("OUTA")

  Msg "" ("RECAP case real-d_LRSD42_L113")
  Qual "D" "RCS06"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS6"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-d_LRSD42_L113'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Msg "" ("RECAP case real-d_SCTD01_L151")
  Qual "D" "RCS07"
  Asg "A" ("FILEIN")
  Delete "C" ("FILEOUT")
  Asg "P, U" ("FILEOUT")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS7"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-d_SCTD01_L151'
  Free "" ("FILEIN")
  Free "" ("FILEOUT")

  Msg "" ("RECAP case real-LRST12_L113")
  Qual "D" "RCS08"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS8"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-LRST12_L113'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Msg "" ("RECAP case real-MPMA03_L138")
  Qual "D" "RCS09"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS9"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-MPMA03_L138'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Msg "" ("RECAP case real-MPMA04_L181")
  Qual "D" "RCS10"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS10"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-MPMA04_L181'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Msg "" ("RECAP case real-MPMA04_L208")
  Qual "D" "RCS11"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS11"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-MPMA04_L208'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Msg "" ("RECAP case real-MPMM02_L198")
  Qual "D" "RCS12"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS12"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-MPMM02_L198'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Msg "" ("RECAP case real-MPMM02_L225")
  Qual "D" "RCS13"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS13"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-MPMM02_L225'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Msg "" ("RECAP case real-MPMM02_L256")
  Qual "D" "RCS14"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS14"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-MPMM02_L256'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Msg "" ("RECAP case real-MPMM03_L163")
  Qual "D" "RCS15"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS15"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-MPMM03_L163'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Msg "" ("RECAP case real-MPMM03_L194")
  Qual "D" "RCS16"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS16"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-MPMM03_L194'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Msg "" ("RECAP case real-MPMT01_L182")
  Qual "D" "RCS17"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS17"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-MPMT01_L182'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Msg "" ("RECAP case real-MPMT01_L209")
  Qual "D" "RCS18"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS18"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-MPMT01_L209'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Msg "" ("RECAP case real-SCTA02_L174")
  Qual "D" "RCS19"
  Asg "A" ("FILEIN")
  Delete "C" ("FILEOUT")
  Asg "P, U" ("FILEOUT")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS19"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-SCTA02_L174'
  Free "" ("FILEIN")
  Free "" ("FILEOUT")

  Msg "" ("RECAP case real-SCTA03_L151")
  Qual "D" "RCS20"
  Asg "A" ("FILEIN")
  Delete "C" ("FILEOUT")
  Asg "P, U" ("FILEOUT")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS20"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-SCTA03_L151'
  Free "" ("FILEIN")
  Free "" ("FILEOUT")

  Msg "" ("RECAP case real-SCTM01_L204")
  Qual "D" "RCS21"
  Asg "A" ("FILEIN")
  Delete "C" ("FILEOUT")
  Asg "P, U" ("FILEOUT")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS21"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-SCTM01_L204'
  Free "" ("FILEIN")
  Free "" ("FILEOUT")

  Msg "" ("RECAP case real-VIRA12_EN_L743")
  Qual "D" "RCS22"
  Asg "A" ("INA")
  Delete "C" ("OUTA")
  Asg "P, U" ("OUTA")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS22"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-VIRA12_EN_L743'
  Free "" ("INA")
  Free "" ("OUTA")

  Msg "" ("RECAP case real-VIRA15_EN_L691")
  Qual "D" "RCS23"
  Asg "A" ("INA")
  Delete "C" ("OUTA")
  Asg "P, U" ("OUTA")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS23"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-VIRA15_EN_L691'
  Free "" ("INA")
  Free "" ("OUTA")

  Msg "" ("RECAP case real-VIRA19_EN_L692")
  Qual "D" "RCS24"
  Asg "A" ("INA")
  Delete "C" ("OUTA")
  Asg "P, U" ("OUTA")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS24"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-VIRA19_EN_L692'
  Free "" ("INA")
  Free "" ("OUTA")

  Msg "" ("RECAP case real-VIRA29_L2_L48")
  Qual "D" "RCS25"
  Asg "A" ("I006TABPROGT")
  Delete "C" ("I006TABPROGC")
  Asg "P, U" ("I006TABPROGC")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS25"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-VIRA29_L2_L48'
  Free "" ("I006TABPROGT")
  Free "" ("I006TABPROGC")

  Msg "" ("RECAP case real-VIRM01_EN_L668")
  Qual "D" "RCS26"
  Asg "A" ("INA")
  Delete "C" ("OUTA")
  Asg "P, U" ("OUTA")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS26"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-VIRM01_EN_L668'
  Free "" ("INA")
  Free "" ("OUTA")

  Msg "" ("RECAP case real-VIRM01_L2_L49")
  Qual "D" "RCS27"
  Asg "A" ("I006TABPROGT")
  Delete "C" ("I006TABPROGC")
  Asg "P, U" ("I006TABPROGC")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS27"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 'real-VIRM01_L2_L49'
  Free "" ("I006TABPROGT")
  Free "" ("I006TABPROGC")

  Msg "" ("RECAP case t-long-records")
  Qual "D" "RCS28"
  Asg "A" ("INACCTA08")
  Delete "C" ("OUTCCTA08")
  Asg "P, U" ("OUTCCTA08")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS28"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 't-long-records'
  Free "" ("INACCTA08")
  Free "" ("OUTCCTA08")

  Msg "" ("RECAP case t-neuro-range")
  Qual "D" "RCS29"
  Asg "A" ("INACCTA08")
  Delete "C" ("OUTCCTA08")
  Asg "P, U" ("OUTCCTA08")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS29"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 't-neuro-range'
  Free "" ("INACCTA08")
  Free "" ("OUTCCTA08")

  Msg "" ("RECAP case t-no-neuro")
  Qual "D" "RCS30"
  Asg "A" ("INACCTA08")
  Delete "C" ("OUTCCTA08")
  Asg "P, U" ("OUTCCTA08")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS30"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 't-no-neuro'
  Free "" ("INACCTA08")
  Free "" ("OUTCCTA08")

  Msg "" ("RECAP case t-one-group")
  Qual "D" "RCS31"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS31"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 't-one-group'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Msg "" ("RECAP case t-short-records")
  Qual "D" "RCS32"
  Asg "A" ("INACCTA08")
  Delete "C" ("OUTCCTA08")
  Asg "P, U" ("OUTCCTA08")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS32"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 't-short-records'
  Free "" ("INACCTA08")
  Free "" ("OUTCCTA08")

  Msg "" ("RECAP case t-spaces-overlap")
  Qual "D" "RCS33"
  Asg "A" ("FICHIER1")
  Delete "C" ("FICHIER2")
  Asg "P, U" ("FICHIER2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_RECAP" -SgsFile "P`$SGS\RCS33"
  Xqt "R, W" ("TPF`$.RECAP")
  Save-GnPrints 't-spaces-overlap'
  Free "" ("FICHIER1")
  Free "" ("FICHIER2")

  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " $_
} Finally {
  Cleanup $false
}