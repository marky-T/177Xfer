# Release Notes — Federale SSG → PowerShell

**Release:** `{{RELEASE_LABEL}}`  **Date:** {{RELEASE_DATE}}
**Scope:** {{PROGRAM_COUNT}} converted OS2200 SSG batch programs, as PowerShell, for execution under AMT Control Center.

---

## 1. Summary

{{SUMMARY}}

### Converter build fingerprint
The bodies in this release were produced by one SsgConverter build:

| Artefact | Size | SHA-256 |
|----------|------|---------|
| `SsgConverter.dll` (Console) | {{CONVERTER_SIZE}} | `{{CONVERTER_SHA256}}` |

Re-running that build over `2_OriginalSource/` reproduces `Bodies/` byte-for-byte.

---

## 2. What's new in this release

{{CHANGELOG}}

---

## 3. How it runs

Each program ships as a **body** (pure converted SSG logic) and a generated **wrapper** (`<KEY>-LIVE.ps1`). The wrapper is the runnable Control Center job:

```
Set-Jobname → Initialize (live Connect-Application) → seed SGS (AddTo-SgsList …) → & <body> → Fin
```

- The **body path is resolved at run time from the live Control Center Script basepath** (`$global:AmtPath.ScriptPath`), not hardcoded — so the same wrapper is portable across environments.
- The **runtime library + settings** come from `AMT_RT` / `AMT_SETTINGS` env vars, or a documented relative fallback (see README §3).
- Any failure (bad settings, missing body, runtime throw) is caught by the wrapper's `Trap` and routed through the AMT `Abort` path, so the **job ends in Error state in Control Center** with a message — it is a run-time abort, surfaced in the Completed Jobs view, not a pre-start rejection.

---

## ⚠ Required runtime setup (2 critical items)

A mock install dry-run confirmed this package installs and runs with **no syntax or step defects**. Two **load-bearing** setup requirements are not self-evident and will **silently** fail a program if set wrong. Both are documented in full in **README §3 ("Required runtime setup")**; in summary:

1. **Bodies must be deployed FLAT at the Control Center *Script path* root, named `<KEY>.ps1`.** Each wrapper resolves its body as `Join-Path $global:AmtPath.ScriptPath '<KEY>.ps1'` — directly in the Script-path folder. **Nesting the bodies in a subfolder (`RUN\`, `Bodies\`, …) breaks body resolution** with no error until the job runs.
2. **Set `AMT_RT` and `AMT_SETTINGS` explicitly on the target** rather than relying on the wrapper's relative fallback. The fallback (`..\..\Libraries`, `..\..\Settings`) only resolves when the wrapper is exactly two folders below the runtime/settings parent; any other deployment depth breaks it **silently**.

> These are the only install-mechanics actions required beyond the standard AMT prerequisites (runtime libraries, a CobolOS2200 application, Control Center login). Everything else is covered by the step-by-step in README §3.

---

## 4. Testing performed to date

| Tier | What it proves | Status |
|------|----------------|--------|
| **Tier-1 mock harness** (`Run-SsgPsTrial.ps1` + `SsgPsMockLib.psm1`) | The body **parses** (0 errors) and **executes its full logic path** against a mocked SGS table; emitted line count; every `GetSgsValue` key is seeded. | **{{TIER1_SUMMARY}}** |
| **Mock install dry-run** | The documented install procedure works end-to-end: flat body placement, path resolution, wrapper/body syntax, run sequence. | {{DRYRUN_SUMMARY}} |
| **Stage B — live Control Center** | Real `Connect-Application` + CC **Start Job** via BatchController on a working CobolOS2200 application. | {{LIVE_SUMMARY}} |

{{LIVE_VALIDATION_DETAIL}}

**Important scope note.** A Tier-1 pass proves the converted logic parses and executes with every lookup resolved; it is **necessary but not sufficient** — it does not prove numeric output parity against the legacy mainframe report. Output-level reconciliation against Federale's expected results is the **next** test phase and is **not** claimed by this release.

---

## 5. Per-program status & known issues

Every program below was **re-proven through the Tier-1 harness at build time** (not carried over from a stored record). `Lines` = emitted line count; `Unmocked` = unresolved `GetSgsValue` lookups (0 is the target).

{{PROGRAM_TABLE}}

{{EXCLUDED_TABLE}}

---

## 6. Cross-cutting known issues & required environment steps

These apply to the **target runtime**, not to the converted logic:

- **T3-010 — Windows "mark-of-the-web" blocks scripts.** Any `.ps1`/`.psm1` copied between machines can carry a `Zone.Identifier` stream that the BatchController host silently refuses (even a trivial Hello-World). **Run `Unblock-File` on all deployed scripts** after copying (README §3, Step 4). The real first error only appears in the main `AmtBatchController_Trace.Log`.
- **T3-011 — `Log-Message` is not in the base AMT runtime.** Several programs call `Log-Message`; the stock runtime has no such function. A minimal stub must exist in the application's `AmtPsCustomerLib.psm1` (the designated customer-extension point). Note the 2nd argument arrives as the literal string `"([LogMessageType]::Information)"`, so the stub must accept `[string]`.
- **Conversion taxonomy (expected warnings, not errors).** Reconversion reports only known-taxonomy warnings: orphaned data lines, auto-appended `@FIN`, and `@MAP`/`@ACOB` "unknown processor" — all expected for SSG-embedded ECL/COBOL pass-through (converter rules KI-1..KI-3).

---

## 7. What this release does **not** yet claim

- **No output-level reconciliation** against legacy mainframe report output (next phase).
- Any program flagged open in §5 is **not** yet proven live.
- The live Stage B evidence comes from a **parallel AMT application**; standing up the equivalent CobolOS2200 application in Federale's target environment is a prerequisite for re-verification there.

---

*Issue IDs (`T3-nnn`) and feature/decision IDs (`MT-nnn`) referenced above are tracked in the project progress register.*
