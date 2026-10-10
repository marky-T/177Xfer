# SSG 2 — Extended Plan: Whole-Source (SSG + COBOL + ECL) Conversion

Companion to `SSG 2 plan a.md` (the Federale OS 2200 Phase 1 forensic prompt). That file defines the evidence rules and guardrails. This file defines the work plan.

Written 2026-10-08. Intended to be exported to the Trial 3 VM, where many utilities will need loading fresh. Section 2 lists what the VM needs. Paths in section 11 are from the original PC and may differ on the VM.

---

## 1. Why this plan exists

| Trial | Scope | Route used |
|---|---|---|
| 1 and 2 | 16 SSG programs | SSG only |
| 3 | 20 SSG programs | SSG only (SsgConverter, SSG to PowerShell) |
| Next | About 50 more programs (not yet received) | Must use all three converters |

The SSG-only route is incomplete. The SsgConverter PS1 output reproduces the SSG template-expansion (code generation) phase. It does not run the program's business logic. The program output needs the COBOL converted to C#, and the job control needs the ECL converted to PowerShell.

Required end state for each program: a PS1 plus C# combination that runs in AMT Control Center (CC).

- ECL converts to a PS1 script using `AmtPsEclLib`. It handles job control: file assignments and `Xqt`.
- COBOL (after SSG expansion) converts to a C# DLL. It runs the business logic.
- The PS1 `Xqt`s the C# job through the BatchController. They are separate artefacts that meet at run time. They are not one file.

COBOL is not converted to PowerShell. The AMT reference states that the PowerShell layer "never performs the program's computation".

---

## 2. What the VM needs (checklist)

Confirm each item on the VM. Mark UNKNOWN if not found.

