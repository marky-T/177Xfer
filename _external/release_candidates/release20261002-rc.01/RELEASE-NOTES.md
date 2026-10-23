# Release Notes — Federale SSG → PowerShell

**Release:** `release20261002-rc.01`  **Date:** 2026-10-02
**Scope:** 20 converted OS2200 SSG batch programs, as PowerShell, for execution under AMT Control Center.

---

## 1. Summary

All **20** programs convert cleanly and **run end-to-end in the Tier-1 mock harness** (0 parse errors, every SGS lookup resolved). Of those 20, **18 have additionally completed a genuine live run** (real `Connect-Application` + Control Center Start Job) in a parallel AMT environment; **2 (`EXTEUR`, `FUSBA_ASCII`) have an open per-program seed gap** in the live run (details below). This is a **test / feature-parity release candidate**, not a production sign-off.

### Converter build fingerprint
The bodies in this release were produced by one SsgConverter build:

| Artefact | Size | SHA-256 |
|----------|------|---------|
| `SsgConverter.dll` (Console) | 51 200 B | `C586C60A39F167DA670E2F4F7BD3809C14590449147151470122E4C3D344C1DA` |

Re-running that build over `2_OriginalSource/` reproduces `Bodies/` byte-for-byte.

---

## 2. How it runs

Each program ships as a **body** (pure converted SSG logic) and a generated **wrapper** (`<KEY>-LIVE.ps1`). The wrapper is the runnable Control Center job:

```
Set-Jobname → Initialize (live Connect-Application) → seed SGS (AddTo-SgsList …) → & <body> → Fin
```

- The **body path is resolved at run time from the live Control Center Script basepath** (`$global:AmtPath.ScriptPath`), not hardcoded — so the same wrapper is portable across environments.
- The **runtime library + settings** come from `AMT_RT` / `AMT_SETTINGS` env vars, or a documented relative fallback (see README §3).
- Any failure (bad settings, missing body, runtime throw) is caught by the wrapper's `Trap` and routed through the AMT `Abort` path, so the **job ends in Error state in Control Center** with a message — it is a run-time abort, surfaced in the Completed Jobs view, not a pre-start rejection.

---

## ⚠ Required runtime setup (2 critical items — validated by a dry-run install)

A mock install dry-run (`CFH-COPY` + `UNLOADIS_ASCII`) confirmed the package installs and runs with **no syntax or step defects**. It also isolated **two load-bearing setup requirements** that are not self-evident and will **silently** fail a program if set wrong. Both are documented in full in **README §3 ("Required runtime setup")**; in summary:

