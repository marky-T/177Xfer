# SSG-4 (MT-069): the generic TABAN program on 32 cases that call EUU003, against the CC-Trial EUU003 TEST DOUBLE, one runstream-style step each (Prepare-TabanCc.ps1).
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path $PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
$AmtSettingsFile = Join-Path $PSScriptRoot '..\..\Settings\AmtSettings.xml'

# Msg ends the pending Xqt (End-Xqt runs at the next statement). A program's print goes to Prints\<date>\<Xqt name>__<time>.<FD>.PRN
# and Cleanup deletes the unprinted ones at job end (RemoveNonPrintedFiles), so copy each new one now.
function Save-GnPrints([String]$Tag) {
  Msg "" ("prints after $Tag")
  $cap = 'E:\Repos\ssg4-work\euu003-261119\dryt-new\Extracts\PRINTCAP'
  New-Item -ItemType Directory -Force $cap | Out-Null
  foreach ($f in @(Get-ChildItem ('E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Prints\' + (Get-Date -Format yyyyMMdd)) -Filter *.PRN -File -ErrorAction SilentlyContinue)) {
    if (Test-Path (Join-Path $cap $f.Name)) { continue }
    Copy-Item $f.FullName $cap
    Msg "" ("  print $Tag $($f.Name) $($f.Length)")
  }
}

Set-Jobname "TABSTUB"
Initialize $AmtSettingsFile

Try {
  Qual "" "TABSTUB"
  Msg "" ("TABAN case real-CCSA09_L340")
  Qual "D" "TBS01"
  Asg "A" ("ICCS9GCL2")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS1"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-CCSA09_L340'
  Free "" ("ICCS9GCL2")

  Msg "" ("TABAN case real-CCSA09_L474")
  Qual "D" "TBS02"
  Asg "A" ("FILIN")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS2"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-CCSA09_L474'
  Free "" ("FILIN")

  Msg "" ("TABAN case real-CCSA14_L93")
  Qual "D" "TBS03"
  Asg "A" ("R171CCSA14")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS3"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-CCSA14_L93'
  Free "" ("R171CCSA14")

  Msg "" ("TABAN case real-CCSM06_MP_L115")
  Qual "D" "TBS04"
  Asg "A" ("I196STA726")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS4"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-CCSM06_MP_L115'
  Free "" ("I196STA726")

  Msg "" ("TABAN case real-CCTA08_L241")
  Qual "D" "TBS05"
  Asg "A" ("INACCTA08")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS5"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-CCTA08_L241'
  Free "" ("INACCTA08")

  Msg "" ("TABAN case real-CCTA08_L330")
  Qual "D" "TBS06"
  Asg "A" ("INACCTA08")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS6"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-CCTA08_L330'
  Free "" ("INACCTA08")

  Msg "" ("TABAN case real-CCTA08_L382")
  Qual "D" "TBS07"
  Asg "A" ("INACCTA08")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS7"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-CCTA08_L382'
  Free "" ("INACCTA08")

  Msg "" ("TABAN case real-CCTA09_L1076")
  Qual "D" "TBS08"
  Asg "A" ("B008S604KS")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS8"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-CCTA09_L1076'
  Free "" ("B008S604KS")

  Msg "" ("TABAN case real-CCTA09_L776")
  Qual "D" "TBS09"
  Asg "A" ("B008S604CC")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS9"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-CCTA09_L776'
  Free "" ("B008S604CC")

  Msg "" ("TABAN case real-CCTA09_L842")
  Qual "D" "TBS10"
  Asg "A" ("B008S604CP")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS10"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-CCTA09_L842'
  Free "" ("B008S604CP")

  Msg "" ("TABAN case real-CGGA01_L146")
  Qual "D" "TBS11"
  Asg "A" ("INA")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS11"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-CGGA01_L146'
  Free "" ("INA")

  Msg "" ("TABAN case real-CGGA01_L76")
  Qual "D" "TBS12"
  Asg "A" ("INA")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS12"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-CGGA01_L76'
  Free "" ("INA")

  Msg "" ("TABAN case real-CLOA47_L303")
  Qual "D" "TBS13"
  Asg "A" ("IPTRESSG")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS13"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-CLOA47_L303'
  Free "" ("IPTRESSG")

  Msg "" ("TABAN case real-CLOA48_L69")
  Qual "D" "TBS14"
  Asg "A" ("ICLODEPTOT")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS14"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-CLOA48_L69'
  Free "" ("ICLODEPTOT")

  Msg "" ("TABAN case real-DEPM01_L269")
  Qual "D" "TBS15"
  Asg "A" ("FDEPMENS")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS15"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-DEPM01_L269'
  Free "" ("FDEPMENS")

  Msg "" ("TABAN case real-DEPM01_L307")
  Qual "D" "TBS16"
  Asg "A" ("FDEPANNUEL")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS16"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-DEPM01_L307'
  Free "" ("FDEPANNUEL")

  Msg "" ("TABAN case real-PAIJ01_CU_L46")
  Qual "D" "TBS17"
  Asg "A" ("INP")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS17"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-PAIJ01_CU_L46'
  Free "" ("INP")

  Msg "" ("TABAN case real-PAIJ01_CU_L87")
  Qual "D" "TBS18"
  Asg "A" ("INP")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS18"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-PAIJ01_CU_L87'
  Free "" ("INP")

  Msg "" ("TABAN case real-PAIJ01_PP_L123")
  Qual "D" "TBS19"
  Asg "A" ("R0091ML120DA")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS19"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-PAIJ01_PP_L123'
  Free "" ("R0091ML120DA")

  Msg "" ("TABAN case real-PAIJ01_PP_L88")
  Qual "D" "TBS20"
  Asg "A" ("I0091ML120C")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS20"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-PAIJ01_PP_L88'
  Free "" ("I0091ML120C")

  Msg "" ("TABAN case real-PBGA01_L244")
  Qual "D" "TBS21"
  Asg "A" ("IPBVGRTOTN")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS21"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-PBGA01_L244'
  Free "" ("IPBVGRTOTN")

  Msg "" ("TABAN case real-PBGA01_L260")
  Qual "D" "TBS22"
  Asg "A" ("IPBVGRHISN")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS22"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-PBGA01_L260'
  Free "" ("IPBVGRHISN")

  Msg "" ("TABAN case real-VIGA50_L111")
  Qual "D" "TBS23"
  Asg "A" ("INVIGA50")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS23"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-VIGA50_L111'
  Free "" ("INVIGA50")

  Msg "" ("TABAN case real-VIRA32_L108")
  Qual "D" "TBS24"
  Asg "A" ("I006TERMNXAT")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS24"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-VIRA32_L108'
  Free "" ("I006TERMNXAT")

  Msg "" ("TABAN case real-VIRA32_L147")
  Qual "D" "TBS25"
  Asg "A" ("B006TERMNUM")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS25"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-VIRA32_L147'
  Free "" ("B006TERMNUM")

  Msg "" ("TABAN case real-VIRA32_L200")
  Qual "D" "TBS26"
  Asg "A" ("B006VIRA32")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS26"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-VIRA32_L200'
  Free "" ("B006VIRA32")

  Msg "" ("TABAN case real-VIRA32_L74")
  Qual "D" "TBS27"
  Asg "A" ("I006TERMNXT")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS27"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 'real-VIRA32_L74'
  Free "" ("I006TERMNXT")

  Msg "" ("TABAN case t-neuro-range")
  Qual "D" "TBS28"
  Asg "A" ("INACCTA08")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS28"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 't-neuro-range'
  Free "" ("INACCTA08")

  Msg "" ("TABAN case t-no-neuro")
  Qual "D" "TBS29"
  Asg "A" ("I006TERMNXT")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS29"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 't-no-neuro'
  Free "" ("I006TERMNXT")

  Msg "" ("TABAN case t-one-group")
  Qual "D" "TBS30"
  Asg "A" ("FDEPMENS")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS30"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 't-one-group'
  Free "" ("FDEPMENS")

  Msg "" ("TABAN case t-seq-error")
  Qual "D" "TBS31"
  Asg "A" ("FDEPMENS")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS31"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 't-seq-error'
  Free "" ("FDEPMENS")

  Msg "" ("TABAN case t-seqerror-yes-unsorted")
  Qual "D" "TBS32"
  Asg "A" ("B006VIRA32")
  Invoke-Ssg -Options "IA" -Skeleton "../../ASSURFED_UTILIT/UTILIT_TABAN_ASCII" -SgsFile "P`$SGS\TBS32"
  Xqt "R, W" ("TPF`$.TABAN")
  Save-GnPrints 't-seqerror-yes-unsorted'
  Free "" ("B006VIRA32")

  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " $_
} Finally {
  Cleanup $false
}