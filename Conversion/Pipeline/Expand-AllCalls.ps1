# SSG-4 step 0 for one skeleton: expand every real call with its own cards (AMT's SGS functions, Invoke-SsgExpansion.ps1).
# Writes <Out>\<Program>__<call>.cob and <Out>\<Program>-expansion.csv; prints a one-line summary.
param(
  [String]$Program = 'BABA_ASCII',
  [String]$Cards = 'E:\Repos\ssg4-work\sgs-cards',
  [String]$Out = 'E:\Repos\ssg4-work\allcalls\expanded',
  # Folder with converted skeletons <Program>.ps1 (default Examples\Output); e.g. a converter fix's _scratch\fix-<id>\out.
  [String]$ScriptDir = 'E:\Repos\SsgTrial\SsgConverter\Examples\Output'
)
$ErrorActionPreference = 'Stop'
$exp = 'E:\Repos\SsgTrial\Conversion\Pipeline\Invoke-SsgExpansion.ps1'
New-Item -ItemType Directory -Force $Out | Out-Null
$calls = Import-Csv "$Cards\sgs-calls.csv" | Where-Object ProgramKey -eq $Program
$rows = foreach ($c in $calls) {
  $id = $c.CardFile -replace '^calls\\ASSURFED_F999RUN', '' -replace '\.sgs$', '' -replace '__', '_' -replace '^_', ''
  $file = Join-Path $Out "${Program}__$id.cob"
  $err = ''
  try { $r = & $exp -Program $Program -CardFile (Join-Path $Cards $c.CardFile) -OutFile $file -ScriptPath (Join-Path $ScriptDir "$Program.ps1") 6>$null 5>$null 4>$null 3>$null } catch { $err = $_.Exception.Message }
  # The expander also reports failure without throwing (Failed/Error on its result object).
  $res = @($r) | Where-Object { $_ -and $_.PSObject.Properties['Failed'] } | Select-Object -Last 1
  if (-not $err -and $res -and $res.Failed) { $err = "$($res.Error)"; if (-not $err) { $err = 'expansion failed (no message)' } }
  $lines = if (Test-Path $file) { @(Get-Content $file).Count } else { 0 }
  [pscustomobject]@{ Call = $id; CardFile = $c.CardFile; Lines = $lines; Procedure = [bool]((Test-Path $file) -and (Select-String $file -Pattern 'PROCEDURE DIVISION' -Quiet)); Error = $err }
}
$rows | Export-Csv (Join-Path $Out "$Program-expansion.csv") -NoTypeInformation
'{0}: {1} calls, {2} with a procedure division, {3} errors' -f $Program, $rows.Count, @($rows | Where-Object Procedure).Count, @($rows | Where-Object Error).Count
$rows | Where-Object { $_.Error -or -not $_.Procedure } | Select-Object -First 10 | ForEach-Object { '  {0}: {1}' -f $_.Call, ($_.Error -replace '\s+', ' ').Substring(0, [Math]::Min(150, ($_.Error -replace '\s+', ' ').Length)) }
