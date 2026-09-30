# Converted SSG → PowerShell programs (T3) — 20-program bundle

This supersedes the earlier 10-program push (branch `T3ConvertedSSG`). All 20 OS2200 **SSG (Symbiont
Stream Generator)** example programs have been converted to **PowerShell** by `SsgConverter`, for
handoff to AMT172 to attempt the first **live** Control Center run (ours has only reached Tier-1
mock-shell, plus one isolated Stage A run for `CFH-COPY`).

**Start here:** [`T3-PS-Response-AMT177to172.md`](T3-PS-Response-AMT177to172.md) — answers your
prepared requirements doc point-by-point, with every gap stated explicitly.

## Layout

| Path | Contents |
|------|----------|
| `Programs/<PROGRAM-KEY>/` | `source.txt` (raw SSG), `script.ps1` (converted), `expected-output.dat` (only where confirmed parameter-matched — see `GoldenReconciliation.json`), `README.md` (execution status + DISC map for that program) |
| `manifest.json` | All 20 entries: key, source/script filenames, execution status, golden status, overlap-with-prior-bundle flag |
| `DiscDesignators.json` | Per-program file/DISC designator tables (logical name, ASSIGN target, LABEL RECORD, BLOCK CONTAINS, record length) — extends the `assign.json` schema found in this repo's `main:CFH-COPY-Trial11/MockInputFiles/assign.json` |
| `GoldenReconciliation.json` | Which programs' Tier-1 SGS seed matches a Trial3 fixture's parameters — and the critical caveat that those fixtures come from a different (real file-I/O) execution engine |
| `Tier1Mock/` | Our verified mock harness (`Run-SsgPsTrial.ps1`, `SsgPsMockLib.psm1`, `sgs-values/<key>.sgs-values.json` for all 20) |
| `RealRuntime/` | Isolated `AmtPsEclLib` copy + Stage A settings/runbook — **not** a live config, see its own README |
| `Tracker-Snapshot-20260930.html` | Point-in-time copy of our progress tracker |

## Programs (20)

| Key | Source file | Execution status | Golden status |
|-----|------------|-------------------|----------------|
| ARCHIFORMAT | ARCHIFORMAT.TXT | tier1-only | confirmed-seeded-from-manifest |
| ARCHISEPARE | ARCHISEPARE | tier1-only | confirmed-seeded-from-manifest |
| BABA_ASCII | BABA_ASCII.TXT | tier1-only | no-manifest-entry |
| CFH-COPY | CFH-COPY.TXT | **tier1+stagea** | confirmed-seeded-from-manifest |
| CFH-COPY_ASCII | CFH-COPY_ASCII.TXT | tier1-only | parameter-mismatch-related-source-variant |
| CHAB100_ASCII | CHAB100_ASCII.TXT | tier1-only | no-manifest-entry |
| CHABAN_ASCII | CHABAN_ASCII.TXT | tier1-only | no-manifest-entry |
| CONDIS2_ASCII | CONDIS2_ASCII.TXT | tier1-only | no-manifest-entry |
| EXTEUR | EXTEUR.TXT | tier1-only | no-manifest-entry |
| FUSBA2_ASCII | FUSBA2_ASCII.TXT | tier1-only | no-manifest-entry |
| FUSBA_ASCII | FUSBA_ASCII.TXT | tier1-only | no-manifest-entry |
| LECTIS_ASCII | LECTIS_ASCII.TXT | tier1-only | confirmed-seeded-from-manifest |
| LOADIS_ASCII | LOADIS_ASCII.TXT | tier1-only | cross-checked-partial-overlap |
| LOADIS_MULTI | LOADIS_MULTI.TXT | tier1-only | no-manifest-entry |
| RECAP | RECAP.TXT | tier1-only | no-manifest-entry |
| SCAN_ASCII | SCAN_ASCII.TXT | tier1-only | parameter-mismatch |
| TABAN_ASCII | TABAN_ASCII.TXT | tier1-only | no-manifest-entry |
| TAPELD_ASCII | TAPELD_ASCII.TXT | tier1-only | confirmed-seeded-from-manifest |
| UNLOADIS_ASCII | UNLOADIS_ASCII.TXT | tier1-only | no-manifest-entry |
| UNLOADIS_MULTI | UNLOADIS_MULTI.txt | tier1-only | cross-checked-partial-overlap |

