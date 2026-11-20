# Release notes — rc.04-test

Generic SSG utility programs, application **BSP**. Previous release: `rc.03`.

## Programs

| Program | Utilities | Real calls | Revision |
|---|---|---:|---|
| `CFH_COPY_GN` | CFH-COPY, LOADIS | 57 | *filled in at packaging* |
| `BABA_GN` | BABA | 122 | *filled in at packaging* |
| `FUSBA_GN` | FUSBA | 36 | *filled in at packaging* |
| `CHABAN_GN` | CHABAN | 31 | *filled in at packaging* |
| `CONDIS2_GN` | CONDIS2 | 18 | *filled in at packaging* |
| `SCAN_GN` | SCAN | 19 | *filled in at packaging* |
| `TAPELD_GN` | TAPELD | 14 | *filled in at packaging* |
| `LECTIS_GN` | LECTIS | 1 | *filled in at packaging* |
| `ARCHISEPARE_GN` | ARCHISEPARE | 0 | *filled in at packaging* |
| `ARCHIFORMAT_GN` | ARCHIFORMAT | 0 | *filled in at packaging* |
| `RECAP_GN` | RECAP | 28 | *filled in at packaging* |
| `TABAN_GN` | TABAN | 27 | *filled in at packaging* |
| `EXTEUR_GN` | EXTEUR | 1 | *filled in at packaging* |

Generated from LionSource `GNBSP5` (LionDev 177, application BSP). Revisions and the SHA256 of every file
(`manifest.csv`) are added when the release is packaged after the LionDev generation.

## Changes since rc.03

- **New program** `CFH_COPY_GN` (CFH-COPY).
- **New program** `BABA_GN` (BABA).
- **New program** `FUSBA_GN` (FUSBA).
- **New program** `CHABAN_GN` (CHABAN).
- **New program** `CONDIS2_GN` (CONDIS2).
- **New program** `SCAN_GN` (SCAN).
- **New program** `TAPELD_GN` (TAPELD).
- **New program** `LECTIS_GN` (LECTIS).
- **New program** `ARCHISEPARE_GN` (ARCHISEPARE).
- **New program** `ARCHIFORMAT_GN` (ARCHIFORMAT).
- **New program** `RECAP_GN` (RECAP).
- **New program** `TABAN_GN` (TABAN).
- **New program** `EXTEUR_GN` (EXTEUR).
- **New include** `RecapParm.inc` (RECAP).
- **New include** `TabanParm.inc` (TABAN).
- **New include** `ExteurParm.inc` (EXTEUR).
- **New skeleton** `UTILIT_RECAP.ps1`.
- **New skeleton** `UTILIT_TABAN_ASCII.ps1`.
- **New skeleton** `UTILIT_EXTEUR.ps1`.
- **Program names:** every program is named after its utility, `<U>_GN` (was `ASSURFED_UTILIT_<U>_GN`), so the name says which utility it is; the hand-offs and `CloneReports` entries use the new names.
- **Layout:** the C# projects go to `BSP_AMT\Development\Programs\<Project>` with the application's own programs, in the solution folder `/Programs/` of `_All_.slnx` (rc.02: `BSP_AMT\Development\Utilities` and `_All_.sln`). The release record is the top-level `Utilities\` folder, which replaces `Scripts_SSG\` (the withdrawn rc.01 PowerShell bodies).

## Control Center proof

Regression in the trial application (CC-Trial, AFBUS build of the same COBOL): last result of each job. Outputs are compared
byte for byte with independent reference results; error cases must end in Error before the program starts.

