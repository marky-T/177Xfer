$calls = Import-Csv 'E:\Repos\ssg4-work\sgs-cards\sgs-calls.csv' | Where-Object { $_.Converted -eq 'True' }
$all20 = 'ARCHISEPARE','CFH-COPY','BABA_ASCII','CHABAN_ASCII','UNLOADIS_ASCII','ARCHIFORMAT','LOADIS_ASCII','UNLOADIS_MULTI','CHAB100_ASCII','LOADIS_MULTI','LECTIS_ASCII','FUSBA2_ASCII','CFH-COPY_ASCII','FUSBA_ASCII','RECAP','TABAN_ASCII','TAPELD_ASCII','CONDIS2_ASCII','EXTEUR','SCAN_ASCII'
$rows = foreach ($k in $all20) {
  $n = @($calls | Where-Object ProgramKey -eq $k).Count
  [pscustomobject]@{ Program = $k; ExportedCalls = $n }
}
$rows | Format-Table -AutoSize | Out-File 'E:\Repos\SsgTrial\_scratch\all20-calls.txt'
Get-Content 'E:\Repos\SsgTrial\_scratch\all20-calls.txt'
