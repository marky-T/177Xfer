# Apply-GuideUpdates.ps1
# Adds Bug #14 row and Step 12.6 to AMT172-Setup-Guide.html
# Preserves UTF-8 BOM encoding

$guideFile = "C:\Amt\Migration\AMT172-Setup-Guide.html"
$encoding   = [System.Text.UTF8Encoding]::new($true)   # true = emit BOM

# ── Backup ──────────────────────────────────────────────────────────────────
Copy-Item $guideFile "$guideFile.bak-before-update" -Force
Write-Host "Backup created."

$html = [System.IO.File]::ReadAllText($guideFile, $encoding)

# ════════════════════════════════════════════════════════════════════════════
# CHANGE 1: Insert Bug #14 row after bug13, before </table>
# ════════════════════════════════════════════════════════════════════════════
$bug14Row = @'
      <tr class="bug-row" id="bug14"><td>14</td><td>12 &#8212; LionSource import</td><td><code>Could not find source with name: MONTANT</code> + <code>Invalid percentage -2147483648</code> &#8212; generator stops after re-import attempt</td><td><code>CobolConverterConsole.exe</code> stores the SSG filename (e.g. <code>ASSURFED_UTILIT_MONTANT_SIGNE(P)</code>) as the object name in the <code>.LionSource</code> file, but the COBOL body has <code>PROGRAM-ID. MONTANT.</code>. SQL-only renaming of REVSET/REVTREE is insufficient &#8212; REVDATA internal content becomes inconsistent, corrupting the revision counter. Generator&#8217;s <code>CobolApp.Sources.Find(objNameWm)</code> looks up by PROGRAM-ID, not REVSET name.</td><td>Fix the <code>.LionSource</code> file <strong>before import</strong>: replace the stored filename with the actual PROGRAM-ID using ASCII encoding (no BOM) &#8212; see Step&#160;12.6. Delete application from LionDev, then re-import the corrected file. &nbsp;<span class="tag">lionsource</span><span class="tag">import</span><span class="tag">program-id</span><span class="tag">bom</span></td></tr>
'@

$oldBug = '<span class="tag">baseyear</span></td></tr>' + "`r`n" + '    </table>'
$newBug = '<span class="tag">baseyear</span></td></tr>' + "`r`n" + $bug14Row.TrimEnd("`r`n") + "`r`n" + '    </table>'

if ($html.Contains($oldBug)) {
    $html = $html.Replace($oldBug, $newBug)
    Write-Host "Bug #14 row inserted."
} else {
    Write-Host "ERROR: Could not find bug13 anchor for Bug #14 insertion."
    exit 1
}

# ════════════════════════════════════════════════════════════════════════════
# CHANGE 2: Insert Step 12.6 after Step 12.5 code-wrap, before phase-body close
# ════════════════════════════════════════════════════════════════════════════
$step12_6 = @'

      <h3 style="margin:18px 0 8px;font-size:13px;color:#6b7280;text-transform:uppercase;letter-spacing:.05em">Step 12.6 &#8212; Verify PROGRAM-ID Matches Object Name in .LionSource</h3>
      <p style="margin:0 0 8px"><code>CobolConverterConsole.exe</code> derives the object name from the SSG filename (e.g. <code>ASSURFED_UTILIT_MONTANT_SIGNE(P)</code>). After suffix-stripping, the stored name becomes <code>ASSURFED_UTILIT_MONTANT_SIGNE</code>, but the COBOL source body contains <code>PROGRAM-ID. MONTANT.</code> &#8212; a completely different identifier. The generator&#8217;s <code>CobolApp.Sources.Find(objNameWm)</code> indexes by <code>PROGRAM-ID</code>, so generation fails with <em>Could not find source with name: MONTANT</em> even after Step&#160;12.5 cleans up the suffix.</p>
      <p style="margin:0 0 6px"><strong>Check before importing:</strong> open the <code>.LionSource</code> file in a text editor:</p>
      <ul style="margin:0 0 10px;font-size:13px">
        <li>Find <code>&lt;OBJECT=&hellip;,COBOL PROGRAM&gt;</code> &#8212; the value between <code>=</code> and <code>,</code> is the stored object name</li>
        <li>Find <code>Name=</code> in the <code>&lt;REVSET=&hellip;&gt;</code> block &#8212; same value</li>
        <li>Find <code>PROGRAM-ID.</code> in the <code>&lt;DATA=Code&gt;</code> block &#8212; this is what the generator uses</li>
        <li>All three should match after stripping any <code>(P)</code> / <code>(F)</code> / <code>(S)</code> suffix</li>
      </ul>
      <p style="margin:0 0 6px"><strong>Fix command (run before import):</strong></p>
      <div class="code-wrap"><span class="code-lang">powershell</span><button class="copy-btn" onclick="copyCode(this)">Copy</button><pre>$f = "C:\Amt\Migration\CobolConvert\output\my-source.LionSource"
