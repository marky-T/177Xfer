---
mode: agent
description: "End-to-end: pick one report, (re)convert its SSG source to PowerShell, run it in the Tier-1 mock harness, then run it against the real AMT runtime (Area D, Stage A)"
argument-hint: "<Program> (e.g. CFH-COPY, ARCHISEPARE)"
---

# /ssg-e2e — convert one report and run it end to end

Drive the whole pipeline for **${input:Program}**: reconvert its SSG source → PowerShell, prove it in
the Tier-1 mock harness, then run it against the **real** `AmtPsEclLib` runtime (isolated Stage A).
Program key = the `SsgConverter/Examples/Output/<Program>.ps1` base name.

Follow the area instructions rather than broad workspace searches:
[ssg-reconvert](../instructions/ssg-reconvert.instructions.md) (C),
[ssg-run-trials](../instructions/ssg-run-trials.instructions.md) (A),
[ssg-amtcc-runbook](../instructions/ssg-amtcc-runbook.instructions.md) (D).

## Steps

1. **Convert (Area C).** Regenerate `SsgConverter/Examples/Output/${input:Program}.ps1` from its SSG
   source with the verified console. If the source/settings aren't wired for this program, say so and
   stop — do not invent inputs. Report the parse-error count (must be **0**).

2. **Tier-1 run (Area A).** From `SsgConverter/Trials/Tier1Mock/`:
   ```powershell
   .\Run-SsgPsTrial.ps1 -Program ${input:Program} -Diff
   ```
   Report emitted line count, any unmocked `GetSgsValue` lookups, and the diff result. Seed
   `SsgConverter/Trials/${input:Program}/sgs-values.json` from the manifest if missing. If parse > 0,
   this is an **Area B** converter defect — log a `T3-nnn` and stop.

3. **Real-runtime run (Area D, Stage A).** From `SsgConverter/Trials/RealRuntime/`:
   ```powershell
   pwsh -NoProfile -File .\Run-StageA.ps1 -Program ${input:Program}
   ```
   If `${input:Program}` has no `$seeds` entry in `Run-StageA.ps1`, add one from
   `Trial3/manifest/programs.manifest.json` (`paramOverrides` / `conditionValues`) and note it.
   Expected PASS = full body runs to FIN/End Job/Script Done; only the COM-cleanup boundary
   (`RemoveNonPrintedFiles`) remains (Stage B). A crash **before** FIN is a real compatibility defect
   → log a `T3-nnn`.

4. **Report** a single line per stage: **Convert** (parse count), **Tier-1** (PASS/BLOCKED + lines),
   **Stage A** (PASS/BLOCKED). Prove repeatability by re-running steps 2–3 once; output must be
   stable.

5. **Update the tracker (closing action).** After the user reviews the result, run
   [`/ssg-update-tracker`](ssg-update-tracker.prompt.md) for `${input:Program}` to sync §3 status/stats,
   the §5b/§5c runbooks, §1 current-state, *Last updated*, and any `T3-nnn`/`MT-nnn` surfaced.

## Guardrails
- `SSG-Source/` is read-only; never hand-edit a generated `.ps1` to force a pass.
- **Do not** call `Initialize` / `Connect-Application` or touch `E:\Repos\Federale_InternalRelease`,
  the live FEDERALE_APP, its DB, or `ava` — Stage A uses only the isolated `Trials/RealRuntime/` copy.
- Do not run Trial3's pipeline past `-ListOnly` (ToDo MT-002).
- Log any bug as `T3-nnn` and any new pipeline function / feature as `MT-nnn` per
  [ssg-todo-issues](../instructions/ssg-todo-issues.instructions.md).
