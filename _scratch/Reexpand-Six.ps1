$w = 'E:\Repos\SsgTrial\_scratch\ssgfix'
New-Item -ItemType Directory -Force "$w\exp" | Out-Null
foreach ($r in Import-Csv E:\Repos\ssg4-work\app\selection.csv) {
  $card = 'E:\Repos\ssg4-work\sgs-cards\calls\' + ($r.Runstream -replace '\(P\)\.TXT$', '') + '__L' + $r.Line + '.sgs'
  $new = "$w\exp\$($r.ProgramId).cob"
  $res = pwsh -NoProfile -File E:\Repos\SsgTrial\Conversion\Pipeline\Invoke-SsgExpansion.ps1 -Program $r.Skeleton -ScriptPath "$w\out\$($r.Skeleton).ps1" -CardFile $card -OutFile $new
  $old = "E:\Repos\ssg4-work\app\expanded\$($r.ProgramId).cob"
  $diff = Compare-Object (Get-Content $old) (Get-Content $new)
  '{0}: oldLines={1} newLines={2} differingLines={3}' -f $r.ProgramId, (Get-Content $old).Count, (Get-Content $new).Count, @($diff).Count
  $diff | Select-Object -First 14 | ForEach-Object { '    {0} {1}' -f $_.SideIndicator, $_.InputObject.Trim() }
}
