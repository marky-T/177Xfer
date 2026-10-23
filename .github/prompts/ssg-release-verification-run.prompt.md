---
mode: agent
description: "Prove a deployed AMT Control Center release genuinely works: stage real mock input files, run a chosen set of programs live via the MT-025 batch runner, and diff real output against goldens where available."
argument-hint: "[-Programs <KEY,KEY,...> | -All] [-ReleaseLabel <rc-label>]"
---

# /ssg-release-verification-run — ${input:Programs}

Prove that a release already deployed to the live AMT Control Center basepath genuinely works — not
just "exit code 0, trust me" — by staging real mock input files, running each program for real
through the **MT-025 live batch runner**, and diffing actual output against a golden where one
exists. Tier-1 (Area A) and Stage A (Area D) already prove the converted *logic* runs in isolation;
this is the step that proves it against **real data, through the real Control Center**.

## Read first — this is background the routine depends on, not optional context

- **What's deployed right now**: bodies at `AmtTools\Basepaths\Scripts\<KEY>.ps1`, wrappers at
  `AmtTools\Basepaths\Scripts\SSGTRIAL\RUN\<KEY>-LIVE.ps1`. If unsure which `/ssg-release` cut is
  live, check the deployed `Scripts_SSG\RELEASE-NOTES.md` / `LastLiveValidation.json` for the label
  and converter fingerprint.
- **The live batch runner (MT-025)**: `AmtTools\Basepaths\Scripts\SSGTRIAL\RUN\{Run-LiveBatch.ps1,
  BatchConfig.json, RunList.txt, KnownIssues.json}`. Mechanics and the exact Start-Job parameter
  convention (file path / `ALL` / inline comma-list) are in
  [SSG-PowerShell-Trial-Progress.html §5](../../docs/SSG-PowerShell-Trial-Progress.html) under
  "run converted programs live via the batch runner".
- **Known caveats before you start**: `KnownIssues.json` (per-program notes, e.g. seed gaps), and
  [T3-013 / MT-024](../../docs/SSG-PowerShell-Trial-Progress.html) — the ComScript RID fix. It is
  **not durable**; a redeploy since the last fix silently reverts it and every program will fail
  identically. Re-check `ComScript.deps.json`'s `runtimeTarget` ends `win-x64` before concluding
  anything about the *programs* vs. the environment.
- **Mock input/expected data** (the "something to run against"): `Trial3/fixtures/<key>/` —
  `assign.json` (logical→physical file map), `input.dat` (mock input content), `expected.dat`
  (golden output), occasionally `_gen-fixtures.ps1` (run it first if the data files aren't already
  present — some fixtures are generated, not static). Cross-reference
  `SsgConverter/Trials/DiscDesignators.json` for the logical→**resolved ECL designator**
  (e.g. `ECL-TAPEIN`) each program's body actually opens.
  **Confirmed exact-key overlap with the 20 release programs so far**: `CFH-COPY`, `ARCHIFORMAT`,
  `ARCHISEPARE`, `LECTIS_ASCII` (fixture jobname `LECTIS` matches the PROGRAM-ID), `UNLOADIS_ASCII`
  (fixture folders `UNLOADIS_MULT`/`UNLOADIS_MULT-NODUP`, jobname `UNLOAD-ASCII` — confirmed 261007/
  T3-017 to match `UNLOADIS_ASCII`'s resolved `ECL-INPUT`/`ECL-OUTPUT`, **not** `UNLOADIS_MULTI` as
  their folder names suggest). Others are close-but-not-identical (`scan`↔`SCAN_ASCII` — unrelated
  logical names, `SCAN_ASCII`'s own designators are unresolved anyway; `LOADIS_MULT-NODUP`↔`LOADIS_ASCII`/
  `LOADIS_MULTI` — has an extra `PRINTER` field neither program's `DiscDesignators.json` entry has,
  still unresolved, see T3-017) — verify each one individually via its `assign.json`/
  `DiscDesignators.json` entry; never assume a name match is a data match (see
  `GoldenReconciliation.json`'s CFH-COPY_ASCII note for why that's dangerous, and T3-016: `TAPELD_DISTRIB/
  assign.json` is literally a mislabeled copy of CFH-COPY's fixture, not TAPELD_ASCII's).
  A program with no matching fixture can still be run live — just report it as an exit-code/joblog
  proof only, not an output-content proof.
