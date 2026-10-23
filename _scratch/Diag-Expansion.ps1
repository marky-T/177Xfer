$here = 'E:\Repos\SsgTrial\Conversion\Pipeline'
$cards = 'E:\Repos\ssg4-work\sgs-cards'
$calls = Import-Csv "$cards\sgs-calls.csv" | Where-Object { $_.Converted -eq 'True' }
foreach ($key in 'BABA_ASCII', 'FUSBA_ASCII') {
  $call = @($calls | Where-Object ProgramKey -eq $key)[0]
  "==== $key  $($call.Runstream) line $($call.Line)  cards $($call.CardFile)"
  Get-Content (Join-Path $cards $call.CardFile)
  '---- expansion output'
  $out = pwsh -NoProfile -File "$here\Invoke-SsgExpansion.ps1" -Program $key -CardFile (Join-Path $cards $call.CardFile) -OutFile "E:\Repos\SsgTrial\_scratch\exp-$key.cob" -RunInfo "$($call.RunId),$($call.RunAccount),$($call.RunProject)" 2>&1
  "exit $LASTEXITCODE"
  $out | Select-Object -Last 25
}
