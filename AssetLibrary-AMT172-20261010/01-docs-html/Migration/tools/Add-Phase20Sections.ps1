param()
$ref = "C:\Amt\Migration\AMT172-Setup-Guide.html"
$c = Get-Content $ref -Raw

$newSections = @'

      <h3 style="margin-top:14px;">TRI_ASCII (Sort-Fichout-1) SSG/ECL Purpose</h3>
      <p style="font-size:.85rem;line-height:1.7;">
        <code>TRI_ASCII</code> is a <strong>reusable sort utility</strong>, not a fixed program. The COBOL source
        contains no literal file names, record sizes, or key positions &#8212; every one of those is an SSG/ECL parameter
        substituted at compile time. The same source file generates a <em>different</em> sort program for each calling
        ECL job: one job might sort a 120-byte ledger file on an 8-byte account key at offset 10; another might sort a
        200-byte claims file on a 12-byte reference at offset 0; the trial here uses 80-byte records with an 8-byte key
        at offset 0. <code>T_SORT</code> is essential precisely because the key position cannot be hardcoded &#8212; it
        is always <em>whatever the ECL job says</em>: <code>keyOffset = [KEYS,1,COL,1]</code> bytes of filler before
        the key, <code>keyWidth = [KEYS,1,COL,2]</code> bytes for the key itself (e.g.&nbsp;offset&nbsp;0 +
        width&nbsp;8 for the trial; offset&nbsp;10 + width&nbsp;12 for a different job). The <code>*DEFINE FILLADD</code>
        macro in the SSG source expresses this filler logic &#8212; it is suppressed by <code>Remove-SsgDirectives.ps1</code>
        and re-expressed in C# as <code>if (keyOffset &gt; 0) { new AmtVarAlpha(keyOffset, m_Sort_R1); }</code>.
        The file names <code>FICHIN-1</code> and <code>FICHOUT-1</code> in the default fields are only a placeholder
        for the current ECL stub &#8212; they will be set from the actual ECL parameters in a production run.
      </p>
      <p style="font-size:.82rem;color:#6b7280;margin-top:4px;">
        <strong>SSG/ECL transform status for TRI_ASCII:</strong>
        <span style="color:#16a34a">&#10003; T3 <code>[INPUT,1,A,2]</code> / <code>[OUTPUT,1,1,2]</code> record sizes &#8212; <code>recordSize</code> params on <code>Fd_Rec_In_1</code>, <code>Fd_Rec_Out</code>, <code>Fd_Sort_Rec</code></span> &nbsp;&middot;&nbsp;
        <span style="color:#16a34a">&#10003; T4 <code>[INPUT,1,A,1]</code> / <code>[OUTPUT,1,1,1]</code> file names &#8212; <code>m_FichinName</code> / <code>m_FichouName</code> fields</span> &nbsp;&middot;&nbsp;
        <span style="color:#16a34a">&#10003; T_SORT <code>[KEYS,1,COL,1]</code> / <code>[KEYS,1,COL,2]</code> key offset + width &#8212; <code>keyOffset</code> / <code>keyWidth</code> params on <code>Fd_Sort_R1</code></span> &nbsp;&middot;&nbsp;
        <span style="color:#9ca3af">&#8212; T_MULTI <code>[INPUT,1]</code> variable input count &#8212; deferred</span>
      </p>

      <h3 style="margin-top:14px;">Sort-Fichout-1 Run Review</h3>
      <p style="font-size:.85rem;color:#475569;margin-bottom:10px;">What actually happens when the program executes &#8212; in plain terms. <span style="background:#eff6ff;border:1px solid #93c5fd;border-radius:3px;padding:1px 5px;font-size:.75rem;color:#1d4ed8;font-family:monospace">SSG tag</span> annotations show where each SSG macro construct is in effect.</p>
      <ol style="font-size:.85rem;line-height:1.9;">
        <li><strong>Start-up.</strong> The AMT runtime reads <code>sys.ini</code>, connects to the SQL Server databases, and creates a job row so the run is tracked.</li>
        <li><strong>Open input file.</strong> The runtime locates <code>FICHIN-1.DAT</code> in the Extracts folder and opens it for sequential reading. The file name comes from the SSG parameter <span style="background:#eff6ff;border:1px solid #93c5fd;border-radius:3px;padding:1px 5px;font-size:.75rem;color:#1d4ed8;font-family:monospace">[INPUT,1,A,1]</span> (T4), now stored in <code>m_FichinName</code> and passed to <code>SetOptions()</code> instead of being a hardcoded literal. The record size &#8212; 80 characters &#8212; comes from <span style="background:#eff6ff;border:1px solid #93c5fd;border-radius:3px;padding:1px 5px;font-size:.75rem;color:#1d4ed8;font-family:monospace">[INPUT,1,A,2]</span> (T3), passed as <code>m_RecordSizeIn=80</code> into <code>Fd_Rec_In_1</code>.</li>
        <li><strong>Open sort work file.</strong> A temporary file (<code>SORT-FICHOUT-1_SORTFILE&lt;requestId&gt;</code>) is created to hold records during sorting. Its layout is defined by two classes working together: <code>Fd_Sort_Rec</code> (the flat 80-byte record, driven by <span style="background:#eff6ff;border:1px solid #93c5fd;border-radius:3px;padding:1px 5px;font-size:.75rem;color:#1d4ed8;font-family:monospace">[OUTPUT,1,1,2]</span> T3 = <code>m_RecordSizeOut</code>) and <code>Fd_Sort_R1</code> which redefines it with the sort key overlay: optional filler of <span style="background:#eff6ff;border:1px solid #93c5fd;border-radius:3px;padding:1px 5px;font-size:.75rem;color:#1d4ed8;font-family:monospace">[KEYS,1,COL,1]</span> (T_SORT = <code>keyOffset=0</code>, so no filler here) then <code>Sort_Key_1</code> of width <span style="background:#eff6ff;border:1px solid #93c5fd;border-radius:3px;padding:1px 5px;font-size:.75rem;color:#1d4ed8;font-family:monospace">[KEYS,1,COL,2]</span> (T_SORT = <code>keyWidth=8</code>). The <code>*DEFINE FILLADD</code> macro in the SSG source expressed this filler logic; it is now in C# as <code>if (keyOffset &gt; 0) { new AmtVarAlpha(keyOffset, m_Sort_R1); }</code>.</li>
        <li><strong>Stage records for sort (Inp loop).</strong> Each record from <code>TAPE-1</code> is copied verbatim into the sort work file. This is the COBOL <code>SORT … INPUT PROCEDURE</code> section.</li>
        <li><strong>Sort.</strong> <code>SortFiles(Sortfile, new Tuple&lt;AmtVariable, AmtOrder&gt;[] { Tuple.Create((AmtVariable)m_Fd_Sort_R1.Sort_Key_1, AmtOrder.Ascending) }, false)</code> is called. The runtime sorts all staged records by the 8-byte key at offset 0, ascending (standard ASCII collation). The sort key field was constructed using the T_SORT parameters &#8212; if <code>keyOffset</code> had been non-zero, a filler entry would have preceded it in the <code>m_Sort_R1</code> structure, shifting the key to the correct byte position.</li>
        <li><strong>Write sorted output (Outp loop).</strong> The sort work file is re-opened for sequential reading. Each sorted record is copied into <code>TAPEOUT</code> (<code>FICHOUT-1.DAT</code>), whose file name comes from <span style="background:#eff6ff;border:1px solid #93c5fd;border-radius:3px;padding:1px 5px;font-size:.75rem;color:#1d4ed8;font-family:monospace">[OUTPUT,1,1,1]</span> (T4) &#8212; stored in <code>m_FichouName</code> &#8212; and whose record size is <span style="background:#eff6ff;border:1px solid #93c5fd;border-radius:3px;padding:1px 5px;font-size:.75rem;color:#1d4ed8;font-family:monospace">[OUTPUT,1,1,2]</span> (T3) = 80 bytes.</li>
        <li><strong>Close files, display counts, exit.</strong> Both files are closed. The program displays input and output record counts <code>UPON PRINTER</code> (written to the Prints folder when the Application Server is available). The sort work file is purged. The process exits with code 0.</li>
      </ol>
      <p style="font-size:.85rem;background:#f0fdf4;border-left:3px solid #22c55e;padding:8px 12px;margin-top:8px;">
        <strong>Result for the test data:</strong>
        input <code>FICHOUT-1.DAT</code> records in order ZZZ&hellip; / AAA&hellip; / MMM&hellip;
        &#8594; output <code>FICHOUT-1.DAT</code>: <strong>AAA / MMM / ZZZ</strong> &#10003;
        &nbsp;&middot;&nbsp; 3 records in, 3 records out.
      </p>
'@

$insertBefore = "</pre>`n    </div>`n  </div>`n`n  <!-- BUG LOG -->"

if ($c.Contains($insertBefore)) {
    $c = $c.Replace($insertBefore, "</pre>" + $newSections + "`n    </div>`n  </div>`n`n  <!-- BUG LOG -->")
    Write-Host "Sections inserted"
} else {
    Write-Host "WARN: anchor not found"
}

$c | Set-Content $ref -NoNewline -Encoding UTF8
Write-Host "Saved ($($c.Length) chars)"
