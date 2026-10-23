# FUSBA step 0: classify all FUSBA/FUSBA2 expansions by procedure shape (names/numbers abstracted) and card options.
param([String]$Environment = 'CC-Trial')
. "$(Split-Path (Split-Path $PSScriptRoot))\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$e = "$($ge.WorkRoot)\allcalls\expanded"
$out = "$($ge.GenericWork)\FUSBA"
New-Item -ItemType Directory -Force $out | Out-Null
$rows = foreach ($p in 'FUSBA_ASCII', 'FUSBA2_ASCII') {
  $inv = Import-Csv "$e\$p-expansion.csv"
  foreach ($c in $inv) {
    $cards = Get-Content (Join-Path $ge.SgsCards $c.CardFile) | Where-Object { $_.Trim() } | ForEach-Object { ($_.Trim() -replace '\s+', ' ') }
    $t = Get-Content "$e\${p}__$($c.Call).cob" | Where-Object { $_.Trim() } | ForEach-Object { ($_ -replace '\s+', ' ').Trim() }
    $pd = [Array]::IndexOf($t, 'PROCEDURE DIVISION.')
    $er = [Array]::IndexOf($t, 'ENDING-ROUTINES SECTION.')
    $proc = $t[$pd..($er - 1)] | ForEach-Object { $_ -replace '\d+', '#' -replace "'[^']*'", "'?'" }
    [pscustomobject]@{
      Program = $p; Call = $c.Call
      Annul   = (($cards | Where-Object { $_ -match '^ANNUL' }) -replace '^ANNUL ?', '')
      Update  = (($cards | Where-Object { $_ -match '^UPDATE' }) -replace '^UPDATE ?', '')
      Keys    = (($cards | Where-Object { $_ -match '^KEYS' }) -replace '^KEYS ?', '')
      Outs    = @($cards | Where-Object { $_ -match '^OUTPUT' } | ForEach-Object { ($_ -split ' ').Count - 1 })[0]
      Fields  = [bool]($cards -match '^FIELDIN')
      Shape   = ($proc -join ' / ')
    }
  }
}
$rows | Export-Csv "$out\inventory.csv" -NoTypeInformation
"calls: $($rows.Count); distinct procedure shapes: $(@($rows | Group-Object Shape).Count)"
'--- card options'
$rows | Group-Object Program, Annul, Outs, Fields | Sort-Object Count -Descending | ForEach-Object { '{0,3} x {1}   e.g. {2}' -f $_.Count, $_.Name, $_.Group[0].Call }
'--- shapes'
$i = 0
$rows | Group-Object Shape | Sort-Object Count -Descending | ForEach-Object { $i++; '{0,3} x shape {1}: {2}' -f $_.Count, $i, (($_.Group | ForEach-Object { "$($_.Program -replace '_ASCII','')/$($_.Call)" }) -join ', ') }
