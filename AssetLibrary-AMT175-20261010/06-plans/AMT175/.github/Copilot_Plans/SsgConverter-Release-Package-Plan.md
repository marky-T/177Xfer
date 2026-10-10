# SsgConverter Release Package Plan

**Goal:** Single zip-ready folder for distribution to another developer.
Contains fixed source, all required dependencies, representative example files, pre-built binaries, and fix documentation.

**Target folder:** `C:\Amt\Migration\SsgConverter-Release-20260821\`

---

## Decisions (confirmed)

1. **Pre-built binaries** — yes, both Console + GUI
2. **Input examples** — one file per SSG/ECL syntax flavour (not all 20; covers all fix scenarios)
3. **README** — yes, `.md`, listing added/fixed features
4. **Settings** — one example `.settings` file with absolute paths (recipient adjusts to their machine)

---

## Folder structure

```
SsgConverter-Release-20260821\
  README.md
  Source\
    SsgConverter\          ← core library (SymstreamProcessor, ExpressionParser, ExpressionMigrator)
    SsgConverterConsole\   ← console app (Program, Os2200ContentConverter)
    SsgConverterGui\       ← GUI app (MainWindow, App)
    SsgConverter.slnx
    _deps\                 ← all 35 shared DLLs required for build
  Build\
    Console\               ← SsgConverterConsole\bin\Debug\net10.0\ (pre-built)
    Gui\                   ← SsgConverterGui\bin\Debug\net10.0-windows\ (pre-built)
  Examples\
    Input\                 ← representative SSG source files (see selection below)
    Settings\
      SsgConverterSettings-example.settings
    Output\                ← pre-generated .ps1 output for comparison
  Fixes\
    SsgConverter-Fix-20260820.md
```

---

## Example input file selection

One file per syntax flavour so all fix scenarios are covered:

| File | Flavour / fix covered |
|------|-----------------------|
| `ARCHISEPARE.TXT` | `*End` as DEFINE/DO terminator (Fix 1+2), unary non-primitive (Fix 3), whitespace lines (Fix 4), dash-separator strings (Fix 5), ECL content block (Fix 6) |
| `CFH-COPY.TXT` | Simpler SSG — baseline/regression check |
| `UNLOADIS_ASCII.TXT` | Known-good pilot output — covers ASCII variant + DISC branch |
| `CHABAN_ASCII.TXT` | Known-good pilot — covers NUMB/MOD/FLDSEL param overrides |
| `BABA_ASCII.TXT` | New program (no Trial 2 equivalent) — broader SSG coverage |

Source: `C:\Amt\Migration\Trial3\SSGConverter_Input\`

---

## README contents (to be authored at build time)

- Overview: what the converter does
- Prerequisites: .NET SDK 10.0.203 (for building from source)
- Build: `dotnet build SsgConverter.slnx`
- Launch (Console): command-line syntax + `/SETTINGSFILE` option
- Launch (GUI): cmd.exe and PowerShell launch with pre-loaded settings
- Added/fixed features (from `Fixes\SsgConverter-Fix-20260820.md`):
  - Fix 1+2: deprecated `*End` accepted as `*DEFINE`/`*DO` terminator
  - Fix 3: unary sign with non-primitive operand emits `(0 ± expr)` 
  - Fix 4: whitespace-only lines no longer crash expression parser
  - Fix 5: dash-separator strings (`---`) treated as literal string
  - Fix 6: ECL pipeline crash on COBOL content is caught gracefully
  - Fix 7: GUI file appender NullRef fixed; logger lifecycle corrected
  - Fix 8: GUI silent crash replaced with MessageBox error display
  - Fix 9: GUI settings pre-fill from command-line arg on launch
  - Fix 10: repeated Convert clicks no longer fail with locked log file

---

## Build steps (when ready to execute)

1. Create `SsgConverter-Release-20260821\` folder tree
2. Robocopy source (exclude `bin\`, `obj\`, `.vs\`)
3. Copy `_deps\` in full
4. `dotnet build` to produce fresh binaries, then copy to `Build\`
5. Copy 5 selected input files → `Examples\Input\`
6. Copy + edit `SSGConverterSettings_20260821_1.settings` → `Examples\Settings\SsgConverterSettings-example.settings`
7. Run console against example inputs → copy `.ps1` output → `Examples\Output\`
8. Copy `SsgConverter-Fix-20260820.md` → `Fixes\`
9. Author `README.md`
10. Zip → `SsgConverter-Release-20260821.zip`

---

## Status: PLAN — not yet executed

## Change log
- 2026-08-21 — Plan created; decisions confirmed; deferred pending further SsgConverter error fixes
