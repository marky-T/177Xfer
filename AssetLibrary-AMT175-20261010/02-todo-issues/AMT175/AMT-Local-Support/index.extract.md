# Extract of embedded bug / issue log

Source: `01-docs-html/AMT175/AMT-Local-Support/index.html` (original: `C:\Amt\Parallel\AMT175\AMT-Local-Support\index.html`)

Original IDs from the HTML are preserved.

## Known issues (id=ssg-known-issues)

### SSG Converter — known issues

### "SymstreamExpressionPrimitive expected."

        The conversion fails for a file with an error like:

        `Error converting <FILE>: SymstreamExpressionPrimitive expected.`

        Cause: a converter limitation. The parser accepts a leading unary `-`/`+`
        in front of any sub-expression, but the migrator only emits a unary sign when the operand is a
        primitive (a literal number/string or a plain identifier). A sign applied to a bracketed
        `[…]` SGS reference, a parenthesised group, or a compound expression throws this error.

        The message carries no line number — the failure is caught at file level, so only the file name is shown.