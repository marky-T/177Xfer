# One-shot generator for MONTANT Tier-1 fixtures.
# input.dat  = synthesized mock records (80-char fixed, CRLF-delimited).
# expected.dat = INDEPENDENTLY hand-derived golden (OS2200 zoned-decimal sign):
#   positive overpunch on trailing digit: 0={ 1=A 2=B 3=C 4=D 5=E 6=F 7=G 8=H 9=I
#   negative overpunch on trailing digit: 0=} 1=J 2=K 3=L 4=M 5=N 6=O 7=P 8=Q 9=R
# Field MONTANT1 = PIC S9(9) at cols 2-10; col1 + col11 = FILLER (space); cols12-80 unmapped (space).
# Logic proven: COMPUTE MONTANT1 = MONTANT1 * +1  => magnitude/sign preserved, re-encoded canonically.
#   000001234 (+1234, plain trailing digit = positive)  -> 00000123D
#   000099999 (+99999)                                   -> 00009999I
#   000000000 (+0)                                       -> 00000000{
#   00000004K (-42, K = negative 2)                      -> 00000004K  (round-trips)
$ErrorActionPreference = 'Stop'
$dir = $PSScriptRoot
function Rec([string]$f) { (' ' + $f + ' ').PadRight(80) }
$in  = @('000001234','000099999','000000000','00000004K') | ForEach-Object { Rec $_ }
$exp = @('00000123D','00009999I','00000000{','00000004K') | ForEach-Object { Rec $_ }
[IO.File]::WriteAllText((Join-Path $dir 'input.dat'),    (($in  -join "`r`n") + "`r`n"))
[IO.File]::WriteAllText((Join-Path $dir 'expected.dat'), (($exp -join "`r`n") + "`r`n"))
Write-Host ("input.dat   bytes=" + (Get-Item (Join-Path $dir 'input.dat')).Length)
Write-Host ("expected.dat bytes=" + (Get-Item (Join-Path $dir 'expected.dat')).Length)
Get-Content (Join-Path $dir 'expected.dat') | ForEach-Object { Write-Host ('[' + $_ + ']  len=' + $_.Length) }