| # | Item | Why |
|---|---|---|
| 1 | Plan files: `SSG 2 plan a.md` and this file | Evidence rules and plan |
| 2 | Raw mainframe source (SSG-COBOL elements `ASSURFED_UTILIT_*.TXT`, Windows-1252) | Input |
| 3 | ECL runstreams (`RunsPrd`, about 800 files, Windows-1252) | SGS parameter cards and the real invocations |
| 4 | Shared copybooks (`CopyPrd`) | COBOL conversion (`GlobalCopyDir`) |
| 5 | `EclCobolPipeline` (tools, manifest, candidates, fixtures, refimpl) | Stream A pipeline |
| 6 | `CobolConvert` (settings, macros, `Targetcsharp`) | COBOL converter settings and stubs |
| 7 | `CobolConverterConsole.exe` and LionDevGenNet | COBOL to Lion to C# |
| 8 | SsgConverter release (`SsgConverter-Release-20260821`) and `T3ConvertedSSG` | Cross-check stream |
| 9 | `AmtPsEclLib.psm1`, `AmtPsSortLib.psm1`, `AmtPsCustomerLib.psm1`, `EclOptions.psm1`, `AmtSettings.xml` | ECL to PS1 target library. FOUND on the original PC as an isolated copy in `C:\Amt\Migration\Trial3\run\RealRuntime\` (see section 11). The `AmtSettings.xml` there is minimal and not a proven live config. |
| 10 | `ComScript.dll` | Needed by `AmtPsEclLib` (`Connect-Application`) |
| 11 | AMT E2P document ("Overview Batch Jobs in AMT - from ECL to PowerShell") | Script skeleton and Appendix A side-by-side example |
| 12 | Unisys SSG and ECL manuals | Evidence source |
| 13 | CC stack: Keycloak, IIS CC site, FileController, BatchController, ApplicationServer | Tier 2 and Tier 3 runs |
| 14 | `AFBUS_2200COBOL` application and database | Where converted jobs run |
| 15 | `find-ssg-ecl.ps1` | Locates runstream call sites |
| 16 | Reference HTML set: `SSG-COBOL-Reference`, `SSG-ECL-PowerShell-Reference`, `SSG-ECL-Command-Matrix`, `SSG-Trial-Progress` | Prior findings and patterns |
| 17 | AMT ECL converter: `EclConverterConsole.exe` and `EclConverterGui` (built, AMT177 Tools) plus the `EclConverter` source | ECL to PowerShell conversion (section 7). Takes `/INPUT:<folder>` or `/INPUTFILE:<file>` and `/OUTPUT:<folder>`. |
| 18 | CFH-COPY C# export: `C:\Amt\Transfer\CFH-COPY-Trial11\` (`CSharpSource`, `CompiledBinary`, `MockInputFiles`, `AppDependencies`) | Target solution (section 6). Check which build it is (see 6). |
| 19 | Trial 3 folder: `C:\Amt\Migration\Trial3\` (manifest, fixtures, `SSG_All_20_Ranked.md`, `run\RealRuntime\Run-StageA.ps1`) | The 20 programs and the Stage A runner |

Encoding warning: the ECL and SSG source is Windows-1252. VS Code search and grep return nothing on these files. Use PowerShell with `[System.Text.Encoding]::GetEncoding(1252)`.

---

## 3. Decisions to confirm

| # | Decision | Recommendation |
|---|---|---|
| D1 | Unit of work | One ECL invocation of an SSG/COBOL element = one manifest entry. |
| D2 | Pipeline | REVISED 2026-10-08. AMT's own route (see 3.1) is: ECL converter produces the PS1; the PS1 calls `Invoke-Ssg` (converted SSG PS, SsgConverter output) for SGS context; `Xqt` starts the C# report built from the COBOL converter. So SsgConverter output stays in the route and is no longer "cross-check only". The Stream A preprocessor remains the way to get COBOL for the C# build. |
| D3 | Shared contract | Extend `programs.manifest.json` with an `ecl` block: SGS cards, ordered ECL steps, logical-to-designator bindings, `@XQT` target PROGRAM-ID. |
| D4 | Binding rule | Logical names in generated C# `Files.cs`, the PS1 file assignments, and the fixtures must be identical. |
| D5 | Template vs invocation | OPEN, evidence-led (see 3.1). Runstreams call one template many times with different parameters under one `@XQT` name, so either the C# takes its parameters at run time, or each invocation gets its own report name. Decide after the Phase 1 experiments. |

Status: D1 and D3 UNCONFIRMED. D2 and D5 depend on the findings below. The user said these need help to resolve.

### 3.1 Findings bearing on D2 and D5

From the isolated `AmtPsEclLib.psm1` (about 499 KB, copy of the AMT177 library; line numbers refer to that copy):

- `Invoke-Ssg` (line 10786): "Invoke a converted SSG skeleton script ... replaces the original @SSG ECL statement." It calls `StartSSG` (creates the SGS label set, loads global SGS, loads `P$SGS\<JobName>` if present, applies command-line SGS overrides), runs `<Skeleton>.ps1`, then `EndSSG`. OBSERVED.
- `Call-ExternalProgram` (line 13966) is a dummy: it only logs "Ipf call to <file> skipped". So the `ucob`/`ACOB`/`MAP` calls in converted SSG scripts do nothing at run time. OBSERVED.
- `Xqt` (line 6801): "In Amt start of a report is prepared." `End-Xqt` (line 6845) then starts the report. OBSERVED.
- `End-Xqt` passes each USE name and its physical path to the report as task values (`SetTVCustom`), plus the switches (`SW`), `QUAL` and `TPF`. In the sections read, SGS values are not passed. OBSERVED. Whether SGS values reach the C# some other way is UNKNOWN.
- `Check-ReportName` (called by `End-Xqt`) rewrites the XQT target: `\`, `/` and `-` become `_`, a leading path or dot prefix is stripped, names are cut to 40 characters, and a leading digit gets an `ASY_` prefix. So `@XQT .CFH-COPY` would start a report named `CFH_COPY`. OBSERVED. The deployed job is named `ASSURFED_UTILIT_CFH_COPY`, so the XQT-to-report-name match is UNKNOWN.

From the runstreams (`RunsPrd`, 1080 files, counts of `@SSG` lines by target, element name only):

- `*UTILIT.CFH-COPY/ASCII` is called 47 times. Calls to one template carry different parameters (the documented `VIRM01_CO` call uses 500 and 135 byte records, not 80). OBSERVED.
- DERIVED: if all calls of a template reach one report name and the C# cannot read the SGS values, the C# cannot be built once per template. Test this first (Phase 1, experiment E3).

Pending those experiments, treat D2 and D5 as open.

---

## 4. Evidence status (carried forward)

Classification uses the labels from `SSG 2 plan a.md`.

| Claim | Class | Source |
|---|---|---|
| ECL converts line by line to PS1 on `AmtPsEclLib`; mainframe behaviour is hidden in the library | PROVEN (AMT document, not a Unisys manual) | E2P overview, section "ECLs converted to PowerShell scripts" |
| PS script skeleton: `Import-Module`, `Set-Jobname`, `Initialize`, `Trap`, commands, `Fin` | OBSERVED (AMT document) | E2P overview, "Script skeleton" |
| PS layer does not run program logic; `Xqt` inserts a job request and the BatchController runs the C# | OBSERVED (project reference) | `SSG-ECL-PowerShell-Reference.html` section 2 |
| MONTANT C# runs in CC (job 740) and its output is byte-identical to the Tier 1 golden (328 B) | OBSERVED (project reference) | Reference section 6b, 2026-07-18 and 2026-09-17 |
| SsgConverter PS1 reproduces template expansion only | OBSERVED (project reference) | Reference section 6c |
| Stream A and T3 expansions differ by 85 to 141 diff rows on five programs, not reconciled | OBSERVED | Reference section 6c |
| MONTANT golden uses stub parameters (offset 2, width 9, 80-byte records) | OBSERVED | Reference, `programs.manifest.json` notes |
| `#` becomes `@` under the SSG sign-character setting | DERIVED_WORKING_MODEL (per the plan) | `SSG 2 plan a.md` |
| The reference describes `#ACOB` as an assembler-COBOL bridge | ASSUMPTION. Conflicts with the plan (ACOB = COBOL compiler). Needs a manual page. | Reference section 3.1 |
| PS1 can run as a CC TYPE=1 script job | OBSERVED for the T3 wrapper (job 1003) | Reference section 6c |
| A PS1 `Xqt` reaching a C# job from a CC script job | UNKNOWN. Not yet shown. | — |
| `AmtPsEclLib` exists on the original PC as an isolated copy (provenance: AMT177 `Federale_InternalRelease`, never modified) | OBSERVED | `Trial3\run\RealRuntime\README.md` |
| Converted SSG scripts run against the real library up to FIN with no live app (Stage A); only CFH-COPY run this way | OBSERVED | `Trial3\run\RealRuntime\README.md` and `Run-StageA.ps1` |
| `AmtPsEclLib` working under a live app (Stage B: `Initialize`, `Connect-Application`) | UNKNOWN. Blocked per the README (no second `CobolOS2200` application). | `Trial3\run\RealRuntime\README.md` |
| `Invoke-Ssg`, `Xqt`, `End-Xqt`, `Check-ReportName`, `Call-ExternalProgram` behave as in section 3.1 | OBSERVED (library source) | `AmtPsEclLib.psm1` |
| An AMT ECL converter (`EclConverterConsole`, ECL to PowerShell/Python) exists and is built | OBSERVED | `C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\` |
| What `EclConverterConsole` generates for `@SSG,IA`, `@ASG`, `@USE` and `@XQT` | UNKNOWN. Not yet run. | — |
| No runstream in `RunsPrd` calls `MONTANT_SIGNE` (0 hits on the element name; the "MONTANT" hits checked are French text in comments) | OBSERVED, one sample file checked | Search of 1080 files, Windows-1252 |
| `@SSG` call counts: BABA 121, ARCHIFUSION 60, ARCHITAB2 60, CFH-COPY 47, FUSBA 32, CHABAN 30, RECAP 28, TABAN 23, SCAN 19, CONDIS2 18, TAPELD 14, LOADIS 9, UNLOADIS 4; also `SYS$*RUNS.FILE/SSG` 21, `EUDEV*REPSSG.CTLTOT` 10, `DIA*DBASSG.EG*` about 30, `POTIER.RFA/SSG` 3 | OBSERVED (regex on `@SSG` lines; noise such as `SKEL` and `SGS` not filtered) | `RunsPrd` |
| Signed-numeric overpunch codec | UNKNOWN against Unisys. Refimpl codec only cross-checked against earlier C# output. | Manifest notes |
| `@XQT` parameter passing, completion, sync/async, status | UNKNOWN | `SSG 2 plan a.md` open items |
| OS 2200, SSG and COBOL versions | UNKNOWN | `SSG 2 plan a.md` open items |

---

## 5. Phase 0 — Inventory and triage

Build a ledger with one row per program (36 done plus about 50 incoming):

- SSG element name and PROGRAM-ID
- compile path (`#ucob` or `#ACOB`)
- constructs used (`*DEFINE`, `*IF` forms, `*INCREMENT`, `*PROCESS`, `*SET` chains)
- file types (flat, indexed, sort, printer, multi-file)
- real runstreams that call it (via `find-ssg-ecl.ps1`) and their SGS cards
- status per tier: T0 SSG expansion, T1 oracle, T2 C# in CC, T3 PS1 plus C# in CC
- Step 9 classification for each open difference

