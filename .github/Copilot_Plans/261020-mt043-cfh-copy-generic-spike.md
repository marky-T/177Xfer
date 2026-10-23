---
title: "MT-043 spike — one generic CFH-COPY program fed by the SGS cards at run time (option b)"
date: "2026-10-20"
status: "draft — for review"
owner: "Mark"
---

# Spike: one CFH-COPY program for every call (option b)

**Goal.** Prove in the real Control Center that **one** CFH-COPY program, built once, produces the right
output for **two different card sets** with no rebuild: AFPH12 L427 (80 → 22) and VIRM01_CO L484
(500 → 135, 10 field moves, one constant). Both have independent references already.

**Why.** Per-call builds do not scale (CFH-COPY 47 calls / 33 card sets; ~275 card sets over 359 calls for
our programs). Owner decision 2026-10-20: (a) per-card-set builds and (c) run-time compile are not pursued;
(b) one program per skeleton is under consideration. This spike tests (b) on the simplest skeleton.
Context: runbook C7 (`docs/SSG4-ControlCenter-Runbook.html#c-ecl`), tracker MT-043, T3-038.

**Not in scope.** The other 19 skeletons; changing R&D's `AmtPsEclLib` (`Invoke-Ssg`, `Xqt`) or R&D's
converted runstreams; FEDERALE_APP.

## What CFH-COPY actually does (from the 47 real calls, expanded with AMT's own SGS functions)

Read from `E:\Repos\ssg4-work\allcalls\expanded\CFH-COPY_ASCII__*.cob` (evidence: `OBSERVED_IN_FEDERALE_SOURCE`
cards + our expansion):

- Cards used: `ASCII`, `INPUT name,len,blk`, `OUTPUT name,len,blk` (all 47), `FIELDIN`/`FIELDOUT` pairs (33),
  `FIXE pos,len,constant` (19), `STARTREC` (1). The skeleton also knows `PRINT`, `REPRISE`, `MAXCOPY`, `SUPCOM`,
  `REPSIM`, `STARTFIELD`, `Y2K`, `COND`, but **no real call uses them**.
- Per record: `MOVE SPACES TO RECOUT`, `READ`; then either `MOVE RECIN TO RECOUT` (whole record) or one
  `MOVE ZONEn TO ZONOn` per FIELDIN/FIELDOUT pair (input start,len → output start,len; pad/truncate); then each
  FIXE constant at its position with `INSPECT ... REPLACING ALL '<' BY ';'`; `WRITE RECOUT`.
- End: `DISPLAY '*CFH-COPY  FIN*'`, `'*NB-ENREG-LUS ='` count, `REC-SKIPPED`.
- Sizes: input up to 3,896, output up to 3,300; up to 13 field moves and 7 constants. Only 1 of 47 has any other
  verb (to classify in step 0).

So the generic program is a small interpreter of a parameter table, not a re-implementation of SSG.

## Design (to confirm in step 0/1)

**Program.** Written once in **COBOL** and taken through our own chain (C4 COBOL converter → C5 LionDev 177 →
C6 177a rebuild), so the C# is still AMT's output. Working name `ASSURFED-UTILIT-CFH-COPY-G`
(job `ASSURFED_UTILIT_CFH_COPY_G`). Large fixed buffers (e.g. 4,000), field moves by reference modification with
run-time positions (`MOVE WS-IN(I-START:I-LEN) TO WS-OUT(O-START:O-LEN)`), output written at exactly the OUTPUT
length (`RECORD VARYING ... DEPENDING ON`), same DISPLAY lines as today.

**Parameters.** A small parameter file (logical name e.g. `SGSPARM`) with one resolved line per item:
input/output name and length, each move, each constant. Resolved values, not raw cards, so the COBOL does no
card parsing.

**Hand-off (ours, no R&D change).** `Invoke-Ssg` (R&D) runs **our** converted skeleton in the job's session with
the call's cards loaded, just before `Asg`/`Use`/`Xqt`. A hand-off block at the end of the skeleton:
1. writes the parameter file from the loaded SGS values and assigns it (`Asg`/`Use SGSPARM`), so `End-Xqt` passes it
   to the program with the other files;
2. adds a run-time `CloneReports` entry (`CFH_COPY` → `ASSURFED_UTILIT_CFH_COPY_G`) to `$global:CloneReports`,
   which `End-Xqt` reads at the moment of the `Xqt`. This also covers the case where one `Xqt` name serves two
   skeletons (FUSBA/FUSBA2, LOADIS/LOADIS_MULTI).
For the spike the block is added by hand to the deployed skeleton copy and marked; if it works, the SsgConverter
(Area B) or a shared module would emit it.

## Open questions the spike must answer (highest risk first)

