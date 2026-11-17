# Copilot handover: DB SSG utilities, continue 261117

**Paste into a fresh session:**

> Read `E:\Repos\ssg4-work\handover-db-ssg-261117.md`, the report `E:\Repos\ssg4-work\report-db-ssg-261116.md` and the plan
> `.github/Copilot_Plans/261116-db-ssg-programs-plan.md`, then do the "Job" below. Stop at each gate.

## Where we stopped (261116 23:29)

- RECAP generic program G1–G8 done; **G8 PASS** in CC (run 1894) on the 6 cases that never call `EUU003`. Commits `a100b4a`, `3b615a2`.
- Team note `E:\Repos\ssg4-work\db-ssg-questions-for-team-261116.md` revised for the planning thread (problem first, T3 in
  brackets; Q10 board list re-checked on develop `88dc012f`). **Not shared**: planning thread first, then owner approval.
- Uncommitted in SsgTrial on purpose: the owner's own change to `.github/instructions/ssg-todo-issues.instructions.md`.
- Next free ids: **T3-071**, **MT-071**.

## Job

1. **Land T3-066 + T3-070** (owner, elevated): `Set-Location E:\Repos\SsgTrial; & E:\Repos\ssg4-work\t3066\Apply-T3-066-T3-070.ps1`.
   Pre-flight 261116 23:07: both source hashes original (`9FB1853B61AF`, `C0E600BEC3BE`), expected goldens complete, exactly
   ARCHIFORMAT, ARCHISEPARE, EXTEUR, RECAP, TABAN_ASCII change. Expected last line: `All 20 goldens equal the pre-tested output.`
   Then (agent): re-expand RECAP and TABAN (`Expand-AllCalls.ps1 -Program RECAP` / `TABAN_ASCII`), re-run
   `Generic/RECAP/check/Test-RecapParm.ps1` → expect **MATCH 28**; set `utilities.json` RECAP `check.crosscheck` to `{ "MATCH": 28 }`
   and its `known` text; mark T3-066 and T3-070 **fixed** on the tracker (and the plan §1); `-Stage Check -Utility All`.
   Owner commits the goldens + those changes (agent writes the message file).
   Generic skeleton copies (UTILIT_ARCHI*, UTILIT_EXTEUR, UTILIT_RECAP, UTILIT_TABAN_ASCII) change only at the MT-057 refresh
   (`amt-go-net-ours` build `_build\EclConverterConsole-ours-T3066` has both fixes; the live build is untouched).
2. **`/ssg-backup`**.
3. **TABAN** (next program to convert): `/ssg-generic-utility TABAN_ASCII`, G1–G7 as RECAP (same `EUU003` pattern, `NEURO` in
   6 calls, `CDTOAF` only under `Y2K`: no real caller), then a G8 on cases that never call `EUU003`.
4. EXTEUR waits for Q3/Q4 and the T3-067 decision.

## Rules (unchanged)
Area E: no shared pipeline script changes without the owner's go-ahead + full regress. `SSG-Source/` read-only. SsgTrial
converter source and goldens are admin-only: changes are tested in scratch and landed by the owner. Owner commits.
CC: log in at http://localhost:5100; `Conversion/Pipeline/ControlCenter/cc-actions.js` (`ccReadJobs`, `ccActivate`,
`ccStartJob`); Start Job's application filter must be set to `AFBUS_2200COBOL_AMT` first.
