param([Parameter(Mandatory)][String]$StartLine, [String]$JobParam, [String]$UseUnicode = 'False')
$job = ($StartLine -split ':')[0]
$tag = if ($JobParam) { "$job-$JobParam" } else { $job }
$out = "$PSScriptRoot\false-$tag.txt"
$a = @{ Stage = 'Regress'; Environment = 'CC-Trial'; Job = $job; StartLine = $StartLine; UseUnicode = $UseUnicode }
if ($JobParam) { $a.JobParam = $JobParam }
& E:\Repos\SsgTrial\Conversion\Pipeline\Generic\Invoke-GnPipeline.ps1 @a *> $out
Get-Content $out | Select-String "^(PASS|FAIL) ($job|settings)" | ForEach-Object { $_.Line.Substring(0, [Math]::Min(260, $_.Line.Length)) }
