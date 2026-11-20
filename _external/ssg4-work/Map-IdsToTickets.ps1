$raw = Get-Content 'E:\Repos\SsgTrial\docs\SSG-PowerShell-Trial-Progress.html' -Raw
$codeIds = (Import-Csv 'E:\Repos\ssg4-work\internal-ids-in-code-261120.csv' | Group-Object Id | ForEach-Object { [pscustomobject]@{ Id = $_.Name; Code = $_.Count } })
$docDir = 'E:\Repos\release_candidates\release20261112-rc.03\Utilities'
$docHits = foreach ($f in Get-ChildItem $docDir -File -Filter '*.md') {
    foreach ($m in [regex]::Matches((Get-Content $f.FullName -Raw), '\b(T3|MT)-\d{3}\b')) { [pscustomobject]@{ Id = $m.Value; Doc = $f.Name } }
}
$docIds = $docHits | Group-Object Id | ForEach-Object { [pscustomobject]@{ Id = $_.Name; Docs = (($_.Group.Doc | Group-Object | ForEach-Object { "$($_.Name) x$($_.Count)" }) -join ', ') } }
$all = @($codeIds.Id) + @($docIds.Id) | Sort-Object -Unique
foreach ($id in $all) {
    $row = [regex]::Match($raw, "(?s)<tr id=""$id"">.*?</tr>").Value -replace '<[^>]+>', ' ' -replace '&[a-z]+;', ' ' -replace '\s+', ' '
    $title = if ($row) { $row.Trim().Substring(0, [Math]::Min(110, $row.Trim().Length)) } else { '(no tracker row)' }
    $tickets = @([regex]::Matches($row, '(?i)(Bug|User Story|Task|Feature|Issue|work item|PR|pull request)\s*#?\s*(\d{5,6})') | ForEach-Object { "$($_.Groups[1].Value) $($_.Groups[2].Value)" } | Select-Object -Unique)
    $c = ($codeIds | Where-Object Id -eq $id).Code
    $d = ($docIds | Where-Object Id -eq $id).Docs
    [pscustomobject]@{ Id = $id; InCode = $c; InDocs = $d; Tickets = ($tickets -join '; '); Title = $title }
}
