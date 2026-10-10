# Plan: Build the SSG Converter solution (minimal deps)

**Reference:** SSG-BUILD
**Date:** 260810
**Status:** DONE 260810 — full `SsgConverter.slnx` builds (0 warnings / 0 errors). Core + Console + GUI produced.
**Raised by:** MT
**Related:** AMT175 MigrationTools; `EclToPowerShellGui.7z`, `SsgConverter.zip`
**Reuses:** existing extracted solution at `MigrationTools\SsgConverter\SsgConverter\`

---

## Goal

Build `MigrationTools\SsgConverter\SsgConverter\SsgConverter.slnx` (net10.0) by
unzipping **only** the migration-tool archives that supply its required dependency
projects. Standalone tool — **not** part of the AMT175 install/runtime workflow.

---

## Verified facts (research complete)

- Inner solution root: `MigrationTools\SsgConverter\SsgConverter\`
  - Projects on disk: `SsgConverter` (lib), `SsgConverterConsole` (exe), `SsgConverterGui` (WPF, net10.0-windows)
- `dgspec.json` in `obj\` is **stale** (empty project refs) — predates current source. Old `bin`/`obj` do not reflect current csproj.
- Source truly needs external namespaces → projects:

  | Namespace | Project |
  |-----------|---------|
  | `PowerShell.Generator` | PowerShellGenerator |
  | `PowerShellWriter` | PowerShellWriter |
  | `Avanade.LtCoE.MigSupport` | ConverterSupport |
  | `Ecl.Parser`, `Ecl.Parser.Os2200` | EclParser, EclParserOs2200 |
  | `Ecl.ToAst`, `Ecl.ToAst.Os2200` | EclToAst, EclToAstOs2200 |

- csproj `ProjectReference`s (build-authoritative) expect deps at:
  - `MigrationTools\SsgConverter\ConverterSupport`
  - `MigrationTools\SsgConverter\PowerShellGenerator`
  - `MigrationTools\SsgConverter\PowerShellWriter`
  - `MigrationTools\SsgConverter\EclConverter\EclParserOs2200`
  - `MigrationTools\SsgConverter\EclConverter\EclToAstOs2200`
- `.slnx` (display only) **disagrees**: lists Ecl projects under `EclToPowershell\` and adds Amt.net libs `Asysco.Amt.AmtSharedDataModel`, `Asysco.Amt.Libs` → **path mismatch to resolve**.
- All 3 csproj: `SignAssembly=true`, key `..\..\..\amt.net\security\signingkeys\sourceproprietary.snk`, Compile `..\..\..\Amt.Net\AmtAssemblyInfo.cs`, `ManagePackageVersionsCentrally=true` → need `MigrationTools\Amt.net\` tree (snk + AmtAssemblyInfo.cs) and a `Directory.Packages.props` up the tree.
- None of the above currently exists on disk (file_search = none).
- Likely single source archive for shared deps: `EclToPowerShellGui.7z` (ConverterSupport is shared, may also appear in other converter archives).

---

## Steps

| # | Step | Depends on |
|---|------|-----------|
| 1 | **Discovery-A** — list `SsgConverter.zip`. If self-contained (has ConverterSupport/PowerShell*/Ecl*/Amt.net), build from a clean extract of it. *(fast win)* | — |
| 2 | **Discovery-B** — list `EclToPowerShellGui.7z` (+ other .7z if needed) to locate each required `.csproj`, `Amt.net`, snk, `Directory.Packages.props`; note real folder names (`EclConverter` vs `EclToPowershell`). | 1 |
| 3 | **Extract minimally** into `MigrationTools\` so relative paths resolve: `SsgConverter\{ConverterSupport,PowerShellGenerator,PowerShellWriter,PowerShellSyntax}`, `SsgConverter\EclConverter\{EclParser,EclParserOs2200,EclToAst,EclToAstOs2200}`, `Amt.net\...` (libs + AmtAssemblyInfo.cs + signingkeys\sourceproprietary.snk), plus `Directory.Packages.props`/`Directory.Build.*`. | 2 |
| 4 | **Reconcile path mismatch** — align on-disk folders to csproj refs (authoritative). If archive uses `EclToPowershell\`, place under `EclConverter\` or fix the 2 `ProjectReference` paths in `SsgConverterConsole.csproj`; optionally align `.slnx`. | 3 |
| 5 | `dotnet restore` then `dotnet build SsgConverter.slnx -c Debug`; iterate on missing transitive refs / packages. | 4 |
| 6 | **Fallback** — if signing key unavailable: set `SignAssembly=false` (documented deviation). | 5 |

---

## Relevant files

- `MigrationTools\SsgConverter\SsgConverter\SsgConverter.slnx` — solution
- `...\SsgConverter\SsgConverter.csproj` — refs PowerShellGenerator, ConverterSupport
- `...\SsgConverterConsole\SsgConverterConsole.csproj` — refs EclConverter\EclToAstOs2200, EclConverter\EclParserOs2200, ConverterSupport, PowerShellWriter
- `...\SsgConverterGui\SsgConverterGui.csproj` — refs SsgConverter, SsgConverterConsole, ConverterSupport (WPF)
- Archives: `MigrationTools\EclToPowerShellGui.7z`, `MigrationTools\SsgConverter.zip`

---

## Verification

1. `dotnet build ...\SsgConverter.slnx -c Debug` → **0 errors**.
2. Outputs exist:
   - `SsgConverter\bin\Debug\net10.0\SsgConverter.dll`
   - `SsgConverterConsole\bin\Debug\net10.0\SsgConverterConsole.dll`
   - `SsgConverterGui\bin\Debug\net10.0-windows\SsgConverterGui.dll`
3. Smoke: run `SsgConverterConsole` (`--help`) with no missing-assembly errors.

---

## Decisions / scope

- **In scope:** unzip minimal required archives + build the 3 SSG projects.
- **Out of scope:** AMT175 runtime, other converters, code changes beyond fixing `ProjectReference`/`.slnx` paths (and snk fallback if key missing).

---

## Further considerations

1. Try `SsgConverter.zip` as a self-contained full solution first? **Rec: YES** (cheap check) — Option A; else `EclToPowerShellGui.7z` — Option B.
2. Fix path mismatch by moving folders vs editing csproj paths? **Rec: edit csproj** to match archive layout (fewer copies).
3. Build all 3 projects incl. WPF GUI, or console+lib only? **Rec: all 3** (Windows host supports WPF).

---

## Findings (as-built, 260810)

- `7z.exe` is **blocked** by Avanade Endpoint Privilege Management (vulnerable-version block). Workaround: Windows `tar.exe` (libarchive) reads/extracts `.7z` without privilege.
- `SsgConverter.zip` = the **same 3 projects only** (not self-contained). Option A dead.
- The migration-tool `.7z` archives are **published binaries** (DLLs + `runtimes/` + locales), **not source** — no `.csproj`/`.slnx`/`.snk`/source anywhere.
- Namespace → assembly availability (scanned `EclToPowerShellGui.7z`, `JclConverter*.7z`):

  | Namespace (needed by) | Assembly | Available? |
  |---|---|---|
  | `PowerShell.Generator` (core, console) | `PowerShellGenerator.dll` | ✅ EclToPowerShellGui.7z |
  | `Avanade.LtCoE.MigSupport` (core, console, gui) | `ConverterSupport.dll` | ✅ EclToPowerShellGui.7z |
  | `PowerShellWriter` (console) | `PowerShellWriter.dll` | ✅ JclConverter*.7z |
  | `Ecl.Parser.Os2200` (console) | — | ❌ not in any scanned archive |
  | `Ecl.ToAst` (console) | — | ❌ not found |
  | `Ecl.ToAst.Os2200` (console) | — | ❌ not found |

- **Core `SsgConverter.dll` is buildable** via DLL references (both deps present).
- **`SsgConverterConsole` + `SsgConverterGui` are BLOCKED** — the OS2200 ECL front-end (`Ecl.Parser.Os2200`, `Ecl.ToAst`, `Ecl.ToAst.Os2200`) is not shipped as source or binary in the available archives.
- Staging extracts: `temp\ecl2ps\` (EclToPowerShellGui), `temp\jclcon\` (JclConverterConsole).

## Revised options

- **Option 1 — Build core engine now:** DLL-reference `ConverterSupport.dll` + `PowerShellGenerator.dll`; edit `SsgConverter.csproj` (drop missing `.snk` sign + `AmtAssemblyInfo.cs` include; ProjectReference → Reference). Produces `SsgConverter.dll`. Console/GUI deferred.
- **Option 2 — Locate OS2200 ECL toolset:** find source or binaries exporting `Ecl.Parser.Os2200` / `Ecl.ToAst[.Os2200]` (other AMT source drop) to build Console + GUI.
- **Option 3 — Stop:** tool is non-runtime; not required for AMT175.

---

## Progress (as-built, 260810)

- ✅ **Core `SsgConverter.dll` BUILT** (0 errors) via DLL refs to `_deps\ConverterSupport.dll` + `_deps\PowerShellGenerator.dll`. Edited `SsgConverter\SsgConverter.csproj`: `SignAssembly=false`, removed `AmtAssemblyInfo.cs` include, ProjectReference → Reference.
- Shared DLL folder: `MigrationTools\SsgConverter\SsgConverter\_deps\` (from `EclToPowerShellGui.7z` + `JclConverterConsole.7z`).
- ✅ Confirmed OS2200 ECL namespaces absent from ALL MigrationTools binary archives, `AmtTools`, and `Lion`/liondev (authoritative binary string scan).
- ✅ **OS2200 ECL SOURCE obtained** from SharePoint: `MigrationTools\EclConverter (1)\EclConverter\` — provides `EclParser`, `EclParserOs2200`, `EclToAst`, `EclToAstOs2200` (net10.0). Prebuilt `bin` folders empty → must build from source.

### Console/GUI dependency resolution
`SsgConverterConsole` → `EclToAstOs2200` + `EclParserOs2200` (+ `ConverterSupport`, `PowerShellWriter`, core). Transitive needs of the ECL source and where satisfied:

| Dependency | Source? | DLL in `_deps`? |
|---|---|---|
| `EclParser`, `EclParserOs2200`, `EclToAst`, `EclToAstOs2200` | ✅ EclConverter(1) | — |
| `Asysco.Amt.Libs` | — | ✅ |
| `ConverterSupport` (`Avanade.LtCoE.MigSupport`) | — | ✅ |
| `PowerShellGenerator` (`PowerShell.Generator`) | — | ✅ |
| `PowerShellWriter` | — | ✅ |
| `PowerShellSyntax` (`PowerShell.Syntax`) | — | ✅ |
| `PythonWriter` | — | ✅ |
| `PythonSyntax` (`Python.Syntax`) | — | ✅ |
| **`IpfConverter`** (`Ipf.Converter[.Commands]`, used by `EclToAstOs2200`) | ❌ | ❌ **MISSING** |

### Remaining blocker (single)
- **`IpfConverter`** — genuinely used by `EclToAstOs2200` source; not in any archive, disk, or the EclConverter(1) download. **Need:** the `IpfConverter` project from the same SharePoint repo (sibling of `EclConverter`, ref path `..\..\IpfConverter\IpfConverter\IpfConverter.csproj`) **or** `IpfConverter.dll`.

### Next steps (once IpfConverter available)
1. Convert non-present sibling ProjectReferences in the 4 ECL csproj to `_deps` DLL `Reference`s (keep Ecl*↔Ecl* ProjectReferences).
2. Point `SsgConverterConsole`/`Gui` at the ECL projects + `_deps` DLLs; drop missing `.snk`/`AmtAssemblyInfo.cs` as done for core.
3. Build `SsgConverterConsole` then `SsgConverterGui`; iterate.

---

## COMPLETED (as-built, 260810)

Full `SsgConverter.slnx` builds: **0 warnings / 0 errors**. Outputs:
- `SsgConverter\bin\Debug\net10.0\SsgConverter.dll`
- `SsgConverterConsole\bin\Debug\net10.0\SsgConverterConsole.dll` (smoke-tested: prints usage banner, loads all deps)
- `SsgConverterGui\bin\Debug\net10.0-windows\SsgConverterGui.dll`

IpfConverter was extracted from SharePoint to `MigrationTools\IpfConverter\IpfConverter\IpfConverter\` — the last missing piece.

### What was changed
- **New** `MigrationTools\Directory.Build.props` — defines `$(SsgDeps)` = shared prebuilt-DLL folder path.
- **Shared DLLs** in `MigrationTools\SsgConverter\SsgConverter\_deps\` (from `EclToPowerShellGui.7z` + `JclConverterConsole.7z`): ConverterSupport, PowerShellGenerator, PowerShellWriter, PowerShellSyntax, PythonWriter, PythonSyntax, Asysco.Amt.Libs (+ closure).
- **csproj edits** (source projects): missing-sibling `ProjectReference` → `<Reference HintPath=$(SsgDeps)…>`; kept real source↔source ProjectReferences; fixed `SsgConverterConsole` paths to `..\..\..\EclConverter (1)\…`; fixed `EclToAstOs2200` IpfConverter path; dropped `SignAssembly`/`.snk` + `AmtAssemblyInfo.cs` include (files: EclParser, EclParserOs2200, EclToAst, EclToAstOs2200, IpfConverter, SsgConverter, SsgConverterConsole, SsgConverterGui).
- **`SsgConverter.slnx`** repointed to the real project locations (Ecl* + IpfConverter + 3 Ssg projects).

### Notes / caveats
- Substituted DLLs are from the same `8.0.26188.0` train and proved **API-compatible** (all source compiled). If SharePoint source moves ahead, refresh `_deps` or add the corresponding source.
- `SignAssembly=false` (proprietary `.snk` not in any extract). Re-enable if the signing key is provided.
- Build tooling note: `7z.exe` is blocked by Avanade EPM; used Windows `tar.exe` for all `.7z` extraction.

### Run / entry points (.exe)
- **GUI (WPF):** `SsgConverter\SsgConverter\SsgConverterGui\bin\Debug\net10.0-windows\SsgConverterGui.exe`
- **Console (CLI):** `SsgConverter\SsgConverter\SsgConverterConsole\bin\Debug\net10.0\SsgConverterConsole.exe`
  - Usage: `SsgConverterConsole.exe /INPUT:"<ssg-src>" /OUTPUT:"<out>"` (or `/SETTINGSFILE:"<file>"`; `/VERBOSE:0-3`, `/CLEAROUTPUT`, `/CONTINUEONERROR`, `/LOGFILE`, `/ENABLELOGFILE`).
  - `dotnet` alt: `dotnet SsgConverterConsole.dll /INPUT:... /OUTPUT:...`
