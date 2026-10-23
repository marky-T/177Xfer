---
title: "MT-010 — Bundle 20 converted SSG programs + source + Tier-1 harness for AMT172 Copilot handoff"
date: "2026-09-30"
status: "DONE — bundle pushed (2bcf8f1); AMT172 live-run results received 261001, 18/20 DONE; follow-ups MT-011/MT-012 open"
owner: "MT"
area: "cross-cutting (A source-of-truth, C provenance, D real-runtime facts) — delivered as a new artifact bundle"
---

# Plan: MT-010 — AMT177→AMT172 handoff bundle

## Context

A second Copilot session on **AMT172** ("AMT178Copilot" in their reply) will register and run our
converted reports as **real Control Center jobs** — a genuine `Connect-Application`/live run, not our
Tier-1 mock-shell. Environmental limits mean I can't do that run here, so the plan is to **bundle
everything AMT172 needs and answer their prepared requirements doc up front**, rather than have them
reverse-engineer it from bare `.ps1` files with no SSG source access.

The other side's paste-ready prompt (saved to their `T3-PS-Import-Requirements-AMT177to172.md`) asks
for 5 numbered things. This plan answers each with what we can supply from this repo/VM today, and
flags — **not silently omits** — every gap.

## Progress log

- **DONE (260930):** branch `T3ConvertedSSG-20` created off `T3ConvertedSSG` on `marky-T/177Xfer`
  and pushed (user confirmed "use our own branch", not `main`'s ad-hoc folder convention).
- **DONE (260930):** verified freshness of everything inherited from `T3ConvertedSSG` against the
  current SsgTrial workspace (per-file hash diff) rather than assuming the old push was current — the
  10 `.ps1`/source/`sgs-values.json` matched, but the **Tier1Mock harness was stale** (predated T3-007
  `.PSBase` ETS-shadowing fix + T3-008 `Log-Message` mock). Refreshed, committed (`d341b1c`), pushed.
- **DONE (260930):** surveyed the whole `177Xfer` repo (all branches + `main` root) before adding
  anything — found `main:CFH-COPY-Trial11/MockInputFiles/assign.json`, a ready DISC-designator JSON
  schema from the sibling COBOL→C# pipeline: `{ "jobname", "fileAssignments": {LOGICAL: physicalFile} }`.
  Adopting it instead of inventing a new format (Phase 1).
- **DONE (260930): Phase 1 — DISC designator extraction, all 20 programs.** Produced
  `SsgConverter/Trials/DiscDesignators.json` (per-program `fileAssignments`-style entries: logical
  name, direction, ASSIGN target raw+resolved, LABEL RECORD, BLOCK CONTAINS, record length
  raw+resolved), extending the `assign.json` schema above. Cross-referenced each program's own
  `Trials/<Program>/sgs-values.json` to resolve bracket keys; left genuinely unresolved ones as
  `null` + a note rather than guessing. **Two real gaps surfaced, not silently fixed:**
  - **Loop-count-zero gap** (`BABA_ASCII`, `FUSBA_ASCII`, `FUSBA2_ASCII`, `SCAN_ASCII`): their
    FILE-CONTROL/FD is `*INCREMENT`-loop-generated over an SGS count our seed has at 0, so no
    concrete per-file designator resolves at all for these 4 — AMT172 needs real counts before they
    can be registered with concrete DISC bindings.
  - **Unresolved-bracket gap** (`CFH-COPY_ASCII`, `CHAB100_ASCII`, `CHABAN_ASCII`, `CONDIS2_ASCII`,
    `EXTEUR`, `RECAP`, `TAPELD_ASCII`): sgs-values.json doesn't cover every INPUT/OUTPUT/FILEIN/
    FILEOUT key their FD sections reference.
  - Also re-confirmed via this pass: `LECTIS_ASCII` has a condition literally named `KEYS` (the exact
    T3-007 ETS-shadowing trigger) — worth flagging to AMT172 if they build their own harness.
- **DONE (260930): Phase 2 — golden reconciliation, all 20 programs.** Produced
  `SsgConverter/Trials/GoldenReconciliation.json` from each program's own `sgs-values.json` `_source`
  field (already documented whether it was manifest-seeded). Classified all 20: 5
  confirmed-seeded-from-manifest (ARCHIFORMAT, ARCHISEPARE, CFH-COPY, LECTIS_ASCII, TAPELD_ASCII),
  2 cross-checked-partial-overlap (LOADIS_ASCII, UNLOADIS_MULTI), 1 parameter-mismatch (SCAN_ASCII —
  a Trial3 fixture exists but uses different values), 1 parameter-mismatch-related-source-variant
  (CFH-COPY_ASCII), 11 no-manifest-entry. Carried the critical caveat: Trial3 fixtures use a
  real-file-I/O refimpl engine, different from our line-capture-only Tier-1 mock — even "confirmed"
  entries are not byte-diff proof.
- **DONE (260930): Phases 3-8 — full bundle assembled and pushed.** Built
  `SsgConverter/Trials/Build-AMT172HandoffBundle.ps1` (repeatable, idempotent) to assemble:
  `Programs/<key>/{source.txt,script.ps1,expected-output.dat (only where confirmed),README.md}` for
  all 20; `manifest.json`; copies of `DiscDesignators.json`/`GoldenReconciliation.json`; `Tier1Mock/`
  with all 20 `sgs-values.json`; `RealRuntime/` (isolated AmtPsEclLib/Sort/Customer libs + Stage A
  settings/runbook, clearly labelled non-live); `Tracker-Snapshot-20260930.html`;
  `T3-PS-Response-AMT177to172.md` (point-by-point answer to AMT172's requirements doc). Removed the
  superseded flat 10-program layout (old top-level `.ps1` + `SSG-Input/`) — git recognized them as
  renames into `Programs/<key>/`. Committed (`2bcf8f1`) and pushed to `T3ConvertedSSG-20`.
  Found+fixed one bug en route: a backtick-escaped `` `$assign` `` in the builder's README template
  produced literal "$assign" text instead of interpolating — caught by spot-checking generated
  output, not assumed correct.
  harness+RealRuntime bundle, tracker snapshot, response doc, final push/PR).

## Scope correction vs. the prior handoff

The prior push (`marky-T/177Xfer` branch `T3ConvertedSSG`) had **10** programs. Per
[copilot-instructions.md](../copilot-instructions.md) Current status, **all 20 example programs**
now convert clean (0 parse errors) and run in the Tier-1 harness (confirmed 2026-09-30 —
`Examples/Output` and `Trials/<Program>/` both have all 20). This bundle supersedes the 10-program
one; the **10 that overlap must be called out explicitly** in the new manifest so AMT172 doesn't
treat them as new/unrelated:

| Overlaps with `T3ConvertedSSG` (10) | New in this bundle (10) |
|---|---|
| ARCHIFORMAT, ARCHISEPARE, BABA_ASCII, CFH-COPY, CHAB100_ASCII, CHABAN_ASCII, LOADIS_ASCII, LOADIS_MULTI, UNLOADIS_ASCII, UNLOADIS_MULTI | CFH-COPY_ASCII, CONDIS2_ASCII, EXTEUR, FUSBA2_ASCII, FUSBA_ASCII, LECTIS_ASCII, RECAP, SCAN_ASCII, TABAN_ASCII, TAPELD_ASCII |

## Answering their 5 requirements — what we have vs. gaps

### 1. Version/compatibility (their flagged blocker)
- **Have:** pwsh 7.6.6 / .NET 10.0.12 on this VM (ComScript preflight OK). Critically, from MT-005's
  Stage B finding: a **standalone pwsh run is NOT a supported host** for a live
  `Connect-Application` — the native MsSql wrapper (`Asysco.Amt.AmtSqlServerWrapper.dll`,
  `SERVER TYPE=MSSQL`) needs a **.NET 8** closure (`Microsoft.Data.SqlClient 6.1.4` + SNI `6.0.2`)
  defined in a `.deps.json`; bare pwsh has none. The supported host is **`AmtPowershellHost.exe`
  (net8 / PS 7.4)** via BatchController/CC — this directly confirms their own suspicion about the
  net8/PS-SDK-7.4.14 host.
- **Have (bundle it):** an isolated copy of `AmtPsEclLib.psm1`/ComScript already exists at
  `SsgConverter/Trials/RealRuntime/` (copied from `Federale_InternalRelease`, never the live one).
  Bundle this copy + note its provenance/version.
- **Gap:** we do not have AMT172's own build/version to compare against — that's on them to state
  back.
- **Have:** the 10/20 overlap table above.

### 2. Per-program contents (all 20)
- **Have:** raw SSG source (`Examples/Input/<file>`) + generated `.ps1` (`Examples/Output/<file>.ps1`)
  for all 20 — pair them 1:1 using the **input file's base name** (see naming rule below, not
  `PROGRAM-ID`).
