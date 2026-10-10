# SsgConverter Local Fixes — 2026-08-20 / 2026-08-21

Build: `8.0.26188.0`  
Solution: `C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\SsgConverter\SsgConverter\SsgConverter.slnx`  
Build result after all fixes: **succeeded — 0 errors**

---

## Conversion results after all fixes

```
3 succeeded, 0 failed   (ECLAT/COMPARE2/CONDIS file set, 2026-08-21)
7 succeeded, 0 failed   (E_* file set, 2026-08-21)
36 succeeded, 0 failed  (full 36-file run, 2026-08-21 13:17 — log: SsgConversion_20260821_131747.log)
```

Warnings on full run:
- `ASSURFED_UTILIT_ARCHIINSERT(P)` — No SSG directives (plain COBOL with ECL header)
- `ASSURFED_UTILIT_ARCHITAB1(P)` — No SSG directives (plain COBOL with ECL header)
- `ASSURFED_UTILIT_ECLAT(P)` — IMPORTANT-WORKAROUND: `*ITERATE A` outer-loop (see Fix 11)

---

## Known issues — NOT fixed (no failing test case to prove; do not change without evidence)

### KI-3 — Mixed ECL + SSG + COBOL files: ECL runstream section is not converted

**Example file:** `ASSURFED_UTILIT_ARCHIFORMAT(P).TXT`

**Status: Not a converter bug — behaviour is correct given current scope. Requires ECL converter integration. Yet to be tested with ECL conversion applied.**

**File structure (ARCHIFORMAT pattern):**

| Section | Content | Converter output |
|---------|---------|-----------------|
| ECL runstream (`#asg`, `#delete`, `#xqt`, SQL, etc.) | ~34 lines | `# Embedded content (unconverted):` comments |
| SSG SET directives (`*set a = 2 + [key,1,1,3] + ...`) | 5 lines | `$A = (2 + (GetSgsValue(...)))` — **correctly converted** |
| COBOL source (after `#ucob`) | ~200+ lines | `# Orphaned data line:` — expected |

**Assessment:** The SSG parameterisation (5 `*SET` lines computing layout sizes) IS properly converted to PowerShell variable assignments with `GetSgsValue(...)`. The ECL runstream at the top requires the ECL converter (`Os2200ContentConverter` / `EclParserOs2200`), not the SSG converter. The COBOL source after `#ucob` is expected to be orphaned. No fix to the SSG converter is needed for this pattern; integration with the ECL pipeline would be required to convert the runstream section.

**Contrast with ARCHIINSERT:** `ASSURFED_UTILIT_ARCHIINSERT(P).TXT` has 347 lines and 0 SSG control directives — it is plain COBOL with an ECL header and produces only orphaned comments. The "No SSG directives recognised" warning (added 2026-08-21) fires for ARCHIINSERT but NOT for ARCHIFORMAT, correctly distinguishing the two cases.

---

### KI-1 — XOR/OR/AND binary operators missing empty-right guard

**File:** `SymstreamExpressionParser.cs` — XOR/OR/AND sections

The 7 comparison operators (`=`, `<`, `>`, `<=`, `>=`, `<>`) and `-`/`+` have the guard
`if (!String.IsNullOrEmpty(left) && !String.IsNullOrWhiteSpace(right))`.  
XOR/OR/AND do NOT. A trailing ` OR ` / ` AND ` / ` XOR ` at the end of a malformed expression
would produce `right = ""` and crash with "expression text may not be null or empty."  
**No current test input triggers this. Do not fix without a confirmed failing file.**

### KI-2 — Pre-existing bug: `*DIVIDE` assigns modulo result to wrong variable

**File:** `SymstreamProcessor.cs` — `case DirectiveId.Divide:` (~line 795, pre-existing)

When GIVING has two variables (`*DIVIDE a BY b GIVING quotient,remainder`), the second block
creates `target = splitVariables[0]` (should be `[1]`). The remainder is assigned to the
quotient variable. Not introduced by our fixes.  
**No current test input uses two-variable GIVING. Do not fix without a confirmed failing file.  
Record for R&D awareness.**

---

## Fix 1 — ERROR-A: deprecated `*End` not accepted as `*DEFINE` block terminator

> **Status: Workaround applied — proper fix requires R&D input.**

**Error (before workaround):** `*ITERATE variable is not the inner most loop variable, this is not supported.`

**Symptom:** File `ASSURFED_UTILIT_ECLAT(P)` failed entirely. `*iterate a` appears inside an inner
`*INCREMENT b` loop and intends to jump to the next iteration of the **outer** `*INCREMENT a` loop.

