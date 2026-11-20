$t = 'E:\Repos\SsgTrial\docs\SSG-PowerShell-Trial-Progress.html'
$l = Get-Content $t
$pat = 'Last updated|utilities on|generic programs|real calls|<h2>1 |<h2>3 |id="status"|id="current|RECAP_GN|TABAN_GN|EXTEUR_GN|Generic route|generic route'
Select-String -Path $t -Pattern $pat | ForEach-Object {
    $s = ($_.Line -replace '<[^>]+>', '' -replace '\s+', ' ').Trim()
    "L$($_.LineNumber): $($s.Substring(0, [Math]::Min(230, $s.Length)))"
}