- **Execution status — must be stated honestly per program:**
  - **19 of 20:** Tier-1 mock-shell only (`Run-SsgPsTrial.ps1`, no live app, no COM).
  - **CFH-COPY:** Tier-1 **+ Stage A** — runs against the **real** (isolated-copy) `AmtPsEclLib`
    with no COM/live app; reaches `FIN`/`End Job`/`Script Done` (exit 0). Still not a live
    `Connect-Application` run.
  - **0 of 20:** have ever completed a live `Connect-Application`/`Xqt`/`Fin` run against a real AMT
    app. That is precisely what we're asking AMT172 to attempt — say so plainly, don't imply more
    maturity than exists.
- **Have (260930):** the `Asg`/`Use`/`Qual` file bindings per program (record length/format) are now
  in `SsgConverter/Trials/DiscDesignators.json` (Phase 1, done) — extracted from each SSG source's
  `FILE-CONTROL`/`FD`/`SELECT...ASSIGN` sections and cross-referenced against each program's
  `sgs-values.json`. **Two honest gaps inside that file, not fixed here:** 4 programs
  (`BABA_ASCII`/`FUSBA_ASCII`/`FUSBA2_ASCII`/`SCAN_ASCII`) have loop-generated file sections whose
  SGS count is seeded at 0 (no concrete designator resolves at all); 7 more have some
  unresolved bracket keys not covered by our `sgs-values.json` seed.