Copy-Item $f "$f.bak" -Force
$content = [System.IO.File]::ReadAllText($f)
$content = $content -replace 'OldObjectName\(P\)', 'ACTUAL-PROGRAM-ID'
[System.IO.File]::WriteAllText($f, $content, [System.Text.Encoding]::ASCII)</pre></div>
      <div class="warn" style="margin-top:10px">&#9888; <strong>Do NOT use <code>Set-Content -Encoding UTF8</code></strong> &#8212; PowerShell 5 writes a UTF-8 BOM. LionDev rejects the file with &#8220;Invalid source file&#8221;. Always use <code>[System.IO.File]::WriteAllText(&hellip;, [System.Text.Encoding]::ASCII)</code>.</div>
      <p style="margin:8px 0 0"><strong>If already imported incorrectly:</strong> SQL-only renaming of REVSET/REVTREE is insufficient &#8212; REVDATA internal content becomes inconsistent. Delete the application from LionDev (right-click &#8594; Delete), fix the <code>.LionSource</code> file as above, then re-import via File &#8594; Import.</p>
'@

$oldStep = "SELECT NAME FROM REVSET WHERE APPID=@id AND REVDELETED&lt;&gt;'Y' AND NAME LIKE '%[^A-Za-z0-9_.\ -]%';</pre></div>" + "`r`n" + '    </div>' + "`r`n" + '  </div>' + "`r`n" + '  <!-- BUG LOG -->'
$newStep = "SELECT NAME FROM REVSET WHERE APPID=@id AND REVDELETED&lt;&gt;'Y' AND NAME LIKE '%[^A-Za-z0-9_.\ -]%';</pre></div>" + $step12_6 + '    </div>' + "`r`n" + '  </div>' + "`r`n" + '  <!-- BUG LOG -->'

if ($html.Contains($oldStep)) {
    $html = $html.Replace($oldStep, $newStep)
    Write-Host "Step 12.6 inserted."
} else {
    Write-Host "ERROR: Could not find Step 12.5 anchor for Step 12.6 insertion."
    # Debug: try LF-only variant
    $oldStepLF = "SELECT NAME FROM REVSET WHERE APPID=@id AND REVDELETED&lt;&gt;'Y' AND NAME LIKE '%[^A-Za-z0-9_.\ -]%';</pre></div>" + "`n" + '    </div>' + "`n" + '  </div>' + "`n" + '  <!-- BUG LOG -->'
    if ($html.Contains($oldStepLF)) {
        Write-Host "Found LF variant — retrying with LF..."
        $newStepLF = "SELECT NAME FROM REVSET WHERE APPID=@id AND REVDELETED&lt;&gt;'Y' AND NAME LIKE '%[^A-Za-z0-9_.\ -]%';</pre></div>" + $step12_6 + '    </div>' + "`n" + '  </div>' + "`n" + '  <!-- BUG LOG -->'
        $html = $html.Replace($oldStepLF, $newStepLF)
        Write-Host "Step 12.6 inserted (LF variant)."
    } else {
        exit 1
    }
}

# ── Write back (UTF-8 with BOM) ──────────────────────────────────────────────
[System.IO.File]::WriteAllText($guideFile, $html, $encoding)
Write-Host "Guide saved. Lines now: $($html.Split("`n").Count)"