| # | Question | How we find out | If no |
|---|---|---|---|
| Q1 | **File names.** The runstream assigns the logical names from the cards (`INASC`/`OUTASC` at AFPH12, `INB`/`INC` at VIRM01). A generic program has fixed `SELECT ... ASSIGN` names. Does AMT's COBOL support a run-time file name (`ASSIGN TO` a data item / `VALUE OF FILE-ID`), so the program opens the names given in the parameter file? | Tiny COBOL test through the COBOL converter and the mock system (no LionDev for the test if a standalone build is enough; else one LionDev round) | Fall back: hand-off adds `Use` aliases (fixed names → same physical files). That needs the hand-off to run after the runstream's `Use`, which it does not; would need a different hook. Stop and report. |
| Q2 | Reference modification with variables and `RECORD VARYING DEPENDING ON` on a line-sequential ASCII file: does AMT write exactly OUTPUT-length records + CRLF (reference `OUTASC` = 25 × (22+2) = 600 B)? | Same test | Pad/trim choice in the program; compare bytes |
| Q3 | Does a `$global:CloneReports` entry set inside the skeleton survive to `End-Xqt` (scope: `Invoke-Ssg` → `StartSSG`/`EndSSG`)? | Read `StartSSG`/`EndSSG`; confirm in the CC run log ("Starting Cobol program: …_G") | Use the settings-file `CloneReports` for the spike (static, one name) |
| Q4 | T3-038: BatchController lock timeouts around script jobs. Does it stop the spike? | Check the SSG-3 `-LIVE` script jobs (also registered in `AFBUS_2200COBOL_AMT`) in older BatchController logs for the same pattern; restart between runs if needed | Log and continue; raise with R&D |
| Q5 | VIRM01_CO: 8 calls share one `P$SGS\VIRM01` file (T3-020). | Spike runs only the L484 step, with its own cards in `Extracts\P$SGS\VIRM01` | Out of spike scope |

## Steps