- **Gap — mock input + expected/golden output:** our Tier-1 harness has no real file I/O (it's a
  parameter/line-emission mock, not a data-file mock), so we don't have a "mock input file" in their
  sense. What we *do* have: `Trial3/candidates/trial-NN-*` goldens for **some** programs (confirmed
  present for at least CFH-COPY, ARCHISEPARE, ARCHIFORMAT, LOADIS_ASCII, UNLOADIS_ASCII, LECTIS_ASCII,
  SCAN_ASCII, CHABAN_ASCII, UNLOADIS_MULTI, TAPELD_ASCII) — reconcile which of the 20 have a matching
  candidate vs. genuinely none (Phase 2).

### 3. Naming & identity
- **Have — direct answer:** `Examples/Output/<Program>.ps1`'s base name is always the **input file's
  base name** (`Path.GetFileNameWithoutExtension`), **not** `PROGRAM-ID` (verified against
  `SsgConverterConsole/Program.cs` L121/L160). These coincide for most of the 20, but not always —
  `LECTIS_ASCII.TXT`'s `PROGRAM-ID` is `LECTIS` (no `_ASCII`) yet output is `LECTIS_ASCII.ps1`;
  `FUSBA2_ASCII.TXT`'s `PROGRAM-ID` is **dynamic** (`FUSION-[OUTPUT,1,1,1]`, an SGS bracket resolved
  at runtime) so a `PROGRAM-ID`-based name isn't even static. Always match by **input filename**.
- **Gap — `Set-Jobname`:** none of the 20 scripts call `Set-Jobname` at all. This is **MT-008**:
  SsgConverter emits **body-only** PowerShell (`param` + body + trailing `Fin`) — no
  `Set-Jobname → Initialize → Trap → body → Fin → HandleTrapAndAbort → Cleanup` job skeleton. This is
  likely **blocking** for a CC `Type=Script` registration and must be flagged, not worked around
  silently on our side or theirs without saying so.

### 4. Dependencies
- **Have — verified by grep, all 20:** **zero** `Import-Module` statements in any generated `.ps1`
  (confirms the MT-008 body-only finding — the scripts assume the runtime/module is already loaded by
  whatever host runs them).
- **Have — direct answer:** confirmed **not** run via `AmtPowershellHost.exe` on our side — only
  standalone `pwsh` (Tier-1) and one isolated Stage A run. Per §1, standalone pwsh is the *unsupported*
  path for anything needing the SQL-client closure; `AmtPowershellHost.exe` (BatchController/CC) is the
  only known-correct host, but we have **not** exercised it ourselves (that's their MT-009-blocked gap
  on our own VM too — see below).
