param()
$ref = "C:\Amt\Migration\AMT172-Setup-Guide.html"
$c = Get-Content $ref -Raw

# 1. Phase 20 badge: "Next Session" -> "Done"
$badgeOld = '<span class="badge" style="background:#fbbf24;color:#78350f">&#9203; Next Session</span></div>'
$badgeNew = '<span class="badge badge-done" style="background:#22c55e;color:#14532d">&#10003; Done 2026-06-25</span></div>'
if ($c.Contains($badgeOld)) {
    $c = $c.Replace($badgeOld, $badgeNew)
    Write-Host "Phase 20 badge updated"
} else {
    Write-Host "WARN: Phase 20 badge not found"
}

# 2. Phase 20 table rows: Pending -> Done
$c = $c.Replace('&#9203; Pending</td>', '&#10003; Done</td>')
Write-Host "Pending-to-Done done"

# 3. Milestone rows: insert before the closing </tbody>
$closeMarker = '      </tr>    </tbody>'
$newRows = '      </tr>' + "`r`n" +
'      <tr>' + "`r`n" +
'        <td style="padding:.4rem;border:1px solid #ddd;">2026-06-25</td>' + "`r`n" +
'        <td style="padding:.4rem;border:1px solid #ddd;">Phase 19</td>' + "`r`n" +
'        <td style="padding:.4rem;border:1px solid #ddd;">TRI_ASCII Pipeline</td>' + "`r`n" +
'        <td style="padding:.4rem;border:1px solid #ddd;">SSG SORT program: pre-processor fixes (*DEFINE FILLADD suppression, string *IF), CobolConverter, LionDev import+generate, build 0 errors, sort trial AAA/MMM/ZZZ &#10003;</td>' + "`r`n" +
'        <td style="padding:.4rem;border:1px solid #ddd;"><a href="SSG-COBOL-Reference.html#ex3">SSG-COBOL-Reference.html §6 Ex3</a></td>' + "`r`n" +
'        <td style="padding:.4rem;border:1px solid #ddd;">&#8212;</td>' + "`r`n" +
'        <td style="padding:.4rem;border:1px solid #ddd;">Low risk &#8212; runtime trial verified</td>' + "`r`n" +
'      </tr>' + "`r`n" +
'      <tr>' + "`r`n" +
'        <td style="padding:.4rem;border:1px solid #ddd;">2026-06-25</td>' + "`r`n" +
'        <td style="padding:.4rem;border:1px solid #ddd;">Phase 20</td>' + "`r`n" +
'        <td style="padding:.4rem;border:1px solid #ddd;">TRI_ASCII SSG Transforms</td>' + "`r`n" +
'        <td style="padding:.4rem;border:1px solid #ddd;">T3 (record sizes), T4 (file names), T_SORT (key offset+width) applied to 5 C# files; build 0 errors; re-trial AAA/MMM/ZZZ &#10003;</td>' + "`r`n" +
'        <td style="padding:.4rem;border:1px solid #ddd;"><a href="SSG-COBOL-Reference.html#pat-tsort">SSG-COBOL-Reference.html §7 T_SORT</a></td>' + "`r`n" +
'        <td style="padding:.4rem;border:1px solid #ddd;">&#8212;</td>' + "`r`n" +
'        <td style="padding:.4rem;border:1px solid #ddd;">Low risk &#8212; parameterised defaults match stub; runtime re-verified</td>' + "`r`n" +
'      </tr>    </tbody>'
if ($c.Contains($closeMarker)) {
    $c = $c.Replace($closeMarker, $newRows)
    Write-Host "Milestone rows inserted"
} else {
    Write-Host "WARN: close marker not found"
}

$c | Set-Content $ref -NoNewline -Encoding UTF8
Write-Host "Saved"