Group programs into families by construct. Triage the incoming 50 into existing families, or flag a new family.

Known T2 state (reference section 6b, 7): MONTANT and CFH-COPY pass. ARCHITAB1 passes structurally. LOADIS is exec-only. ARCHIFORMAT, COMPARE2, TAPELD_DISTRIB and TRI_ASCII are blocked by designator collisions.

---

## 6. Phase 1 — The target solution (hand-built)

Target A: CFH-COPY (decided 2026-10-08). No runstream in `RunsPrd` calls `MONTANT_SIGNE`, while CFH-COPY has 47 `@SSG` calls and a C# build already exists.

Starting artefacts on the original PC:

- C# source, compiled DLL and mock inputs: `C:\Amt\Transfer\CFH-COPY-Trial11\`.
- Deployed DLLs: `Lion\Apps\AFBUS_2200COBOL\Binaries\Reports\` and `Programs\`.
- Real runstream with real parameters: `ASSURFED_F999RUN_VIRM01_CO(P).TXT` (`INPUT INB,500,10`, `OUTPUT INC,135,10`, `FIELDIN`/`FIELDOUT` cards).
- Stage A seed: `INPUT ECL-TAPEIN,80,1`, `OUTPUT ECL-TAPEOUT,80,1`, `ASCII 1` (`Run-StageA.ps1`).

Check first: the `Transfer` copy is the Trial 11 build. The record-size rework (reference section 6d) changed `Fd_Recin`/`Fd_Recout` in the deployed project. Compare the two before choosing which to export. If they differ, or the C# is only 80-byte, re-convert.

MONTANT remains the proven flat-file oracle (C# job 740, golden `fixtures/montant/expected.dat`) but has no real runstream, so it cannot be the ECL target.

Experiments to run first (each answers part of D2/D5):

- E1: run `EclConverterConsole` on `VIRM01_CO`. Record exactly what it emits for `@SSG,IA`, `@ASG`, `@USE`, `@XQT`.
- E2: run the E1 output against the isolated library (Stage A style). Note where it stops.
- E3: find whether SGS values can reach the C# report (read `End-Xqt` to its end, and the C# runtime that receives the task values). If not, D5 resolves to per-invocation report names or a task-value channel.
- E4: confirm which report name `@XQT .CFH-COPY` resolves to (`CFH_COPY`) and which name the deployed job has.

Target artefact set:

1. The original runstream and SGS block.
2. Its manifest entry, including the `ecl` block.
3. The expanded COBOL candidate.
4. The C# DLL.
5. The hand-written PS1 on the E2P skeleton.
6. `AmtSettings.xml`.
7. Fixture input and expected output.
8. An evidence table per `SSG 2 plan a.md` (claim, class, source, location, confidence).

Acceptance for Target A: T3 passes. The PS1 runs in CC, the C# job runs, and the output matches the golden (date bytes masked where needed).

The `<=>` loop: diff converter output against the target and classify each difference using the Step 9 categories. Fix the converter, or fix the target if it was wrong (`REFERENCE_IMPLEMENTATION_DEFECT`). Never change expected output just to make the converter pass.

Target B: a fresh program from a different family (indexed such as LOADIS/UNLOADIS, or sort such as TRI_ASCII), converted by hand across SSG, COBOL and ECL. This stops the converters being tuned to flat-file programs only.

---

## 7. Phase 2 — ECL converter spike

1. Build an ECL command to `AmtPsEclLib` map: `@ASG`, `@USE`, `@CAT`, `@DELETE`, `@XQT`, `@FREE`, `@ERS`, `@ADD`, `@LAB`, `@EOF`, `@TIME`, `@MSG`, and the embedded `#` forms. Give each row an evidence class from the Unisys ECL manual and E2P Appendix A. Anything unmapped is `UNSUPPORTED_SOURCE_CONSTRUCT`.
2. `AmtPsEclLib` is available as an isolated copy. Stage B (live app) is blocked on the original PC: the README says no second `CobolOS2200` application exists. Check whether the VM has one.
3. Convert the target runstream to PS1 and diff against the hand-written target.
4. An AMT ECL converter already exists (checklist item 17). Run it first (experiment E1) and extend only what it cannot do.

