# SsgConverter — Copilot Instructions

This file provides context for GitHub Copilot (or any AI assistant) working with the
**SsgConverter** package. When a developer asks questions about this tool, use the information
below to answer accurately without searching the internet.

---

## How Copilot can help — prompt on first load

After reading this file, introduce yourself to the developer with a brief summary and offer:

> I've loaded the SsgConverter Copilot instructions. I can help you with:
>
> - **Run the tool** — launch the GUI or console with the example settings
> - **Build from source** — dotnet build instructions and dependency notes
> - **Debug conversion output** — interpret warnings, errors, and IMPORTANT-WORKAROUND messages
> - **Understand a specific error** — paste the error and I'll explain root cause and fix
> - **Extend or fix the codebase** — navigate source projects, apply fixes, add directives
> - **Security / CI** — exit codes, safe execution of generated scripts, automation guidance
>
> What would you like to do?

---

## What this tool does

SsgConverter converts **SSG (Symbiont Stream Generator) skeleton files** — OS2200 `.TXT` source
files containing `*IF`, `*SET`, `*DEFINE`, `*LOOP` etc. directives — into **PowerShell `.ps1`
scripts** using the AMT PowerShell runtime library (`GetSgsValue`, `DataLineOrNoStatement`,
`CompareTypeSafe`, `Sort-SgsList`, etc.).

It does NOT convert:
- Plain COBOL programs (which produce mostly `# Orphaned data line:` output — this is expected)
- ECL runstream commands (`#asg`, `#delete`, `#xqt`) — captured as `# Embedded content (unconverted):` comments
- PowerShell batch/job orchestration — that is the SsgConverter's PowerShell output target, not input

---

## Source project structure

```
Source\
  SsgConverter\              ← core library — SymstreamProcessor.cs, SymstreamExpressionParser.cs,
                               SymstreamExpressionMigrator.cs, Expressions\, Enums\
  SsgConverterConsole\       ← console entry point — Program.cs, Os2200ContentConverter.cs,
                               SsgSettingsSupport.cs, SsgConversionSettings.cs
  SsgConverterGui\           ← WPF GUI — MainWindow.xaml.cs, App.xaml.cs, UiLogAppender.cs, LogItem.cs
  _deps\                     ← AMT migration support DLLs (not on NuGet — do not remove)
  SsgConverter.slnx          ← solution file
```

There is **no automated test project** in this package. The "36 succeeded, 0 failed" result in
`Fixes\SsgConverter-Fix-20260820.md` refers to 36 SSG source files processed through the converter
as an integration validation run, not a unit test suite.

---

## Prerequisites and version note

- **.NET SDK 10.0.203** — required to **build** from source
- Pre-built binaries in `Build\Console\` and `Build\Gui\` — **no SDK needed to run**

**Version note:** `8.0.26188.0` is the **AMT product build number** (the version of the
migration support libraries in `_deps\`). `.NET SDK 10.0.203` is the separate **.NET runtime
version** used to compile and run the converter. These are independent versioning schemes.

---

## Build from source

```
dotnet build Source\SsgConverter.slnx -c Debug
```

All required DLLs are in `Source\_deps\`. Do not remove them — they are the AMT migration support
libraries and are not available on NuGet.

---

## Launch — Console

```
Build\Console\SsgConverterConsole.exe /SETTINGSFILE:"Examples\Settings\SsgConverterSettings-example.settings"
```

Or with individual parameters:
```
Build\Console\SsgConverterConsole.exe /INPUT:"<folder>" /OUTPUT:"<folder>" /CONTINUEONERROR:TRUE /VERBOSE:2 /ENABLELOGFILE:TRUE /LOGFILE:"<folder>"
```

### Console exit codes (CI automation)

| Exit code | Meaning |
|-----------|---------|
| `0` | All files converted successfully |
| `1` | One or more files failed, OR a fatal startup error |

**Important:** `/CONTINUEONERROR:TRUE` allows conversion to continue past individual file failures,
but the process still exits with code `1` if any file failed. Check the log for
`Error converting <filename>:` entries even when exit code is `1`.

## Launch — GUI

cmd.exe (pre-loads settings — recommended):
```
Build\Gui\SsgConverterGui.exe "Examples\Settings\SsgConverterSettings-example.settings"
```

PowerShell (`&` is required):
```powershell
& 'Build\Gui\SsgConverterGui.exe' 'Examples\Settings\SsgConverterSettings-example.settings'
```

---

## Input file discovery

- Scans **all files** in the input folder matching `*.*` — **not recursive** (subdirectories ignored)
- Any file extension is accepted; the `LooksLikeSsg` check (first non-empty line starts with `*` or `#`) gates actual processing
- Output `.ps1` files are **overwritten** on each run without warning
- The output folder is created automatically if it does not exist