- **Gap — proven-working live `AmtSettings.xml`:** we do **not** have one. Our own Stage B is
  blocked by **MT-009** (AMT177 has only the ABSuite/LINC `FEDERALE_APP`; SSG/ECL/COBOL reports need
  a separate `ApplicationKind=CobolOS2200` application that doesn't exist yet here). What we *can*
  offer: (a) the **Stage A** settings file (`SsgConverter/Trials/RealRuntime/AmtSettings.xml`) — a
  minimal, non-live, isolated-run config, clearly labelled as **not** a live-run proof; (b) the shape
  reference from the previous **`AMT175_AFBUS_COBOL`** application noted in MT-009 — also labelled
  reference-only, stale paths, not for reuse as-is.

### 5. Delivery shape
- Adopt exactly what they asked: `<PROGRAM-ID>/{source.txt, script.ps1, mock-input.*,
  expected-output.*, README.md}` + top-level `manifest.json`, mirroring
  `Trial3/fixtures/<key>/` + `Trial3/manifest/programs.manifest.json`. Where a field is genuinely
  unavailable (e.g. no golden, no DISC map yet), the manifest entry says so explicitly rather than
  omitting the key.
- **Also include, for reference (read-only context, not something AMT172 edits):** a copy of
  [docs/SSG-PowerShell-Trial-Progress.html](../../docs/SSG-PowerShell-Trial-Progress.html) at the
  bundle root. It's the single place that already carries the per-program parse/Tier-1 status (§3),
  the Stage A/B findings behind §1/§4 above (§5b/§5c runbooks), and the `T3-nnn`/`MT-nnn` registers
  (§6/§7) this plan cites — cheaper for AMT172 to read once than to have every fact re-explained in
  the response doc. Snapshot it at bundle time (static copy); it will drift from the live one here,
  so date-stamp it in the bundle README ("tracker snapshot as of <push date>").

## Phases

1. **[DONE] DISC designator extraction** (per program, all 20) → `SsgConverter/Trials/DiscDesignators.json`.
2. **[NOT STARTED] Golden reconciliation**: for each of the 20, check `Trial3/candidates/*` for a
   matching output; record match / no-match honestly in the manifest.
3. **[NOT STARTED] Assemble delivery folders**: one per program under a new bundle root, each with
   `source.txt` (copy of `Examples/Input/<file>`), `script.ps1` (copy of `Examples/Output/<file>.ps1`),
   `expected-output.*` (copy of the matching Trial3 candidate, or omitted + noted "none" in
   `README.md`), `README.md` (execution status, DISC map, PROGRAM-ID vs filename note).
   `mock-input.*` is N/A for our harness — say so in each README rather than fabricate a file.
4. **[NOT STARTED] Top-level `manifest.json`**: all 20 entries — key, PROGRAM-ID, execution status
   (`tier1-only` / `tier1+stagea`), overlap flag (in `T3ConvertedSSG`?), golden match (y/n), DISC map
   ref.
5. **[NOT STARTED] Harness bundle** (once, not per-program): `Tier1Mock/{Run-SsgPsTrial.ps1,SsgPsMockLib.psm1}` +
   all 20 `sgs-values.json` (as already done for the 10-program push) + the isolated
   `RealRuntime/{AmtPsEclLib.psm1 copy, AmtSettings.xml}` for Stage-A-style reference, each clearly
   labelled per §1/§4 above.
6. **[NOT STARTED] Reference copy**: snapshot `docs/SSG-PowerShell-Trial-Progress.html` into the bundle root
   (date-stamped in the bundle README as a point-in-time copy, not a live link).
7. **[NOT STARTED] Response doc**: compile a `T3-PS-Response-AMT177to172.md` in the bundle root answering the
   AMT178Copilot prompt point-by-point (mirrors the "have / gap" breakdown above) so it reads as a
   direct reply, not just raw files.
8. **[DONE — branch only] Push**: branch `T3ConvertedSSG-20` created + pushed off `T3ConvertedSSG`
   (confirmed with user, not overwriting the passed 10-program `T3ConvertedSSG` branch). Still
   **pending**: the actual content push (Phases 1–7) and a final confirm before that lands.

## Guardrails
- `SSG-Source/` / `Examples/Input` stay read-only; only copies leave this repo.
- Never present the Stage A settings file or the `AMT175_AFBUS_COBOL` reference as a "working live
  config" — both are explicitly reference/non-live.
- Every "gap" in §1–5 above must land in the response doc as a stated gap, not a silent omission
  (their own explicit ask).
- Confirm the push branch/target with the user before writing to the shared `177Xfer` remote.

## Relevant files
- `SsgConverter/Examples/{Input,Output}/*` (20 programs), `SsgConverter/Trials/<Program>/sgs-values.json`
- `SsgConverter/Trials/Tier1Mock/{Run-SsgPsTrial.ps1,SsgPsMockLib.psm1}`
- `SsgConverter/Trials/RealRuntime/*` (isolated `AmtPsEclLib` copy + Stage A settings)
- `Trial3/candidates/*`, `Trial3/manifest/programs.manifest.json`, `Trial3/fixtures/<key>/`
- Prior bundle for cross-reference: `marky-T/177Xfer` branch `T3ConvertedSSG`
- Tracker: [docs/SSG-PowerShell-Trial-Progress.html](../../docs/SSG-PowerShell-Trial-Progress.html) §7 (`MT-010`)

## Follow-up — AMT172 live-run results received (2026-10-01)

AMT172 ran the bundle as genuine Tier-3 jobs (real `Connect-Application`/CC/BatchController) — 18 of
20 DONE. Pulled down as a git worktree at
`E:\Repos\177Xfer\ConvertedSSG-Results-1-Live-fromAMT172Run` (branch `T3-LiveRun-Results-20261001`,
commit `6a46348`). **Full detail lives on the tracker only** (single source of truth — not repeated
here): issues `T3-010`/`T3-011`, follow-ups `MT-011`/`MT-012`, milestone note on `MT-005`.
- Tracker updated: `T3-010`, `T3-011` (issues), `MT-011`, `MT-012` (follow-ups), `MT-005` annotated
  with the cross-environment milestone note.
