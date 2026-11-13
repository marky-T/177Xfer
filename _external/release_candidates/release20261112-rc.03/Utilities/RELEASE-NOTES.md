# Release notes — release20261112-rc.03

Generic SSG utility programs, application **BSP**. Previous release: `release20261022-rc.02`.

## Programs

| Program | Utilities | Real calls | Revision |
|---|---|---:|---|
| `CFH_COPY_GN` | CFH-COPY, LOADIS | 57 | 1.0.0.0 |
| `BABA_GN` | BABA | 122 | 1.0.0.0 |
| `FUSBA_GN` | FUSBA | 36 | 1.0.0.0 |
| `CHABAN_GN` | CHABAN | 31 | 1.0.0.0 |
| `CONDIS2_GN` | CONDIS2 | 18 | 1.0.0.0 |
| `SCAN_GN` | SCAN | 19 | 1.0.0.0 |
| `TAPELD_GN` | TAPELD | 14 | 1.0.0.0 |
| `LECTIS_GN` | LECTIS | 1 | 1.0.0.0 |
| `ARCHISEPARE_GN` | ARCHISEPARE | 0 | 1.0.0.0 |
| `ARCHIFORMAT_GN` | ARCHIFORMAT | 0 | 1.0.0.0 |

Generated from LionSource `GNBSP4` (LionDev 177, application BSP). Placed against Federale_InternalRelease origin/main (d4da9d0d80); every file of this release with its SHA256 in `Utilities\manifest.csv`.

## Changes since release20261022-rc.02

- **Renamed** `ASSURFED_UTILIT_CFH_COPY_GN` → `CFH_COPY_GN` (PROGRAM-ID `CFH-COPY-GN`; MT-063).
- **Renamed** `ASSURFED_UTILIT_BABA_GN` → `BABA_GN` (PROGRAM-ID `BABA-GN`; MT-063).
- **Renamed** `ASSURFED_UTILIT_FUSBA_GN` → `FUSBA_GN` (PROGRAM-ID `FUSBA-GN`; MT-063).
- **Renamed** `ASSURFED_UTILIT_CHABAN_GN` → `CHABAN_GN` (PROGRAM-ID `CHABAN-GN`; MT-063).
- **Renamed** `ASSURFED_UTILIT_CONDIS2_GN` → `CONDIS2_GN` (PROGRAM-ID `CONDIS2-GN`; MT-063).
- **Renamed** `ASSURFED_UTILIT_SCAN_GN` → `SCAN_GN` (PROGRAM-ID `SCAN-GN`; MT-063).
- **Renamed** `ASSURFED_UTILIT_TAPELD_GN` → `TAPELD_GN` (PROGRAM-ID `TAPELD-GN`; MT-063).
- **New program** `LECTIS_GN` (LECTIS).
- **New program** `ARCHISEPARE_GN` (ARCHISEPARE).
- **New program** `ARCHIFORMAT_GN` (ARCHIFORMAT).
- **Include changed** `LoadisParm.inc` (LOADIS).
- **Include changed** `BabaParm.inc` (BABA).
- **Include changed** `FusbaParm.inc` (FUSBA).
- **Include changed** `ChabanParm.inc` (CHABAN).
- **Include changed** `CondisParm.inc` (CONDIS2): the skeleton's own card checks V1, V3, V4, V5 added (T3-057): invalid PG cards now stop the job before the Xqt, as on OS 2200.
- **Include changed** `ScanParm.inc` (SCAN).
- **Include changed** `TapeldParm.inc` (TAPELD).
- **New include** `LectisParm.inc` (LECTIS).
- **New include** `ArchisepareParm.inc` (ARCHISEPARE).
- **New include** `ArchiformatParm.inc` (ARCHIFORMAT).
- **New skeleton** `UTILIT_LECTIS_ASCII.ps1`.
- **New skeleton** `UTILIT_ARCHISEPARE.ps1`.
- **New skeleton** `UTILIT_ARCHIFORMAT.ps1`.
- **Program names (MT-063):** every program is named after its utility, `<U>_GN` (was `ASSURFED_UTILIT_<U>_GN`), so the name says which utility it is; the hand-offs and `CloneReports` entries use the new names.
- **Layout (MT-064):** the C# projects go to `BSP_AMT\Development\Programs\<Project>` with the application's own programs, in the solution folder `/Programs/` of `_All_.slnx` (rc.02: `BSP_AMT\Development\Utilities` and `_All_.sln`). The release record is the top-level `Utilities\` folder, which replaces `Scripts_SSG\` (the withdrawn rc.01 PowerShell bodies).

## Control Center proof

Regression in the trial application (CC-Trial, AFBUS build of the same COBOL): last result of each job. Outputs are compared
byte for byte with independent reference results; error cases must end in Error before the program starts.

