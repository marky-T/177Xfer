$out = 'E:\Repos\SsgTrial\_scratch\bc-log-check.txt'
$logs = 'E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Logs'
$files = @("$logs\20261019\FederaleBatchController.Log", "$logs\20261020\FederaleBatchController.Log")
$res = foreach ($f in $files) {
  if (-not (Test-Path $f)) { "MISSING: $f"; continue }
  "=== $f ($((Get-Item $f).Length) bytes)"
  Select-String -Path $f -Pattern 'ASSURFED|ProcessJobId|Id: 3[01]|Critical|OutputError|Error running|started|Starting job|Job .* (completed|finished|ended)' |
    ForEach-Object { ('{0}: {1}' -f $_.LineNumber, ($_.Line -replace '\s+', ' ').Trim()) } | Select-Object -First 60
}
$res | Out-File $out -Width 300
"lines: $($res.Count)"
