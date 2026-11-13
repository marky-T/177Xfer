# Handover — MT-068: generic pipeline with UseUnicode=False or True (261113)

For a **fresh Copilot session**. This work is separate from the rc.03 release / ADO tickets session; do not touch ADO
items, the rc.03 branch or its package from here.

## Paste this as the first message of the new session

> Start MT-068. Read `E:\Repos\ssg4-work\handover-mt068-useunicode-261113.md` and the plan
> `.github\Copilot_Plans\261113-useunicode-dual-mode-plan.md`, then do Phase 0 (baseline) and Phase 1 (pipeline switch),
> stopping at Gate 1 for my review. Area E rules apply (`ssg-generic-utility.instructions.md`).

## Goal (owner, 261113)

Extend the SSG-4 generic pipeline (`Conversion\Pipeline\Generic`) so the script set can be built and proven with either
`UseUnicode=False` or `UseUnicode=True` in `Settings\AmtSettings.xml`.
- **False** is proven (regression 18/18 PASS, 12 Nov 2026): keep the existing set-up and test packs as its proof, unchanged.
- **True**: switch the setting and run all 18 jobs. The owner expects no change inside the programs, but the line-reading
  behaviour may differ: watch the CR/LF issues **T3-059** (CONDIS2S, short lines merged into one record) and **T3-040**
  (BABA, short parameter lines; our padding workaround), also LECTIS.
- Why: the target system's value is unknown. The 11 Nov drop ships `UseUnicode=True` (and `AppName=AFBUS_AMT`) in
  `Scripts\Settings\AmtSettings.xml`; `AmtPsEclLib` defaults to True when the key is missing. The owner is checking the target
  value separately (MT-046; listed as an R&D confirmation on ADO Testing task 120437).

## Background facts (verified 261113)

- **T3-039**: with True, `Asy-Cat` pre-creates output files as UTF-16 (BOM); the COBOL program then writes UTF-16 records with
  no CR LF between them (VIRM01: 6,852 B instead of 3,425 B; decoded content identical). The trial application's option
  "Define Unicode for all extract files" is off, so we set False.
- `AmtPsEclLib` uses `$global:UseUnicode` in `Create-TextFile`, `CreateFileCycle`, `Assign`, and the sort
  (`AmtPsSortLib`: `SetUnicode`).
- Places in our pipeline that assume False:
  - `Deploy-GnScriptSet.ps1` line 21 hard-codes `UseUnicode = 'False'` (the switch point);
  - `environments.psd1` has no UseUnicode per profile (CC-Trial, CC-Federale, Repo-BSP, Mock);
  - `GnHandoff.ps1` line 11 reads the card file as ISO-8859-1 (UTF-16 cards would be misread); line 97 writes the parameter
    file ISO-8859-1, no BOM;
  - `Test-CcJob.ps1` (lines ~66–72) and `Test-CcPrints.ps1` byte-compare outputs; the per-utility `check` scripts in
    `utilities.json` "regress" steps too;
  - `Invoke-GnPipeline.ps1` Regress writes `<GenericWork>\regress-results.csv` (one result per job; a True run must not
    overwrite it); Package/`New-GnReleaseDocs.ps1` say "UseUnicode must be False".
- T3-059 rule and evidence: tracker row T3-059; probe `E:\Repos\ssg4-work\probe-t3059\FINDINGS.md`; CC job
  `SSG4_CONDIS2S_CASES` (cases `t3059-*`, `syn-d42-boundaries`).

## Rules

- False stays the default and stays proven: every change checked with False first (identical settings file, same results).
- Never change an expected output to make a True run pass; UTF-16 outputs are compared decoded and reported as such.
- Each new failure under True gets a `T3-nnn` on the tracker (`ssg-todo-issues.instructions.md`).
- One CC job at a time. Owner gates after Phase 1, Phase 2, and before deploying True (Phase 3).
- CC: log in at http://localhost:5100 (TransactionServer stops at start, T3-014). Repo commits are made elevated by the owner.

## State at hand-over

- Plan written: `.github\Copilot_Plans\261113-useunicode-dual-mode-plan.md` (phases 0–5, gates, open decision on the
  application's Unicode option).
- Tracker: **MT-068** opened (`docs\SSG-PowerShell-Trial-Progress.html`, §7). MT-046 has the 261113 recheck note.
- No pipeline code changed yet. CC-Trial's script set is deployed with False.
- Uncommitted in the repo (from the tickets session too): the plan, the tracker, `docs\RnD-Tickets\SSG4-RnD-tickets-261113.md`.
  The owner commits; the new session should not commit for the tickets session.
