$rep = [System.IO.File]::ReadAllLines('C:\Amt\Migration\EclCobolPipeline\fixtures\archiformat\fic-report.dat')
Write-Host "rep count: $($rep.Count)  len[0]: $($rep[0].Length)  len[4]: $($rep[4].Length)"
Write-Host "Line1 pos4-24: [$($rep[0].Substring(3,21))]"
Write-Host "Line2 pos7-8:[$($rep[1].Substring(6,2))] 10-11:[$($rep[1].Substring(9,2))] 13-14:[$($rep[1].Substring(12,2))]"
Write-Host "Line5 Allowed@: $($rep[4].IndexOf('Allowed'))"
Write-Host "Line6 pos42:[$($rep[5][41])] pos43:[$($rep[5][42])]"
Write-Host "Line7 pos42:[$($rep[6][41])]"
Write-Host "Line9 1-13:[$($rep[8].Substring(0,13))] PK_@: $($rep[8].IndexOf('PK_'))"
Write-Host "Line11 comma@: $($rep[10].IndexOf(','))  tri:[$($rep[10].Substring(16,3))]"

$des = [System.IO.File]::ReadAllLines('C:\Amt\Migration\EclCobolPipeline\fixtures\archiformat\fic-descript.dat')
Write-Host "des count: $($des.Count)  len[1]: $($des[1].Length)"
Write-Host "des[1] type:[$($des[1].Substring(5,7))] len:[$($des[1].Substring(12,10))] TION.@: $($des[1].IndexOf('TION.'))  name:[$($des[1].Substring(44,10))]"
Write-Host "des[2] type:[$($des[2].Substring(5,7))] name:[$($des[2].Substring(44,10))]"

$unl = [System.IO.File]::ReadAllLines('C:\Amt\Migration\EclCobolPipeline\fixtures\archiformat\fic-unload.dat')
Write-Host "unl count: $($unl.Count)  len[0]: $($unl[0].Length)  len[1]: $($unl[1].Length)"
Write-Host "unl[0] key:[$($unl[0].Substring(0,10))] nullflags:[$($unl[0].Substring(66,2))]"