| Job | Utilities | Last run | Result | Detail |
|---|---|---|---|---|
| `SSG4_AFPH12_CFH_COPY` | CFH-COPY | 2026-11-20 00:34:16 | **PASS** | --- 1 of 1 outputs byte-identical; === SSG4_AFPH12_CFH_COPY : all checks passed |
| `SSG4_VIRM01_CFH_COPY` | CFH-COPY | 2026-11-20 00:34:41 | **PASS** | --- 1 of 1 outputs byte-identical; === SSG4_VIRM01_CFH_COPY : all checks passed |
| `SSG4_NEWNAME_CFH_COPY` | CFH-COPY | 2026-11-20 00:35:02 | **PASS** | --- 1 of 1 outputs byte-identical; === SSG4_NEWNAME_CFH_COPY : all checks passed |
| `SSG4_VIRM01UL_CFH_COPY` | CFH-COPY | 2026-11-20 00:35:22 | **PASS** | --- 1 of 1 outputs byte-identical; === SSG4_VIRM01UL_CFH_COPY : all checks passed |
| `SSG4_VIRJ01PP_CFH_COPY` | CFH-COPY | 2026-11-20 00:35:44 | **PASS** | --- 1 of 1 outputs byte-identical; === SSG4_VIRJ01PP_CFH_COPY : all checks passed |
| `SSG4_BABA_CASES` | BABA | 2026-11-20 00:36:20 | **PASS** | --- 11 of 11 outputs byte-identical; === SSG4_BABA_CASES : all checks passed |
| `SSG4_CHABAN_CASES` | CHABAN | 2026-11-20 00:36:57 | **PASS** | --- 8 of 8 outputs byte-identical; === SSG4_CHABAN_CASES : all checks passed |
| `SSG4_FUSBA_CASES` | FUSBA | 2026-11-20 00:37:39 | **PASS** | --- 12 of 12 outputs byte-identical; === SSG4_FUSBA_CASES : all checks passed |
| `SSG4_CONDIS_CASES` | CONDIS2 | 2026-11-20 00:38:13 | **PASS** | --- 6 of 6 outputs byte-identical; === SSG4_CONDIS_CASES : all checks passed |
| `SSG4_SCANGRP_PRINTS` | SCAN, TAPELD | 2026-11-20 00:48:18 | **PASS** | === SSG4_SCANGRP_PRINTS : all checks passed; PRN files since 00:47:45: 12, expected 12; === prints: all checks passed |
| `SSG4_LOADIS_CASES` | LOADIS | 2026-11-20 00:48:48 | **PASS** | === SSG4_LOADIS_CASES : all checks passed; problems: 0 |
| `SSG4_LOADIS_ALL` | LOADIS | 2026-11-20 00:49:32 | **PASS** | === SSG4_LOADIS_ALL : all checks passed; 15/15 pass |
| `SSG4_LOADIS_ABORT [UNSORTED]` | LOADIS | 2026-11-20 00:49:51 | **PASS** | job ended in Error as expected; UNSORTED PASS: IS.ERROR key=True, record number=True, job aborted=True, program not started=True, not past the Xqt=True, no index left=True |
| `SSG4_LOADIS_ABORT [DUPLICATE]` | LOADIS | 2026-11-20 00:50:08 | **PASS** | job ended in Error as expected; DUPLICATE PASS: IS.ERROR key=True, record number=True, job aborted=True, program not started=True, not past the Xqt=True, no index left=True |
| `SSG4_ARCHIVE_CASES` | ARCHISEPARE, ARCHIFORMAT | 2026-11-20 00:50:48 | **PASS** | === SSG4_ARCHIVE_CASES : all checks passed; === SSG4_ARCHIVE_CASES : failures 0 |
| `SSG4_LECTIS_CASES` | LECTIS | 2026-11-20 00:51:52 | **PASS** | === SSG4_LECTIS_CASES : all checks passed; PRN files since 00:50:54: 24, expected 24; === prints: all checks passed; === LECTIS DISPLAY lines: PASS (23 of 24 as modelled, 1 known AMT difference(s): KEYIMAGE) |
| `SSG4_LECTIS_ABORT [NOCOND]` | LECTIS | 2026-11-20 00:52:09 | **PASS** | job ended in Error as expected; NOCOND PASS: abort [E3] from the hand-off=True, program not started=True, not past the Xqt=True |
| `SSG4_LECTIS_ABORT [BADCOND]` | LECTIS | 2026-11-20 00:52:24 | **PASS** | job ended in Error as expected; BADCOND PASS: abort [L3] from the hand-off=True, program not started=True, not past the Xqt=True |
| `SSG4_RECAP_CASES` | RECAP | 2026-11-20 00:52:50 | **PASS** | --- 6 of 6 outputs byte-identical; === SSG4_RECAP_CASES : all checks passed; === RECAP report lines: PASS (6 of 6 identical to the model) |
| `SSG4_TABAN_CASES` | TABAN | 2026-11-20 00:54:54 | **PASS** | === SSG4_TABAN_CASES : all checks passed; PRN files since 00:54:18: 12, expected 12; === prints: all checks passed |
| `SSG4_RECAP_EUU003STUB` | RECAP | 2026-11-20 00:54:12 | **PASS** | --- 33 of 33 outputs byte-identical; === SSG4_RECAP_EUU003STUB : all checks passed; === RECAP report lines: PASS (33 of 33 identical to the model) |
| `SSG4_TABAN_EUU003STUB` | TABAN | 2026-11-20 00:56:16 | **PASS** | === SSG4_TABAN_EUU003STUB : all checks passed; PRN files since 00:55:00: 32, expected 32; === prints: all checks passed |
| `SSG4_EXTEUR_CASES` | EXTEUR | 2026-11-20 00:56:48 | **PASS** | --- 12 of 12 outputs byte-identical; === SSG4_EXTEUR_CASES : all checks passed; === EXTEUR console lines: PASS |
| `SSG4_EXTEUR_ABORT [CURRENCY]` | EXTEUR | 2026-11-20 00:57:06 | **PASS** | job ended in Error as expected; === EXTEUR abort CURRENCY: PASS |
| `SSG4_EXTEUR_ABORT [OVERFLOW]` | EXTEUR | 2026-11-20 00:57:27 | **PASS** | job ended in Error as expected; === EXTEUR abort OVERFLOW: PASS |

