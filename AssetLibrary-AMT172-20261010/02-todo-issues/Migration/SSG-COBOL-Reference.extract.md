# Extract of embedded bug / issue log

Source: `01-docs-html/Migration/SSG-COBOL-Reference.html` (original: `C:\Amt\Migration\SSG-COBOL-Reference.html`)

Original IDs from the HTML are preserved.

### Bare-IF fix (new pattern — recorded here as Bug 17a)

      When `[COND,1,I,1]` with COND,1=0 resolves to an empty string, CobolConverter generates:

      cobol-bad       IF
           NEXT SENTENCE
       ELSE
           GO TO FIN.        <-- ERR 000084: empty IF condition

      Fix: The whole block is a no-op when COND,1=0. Delete all 3 lines in the pre-processor output before conversion. Do not add a macro stub — the empty token is intentional (no condition = pass all records).