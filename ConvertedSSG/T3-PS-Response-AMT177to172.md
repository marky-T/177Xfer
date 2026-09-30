# Response to AMT172's import requirements (T3-PS-Import-Requirements-AMT177to172.md)

This answers your prepared requirements doc point-by-point. Everything referenced below is in this
bundle (`ConvertedSSG/` on branch `T3ConvertedSSG-20`). Gaps are stated explicitly, not omitted —
per your own ask.

**Supersedes** the earlier 10-program push (branch `T3ConvertedSSG`). Overlap: `ARCHIFORMAT`,
`ARCHISEPARE`, `BABA_ASCII`, `CFH-COPY`, `CHAB100_ASCII`, `CHABAN_ASCII`, `LOADIS_ASCII`,
`LOADIS_MULTI`, `UNLOADIS_ASCII`, `UNLOADIS_MULTI`. New in this bundle: `CFH-COPY_ASCII`,
`CONDIS2_ASCII`, `EXTEUR`, `FUSBA2_ASCII`, `FUSBA_ASCII`, `LECTIS_ASCII`, `RECAP`, `SCAN_ASCII`,
`TABAN_ASCII`, `TAPELD_ASCII`.

## 1. Version/compatibility

- This VM: pwsh 7.6.6 / .NET 10.0.12 (ComScript preflight OK).
- **A standalone pwsh run is NOT a supported host** for a live `Connect-Application` — the native
  MsSql wrapper (`Asysco.Amt.AmtSqlServerWrapper.dll`, `SERVER TYPE=MSSQL`) needs a **.NET 8** closure
  (`Microsoft.Data.SqlClient 6.1.4` + native SNI `6.0.2`) defined in a `.deps.json`; bare pwsh has
  none. The supported host is **`AmtPowershellHost.exe` (net8 / PS 7.4)** via BatchController/CC —
  this matches your own suspicion about the net8/PS-SDK-7.4.14 host.
- `RealRuntime/` bundles our isolated copy of `AmtPsEclLib.psm1`/`AmtPsSortLib.psm1`/
  `AmtPsCustomerLib.psm1` (see `RealRuntime/README.md` for provenance/limits — **not** a live config).
- **Gap:** we don't have your VM's own build/version to compare against.

## 2. Per-program contents (all 20)

- Each `Programs/<key>/` folder: `source.txt` (raw SSG source) + `script.ps1` (converted PowerShell),
  paired by the **input file's base name** (not `PROGRAM-ID` — see §3).
- **Execution status, stated honestly per program** (also in `manifest.json.programs[].executionStatus`):
  - **19 of 20:** `tier1-only` — Tier-1 mock-shell (`Tier1Mock/Run-SsgPsTrial.ps1`) only, no live app, no COM.
  - **`CFH-COPY`:** `tier1+stagea` — additionally runs against the **real** (isolated-copy)
    `AmtPsEclLib` with no COM/live app; reaches `FIN`/`End Job`/`Script Done` (exit 0).
  - **0 of 20** have ever completed a live `Connect-Application`/`Xqt`/`Fin` run. That's what we're
    asking you to attempt.
- **DISC designators:** `DiscDesignators.json` (also summarized in each `Programs/<key>/README.md`) —
  logical name, direction, ASSIGN target (raw + resolved where our seed covers it), LABEL RECORD,
  BLOCK CONTAINS, record length. **Gaps inside it, not fixed:**
  - **Loop-count-zero** (`BABA_ASCII`, `FUSBA_ASCII`, `FUSBA2_ASCII`, `SCAN_ASCII`): their
    FILE-CONTROL/FD is `*INCREMENT`-loop-generated over an SGS count our seed has at 0 — **no
    concrete DISC designator resolves at all** for these 4.
  - **Unresolved brackets** (`CFH-COPY_ASCII`, `CHAB100_ASCII`, `CHABAN_ASCII`, `CONDIS2_ASCII`,
    `EXTEUR`, `RECAP`, `TAPELD_ASCII`): some INPUT/OUTPUT keys aren't in our seed.