## Known issues and open items


### AMT's line-sequential reader can read two or more short lines as one record (silent record loss)

- **Area:** AMT run time · **Utilities:** All
- **Impact:** While every record read so far has had the same length L, a READ takes the next L bytes as one record if they are followed by CR LF, even when they contain CR LF. A file that looks fixed-length loses records when a group of shorter lines totals exactly L bytes. Seen in Control Center with CONDIS2 and LECTIS test data. Affects any converted program reading variable-length text input, not only these.
- **Workaround:** None on our side. Input files whose records all have the same length are not affected.
- **Status:** To be raised on the team board as an AMT run-time bug (neutral reproduction prepared)

### The converted skeleton bodies in this release come from the 2026-10-12 converter build

User story: 120439  

- **Area:** Release content · **Utilities:** All
- **Impact:** None at run time: the hand-off at the top of each skeleton returns before the body. The bodies still contain arithmetic errors fixed since in the converter, so the body must not be used as it is.
- **Workaround:** Not needed for the generic route.
- **Status:** Regenerate after our converter fixes are merged with R&D's current converter

### AddTo-SgsList splits a quoted SGS value that contains spaces

- **Area:** AMT run time (AmtPsEclLib) · **Utilities:** CONDIS2, CFH-COPY
- **Impact:** Cards such as PG CASE 74,2,''  '' are split into several values by AMT's SGS store.
- **Workaround:** The hand-offs read such cards from the raw card file ($SgsFilePath), not from the SGS store.
- **Status:** To be raised on the team board as an AMT run-time bug (neutral reproduction prepared)

### SGS labels were case-sensitive in AMT (they are not in SSG)

- **Area:** AMT run time (AmtPsEclLib) · **Utilities:** All
- **Impact:** A label written in another case on a card was not found.
- **Workaround:** Every hand-off looks labels up in upper case; harmless now that AMT ignores the case.
- **Status:** Fixed in AMT (R&D PR 16391, in the internal release of 11 Nov 2026)

### CONDIS2's converted skeleton body throws under StrictMode for calls with an OTHERWISE card

User story: 120439  

- **Area:** Converted skeleton (per-call route) · **Utilities:** CONDIS2
- **Impact:** Only if the skeleton body runs (per-call route). The generic route is not affected: the hand-off returns before the body.
- **Workaround:** Use the generic program (this release).
- **Status:** Open; the source tests an SGS variable that is never set ([*CASE])

### R&D's converted Hdg lines abort the job

