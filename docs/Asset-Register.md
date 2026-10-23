# SsgTrial Asset Register

**Generated:** 2026-09-08 &nbsp;|&nbsp; **Last reviewed:** 2026-10-07
**Scope:** Inventory of Copilot instructions/prompts and source/tooling objects across the `SsgTrial` repo, taken before (1) running a subset of the SsgConverter set and reviewing warnings, and (2) investigating how to get `CobolConverterConsole.exe` onto this VM for a real `Run-EclPipeline` run against AFBUS/Federale.

> This VM's live AMT environment is **AMT177 / FEDERALE_APP** (COBOL OS 2200 track). Any path below starting `C:\Amt\...` or `C:\Dev\amt-go-net-net8\...` is carried over from the **source environment** and has **not** been verified to exist on this VM — treat as stale/unconfirmed unless noted otherwise.

> **⚠ Review note (2026-10-07):** this register was written on 2026-09-08 and several §4/§5 claims had gone stale (the "only 5 input files" line, and "not yet wired to Trial3/SsgConverter"). Those are corrected below. The **ToDo register at the foot of this file is no longer maintained here** — it had drifted to MT-005 while the live list reached MT-026. The single source of truth is now [SSG-PowerShell-Trial-Progress.html](SSG-PowerShell-Trial-Progress.html) §6 (Issues `T3-nnn`) and §7 (ToDo `MT-nnn`).

---

## 1. Copilot instructions, prompts & plans

