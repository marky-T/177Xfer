param([Parameter(Mandatory)][String]$StartLine, [String]$JobParam)
$job = ($StartLine -split ':')[0]
$tag = if ($JobParam) { "$job-$JobParam" } else { $job }
$out = "$PSScriptRoot\$tag.txt"
$a = @{ Stage = 'Regress'; Environment = 'CC-Trial'; Job = $job; StartLine = $StartLine }
if ($JobParam) { $a.JobParam = $JobParam }
& E:\Repos\SsgTrial\Conversion\Pipeline\Generic\Invoke-GnPipeline.ps1 @a *> $out
Get-Content $out | Select-String "^(PASS|FAIL) $job" | ForEach-Object { $_.Line.Substring(0, [Math]::Min(260, $_.Line.Length)) }
