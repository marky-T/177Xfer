# Cross-Trial Asset Register (Trials 1–3)

**Generated:** 2026-10-09 · **Scope:** what routines, tools and reference material already exist
from Trials 1–3, so Trial 4 (whole-source SSG+ECL+COBOL conversion, ~50 incoming programs) doesn't
reinvent them. Companion to
[docs/Asset-Register.md](Asset-Register.md) (Trial 3 detail, this repo) and
[.github/Copilot_Plans/261009-trial4-epic-strategy.md](../.github/Copilot_Plans/261009-trial4-epic-strategy.md)
(the epic this supports).

> Trials 1 and 2 ran on a laptop that is no longer the working environment. Their artefacts survive
> only as documentation carried into this repo (`docs/AMT172-Setup-Guide.*`, `docs/AMT175-Setup-Guide.html`,
> the older `docs/SSG-Trial-Progress.html`) — the laptop's actual file tree was not re-verified for
> this register. Treat any laptop-local path in those docs as **stale/unconfirmed**, same rule as
> `C:\Amt\...` paths elsewhere in this project.

---

## 1. Overview

| Trial | Programs | Environment | Where it ran | Route | Outcome |
|---|---|---|---|---|---|
| 1 (June) | 16 | AMT172, laptop | laptop AMT stack | SSG-led, early COBOL→C# proofs | Main push was SsgConverter; laptop perf/space/consistency limited the trial |
| 2 (Aug) | 20 (overlaps Trial 1) | AMT175, laptop | laptop AMT stack | SSG-led | Same laptop constraints |
| 3 (Sept–now) | 20 | This VM, AMT177→~AMT179 | Tier-1 mock harness; live runs on AMT172 | SSG only | 20/20 convert + parse-clean; 18/20 live on AMT172 (rc.01), re-validation pending (MT-021); **no real business output** (ECL/COBOL never converted) — this is the reason for Trial 4 |

---

## 2. Trial 1 — AMT172, 16 programs

- **Full asset library landed 2026-10-11:**
  [docs/Reference-Trials/AssetLibrary-AMT172-20261010/](Reference-Trials/AssetLibrary-AMT172-20261010/)
  (708 files, own `asset-register.csv`/`.md`). Built and exported by the AMT172 Copilot session per
  [export-trial-asset-library.prompt.md](Plan/export-trial-asset-library.prompt.md), pulled from
  `marky-T/177Xfer` branch `asset-library-AMT172-20261010`. Includes `02-todo-issues/*.todo.extract.md`
  (16 files, done+open counts) — the direct input for **MT-029**, reviewed 2026-10-11 (§4 below).
  `07-other` carries the `CFH-COPY-Trial11`
  C# source (`Assurfed_Utilit_Cfh_Copy.Core.cs`/`.csproj`) — Target A's prior build (epic §4C), not
  clutter; promote it out of `07-other` once `Conversion/` exists. A handful of `.ini`/`.code-workspace`/
  `.gitignore`/`.7z` rows are marked `Status=unknown` in its register — harmless, no action needed.
- **Runbook:** [docs/AMT172-Setup-Guide.md](AMT172-Setup-Guide.md) / `.html` — environment setup
  guide for AMT172. Treat as historical; AMT172 is not this VM's live target.
