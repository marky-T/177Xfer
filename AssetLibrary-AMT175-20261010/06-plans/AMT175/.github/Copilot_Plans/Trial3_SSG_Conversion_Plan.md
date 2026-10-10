# Trial 3 - SSG / ECL-COBOL to C# + PowerShell Conversion Plan (AMT175)

**Goal:** Convert the **20** OS2200 SSG/ECL-COBOL utility programs from the **2026-07-07 SSG drop**
for the **AMT175** lane -> **C#** (business logic, Lion Cobol OS 2200 app in CC) and **PowerShell**
(batch orchestration), run in CC against **mocked files**, verify parity. Uses the **new dedicated
SsgConverter** for the SSG->PowerShell stream (replacing Trial 2 hand-rolled scripts).

Started: 2026-08-18. Basis: Trial 2 (EclCobolPipeline), Trial 1 (CobolConvert), AMT_ECLtoPowershell.

Legend: [x] done  [~] in progress  [ ] todo

---

## CAVEAT (user, 2026-08-18)
The ~12 overlapping programs in the 2026-07-07 drop may be **slightly different source** vs the
Trial 2 (Codedrop 2025) copy. Do NOT blindly reuse Trial 2 candidates/goldens. Per overlap program:
diff new source vs Trial 2 source first; re-convert from the new source; refresh fixtures/expected
where the source changed.

## The 20 programs (source: C:\Amt\MainframeSource\2026-07-07_SSG\CreatingCobol\)
ARCHIFORMAT, ARCHISEPARE, BABA_ASCII, CFH-COPY, CFH-COPY_ASCII, CHAB100_ASCII, CHABAN_ASCII,
CONDIS2_ASCII, EXTEUR, FUSBA2_ASCII, FUSBA_ASCII, LECTIS_ASCII, LOADIS_ASCII, LOADIS_MULTI, RECAP,
SCAN_ASCII, TABAN_ASCII, TAPELD_ASCII, UNLOADIS_ASCII, UNLOADIS_MULTI.
Overlap w/ Trial 2 (~12): ARCHIFORMAT, ARCHISEPARE, CFH-COPY(+_ASCII), LECTIS, LOADIS(+MULTI),
SCAN, TAPELD, UNLOADIS(+MULTI). NEW (~8, need fresh fixtures/goldens): BABA, CHAB100, CHABAN,
CONDIS2, EXTEUR, FUSBA/FUSBA2, RECAP, TABAN.

