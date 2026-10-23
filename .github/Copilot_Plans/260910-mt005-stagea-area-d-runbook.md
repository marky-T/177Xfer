---
title: "MT-005 Stage A+ — record CFH-COPY & Stage A runbooks, add Area D (run under real AMT runtime)"
date: "2026-09-10"
status: "in-progress"
owner: "MT"
---

# Plan: MT-005 Stage A+ / Area D runbook regime

Record the SSG→PowerShell trial's real-runtime run (Stage A) reproducibly for testers, and add a
fourth work area (D) for running converted programs under the real AMT runtime / Control Center,
with an end-to-end prompt that converts and runs a chosen report.

## Approved decisions
- **Option A** for Stage A+: craft a minimal `AmtSettings.xml` + call `Initialize` so `CFH-COPY.ps1`
  completes cleanly against the real `AmtPsEclLib` (most faithful). Fallback: set the missing init
  globals (`$global:WarningRcw2435` …) to reach a clean FIN, honestly documented.
- **Area D** is its own area (real runtime ≠ Tier-1 mock), with an e2e prompt.

## Phase 1 — Area D regime
- NEW `.github/instructions/ssg-amtcc-runbook.instructions.md` = **Area D — run converted PS under the
  real AMT runtime / Control Center**. Covers: isolated `Trials/RealRuntime/` copy of `AmtPsEclLib`
  (never modify `Federale_InternalRelease`); SGS seeding (`$global:SgsLabels` + `AddTo-SgsList
  "LABEL f,f,f"`, count-based); `Initialize(AmtSettings.xml)`; `DataLineOrNoStatement` routes by
  `$global:PreviousStatement`; Stage A (standalone vs real lib) vs Stage B (BatchController/CC,
  `Files\Extracts\<designator>.DAT` staging). Guardrails: do not wire into live FEDERALE_APP.
  `applyTo: "**/Trials/RealRuntime/**"` + keyword-rich description.
- `.github/copilot-instructions.md`: add **Area D** row to the work-areas table + Key-files pointer.
- NEW prompt `.github/prompts/ssg-e2e.prompt.md` = `/ssg-e2e <Program>` (mode: agent): pick a report →
  reconvert (Area C) → Tier-1 run (Area A) → real-runtime run (Area D Stage A) → report result. Drives
  the whole pipeline for one program.

## Phase 2 — Complete Stage A+ (Option A)
- Craft `SsgConverter/Trials/RealRuntime/AmtSettings.xml` from `Federale…/Scripts/Settings/AmtSettings.xml.sample`
  (minimal: AppName, logging off, no live app connection).
- NEW repo artifact `SsgConverter/Trials/RealRuntime/Run-StageA.ps1`: import isolated `AmtPsEclLib`,
  `Initialize <AmtSettings.xml>`, seed `$global:SgsLabels` for the program, stage a mock TAPEIN input,
  run `Examples/Output/<Program>.ps1`, capture emitted output; idempotent/isolated.
- Run for CFH-COPY; capture the clean output (or the reach-FIN + init note for the record).

## Phase 3 — Record runbooks (docs/SSG-PowerShell-Trial-Progress.html)
- **Program runbook — CFH-COPY** (`id="run-cfh-copy"`, mirror `#run-montant`): Item/Value table
  (SSG source, program key, seed file, Tier-1 command + 47-line output/diff) + Stage A note.
- **Stage A runbook** (`id="stagea-runbook"`, mirror `#controlcentrerunbook` §6b): numbered
  tester-reproducible steps — isolated copy → seed SGS → run `Run-StageA.ps1` → expected result → map
  to Stage B. Honest result box.
- Add nav "Runbooks" section; refresh Last-updated + MT-005/§1.

## Phase 4 — Verify
- Reload tracker + screenshot both runbook sections; confirm `Run-StageA.ps1` re-runs from clean.
- Update memory + MT-005 tracker status.

## Relevant files
- `.github/instructions/ssg-amtcc-runbook.instructions.md` (new), `.github/prompts/ssg-e2e.prompt.md` (new)
- `.github/copilot-instructions.md`, `docs/SSG-PowerShell-Trial-Progress.html`
- `SsgConverter/Trials/RealRuntime/{Run-StageA.ps1,AmtSettings.xml}` (new) + isolated `*.psm1` (present)
- model formats: `docs/SSG-ECL-PowerShell-Reference.html` `#run-montant` (L563), `#controlcentrerunbook` (L987)

## Guardrails
- `Federale_InternalRelease` is read-only reference; only ever COPY its libs into `Trials/RealRuntime/`.
- Do not connect to / modify the live FEDERALE_APP, its DB, or `ava`.
- Every step isolated, idempotent, re-runnable.