| Asset | Path | Type | Purpose | Staleness / notes |
|---|---|---|---|---|
| AMT COBOL migration instructions | [.github/instructions/amt-cobol-migration.instructions.md](../.github/instructions/amt-cobol-migration.instructions.md) | `.instructions.md` (`applyTo: Amt/Migration/**`) | 10-step trial process, naming conventions, `Run-EclPipeline`/`Run-EclProof` usage, HTML-template generation workflow | References `C:\Amt\Migration\EclCobolPipeline\...`, `C:\Amt\Parallel\templates\...`, `C:\Amt\AMT_ReferenceDocuments\...` — **none confirmed present on this VM**. `applyTo` glob (`Amt/Migration/**`) doesn't match this repo's actual folder names (`Trial3/`), so it likely won't auto-attach here. |
| AMT-MIGRATE prompt | [.github/prompts/AMT-MIGRATE.prompt.md](../.github/prompts/AMT-MIGRATE.prompt.md) | `.prompt.md` (`mode: agent`) | `/AMT-MIGRATE <SSG_ELEMENT_NAME>` — single-program conversion workflow | References `c:\Amt\.github\...`, `c:\Amt\Migration\CobolConvert\...` (the **old** pre-EclCobolPipeline pipeline) — paths and even the pipeline name are superseded by Trial3/EclCobolPipeline. Needs rewrite before reuse. |
| HTML template architecture plan | [.github/Copilot_Plans/260819-share-html-templates.md](../.github/Copilot_Plans/260819-share-html-templates.md) | Design doc | Plan to split the 3 trial HTML files into versioned templates + JSON content + fill scripts | Describes `C:\Amt\Parallel\templates\` package (fill scripts, schema, README) — **not present in this repo**; the `docs/*.html` files here are the older monolithic (non-templated) files. Historical/aspirational, not actionable as-is. |
| Manifest schema doc | [.github/schemas/programs.manifest.schema.md](../.github/schemas/programs.manifest.schema.md) | Reference | Field-by-field schema for `programs.manifest.json` | Matches the manifest in this repo (`Trial3/manifest/programs.manifest.json`) — **current/authoritative**, safe to trust for manifest edits. |
| SsgConverter Copilot instructions | [SsgConverter/SsgConverter-COPILOT.md](../SsgConverter/SsgConverter-COPILOT.md) | Standalone context doc | Full behavioural spec for `SsgConverter` (what it does/doesn't convert, settings format, warning taxonomy, known issues KI-1..KI-3) | **Current/authoritative** — this is the tool actually verified working on this VM. No stale paths. |
| SsgConverter README | [SsgConverter/README.md](../SsgConverter/README.md) | Package readme | Quick start, prerequisites, fix log summary, package contents | Current. States "Full test result: 36 succeeded, 0 failed" — see ToDo MT-003 below. |
| SsgConverter fix log | [SsgConverter/Fixes/SsgConverter-Fix-20260820.md](../SsgConverter/Fixes/SsgConverter-Fix-20260820.md) | Fix log | 11 numbered fixes vs original build; documents the 36-file full run (3+7+36 breakdown) and its 3 warnings | Build path in header (`C:\Amt\Parallel\AMT175\...`) is source-env only; content itself (fix descriptions) is authoritative. |
| Trial3 README | [Trial3/README.md](../Trial3/README.md) | Package readme | EclCobolPipeline layout, design decisions, usage, follow-ups | Says "originals remain untouched in `C:\Amt\Migration\CobolConvert`" — that claim is now moot post-migration (this repo *is* the working copy). Usage examples `cd C:\Amt\Migration\EclCobolPipeline\tools` are stale; actual path is `Trial3\tools\`. |

**ToDo MT-001:** No `.instructions.md`/`.prompt.md` in this repo currently targets `Trial3/**` or references AMT177/FEDERALE_APP — all Copilot guidance still assumes the old AMT172/175 + `C:\Amt\Migration\...` layout. Worth authoring a Trial3-scoped instructions file once paths are confirmed.

---

## 2. Raw source objects — `SSG-Source/` (read-only reference)

20 Unisys 2200 SSG/COBOL hybrid files, referenced by `Trial3/config/pipeline.config.json` → `rawSourceDir` (currently `C:\Amt\MainframeSource\2026-07-07_SSG\CreatingCobol` — **unconfirmed on this VM**; a local copy also lives at `../SSG-Source` per the user's note).

| File | Complexity score (SSG_QUICK_REFERENCE.md) | Manifest coverage |
|---|---|---|
| SCAN_ASCII.TXT | 214.6 (highest) | `SCAN` — done |
| CONDIS2_ASCII.TXT | 210 | not in manifest |
| TAPELD_ASCII.TXT | 209.5 | `TAPELD_DISTRIB` — done |
| TABAN_ASCII.TXT | 191.5 | not in manifest |
| EXTEUR.TXT | 183.3 | not in manifest |
| RECAP.TXT | 164.1 | not in manifest |
| FUSBA_ASCII.TXT | 161.5 | not in manifest |
| CFH-COPY_ASCII.TXT | 155.6 | not in manifest |
| CFH-COPY.TXT | 146 | `CFH-COPY` — done |
| BABA_ASCII.TXT | 137.7 | not in manifest (converted via SsgConverter Examples) |
| FUSBA2_ASCII.TXT | 131.4 | not in manifest |
| LECTIS_ASCII.TXT | 78.6 | `LECTIS` — done |
| LOADIS_MULTI.TXT | 77 | `LOADIS_MULT-NODUP` — done |
| ARCHIFORMAT.TXT | 73 | `ARCHIFORMAT` — done |
| CHAB100_ASCII.TXT | 69.1 | not in manifest |
| CHABAN_ASCII.TXT | 69 | not in manifest (converted via SsgConverter Examples) |
| UNLOADIS_MULTI.txt | 56.2 | `UNLOADIS_MULT` / `UNLOADIS_MULT-NODUP` — done |
| ARCHISEPARE | 41.9 | `ARCHISEPARE` — done (also SsgConverter Examples) |
| LOADIS_ASCII.TXT | 37.1 | not in manifest |
| UNLOADIS_ASCII.TXT | 26.9 | not in manifest (also SsgConverter Examples) |

Also present but not scored: `ARCHITAB1` (manifest, sourced from `ASSURFED_UTILIT_ARCHITAB1(P).TXT` — not in `SSG-Source/` file list above, likely named differently), `ECLAT`/`UGXB02`, `COMPARE`/`COMPARE2`, `MONTANT_SIGNE`, `TRI_ASCII`/`SORT-FICHOUT-1`.

Related root-level analysis artefacts in `Trial3/`: [SSG_All_20_Ranked.md](../Trial3/SSG_All_20_Ranked.md), [SSG_Complexity_Metrics.csv](../Trial3/SSG_Complexity_Metrics.csv), [SSG_COMPLEXITY_REPORT.md](../Trial3/SSG_COMPLEXITY_REPORT.md), [SSG_QUICK_REFERENCE.md](../Trial3/SSG_QUICK_REFERENCE.md).

---

## 3. Trial3 — EclCobolPipeline assets

### 3.1 Config
- [Trial3/config/pipeline.config.json](../Trial3/config/pipeline.config.json) — **ToDo MT-002:** `converterConsolePath` points to `C:\Dev\amt-go-net-net8\Migration Tools\CobolToAmt\CobolConverterConsole\bin\Debug\net8.0\CobolConverterConsole.exe` and `globalCopyDir` to `C:\Amt\MainframeSource\Codedrop 2025\CopyPrd` — **neither confirmed present on this VM**. This is the blocker for running the pipeline beyond `-ListOnly`.

### 3.2 Manifest — `manifest/programs.manifest.json` (14 programs, all `status: "done"`)

| key | programId | candidateDir | source file |
|---|---|---|---|
| MONTANT | MONTANT | trial-03-montant | ASSURFED_UTILIT_MONTANT_SIGNE(P).TXT |
| LECTIS | LECTIS | trial-05-lectis | ASSURFED_UTILIT_LECTIS_MULT(P).TXT |
| TRI_ASCII | SORT-FICHOUT-1 | trial-06-tri-ascii | ASSURFED_UTILIT_TRI_ASCII(P).TXT |
| ARCHITAB1 | ARCHITAB1 | trial-07-architab1 | ASSURFED_UTILIT_ARCHITAB1(P).TXT |
| SCAN | SCAN | trial-08-scan | (see manifest) |
| ECLAT | UGXB02 | trial-09-eclat | (see manifest) |
| COMPARE2 | COMPARE | trial-10-compare2 | (see manifest) |
| CFH-COPY | CFH-COPY | trial-11-cfh-copy | (see manifest) |
| ARCHIFORMAT | ARCHIFORMAT | trial-13-archiformat | (see manifest) |
| ARCHISEPARE | ARCHISEPARE | trial-12-archisepare | (see manifest) |
| LOADIS_MULT-NODUP | LOADIS-ASCII | trial-14-loadis-ascii | (see manifest) |
| UNLOADIS_MULT | UNLOAD-ASCII | trial-15-unload-ascii | (see manifest) |
| UNLOADIS_MULT-NODUP | UNLOAD-ASCII | trial-16-unload-ascii-nodup | (see manifest) |
| TAPELD_DISTRIB | CFH-COPY | trial-17-tapeld-distrib | (see manifest) |

Manifest backups: `manifest/backups/programs.manifest.20260702-{015358,022023,022735}.json` (3 point-in-time snapshots, 2026-07-02).

### 3.3 Tools (`tools/`)
Core pipeline: `Run-EclPipeline.ps1`, `Run-EclProof.ps1`, `Remove-SsgDirectives.ps1`, `Convert-SsgToLion.ps1`.
Support/one-off: `Fill-AfmtColumn.ps1`, `fill-ULND-cells.ps1`, `Revert-CobolBuildEdits.ps1`, `Rewrite-CobolRefs.ps1`, `Run-Pilot-CHABAN.ps1`, `Run-Pilot-UNLOADIS.ps1`, `_build-scan-candidate.ps1`, `_build-scan-fixtures.ps1`, `_check-json.ps1`, `_debug-trig-b.ps1`, `_eclat-trigger-b.ps1`, `_run-eclat-remove.ps1`, `_scan-find-ecl.ps1`, `_scan-show-params.ps1`, `_scan-trigger-b.ps1`, plus `AMT Mig` (name suggests leftover/misplaced item — worth checking) and `refimpl/` (per-program oracle scripts referenced by manifest `proof.refImpl`, 14 keys lowercased match fixture dir names below).

### 3.4 Settings (`settings/`) — 23 `.settings` files, one per trial + 3 general (`SSGConverterSettings*.settings`).

### 3.5 Candidates (`candidates/`) — 21 directories (14 from the current manifest `trial-NN-*` plus 7 older/duplicate `trial-01`..`trial-17` and `trial3-*` prefixed dirs — some naming overlap between `trial-12-archisepare`/`trial3-archisepare`, `trial-14-loadis-ascii`/`trial3-loadis-ascii`, `trial-15-unload-ascii`/`trial3-unloadis`, suggesting earlier re-runs under a different naming scheme). Worth reconciling which are canonical before the next pipeline run.

### 3.6 Fixtures (`fixtures/`) — 13 directories: `archiformat`, `archisepare`, `architab1`, `cfh-copy`, `compare2`, `eclat`, `lectis`, `LOADIS_MULT-NODUP`, `montant`, `scan`, `TAPELD_DISTRIB`, `tri_ascii`, `UNLOADIS_MULT`, `UNLOADIS_MULT-NODUP` (13 vs 14 manifest keys — inconsistent casing on 3 dirs, e.g. `LOADIS_MULT-NODUP` not lowercased per the naming convention in `amt-cobol-migration.instructions.md`).

### 3.7 Output (`output/`) — git-ignored, currently only a `.tmp/` scratch dir (no generated `.LionSource` artefacts present — consistent with the pipeline not yet run end-to-end on this VM).

### 3.8 Macros — `macros/ssg-stub.macros.xml` (stub token inventory, copied from legacy CobolConvert).

---

## 4. SsgConverter assets

| Asset | Path | Notes |
|---|---|---|
| Console binary | `SsgConverter/Build/Console/` (SsgConverterConsole.exe + deps) | Verified working — no rebuild needed |
| GUI binary | `SsgConverter/Build/Gui/` (SsgConverterGui.exe + deps) | Verified working — no rebuild needed |
| C# source | `SsgConverter/Source/SsgConverter.slnx`, `SsgConverter/`, `SsgConverterConsole/`, `SsgConverterGui/`, `_deps/` | Core logic in `SsgConverter/SymstreamProcessor.cs`, `SymstreamExpressionParser.cs`, `SymstreamExpressionMigrator.cs`, `Expressions/`, `Enums/`, `Exceptions/` |
| Example input | `SsgConverter/Examples/Input/` — **20 files** (was 5 at 2026-09-08; grown as programs were added from `SSG-Source/`) | The source files physically present for SsgConverter runs on this VM |
| Reference output | `SsgConverter/Examples/Output/` — matching **20** `.ps1` files | Golden output; all 20 parse 0 and run clean in the Tier-1 harness |
| Verify output | `SsgConverter/Examples/VerifyOutput/` + `SsgConversion_*.log` | Local verification run artefacts |
| Settings | `SsgConverter/Examples/Settings/SsgConverterSettings-example.settings` | Template — paths need updating per-machine per README |
| **Tier-1 harness (Area A)** | `SsgConverter/Trials/Tier1Mock/{Run-SsgPsTrial.ps1,SsgPsMockLib.psm1}` + `Trials/<Program>/sgs-values.json` | Mocks the AMT runtime; no AMT stack needed |
| **Real-runtime (Area D)** | `SsgConverter/Trials/RealRuntime/` — `Run-StageA.ps1`, `Run-StageB.ps1`, isolated `{AmtPsEclLib,AmtPsSortLib,EclOptions,AmtPsCustomerLib}.psm1`, `Deploy-CC-Job.ps1`, `Manage-FederaleServices.ps1`, `Repair-SqlServerWrapperClosure.ps1`, `AmtSettings.xml` | §B env-touching — see §5 |
| **Release tooling (MT-017)** | `SsgConverter/Trials/Release/` — `Build-Release.ps1`, `Generate-Release-Wrappers.ps1`, `Invoke-Tier1Check.ps1`, `Mock-Install-Dryrun.ps1`, `Get-MechanicsFingerprint.ps1`, `KnownIssues.json`, `LastLiveValidation.json`, `{README,RELEASE-NOTES}.template.md`, `VALIDATION-PROMPT.md`, `MockRuntime/` | Drives the weekly `/ssg-release` cycle |
| **Live batch runner (MT-025, new 261007)** | `SsgConverter/Trials/LiveBatch/` — `Run-LiveBatch.ps1`, `BatchConfig.json`, `RunList.txt`, `KnownIssues.json` | One CC job runs many programs, each as its own child process, with watchdog + joblog harvest. Deployed copy sits in the live Basepaths (§5) |

**ToDo MT-003 (36-file set) — partially superseded.** The README/fix-log reference a **"full 36-file run" (36 succeeded, 0 failed, 2026-08-21)**. At 2026-09-08 only **5** of those inputs were present; the set has since been grown to **20** (sourced from `SSG-Source/`), all converting and running clean in Tier-1. The original 36 are still not all present, so the item remains open in the narrower sense — but the "only 5 runnable" constraint no longer applies.

---

## 5. Environment / config assets outside the repo (unconfirmed on this VM)

| Reference | Found in | Status |
|---|---|---|
| `C:\Dev\amt-go-net-net8\...\CobolConverterConsole.exe` | `Trial3/config/pipeline.config.json` | **Not confirmed** — blocks full pipeline run (user's stated known gap) |
| `C:\Amt\MainframeSource\Codedrop 2025\CopyPrd` (globalCopyDir) | `Trial3/config/pipeline.config.json` | **Not confirmed** — same gap |
| `C:\Amt\MainframeSource\2026-07-07_SSG\CreatingCobol` (rawSourceDir) | `Trial3/config/pipeline.config.json` | **Not confirmed**; local `../SSG-Source` substitute exists per user note |
| `C:\Amt\Migration\...`, `C:\Amt\Parallel\templates\...`, `C:\Amt\AMT_ReferenceDocuments\...` | `.github/instructions/amt-cobol-migration.instructions.md`, `.github/prompts/AMT-MIGRATE.prompt.md` | **Not confirmed** — historical source-env paths, do not assume present |
| AMT177 Control Center / FEDERALE_APP / AFBUS_AMT / FA_AFBUS / Basepaths | User-supplied | **This VM's live target environment.** ⚠ The old "not yet wired to Trial3/SsgConverter" note is **no longer true** — see §5.1 |

### 5.1 Live AMT touchpoints created 2026-10-06/07 (previously "not wired")

The trial is now genuinely installed into, and running against, the live AMT environment at
`E:\Repos\Federale_InternalRelease`. These are the concrete touchpoints — all **outside** the SsgTrial repo,
so they do **not** survive an environment rebuild and must be re-created (see the routines in
[SSG-PowerShell-Trial-Progress.html](SSG-PowerShell-Trial-Progress.html#routine) §5):

| Live path | What we put there | Durability |
|---|---|---|
| `AmtTools\Basepaths\Scripts\<KEY>.ps1` | 20 converted bodies, **flat at the Script-path root** (nesting breaks wrapper resolution) | Survives redeploy (Basepaths not republished) |
| `AmtTools\Basepaths\Scripts\SSGTRIAL\RUN\<KEY>-LIVE.ps1` | 20 generated CC wrappers, 2 folders below root so their `..\..\Libraries` fallback resolves | Survives redeploy |
| `AmtTools\Basepaths\Scripts\SSGTRIAL\RUN\{Run-LiveBatch.ps1,BatchConfig.json,RunList.txt,KnownIssues.json}` | Live batch runner (MT-025); results under `LiveBatchRuns\<stamp>\` | Survives redeploy |
| `AmtTools\Basepaths\Scripts\Libraries\AmtPsCustomerLib.psm1` | `Log-Message` stub (T3-011), extended to write to the real joblog | Survives redeploy |
| `AmtTools\Basepaths\Scripts\Settings\AmtSettings.xml` | `AppName` corrected `AFBUS_2200COBOL` → `FEDERALE_APP` (the former was never a registered app) | Survives redeploy |
| `AmtTools\ComScript\` | **T3-013 RID fix** — republished `-r win-x64` | ⚠ **REVERTED by any release redeploy (MT-024)** — must be re-applied |

**Backups of everything overwritten:** `SsgConverter/_backup/ComScript-live-<stamp>/` (116 files) and
`SsgConverter/_backup/AmtSettings-live-20261006.xml`.

---

## ToDo register (MT-nnn) — moved

> **No longer maintained in this file.** It had drifted badly (stopped at MT-005 while the live register
> reached MT-026), which is exactly the dual-maintenance failure mode worth avoiding. The authoritative
> registers are now:
>
> - **Issues (`T3-nnn`)** — [SSG-PowerShell-Trial-Progress.html §6](SSG-PowerShell-Trial-Progress.html#issues)
> - **ToDo (`MT-nnn`)** — [SSG-PowerShell-Trial-Progress.html §7](SSG-PowerShell-Trial-Progress.html#todo)
> - Conventions — [.github/instructions/ssg-todo-issues.instructions.md](../.github/instructions/ssg-todo-issues.instructions.md)
>
> The items this file still references inline (MT-001/002/003/004) are kept where they appear above for
> context, but their **current status lives in the tracker**, not here.