- **Area:** ECL converter (R&D) · **Utilities:** All
- **Impact:** @HDG,P text is converted with options and heading in one string; Hdg aborts with 'Invalid options for HdgOptions'.
- **Workaround:** In place in our test jobs.
- **Status:** To be raised on the team board as an ECL converter bug (neutral reproduction prepared)

### Xqt name to program mapping is set by the hand-offs and CloneReports

Task: 119872/120437  

- **Area:** Run-time settings · **Utilities:** All
- **Impact:** Each include names the program its Xqt starts; CloneReports in AmtSettings.xml must hold the same entries (Settings section of INSTALL).
- **Workaround:** Install the CloneReports entries with the release.
- **Status:** CONFIRM with R&D

### R&D's skeleton folder has no UTILIT_CHAB100_ASCII.ps1

- **Area:** Release content · **Utilities:** CHABAN
- **Impact:** This release adds it.
- **Status:** To clear with R&D

### This release replaces R&D's converted skeleton files in Scripts\ASSURFED_UTILIT

Task: 119872/120437  

- **Area:** Release content · **Utilities:** All
- **Impact:** The runstreams call the skeletons by fixed relative path, so the hand-off skeletons take effect only by replacing R&D's files.
- **Status:** CONFIRM with R&D before install

### ARCHISEPARE and ARCHIFORMAT have no identified caller (Oct-2026)

User story: 120446  

- **Area:** Coverage · **Utilities:** ARCHISEPARE, ARCHIFORMAT
- **Impact:** Proven in Control Center on test cases only (no real runstream call found).
- **Status:** Where are the archive runstreams? Question for R&D / Federale

### ARCHIFORMAT is not production-ready: real table and column mapping open

User story: 120443  

- **Area:** Release content · **Utilities:** ARCHIFORMAT
- **Impact:** Proven against test tables (SCHEMA1.TABLE-ARCH) in the trial database. The real AMT tables are named without a schema, use '_' in column names and carry a LIONRECNO identity column; numeric / nvarchar lengths are not yet mapped. The include still carries test helpers.
- **Workaround:** Do not run ARCHIFORMAT against production tables until the table mapping is done.
- **Status:** Open (target: AMT's UnloadSql -WithDescription)

### The ECL converter mangles SGS references inside a skeleton's ECL lines

Bug: 118384 (R&D)  

- **Area:** ECL converter (R&D) · **Utilities:** ARCHIFORMAT
- **Impact:** ARCHIFORMAT's ECL steps (DD report, description) are therefore written by hand in its hand-off.
- **Workaround:** In place (ECL steps in the hand-off).
- **Status:** R&D's fix (PR 16108) may cover it; to be checked after the converter merge

### LECTIS: KEYS, Y2K and NOLIST are not used by any known caller

- **Area:** Coverage · **Utilities:** LECTIS
- **Impact:** The one real call is sequential (COND CTR > 0). Key mode, Y2K and NOLIST are kept in the program and proven with labelled test data only.
- **Status:** Information

### RECAP, TABAN and EXTEUR are proven without the real EUU003 routine and without the real EU001/EU002 tables

- **Area:** Coverage · **Utilities:** RECAP, TABAN, EXTEUR
- **Impact:** RECAP and TABAN: the totals that go through EUU003 were run in Control Center only against a test double (not part of this release), so the flow and the call are proven but not the text the real Euu003 writes on those lines. The cases without EUU003 are proven byte for byte. EXTEUR (no EUU003 call) reads the euro phase from EU001.C_PHA_EUR and was proven only against a trial EU001 table (one row, phase 400).
- **Workaround:** Euu003 and the tables EU001 (and EU002) must exist in the target application; Euu003 reads EU002 by run name, else EU001 key '1'.
- **Status:** To prove in BSP with the real Euu003, EU001/EU002 and real data, compared with an OS 2200 run (team-board User Story to be raised)

## Not included

- The test jobs (`ASSURFED_F999\RUN\SSG4_*`), their data, and the test-only reference programs (`*_RA`, `*_RB`, `*_RD`, `*_RV`, `*_GS`).
- Utilities not converted yet: ARCHIFUSION (a plain ECL sort, converts without a generic program); see PROGRAM-SUMMARY section 8.
