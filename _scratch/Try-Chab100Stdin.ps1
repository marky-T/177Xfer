Import-Module E:\Repos\SsgTrial\Conversion\Pipeline\MockTest\MockTestLib.psm1 -Force -DisableNameChecking
$c = Get-SetCalls | Where-Object Key -eq 'CHAB100_ASCII'
$cards = @(Get-DataCards $c.Runstream $c.Line)
$d = 'E:\AMT_Work\MockTest\Ref\CHAB100'
Start-MockFc
try {
  & E:\Repos\SsgTrial\Conversion\Pipeline\MockTest\Run-ProgramCase.ps1 -Case 'TRY_CHAB100_STDIN' -Dll $c.Dll -Inputs @{} -StdinLines $cards -ExpectedName 'FILEIN' -ExpectedFile "$d\expected.bin"
  Get-ChildItem E:\AMT_Work\MockTest\Extracts | Select-Object Name, Length
  Get-Content E:\AMT_Work\MockSystem\case_TRY_CHAB100_STDIN.log | Select-Object -Last 8
} finally { Stop-MockFc }