| # | Step | Who | Output | Gate |
|---|---|---|---|---|
| 0 | Behaviour inventory of all 47 expanded calls (classify whole-record / moves / FIXE / STARTREC / the one odd call) and write the generic spec with the exact byte behaviour | me | `Conversion\Pipeline\Generic\CFH-COPY\spec.md`, inventory csv | spec covers 47/47 or lists exceptions |
| 1 | Answer Q1–Q3 with a minimal COBOL test program (dynamic file name, ref-mod, RECORD VARYING) through the COBOL converter and the mock system | me (+ you if a LionDev round is needed) | test result note | Q1 yes, else stop and report |
| 2 | Write the generic COBOL + a parameter-file writer (PowerShell, from SGS values) | me | `.cob`, `Write-CfhParm` | converts with 0 errors |
| 3 | Mock proof: parameter files for AFPH12 and VIRM01, run the generic program in the mock system, byte-compare with both references | me | PASS × 2 | both byte-identical |
| 4 | Build for real: `.LionSource` → LionDev 177 import/Get newest/generate → 177a rebuild → package | you (LionDev), me (rest) | `ASSURFED_UTILIT_CFH_COPY_G.dll` | generated 1, not generated 0 |
| 5 | Deliver + register: copy DLL to `<APPROOT>\Programs`, restart services (elevated), Read all jobs, activate | you (restart), me | job registered | listed in Start Job |
| 6 | CC run 1 (AFPH12): hand-off skeleton + `SSG4_AFPH12_CFH_COPY` script job; compare `IAFB012FAI.DAT` with the AFPH12 reference | me | PASS | log shows `…_G` started; byte-identical |
| 7 | CC run 2 (VIRM01_CO L484): new script `SSG4_VIRM01_CFH_COPY` (statements copied from R&D's converted script lines 760–770), its cards in `P$SGS\VIRM01`, input `I006VRM01ATT`; compare `I006VRM01ATC` with `MockTest\VIRM01\expected\INC` (3,425 B) | me | PASS | byte-identical, **same DLL, no rebuild** |
| 8 | Record: runbook C7 (and a Run record entry if you want it), tracker MT-043, PROCESS.md, memory; recommendation for the other 19 skeletons | me | docs | — |

**Success = steps 6 and 7 both byte-identical with the same `…_G` DLL.**
Stop points: after step 1 (if Q1 fails) and after step 3 (if the mock proof fails), with a short report.

## Effort (no time estimate)

One manual LionDev round (step 4) and two elevated restarts (step 5, plus any T3-038 recovery) from you. Everything
else is scripted by me, one job at a time, each step re-runnable. The biggest unknown is Q1; it is answered first and
cheaply.

## Decisions needed before starting

1. Go ahead with the spike as above?
2. Program name `ASSURFED-UTILIT-CFH-COPY-G` — or another convention for generic programs?
3. Hand-off in the skeleton (our converter output) is acceptable as the mechanism, given `Invoke-Ssg`/`Xqt` stay
   untouched?
(All three agreed 2026-10-20.)

## Findings so far (2026-10-20)

- Step 0: 47 calls → 18 moves / 14 moves+FIXE / 9 whole record / 1 STARTREC / 5 expansions broken by a quoted all-space
  FIXE (T3-028). Parameter files from the cards match the skeleton's own expansion for 41 of 42; the one difference
  (AFID01 `'+'`) is a defect in the static expansion (`VALUE ''+''`), not in the parameter file. A PowerShell model of
  the generic logic is byte-identical on both references (AFPH12 600 B, VIRM01_CO 3,425 B).
- Q1 **no**: LionDev 177 generates `ASSIGN TO <data-name>` as the literal file name (`SetOptions("WS-INNAME")`), so
  `-G` is dead. Fallback `-GF` (one SELECT per known name, 22 in / 21 out, generated from the inventory) generates fine.
- Q2 **not as hoped**: the mock run of `-GF` gives correct record content but every record 4,000 bytes (first
  difference exactly at the output length). Runtime cause: `AmtBaseCobolFunctions.PrepareWriteBuffer` overwrites the
  `RECORD VARYING ... DEPENDING ON` field with the layout size before `AddRecord` (only skipped when
  `Configuration.UseSQLite`); an `OCCURS ... DEPENDING ON` output record does not change that (`RecSize` =
  `m_DataRecord.Length`). Variable-length line-sequential output from COBOL is therefore not available this way.
- Remaining route found in the runtime: task value `RECSIZE<logical name>` (`AmtFileId.GetPhysicalFile`) sets the
  file's record size at open; with a fixed (non-VARYING) output FD the write length is then that size. The hand-off
  could set it on the task object (after `Check-ClearTaskObject`). Costs: one more LionDev round (output FD without
  VARYING), and it can only be tested in Control Center (the mock runner passes no task values). Question for R&D
  (MT-033): the intended way to write variable-length records from AMT COBOL.

## Result (2026-10-20): the spike works

We took the `RECSIZE` route (owner: "one more alternative, run it"): `-GF` revision 1.3 with **fixed** output FDs.
The hand-off also sets task value `RECSIZE<output name>` (after `Check-ClearTaskObject`), alongside the parameter
file and the run-time `CloneReports` mapping. It runs as one DLL, `ASSURFED_UTILIT_CFH_COPY_GF.dll` (47,616 B, 177a
rebuild), delivered as a new file.

| Run | Call | Hand-off | Output | Result |
|---|---|---|---|---|
| 424 (16:46) | AFPH12 L427, 80 → 22, 1 move | 3 parameter lines, `RECSIZEOUTASC` | `IAFB012FAI.DAT` 600 B | **PASS**, byte-identical |
| 426 (16:50) | VIRM01_CO L484, 500 → 135, 10 moves + constant | 13 lines, `RECSIZEINC` | `I006VRM01ATC.DAT` 6,852 B = UTF-16 BOM + 25 × 137 × 2 | **PASS on content**: decoded, byte-identical to the 3,425 B reference |

Both job logs show the same sequence: `XQT: .CFH-COPY`, then *Starting Cobol program: ASSURFED_UTILIT_CFH_COPY_GF*,
then 25 records, then *Script Done*.

The UTF-16 output comes from the runstream, not the program. VIRM01_CO pre-creates its output with `Asy-Cat "P"`,
which calls `CreateFileCycle(..., $global:UseUnicode, ...)`. Federale's setting is `UseUnicode=True`, so the program
writes into an existing UTF-16 file (T3-039). AFPH12 creates its output in the program (`Asg "P,U"`), so it is ASCII.
Every script run again left the BatchController queue blocked until a restart (T3-038).

**One program, built once, handled two record formats with no rebuild, driven by the cards at run time.**

Later on 2026-10-20 both were fixed and the runs repeated with no restart: AFPH12 (job 591) and VIRM01 (job 593) were
Done, and both outputs byte-identical (VIRM01 3,425 B ASCII).
- T3-038 was ours: `Remove-OrphanProcessJobs.sql` left a transaction open in SSMS, which locked `AMTSYSPROCESSJOB`.
- T3-039: `UseUnicode=False` in the SSG4 settings copy. The application does not define Unicode extract files.

Open before scaling:
- ~~`-GF` has a closed list of file names, so a new name needs a rebuild.~~ **Done 2026-10-20, `-GN`:** the program opens
  only `CFHIN`/`CFHOUT`. The hand-off (`-FixedNames`) adds two use-name entries that follow the call's real names, so
  R&D's own `End-Xqt` gives them the same physical files (no library change). Jobs 595 AFPH12, 597 VIRM01 and
  599 NEWNAME (names `ZZNEWIN`/`ZZNEWOUT`, never seen by any program) were all Done and **byte-identical**, from one DLL.
- ~~The 5 UL calls (T3-028).~~ **Done 2026-10-20:** AMT's `AddTo-SgsList` splits `FIXE 71,8,'        '` at the spaces, and
  the skeleton body then crashed before the hand-off. The hand-off now reads `FIXE` from the raw card file (via
  `Invoke-Ssg`'s `$SgsFilePath`) and runs at the top of the skeleton, then returns: the generic program does not need
  the expansion. The cross-check runs under StrictMode 2 like the job session: 41 MATCH, and the 5 UL calls get
  correct parameters. CC: VIRM01_UL job 608 (R&D's LAB110 statements; cards name assigned files, not use names)
  byte-identical; AFPH12/VIRM01/NEWNAME re-run (610/612/614) byte-identical. All 47 CFH-COPY calls are now covered by
  one DLL.
- Applying the same approach to the other 19 skeletons.
