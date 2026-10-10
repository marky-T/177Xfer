$html = Get-Content 'C:\Amt\Migration\SSG-ECL-Command-Matrix.html' -Raw -Encoding UTF8
$rows = $html -split '(?=[ \t]*<tr[>\s])'
foreach ($r in $rows) {
  if ($r -match 'class="directive"><code>(@SSG,IA|@XQT |@ASG,A|#ACOB|\*INCREMENT|\*IF|\[PARAM,r,1)') {
    $dir = $Matches[1]
    $lines = $r -split "`n"
    $cellIdx = 0
    foreach ($ln in $lines) {
      if ($ln -match '<td class="cell">') {
        $cellIdx++
        if ($cellIdx -eq 11) {
          Write-Host ('{0,-25} -> {1}' -f $dir, $ln.Trim())
        }
      }
    }
  }
}