- **Mock input + expected output:** our Tier-1 harness has **no real file I/O** (parameter/line-
  emission mock only), so there's no `mock-input.*` in your sense — noted per-program rather than
  fabricated. `expected-output.dat` is included **only** where `GoldenReconciliation.json` shows
  `confirmed-seeded-from-manifest` (5 programs: `ARCHIFORMAT`, `ARCHISEPARE`, `CFH-COPY`,
  `LECTIS_ASCII`, `TAPELD_ASCII`) — and even then, **read the caveat** in that file: those goldens
  come from a different execution engine (a refimpl that simulates real file I/O), not a byte-diff
  against our Tier-1 output. 2 more (`LOADIS_ASCII`, `UNLOADIS_MULTI`) have a partially-overlapping
  Trial3 fixture, deliberately **not** copied in as a golden. `SCAN_ASCII` has a same-named Trial3
  fixture with **different parameters** — deliberately not copied in either; don't use it.

## 3. Naming & identity

- `Examples/Output/<Program>.ps1`'s base name is always the **input file's base name**, **not**
  `PROGRAM-ID` (verified against `SsgConverterConsole/Program.cs` L121/L160). `LECTIS_ASCII.TXT`'s
  `PROGRAM-ID` is `LECTIS` (no `_ASCII`); `FUSBA2_ASCII.TXT`'s `PROGRAM-ID` is **dynamic**
  (`FUSION-[OUTPUT,1,1,1]`, resolved only at runtime). Always match by input filename.
- **Gap — no `Set-Jobname`:** none of the 20 scripts call `Set-Jobname` at all. SsgConverter emits
  **body-only** PowerShell (`param` + body + trailing `Fin`) — no
  `Set-Jobname → Initialize → Trap → body → Fin → HandleTrapAndAbort → Cleanup` job skeleton. This is
  likely **blocking** for CC `Type=Script` registration as-is.

## 4. Dependencies

- **Zero `Import-Module` statements** in any of the 20 generated `.ps1` (confirmed by grep) — they
  assume the runtime is already loaded by whatever host runs them.
- Confirmed **not** run via `AmtPowershellHost.exe` on our side — only standalone pwsh (Tier-1) and
  one isolated Stage A run.
- **Gap — no proven-working live `AmtSettings.xml`.** Our own Stage B is blocked (this VM has only
  the ABSuite/LINC `FEDERALE_APP`; SSG/ECL/COBOL reports need a separate
  `ApplicationKind=CobolOS2200` application that doesn't exist here yet). `RealRuntime/AmtSettings.xml`
  is Stage-A-only (non-live) — see its README before using it as a reference.

## 5. Delivery shape

- `Programs/<PROGRAM-KEY>/{source.txt, script.ps1, expected-output.dat (only where confirmed),
  README.md}` + top-level `manifest.json` (all 20, with `executionStatus`, `goldenStatus`,
  `overlapsWithT3ConvertedSSG10`) + `DiscDesignators.json` + `GoldenReconciliation.json`.
- `Tier1Mock/` — our verified mock harness (`SsgPsMockLib.psm1`, `Run-SsgPsTrial.ps1`,
  `sgs-values/<key>.sgs-values.json` for all 20). If you build your own mock, note: `GetSgsValue` must
  return **typed** values (not raw strings) or `*SET` arithmetic and truthiness checks silently break;
  and watch for SGS condition flags that collide with real Hashtable member names (e.g. `LECTIS_ASCII`
  has one literally named `KEYS`) — PowerShell's ETS will shadow `.Keys`/`.Count`/`.ContainsKey`
  unless you use `.PSBase.*`.
- `RealRuntime/` — isolated `AmtPsEclLib` reference (see its own README — not a live config).
- `Tracker-Snapshot-20260930.html` — point-in-time copy of our progress tracker (will drift from the
  live one in our repo; re-ask if you need current state).
