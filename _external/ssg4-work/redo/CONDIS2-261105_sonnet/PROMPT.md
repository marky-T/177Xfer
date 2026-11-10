# Prompt — CONDIS2 independent reconversion (Sonnet factory run, 261105)

Paste everything below the line into a **new chat** (workspace `SsgTrial`), model Sonnet 5.5.

---

You are doing an **independent, blind reconversion** of the SSG utility **CONDIS2** through both SSG-4 routes, for
the validation run MT-053 (plan `.github/Copilot_Plans/261105-condis2-route-validation-plan.md`). Your result will be
reviewed afterwards against earlier runs, so **work only from the sources and rules listed here**.

## Output folder (the only place you write)
`E:\Repos\ssg4-work\redo\CONDIS2-261105_sonnet\` (call it `<out>`), with sub-folders `percall\`, `generic\` (`gen\`,
`check\`, `cc\`, `cobol\`, `deploy\`), `evidence\`, and a final `REPORT.md`. Create them. Write **nothing** anywhere else.
Leave `PROMPT.md` in that folder unchanged.

## Read first (rules)
1. `.github/copilot-instructions.md` (Area E; guardrails).
2. `.github/instructions/ssg-generic-utility.instructions.md` (hand-made vs mechanical; design rules; evidence rules).
3. `.github/prompts/ssg-generic-utility.prompt.md` (steps G1–G8), and the templates in
   `.github/skills/ssg-generic-utility/templates/` (`spec.md`, `Parm.ps1`, `Test-Parm.ps1`, `Prepare-Cc.ps1`).
4. Runbook `docs/SSG4-ControlCenter-Runbook.html`, tab 6 (`#tab-method`) and tab 5 (`#tab-exec`).

## Blind rules — do NOT open or search these (they are what you will be compared with)
- `Conversion\Pipeline\Generic\CONDIS2\` (any file).
- The CONDIS2 entry of `Conversion\Pipeline\Generic\utilities.json` (other entries may be read as examples).
- `E:\Repos\release_candidates\` (all).
- `E:\Repos\ssg4-work\redo\CONDIS2-261105\` (the earlier run).
- `E:\Repos\ssg4-work\generic\CONDIS2\`, `E:\Repos\ssg4-work\release\`, `E:\Repos\ssg4-work\allcalls\` (earlier outputs).
- The deployed CC script set (`...\Basepaths\Scripts\...`), and any `*CONDIS*` DLL or C# source.
- Tracker / runbook / plan text describing CONDIS2's generic design: if you meet it while reading, do not use it as a source.
If you need something on this list, stop and ask me.

## Allowed sources and tools
- Skeleton (read-only): `SsgConverter\Examples\Input\CONDIS2_ASCII.TXT`; converted skeleton
  `SsgConverter\Examples\Output\CONDIS2_ASCII.ps1`; `Conversion\Pipeline\Generic\skeletons\UTILIT_CONDIS2_ASCII.ps1`.
- Cards: `E:\Repos\ssg4-work\sgs-cards\` (`sgs-calls.csv`, rows with `ProgramKey = CONDIS2_ASCII`).
- Shared mechanical scripts, **run but never edit**: `Conversion\Pipeline\{Build-AppLionSource.ps1, Expand-AllCalls.ps1,
  Invoke-SsgExpansion.ps1, Invoke-CobolConversion.ps1, SgsCardChecks.ps1}`, `Conversion\Pipeline\Generic\{GnHandoff.ps1,
  GnEnvironment.ps1, Deploy-GnSkeleton.ps1}`, and the isolated `SsgConverter\Trials\RealRuntime\AmtPsEclLib.psm1`.
- Other utilities' folders under `Conversion\Pipeline\Generic\` (CHABAN, CFH-COPY, BABA, FUSBA, ...) as **examples of style only**.

## Work

### Part 1 — per-call route (mechanical)
1. `Build-AppLionSource.ps1 -Programs CONDIS2_ASCII -CallIndex 1 -WorkDir <out>\percall` (expansion of the first call + LionSource).
2. `Expand-AllCalls.ps1 -Program CONDIS2_ASCII -Out <out>\percall\allcalls` (every real call).
3. `evidence\percall.txt`: number of calls, how many expanded, which failed and why, conversion errors and warnings.

### Part 2 — generic route (hand-made G1–G7, then the offline mechanical part)
Follow `/ssg-generic-utility` in **scratch** mode, with `<out>\generic` as the target. Names: program
`ASSURFED-UTILIT-CONDIS2-GN`, XQT name `CONDIS2`, include `CondisParm`, parameter file name of your choice.
- **G1** shapes table of all calls (from part 1's expansions and the cards) → `evidence\shapes.md`.
- **G2** `generic\spec.md` from the template, written from the skeleton and the expansions only.
  **GATE: stop, show me a summary and the open UNKNOWNs, wait for "continue".**
- **G3** `generic\check\CondisModel.ps1` (reference model from the spec) and seeded test cases in `generic\check\cases\`,
  covering at least: no CASE; CASE + OTHERWISE; every date code used by the real calls; CONST; a short record.
  Run it twice: outputs byte-identical.
- **G4** `generic\gen\ASSURFED-UTILIT-CONDIS2-GN.cob` per the design rules; convert with
  `Invoke-CobolConversion.ps1 -WorkDir <out>\generic\cobol` → 0 errors; list each warning.
- **G5** `generic\gen\CondisParm.ps1` (`Get-CondisParmLines`, `Invoke-CondisHandoff`) from the template.
- **G6** do **not** edit `utilities.json`; write the entry you would add to `generic\utilities-entry.json`.
- **G7** `generic\check\Test-CondisParm.ps1` from the template, reading the expansions from `<out>\percall\allcalls` and writing
  to `<out>\evidence\` → `crosscheck.csv` + counts. Explain every non-MATCH.
  **GATE: stop, show me the counts, wait for "continue".**
- **Deploy dry run:** `Deploy-GnSkeleton.ps1 -Skeleton UTILIT_CONDIS2_ASCII -ParmScript <out>\generic\gen\CondisParm.ps1
  -Call 'Invoke-CondisHandoff' -Target <out>\generic\deploy` → parse errors 0. `-Target` is mandatory: never deploy to CC.
- **G8** write `generic\cc\Prepare-CondisCc.ps1` from the template, **do not run it** (no LionDev, Deliver or CC).

### Part 3 — report
`<out>\REPORT.md`: per step what you did, the commands, counts, every file created, open UNKNOWNs, every deviation from
the rules, and time taken per part. No comparison with earlier runs (that is the review's job).

## Hard limits
- Never edit anything outside `<out>`; never edit `SSG-Source\`; never run `Invoke-GnPipeline.ps1` stages
  Deliver / Deploy / Regress / Package; never touch CC, LionDev, SQL or AMT services; no git commits.
- PowerShell: one-letter names such as `H` and `R` are built-in aliases, so use full function names. SGS label lookups in upper case.
- If a shared script fails, report it; do not patch it.