## FINDINGS (2026-08-18, Phase 0 discovery) — READ FIRST
1. The 2026-07-07_SSG drop has ONLY `CreatingCobol\` (20 .TXT). These are **SSG-parameterized
   COBOL** (stream 1): `*IF [ASCII]/*ELSE/*END`, `#ACOB,I .LECTIS`, substitution vars
   `[INPUT,1,1,1]`,`[LKEY,1,1,2]`,`[KEYS]`. i.e. the **COBOL->C# stream (Phase 3)**.
2. The **new SsgConverter converts SSG symstream -> PowerShell ONLY** (confirmed by its `/?`).
   Run against a `CreatingCobol` file it CRASHES: `Index was outside the bounds of the array`.
   => It is **NOT** the tool for these files. **Phase 2 (SSG->PowerShell) has no source in this
   drop** — parked unless a batch-symstream/runstream folder turns up.
3. "Get the SSG-COBOL conversion going" = **Phase 3 = the Trial 2 pipeline** exactly:
   SSG-expand (`Remove-SsgDirectives.ps1` w/ manifest paramOverrides+conditionValues) -> clean
   COBOL candidate -> `CobolConverterConsole <.settings>` -> `.LionSource` -> LionDev import
   (Cobol OS 2200) -> F7 Logic Status -> Generate C#. Driver: `EclCobolPipeline\tools\Run-EclPipeline.ps1`.
4. **Variant mismatch (caveat is REAL):** Trial 2 LECTIS = `_MULT` variant; new drop = `LECTIS_ASCII`
   (356-line raw SSG) — different program variant, not just drift. Per-program param reconciliation
   + fresh fixtures/goldens required; do NOT blind-reuse Trial 2 overrides/goldens.

## Pilot approach (agreed 2026-08-18) — vertical slice, then document
- **Pilot program = `LECTIS_ASCII`** (larger than ideal but accepted as the first end-to-end).
- **Pass 1 (walking skeleton):** drive LECTIS_ASCII through Phases 1->7 to *running in CC*, capturing
  rough steps as we go (what worked, exact commands, gotchas). Goal = one report converted + running.
- **Pass 2 (document):** repeat the SAME program cleanly, flesh out each step, and author the Trial-3
  reference into `C:\Amt\Migration\SSG-ECL-PowerShell-Reference.html` (Trial-3 section; the existing
  100KB file is the Trial-2 companion — extend/mirror it for Trial 3, do not overwrite Trial-2 content).
- LECTIS_ASCII then becomes the **template** the other 19 programs follow.

## Two output streams
1. C# (business logic): SSG macro-COBOL -> expand/strip SSG -> clean COBOL -> CobolConverterConsole
   -> .LionSource -> LionDev import (Cobol OS 2200) -> Generate C# -> run in CC.
2. PowerShell (batch/job): SSG symstream -> new SsgConverter -> .ps1 using AmtPsEclLib.psm1
   (+ AmtPsSortLib.psm1), AmtSettings.xml, ComScript -> run in CC via BatchController.

## Tools & locations  (VERIFIED runnable 2026-08-18)
- New SsgConverter (SSG->PowerShell): `C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\SsgConverter\
  SsgConverter\SsgConverterConsole\bin\Debug\net10.0\SsgConverterConsole.exe` (built; smoke-tested OK).
  NOTE: the `C:\Dev\amt-go-net-net8\Migration Tools\SsgConverter` tree is SOURCE only (no build output).
  CLI: /INPUT:<folder> /OUTPUT:<folder> [/SETTINGSFILE /CLEAROUTPUT:TRUE /CONTINUEONERROR:TRUE
  /VERBOSE:0-3 /LOGFILE /ENABLELOGFILE:TRUE]. SSG detected = first non-empty line starts # or *.
- CobolConverterConsole (COBOL->C#, v8.0.26125.50): `C:\Dev\amt-go-net-net8\Migration Tools\CobolToAmt\
  CobolConverterConsole\bin\Debug\net8.0\CobolConverterConsole.exe` (smoke-tested OK).
  USAGE: `CobolConverterConsole <settings-file.settings>` (NOT /INPUT /OUTPUT — takes a .settings file,
  as in Trial 2).
- Trial 2 template: C:\Amt\Migration\EclCobolPipeline\ (driver, manifest, settings, macros,
  candidates, fixtures, tools\refimpl).
- Trial 3 source: C:\Amt\MainframeSource\2026-07-07_SSG\CreatingCobol\ (20 files).
- Reference: AMT_ECLtoPowershell\Overview Batch Jobs in AMT - from ECL to PowerShell.md;
  AMT_LionReferenceDocs\OS2200 COBOL to AMT LION Tech Specs; SSG-ECL-PowerShell-Reference.html;
  Avanade_AMT_COBOL_FileConverter_.pdf; .github\copilot-instructions.md.

---

## Phase 0 - Prerequisites  [~]
- [x] Confirm SsgConverterConsole.exe + CobolConverterConsole.exe runnable (both print usage; paths above).
- [x] AMT175 Lion AFBUS app running -> CC available (web UI hosting done; OIDC parked, not needed for CC/batch).
- [ ] COBOL DB = AMT175_AFBUS_2200COBOL (mirrors Working WORKING_AFBUS_2200COBOL).
- [ ] Confirm copybooks the 20 programs #INCLUDE (2026-07-07 drop vs Codedrop 2025 CopyPrd).

## Phase 1 - Trial 3 workspace  [x]
- [x] Created C:\Amt\Migration\Trial3 (robocopy from EclCobolPipeline, excl output/.git; Trial 2 intact).
- [x] config\pipeline.config.json: rawSourceDir -> 2026-07-07_SSG\CreatingCobol; converterConsolePath
      + globalCopyDir (Codedrop2025\CopyPrd) unchanged. (No ssgConverterPath - Phase 2 parked.)
- [ ] Full 20-program manifest - deferred; using per-program pilot runners first (UNLOADIS done).

## Phase 2 - SSG -> PowerShell (new SsgConverter)  [PARKED - no source in this drop]
- [x] Baseline attempted: `SsgConverterConsole` on `LECTIS_ASCII` -> CRASH (wrong input type; these
      are COBOL-gen SSG, not batch symstreams). New SsgConverter = SSG->PowerShell only.
- PARKED: revisit only if a batch runstream/symstream SSG folder is supplied for the 2026-07-07 set.

## Phase 3 - COBOL -> C#  [~]  (PILOTs = UNLOADIS_ASCII, CHABAN_ASCII)
- [x] **UNLOADIS_ASCII STEP 1+2 DONE** via `Trial3\tools\Run-Pilot-UNLOADIS.ps1` (direct in-repo,
      bypasses the 2 Convert-SsgToLion gotchas): `Remove-SsgDirectives.ps1` -> clean COBOL
      `candidates\trial3-unloadis\UNLOAD-ASCII.TXT` (PROGRAM-ID UNLOAD-ASCII, DISC branch) ->
      `CobolConverterConsole` -> `output\trial3-unloadis.LionSource` (7330 B) with
      `<OBJECT=UNLOAD-ASCII,COBOL PROGRAM>`. Params: ConditionValues ASCII=1, OUTPUT,1,1=0, OMITTED=0,
      KEYIS,1,1,1=0, MAXREC=0; ParamOverrides FICHIN-1/FICHOUT-1 (+80/1) for INPUT/OUTPUT, KEYIS/MAXREC.
- [x] **CHABAN_ASCII STEP 1+2 DONE** via `Trial3\tools\Run-Pilot-CHABAN.ps1`: `Remove-SsgDirectives.ps1`
      -> clean COBOL `candidates\trial3-chaban\CHABAN.TXT` (PROGRAM-ID CHABAN) ->
      `CobolConverterConsole` -> `output\trial3-chaban.LionSource` (11481 B) with CHABAN object present.
      Params: ConditionValues ASCII=1, LIST=0, NUMB=1; ParamOverrides OUTPUT/NUMB/MOD/FLDSEL.
- NOTE: converter summary "Objects processed: 0" is MISLEADING (Trial 2 known-good also shows 0 but
      writes 187KB). Success = `<OBJECT=...>` in the .LionSource. .LionSource is `<EXPORT FILE VERSION=6>`
      -> AMT172 bug#13 (BaseYear=0) may bite at import.
- [x] **LionDev import + F7 + Generate C# DONE (2026-08-19):**
      UNLOAD-ASCII imported 00:32 (v1.1), CHABAN imported 04:41 (v1.2), both into AFBUS_COBOL.
      F7 Logic Status run on both. Generate C# completed 19:08 — CHABAN Rev 1.2, UNLOAD-ASCII Rev 1.1.
      App: AFBUS_COBOL NEW APPLICATION, build 8.0.26188.0. HTML report updated.
- [ ] Clean COBOL candidates for remaining 18 programs (SSG expand w/ manifest paramOverrides/conditionValues).
- [ ] CobolConverterConsole -> .LionSource -> LionDev import (Cobol OS 2200) -> Generate C#.

## Phase 4 - AMT175 COBOL app + DB in CC  [~]
- [x] Created empty `AMT175_AFBUS_2200COBOL` (SQL): ONLINE, SIMPLE recovery, user `amt175_afbus_user`
      = db_owner (mirrors Working WORKING_AFBUS_2200COBOL single-user pattern).
- [x] Register in CC -> Architecture -> Databases (server localhost, MsSql, amt175_afbus_user). Test connection OK (2026-08-19).
- [x] AmtReorganize `AMT175_AFBUS_2200COBOL` done 2026-08-19 21:19:24 — "Reorganize database AMT175_AFBUS_2200COBOL done."
- [x] CC Architecture -> Applications -> add COBOL app (Cobol OS 2200): AMT175_AFBUS_COBOL registered,
      base path %SYSROOT%\Apps\AFBUS_COBOL\Source_AMTLion\Binaries, DB=AMT175_AFBUS_2200COBOL,
      Config=AMT175 Config, Admin=AMT175_ServiceAccount. (2026-08-19)
- [BLOCKED] Start application: CC Server Control shows all entries yellow/Invalid (Server port=0).
      AMT Windows services ARE running (ApplicationManager, ApplicationServer, FileController,
      BatchController all Running). Root cause: CC Server Control broken on this build (8.0.26188.0) —
      yellow for ALL services incl. BatchController/FileController with correct ports; "Startup server"
      does not respond; (De)Install crashes with null reference (Critical: Object reference not set to
      an instance of an object in ApplicationCenter_BL.Log 21:38:48). Lion service added for
      AMT175_AFBUS_COBOL on port 4445 — did not help. Phase 6 blocked pending CC Server Control fix
      or AMT support guidance. Do not retry (De)Install.

## Phase 5 - Deploy PowerShell scripts  [ ]
- [ ] Place .ps1 + AmtPsEclLib.psm1 + AmtPsSortLib.psm1 + AmtSettings.xml in AMT175 script path.
      AmtSettings.xml: AppName=AMT175 COBOL app, IniFile=lane sys.ini, ComScript. Register in CC.

## Phase 6 - Run in CC against mocked files  [~]
- [x] CHABAN_RUN executed successfully 2026-08-19 04:48 AND 23:03 (log=729B, Script Done in 6s)
      via `Trial3\run\Run-Chaban.ps1` under pwsh 7.6.3 (.NET 10). Connected to AMT175_AFBUS_COBOL.
      Harness: Set-ExecutionPolicy Bypass -> Initialize AmtSettings.xml -> Qual AFBUS ->
      Asg FICHOUT-1 -> Xqt CHABAN. Job logged in CC Jobs -> Batch Control.
      NOTE: must use `pwsh.exe` (7.6.3) not `powershell.exe` (5.1) — .NET 10 assemblies required.
      NOTE: Lion services entry for AmtApplicationServer must exist in AMT175_SYSTEM DB (restored
      2026-08-19 after CC (De)Install bug deleted it; re-added via CC Services -> Lion services Add).
- [BLOCKED] Evening 2026-08-19: forced Stop-Process on ApplicationServerAgent (PID 28840)
      to clear a hung run caused AMT175_ApplicationServer service crash loop (agents 2-8
      died before writing logs). Service now in failed state; won't restart until machine reboot.
      **Resolution: reboot machine to restore AMT services to clean state.**
- [ ] Re-run CHABAN after reboot. Verify FICHOUT-1 output bytes.
- [ ] Run UNLOAD-ASCII (Run-UnloadAscii.ps1) — needs indexed FICHIN-1 input (flat mock gave 0 records).
- [ ] Stage fixture inputs for remaining programs.

## Phase 7 - Verify parity  [ ]
- [ ] Tier-1: diff actual vs expected.dat / refimpl golden (0 diff = PASS).
- [ ] Tier-2: apply run-date masks (dt-ach, dt-maj, date-fr) before diff. Record pass/fail.

---

## Open questions / decisions
0. CAVEAT above: overlap programs may differ from Trial 2 source -> re-validate, do not blind-reuse.
1. Scope of new SsgConverter: only SSG->PowerShell [assumed] vs also SSG->COBOL expansion.
2. Run surface (Trial 2 "ran in CC vs mocked files"): C# programs, PowerShell scripts, or both?
3. Workspace: new Trial3 copy (recommended) vs reuse EclCobolPipeline.
4. COBOL app/DB name: AMT175_AFBUS_2200COBOL (recommended).
5. New programs goldens: who authors fixtures/expected for the 8 new (BABA, CHAB100, CHABAN,
   CONDIS2, EXTEUR, FUSBA/FUSBA2, RECAP, TABAN)?
6. Copybooks: 2026-07-07 own copybooks vs reuse Codedrop 2025 CopyPrd.

## HTML trial report (live — update after every program milestone)
Active JSON: `C:\Amt\Parallel\templates\examples\trial-03-amt175-ssg_v1.json`
After each program completes a phase step, Copilot must:
1. Update `status` / `candidateBytes` / `notes` for that program in the JSON.
2. Run from `C:\Amt\Parallel\templates\tools\`:
   ```
   .\Update-TrialProgress.ps1 -ContentFile ../examples/trial-03-amt175-ssg_v1.json -OutputDir ../output
   ```
3. Verify the script exits 0 (PASS). Output lands in `templates\output\SSG-Trial-Progress_<ts>.html`.

## Change log
- 2026-08-19 - CHABAN_ASCII Steps 1+2 confirmed done; HTML report obligation added.
- 2026-08-18 - Plan created from Trial 2 + new SsgConverter research; 20-program set confirmed from
  2026-07-07_SSG\CreatingCobol; caveat that overlap programs may differ from Trial 2 source.