---

## 8. Phase 3 — Align the SSG and COBOL stages

1. SGS-card parser: read parameter cards from the runstream into the manifest, replacing hand-typed `paramOverrides` and `conditionValues`.
2. Loud failure: an unresolved token fails the run and is reported. Today unmatched tokens collapse to `1` (this caused the ARCHIFORMAT designator collisions).
3. Sidecar: `Remove-SsgDirectives` writes the lines it strips (`#ASG`, `#USE`, `#LINK`, `#FREE`, `#DELETE`, `#CAT`, `#XQT`, `#ACOB`, `#ucob`) to a tagged sidecar for the ECL converter.
4. D4 binding check as an automated test.
5. Reconcile Stream A and T3 expansion differences against the manuals, using the oracle as arbiter.
6. Track hand-adjusted candidates (for example ECLAT loop expansion) as converter gaps.

---

## 9. Phase 4 — Integration runner

One command per manifest entry:

1. SSG expansion to clean COBOL.
2. COBOL converter, then LionDevGenNet, then C# build.
3. Deploy the DLL to `Binaries\Reports` and register the job.
4. Generate the PS1.
5. Start the PS1 in CC.
6. Collect outputs from `Files\Extracts\<designator>.DAT`.
7. Diff against the golden, with date masks.

Pre-flight checks to include (from the reference):

