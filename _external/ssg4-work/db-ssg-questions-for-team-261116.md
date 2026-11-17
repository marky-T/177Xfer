# DB SSG utilities RECAP, TABAN, EXTEUR: what we found and what we need from the team (2026-11-16)

For Allard, Eddy and Hagop. Owner review first. Our work item: MT-069 (plan `.github/Copilot_Plans/261116-db-ssg-programs-plan.md`,
spec `Conversion/Pipeline/Generic/RECAP/spec.md`, commit `a100b4a`). Three SSG utilities touch the database: **RECAP**
(28 real calls), **TABAN** (27) and **EXTEUR** (1). We converted every real call to find the problems, fixed what is ours,
and built RECAP as a generic program to prove the conversion end to end **without waiting for answers**: where we needed
one, we took a working assumption (listed below) and wrote down how a wrong one would show. Our issue ids are in brackets,
for reference only.

## Where we are

| Utility | Real calls | Conversion of every call (R&D CobolConverterConsole) | Database use | Generic program |
|---|---:|---|---|---|
| RECAP | 28 | 24 clean; 4 fail on `PIC X(0)` (a 1-byte output field) | none of its own: opens a read session (`UDSSRC`, qualifier `AFLINC`) only for `EUU003` | **built (RECAP_GN) and proven in Control Center** on every case that does not call `EUU003` (6/6 outputs byte-identical, 6/6 reports identical, run 1894) |
| TABAN (ASCII) | 27 | 27 clean (numeric-vs-SPACE warnings only) | same as RECAP | next program to convert |
| EXTEUR | 1 | 10 errors, all from `INVOKE TABLE EU001 OF AFLINC FROM REPOSITORY` (was 99: the other 89 were ours, now explained and fixed or proven) | one query: `SELECT C_PHA_EUR FROM EU001` | after Q3/Q4 |

**The key finding:** `EUU003` is not just formatting. AMT's `Euu003` (in **BSP_AMT** and FEDERALE_APP) calls `INFRUN` for the run
name, reads table **`EU002`** for that run, falls back to **`EU001`** (`K_CLE_TAB = '1'`), calls `ABRDMS` on a SQL error, then
converts BEF/EUR and formats the amount. `Euu003`, `Infrun` and `Abrdms` are all in BSP_AMT (FEDERALE_APP has `Euu003` and `Infrun`).
So every RECAP/TABAN grand total depends on `EU001`/`EU002` and on the program finding `EUU003`. Our test application
(`AFBUS_2200COBOL`) has neither; LionDev warns about it, and Control Center showed that the call is only resolved when it runs.

## What we pushed through (working assumptions, RECAP spec A1–A10)

| # | We assumed, and built on | Confirmed so far | Question |
|---|---|---|---|
| A1 | 1-byte output field = no filler (`PIC X(0)` means "no bytes") | runs on AMT as designed | Q7 |
| A2 | the RDMS session (`RSA$INIT`, `ACOB$RDMR`) is dropped; AMT uses its own connection | — | Q5 |
| A3 | `EUU003` is called as on OS 2200; we record what AMT's `Euu003` prints, we do not predict it | — | Q1 |
| A4 | `CALL 'ABORT'` = AMT abort (as BABA, released) | — | Q6 |
| A7 | a sum is stored with the sign overpunched on the last digit (ACOB manual Table 2-1) | **AMT does exactly this** (CC run 1894) | Q9 |
| A9 | a missing card or unsupported option stops before the program runs (our design rule) | — | — |
| A10 | proof only where `EUU003` is not needed | **PASS** for those cases | Q2, Q3 |

## Ours: fixed, or fix proven

- Our SSG converter treated a literal `@` ECL line as plain text, so EXTEUR's compile and link statements ended up inside its COBOL (T3-066): fix proven, landing pending.
- Our SSG converter replaced the label of `[NEURO,1]` with a variable of the same name, so the `NEURO` card was silently ignored in RECAP and TABAN, 8 real calls (T3-070): fix proven, landing pending.
- Our per-call scripts converted EXTEUR, a UCS COBOL-85 (`@UCOB`) program, as COBOL-74 and kept its ECL lines (T3-067): proven with a spike; the script change waits for our own go-ahead.
- On the generic route, the 1-byte output field and the `NEURO` card work whatever the converter does.

## Open, needing someone else