- **Where mock files actually land**: `AmtTools\Basepaths\Extracts\` (sibling of `Scripts\`/
  `Logs\`/`Prints\`). This is a **standard, confirmed AMT feature** — the client/user governs it via
  the Control Center basepath configuration (AMT175 example already shown), not something this trial
  invented. Dropping fixture files straight into `Extracts\` under their resolved designator name is
  the normal/expected way to give a live job real data; it is reused **fresh each run** (archive-then-
  overwrite, step 3), never left to accumulate across runs.
- **Where process logging for this routine belongs**: a single structured register per run —
  `AmtTools\Basepaths\Logs\<yymmdd>\v<n>\release-verification-log.md` — versioned the same way as
  step 3's `Extracts\Archive-SSG-Verification\<yymmdd>\v<n>\` folder (`v1`, `v2`, ... incrementing if
  today already has one), so the two numbered trails line up run-for-run. Write it in the
  [docs/Asset-Register.md](../../docs/Asset-Register.md) register style (header block, numbered
  sections mirroring steps 1-8, tables over prose). Archive/stage/diff actions taken by this routine
  are **not** scratch output in the repo — this file is the durable record, living alongside the job
  logs it explains, not a one-off flat `.log` appended to ad hoc. **Copy that run's `Combined.log` +
  `results.csv`** (from `Scripts\SSGTRIAL\RUN\LiveBatchRuns\<stamp>\`, see step 6) **into the same
  `v<n>` folder** — found 261007: without this, a reviewer looking in `Logs\<yymmdd>\v<n>\` finds only
  the register and none of "the one log" it refers to, since `Combined.log`/`results.csv` are written
  to a different basepath subtree (under `Scripts\`, not `Logs\`) by design.

## Steps

1. **Resolve the program list.** Same convention as `/ssg-release`: explicit `-Programs`, or `-All`
   meaning every converted/released program. If neither is given, ask — don't silently pick a subset.

2. **Confirm the live deployment matches what you intend to verify.** Compare the deployed
   `<KEY>.ps1` (size/timestamp, or a hash) against `SsgConverter/Examples/Output/<KEY>.ps1` or the
   relevant `Scripts_SSG` release folder. If they differ, stop and ask whether to redeploy first —
   never silently verify stale bodies.

3. **Archive the previous verification run — first, before touching `Extracts\`.** Move (don't
   delete) whatever currently sits in `AmtTools\Basepaths\Extracts\` from a prior verification pass
   into `AmtTools\Basepaths\Extracts\Archive-SSG-Verification\<yymmdd>\v<n>\`, where `<yymmdd>` is
   today's date and `<n>` increments if an archive for today already exists (`v1`, `v2`, ...). Leave
   anything that isn't ours (unrelated client files) untouched. Start this run's
   `release-verification-log.md` (same `<yymmdd>\v<n>`) now and record the archive action (what
   moved, to where, or "nothing to archive") in it per the logging note above.

4. **Confirm the exact designator filename per program.** Most are a direct, literal match on the
   resolved `DiscDesignators.json` name (e.g. `ECL-TAPEIN`); a few are computed/dynamic (flagged with
   a `notes` field in `DiscDesignators.json`, e.g. BABA_ASCII's loop-generated designators) and need a
   quick check against that program's seed before you know the real name. If still genuinely unsure
   for a program, run it once with Debug-level logging (`<LoggingSeverity>Debug</LoggingSeverity>` in
   the live `AmtSettings.xml`) and read the joblog's `File-Exists:` / `Found assigned file:` lines —
   don't guess. Revert the severity change afterward unless the user wants Debug logging kept on for
   the whole pass (it makes the per-program proof more legible either way).

5. **Stage fresh fixtures.** For each requested program with a genuine fixture match, copy its
   `input.dat` into `Extracts\` under the confirmed designator filename from step 4. Use
   `assign.json` for the logical name. **Never fabricate a mapping** — if a fixture's logical names
   don't cleanly resolve, say so and skip staging for that program (it still runs, just without real
   input). This is a fresh drop every run — nothing here is expected to persist from the prior pass
   (that's what step 3 archived).

6. **Run them live.** Point the batch runner's `RunList.txt` at exactly the requested keys (or pass
   them inline via the Commandline parameter), Start Job `RUN-LIVEBATCH` in Control Center, and
   follow `progress.log` (`Get-Content -Wait`) rather than polling the CC UI. Each run writes
   `LiveBatchRuns\<stamp>\Combined.log` (261007 feature) — `progress.log` + every program's copied
   joblog + any non-empty stderr, stitched into one chronological file — review that one file rather
   than opening each program's separate joblog. **Note the location split**: the *real* per-program
   AMT joblogs (`T3_20_<KEY>_LIVE_*.log`, one per job — vendor-written, cannot be consolidated from
   here) land directly in `AmtTools\Basepaths\Logs\<yyyymmdd>\`, alongside every other job's logs,
   past and present — expect clutter there, it's normal. `Combined.log` and `results.csv` are
   generated separately, under `Scripts\SSGTRIAL\RUN\LiveBatchRuns\<stamp>\` — **copy both into this
   run's `Logs\<yyyymmdd>\v<n>\` folder** (next to `release-verification-log.md`, started in step 3)
   so everything for the run is in the one place a reviewer will actually look, not scattered across
   two different basepath subtrees.

7. **Verify against something real, not just exit code.** For each program with an `expected.dat`:
   locate whatever output file the body wrote under `Extracts\` (same designator mapping) and diff
   it byte-for-byte against `expected.dat`. Report byte-identical / differs (+ first difference
   offset) / not-found. For programs with no fixture, report exit code + outcome from `results.csv`
   only, and say plainly that output content wasn't verified.

8. **Translate and triage any non-English (French) output** found in `Combined.log`/joblogs this run
   (user rule, 261007) — don't just note "emits Log-Message" and move on. For every distinct French
   line/banner: translate it, then classify as exactly one of:
   - **A request that requires a reply** — phrased as a question/prompt expecting operator input or a
     decision. Treat as **blocking**: this needs a human answer *every run*, not a one-time review —
     log it as an open `T3-nnn` (never silently mark "known") and flag it plainly in the report.
   - **A note confirming some action** — informational/state-echo text (e.g. a schema name, a
     confirmation that something completed). Translate for the record in the run's
     `release-verification-log.md`; no further action needed.
   - **An error/warning which needs reviewing** — a genuine failure/validation-rule banner (e.g.
     CONDIS2_ASCII's "ERREUR..." PG-card rules, T3-019). Must be reviewed **at least once** per
     distinct message text — translate it and record the translation + classification in
     `KnownIssues.json` as `"known"` once reviewed; a later run whose `KnownIssues.json` entry already
     covers the exact text can skip re-review and just cite it. If the body changes (new converter
     output) and the text changes or moves, treat it as unreviewed again.
   Never guess a translation is "probably just a note" to skip triage — a mistranslated request-for-
   reply silently treated as a note is exactly the failure mode this rule exists to prevent.

9. **Report one line per program**: Key, outcome (Ok/Failed/Killed*), exit code, output-diff result,
   any `KnownIssues.json` note (including step 8's language triage result, where applicable).

10. **Close the loop.** Finish the run's `release-verification-log.md` (steps 4-9's findings, one
    section each). Log any new finding (a confirmed designator-filename convention, a genuine
    output mismatch, a fixture/key mapping gap, an unreviewed French message) as `T3-nnn`; update
    [the tracker](../../docs/SSG-PowerShell-Trial-Progress.html) §3/§6/§7, and `LastLiveValidation.json`
    if this run satisfies `/ssg-release`'s mechanics-fingerprint live-validation gate.

11. **End-of-session wrap-up.** List what's under `Extracts\Archive-SSG-Verification\` (all
    `<yymmdd>\v<n>\` folders, including the one step 3 created this session) and ask the user whether
    any are no longer needed and can be deleted. Never delete an archive folder without the user's
    say-so in that moment — this is a destructive, hard-to-reverse action.

## Guardrails

- This is a **live run against the real environment** (`E:\Repos\Federale_InternalRelease`) — not a
  mock. A `Killed*` outcome means `Fin`/`Cleanup` never ran (environment may be dirty); flag it, do
  not report it as a clean failure.
- `Trial3/fixtures/` and `SSG-Source/` are read-only references — copy from them, never edit them in
  place.
- Never invent a file-assignment mapping you haven't confirmed via `DiscDesignators.json` or a live
  Debug-log check (step 4) — an unverified guess here quietly invalidates the whole proof.
- **Archive before you overwrite** (step 3) — never drop fresh fixtures into `Extracts\` without
  first moving aside whatever a prior run left there. `Extracts\` is a shared, client-governed
  basepath, not scratch space owned solely by this routine.
- Process logging (archive/stage/diff actions) goes in the run's
  `AmtTools\Basepaths\Logs\<yymmdd>\v<n>\release-verification-log.md` register, not a repo-side
  scratch file or an unversioned flat `.log` — it needs to sit alongside the job logs it explains and
  line up with the matching `Extracts\Archive-SSG-Verification\<yymmdd>\v<n>\` folder.
- Per MT-026 (open): job/joblog names still use the internal `T3_20_<KEY>_LIVE` convention — expect
  to see that in Control Center and in joblog filenames; it's not a bug.
- **French/foreign-language output is never "probably fine" (step 8, MT-028).** Translate it and
  classify it (request-needing-reply / note / error-needing-review) every time it's found — a
  request for a reply is a **permanent blocker needing a human answer each run**, not something that
  becomes "known" after one review. Only error/warning banners get that one-review-then-known
  treatment, and only once their exact text is recorded in `KnownIssues.json`.
- Follow the diagnose-before-theorising rules ([T3-015](../../docs/SSG-PowerShell-Trial-Progress.html)):
  grep for a named error in our own code before calling it vendor noise, and don't attribute a result
  to the environment/timing when it could be our own staging/mapping being wrong.