Full detail (per-program DISC designators, naming caveats, golden reconciliation caveats) is in
`DiscDesignators.json` / `GoldenReconciliation.json` and each `Programs/<key>/README.md`.

## Overlap with the prior 10-program bundle (`T3ConvertedSSG`)

ARCHIFORMAT, ARCHISEPARE, BABA_ASCII, CFH-COPY, CHAB100_ASCII, CHABAN_ASCII, LOADIS_ASCII,
LOADIS_MULTI, UNLOADIS_ASCII, UNLOADIS_MULTI. New in this bundle: CFH-COPY_ASCII, CONDIS2_ASCII,
EXTEUR, FUSBA2_ASCII, FUSBA_ASCII, LECTIS_ASCII, RECAP, SCAN_ASCII, TABAN_ASCII, TAPELD_ASCII.

## Running on AMT172

These scripts call into the AMT PowerShell runtime (e.g. `GetSgsValue`, `DataLineOrNoStatement`,
`CompareTypeSafe`, `Process-Skip`, `Call-ExternalProgram`). On AMT172 they must run with the real
`AmtPsEclLib` module loaded and the application initialised — not the Tier-1 mock. Each accepts an
optional `-Parameters` string array. **Gap:** none currently call `Set-Jobname` or have the
`Initialize`/`Trap`/`Fin` job skeleton — see `T3-PS-Response-AMT177to172.md` §3.

## Tier1Mock/ — our verified mock harness (for when `AmtPsEclLib` isn't available)

- `SsgPsMockLib.psm1` — implements only the primitives the generated scripts call: `GetSgsValue`,
  `DataLineOrNoStatement`, `CompareTypeSafe`, `Process-Skip`, `Call-ExternalProgram`, `Fin`, `Abort`,
  `AddTo-SgsList`, `RemoveFrom-SgsList`, `Sort-SgsList`, `Log-Message`.
- `Run-SsgPsTrial.ps1` — seeds the mock SGS table from a per-program `sgs-values/<key>.sgs-values.json`,
  runs the script, captures every emitted line.
- `sgs-values/<key>.sgs-values.json` — the parameter values we seeded for each of the 20 programs.

Usage:

```powershell
Import-Module .\Tier1Mock\SsgPsMockLib.psm1 -Force -DisableNameChecking
.\Tier1Mock\Run-SsgPsTrial.ps1 -Program CFH-COPY `
  -ScriptPath .\Programs\CFH-COPY\script.ps1 -ValuesFile .\Tier1Mock\sgs-values\CFH-COPY.sgs-values.json
```

**Important lesson worth reconciling with any independently-built mock** (e.g. `Mock-SsgRuntime.psm1`):
`GetSgsValue` must return **typed** values (`[Int64]`/`[Double]`), not raw strings. A string-only mock
causes two silent bugs: (1) `+` becomes string concatenation instead of arithmetic in `*SET` chains,
and (2) the string `"0"` is truthy in PowerShell (only `""` is falsy) while the int `0` is falsy, so a
disabled feature (e.g. `MAXCOPY=0`) wrongly evaluates as enabled in bare `If ((GetSgsValue (...)))`
checks. Also watch for SGS condition flags that collide with real Hashtable member names (e.g.
`LECTIS_ASCII` has one literally named `KEYS`) — use `.PSBase.Keys`/`.PSBase.ContainsKey`/
`.PSBase.Count`, not the bare members, or PowerShell's ETS silently shadows them. See
`SsgPsMockLib.psm1`'s `GetSgsValue`/`Reset-SgsMock` for the exact fix.

## Provenance

- Generated by `SsgConverter` from the read-only `SSG-Source` reference set in the SsgTrial workspace.
- All 20 verified: 0 parse errors; run under the Tier-1 mock harness (`Run-SsgPsTrial.ps1`).
- These are conversion-trial artifacts; validate against expected output on AMT172 before any
  production use.

