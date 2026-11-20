# Check 2a (261119): what AMT's own library does with the inline merge's SORT parameter lines (VIRJ01_UL L115 etc.):
# Asy-Sort, then DataLineOrNoStatement "FILEIN=IN0 ..." as R&D's converted runstream does. Imports the Federale libraries read-only
# (no Initialize, no CC, no files touched); Add-WarningMsg / Add-ErrorMsg / Write-JobLog are captured.
$ErrorActionPreference = 'Stop'
$lib = 'E:\Repos\Federale_InternalRelease\Scripts\Libraries'
Import-Module "$lib\AmtPsEclLib.psm1" -Force -DisableNameChecking
Import-Module "$lib\AmtPsSortLib.psm1" -Force -DisableNameChecking
$global:Captured = New-Object System.Collections.Generic.List[String]
$m = Get-Module AmtPsEclLib
& $m { function script:Add-WarningMsg { param($Msg) $global:Captured.Add("WARNING: $Msg") }
       function script:Add-ErrorMsg { param($Msg) $global:Captured.Add("ERROR: $Msg") }
       function script:Write-JobLog { param($Msg, $Sev) $global:Captured.Add("LOG[$Sev]: $Msg") } }
$state = { & $m { "PreviousStatement=$($global:PreviousStatement)  SortInputFiles=$(@($global:SortInputFiles).Count)" } }
try { Asy-Sort } catch { $global:Captured.Add("Asy-Sort threw: $($_.Exception.Message)") }
$global:Captured.Add("after Asy-Sort: $(& $state)")
foreach ($line in 'FILEIN=IN0 MODE=SDF BLOCK=10', 'FILEIN=IN1 MODE=SDF BLOCK=10', 'FILEOUT=OUT   MODE=SDF BLOCK=10', 'DATA=ASCII', 'RSZ=200') {
  try { DataLineOrNoStatement $line } catch { $global:Captured.Add("DataLineOrNoStatement threw: $($_.Exception.Message)") }
}
$global:Captured.Add("after the data lines: $(& $state)")
$global:Captured
