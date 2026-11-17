# Report: DB SSG utilities (RECAP, TABAN, EXTEUR), session 261116

For the planning thread. Handover: `E:\Repos\ssg4-work\handover-db-ssg-261116.md`. Plan:
`.github/Copilot_Plans/261116-db-ssg-programs-plan.md`. Work item **MT-069** (spike **MT-070**).

## RECAP gate reached: **G8 PASS** (cases without EUU003); full G8 waits for Q1–Q3

- G1 shapes (28 calls: 17 same layout, 4 whole-record, 6 moved, 1 moved+resized; all ASCII; 2 with `NEURO`).
- G2 spec approved (`Conversion/Pipeline/Generic/RECAP/spec.md`), with **assumptions A1–A10 pushed through** for the end-to-end
  proof and ACOB/SSG manual quotes Q-1…Q-7.
- G3 model: 59 TEST DATA cases, repeatable byte for byte. G4 `RECAP-GN.cob`: 0 conversion errors. G5 `RecapParm.ps1`.
  G6 catalog. G7: 28 real calls **MATCH 26, DIFF 2** (both `NEURO`, T3-070; **28/28** against the fixed expansions); writer vs
  model 59/59; `-Stage Check -Utility All` passed.
- **G8 in Control Center** (job `SSG4_RECAP_CASES`, run 1894, 261116 22:08, AFBUS_2200COBOL_AMT, UseUnicode True), on the 6 cases
  that never call `EUU003` (RISH02 L284 + 5 real-call card sets with every total on `NEURO`): **6/6 output files byte-identical,
  6/6 reports (84 lines) identical to the model**.
- **What stopped a full G8:** the other 26 real-call shapes call `EUU003`, which needs `EUU003`/`INFRUN`/`ABRDMS` and tables
  `EU001`/`EU002`; these are in BSP_AMT, not in our test application AFBUS_2200COBOL (Q1–Q3).
- Findings from the run: AMT stores and displays the sign overpunch exactly as the ACOB manual says (A7); AMT resolves
  `CALL 'EUU003'` only when executed (A10). The first check failed only on our test set-up (PRN check; RECAP prints to the job
  log): check replaced (`cc/Check-RecapCc.ps1`), same run re-checked, no program change.

## Issues found

| ID | One line | Status |
|---|---|---|
| T3-066 | Our SsgConverter treated a literal `@` ECL image as text (EXTEUR: ECL in the expanded COBOL, 20 errors) | **fixed in scratch, proven** (17/20 examples identical, 3 changed and accounted for; EXTEUR 99 → 79 errors); **open — owner lands** `E:\Repos\ssg4-work\t3066\Apply-T3-066-T3-070.ps1` (elevated) |
| T3-067 | Our per-call scripts convert the `@UCOB` program EXTEUR in COBOL-74 mode and keep its ECL (69 errors) | **spike proven** (MT-070: EXTEUR → 10 errors, ACOB programs unchanged); **open — owner decides** the shared-script change + full regress |
| T3-068 | RECAP generates `PIC X(0)` for a 1-byte output field (4 real calls) | **generic route works** (CC); **open — Eddy** (Q7, OS 2200 behaviour) |
| T3-069 | ECL converter writes `@USE` with unescaped `$` → fails under StrictMode (same on R&D develop `88dc012f`) | **open — R&D**; board candidate (Q10, Migration Lead courtesy) |
| T3-070 | Our SsgConverter replaced the label of `[NEURO,1]` with a same-named variable, so `NEURO` was ignored (8 real calls) | **fixed in scratch, proven** (18/20 examples identical, RECAP/TABAN 4 lines each; exactly the 8 NEURO calls change); **open — owner lands** with T3-066 |
| T3-027 | extended: `RSA$INIT`/`ACOB$RDMR` pass conversion silently; the session only serves `EUU003` | open — R&D (Q5); generic route drops it (A2) |
| T3-037 | extended: only 10 of EXTEUR's 99 errors are the `INVOKE TABLE EU001` (rest T3-066/T3-067) | open — R&D (Q4) |

Also: Tier-1 mock gained `Asg`/`Use`/`Free` (additive). The "4 warnings" on every conversion are the 4 comments in our macros
file (kept; documented in `/ssg-generic-utility` G4). `CDTOAF` is never reached by a real TABAN call (only under `Y2K`).
Corrections to the plan: EXTEUR is `@UCOB` (UCS COBOL-85), not ACOB; AMT's `Euu003` calls `ABRDMS` on a SQL error (`EREABT$`
only in commented code).

## MT rows and board candidates

- **MT-069** added (plan + probe + RECAP G1–G8); **MT-070** added (spike T3-067).
- Board candidates (`docs/RnD-Tickets/board-candidates.md`): **T3-069** ready; **T3-066, T3-070** with the MT-058 merge;
  T3-068 not yet (Eddy); T3-067, T3-027 ours only. Nothing created on ADO.

## Team note

`E:\Repos\ssg4-work\db-ssg-questions-for-team-261116.md` (10 questions with expected answers; A1–A10; fixed and open items).
**Not shared**; owner approval pending, **planning-thread review first**. Revised 261116 after the planning thread: every item
says the problem first, our T3 id only in brackets; Q10 asks Allard to agree the board list in plain words (T3-059, T3-023,
T3-020, T3-046, T3-069), each re-checked on develop `88dc012f`: all still present; T3-020 and T3-046 checked in the source
(files unchanged since 261009), not yet by a conversion with a develop build (`board-candidates.md` updated).

## Commits

- `a100b4a` SSG-4 MT-069: DB SSG utilities probe + generic RECAP (G1-G8, CC PASS without EUU003) — 429 files.
- `3b615a2` SSG-4 MT-069: board re-check T3-020/T3-046 on develop; Euu003 calls ABRDMS — 3 files.
- Not committed (on purpose): owner's own earlier change to
  `.github/instructions/ssg-todo-issues.instructions.md` left out on purpose.
- `/ssg-backup`: **not run yet**.
- Outside git: `amt-go-net-ours` `SymstreamProcessor.cs` (T3-066) and `SymstreamExpressionParser.cs` (T3-070) patched, backups in
  `E:\Repos\ssg4-work\t3066\` (README-DELETE-AFTER, earliest clean-up 261216); separate build `_build\EclConverterConsole-ours-T3066`
  (the live build is untouched). Build note: `amt-go-net-ours` now needs `-p:NuGetAudit=false -p:SignAssembly=false`.

## Next step

1. Owner: land T3-066 + T3-070 (`Apply-T3-066-T3-070.ps1`, elevated), commit the goldens; RECAP's G7 baseline then becomes MATCH 28.
2. Planning thread: review the team note, then share with Allard / Eddy / Hagop.
3. **TABAN** through G1–G7 (27 calls, same `EUU003` pattern, `NEURO` in 6 calls); a no-`EUU003` G8 as for RECAP.
4. **EXTEUR** after Q3/Q4 (EU001 in AMT; `Copbk_Eu001`), and after the T3-067 decision.
5. Full RECAP/TABAN G8 once Q1–Q3 are answered (likely: test and release in BSP).