1. **Bodies must be deployed FLAT at the Control Center *Script path* root, named `<KEY>.ps1`.** Each wrapper resolves its body as `Join-Path $global:AmtPath.ScriptPath '<KEY>.ps1'` — directly in the Script-path folder. **Nesting the bodies in a subfolder (`RUN\`, `Bodies\`, …) breaks body resolution** with no error until the job runs.
2. **Set `AMT_RT` and `AMT_SETTINGS` explicitly on the target** rather than relying on the wrapper's relative fallback. The fallback (`..\..\Libraries`, `..\..\Settings`) only resolves when the wrapper is exactly two folders below the runtime/settings parent; any other deployment depth breaks it **silently**. Setting the two environment variables removes the dependency.

> These are the only install-mechanics actions required beyond the standard AMT prerequisites (runtime libraries, a CobolOS2200 application, Control Center login). Everything else is covered by the step-by-step in README §3.

> **Confirmed live (2026-10-02):** this exact package was installed and run on a real AMT Control Center (`CFH-COPY`, AMT172). The wrapper's env-var resolution (`AMT_RT`/`AMT_SETTINGS`) and live Script-path resolution (`$global:AmtPath.ScriptPath` from `Initialize` reading the CC Basepath config) were both genuinely exercised — the body was located from live config, not a hardcoded path. Both "Required runtime setup" items above were necessary and sufficient, with the caveat that the Script-path value and the required env-var scope must be **confirmed in the live admin UI**, not assumed from a prior environment. See `VALIDATION-PROMPT.md` for a reusable, environment-agnostic validation procedure.

---

## 3. Testing performed to date

| Tier | What it proves | Status |
|------|----------------|--------|
| **Tier-1 mock harness** (`Run-SsgPsTrial.ps1` + `SsgPsMockLib.psm1`) | The body **parses** (0 errors) and **executes its full logic path** against a mocked SGS table; emitted line count; every `GetSgsValue` key is seeded. | **20 / 20 pass** |
| **Stage A — isolated real runtime** | The body runs against the **real** `AmtPsEclLib` with no COM/app (reaches `FIN` / End Job). | Proven for `CFH-COPY` |
| **Stage B — live Control Center** | Real `Connect-Application` + CC **Start Job** via BatchController on a working CobolOS2200 application. | **18 / 20 pass** (parallel AMT env, 2026-10-01) |

**Important scope note.** A Tier-1 pass proves the converted logic parses and executes with every lookup resolved; it is **necessary but not sufficient** — it does not prove numeric output parity against the legacy mainframe report. Output-level reconciliation against Federale's expected results is the **next** test phase and is **not** claimed by this release.

### Live install validation of THIS package (CFH-COPY, AMT172, 2026-10-02)
This exact release package was installed and run on a live AMT Control Center (AMT172) for `CFH-COPY`:
installed per the README (body flat at the CC Script path — confirmed live as `Working`; wrapper in a
`RUN` subfolder; `AMT_RT`/`AMT_SETTINGS` set at **Machine** scope via an elevated terminal; `Unblock-File`
on both scripts), registered via **Batch & Forms → Available Jobs → "Read all jobs from system"** (JobId
1085) then **Security → Jobs → Activate All**, and started from Control Center. Result: **`Script Started →
FIN → Script Done`, exit code 0** in both the job log and the Completed Jobs detail. This genuinely
exercised the wrapper's design — explicit `AMT_RT`/`AMT_SETTINGS` resolution and live
`$global:AmtPath.ScriptPath` from `Initialize` reading the real CC Basepaths config. Note `CFH-COPY`'s
converted body is **codegen-only** (no runtime file I/O), so no `ECL-TAPEIN` input needed staging. See
`VALIDATION-PROMPT.md` for the reusable, environment-agnostic validation procedure distilled from this run.

---

## 4. Per-program status & known issues

Legend — **T1** = Tier-1 mock; **Live** = Stage B live CC run (parallel AMT env, 2026-10-01).

| # | Program | Purpose | T1 | Live | Notes / known issues |
|---|---------|---------|----|------|----------------------|
| 1 | `ARCHISEPARE` | Archive / separate | ✅ | ✅ | Clean. 1 external call (`ucob`). |
| 2 | `CFH-COPY` | File copy | ✅ | ✅ | Baseline program. Emitted-line count corrected 47→45 by fix **T3-006**. |
| 3 | `CFH-COPY_ASCII` | File copy (ASCII variant) | ✅ | ✅ | Clean. Sibling of `CFH-COPY`. |
| 4 | `BABA_ASCII` | Data build | ✅ | ✅ | Needed converter fix **T3-003** (`*CLEAR`) + harness primitives **T3-004** (`SetC`), **T3-005**. |
| 5 | `CHABAN_ASCII` | Data build | ✅ | ✅ | Needed **T3-003** (`*CLEAR` → `$name = 0`). |
| 6 | `CHAB100_ASCII` | Data build (card→fixed) | ✅ | ✅ | Clean. Sibling of `CHABAN_ASCII`. |
| 7 | `UNLOADIS_ASCII` | Unload indexed file | ✅ | ✅ | Needed harness primitive **T3-002** (`Hdg`/`#HDG`). |
| 8 | `UNLOADIS_MULTI` | Unload indexed, multi-key | ✅ | ✅ | Clean. Alternate-key WITH-DUPLICATES branch. |
| 9 | `LOADIS_ASCII` | Load indexed file | ✅ | ✅ | Clean (lightest program by complexity). |
| 10 | `LOADIS_MULTI` | Load indexed, multi-key | ✅ | ✅ | Clean. Mirror of `UNLOADIS_MULTI`. |
| 11 | `LECTIS_ASCII` | Multi-key sequential reader | ✅ | ✅ | Surfaced harness fix **T3-007** (Hashtable `.Keys` shadowed by a seed key literally named `KEYS`). |
| 12 | `ARCHIFORMAT` | Archive formatter (mixed ECL+SSG+COBOL) | ✅ | ✅ | **By design emits 0 lines** — only its 5 `*SET` lines convert; the rest is ECL/COBOL pass-through (converter rule KI-3, expected, not a bug). Computed values verified (`$A=69`) after fix **T3-006**. |
| 13 | `FUSBA2_ASCII` | File merge/fusion (dynamic `PROGRAM-ID`) | ✅ | ✅ | **T3-007** during seeding. `PROGRAM-ID` is a dynamic SGS-bracket reference (output name = input file's base name). |
| 14 | `RECAP` | Recapitulative totals | ✅ | ✅ | Needed harness primitive **T3-008** (`Log-Message`). Emits `Log-Message` → needs the **T3-011** runtime stub (see §5). |
| 15 | `TABAN_ASCII` | Table analysis | ✅ | ✅ | Clean. Emits `Log-Message` → needs the **T3-011** runtime stub. |
| 16 | `TAPELD_ASCII` | Tape load | ✅ | ✅ | Clean. Emits `Log-Message` → needs the **T3-011** runtime stub. |
| 17 | `CONDIS2_ASCII` | Condition/discrepancy check (largest: 911 src lines) | ✅ | ✅ | Needed converter fix **T3-009** (`*Increment +I` leading-`+` loop variable). Emits `Log-Message` → **T3-011**. |
| 18 | `SCAN_ASCII` | Conditional/total record scan (highest complexity score) | ✅ | ✅ | Runs clean, **but only the "TOTAL SCAN" path is exercised** — the seed selects `IF=0`, so the per-field `*EDIT ON &` tests and the self-referential `*CREATE SGS`/`*REMOVE SGS` card-table codegen are **skipped, not validated**. Conditional path needs its own seeded run. |
| 19 | `EXTEUR` | Batch DB extract / currency conversion (RDMS/SQL-heavy, largest src: 961 lines) | ✅ | ❌ | **Open — MT-012.** Live run fails: seed supplies the literal string `"NONE"` where an integer default is expected (src line 158). Needs a numeric seed override. Passes Tier-1; the gap is in the **generated wrapper seed**, not the converted body. Converter fix **T3-009** also reconfirmed here. |
| 20 | `FUSBA_ASCII` | File merge/fusion (variant of `FUSBA2_ASCII`) | ✅ | ❌ | **Open — MT-012.** Live run fails: `Define_limpara` (src line 50) indexes an array the generic scalar seed doesn't populate — needs an occurrence/array-style seed. Passes Tier-1; gap is in the seed, not the body. |

---

## 5. Cross-cutting known issues & required environment steps

These apply to the **target runtime**, not to the converted logic:

- **T3-010 — Windows "mark-of-the-web" blocks scripts.** Any `.ps1`/`.psm1` copied between machines can carry a `Zone.Identifier` stream that the BatchController host silently refuses (even a trivial Hello-World). **Run `Unblock-File` on all deployed scripts** after copying (README §3, Step 4). The real first error only appears in the main `AmtBatchController_Trace.Log`.
- **T3-011 — `Log-Message` is not in the base AMT runtime.** Five programs (`RECAP`, `TABAN_ASCII`, `TAPELD_ASCII`, `CONDIS2_ASCII`, and one diagnostic in others) call `Log-Message`; the stock runtime has no such function. A minimal stub must exist in the application's `AmtPsCustomerLib.psm1` (the designated customer-extension point). Note the 2nd argument arrives as the literal string `"([LogMessageType]::Information)"`, so the stub must accept `[string]`.
- **MT-012 — the two live failures above** are **seed-data** issues (`EXTEUR`, `FUSBA_ASCII`), not converter or runtime defects. They are carried as open and must be closed with per-program seed overrides before those two can be signed off live.
- **Conversion taxonomy (expected warnings, not errors).** Reconversion reports only known-taxonomy warnings: orphaned data lines, auto-appended `@FIN`, and `@MAP`/`@ACOB` "unknown processor" — all expected for SSG-embedded ECL/COBOL pass-through (converter rules KI-1..KI-3).

---

## 6. What this release does **not** yet claim

- **No output-level reconciliation** against legacy mainframe report output (next phase).
- **`EXTEUR` and `FUSBA_ASCII` are not yet proven live** (MT-012 seed gaps open).
- **`SCAN_ASCII`'s conditional/codegen path is unexercised** — only the total-scan branch is validated.
- The live Stage B evidence (18/20) comes from a **parallel AMT application**; standing up the equivalent CobolOS2200 application in Federale's target environment is a prerequisite for re-verification here.

---

*Issue IDs (`T3-nnn`) and feature/decision IDs (`MT-nnn`) referenced above are tracked in the project progress register.*
