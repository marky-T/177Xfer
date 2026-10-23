# MT-043 quick try: status of the SSG4_AFPH12_CFH_COPY script job and anything it started. Read-only; full detail to _scratch\ecl-pilot\check.txt.
$day = Get-Date -Format 'yyyyMMdd'
$logs = "E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Logs\$day"
$x = 'E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Extracts'
$out = 'E:\Repos\SsgTrial\_scratch\ecl-pilot\check.txt'
$since = (Get-Date).AddMinutes(-15)
$r = @()
$r += '--- BatchController'
$r += Get-Content "$logs\FederaleBatchController.Log" | Where-Object { $_ -match 'SSG4_AFPH12|CFH_COPY' } | Select-Object -Last 8 | ForEach-Object { ($_ -replace '\s+', ' ').Trim() }
$r += '--- new/changed log files in the last 15 min'
$new = Get-ChildItem $logs -File | Where-Object LastWriteTime -ge $since | Sort-Object LastWriteTime
$r += $new | ForEach-Object { '{0:HH:mm:ss} {1,8:N0} {2}' -f $_.LastWriteTime, $_.Length, $_.Name }
foreach ($f in $new | Where-Object { $_.Name -match 'AFPH12|SSG4|CFH|BugReport' }) {
  $r += "=== $($f.Name) (errors/warnings/key lines)"
  $r += Get-Content $f.FullName | Where-Object { $_ -match 'Error|Warning|Abort|not found|XQT|ASG|USE|Invoke-Ssg|exception message|Report|SGS' } | Select-Object -First 40 | ForEach-Object { ($_ -replace '\s+', ' ').Trim() }
}
$r += '--- Extracts files touched in the last 15 min'
$r += Get-ChildItem $x -Recurse -File | Where-Object LastWriteTime -ge $since | ForEach-Object { '{0:HH:mm:ss} {1,8:N0} {2}' -f $_.LastWriteTime, $_.Length, $_.FullName.Substring($x.Length + 1) }
$r | Out-File $out -Width 250
"written $out ($($r.Count) lines)"
$r | Select-Object -First 12
