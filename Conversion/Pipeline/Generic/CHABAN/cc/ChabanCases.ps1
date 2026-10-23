# CHABAN (MT-043) test cases: case -> @{ Parm = <work>\parm\<skeleton>_<call>.parm; Lines = data images after @XQT }.
$ChabanCases = [ordered]@{
  E0  = @{ Parm = 'CHABAN_VIRA12_UL_L83'; Lines = @() }
  EN  = @{ Parm = 'CHABAN_MAPA01_L350'; Lines = @('NUM CARD IS NOT NUMB', 'SECOND') }
  B1  = @{ Parm = 'CHABAN_BSEH02_L110'; Lines = @('') }
  R4  = @{ Parm = 'CHABAN_SINM05_L190'; Lines = @((('A' * 79) + '1'), 'CARD 2 OF RECORD 1', '', (('D' * 70) + '0123456789'), 'EXTRA CARD IGNORED') }
  R22 = @{ Parm = 'CHABAN_-d_TABD53_L31'; Lines = @('REC1 CARD1', ('REC1 CARD2 ' + ('Z' * 69)), 'REC2 CARD1 THEN END OF CARDS') }
  R5  = @{ Parm = 'CHABAN_-d_VIRD50_EN_L484'; Lines = @(1..5 | ForEach-Object { "LINE $_ ".PadRight(75, '.') + ('{0:D5}' -f ($_ * 11)) }) }
  R58 = @{ Parm = 'CHABAN_COCA11_L23'; Lines = @((('0123456789' * 8) + 'TOO LONG FOR A CARD')) }
  C100 = @{ Parm = 'CHAB100_-d_EUPD01_L15'; Lines = @('PRD300403399') }
}
