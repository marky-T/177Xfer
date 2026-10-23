# SsgConverter change list for R&D review

Date: 2026-10-14. Prepared by the SSG-4 trial team. For review by R&D.

## 1. What this is

The SsgConverter (SSG to PowerShell) has been taken forward in the ProjectOct2026 trial since R&D handed it over in July.
This package contains every source file we changed, a patch against R&D `develop`, and this list.
It is a proposal for review, not a request to merge as is.

- **Only the stand-alone SsgConverter is touched** (library, console, GUI). The ECL converter is **not** part of this package.
  The ECL converter project references the SsgConverter library project, so a build that picks up the patched library gets the fixes with no change to the ECL converter.
- **Merge base:** `SsgConverter Jul27 from AMT178release.zip` (R&D's own 27 July source). `develop` differs from it only in `SymstreamProcessor.cs` (+15/-12, the `hasExplicitFrom/To` change, C-18 below, and a data-line change, see C-13).
  The 21 August release we worked from (`SsgConverter-Release-20260821.zip`) has identical source to our 8 September import.
- **Not sent:** the three `.csproj` files (ours differ only so it builds on our VM: shipped `_deps` binaries, no signing). `KI-1`, `KI-2`, `KI-3` of the 20 August fix log are unchanged.
- **Files (7):** `SymstreamProcessor.cs`, `SymstreamExpressionMigrator.cs`, `SymstreamExpressionParser.cs`, `SsgConverterConsole/Os2200ContentConverter.cs`, `SsgConverterConsole/Program.cs`, `SsgConverterGui/App.xaml.cs`, `SsgConverterGui/MainWindow.xaml.cs`. In the package they sit at R&D's paths under `Migration Tools/SsgConverter/`.
- **Applying:** from `Migration Tools/SsgConverter` run `git apply -p1 --ignore-whitespace SsgConverter-vs-develop.patch`. Our files use CRLF line endings, as the `develop` clone we compared with. Applying the patch to a scratch copy of `develop` reproduces all 7 files byte for byte (checked by `Trials/New-RnDPackage.ps1`).

## 2. The changes

Origin: **A** = made 20-21 Aug, described in `SsgConverter-Fix-20260820.md`; **B** = present in the 21 Aug release code but not described in that log (we know them from the code comments only); **C** = made since 8 Sept, tracked as `T3-nnn` in our issue register; **D** = taken from R&D `develop`.

| ID | Origin | File | Change | Why / evidence |
|----|--------|------|--------|----------------|
| C-01 | A (Fix 1, 2) | Processor | The deprecated `*End` is accepted as the terminator of `*DEFINE` and `*DO` blocks, as well as `*ENDDEFINE` / `*ENDDO`. | Without it a skeleton fails with `This is unexpected. DirectiveId: End`. With R&D `develop`'s library 15 of our 20 example skeletons fail this way. |
| C-02 | A (Fix 3) | Migrator | A unary `+`/`-` in front of a non-primitive operand emits `(0 - expr)` / `(0 + expr)` instead of throwing `SymstreamExpressionPrimitive expected`. | Reported error B from the R&D thread. |
| C-03 | A (Fix 4, 5) | Parser, Processor | Empty or whitespace-only text or operand no longer reaches the expression parser: an empty-text guard; the six comparison operators and unary `-`/`+` only recurse when an operand exists; `A +` with an empty right side returns the left side; `RemoveEmpty` drops whitespace-only entries. | `IndexOutOfRange` and `expression text may not be null or empty` on lines of dashes or spaces. |
| C-04 | A (Fix 6) | Os2200ContentConverter | Parsing or migrating an ECL block inside an SSG file is wrapped in try/catch: a warning is logged and the block is skipped instead of failing the whole file. | ECL pipeline crash failed whole SSG files. |
| C-05 | A (Fix 7) | Console `Program.cs`, GUI `App.xaml.cs`, `MainWindow.xaml.cs` | Logger started after all appenders are added (also in the GUI); unique log file name per run; guarded error logging; GUI shows unhandled errors and accepts a settings file on the command line; console warns when a file has no SSG directives. | `NullReferenceException` in `MigFileAppender` when converting from the GUI. |
| C-06 | B | Processor | An expression that fails to parse or migrate is rethrown with the file name and the expression text. | Diagnosability only; the error is still an error. |
| C-07 | B | Processor | A directive the converter does not implement (`default` case of the directive switch) now logs a warning and emits `# NOT IMPLEMENTED: <line>` instead of aborting the file. | Lets a file convert with the gap marked. Note: every `DirectiveId` currently has its own `case`, so only a malformed `*MULTIPLY` reaches this today; the nine directives marked "not used in STA sources" still throw `This is unexpected` (see section 5). |
| C-08 | B | Processor | `*MULTIPLY n BY m GIVING v` is implemented (it threw before); other forms fall back to C-07. | |
| C-09 | B | Processor | `*REMOVE VARIABLE name` is implemented. | |
| C-10 | B | Processor | `*SORT` no longer throws when the name field contains a comma. | |
| C-11 | B | Processor | `*ITERATE` on an outer loop variable logs an `IMPORTANT-WORKAROUND` error and emits a comment instead of throwing. **Known limitation: the loop body is not skipped.** PowerShell has no labelled `continue`. | Seen in ECLAT. Needs an R&D decision. |
| C-12 | B | Parser | `IsSearchConditional` also requires the word `SEARCH`, so identifiers starting with `ROW`, `COLUMN` or `KEYWORD` are not taken for a search condition. | |
| C-13 | C (T3-001) | Processor, Migrator | **Output (data) lines are emitted as literal text** with only `[bracketed]` references converted, using the variable context. Before, the whole line was parsed as an SSG expression, which gave invalid PowerShell for any COBOL line with `-`, `+`, `(` or similar (103 to 248 parse errors per file in the first five examples). `SplitBracketedReferencesAndLiteralParts` is made public for this. | `develop` has fixed the same defect with `WrapSgsReferencesInFunctionCalls`, which has no variable context. With the `develop` library, 3 of the 5 example files that convert still have parse errors (ARCHISEPARE 30, CONDIS2_ASCII 68, EXTEUR 118); we did not isolate whether this is the cause. See also "Blank lines" below. |
| C-14 | C (T3-003) | Processor | `*CLEAR v` emits `$v = 0` (SSG sets the variable to 0) instead of `Clear-Variable $v`, which passed the variable's value as `-Name` and threw when unset. | CHABAN_ASCII, BABA_ASCII. |
| C-15 | C (T3-009) | Processor | `*INCREMENT +I ...`: a leading `+` on the loop variable name is stripped. | CONDIS2_ASCII, EXTEUR. Without it the declared and the compared variable names differ (invalid `For` loop). The `*DO` variable has the same pattern; left alone, no failing case. |
| C-16 | C (T3-025) | Migrator | `*IF VALUE OF [x] = ...`: the text operand `VALUE OF` is dropped so only the reference is compared. | The parser read `VALUE OF` as text joined with `+`, so the test was string against number and never true. FUSBA2_ASCII looped forever. |
| C-17 | C (T3-026) | Processor, Migrator | Inside a `*DEFINE`, `*SET` and `*CLEAR` of a plain variable emit `Set-Variable -Name "X" -Value (...) -Scope 1` (SSG variables are global; a plain assignment in the generated PowerShell function changes a local copy). A define parameter `[#n]` used in arithmetic becomes `[Int64]$Parameters[n-1]` (`$Parameters` are strings, so `"6"+1` gave `"61"`). | FUSBA2_ASCII had no `FILLER` between the key fields (second key at the wrong offset). **Still open:** `*SET [#1] TO ...` (variable named by a parameter) still assigns a local. |
| C-18 | D | Processor | Taken from `develop`: an `*INCREMENT` with explicit `FROM` and `TO` needs no closing `*LOOP`. | No change in our 20 outputs. |

### Blank lines (decision 2026-10-14, T3-001)

The generated PowerShell now contains a `DataLineOrNoStatement ("    ")` call for a whitespace-only line of the skeleton. Basis:

- Unisys SSG Programming Reference Manual 7831 1784-010, section 4.3: every image without `*` in column 1 is sent to the generated output stream (`GOSCNT$` counts it). The manual makes no exception for blank images.
- `develop` already uses `String.IsNullOrEmpty` for this test. Our 21 August release had changed it to `IsNullOrWhiteSpace` (Fix 4, because a whitespace-only line then reached the expression parser). Since C-13 data lines are no longer parsed as expressions, that workaround is not needed.

Effect on our 20 examples: 9 outputs gain blank lines (ARCHISEPARE, BABA_ASCII, CFH-COPY, EXTEUR, LECTIS_ASCII, LOADIS_ASCII, RECAP, TAPELD_ASCII, UNLOADIS_ASCII). In the generated COBOL this only adds blank lines and shifts line numbers.
Lines that are completely empty (zero length) are still skipped. By the manual they should be output too. We have left that as it is in `develop`.

## 3. Test evidence

Run on 2026-10-14 with the library built from the files in this package.

| Check | Result |
|-------|--------|
| 20 example skeletons (the 20 ProjectOct2026 programs in scope) converted | 20 succeeded, 0 failed |
| PowerShell parse check of the 20 outputs | 0 errors in all 20 |
| Same 20 converted with `develop`'s three library files (our console as host) | 5 converted, 15 failed (`DirectiveId: End`); of the 5, 2 parse clean, 3 have 30, 68, 118 parse errors |
| Tier-1 mock harness (the output runs against a mock of the AMT PowerShell runtime) | 20 of 20 run |
| Programs generated through the Lion pipeline from the converted skeletons | 6 programs, 6 generated, 0 not generated |
| CFH-COPY_ASCII, real AMT runtime, output compared with an independently built reference | identical (25 records) |
| FUSBA2_ASCII, merge of key-ordered records, compared with an independently built expected file | identical (9,672 bytes) |
| LOADIS_ASCII then UNLOADIS_ASCII round trip, 40 records, ascending keys | identical (8,240 bytes) |
| LECTIS_ASCII, VIRD03, CLOA43 smoke runs | load, open files, end with exit code 0 |
| RECAP | fails at run time, **not** a converter defect: it reads an RDMS database and the COBOL converter turns the database statements into comments (our issue T3-027, out of scope for now) |

Our 20 skeletons are the ProjectOct2026 SSG-in-COBOL programs of the trial. The only R&D sample we hold, the four `Y2K*` outputs in `Cobol SSG.zip`, matches our output for the one input we have (`ASSURFED_UTILIT_Y2KCLR_PRD`) except for the `(P)` in the header comment.

## 4. Questions for R&D

1. Does the R&D converter have the same defects as C-16 (`VALUE OF`) and C-17 (variables set inside a define, `[#n]` as text)? Both silently produce wrong output rather than an error.
2. Is the data-line approach of C-13 acceptable, or should `develop`'s `WrapSgsReferencesInFunctionCalls` be extended with the variable context instead?
3. Blank lines: should completely empty skeleton lines be output as well (manual section 4.3)?
4. The manual's column-1 conversion of `PILOCHAR$` (`"` to `*`) is not implemented (`NSIGNCHAR$` is). None of our 20 files uses it.
5. C-11 (`*ITERATE` on an outer loop): is a labelled loop or a flag the intended conversion?
   - Background: `*ITERATE A` skips the rest of this pass of loop `A` and goes on with its next pass. When `A` is an outer loop and the `*ITERATE` sits inside an inner loop, the rest of the inner loop must be abandoned and the outer loop must continue. A plain PowerShell `continue` only affects the innermost loop.
   - Today (C-11) the converter logs an `IMPORTANT-WORKAROUND` message and writes the `*ITERATE` as a comment. The converted program then keeps running the rest of the inner loop, where SSG would have skipped it, so the output can be wrong. We saw this in ECLAT.
   - Option 1, labelled loop: name the outer loop and continue to that name, for example `:outerA for (...) { ... continue outerA }`. The comment in the code says PowerShell has no labelled continue; we believe it has, but have not tried it with this converter's code writer.
   - Option 2, flag variable: the inner `*ITERATE` sets a flag and leaves the inner loop; straight after the inner loop the outer loop tests the flag and does its own `continue`.
   - We have not chosen, because it has to fit how your code writer builds loops. It only matters when a remaining program uses `*ITERATE` on an outer loop.
6. Outside the converter, found while testing the generated programs: the AMT runtime accepts out-of-order keys on a sequential load into an indexed file and drops the records silently (COBOL raises `INVALID KEY`). Is this intended?
7. `CASE$`: six of our skeletons do `*SET CASE$ TO 1` (SSG then returns every string in upper case). The converter emits `$Rgv_CASE = 1` and nothing reads it, neither the converter nor the AMT PowerShell runtime library. Should the converter apply it (for instance on the `GetSgsValue` results) or the runtime?
8. `IsComment` (`SymstreamProcessor.cs`, around line 401) accepts white space between `*` and `.`, which your comment says is legal "though the documentation suggests otherwise". Manual 4.4 allows spaces between the asterisk and the directive name, and says a period anywhere on a directive image ends the scan unless it is inside a quoted string. Does the converter apply the period rule to directives other than comments?
9. The comments say several directives are "not used in STA sources" and so are not implemented (`*CORRECT`/`*ENDCORRECT`, `*DUMP`, `*EJECT`, `*LIST`, `*MERGE`, `*RESTORE`, `*SAVE`, `*UNLIST`, `*CLEAR` with a variable named by a reference, parenthesised expressions). `*COPY` is also not implemented (a TODO: "occurs in 2 files only: system\install and system\patch"). What are the STA sources? We want to know which directives to expect in the remaining ProjectOct2026 programs. `*COPY` matters most, because it is how a define packet can come from another element.

## 5. Next updates (not in this package)

To be made as the remaining programs are converted:

- **C-19, reserved variables.** Fill the `m_SystemVariables` table in `SymstreamProcessor.cs` (lines 49-96) from manual Table 3-9: the initial values (`ADD_GOS$` 1, `IMGLEN$` 80, `SSGSGS$` 9, `TCFNAME$` 1, `UNS_CONTROL$` -1, `STARTCHAR$`, `STOPCHAR$` and `STRINGCHAR$` `.`, 0 for the counters and switches) and add the missing `FEATURE_LEVEL$`, `FLD$`, `PILOCHAR$`, `PROCESS_LEVEL$` and `UTC$`. Only `NSIGN$` and `NSIGNCHAR$` are read today, so this changes none of the current outputs.
- **`CASE$`** (question 7): to be decided with R&D, then applied.
- **Directives marked "not used in STA sources", and `*COPY`** (question 9): implement each as soon as a ProjectOct2026 program uses it. Until then a program using one stops with `This is unexpected` for that directive. `*COPY` is the likeliest to be needed; none of our 20 skeletons uses it.
- **Open from our register:** `*SET [#1] TO ...` assigns a local (T3-026), `*DO` variable with a leading `+` (T3-009), `*ITERATE` on an outer loop (C-11), `PILOCHAR$`, completely empty lines.
- **Parked, low priority:** the converter does not warn when a `*name` call (the implicit `*PROCESS` of manual 5.2.34) names a define that is not in the file. The conversion itself is correct. We will reconsider a warning ("not defined in this file") together with `*COPY` and a coverage report of unimplemented directives and reserved variables set without effect.