- The ECL converter writes `$` in an `@USE` name without escaping it, so the converted script fails under StrictMode (T3-069): R&D; on the board list, Q10.
- Our two SSG converter fixes above (T3-066, T3-070) go to R&D with the converter merge.
- EXTEUR's `INVOKE TABLE EU001 OF AFLINC FROM REPOSITORY` has no AMT equivalent yet (T3-037): Q4.
- Whether ACOB accepts `PIC X(0)`, and as what (T3-068): Q7.
- The RDMS session statements pass conversion as text and fail at run time on the per-call route (T3-027): Q5.

## Short questions (with the answer we expect)

| # | Question | To | Expected answer |
|---|---|---|---|
| 1 | Does AMT's `Euu003` behave as on OS 2200 (convert/format with `EUW002`, reading `EU002` by run name, else `EU001`)? | R&D | Yes |
| 2 | `EUU003`, `INFRUN` (and `ABRDMS`) exist in BSP_AMT, not in AFBUS_2200COBOL. Should RECAP_GN/TABAN_GN be released into **BSP** (our rc target), or should `EUU003` be added to AFBUS_2200COBOL for testing? | R&D / Migration Lead | Test and release in BSP |
| 3 | Are tables `EU001` and `EU002` (schema AFLINC) in the AMT database with data, under these names? | R&D (data migration) | Yes, migrated with AFLINC |
| 4 | Is BSP's copybook `Copbk_Eu001` the AMT form of `INVOKE TABLE EU001 OF AFLINC FROM REPOSITORY`, so EXTEUR can use it? | R&D | Yes |
| 5 | Is dropping `RSA$INIT` / `ACOB$RDMR` (the RDMS session) right on AMT? | R&D | Yes, AMT uses the application connection |
| 6 | Where are `ABORT`, `EREABT$` (EXTEUR) and `CDTOAF` in the target? (`CDTOAF` only matters with a `Y2K` card: no real call has one; AMT's `Euu003` uses `ABRDMS` instead of `EREABT$`) | R&D | AMT functions / Abort |
| 7 | Does ACOB accept `PIC X(0)` (RECAP with a 1-byte output field, 4 real calls), and as what? | Eddy | Yes, as no field |
| 8 | Is schema `AFLINC` right for every production run (the skeletons pick it from the run's project)? | Eddy | Yes |
| 9 | On OS 2200, does RECAP's output carry the overpunch (`{`, `A`–`I`) in the last byte of each total, what does a zero total look like, and what happened on overflow (the manual says "undefined")? AMT matches the manual. | Eddy | Overpunch as the manual; zero `{`; low-order digits kept |
| 10 | May we put these product problems on the board, as Bugs under User Story 119872? (1) AMT run time: a line-sequential READ can join two short lines into one record, so records are silently lost (T3-059). (2) AMT run time: SSG's built-in `INFO$` values are blanked at run time, so skeletons that choose by project generate nothing (T3-023). (3) ECL converter: inline SGS cards between `@SSG` and `@EOF` are dropped (T3-020). (4) ECL converter: `@HDG,P text` is written as one string, so the heading call aborts (T3-046). (5) ECL converter: `$` in an `@USE` name isn't escaped, so the script fails under StrictMode (T3-069). | Allard | Yes, as one batch (a courtesy, not a gate) |

Status of the five, checked 2026-11-16 on R&D's develop as last fetched (`88dc012f`, 2026-11-09):
(1) still present (Control Center run, rc.03 regression 261112); (2) still present in develop and in the 11 Nov drop
(`Update-InfoSgs`); (3) still present: `VisitSsg` writes `Invoke-Ssg … -SgsFile "P$SGS\<run-id>"` and writes no cards;
(4) still present: `VisitHdg` passes options and text as one string; (5) still present: `VisitUse` does not escape `$`.
(3) and (4) were checked in the source (both files unchanged since 2026-10-09), not by a conversion with a develop build;
we fetch develop again before drafting the Bugs.

## Background

- **Why RECAP opens a database session:** only for `EUU003`. The session statements (`BEGIN THREAD FOR APPLICATION UDSSRC READ`,
  `USE DEFAULT QUALIFIER AFLINC`, `USE DEFAULT VERSION PRODUCTION`) pass the COBOL converter as text and fail at run time
  (`Invalid function call RSA$INIT`) on the per-call route; the generic program leaves them out.
- **`NEURO`** lists the totals printed raw instead of through `EUU003` (likely "non-euro": counts, not money). A call whose
  totals are all on `NEURO` (e.g. RISH02 L284) never needs `EUU003`, which is how we proved RECAP before these answers.
- **What the CC run proves:** the generic RECAP reproduces the skeleton byte for byte on AMT for groups, space-padded amounts,
  1-byte fields, moved and resized fields, whole-record copies and overlapping totals; the remaining risk is `EUU003` and its
  tables (Q1–Q3).