| Job | Utilities | Last run | Result | Detail |
|---|---|---|---|---|
| `SSG4_AFPH12_CFH_COPY` | CFH-COPY | 2026-11-12 19:56:02 | **PASS** | --- 1 of 1 outputs byte-identical; === SSG4_AFPH12_CFH_COPY : all checks passed |
| `SSG4_VIRM01_CFH_COPY` | CFH-COPY | 2026-11-12 19:56:22 | **PASS** | --- 1 of 1 outputs byte-identical; === SSG4_VIRM01_CFH_COPY : all checks passed |
| `SSG4_NEWNAME_CFH_COPY` | CFH-COPY | 2026-11-12 19:56:38 | **PASS** | --- 1 of 1 outputs byte-identical; === SSG4_NEWNAME_CFH_COPY : all checks passed |
| `SSG4_VIRM01UL_CFH_COPY` | CFH-COPY | 2026-11-12 19:56:54 | **PASS** | --- 1 of 1 outputs byte-identical; === SSG4_VIRM01UL_CFH_COPY : all checks passed |
| `SSG4_VIRJ01PP_CFH_COPY` | CFH-COPY | 2026-11-12 19:57:10 | **PASS** | --- 1 of 1 outputs byte-identical; === SSG4_VIRJ01PP_CFH_COPY : all checks passed |
| `SSG4_BABA_CASES` | BABA | 2026-11-12 19:57:41 | **PASS** | --- 11 of 11 outputs byte-identical; === SSG4_BABA_CASES : all checks passed |
| `SSG4_CHABAN_CASES` | CHABAN | 2026-11-12 19:58:14 | **PASS** | --- 8 of 8 outputs byte-identical; === SSG4_CHABAN_CASES : all checks passed |
| `SSG4_FUSBA_CASES` | FUSBA | 2026-11-12 19:58:51 | **PASS** | --- 12 of 12 outputs byte-identical; === SSG4_FUSBA_CASES : all checks passed |
| `SSG4_CONDIS_CASES` | CONDIS2 | 2026-11-12 19:59:19 | **PASS** | --- 6 of 6 outputs byte-identical; === SSG4_CONDIS_CASES : all checks passed |
| `SSG4_SCANGRP_PRINTS` | SCAN, TAPELD | 2026-11-12 20:00:00 | **PASS** | === SSG4_SCANGRP_PRINTS : all checks passed; PRN files since 19:59:26: 12, expected 12; === prints: all checks passed |
| `SSG4_LOADIS_CASES` | LOADIS | 2026-11-12 20:00:29 | **PASS** | === SSG4_LOADIS_CASES : all checks passed; problems: 0 |
| `SSG4_LOADIS_ALL` | LOADIS | 2026-11-12 20:01:16 | **PASS** | === SSG4_LOADIS_ALL : all checks passed; 15/15 pass |
| `SSG4_LOADIS_ABORT [UNSORTED]` | LOADIS | 2026-11-12 20:01:33 | **PASS** | job ended in Error as expected; UNSORTED PASS: IS.ERROR key=True, record number=True, job aborted=True, program not started=True, not past the Xqt=True, no index left=True |
| `SSG4_LOADIS_ABORT [DUPLICATE]` | LOADIS | 2026-11-12 20:01:49 | **PASS** | job ended in Error as expected; DUPLICATE PASS: IS.ERROR key=True, record number=True, job aborted=True, program not started=True, not past the Xqt=True, no index left=True |
| `SSG4_ARCHIVE_CASES` | ARCHISEPARE, ARCHIFORMAT | 2026-11-12 20:03:34 | **PASS** | === SSG4_ARCHIVE_CASES : all checks passed; === SSG4_ARCHIVE_CASES : failures 0 |
| `SSG4_LECTIS_CASES` | LECTIS | 2026-11-12 20:04:42 | **PASS** | === SSG4_LECTIS_CASES : all checks passed; PRN files since 20:03:42: 24, expected 24; === prints: all checks passed; === LECTIS DISPLAY lines: PASS (23 of 24 as modelled, 1 known AMT difference(s): KEYIMAGE (T3-059)) |
| `SSG4_LECTIS_ABORT [NOCOND]` | LECTIS | 2026-11-12 20:04:59 | **PASS** | job ended in Error as expected; NOCOND PASS: abort [E3] from the hand-off=True, program not started=True, not past the Xqt=True |
| `SSG4_LECTIS_ABORT [BADCOND]` | LECTIS | 2026-11-12 20:05:16 | **PASS** | job ended in Error as expected; BADCOND PASS: abort [L3] from the hand-off=True, program not started=True, not past the Xqt=True |

## Known issues and open items

Details and history: the project's issue register (T3-nnn) and work list (MT-nnn).

### T3-059 — AMT's line-sequential reader can read two or more short lines as one record (silent record loss)

- **Area:** AMT run time · **Utilities:** All
- **Impact:** While every record read so far has had the same length L, a READ takes the next L bytes as one record if they are followed by CR LF, even when they contain CR LF. A file that looks fixed-length loses records when a group of shorter lines totals exactly L bytes. Seen in CC (CONDIS2 test data, LECTIS KEYIMAGE). Affects any converted program reading variable-length text input, not only these.
- **Workaround:** None on our side. Input files whose records all have the same length are not affected.
- **Status:** R&D ticket (MT-055); rule and reproduction in docs/RnD-Tickets/T3-059-repro

### T3-062 — The converted skeleton bodies in this release come from the 2026-10-12 converter build

