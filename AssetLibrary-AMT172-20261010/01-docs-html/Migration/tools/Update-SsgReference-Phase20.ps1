param()
$ref = "C:\Amt\Migration\SSG-COBOL-Reference.html"
$c = Get-Content $ref -Raw

# ── 1. Nav: insert Ex 3 link ─────────────────────────────────────────────
$navTarget = '<li class="sub"><a href="#ex2">Ex 2 &middot; LECTIS_MULT</a></li>'
if ($c.Contains($navTarget)) {
    $c = $c.Replace($navTarget,
        $navTarget + "`r`n    " + '<li class="sub"><a href="#ex3">Ex 3 &middot; TRI_ASCII (SORT)</a></li>'
    )
    Write-Host "Nav link inserted"
} else {
    Write-Host "WARN: nav target not found"
}

# ── 2. Example 3 HTML block ───────────────────────────────────────────────
$ex3Html = @'

  <!-- EXAMPLE 3: TRI_ASCII / SORT-FICHOUT-1 -->
  <div id="ex3">
    <div class="example-header">
      <h3>Example 3 &mdash; TRI_ASCII</h3>
      <p>ASCII sort utility &nbsp;&#183;&nbsp; PROGRAM-ID: SORT-FICHOUT-1 &nbsp;&#183;&nbsp;
         <span class="badge badge-done" style="background:rgba(255,255,255,.15);color:#bbf7d0;">&#10003; Trial 06 &mdash; Generated + Trial 2026-06-25</span></p>
    </div>
    <div class="example-body">

      <h3>Purpose</h3>
      <p><strong>TRI_ASCII</strong> reads a flat sequential file (<code>FICHIN-1</code>), sorts
      records ascending by an 8-byte ASCII key at offset 0, and writes the sorted output to
      <code>FICHOUT-1</code>.  The program is a direct SSG-parameterised wrapper around the OS2200
      SORT verb and is the canonical example of the <strong>T_SORT</strong> transform tier.</p>

      <h3>SSG Invocation Parameters</h3>
      <table class="ref">
        <thead><tr><th>ECL Parameter</th><th>Address</th><th>Stub Value</th><th>Meaning</th></tr></thead>
        <tbody>
          <tr><td><code>INPUT</code></td><td><code>[INPUT,1,A,1]</code></td><td>FICHIN-1</td><td>Input file name (TAPE-1)</td></tr>
          <tr><td><code>INPUT</code></td><td><code>[INPUT,1,A,2]</code></td><td>80</td><td>Input record size (bytes)</td></tr>
          <tr><td><code>OUTPUT</code></td><td><code>[OUTPUT,1,1,1]</code></td><td>FICHOUT-1</td><td>Output file name (TAPEOUT)</td></tr>
          <tr><td><code>OUTPUT</code></td><td><code>[OUTPUT,1,1,2]</code></td><td>80</td><td>Output record size (bytes); also SD record size</td></tr>
          <tr><td><code>KEYS</code></td><td><code>[KEYS,1,COL,1]</code></td><td>0</td><td>Sort key offset (bytes from record start; 0 = no filler)</td></tr>
          <tr><td><code>KEYS</code></td><td><code>[KEYS,1,COL,2]</code></td><td>8</td><td>Sort key width (bytes)</td></tr>
        </tbody>
      </table>

      <h3>Pre-Processor Fixes (Phase 19)</h3>
      <div class="info-box">
        <ul style="margin:4px 0 0 18px;">
          <li><strong><code>*DEFINE FILLADD</code> block suppression</strong> — the macro body (including
          nested <code>*IF</code>) is fully stripped by <code>Remove-SsgDirectives.ps1</code> before passing
          to CobolConverter.  Without this, a stray <code>03 FILLER PIC X(1).</code> appeared before
          <code>IDENTIFICATION DIVISION</code>, aborting the converter.</li>
          <li><strong>String <code>*IF</code> comparison</strong> — <code>*IF [INPUT,1,A,1] = CARDREADER</code>
          compares a <em>string-valued</em> SSG parameter against a bare keyword.
          <code>Resolve-SsgCondition</code> now has a string-comparison arm that looks up
          <code>ParamOverrides["INPUT,1,A,1"]</code> and returns <code>false</code> for the CARDREADER
          and CARDPUNCH branches, emitting only the DISC branch.</li>
        </ul>
      </div>

      <h3>Generated C# Structure</h3>
      <table class="ref">
        <thead><tr><th>File</th><th>Key content</th></tr></thead>
        <tbody>
          <tr><td><code>Sort_Fichout_1.cs</code></td><td>Entry point, <code>CreateDefinitions()</code></td></tr>
          <tr><td><code>Sort_Fichout_1.Core.cs</code></td><td>Sort_Start(), Inp(), Outp(), Close_Files() with <code>SortFiles()</code> call</td></tr>
          <tr><td><code>Sort_Fichout_1.Files.cs</code></td><td>T3/T4/T_SORT fields + wired constructors + <code>SetOptions(m_FichinName, &hellip;)</code></td></tr>
          <tr><td><code>Fd_Rec_In_1.cs</code></td><td>T3: <code>int recordSize = 80</code> param on constructor</td></tr>
          <tr><td><code>Fd_Rec_Out.cs</code></td><td>T3: <code>int recordSize = 80</code> param on constructor</td></tr>
          <tr><td><code>Fd_Sort_Rec.cs</code></td><td>T3: SD record size = <code>m_RecordSizeOut</code></td></tr>
          <tr><td><code>Fd_Sort_R1.cs</code></td><td>T_SORT: filler if <code>keyOffset &gt; 0</code>, <code>keyWidth</code> on Sort_Key_1</td></tr>
        </tbody>
      </table>

      <h3>Sort Runtime API</h3>
      <div class="code-wrap">
        <span class="code-label">Sort_Fichout_1.Core.cs — SortFiles call</span>
        <pre><span class="csharp-type">SortFiles</span>(Sortfile,
    <span class="csharp-kw">new</span> Tuple&lt;AmtVariable, AmtOrder&gt;[] {
        Tuple.Create((<span class="csharp-type">AmtVariable</span>)m_Fd_Sort_R1.Sort_Key_1, AmtOrder.Ascending)
    }, <span class="csharp-kw">false</span>);</pre>
      </div>
      <p class="note">Use <code>SortFiles(fileId, tupleArray, descend)</code>.
      <strong>Not</strong> <code>AmtAfcSortInfo</code> (IBM DFSORT only).</p>

      <h3>Trial 06 Result</h3>
      <div class="info-box">
        Input <code>FICHIN-1.DAT</code> (3 records: ZZZ / AAA / MMM) &rarr;
        Output <code>FICHOUT-1.DAT</code>: <strong>AAA / MMM / ZZZ</strong> &nbsp;&#10003;
      </div>

    </div><!-- /example-body -->
  </div><!-- /ex3 -->

