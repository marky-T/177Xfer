. E:\Repos\SsgTrial\Conversion\Pipeline\MockTest\MockFc.ps1
Start-MockFc
$d = 'E:\AMT_Work\MockTest\Ref\LOADIS_UNLOADIS'
& E:\Repos\SsgTrial\Conversion\Pipeline\MockTest\Run-ProgramCase.ps1 -Case 'DBG_LOADIS' -Dll 'ASSURFED_UTILIT_LOADIS_ASCII.dll' -Inputs @{ B010SINAUTCL = "$d\B010SINAUTCL.bin" } -KeepOutputAs 'OUTCLOA49' -KeepOutputTo "$d\dbg-loaded.dat" | Format-List | Out-String
Get-Content E:\AMT_Work\MockSystem\case_DBG_LOADIS.log
Get-ChildItem E:\AMT_Work\MockTest\Extracts | Select-Object Name, Length | Format-Table -AutoSize | Out-String
Stop-MockFc