- **Area:** Release content · **Utilities:** All
- **Impact:** None at run time: the hand-off at the top of each skeleton returns before the body. The bodies still contain arithmetic errors fixed since in the converter (T3-043, T3-048, T3-061), so the body must not be used as it is.
- **Workaround:** Not needed for the generic route.
- **Status:** Regenerate after our converter fixes are merged with R&D's current converter (MT-058, MT-057)

### T3-028 — AddTo-SgsList splits a quoted SGS value that contains spaces

- **Area:** AMT run time (AmtPsEclLib) · **Utilities:** CONDIS2, CFH-COPY
- **Impact:** Cards such as PG CASE 74,2,''  '' are split into several values by AMT's SGS store.
- **Workaround:** The hand-offs read such cards from the raw card file ($SgsFilePath), not from the SGS store.
- **Status:** Question for R&D (MT-033)

### T3-054 — SGS labels are case-sensitive in AMT (they are not in SSG)

- **Area:** AMT run time (AmtPsEclLib) · **Utilities:** All
- **Impact:** A label written in another case on a card is not found.
- **Workaround:** Every hand-off looks labels up in upper case.
- **Status:** R&D PR 16391 (2026-11-09, 'SGS labels are now case-insensitive') may fix it; to be checked (MT-058)

### T3-056 — CONDIS2's converted skeleton body throws under StrictMode for calls with an OTHERWISE card

- **Area:** Converted skeleton (per-call route) · **Utilities:** CONDIS2
- **Impact:** Only if the skeleton body runs (per-call route). The generic route is not affected: the hand-off returns before the body.
- **Workaround:** Use the generic program (this release).
- **Status:** Open; the source tests an SGS variable that is never set ([*CASE])

### T3-046 — R&D's converted Hdg lines abort the job

- **Area:** ECL converter (R&D) · **Utilities:** All
- **Impact:** @HDG,P text is converted with options and heading in one string; Hdg aborts with 'Invalid options for HdgOptions'.
- **Workaround:** In place in our test jobs.
- **Status:** Question for R&D

### MT-044 — Xqt name to program mapping is set by the hand-offs and CloneReports

- **Area:** Run-time settings · **Utilities:** All
- **Impact:** Each include names the program its Xqt starts; CloneReports in AmtSettings.xml must hold the same entries (Settings section of INSTALL).
- **Workaround:** Install the CloneReports entries with the release.
- **Status:** To clear with R&D

### MT-045 — R&D's skeleton folder has no UTILIT_CHAB100_ASCII.ps1

- **Area:** Release content · **Utilities:** CHABAN
- **Impact:** This release adds it.
- **Status:** To clear with R&D

### MT-046 — This release replaces R&D's converted skeleton files in Scripts\ASSURFED_UTILIT

- **Area:** Release content · **Utilities:** All
- **Impact:** The runstreams call the skeletons by fixed relative path, so the hand-off skeletons take effect only by replacing R&D's files.
- **Status:** CONFIRM with R&D before install

### MT-047 — ARCHISEPARE and ARCHIFORMAT have no identified caller (Oct-2026)

- **Area:** Coverage · **Utilities:** ARCHISEPARE, ARCHIFORMAT
- **Impact:** Proven in Control Center on test cases only (no real runstream call found).
- **Status:** Where are the archive runstreams? Question for R&D / Federale

### MT-052 — ARCHIFORMAT is not production-ready: real table and column mapping open

- **Area:** Release content · **Utilities:** ARCHIFORMAT
- **Impact:** Proven against test tables (SCHEMA1.TABLE-ARCH) in the trial database. The real AMT tables are named without a schema, use '_' in column names and carry a LIONRECNO identity column; numeric / nvarchar lengths are not yet mapped. The include still carries test helpers.
- **Workaround:** Do not run ARCHIFORMAT against production tables until MT-052 is done.
- **Status:** Open (target: AMT's UnloadSql -WithDescription, T3-053)

### T3-052 — The ECL converter mangles SGS references inside a skeleton's ECL lines

- **Area:** ECL converter (R&D) · **Utilities:** ARCHIFORMAT
- **Impact:** ARCHIFORMAT's ECL steps (DD report, description) are therefore written by hand in its hand-off (route B).
- **Workaround:** In place (route B).
- **Status:** R&D request MT-051; R&D PR 16108 (bug 118384) may fix it; to be checked (MT-058)

### LECTIS-cov — LECTIS: KEYS, Y2K and NOLIST are not used by any known caller

- **Area:** Coverage · **Utilities:** LECTIS
- **Impact:** The one real call is sequential (COND CTR > 0). Key mode, Y2K and NOLIST are kept in the program and proven with labelled test data only.
- **Status:** Information

## Not included

- The test jobs (`ASSURFED_F999\RUN\SSG4_*`), their data, and the test-only reference programs (`*_RA`, `*_RB`, `*_RD`, `*_RV`, `*_GS`).
- Utilities not converted yet: RECAP and TABAN (database statements), EXTEUR (LINC repository table), ARCHIFUSION; see PROGRAM-SUMMARY section 8.