'@

$footerTarget = '  <!-- Footer -->'
if ($c.Contains($footerTarget)) {
    $c = $c.Replace($footerTarget, $ex3Html + $footerTarget)
    Write-Host "Example 3 inserted"
} else {
    Write-Host "WARN: footer target not found"
}

# ── 3. T_SORT pattern block ───────────────────────────────────────────────
$tsortHtml = @'

      <!-- ── T_SORT: SORT key ─────────────────────────────────────────── -->
      <div id="pat-tsort" class="pattern-card">
        <h3>Pattern: <code>[KEYS,1,COL,1]</code> / <code>[KEYS,1,COL,2]</code>
&rarr; constructor <code>int keyOffset, int keyWidth</code></h3>
        <h3>SSG Original</h3>
        <div class="code-wrap">
          <span class="code-label">SSG-COBOL SD definition</span>
          <pre>SD  SORTFILE  DATA RECORD IS SORT-REC.
01  SORT-REC  PIC X([OUTPUT,1,1,2]).     *> SD record = output record size
01  SORT-R1.
    *DEFINE FILLADD [KEYS,1,COL,1]       *> emits FILLER if offset > 0
    03  SORT-KEY-1  PIC X([KEYS,1,COL,2]).  *> sort key width</pre>
        </div>
        <h3>C# Implementation</h3>
        <div class="code-wrap">
          <span class="code-label">Fd_Sort_R1.cs — parameterised sort key</span>
          <pre><span class="csharp-kw">public</span> Fd_Sort_R1 (Sort_Fichout_1 parentObject, AmtFileLayout sharedLayout,
                    <span class="csharp-kw">int</span> keyOffset = 0, <span class="csharp-kw">int</span> keyWidth = 8) {
  m_DataRecord = <span class="csharp-kw">new</span> AmtStructure();
  {
    m_Sort_R1 = <span class="csharp-kw">new</span> AmtStructure(m_DataRecord);
    {
      <span class="csharp-kw">if</span> (keyOffset &gt; 0) { <span class="csharp-kw">new</span> AmtVarAlpha(keyOffset, m_Sort_R1); }  <span class="csharp-cmt">// FILLER</span>
      m_Sort_Key_1 = <span class="csharp-kw">new</span> AmtVarAlpha(keyWidth, m_Sort_R1);
    }
  }
  <span class="csharp-kw">if</span> (sharedLayout != <span class="csharp-kw">null</span>) { m_DataRecord.Redefines(sharedLayout.DataRecord); }
  AllocateStructures();
}</pre>
        </div>
        <div class="code-wrap">
          <span class="code-label">Sort_Fichout_1.Files.cs — T_SORT fields + FilesCreate wiring</span>
          <pre><span class="csharp-cmt">// T_SORT fields (defaults = stub values)</span>