---

## Settings file format

```xml
<SsgConversionSettings>
  <InputFolder>C:\path\to\ssg\input</InputFolder>
  <OutputFolder>C:\path\to\ps1\output</OutputFolder>
  <ClearOutputFolder>false</ClearOutputFolder>
  <ContinueOnException>true</ContinueOnException>
  <VerboseLevel>2</VerboseLevel>
  <LogFile>C:\path\to\logs\</LogFile>   <!-- folder path → auto-timestamped filename per run -->
  <EnableLogFile>true</EnableLogFile>
</SsgConversionSettings>
```

If `LogFile` is a folder path (no extension), a timestamped log is auto-generated per run.
If it is a full file path, a timestamp is still appended to prevent file-lock errors on re-run.

---

## Understanding the output

### Normal conversion output (good)

```powershell
$A = (2 + (GetSgsValue ("key,1,1,3") + ...))    # *SET computed from SSG parameters
If ((CompareTypeSafe (GetSgsValue ("key,1,2,1")) "EqualTo" 0)) { ... }   # *IF
```

### Expected comments (not errors)

```powershell
# Orphaned data line: FD ficunload.        # COBOL source after #ucob — expected
# Embedded content (unconverted): #asg...  # ECL runstream — expected
# NOT IMPLEMENTED: *someDirective          # Unrecognised directive — continues, not an error
```

### Warning types in log

| Warning | Meaning | Action |
|---------|---------|--------|
| `No SSG directives recognised in 'FILENAME'` | File is plain COBOL with an ECL header, no SSG content | Remove from input folder |
| `Orphaned data line` | COBOL source after `#ucob` — converter working correctly | No action |
| `Missing @FIN statement — auto-appended` | ECL content block has no job terminator — recovers | No action |
| `ECL parse failed for content block` | ECL runstream crashed the pipeline — block skipped | Review output |

### Error (RED in GUI)

```
IMPORTANT-WORKAROUND applied: *ITERATE A targets an outer loop
```

PowerShell has no labelled `continue` — the directive is emitted as a PS comment and is a
**no-op**. The converted `.ps1` is logically different from the original SSG at this point.
See `Fixes\SsgConverter-Fix-20260820.md` Fix 11 for the full R&D specification.

---

## Security — generated script execution

Generated `.ps1` scripts call AMT PowerShell runtime functions (`GetSgsValue`, `DataLineOrNoStatement`,
`CompareTypeSafe`, etc.) which are provided by the AMT PS library (`AmtPsEclLib.psm1` or similar).

- Scripts are **not standalone** — they will fail with "command not found" if the AMT library is not loaded
- Scripts do **not** execute system commands or access the network directly
- SSG parameter values are resolved via `GetSgsValue()` at runtime — they are data values, not injected code
- ECL content blocks that fail conversion are emitted as `#` comments and are inert

Review generated scripts before executing in production. Automated execution requires the AMT PS runtime loaded in the session.

---

## Known issues (do not fix without a confirmed failing test case)

### KI-1 — XOR/OR/AND missing empty-right guard
`SymstreamExpressionParser.cs` — trailing ` OR ` / ` AND ` / ` XOR ` at end of expression produces
`right = ""` → crash. Not triggered by any current test file.

### KI-2 — `*DIVIDE GIVING quotient,remainder` — DEFECT (pre-existing)
`SymstreamProcessor.cs` ~line 795. When `*DIVIDE` specifies two GIVING variables, the modulo result
is assigned to the **quotient variable** (index 0) instead of the remainder variable (index 1).
**This produces incorrect PowerShell output.** Not introduced by the current fix set.
Not triggered by any current test file. **Flagged as defect for R&D prioritisation.**

### KI-3 — Mixed ECL + SSG + COBOL files
Files with an ECL runstream section + SSG `*SET` lines + COBOL source (e.g. `ARCHIFORMAT`):
the SSG `*SET` lines convert correctly; the ECL runstream is captured as comments.
Full ECL conversion requires integrating the ECL converter pipeline — out of scope for this package.

---

## Diagnosing conversion quality

Run with `/VERBOSE:2` and inspect the log for:
- `Error converting <name>:` — hard failure; check the expression context shown
- `IMPORTANT-WORKAROUND applied` — semantic gap; review `.ps1` output manually
- `No SSG directives recognised` — file should not be in the input folder

A properly converted SSG file should have PS variable assignments, `If`/`elseif`/`else` blocks,
`function DEFINE_xxx` definitions, `for` loops, and `GetSgsValue(...)` calls throughout.

---

## Fix log

Full details of all fixes applied to build 8.0.26188.0:
`Fixes\SsgConverter-Fix-20260820.md`

Integration validation result: **36 source files converted, 0 failed** (2026-08-21).
