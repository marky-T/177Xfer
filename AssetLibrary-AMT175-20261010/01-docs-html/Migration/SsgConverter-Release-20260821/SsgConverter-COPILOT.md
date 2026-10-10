# SsgConverter — Copilot Instructions

This file provides context for GitHub Copilot (or any AI assistant) working with the
**SsgConverter** package. When a developer asks questions about this tool, use the information
below to answer accurately without searching the internet.

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

## Prerequisites

- **.NET SDK 10.0.203** — required to build from source (enforced by `global.json` if present)
- Pre-built binaries in `Build\Console\` and `Build\Gui\` — no build needed to run

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

## Launch — GUI

cmd.exe (pre-loads settings):
```
Build\Gui\SsgConverterGui.exe "Examples\Settings\SsgConverterSettings-example.settings"
```

PowerShell (`&` is required):
```powershell
& 'Build\Gui\SsgConverterGui.exe' 'Examples\Settings\SsgConverterSettings-example.settings'
```

---

## Settings file format

```xml
<SsgConversionSettings>
  <InputFolder>C:\path\to\ssg\input</InputFolder>
  <OutputFolder>C:\path\to\ps1\output</OutputFolder>
  <ClearOutputFolder>false</ClearOutputFolder>
  <ContinueOnException>true</ContinueOnException>
  <VerboseLevel>2</VerboseLevel>
  <LogFile>C:\path\to\logs\</LogFile>   <!-- folder → auto-timestamped filename -->
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
| `No SSG directives recognised in 'FILENAME'` | File is plain COBOL with an ECL header, no SSG content to convert | Remove from input folder |
| `Orphaned data line` | COBOL source after `#ucob` — converter is working correctly | No action |
| `Missing @FIN statement — auto-appended` | ECL content block has no job terminator — converter recovers | No action |
| `ECL parse failed for content block` | ECL runstream in file caused a pipeline crash — block skipped | Review output; may need ECL converter |

### Error (RED in GUI)

```
IMPORTANT-WORKAROUND applied: *ITERATE A targets an outer loop
```

This means a `*ITERATE <varname>` directive targets an **outer loop variable**. PowerShell has no
labelled `continue` — the directive is emitted as a PS comment and is a **no-op**. The converted
`.ps1` is logically different from the original SSG at this point. See `Fixes\SsgConverter-Fix-20260820.md`
Fix 11 for the full R&D specification of the proper fix.

---

## Known issues (do not fix without a confirmed failing test case)

### KI-1 — XOR/OR/AND missing empty-right guard
`SymstreamExpressionParser.cs` — if an expression ends with a trailing ` OR `, ` AND `, or ` XOR `
(malformed SSG), `right = ""` and `Parse("")` would throw. Not triggered by any current test file.

### KI-2 — `*DIVIDE GIVING quotient,remainder` assigns modulo to wrong variable
`SymstreamProcessor.cs` ~line 795 (pre-existing). The second variable gets the same value as the
first. Not triggered by any current test file.

### KI-3 — Mixed ECL + SSG + COBOL files
Files like `ASSURFED_UTILIT_ARCHIFORMAT(P)` have an ECL runstream section + SSG `*SET` lines +
COBOL source. The SSG `*SET` lines ARE converted correctly. The ECL section is captured as
`# Embedded content (unconverted):` comments. Full ECL conversion requires integrating the ECL
converter pipeline — out of scope for this package.

---

## Diagnosing conversion quality

Run the console with `/VERBOSE:2` and inspect the log for:
- `Error converting <name>:` — hard failure; check the expression context shown
- `IMPORTANT-WORKAROUND applied` — semantic gap; review the `.ps1` output manually
- `No SSG directives recognised` — file should not be in the input folder
- Count of `# Orphaned data line:` vs active PS statements — high ratio = plain COBOL file

A properly converted SSG file should have:
- PS variable assignments (`$VAR = ...`) for each `*SET`
- `If`/`elseif`/`else` blocks for `*IF`/`*ELSEIF`/`*ELSE`
- Function definitions (`function DEFINE_xxx`) for `*DEFINE`
- `for` loops for `*INCREMENT`/`*DO`
- `GetSgsValue(...)` calls for each `[token,x,y,z]` SSG parameter reference

---

## Fix log

Full details of all 11 fixes applied to build 8.0.26188.0:
`Fixes\SsgConverter-Fix-20260820.md`

Full test result: **36 succeeded, 0 failed** (2026-08-21, build 8.0.26188.0).