<span class="csharp-kw">private int</span>    m_SortKeyOffset = 0;   <span class="csharp-cmt">// [KEYS,1,COL,1]</span>
<span class="csharp-kw">private int</span>    m_SortKeyWidth  = 8;   <span class="csharp-cmt">// [KEYS,1,COL,2]</span>

<span class="csharp-cmt">// Fd_Sort_Rec also gets the output record size (T3)</span>
m_Fd_Sort_Rec = <span class="csharp-kw">new</span> Fd_Sort_Rec(this, m_RecordSizeOut);
m_Fd_Sort_R1  = <span class="csharp-kw">new</span> Fd_Sort_R1(this, m_Fd_Sort_Rec, m_SortKeyOffset, m_SortKeyWidth);</pre>
        </div>
        <h3>Notes / Gotchas</h3>
        <ul>
          <li><code>*DEFINE FILLADD</code> macro body must be suppressed by <code>Remove-SsgDirectives.ps1</code>
          before passing to CobolConverter; it only emits the C# filler logic at runtime via
          <code>keyOffset &gt; 0</code>.</li>
          <li>When <code>keyOffset = 0</code> (key at start of record) no FILLER is created — the
          <code>AmtVarAlpha(0, …)</code> path is avoided entirely.</li>
          <li><code>Fd_Sort_Rec</code> (the SD flat record) uses <code>m_RecordSizeOut</code>, not a separate
          parameter — the sort workspace record is the same size as the output record.</li>
          <li>The <code>SortFiles</code> API (AMT sort) takes a <code>Tuple&lt;AmtVariable, AmtOrder&gt;[]</code>.
          Multi-key sorts add further tuples to the array; ascending = <code>AmtOrder.Ascending</code>.</li>
        </ul>
        <h3>Applies to programs</h3>
        <p>All SSG utility programs that use the OS2200 <code>SORT</code> verb with parameterised key
        address (<code>[KEYS,1,COL,1]</code> / <code>[KEYS,1,COL,2]</code>).
        Currently: <strong>TRI_ASCII</strong> (SORT-FICHOUT-1).</p>
      </div>

'@

$patternEnd = '  </div><!-- /patterns -->'
if ($c.Contains($patternEnd)) {
    $c = $c.Replace($patternEnd, $tsortHtml + $patternEnd)
    Write-Host "T_SORT pattern inserted"
} else {
    Write-Host "WARN: patterns end not found"
}

# ── 4. Update footer date ────────────────────────────────────────────────
$c = $c.Replace('2026-06-24', '2026-06-25')
Write-Host "Footer date updated"

# ── 5. Save ──────────────────────────────────────────────────────────────
$c | Set-Content $ref -NoNewline -Encoding UTF8
Write-Host "SSG-COBOL-Reference.html saved ($($c.Length) chars)"
