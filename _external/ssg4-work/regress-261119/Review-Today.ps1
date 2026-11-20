$t = 'E:\Repos\SsgTrial\docs\SSG-PowerShell-Trial-Progress.html'
$raw = Get-Content $t -Raw
"tracker Last updated: " + ([regex]::Match($raw, 'Last updated[^<]*(<[^>]+>)?[^<]{0,40}').Value -replace '<[^>]+>', '')
foreach ($k in 'EXTEUR', 'EUU003', 'MT-069', 'MT-070', 'RECSTUB', 'T3-071') {
    "{0,-8} hits in tracker: {1}" -f $k, ([regex]::Matches($raw, [regex]::Escape($k))).Count
}
$mt = [regex]::Matches($raw, 'id="MT-(\d{3})"') | ForEach-Object { [int]$_.Groups[1].Value } | Measure-Object -Maximum
"max MT id: $($mt.Maximum)"
$row = [regex]::Match($raw, '(?s)<tr id="MT-069">.*?</tr>').Value -replace '<[^>]+>', '' -replace '\s+', ' '
"MT-069 row: " + $row.Substring(0, [Math]::Min(900, $row.Length))
"--- runbook"
$rb = Get-Content 'E:\Repos\SsgTrial\docs\SSG4-ControlCenter-Runbook.html' -Raw
foreach ($k in 'EXTEUR', 'RECAP', 'TABAN', 'EUU003') { "{0,-7} hits in runbook: {1}" -f $k, ([regex]::Matches($rb, $k)).Count }
$inv = [regex]::Match($rb, '(?s)<h2>Inventory.*?</table>').Value -replace '<[^>]+>', ' ' -replace '\s+', ' '
"Inventory: " + $inv.Substring(0, [Math]::Min(700, $inv.Length))
"--- copilot-instructions status line"
Select-String -Path 'E:\Repos\SsgTrial\.github\copilot-instructions.md' -Pattern 'utilities on|Current status' | ForEach-Object Line
"--- utilities.json"
$j = Get-Content 'E:\Repos\SsgTrial\Conversion\Pipeline\Generic\utilities.json' -Raw | ConvertFrom-Json
foreach ($u in $j.utilities | Where-Object { $_.utility -in 'RECAP', 'TABAN', 'EXTEUR' }) {
    "{0}: program={1} tests={2} | proven={3}" -f $u.utility, $u.program, (($u.tests | ConvertTo-Json -Compress -Depth 4)), (($u.provenInCc | Out-String).Trim() -replace '\s+', ' ')
}
"crosscheck keys: " + (($j.check.crosscheck.psobject.Properties.Name) -join ', ')
"--- SsgConverter examples / Tier-1 for EXTEUR"
Get-ChildItem 'E:\Repos\SsgTrial\SsgConverter\Examples\Output' -Filter 'EXTEUR*' | ForEach-Object { "$($_.Name) $($_.LastWriteTime)" }
Get-ChildItem 'E:\Repos\SsgTrial\Conversion\Pipeline\Generic\skeletons' -Filter '*EXTEUR*' -ErrorAction SilentlyContinue | ForEach-Object { "skeleton: $($_.Name) $($_.LastWriteTime)" }
