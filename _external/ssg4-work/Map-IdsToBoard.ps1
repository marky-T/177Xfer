param([String]$Tracker = 'E:\Repos\SsgTrial\docs\SSG-PowerShell-Trial-Progress.html',
      [String]$CodeIds = 'E:\Repos\ssg4-work\internal-ids-in-code-261120.csv',
      [String]$Known   = 'E:\Repos\SsgTrial\Conversion\Pipeline\Generic\release-known-issues.json',
      [String]$Out     = 'E:\Repos\ssg4-work\id-board-map-261120.csv')
$html = [IO.File]::ReadAllText($Tracker)
$code = Import-Csv $CodeIds | Group-Object Id -AsHashTable -AsString
$json = (Get-Content $Known -Raw | ConvertFrom-Json).issues | Group-Object id -AsHashTable -AsString
$rows = [regex]::Matches($html, '(?s)<tr id="((?:T3|MT)-\d{3})"[^>]*>(.*?)</tr>')
$res = foreach ($m in $rows) {
    $id = $m.Groups[1].Value
    $cells = [regex]::Matches($m.Groups[2].Value, '(?s)<td[^>]*>(.*?)</td>') | ForEach-Object { $_.Groups[1].Value }
    $plain = { param($s) ([regex]::Replace($s, '<[^>]+>', ' ') -replace '&amp;','&' -replace '&[a-z#0-9]+;',' ' -replace '\s+',' ').Trim() }
    $text = & $plain ($cells -join ' ')
    $status = & $plain $cells[-1]
    $refs = [regex]::Matches($text, '(?i)\b(user story|story|bug|issue|task|feature|PR)\s*#?\s*(\d{5,6})\b|#(1\d{5})\b') |
        ForEach-Object { if ($_.Groups[3].Value) { "#$($_.Groups[3].Value)" } else { "$($_.Groups[1].Value) $($_.Groups[2].Value)" } } |
        Select-Object -Unique
    $open = $status -notmatch '(?i)✓|done|fixed|resolved|closed|superseded|dropped|not needed|withdrawn' -or $status -match '(?i)\bopen\b'
    [pscustomobject]@{
        Id = $id; Open = $open
        Status = $status.Substring(0, [Math]::Min(90, $status.Length))
        InCode = if ($code[$id]) { $code[$id].Count } else { 0 }
        ReleaseBoard = if ($json[$id]) { ($json[$id].board -join '; ') } else { '' }
        BoardRefs = ($refs -join '; ')
        Title = ($text -replace "^$id\s+\d{6}\s+", '').Substring(0, [Math]::Min(110, ($text -replace "^$id\s+\d{6}\s+", '').Length))
    }
}
$res | Export-Csv $Out -NoTypeInformation -Encoding utf8
"rows: $($res.Count)  open: $(@($res | ? Open).Count)  inCode: $(@($res | ? InCode).Count)  inRelease: $(@($res | ? ReleaseBoard -ne '' ).Count + @($json.Keys | ? { -not ($res.Id -contains $_) }).Count)"
"open with no board ref: $(@($res | ? { $_.Open -and -not $_.BoardRefs -and -not $_.ReleaseBoard }).Count)"
