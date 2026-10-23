---
name: "SSG Area D — Run under the real AMT runtime"
description: "Use when running SsgConverter-generated PowerShell against the REAL AmtPsEclLib runtime (isolated copy) rather than the Tier-1 mock: Stage A (isolated, no COM/app) vs Stage B (full Initialize/Connect-Application/Control Center). Covers Run-StageA.ps1, SGS seeding, the WarningRcw2435 init flag, the COM-cleanup boundary. Area D of the SSG→PS trial."
applyTo: "**/Trials/RealRuntime/**"
---

# Area D — Run converted PowerShell under the real AMT runtime

Prove that a SsgConverter-generated `.ps1` runs against the **real** `AmtPsEclLib` runtime (not the
Tier-1 mock), so the converter output is validated against the production API surface. See the
always-on [copilot-instructions.md](../copilot-instructions.md) for overall guardrails and status.

This area has two stages:

| Stage | What it proves | Isolation |
|-------|----------------|-----------|
| **A — Isolated** | The converted `.ps1` is API-compatible with the real runtime: every runtime function it calls exists with a matching signature and the script runs its full body to FIN with no missing-member / missing-global crash. | **No COM, no app connection.** Uses only the isolated library copies in `Trials/RealRuntime/`. |
| **B — Faithful completion** | The program completes end-to-end under the real app (COM object, `Connect-Application`, file controllers, report/printer capture, Control Center / BatchController). | Connects to the live app; **out of scope for this trial's VM** unless explicitly requested. |

## Layout

| Item | Path |
|------|------|
| Isolated runtime copies | `SsgConverter/Trials/RealRuntime/{AmtPsEclLib,AmtPsSortLib,EclOptions,AmtPsCustomerLib}.psm1` |
| Stage A runner | `SsgConverter/Trials/RealRuntime/Run-StageA.ps1` |
| Script under test | `SsgConverter/Examples/Output/<Program>.ps1` |
| Real runtime source (reference only — never modify) | `E:\Repos\Federale_InternalRelease\Scripts\Libraries\AmtPsEclLib.psm1` |

## Guardrails (Area D)

- The isolated `*.psm1` in `Trials/RealRuntime/` are **read-only COPIES**. Never wire the trial into
  `E:\Repos\Federale_InternalRelease`, the live **FEDERALE_APP**, its DB, or the `ava` account.
- **Do not call `Initialize` / `Connect-Application` in Stage A.** `Initialize` (AmtPsEclLib L497)
  loads `ComScript.dll` (`Add-Type`), creates the COM object, and calls `Connect-Application` — i.e.
  it connects to the live app. That is **Stage B**, not isolated Stage A.
- Stage A is about *running the body against the real API*, not byte-identical output: in the real
  lib, unrecognized data lines route to `NoStatement` (an empty no-op), and real output/printing goes
  through COM objects that only Stage B supplies. Output-equivalence is a Tier-1 (Area A) or Stage B
  concern.

## Stage A — standard process

Run from `SsgConverter/Trials/RealRuntime/`:

```powershell
pwsh -NoProfile -File .\Run-StageA.ps1 -Program CFH-COPY
```

`Run-StageA.ps1` is idempotent and does, in order:

1. **Import** the isolated `AmtPsEclLib.psm1` (+ `AmtPsSortLib.psm1`) — never the Federale copy.
2. **Isolated init.** Set only the init-scope globals the run needs *without* the COM/app bring-up:
   - `$global:WarningRcw2435 = $false` — normally set by `Initialize` from `AmtSettings.xml`
     (AmtPsEclLib L587), **not** at module load; `Fin` reads it at L6051. Missing → the run throws
     at FIN.
   - The statement-context globals (`InSsg`, `SsgOptionB`, `GlobalSgsLabels`, `Rcw`,
     `PreviousStatement`, `FilesList`) are already set at module load — leave them.
3. **Seed SGS.** Create the per-job label store and seed it from the program's manifest values:
   ```powershell
   $global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
   foreach ($line in $seed.Sgs) { AddTo-SgsList $line }   # "LABEL field,field,field" (count-based)
   ```
   Add new programs to the `$seeds` table in `Run-StageA.ps1` (sourced from
   `Trial3/manifest/programs.manifest.json` `paramOverrides` / `conditionValues`).
4. **Run** `Examples/Output/<Program>.ps1 -Parameters $seed.Parameters` inside a `try/catch`.

### The expected Stage A boundary (COM cleanup)

The end-of-job cleanup calls `$global:Com.RemoveNonPrintedFiles($global:BatchId)` (AmtPsEclLib
L3157), an **unguarded** COM call (unlike the `$global:AmtFile -ne $null` guard just below it). With
no COM object this throws **after** the body has already run and printed `FIN`, `End Job`, and
`Script Done`. `Run-StageA.ps1` recognises this specific position (`RemoveNonPrintedFiles`) and
reports **PASS (Stage A)** with exit 0: the full body executed; only Stage B COM cleanup remains.

Do **not** try to fully mock `$global:Com`: installing a stub only triggers further COM property
accesses in the logging path (e.g. `$global:Com.Station` at L13989). Re-mocking the whole COM object
*is* Stage B. Keep `$global:Com` null and accept the honest boundary.

## Reporting

- **PASS (Stage A)** = the body ran to FIN/End Job/Script Done against the real lib and the only
  remaining step is the COM cleanup boundary above.
- **BLOCKED** = a missing runtime function, signature mismatch, or missing-global crash *before* FIN.
  That is a real converter/runtime-compatibility defect — log it as a `T3-nnn` issue per
  [ssg-todo-issues.instructions.md](ssg-todo-issues.instructions.md).
- Never edit the generated `.ps1` or the isolated `*.psm1` to force a pass.

## Closing action — update the tracker

Once a Stage A/B run has completed **and the user has reviewed it**, sync
[docs/SSG-PowerShell-Trial-Progress.html](../../docs/SSG-PowerShell-Trial-Progress.html) via the
[`/ssg-update-tracker`](../prompts/ssg-update-tracker.prompt.md) prompt (or directly): the §5b/§5c
runbooks, §3 status, §1 current-state and *Last updated*, plus any `T3-nnn` issue (§6) or `MT-nnn`
ToDo (§7) the run surfaced. This is the explicit step behind §8's "kept in step" note.