**Why it cannot be fixed simply:**
PowerShell's `continue` statement always affects the **innermost** enclosing loop only. There is no
labelled `continue` equivalent (unlike C#, Java, or Perl). The SSG `*ITERATE <varname>` semantic
— "continue the loop whose control variable is `<varname>`" — has no single-statement PowerShell
equivalent when that variable belongs to an outer loop.

**Workaround applied:**
Instead of throwing and failing the file, the converter now:
1. Logs an **`IMPORTANT-WORKAROUND applied`** warning in the conversion log.
2. Emits a PS comment in the output `.ps1`:
   ```powershell
   # IMPORTANT-WORKAROUND: *ITERATE a skips to the next iteration of an outer loop.
   # PowerShell 'continue' only affects the innermost loop, so this is a no-op here.
   # R&D fix required — see SsgConverter-Fix-20260820.md Fix 11.
   ```
3. The loop body continues executing normally (no iteration skip occurs).

This means the converted `.ps1` is **logically different** from the original SSG source at this point.
All other directives in the file convert correctly.

**Proper R&D fix:**
Requires the `*INCREMENT`/`*DO` code-generation path to look ahead for any `*ITERATE <its-variable>`
inside nested child loops, and conditionally emit a flag-variable scaffold:

```powershell
$continueA = $false
for ($a = 1; $a -le $KEY; $a++) {
    $continueA = $false
    for ($b = $c; $b -le $KEY; $b++) {
        if ($b -eq $a) {
            $continueA = $true   # replaces *iterate a
            break
        }
    }
    if ($continueA) { continue }
}
```

This is a non-trivial generator change. Decision for R&D: include in next build or accept the workaround.

**File:** `SsgConverter\SsgConverter\SymstreamProcessor.cs` — `case DirectiveId.Iterate:`

---

## Fix 1 — ERROR-A: deprecated `*End` not accepted as `*DEFINE` block terminator

**Error:** `This is unexpected. DirectiveId: End  Line: <n>`

**Root cause:** The `*DEFINE` reader loop used a string comparison that only accepted `*ENDDEFINE`
as a terminator. When legacy SSG source closes a `*DEFINE` block with the deprecated `*End`
directive, the loop continued past it. The outer `Convert()` switch then received
`DirectiveId.End`, which is not handled there, and threw the "unexpected" exception.

**File:** `SsgConverter\SsgConverter\SymstreamProcessor.cs`

**Location:** `case DirectiveId.Define:` block — the body-reading for-loop.

| | Lines (post-fix) |
|---|---|
| `DirectiveId endDefId;` declaration | 702 |
| for-loop start | 703 |
| `*ENDDEFINE` string-check break | 704 |
| `DirectiveId.End` break (new) | 705–706 |
| body conversion | 707 |

**Before:**
```csharp
i++;
for (; (i < lines.Count) && !lines[i].Trim().StartsWith(String.Format("{0}ENDDEFINE", m_DirectivePrefix), StringComparison.OrdinalIgnoreCase); i++) {
    define.Body.AddInstrBlock(Convert(lines, ref i, globalVariables));
}
```

**After:**
```csharp
i++;
DirectiveId endDefId;
for (; i < lines.Count; i++) {
    if (lines[i].Trim().StartsWith(String.Format("{0}ENDDEFINE", m_DirectivePrefix), StringComparison.OrdinalIgnoreCase)) break;
    // accept deprecated *End as *ENDDEFINE terminator
    if (IsDirective(lines[i], m_DirectivePrefix, out endDefId) && endDefId == DirectiveId.End) break;
    define.Body.AddInstrBlock(Convert(lines, ref i, globalVariables));
}
```

---

## Fix 2 — ERROR-A (related): deprecated `*End` not accepted as `*DO` block terminator

**Error:** Same `This is unexpected. DirectiveId: End` — triggered when `*DO` is closed with `*End`.

**Root cause:** The `*DO` reader loop correctly used `IsDirective()` but only tested for
`DirectiveId.EndDo`. Adding `|| loopId == DirectiveId.End` mirrors the pattern applied to Fix 1.

**File:** `SsgConverter\SsgConverter\SymstreamProcessor.cs`

**Location:** `case DirectiveId.Do:` block — the body-reading for-loop condition.

| | Lines (post-fix) |
|---|---|
| Added comment + `DirectiveId.End` OR clause | 923–925 |

**Before:**
```csharp
if ((IsDirective(lines[i], m_DirectivePrefix, out loopId)) && (loopId == DirectiveId.EndDo)) {
    break;
}
```

**After:**
```csharp
// accept deprecated *End as *ENDDO terminator
if ((IsDirective(lines[i], m_DirectivePrefix, out loopId)) && (loopId == DirectiveId.EndDo || loopId == DirectiveId.End)) {
    break;
}
```

---

## Fix 3 — ERROR-B: `SymstreamExpressionPrimitive expected` for unary sign with non-primitive operand

**Error:** `SymstreamExpressionPrimitive expected`

**Root cause:** The expression migrator handled unary `-` / `+` only for the case where the
operand is a `SymstreamExpressionPrimitive`. SSG expressions such as `-[key,1,2,2]` can
produce a unary node whose operand is a `SymstreamExpressionBinary` or other non-primitive
(e.g. when the parser resolves a leading sign before a complex bracketed expression). The
original code threw unconditionally for this case.

**Fix approach:** When the operand is not a primitive, recursively migrate it and emit
`(0 - <expr>)` for negative or `(0 + <expr>)` for positive, which is semantically equivalent
and valid PowerShell.

**File:** `SsgConverter\SsgConverter\SymstreamExpressionMigrator.cs`

**Location:** `Migrate()` method — `case UnaryOperator.Negative: / case UnaryOperator.Positive:` block.

| | Lines (post-fix) |
|---|---|
| Primitive operand path (unchanged logic, restructured) | 84–95 |
| Non-primitive operand path (new) | 96–100 |

**Before:**
```csharp
case UnaryOperator.Negative:
case UnaryOperator.Positive:
    // operand shoud be a primitive
    SymstreamExpressionPrimitive primitiveOperand = operand as SymstreamExpressionPrimitive;
    if (primitiveOperand == null) {
        throw new SymstreamException("SymstreamExpressionPrimitive expected.");
    }
    String sign = String.Empty;
    if (ue.UnaryOperator == UnaryOperator.Negative) {
        sign = "-";
    }
    if (primitiveOperand.PrimitiveType == PrimitiveType.Identifier) {
        powerShellExpressionBlock.AddExpression(new PsAstExprPrimitive(sign + primitiveOperand.Image, PsAstPrimitiveType.LocalObject));
    } else {
        powerShellExpressionBlock.AddExpression(new PsAstExprPrimitive(sign + primitiveOperand.Image));
    }
    break;
```

**After:**
```csharp
case UnaryOperator.Negative:
case UnaryOperator.Positive:
    SymstreamExpressionPrimitive primitiveOperand = operand as SymstreamExpressionPrimitive;
    if (primitiveOperand != null) {
        String sign = String.Empty;
        if (ue.UnaryOperator == UnaryOperator.Negative) {
            sign = "-";
        }
        if (primitiveOperand.PrimitiveType == PrimitiveType.Identifier) {
            powerShellExpressionBlock.AddExpression(new PsAstExprPrimitive(sign + primitiveOperand.Image, PsAstPrimitiveType.LocalObject));
        } else {
            powerShellExpressionBlock.AddExpression(new PsAstExprPrimitive(sign + primitiveOperand.Image));
        }
    } else {
        // non-primitive operand: emit (0 - expr) or (0 + expr)
        PsAstExprBlock migratedOperand = Migrate(operand);
        PSAstOperatorType op = ue.UnaryOperator == UnaryOperator.Negative ? PSAstOperatorType.Substract : PSAstOperatorType.Add;
        powerShellExpressionBlock.AddExpression(new PsAstExprParenthesized(new PsAstExprBinaryOperator(new PsAstExprPrimitive("0"), op, migratedOperand)));
    }
    break;
```

---

## Validation scenarios (recommended re-run)

- `*DEFINE` closed by deprecated `*End`
- `*DEFINE` containing nested `*IF` closed by `*End`, then a second `*End` for `*DEFINE`
- `*DO` closed by deprecated `*End`
- Normal `*DEFINE` closed by explicit `*ENDDEFINE` (regression check)
- Expression with unary `-` before a bracketed reference: `-[key,1,2,2]`
- Expression with `[rsz,1,1,1] - [key,1,2,2]` (binary — should be unaffected)

## Known pre-existing issues (not fixed here)

- None remaining from the original ERROR-A/B/C set.

---

## Fix 4 — IndexOutOfRange: whitespace-only line reaches expression parser

**Error:** `Index was outside the bounds of the array` at `System.String.get_Chars`

**Root cause:** Two guards used `String.IsNullOrEmpty` instead of `String.IsNullOrWhiteSpace`:
1. `RemoveEmpty()` in `SymstreamProcessor.cs` kept whitespace-only `splitParameters` entries.
2. The DataLine path in `Convert()` used `!String.IsNullOrEmpty(lines[i])` — a line containing only spaces passed the check, then `SymstreamExpressionToPowerShellExpression` was called, `Parse()` trimmed it to `""`, and `text[0]` crashed.

**Files:**
- `SsgConverter\SsgConverter\SymstreamProcessor.cs`
- `SsgConverter\SsgConverter\SymstreamExpressionParser.cs`

**Changes:**

`SymstreamProcessor.cs` — `RemoveEmpty()` (~line 365):
```csharp
// before:
if (!String.IsNullOrEmpty(s)) {
// after:
if (!String.IsNullOrWhiteSpace(s)) {
```

`SymstreamProcessor.cs` — DataLine path (~line 1912):
```csharp
// before:
} else if (!String.IsNullOrEmpty(lines[i])) {
// after:
} else if (!String.IsNullOrWhiteSpace(lines[i])) {
```

`SymstreamExpressionParser.cs` — `Parse()` post-trim guard (~line 30):
```csharp
text = text.Trim();
// added:
if (String.IsNullOrEmpty(text)) {
    throw new ArgumentException("The expression text may not be null or empty.");
}
```

---

## Fix 5 — "expression text may not be null or empty": unary recursion on dash-separator strings

**Error:** `The expression text may not be null or empty`

**Root cause:** COBOL separator comment lines (e.g. `*---------- LECTURE ---`) were treated as DEFINE call parameters. One parameter `"-------------------"` was parsed as a nested unary `-` chain: Parse("---") → operand="--" → Parse("--") → operand="-" → Parse("-") → operand="" → Parse("") → throws. The bracketed section also had a potential empty `right` passed to `Parse()`.

**Files:**
- `SsgConverter\SsgConverter\SymstreamExpressionParser.cs`

**Changes:**

Unary `-` and `+` guards (~lines 301, 315): only recurse if operand is non-whitespace:
```csharp
// before:
if (match.Success) {
    String operand = text.Substring(match.Index + match.Length);
    SymstreamExpression exprOperand = Parse(operand, ...);
// after:
if (match.Success) {
    String operand = text.Substring(match.Index + match.Length);
    if (!String.IsNullOrWhiteSpace(operand)) {
        SymstreamExpression exprOperand = Parse(operand, ...);
        return new SymstreamExpressionUnary(...);
    }
}
// falls through to primitive (literal string) when operand is empty
```

Bracketed section `right` guard (~line 279): when `right` is empty after rewrite, return `exprLeft` instead of calling `Parse("")`:
```csharp
SymstreamExpression exprLeft = Parse(left, ...);
if (String.IsNullOrEmpty(right)) { return exprLeft; }  // added
SymstreamExpression exprRight = Parse(right, ...);
```

---

## Os2200ContentConverter — ECL pipeline guards (Fix 6)

**File:** `SsgConverterConsole\Os2200ContentConverter.cs`

Both `parser.Parse()` and `migrator.MigrateStatements()` wrapped in `try-catch` to prevent ECL pipeline crashes from failing the entire SSG file conversion. On catch, a warning is logged and the content block is emitted as a comment instead.

---

## Fix 7 — GUI: MigFileAppender NullReferenceException on conversion (2026-08-21)

**Error:** `System.NullReferenceException` in `MigFileAppender.WriteStart` → `logger.Error` in outer catch

**Root cause:** The GUI called `logger.Start(1)` / `logger.ThreadStarted(0)` BEFORE `Program.RunConversion`
added the `MigFileAppender`. `MigFileAppender` never received the Start signal → internal `StreamWriter`
was null → NullRef on first write. Also, the outer catch's `logger.Error()` call was unguarded, so a
secondary NullRef propagated as an unhandled exception that crashed the GUI silently (pre-fix-6).

**Files changed:**
- `SsgConverterConsole\Program.cs` — always call `Start`/`ThreadStarted` after all appenders added (not
  just when `ownLogger=true`); guard outer-catch `logger.Error` with its own try-catch.
- `SsgConverterGui\MainWindow.xaml.cs` — removed the duplicate `logger.Start(1)` / `logger.ThreadStarted(0)`
  calls that pre-empted the Start signal before the file appender was added.

**Also fixed in same session (2026-08-21):**
- `App.xaml.cs` — added `DispatcherUnhandledException` handler so future unhandled exceptions show a
  `MessageBox` rather than silently closing the window.
- `MainWindow.xaml.cs` — `ConvertButton_Click` now wraps `await Task.Run` in try-catch with `MessageBox`.
- `MainWindow.xaml.cs` — added `LoadSettingsFromFile(path)` public method; constructor reads
  `Environment.GetCommandLineArgs()[1]` after `InitializeComponent` so settings pre-fill reliably
  from both cmd.exe and PowerShell (`&` operator required in PS).

**Launch with settings pre-loaded:**

cmd.exe:
```
"C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\SsgConverter\SsgConverter\SsgConverterGui\bin\Debug\net10.0-windows\SsgConverterGui.exe" "C:\Amt\Migration\Trial3\settings\SSGConverterSettings_20260821_1.settings"
```

PowerShell:
```powershell
& 'C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\SsgConverter\SsgConverter\SsgConverterGui\bin\Debug\net10.0-windows\SsgConverterGui.exe' 'C:\Amt\Migration\Trial3\settings\SSGConverterSettings_20260821_1.settings'
```
