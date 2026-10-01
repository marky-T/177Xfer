$scriptsDir = 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts'
$results = New-Object System.Collections.Generic.List[object]

$wrappers = Get-ChildItem $scriptsDir -Filter '*-LIVE.ps1' | Where-Object { $_.Name -ne 'HelloWorld-LIVE.ps1' }

foreach ($w in $wrappers) {
  $out = & pwsh -NoProfile -ExecutionPolicy Bypass -File $w.FullName 2>&1
  $text = ($out | Out-String)
  $pass = $text -match 'Body completed without a thrown exception'
  $connected = $text -match 'Initialize OK'
  $lastLine = ($text -split "`r?`n" | Where-Object { $_.Trim() -ne '' } | Select-Object -Last 1)
  $keyName = $w.BaseName -replace '-LIVE$', ''
  $results.Add([pscustomobject]@{
    Key       = $keyName
    Connected = $connected
    Pass      = [bool]$pass
    LastLine  = $lastLine
  })
}

$results | Format-Table -AutoSize | Out-String -Width 200
"`nPASS: $(($results | Where-Object Pass).Count) / $($results.Count)"
