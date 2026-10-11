# Done / open items extracted from Trial3_SSG_Conversion_Plan.md

Source: `06-plans/AMT175/.github/Copilot_Plans/Trial3_SSG_Conversion_Plan.md` (original: `C:\Amt\Parallel\AMT175\.github\Copilot_Plans\Trial3_SSG_Conversion_Plan.md`)

13 done / 11 open (markdown checkboxes)

## Phase 0 - Prerequisites  [~]

- [x] Confirm SsgConverterConsole.exe + CobolConverterConsole.exe runnable (both print usage; paths above).
- [x] AMT175 Lion AFBUS app running -> CC available (web UI hosting done; OIDC parked, not needed for CC/batch).
- [ ] COBOL DB = AMT175_AFBUS_2200COBOL (mirrors Working WORKING_AFBUS_2200COBOL).
- [ ] Confirm copybooks the 20 programs #INCLUDE (2026-07-07 drop vs Codedrop 2025 CopyPrd).

## Phase 1 - Trial 3 workspace  [x]

- [x] Created C:\Amt\Migration\Trial3 (robocopy from EclCobolPipeline, excl output/.git; Trial 2 intact).
- [x] config\pipeline.config.json: rawSourceDir -> 2026-07-07_SSG\CreatingCobol; converterConsolePath
- [ ] Full 20-program manifest - deferred; using per-program pilot runners first (UNLOADIS done).

## Phase 2 - SSG -> PowerShell (new SsgConverter)  [PARKED - no source in this drop]

- [x] Baseline attempted: `SsgConverterConsole` on `LECTIS_ASCII` -> CRASH (wrong input type; these

## Phase 3 - COBOL -> C#  [~]  (PILOTs = UNLOADIS_ASCII, CHABAN_ASCII)

- [x] **UNLOADIS_ASCII STEP 1+2 DONE** via `Trial3\tools\Run-Pilot-UNLOADIS.ps1` (direct in-repo,
- [x] **CHABAN_ASCII STEP 1+2 DONE** via `Trial3\tools\Run-Pilot-CHABAN.ps1`: `Remove-SsgDirectives.ps1`
- [x] **LionDev import + F7 + Generate C# DONE (2026-08-19):**
- [ ] Clean COBOL candidates for remaining 18 programs (SSG expand w/ manifest paramOverrides/conditionValues).
- [ ] CobolConverterConsole -> .LionSource -> LionDev import (Cobol OS 2200) -> Generate C#.

## Phase 4 - AMT175 COBOL app + DB in CC  [~]

- [x] Created empty `AMT175_AFBUS_2200COBOL` (SQL): ONLINE, SIMPLE recovery, user `amt175_afbus_user`
- [x] Register in CC -> Architecture -> Databases (server localhost, MsSql, amt175_afbus_user). Test connection OK (2026-08-19).
- [x] AmtReorganize `AMT175_AFBUS_2200COBOL` done 2026-08-19 21:19:24 — "Reorganize database AMT175_AFBUS_2200COBOL done."
- [x] CC Architecture -> Applications -> add COBOL app (Cobol OS 2200): AMT175_AFBUS_COBOL registered,

## Phase 5 - Deploy PowerShell scripts  [ ]

- [ ] Place .ps1 + AmtPsEclLib.psm1 + AmtPsSortLib.psm1 + AmtSettings.xml in AMT175 script path.

## Phase 6 - Run in CC against mocked files  [~]

- [x] CHABAN_RUN executed successfully 2026-08-19 04:48 AND 23:03 (log=729B, Script Done in 6s)
- [ ] Re-run CHABAN after reboot. Verify FICHOUT-1 output bytes.
- [ ] Run UNLOAD-ASCII (Run-UnloadAscii.ps1) — needs indexed FICHIN-1 input (flat mock gave 0 records).
- [ ] Stage fixture inputs for remaining programs.

## Phase 7 - Verify parity  [ ]

- [ ] Tier-1: diff actual vs expected.dat / refimpl golden (0 diff = PASS).
- [ ] Tier-2: apply run-date masks (dt-ach, dt-maj, date-fr) before diff. Record pass/fail.
