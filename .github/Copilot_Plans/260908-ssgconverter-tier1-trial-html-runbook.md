---
title: "Repeatable SsgConverter Tier-1 Trial + HTML Runbook"
date: "2026-09-08"
status: "in-progress"
owner: "Mark"
---

# Plan: Repeatable SsgConverter Tier-1 trial + HTML runbook

## Correction from earlier research turn
Earlier assumption was wrong: `AmtPsEclLib.psm1`'s full COM/`Connect-Application` stack is
**not** required to run a converted `.ps1` "locally". `docs/SSG-ECL-PowerShell-Reference.html`
§2 already documents a proven 3-tier model for the COBOL→C# stream:

- **Tier 1 — mock-shell**: thin harness stands in for PowerShell+BatchController, no AMT stack needed.
- **Tier 2 — AMT .NET runtime**: real compiled C# run via Control Center/BatchController (proven for
  MONTANT + CFH_COPY, file-staging at `%SYSROOT%\Files\Extracts\<designator>.DAT`).
- **Tier 3 — full PowerShell ECL orchestration**: real `AmtPsEclLib` + BatchController Xqt. Marked
  "optional" in the doc, not yet proven for any program.

SsgConverter's PS output = "Stream B" (ECL/SSG job-control layer). Running it locally = Tier 1 (needs
only a lightweight mock of the handful of functions it calls: `GetSgsValue`, `DataLineOrNoStatement`,
`CompareTypeSafe`, `Process-Skip`, `Sort-SgsList`, `Call-ExternalProgram`, `Fin`, `Abort`). Running it
"for real" via AMT CC = Tier 3, not Tier 2 (no C# compile step for this stream) — heavier, unproven so
far, gated as a later phase. The naming-mismatch gap noted earlier in `docs/Asset-Register.md` is out
of scope for this plan.

## Subset
Primary: **ARCHISEPARE + CFH-COPY** (both have existing Trial3 candidates as cross-check goldens:
`Trial3/candidates/trial-12-archisepare/`, `Trial3/candidates/trial-11-cfh-copy/`).

## Phases
- **Phase 0** — re-run `SsgConverterConsole.exe` on the Examples/Input subset, review warnings vs
  the taxonomy in `SsgConverter-COPILOT.md`.
- **Phase 1** — build Tier-1 mock-shell (`SsgConverter/Trials/Tier1Mock/SsgPsMockLib.psm1` +
  `Run-SsgPsTrial.ps1`), per-program SGS value table (reuse Trial3 manifest `paramOverrides`/
  `conditionValues` for ARCHISEPARE/CFH-COPY), diff captured output vs golden. Must be
  idempotent/repeatable.
- **Phase 2** — new HTML doc `docs/SSG-PowerShell-Trial-Reference.html`, styled like
  `docs/SSG-ECL-PowerShell-Reference.html` (reuse CSS/nav/section-card/badge chrome), per-program
  runbook entries with `id="run-<name>"`, warnings catalogue, troubleshooting section.
- **Phase 3** (gated, later) — Tier-3 real AMT CC run via `Federale_InternalRelease` `AmtPsEclLib`;
  isolated test job, do not overwrite existing `ASSURFED_UTILIT_*` stubs without explicit confirmation.

## Relevant files
- `SsgConverter/Trials/Tier1Mock/SsgPsMockLib.psm1` — new, mock runtime functions
- `SsgConverter/Trials/Tier1Mock/Run-SsgPsTrial.ps1` — new, repeatable driver
- `SsgConverter/Examples/Output/ARCHISEPARE.ps1`, `CFH-COPY.ps1` — inputs to the harness
- `Trial3/manifest/programs.manifest.json` — source of the SGS value tables + goldens for cross-check
- `docs/SSG-ECL-PowerShell-Reference.html` — style/structure template to copy
- `docs/SSG-PowerShell-Trial-Reference.html` — new deliverable

## Verification
1. `Run-SsgPsTrial.ps1` for ARCHISEPARE and CFH-COPY → diff=0 vs the Trial3 candidate goldens.
2. Re-running the harness twice produces byte-identical output (proves repeatability).
3. Fresh SsgConverterConsole run's warnings match/explain against the known taxonomy.
4. New HTML page opens correctly and visually matches the existing reference's nav/badges/section-cards.

## Status
Phase 3 deferred pending separate go/no-go; not started this pass.