- Pin the shared assembly version to match the BatchController (otherwise a silent Running to Queued loop).
- Create the full `Binaries\Common\*` folder set.
- `Restart-Service AmtBatchController` after deploying a new DLL.
- Build with `-p:NuGetAudit=false` if the SSH.NET advisory errors.
- Clear stale output and index sidecars before re-runs.
- Distinct designators per file (D4).
- Converter settings: `Env = 4096` (CobolOS2200), `GlobalCopyDir`, `UseCobolAnalyser = true`, `DontIncludeFolderNames = true`.
- Candidate filename must equal the PROGRAM-ID (Bug 14).
- Parse in LionDev (F7) before Generate (Bug 15).

---

## 10. Phase 5 and 6 — Pilot, retrofit, intake

Phase 5:

1. Run Target B end to end.
2. Re-run the 16 templates and the T3 batch through the full pipeline to replace the SSG-only baseline.

Phase 6, per batch of incoming programs:

1. Triage into families.
2. Add manifest entries.
3. Run the pipeline.
4. Classify the differences.
5. Fix the converters.
6. Regression-run everything already passing.

Definition of done per program: T3 passes, with every remaining difference explained and classified, per `SSG 2 plan a.md`.

Parallel track, evidence closure from the Unisys manuals: `@XQT` semantics, signed-numeric codec, platform versions. Cite the manual, edition, section and page, or leave UNKNOWN. Do not invent page numbers.

Known test limits:

- Indexed-output programs are not byte-comparable to a flat golden (execution pass only).
- Date-sensitive programs need the run-date bytes masked.
- Shared designators (`ECL-TAPEIN`, `ECL-TAPEOUT`) need the input staged fresh before each run.

---

## 11. Reference paths on the original PC

Paths may differ on the VM.

| Item | Path |
|---|---|
| Plan files | `C:\Amt\Working\SSG 2\` |
| Migration folder | `C:\Amt\Migration\` |
| Reference HTML | `C:\Amt\Migration\SSG-COBOL-Reference.html`, `SSG-ECL-PowerShell-Reference.html` |
| Stream A pipeline | `C:\Amt\Migration\EclCobolPipeline\` (tools, manifest, candidates, fixtures, refimpl) |
| Manifest | `C:\Amt\Migration\EclCobolPipeline\manifest\programs.manifest.json` |
| COBOL converter settings | `C:\Amt\Migration\CobolConvert\` |
| SsgConverter release | `C:\Amt\Migration\SsgConverter-Release-20260821\` |
| T3 converted SSG | `C:\Amt\Migration\T3ConvertedSSG\` |
| E2P documents | `C:\Amt\AMT_ReferenceDocuments\AMT_ECLtoPowershell\` |
| Raw mainframe source | `C:\Amt\MainframeSource\Codedrop 2025\SSG Prd\SSG Creating COBOL\` |
| Converted MONTANT C# | `C:\Amt\Working\Apps\AFBUS_COBOL\Source_AMTLion\Development\Programs\Montant\` |
| Deployed CC jobs | `C:\Amt\Working\Lion\Apps\AFBUS_2200COBOL\Binaries\Reports\` |
| CC stage-2 file area | `C:\Amt\Working\Lion\Files\Extracts\` |
| CC start-up script | `C:\Amt\Migration\tools\Federale_CC_Startup.ps1` (run elevated) |
| CC UI | `http://localhost/Working/ControlCenter/` |
| Isolated AMT ECL library | `C:\Amt\Migration\Trial3\run\RealRuntime\` (`AmtPsEclLib.psm1`, `AmtPsSortLib.psm1`, `AmtPsCustomerLib.psm1`, `EclOptions.psm1`, `AmtSettings.xml`, `Run-StageA.ps1`, `README.md`) |
| Library provenance (as stated in the README, not verified) | `E:\Repos\Federale_InternalRelease` on AMT177. T3 converted SSG source: repo `marky-T/177Xfer`, branch `T3ConvertedSSG`. |
| AMT ECL converter | `C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\` (`AMT177 Tools` has the built console and GUI; `EclConverter (1)\EclConverter` has the source) |
| CFH-COPY C# export | `C:\Amt\Transfer\CFH-COPY-Trial11\` |
| Trial 3 working folder | `C:\Amt\Migration\Trial3\` |
| Runstreams | `C:\Amt\MainframeSource\Codedrop 2025\RunsPrd\` (1080 files) |

---

## 12. First action on the VM, and open questions

First action on the VM: ask the user for the location of the Unisys SSG and ECL manuals (the user will set them up there), then record the path here.

Answered 2026-10-08:

1. Manuals: to be set up on the VM. Prompt for the location.
2. No runstream calls `MONTANT_SIGNE`. Target A is CFH-COPY. A C# build exists in `C:\Amt\Transfer\CFH-COPY-Trial11\`. Check it against the deployed build first (section 6).
3. D1 and D2: the user does not know. Section 3.1 gives the evidence and section 6 the experiments that decide them.
4. `AmtPsEclLib.psm1`: found (section 11). Referenced in the E2P document, `Trial3\run\RealRuntime\README.md`, `Run-StageA.ps1` and the reference HTML section 6b.
5. New templates are expected in the 50. Prioritise by `@SSG` call count (section 4).

Still open:

1. Does the VM have a second `ApplicationKind = CobolOS2200` application for Stage B?
2. Is `E:\Repos\Federale_InternalRelease` (or the git repo for the library) available on the VM?
3. Which of the templates in the section 4 call counts are already among the 36 converted programs, and which are new?
4. Confirm D1 (one manifest entry per runstream invocation).
