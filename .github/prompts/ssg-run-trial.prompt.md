---
mode: agent
description: "Run a Tier-1 mock-harness trial for one SsgConverter-generated PowerShell program (Area A)"
argument-hint: "<Program> (e.g. ARCHISEPARE, CFH-COPY)"
---

# /ssg-run-trial — Tier-1 PowerShell trial

Run the repeatable Tier-1 trial for **${input:Program}**. Follow
[ssg-run-trials.instructions.md](../instructions/ssg-run-trials.instructions.md); do not do broad
workspace searches. Program key = the `SsgConverter/Examples/Output/<Program>.ps1` base name.

## Steps

1. **Orient.** Confirm `SsgConverter/Examples/Output/${input:Program}.ps1` and
   `SsgConverter/Trials/${input:Program}/sgs-values.json` exist. If the value table is missing, seed
   it from `Trial3/manifest/programs.manifest.json` (`paramOverrides` brackets stripped +
   `conditionValues`) and note that you created it.

2. **Parse-check first (no execution).** Report the error count:
   ```powershell
   $e=$null; [System.Management.Automation.Language.Parser]::ParseFile(
     "SsgConverter/Examples/Output/${input:Program}.ps1", [ref]$null, [ref]$e); $e.Count
   ```
   If > 0, show the first few errors, classify it as an **Area B** converter defect, and stop —
   do **not** hand-edit the generated `.ps1`.

3. **Run the harness** (only if parse = 0) from `SsgConverter/Trials/Tier1Mock/`:
   ```powershell
   .\Run-SsgPsTrial.ps1 -Program ${input:Program} -Diff
   ```

4. **Review** the summary: emitted line count, unmocked `GetSgsValue` lookups (add missing keys to
   `sgs-values.json`), `Call-ExternalProgram` calls, and the `-Diff` result vs the
   `Trial3/candidates/*${input:Program}*` golden.

5. **Prove repeatability** — run it a second time; confirm `out/${input:Program}.out.txt` is
   byte-identical.

6. **Report** one of: **PASS** (parse = 0 and diff acceptable) or **BLOCKED + root cause** (with the
   area that owns the fix). Never report done on a script that fails to parse.

7. **Update the tracker (closing action).** After the user has reviewed the result, run
   [`/ssg-update-tracker`](ssg-update-tracker.prompt.md) for `${input:Program}` to sync §3 status/stats,
   §1 current-state, *Last updated*, and any `T3-nnn`/`MT-nnn` the run surfaced.

## Guardrails
- Read-only against `SSG-Source/`. Never edit generated `.ps1` to force a pass.
- A missing runtime primitive is a harness gap (fix `SsgPsMockLib.psm1`), not a script edit.
- Do not run Trial3's pipeline past `-ListOnly` (ToDo MT-002).