- **Progress tracker:** the older [docs/SSG-Trial-Progress.html](SSG-Trial-Progress.html) (distinct
  from the current [SSG-PowerShell-Trial-Progress.html](SSG-PowerShell-Trial-Progress.html), which is
  Trial 3's) — covers the 16-program set at this earlier stage.
- **Reusable artefact of note:** `Run-EclProof.ps1` — a Tier-1 ECL→PowerShell proof/validation
  script, `-ListOnly`-capable, fixture-driven. This is the Trial-era ancestor of Trial 3's
  `Run-SsgPsTrial.ps1` / Tier-1 harness pattern — worth comparing the two before building Trial 4's
  ECL-layer harness, rather than starting from nothing.
- **Converter used:** `CobolConverterConsole.exe` (version unverified). Not in this repo; the
  installed AMT drop `E:\Repos\AMT\MigrationTools\CobolToAmt.zip` has the GUI only. Console to be
  obtained from the R&D repo (`amt-go-net-mirror/Migration Tools/CobolToAmt`) — see epic §6 item 7.
- **Known issue carried forward:** UTF-8 BOM in column 1 of source files made
  `CobolConverterConsole` emit 0 objects; fix was to rewrite the source BOM-free. Re-check this the
  moment real COBOL source is fed into the console again.
- **Not yet amalgamated into the one ToDo list ([MT-029](SSG-PowerShell-Trial-Progress.html#MT-029)),
  but inputs now in hand (2026-10-11):**
  a 17-entry Bug Log (`bug1`–`bug17`) covering AB Suite, LincToLionGui, Keycloak, LionDevGenNet,
  ApplicationCenter, and LionDev-import issues, plus the asset library's own
  `02-todo-issues/*.todo.extract.md` files (done+open items from checklists and status badges). Per
  the user's rule — **only one ToDo list exists**, this project's `T3-nnn`/`MT-nnn` register — these
  need reviewing and either ported forward or explicitly marked superseded, not left as a second,
  un-cross-referenced list.

## 4. Todo-extract review (2026-10-11) — findings against the 12 distinct plan/checklist documents

The 44 `*.todo.extract.md` files across both libraries collapse to **12 logically distinct
documents** (the rest are duplicate copies collected from different folders on the same machine).
Each was read in full and cross-checked against this register. Outcome logged as
[MT-030](SSG-PowerShell-Trial-Progress.html#MT-030),
[MT-031](SSG-PowerShell-Trial-Progress.html#MT-031),
[MT-032](SSG-PowerShell-Trial-Progress.html#MT-032), plus evidence folded into
[MT-002](SSG-PowerShell-Trial-Progress.html#MT-002) and
[MT-005](SSG-PowerShell-Trial-Progress.html#MT-005-amt175). Headline: **both historical trials got
Tier-1 (mock) validation solid but left Tier-2+ (real runtime / Control Center) work incomplete or
unverified** — not a reason to distrust their *logic*, but a reason not to assume their *process*
for CC registration or real-library deployment was ever proven end-to-end. The numbered Bug Log
(`bug1`–`bug17`) itself is a separate, still-unreviewed piece of MT-029.

**Data-quality caveat found during this review:** duplicate-named files are not guaranteed
identical. `Migration/SSG-ECL-PowerShell-Reference.todo.extract.md` (18 done / 16 not done) and
`Amt/SharePipelineProcess/SSG-ECL-PowerShell-Reference.todo.extract.md` (6 done / 10 not done) are
the *same* source document captured at two different points from two different folders on AMT172 —
they'd drifted out of sync with each other on their own machine before export. Don't assume
same-named files across sub-paths are safe to dedupe without a diff first.

**Noise, confirmed safe to ignore:** HTML-template-sharing infra tasks, documentation-UX checklist
items (collapsible sections, localStorage), the generic 25-phase `trial-checklist` template (we use
`Run-SsgPsTrial.ps1` instead), the AMT172/175 parallel-coexistence review prompt, and AFBUS web-UI
(OIDC/IIS/Blazor) items — none bear on SSG/ECL/COBOL conversion.

## 5. Trial 2 — AMT175, 20 programs

- **Full asset library landed 2026-10-11:**
  [docs/Reference-Trials/AssetLibrary-AMT175-20261010/](Reference-Trials/AssetLibrary-AMT175-20261010/)
  (891 files, own `asset-register.csv`/`.md`), same export process and provenance as Trial 1's (§2).
  Includes 28 `02-todo-issues/*.todo.extract.md` files (more than Trial 1's 16, reflecting the larger
  20-program set) and the whole of `Source-SSG` plus `candidates`/`SSGConverter_Input` test data under
  `03-pipelines` (tagged "SSG source/test data" in its register). Also carries its own copy of the
  `CFH-COPY-Trial11` C# source in `07-other` — same caveat as Trial 1 (§2): this is Target A material,
  diff the two copies before picking one as canonical.
- **Runbook:** [docs/AMT175-Setup-Guide.html](AMT175-Setup-Guide.html).
- Shares most of Trial 1's program set (4–8 programs overlap) and the same `CobolConverterConsole`
  binary/issue above (BOM). **Caveat:** program variants between the two trials are not guaranteed
  identical — diff source before reusing any Trial 1/2 fixture against a Trial 2 (or Trial 4) program
  of the same name.
- No separate COBOL→C# pipeline documentation beyond what's in
  `docs/Reference Docs/Migration CobolToC/Trial-Setup-Guide.md` (5-step outline: source analysis →
  pilot script → pipeline → fixtures → refimpl oracle). This is the closest thing to a written
  COBOL-conversion runbook predating Trial 4 — read it before designing Trial 4's COBOL pipeline
  step, since it already encodes the refimpl/oracle pattern the incoming plan also calls for.

## 6. Trial 3 — this VM, AMT177→~AMT179, 20 programs

Already has a dedicated, actively maintained register: [docs/Asset-Register.md](Asset-Register.md).
Headline recap only (see that file for full detail):

- **Converter:** `SsgConverter` (SSG→PowerShell) — `Build/Console`, `Build/Gui`, verified, 20/20
  examples parse-clean. Source at `SsgConverter/Source/`.
- **Tier-1 harness:** `SsgConverter/Trials/Tier1Mock/{Run-SsgPsTrial.ps1,SsgPsMockLib.psm1}` — mocks
  the AMT runtime surface (`GetSgsValue`, `Call-ExternalProgram`, `Hdg`, `SetC`, `Log-Message`, …).
- **Real-runtime harness (Area D):** `SsgConverter/Trials/RealRuntime/` — isolated copy of
  `AmtPsEclLib`/`AmtPsSortLib`/`AmtPsCustomerLib`/`EclOptions`, `Run-StageA.ps1`, `Run-StageB.ps1`,
  `Deploy-CC-Job.ps1`. Stage A (no live app) reaches `Fin` clean for CFH-COPY. Stage B blocked on
  **MT-009** (no 2nd `CobolOS2200` CC application yet) — Trial 4 now depends on this directly.
  Also carries `Manage-FederaleServices.ps1` and `Repair-SqlServerWrapperClosure.ps1` — operational
  helpers worth checking before writing new ones for Trial 4's CC interactions.
- **Release tooling (MT-017):** `SsgConverter/Trials/Release/{Build-Release.ps1,
  Generate-Release-Wrappers.ps1,Invoke-Tier1Check.ps1,Mock-Install-Dryrun.ps1,
  Get-MechanicsFingerprint.ps1}` — drives the proven `/ssg-release` cycle (see §7 below).
- **Live batch runner (MT-025):** `SsgConverter/Trials/LiveBatch/{Run-LiveBatch.ps1,BatchConfig.json,
  RunList.txt}` — one CC job runs many programs as child processes with a watchdog. Useful pattern
  for running the ~70-program Trial 4 set without one CC job per program.
- **Trial3/EclCobolPipeline (the pre-Trial-3 COBOL attempt):** `Trial3/tools/{Run-EclPipeline.ps1,
  Run-EclProof.ps1,Remove-SsgDirectives.ps1,Convert-SsgToLion.ps1}`, `Trial3/manifest/programs.manifest.json`
  (14 programs, schema at [schemas/programs.manifest.schema.md](../.github/schemas/programs.manifest.schema.md)),
  `Trial3/fixtures/`, `Trial3/candidates/`, `Trial3/refimpl/`. **Blocked beyond `-ListOnly`** — the
  config points at a `CobolConverterConsole.exe` and `globalCopyDir` not present on this VM
  (**MT-002**, **MT-004**). This is the same missing-binary gap as Trial 1/2 §2/§5 above — one gap,
  three trials, still open. Closing it once unblocks all three retrospectively.
- **Known issues fixed (reusable fix patterns, not just history):** `T3-001`..`T3-012` — data-line
  parse bug, `Hdg`/`SetC`/`Log-Message` mock primitives, `Clear-Variable`→`$name=0` rewrite, Hashtable
  `.Keys`/`.ContainsKey` ETS-shadowing (`.PSBase.*` fix), leading-`+` `*INCREMENT` variable names,
  `Zone.Identifier` block on copied-in `.psm1` files breaking BatchController silently. Full table:
  [SSG-PowerShell-Trial-Progress.html](SSG-PowerShell-Trial-Progress.html) §6.

## 7. Federale release/deployment area — already proven, reuse not rebuild

Confirmed present on this VM, outside this repo:

| Location | Contents | Status |
|---|---|---|
| `E:\Repos\release_candidates\release20261002-rc.01` | `1_ConvertedScripts/{Bodies,Wrappers,SgsSeeds}`, `2_OriginalSource/`, `README.md`, `RELEASE-NOTES.md`, `VALIDATION-PROMPT.md` | One RC package, 2026-10-02 |
| `E:\Repos\Federale_InternalRelease\Scripts_SSG` | 20 program bodies, 20 `-LIVE.ps1` wrappers, 20 SGS seed files, 20 original source `.TXT`, `Generate-Release-Wrappers.ps1`, `README.md`, `RELEASE-NOTES.md` | 20/20 parse-clean, 18/20 live-pass (EXTEUR, FUSBA_ASCII open) |
| `E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Scripts` | 20 deployed `.ps1` bodies flat + `Libraries/`, `Settings/` | Live CC deployment target — matches Scripts_SSG |

**No converter binaries exist anywhere in `Federale_InternalRelease`** — `EclConverterConsole.exe`
and `CobolConverterConsole.exe` are not there, and `SsgConverterConsole.exe` only exists inside this
repo (`SsgConverter/Build/Console`), not deployed to Federale. This confirms the build area and the
release/deploy area are correctly separated (per the CI's core rule), but it also means the ECL/COBOL
converter binaries have to be sourced fresh for Trial 4 — they were never captured from the original
PC into either repo.

## 8. Gaps — nothing to build yet, just not here

- ~~Unisys OS 2200 / SSG / ECL manuals — location on this VM unconfirmed.~~ **Closed 2026-10-09:**
  `docs/Reference Docs/` now holds 22 source documents (3 Unisys OS/2200 vendor manuals — ECL/FURPUR,
  Exec System Software, ClearPath Extension Kit — plus 6 Avanade/Asysco training & product docs and 4
  internal trial-pipeline docs), catalogued with authority ratings and subject coverage in
  [docs/Reference-Docs-Register.md](Reference-Docs-Register.md). Note: two of the internal docs
  there (`Migration CobolToC/converter-settings-guide.md`,
  `Migration CobolToC/batch-harness-patterns.md`) directly describe `CobolConverterConsole`'s
  `.settings` schema and `AmtPsEclLib`/`AmtSettings.xml` patterns — read these before re-deriving
  either from scratch once the binary itself is sourced (epic §6 process-map item 7).
- Raw ECL runstreams (`RunsPrd`, ~1080 files) and shared copybooks (`CopyPrd`) — referenced by the
  incoming plan and by Trial 3's `pipeline.config.json`, not confirmed present on this VM.
- `find-ssg-ecl.ps1` (runstream call-site locator, used to find real SGS parameter cards per program)
  — not confirmed present.
- The forensic research report the user originally referenced
  (`phase_1_forensic_research_report_federale_os_2200_20261007_191715.docx`) was not found in
  `docs/Plan/` or elsewhere in the workspace — only the two plan text files landed. Flagging in case
  it was meant to be added separately.
