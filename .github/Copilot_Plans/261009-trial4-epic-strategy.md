---
title: "SSG-4 (Trial 4) — Epic & Strategy (whole-source conversion: SSG + ECL + COBOL)"
date: "2026-10-09"
status: "draft — for review"
owner: "Mark"
---

# Epic: SSG-4 — convert SSG + ECL + COBOL as one pipeline, on AMT's own tools

> **Naming (2026-10-12):** **SSG-4** is the shorthand for this effort (Trial 4); **SSG-3** is the
> earlier SSG-only work in `Trial3/` and `SsgConverter/`. Anything actively used for this effort is
> labelled SSG-4. Existing folder and file names (for example `Trial3/`, and this file's name) are
> **not** renamed, because links, scripts and the weekly release depend on them.

> **The working process (2026-10-13):** the numbered steps, who or what does each, inputs and outputs, and
> the known gotchas are on one page: [Conversion/PROCESS.md](../../Conversion/PROCESS.md). This epic
> holds the decisions and evidence; that page holds how to run it.

> **This is the top-line document the user asked to review before any per-area detail work
> starts.** It does not change any code. Nothing below is actioned until confirmed.

## 1. Why Trial 4 exists

| Trial | Scope | Environment | Route used | Outcome |
|---|---|---|---|---|
| 1 (June) | 16 programs | AMT172, laptop | SSG-led, with early COBOL→C# proofs (e.g. TRI_ASCII, MONTANT) | Main push was building/fixing SsgConverter; laptop constrained (perf/space/inconsistent AMT setup) |
| 2 (Aug) | 20 programs (overlaps Trial 1) | AMT175, laptop | SSG-led | Same laptop constraints |
| 3 (Sept–now) | 20 programs | This VM, AMT177→now ~AMT179 | SSG only (`SsgConverter`) | **20/20 convert + parse-clean + Tier-1 clean; 18/20 ran live on AMT172 (rc.01), re-validation pending after T3-012 (MT-021) — but no real business output** |

> Naming: the `trial-NN-*` folders under `Trial3/candidates` are individual **report runs**, not
> Trials 1–4. Call them *runs* in new docs to avoid the clash.

**Root cause found in Trial 3:** the pipeline only ever converted the **SSG** layer (template/code
generation). The **ECL** (job control: `@ASG`/`@USE`/`@XQT`…) and **COBOL** (the actual business
logic: `OPEN`/`READ`/`COMPUTE`/`WRITE`) were never converted. The PowerShell runs to `Fin` because
`AmtPsEclLib`'s `Call-ExternalProgram` is a no-op stub — it logs and does nothing. There was never
a C# program for `Xqt` to start. "Ran end-to-end" was never the same as "did the job."

**Two new plan documents** (now in `docs/Plan/`: `ssg-2-prompt` / `SSG4 plan-a` — an evidence/guardrail
framework — and `SSG4 plan-a extended` — the concrete work plan) lay out how to close this gap:
convert all three layers, stop treating the existing converters as self-validating, and build a
real differential oracle. Trial 4 adopts that plan's structure, adjusted to what's actually on this
VM.

**Scale change:** ~50 more programs are coming in, not yet seen. Total scope moves from 20 to
roughly 70+. A per-program Copilot-driven conversion (as used to build/fix `SsgConverter` itself)
is not repeatable or affordable at that scale — Trial 4's second objective is to get this running on
**AMT's own converters** (`EclConverterConsole`, `CobolConverterConsole` → C#) as a pipeline, with
Copilot's role narrowing to fixing the converters and adjudicating differences, not hand-converting
programs.

## 2. Objectives (what "done" means for Trial 4)

1. **One program, all three layers, byte/behaviour-verified.** A single proving target converts
   SSG + ECL + COBOL, runs in the real AMT Control Center, and produces output that matches an
   independently built reference (not matched against the converter's own prior output).
2. **One consolidated build area.** Assets currently spread across 3 historical environments (two
   laptops now effectively gone, plus this VM) and 2 fresh plan documents land in **one place** —
   this repo — before the pipeline is extended to more programs.
3. **A pipeline, not a chat session.** Re-running a program through AMT's converters is a scripted,
   idempotent step, matching the existing Area A/B/C/D regime already in
   [copilot-instructions.md](../copilot-instructions.md).
4. **An asset register per historical trial**, so nothing already built gets reinvented when the
   50 incoming programs land (separate deliverable, see §7).
5. **One active codebase, clearly split by purpose** — not scattered across ad-hoc folders (§5).

## 3. Principles adopted from the incoming plan (cross-cutting, not area-specific)

These apply to every area below, not just one:

- **Evidence hierarchy** (plan §1): Unisys manuals > actual Federale source/runstreams > existing
  converter implementation > existing internal docs > labelled inference. Classify conclusions as
  `PROVEN_BY_UNISYS_MANUAL` / `OBSERVED_IN_FEDERALE_SOURCE` / `DERIVED_WORKING_MODEL` / `ASSUMPTION`
  / `UNKNOWN`. Never use converted PowerShell/C# as evidence of original intent. **The top of this
  hierarchy is now in hand:** `docs/Reference Docs/` has been updated with 22 source documents (3
  Unisys OS/2200 vendor manuals, 6 Avanade/Asysco training & product docs, 4 internal trial-pipeline
  docs, 1 online-help index), catalogued in
  [docs/Reference-Docs-Register.md](../../docs/Reference-Docs-Register.md) (authority rating + subjects
  + use recommendation per document; register itself lives in `docs/`, not inside `Reference Docs/`,
  and is not tracked in git). `PROVEN_BY_UNISYS_MANUAL` claims can now cite page numbers against the 3
  vendor manuals rather than being deferred as `UNKNOWN`.
- **Generation-time vs runtime** (plan §4): SSG's `*SET`/`*DEFINE`/`*PROCESS`/`*INCREMENT`/SGS
  lookups decide *what gets generated*; COBOL's `OPEN`/`READ`/`WRITE` is the generated program
  *running*. Don't collapse SSG variables into runtime PowerShell variables.
- **Reference oracle, not self-testing** (plan §8–10): build an independent reference
  implementation per target program; diff the converter pipeline against *that*, never against its
  own earlier output. This is new discipline — Trial 1–3 did not have an independent oracle for
  ECL/COBOL (Trial 3's SSG expansion already drifted 85–141 rows from one such attempt, unreconciled).
  We already have this instinct for SSG-only work (`SsgConverter/Trials/Tier1Mock` harness + Trial3
  goldens) — it needs extending one layer down, not inventing from scratch.
  This mirrors our own house rule in [copilot-instructions.md](../copilot-instructions.md)
  ("diagnose before theorising" / T3-015) — same discipline, now applied to ECL + COBOL.
- **Difference classification** (plan §18): every mismatch gets one label —
  `CONVERTER_DEFECT` / `AMT_PLATFORM_ADAPTATION` / `UNSUPPORTED_SOURCE_CONSTRUCT` /
  `REFERENCE_IMPLEMENTATION_DEFECT` / `UNRESOLVED_UNISYS_SEMANTIC` / `FEDERALE_SOURCE_AMBIGUITY`.
  This slots next to our existing `T3-nnn`/`MT-nnn` registers (§7) rather than replacing them —
  recommend tagging each `T3-nnn` row with one of these six labels going forward.
- **Don't invent; search AMT first.** Before any new C#/PowerShell emulation, check whether
  AMT libraries already provide the behaviour (plan §15/Rule 9). This matches our existing rule not
  to "fix" SsgConverter KI-1..3 without a confirmed failing case — extend the same caution to ECL/COBOL.

## 4. High-level approach, per significant area

Strategy only — the detailed task breakdown for each comes after this epic is confirmed.

### A — Asset & tool consolidation
Bring everything needed into this repo/VM before scaling, landing it directly in the target layout
from §5 rather than the current scattered roots. Confirmed present vs still-needed is in
the process map (§6). Headline gaps found just now: **`EclConverterConsole.exe` and
`CobolConverterConsole.exe` are not present anywhere in this repo or in
`E:\Repos\Federale_InternalRelease`** — both existed only on the original PC (per the incoming plan's
§11 path list). This is the first blocking gap, not a detail item.

### B — Evidence & reference-oracle discipline
Stand up the classification habit (§3) as a lightweight convention — reuse the existing
`T3-nnn`/`MT-nnn` register mechanics ([ssg-todo-issues.instructions.md](../instructions/ssg-todo-issues.instructions.md))
rather than a parallel system. Build one independent reference implementation (plan §13) for the
first proving target only — not all 70 programs.

### C — Phase-1 spike: one program, all three layers
The incoming plan nominates **CFH-COPY** as Target A (47 real `@SSG` calls in the runstreams, a
prior C# build already exists at `CFH-COPY-Trial11` on the original PC, and it's already proven at
the SSG-only layer in this repo). MONTANT_SIGNE (the plan's original nominee) has **no real
runstream calling it** — drop it as the *primary* target, keep it as a secondary flat-file oracle
(it already has a working C# job and Tier-1 golden). This reuses Trial 3's own finding, not a new
one.

### D — Manifest & pipeline integration: **revive and extend `Trial3/tools/Run-EclPipeline.ps1`, don't build a new pipeline**
We already have a pipeline shaped for exactly this: `Trial3/tools/{Run-EclPipeline.ps1,
Run-EclProof.ps1,Remove-SsgDirectives.ps1,Convert-SsgToLion.ps1}` plus `manifest/programs.manifest.json`,
`candidates/`, `fixtures/`, `refimpl/`. This is the **EclCobolPipeline** — its name and shape already
assume SSG+ECL+COBOL, not SSG-only. It has never been run past `-ListOnly` because
`pipeline.config.json` points at a `CobolConverterConsole.exe` and `globalCopyDir` that aren't on
this VM (**MT-002**/**MT-004** — same root cause as §6 item 7 below). Closing that gap is what
unblocks this pipeline, not writing a replacement for it. Under §5's fresh layout, the proven pieces
of this pipeline are **copied/adapted into** `Conversion/Pipeline/` one at a time — `Trial3/` itself
stays where it is, untouched.

So the concrete plan is:
1. Source `CobolConverterConsole.exe` + `globalCopyDir` (closes MT-002/MT-004) so `Run-EclPipeline.ps1`
   can run past `-ListOnly`.
2. Reconcile its 14-program manifest against Trial 3's 20 — same `programs.manifest.json` schema,
   just needs the 6 missing entries added (or confirmed out of scope).
3. Extend that manifest with the `ecl` block (SGS cards, ordered ECL steps, logical-to-designator
   bindings, `@XQT` target) — additive schema change, documented in
   [programs.manifest.schema.md](../schemas/programs.manifest.schema.md).
4. `SsgConverter` stays as the SSG-layer sub-tool the pipeline calls (it already is, conceptually —
   `Convert-SsgToLion.ps1` is the seam); the Tier-1 mock harness
   (`SsgConverter/Trials/Tier1Mock`) stays as the SSG-only regression check it already is, not a
   second pipeline.
5. The ECL converter (once sourced, §6 item 6) and the reference-oracle/refimpl step (§3) slot into
   this same `Run-EclPipeline.ps1`/`Run-EclProof.ps1` structure as new stages, alongside the existing
   `candidates/`/`fixtures/`/`refimpl/` folders — those folders already anticipate this.

### E — Scale-out: triage existing 20 + ~50 incoming
Group by construct family (flat / indexed / sort / multi-file), not by arrival order. Reuse Trial
3's complexity ranking (`SSG_All_20_Ranked.md`) as the model for ranking the incoming 50 once seen.

### F — Release & deployment reuse
**This is the one area that's already working and proven at scale** — do not rebuild it. The
Scripts_SSG → `release_candidates` → `AmtTools\Basepaths\Scripts` path already ships 20 SSG-only
programs live (RC `release20261002-rc.01`, 18/20 passing live). Trial 4 only needs to **extend**
this path to also carry the C# DLL half (deploy to `Binaries\Reports`/`Programs`, register as a CC
job) — the PS1-side packaging, wrapper generation, and validation-prompt machinery stay as-is.

## 5. Repository layout — one active codebase

Raised directly by the user, not in either incoming plan doc — added here because it gates where
every item in §4 and §6 physically lands. Current state: the active codebase is **split across 3
workspace roots** (`SsgConverter/` has the SSG converter + all the Tier-1/RealRuntime/Release
harnesses; `Trial3/` has the EclCobolPipeline tooling/manifest/fixtures; `SSG-Source/` has the raw
program source) plus loose top-level clutter in `docs/`. That's the scatter the user wants fixed
before Trial 4 adds an ECL converter and a COBOL converter on top.

**Proposed target shape**, mapped to the six buckets requested:

| Bucket | Target location | What lands there | Source to copy from (not moved) |
|---|---|---|---|
| **Documentation** — trial tracking/process docs (html + source) | `docs/Trial-Progress/` | `SSG-PowerShell-Trial-Progress.html`, the older `SSG-Trial-Progress.html`, `SSG-COBOL-Reference.html`, `SSG-ECL-Command-Matrix.html`, `SSG-ECL-PowerShell-Reference.html`, `AMT172-Setup-Guide.*`, `AMT175-Setup-Guide.html` | `docs/` root (mixed in with ~150 loose `_*.txt` diagnostic files) |
| **Documentation** — asset registers | `docs/Asset-Registers/` (see open question below) | `Asset-Register.md`, `Cross-Trial-Asset-Register.md` | `docs/` root |
| **Documentation** — reference manuals | `docs/Reference Docs/` (unchanged) | 22 Unisys/Avanade/Asysco docs + `Reference-Docs-Register.md` | already here, no move |
| **Documentation** — previous-trial reference | `docs/Reference-Trials/` (new) | Pointers/summaries into Trial 1/2/3 original material that is **not** being actively reused (the laptop-era docs, superseded candidate dirs) | currently just narrative in `Cross-Trial-Asset-Register.md` |
| **Conversion** — pipeline process | `Conversion/Pipeline/` (new root) | `Trial3/tools/{Run-EclPipeline.ps1,Run-EclProof.ps1,Remove-SsgDirectives.ps1,Convert-SsgToLion.ps1}`, `manifest/`, `candidates/`, `fixtures/`, `refimpl/`, `config/` | `Trial3/` |
| **Conversion** — SSG | `Conversion/Ssg/` | `SsgConverter/{Source,Build,Examples}` | `SsgConverter/` root |
| **Conversion** — ECL | `Conversion/Ecl/` (new, empty until sourced) | `EclConverterConsole` once sourced (§6 item 6) | n/a yet |
| **Conversion** — COBOL | `Conversion/Cobol/` (new, empty until sourced) | `CobolConverterConsole`/LionDevGenNet once sourced (§6 item 7) | n/a yet |
| **Git** — instructions/prompts/plans | `.github/{instructions,prompts,Copilot_Plans}` (unchanged) | already correct | no move |
| **Git** — todo | see open question below | `T3-nnn`/`MT-nnn` registers | currently embedded in `docs/Trial-Progress/SSG-PowerShell-Trial-Progress.html` §6/§7 |
| **Release software** | `Release/` (new root) | `SsgConverter/Trials/Release/*` (`Build-Release.ps1`, `Generate-Release-Wrappers.ps1`, wrapper templates, `KnownIssues.json`) | `SsgConverter/Trials/Release/` |
| **Released verification + CC deploy tests** | `Verification/` (new root) | `SsgConverter/Trials/{Tier1Mock,RealRuntime,LiveBatch}`, `Deploy-CC-Job.ps1`, `Mock-Install-Dryrun.ps1`, `VALIDATION-PROMPT.md` | `SsgConverter/Trials/` |
| **Release area** | `E:\Repos\release_candidates` (unchanged, external) | RC packages | already correct, no move |

`SSG-Source/` (the 20 raw program files) was planned to stay a standalone **read-only** root, but the
folder no longer exists on this VM and its workspace entry was removed on 2026-10-12. The 20 sources
now live in three copies (see §6 item 2); one becomes the master, read-only, in the new layout.

**Decided (2026-10-09):**
1. **Asset registers** → `docs/Asset-Registers/`. Accepted as recommended.
2. **Todo — there is only ever one ToDo list.** The `T3-nnn`/`MT-nnn` register in
   `docs/Trial-Progress/SSG-PowerShell-Trial-Progress.html` *is* that one list (register content stays
   documentation, not `.github` config — `.github` keeps the process instructions only, per the
   original recommendation). **New requirement, not previously tracked:** Trial 1 (AMT172) and Trial 2
   (AMT175) each have their own bug/gap log that has never been amalgamated into this one register —
   e.g. AMT172's 17-entry Bug Log in `AMT172-Setup-Guide.html`. Some entries are expected to be
   redundant or superseded now (laptop-era, pre-AMT177). Logged as **MT-029** in the live tracker:
   review each Trial 1/2 entry and port forward only what's still live (as `T3-nnn`/`MT-nnn`), marking
   the rest explicitly superseded rather than dropping them silently. This is a prerequisite for
   closing out the §7 asset-register deliverable, not just a layout nicety — the cross-trial register
   currently *describes* Trial 1/2 issues narratively without this reconciliation.

**Build approach — start fresh, not a move (decided 2026-10-09, B2).** Create the new folders empty and
bring in only the routines and proven processes we choose to reuse, adapting each as it comes in.
`Trial3/` and `SsgConverter/` are **not** moved, renamed or restructured: they keep running
(MT-019/MT-021, weekly `/ssg-release`) and stay as read-only reference sources. Adapting Trial 3 in
place was judged more problematic than copying selectively. Reused items are recorded in the asset
register (source path, date copied, what was changed) so provenance stays traceable. Because nothing
existing is touched, the `.code-workspace` roots, `pipeline.config.json` paths and `applyTo` globs for
Trial 3 are unaffected; the new folders get their own config and instructions as they're created.
When the new pipeline is proven end to end, Trial 3 is frozen and tagged (B3).

The "Current location" column above therefore reads "**source to copy from**", not "moves from".

## 6. Process map — getting the right tools in place

| # | Item | Status on this VM (just checked) | Action |
|---|---|---|---|
| 1 | Both new plan docs | ✅ landed in `docs/Plan/` | Keep as reference; don't fold wholesale into always-on CI (too long) — CI should point at them |
| 2 | Raw SSG/COBOL source (20 programs) | ⚠ `SSG-Source/` workspace root points at a **missing** folder. Copies exist in `SsgConverter/Examples/Input`, `Trial3/SSGConverter_Input`, `release_candidates/release20261002-rc.01/2_OriginalSource` | pick one master copy for the new layout; dead workspace root **removed 2026-10-12** |
| 3 | Runstreams (`RunsPrd`, ~1080 files, cp1252) | ⚠ **not on this VM, but exist on AMT172** (reported 2026-10-12): `C:\Amt\MainframeSource\Codedrop 2025\RunsPrd\`, 1,080 files, 7.37 MB, includes `ASSURFED_F999RUN_VIRM01_CO(P).TXT` | transfer via git (see §9); then experiment E1 |
| 4 | Shared copybooks (`CopyPrd`) | ⚠ **not on this VM, but exist on AMT172** (reported): `Codedrop 2025\CopyPrd\`, 3,193 real files, 76 MB. Only `ARCHIINSERT` of the SSG utilities includes any copybook; the other sources have no `COPY` or `#INCLUDE` | transfer; MT-002's copybook worry is largely moot for the 20 programs |
| 5 | `SsgConverter` (SSG→PS1) | ✅ built, verified, 20/20 clean | none |
| 6 | `EclConverterConsole.exe` / source | ✅ binary in `E:\Repos\AMT\MigrationTools\EclConverterConsole\` (2026-10-07). **Source now on the VM** (2026-10-12): `E:\Repos\amt-go-net-ref\Migration Tools\EclConverter` | pin a version; run experiment E1 |
| 7 | `CobolConverterConsole.exe` / LionDevGenNet | ✅ **built 2026-10-12** from R&D `develop`: `E:\Repos\amt-go-net-ref\_build\CobolConverterConsole\CobolConverterConsole.exe`, version 8.0.26273.50, runs and prints usage (takes one `.settings` file). `LionDev.exe`/`LionDevGenNet.exe` in `E:\Repos\AMT\Lion\`. The installed `CobolToAmt.zip` has GUI only. | pin this build; still needs `globalCopyDir` (copybooks, MT-002) and a real `.settings` file before a conversion run |
| 8 | `AmtPsEclLib` + sibling libs (isolated copy) | ✅ `SsgConverter/Trials/RealRuntime/` | none |
| 9 | Second `CobolOS2200` CC application (Stage B) | ❌ blocked — tracked as **MT-009** | already an open ToDo, Trial 4 now depends on it directly |
| 10 | Unisys SSG/ECL/COBOL manuals | ✅ **done** — ECL (`78307949-031`), SSG (`78311784-010`, added 2026-10-12; `82252461-003` is the Extension Kit guide, not the SSG manual), plus 4 COBOL/UCOB manuals added 2026-10-09: ASCII COBOL (`78307709-002`), UCS COBOL Compiler Vol 1 (`78310448-005`), Vol 2 current/prior editions (`78310455-022`/`-021`) | none — UCOB compiler + signed-numeric evidence can now be cited to manual + page |
| 11 | Release pipeline (Scripts_SSG, release_candidates, Basepaths) | ✅ working, proven (§4F) | extend, don't rebuild |
| 12 | `find-ssg-ecl.ps1` (runstream call-site locator) | ❓ not confirmed present | locate or recreate |

**Reading:** the real blockers are now item 7 (no scriptable COBOL converter console) and item 9
(Stage B CC application). Item 6 is resolved — the ECL converter is on the VM, so experiment E1 can
run now. Item 10 is also resolved (2026-10-09, see §9) — the UCOB compiler manuals landed. Item 9
blocks live verification but not the conversion/reference-oracle work, so it can run in parallel.

## 7. Separate deliverable — asset register per trial

A cross-trial asset register (what routines/functions already exist per trial, so the incoming 50
don't trigger reinvention) is being produced alongside this epic:
[docs/Cross-Trial-Asset-Register.md](../../docs/Cross-Trial-Asset-Register.md). Trial 3 already has
a detailed register ([docs/Asset-Register.md](../../docs/Asset-Register.md)); the new document adds
Trial 1/2 and the Federale release-area assets, and cross-references rather than duplicates. Both
move to `docs/Asset-Registers/` under §5's layout, pending confirmation of that open question.

## 8. Open decisions (carried from the incoming plan, need your call)

These are the plan's own D1–D5 (§3 of `SSG4 plan-a extended`), restated because they gate the Phase-1
spike design, not because they need answering this session:

- **D1** — unit of work: one ECL invocation of an SSG/COBOL element = one manifest entry?
- **D2** — pipeline shape: SsgConverter output stays in the live route (PS1 calls `Invoke-Ssg` for
  SGS context, then `Xqt` starts the C#) rather than being cross-check-only. Plan's own finding, looks
  right, not yet tested end-to-end (experiments E1–E4, plan §6).
- **D3** — manifest `ecl` block shape (§4D above).
- **D4** — logical-name binding must match identically across generated C# `Files.cs`, PS1 file
  assignments, and fixtures.
- **D5** — one C# build per *template*, or per *invocation* (some templates are called dozens of
  times with different record layouts — e.g. CFH-COPY's 47 calls aren't all 80-byte). Open until
  experiment E3 runs. **Test-design rule added 2026-10-12:** we have no real data, only generated mock
  files. For every SSG program, prove it with **two mock file sets that differ in record length** (and
  anything else the SSG manipulates). Run SSG, convert, run on set 1 until it opens, reads and processes
  correctly, then repeat on set 2 with the changed parameters. A plain COBOL program without SSG cannot
  handle different record lengths in the same file set-up, so passing both sets is what proves the SSG
  parameterisation works, and it directly tests D5 (one build per distinct parameter set).

Plus two new ones specific to Trial 4's scale and layout:

- **D6 (new)** — do we wait for the 50 incoming programs before building the pipeline, or prove it
  on Target A (CFH-COPY) first and scale after? *Recommendation: prove on CFH-COPY first* — matches
  the plan's own phasing (§6–10) and avoids building generic machinery against programs we haven't
  seen.
- **D7 (resolved 2026-10-09)** — repository layout: **start fresh** with the §5 folders and copy in
  proven parts selectively; no move of `Trial3/` or `SsgConverter/`. See §5 and the B2 entry in §9.
- **D8 (resolved 2026-10-12)** — how SGS cards are consumed: **the same as AMT.** The cards are read
  at run time by AMT's runtime (`Invoke-Ssg` → `StartSSG` / `Add-Sgs` / `AddTo-SgsList` →
  `GetSgsValue`); no new parser or mechanism of our own. Consequence: the conversion must deliver each
  runstream's inline cards as the SGS file `Invoke-Ssg` loads (`P$SGS\<name>`); today both our ECL
  run and R&D's released scripts drop them, which is incorrect (logged as **T3-020**, MT-033 item 11). Still open under B4/D5: how the values reach the pre-built
  C# report. The assumed end-to-end model, with a worked `VIRM01_CO` example and its cards, is in
  [docs/SSG-4-Report-Execution-Model.md](../../docs/SSG-4-Report-Execution-Model.md) (draft runbook
  section).
- **D9 (decided 2026-10-12)** — LionDev environment: a **LionDev-only install at `E:\Amt`**, outside
  `Federale_InternalRelease` because that folder is replaced by each deployment. Not tied to a release number
  (install the latest AMT; record the version). Only the developer side is installed (LionDev, generator
  service, repository); the runtime (Control Center, batch controller) stays in Federale, so no second set of
  ports is needed. The generator service names `LionDevGenNet` / `LionDevNet_Generator` are reused (the old
  registrations point at the moved `z-old\AMT\Lion` and must be re-pointed). SQL: the existing instance, new
  repository database, collation `Latin1_General_BIN`; `FA_AFBUS` and `FEDERALE_*` are not touched. Built C#
  is then delivered into Federale's own C# set-up; expectation (user) is that it fits, to be proven with one
  DLL (this also tests the MT-009 assumption). Open: SQL account that may create databases.
  **Installer (found 2026-10-12):** SharePoint `Legacy Modernization Tower ICOE-Release` > AMT-versions > AMT 8.0 >
  AMT 179 > `8.0.26273.0`: `Setup.exe` (54.7 MB) + `AMT_179.dat` (259 MB) are the installer pair, the same
  pattern as the old `Setup.exe` + `AMT 178a - 260908_Build_50.dat`. `Release_8.0.26273.0.7z` (269 MB) is
  probably the same payload unpacked; `MigrationTools` (22 items) and `ExtraTools` (4) match what the old install
  already had; `YDrive_C#.7z` (25 MB) is probably the Y: drive support files for C# generation (to confirm);
  `pdb` and the `RC1..RC4` folders are not needed. Installer files go in `E:\Amt\Setup`.
  **Why the repository was never created last time (from the old `Setup.log`):** Setup ran with no
  `Lion.ini`, so "Database repository check is skipped". Order for the new install: run Setup, create
  `Lion.ini` from `Default_Lion.ini` pointing at the empty repository database, run Setup again so it checks
  and creates the repository. Setup also does a clean install ("removing all files of any previous
  installation"), so `E:\Amt` is for AMT only, and it refuses to update while `LionDevGenNet` is running.
  **Installer landed and verified (2026-10-12):** AMT172 pushed branch `amt179-installer-20261012` on
  `marky-T/177Xfer` (head `1eb0ac3`); pulled via a temporary `git worktree`, `AMT_179.dat` reassembled from its
  three 90 MiB parts, all SHA-256 match the manifest. In `E:\Amt\Setup`: `Setup.exe` (8.0.26273.0, product
  "AMT 179 - 260930", Asysco Software BV, not code-signed), `AMT_179.dat` (271,683,339 B), `YDrive_C#.7z`.
  Not run or extracted yet. **`YDrive_C#.7z` is the `Y:` drive** (6,177 files: `CSharpNet\Amt.Net`,
  `AmtLion`, `Common_lion_amt`, build props): the old generated C# projects reference
  `Y:\Amt.Net\Libraries\...` as `ProjectReference`s, so building generated C# from source needs `Y:` to point at
  the `CSharpNet` folder. There is also a `*.FileRef.csproj` variant that references prebuilt AMT DLLs in
  `Binaries\Application` (pinned to 8.0.26251.50, i.e. 178a) and needs no `Y:`. A `subst` mapping is per
  logon session, so the LionDev generator service (LocalSystem) would not see it; a persistent mapping is needed.
  Remote branch deleted from `marky-T/177Xfer` after verification (user's go-ahead). `YDrive_C#.7z`
  extracted to `E:\AMT_Y` (6,177 files; name chosen because R&D have an agent called AMTY); `Y:` is to map to
  `E:\AMT_Y\CSharpNet`. Preflight and hashes: `Conversion/LionDevSetup/{Preflight-LionDev.ps1,amt179-manifest.csv}`
  (read-only; run 2026-10-12: no blocking problems; .NET Framework 4.8, SDK 10.0.401, MSBuild from Visual Studio,
  SQL port reachable). Target framework check: the Federale hosts run `Microsoft.NETCore.App 10.0.0` and the old
  generated project targets `net10.0`, so no framework mismatch is expected.
  **SQL (2026-10-12, user-run test):** `ava` is sysadmin and may create databases. Databases on the server:
  `FEDERALE_SYSTEM`, `FEDERALE_APP`, `FA_AFBUS`, `AFBUS_2200COBOL_AMT`, `FEDERALE_REPOS` (the empty repository
  from the first attempt, left alone). The old `Lion.ini` named `FEDERALE_AFBUS_2200COBOL`, which no longer
  exists. Plan: `ava` is used only to create a new `AMT_REPOS` (collation `Latin1_General_BIN`) and a dedicated
  `LionDev` login that is `db_owner` of that database only; `Lion.ini` uses `LionDev`, not `ava`
  (`Conversion/LionDevSetup/Create-RepositoryDb.sql`, password via an environment variable, never in a file).
  **`Y:` mapping:** approved by the user. Registry value `Y:` under `HKLM\...\Session Manager\DOS Devices`
  (global, applies after a reboot, adds one value; checked first: only the default devices are there, `Y:` is
  free, no `subst` or network drives).
  **Setup pass 1 done (2026-10-12 18:47, by the user):** clean install of AMT 179 into `E:\Amt`
  (`AMTTools`, `License`, `Lion`, `Setup`; LionDev 8.0.26273.0 "AMT 179 - 260930"); "Database repository check is
  skipped" as expected (no `Lion.ini`); Federale services unchanged. `E:\Amt\Lion\Lion.ini` created from
  `Default_Lion.ini`: server `VMFEDPE08`, database `AMT_REPOS`, user `LionDev`, `DBPSSW` empty (LionDev/Setup asks
  and stores it encrypted), `LIONDEVNETSERVICENAME=LionDevNet_Generator`. The two LionDev services still point at
  the removed `E:\Repos\AMT\Lion` and must be re-pointed (elevated) before the generator can run.
  **LionDev 179 working (2026-10-13, steps done one at a time with the user):** `AMT_REPOS` created in SSMS as
  `ava` (Latin1_General_BIN, dedicated `LionDev` db_owner login); services re-pointed to `E:\Amt\Lion`
  (`sc.exe config`, still stopped); `Lion.Lic` copied from `C:\Amt\lic` (identical to the old install's);
  `Lion.ini` password typed once then stored encrypted by LionDev (empty value = "Login failed"; Setup does not
  prompt); Setup sync created the repository (level 78); `ALLOW-DECODED-LIONSOURCE` added to `Lion.ini`.
  **First pipeline output imported:** `CFH-COPY_ASCII.LionSource` (File > Import > Lion Source File, no errors)
  as application `CFHCOPYASCII`: Application Options, DMS Schema, Cobol Program `CFH-COPY`. Generation set
  `CFHCOPY_GEN` (MsSql, Vs2026, `E:\AMT_Work\Apps`, `E:\AMT_Work\Script`); default set deleted; Revision Control
  > Get Newest brought `CFH-COPY` into it (1.0); Logic Status F7: **Validated**. Remaining before Generate:
  `Y:` mapping (registry + reboot) and starting `LionDevNet_Generator` (elevated). Pipeline notes: the
  converter writes `<DESCRIPTION=NEW APPLICATION>` into every `.LionSource` (a poor default name; could be set
  in the pipeline); a stale "(Default from loading source)" caption persisted until Get Newest was run.
  **First C# and DLL from real SGS cards (2026-10-13 01:52):** after the reboot (`Y:` now global), the generator
  service was replaced by the window version (`LionDevGenNet.exe` as an application, so messages are visible;
  one generator at a time). A Whole System request first failed with "Application options object ... See Revision
  Control" until **Get newest** was also run on the **System > Application** object (every imported object needs
  it in a new generation set; DMS Database tab was empty). Then: "Generating Cobol Program ... Revision 1.0 Done",
  "Generated: 1 Not Generated: 0", licence "Licensed to Avanade ... Site-license, expires 01 January 2028", full
  version 8.0.26273.0, compiler Roslyn, "NO REO NEEDED". Output: `E:\AMT_Work\Apps\Development\Programs\Cfh_Copy`
  (net10.0, `Y:\Amt.Net\...` project references, 10 `Fd_Rec1n`/`Fd_Rec2n` field records, `Fd_Recin`
  `AmtVarAlpha(500)`, `Fd_Recout` `AmtVarAlpha(135)`, `m_Fixed1.InitialValue = "TAX-CLASIQ"`) and the built
  `E:\AMT_Work\Apps\Binaries\Programs\CFH_COPY.dll` (24,736 B) plus `CFHCOPYASCII.Application.dll` and
  `.Database.dll`. **This is the first end-to-end conversion of a program through SSG expansion with the
  runstream's real cards, COBOL, LionSource, LionDev and C# to a DLL.** Not yet run.

  **BaseYear fix (2026-10-13):** LionDev's Options screen crashed ("un-representable DateTime") because the COBOL
  converter writes `BaseYear=0`. `Invoke-CobolConversion.ps1` now passes `-BaseYear` (default **1957**, the LINC
  base year given by the owner; only a year can be stored); the imported application was patched in `REVDATA`
  (`OBJTYPE=123`, `LINENR=1`), the Options screen opens, and the program was regenerated (T3-024).
  **First run on mock data, PASS (2026-10-13 09:33):** `CFH_COPY.dll` ran to exit 0 through an isolated mock AMT
  system (`AMT_MOCKSYS` + `AMT_MOCKAPP`, a mock file controller on port 18132, `MockSystemTool run`) and its
  output (25 records, 135 bytes + CRLF) is **byte-identical** to an expected file derived independently from the
  SGS cards only (`New-CopyMockTest.ps1`). Findings: AMT adds `.DAT` to logical file names (`INB` is read from
  `INB.DAT`); all file I/O needs a file controller; the application database must be kind *Internal* or the
  reorganize reports "Application or database unknown"; the machine-wide `AMTSYSTEM` points at Federale, and AMT
  tools read it from the machine scope only, so every tool is run from a copy with the mock `Sys.ini` beside it
  (one attempt reached `FEDERALE_SYSTEM` in analysis only; nothing changed). Recipe: `Conversion/PROCESS.md`;
  tracker: MT-036. Still to do: the second record shape (PBDA04 700/700), the other programs, and delivery to
  Federale's C# set-up (check the `AmtSharedDataModel` version, 177a against 179).

  **Six programs in one application at LionDev 177 (2026-10-13, later):** LionDev was moved from 179 to **177**
  (`8.0.26230.0`, fresh repository `AMT_REPOS177`; the 179 install is parked for rollback) because Federale runs 177a.
  `Build-AppLionSource.ps1` builds one application `AFBUS_2200COBOL` with six programs (`ASSURFED-UTILIT-<KEY>`: CFH-COPY_ASCII,
  FUSBA2_ASCII, LECTIS_ASCII, LOADIS_ASCII, RECAP, UNLOADIS_ASCII); LionDev 177 generated all six ("Generated: 6 Not
  Generated: 0"). **177 and 177a are not the same API:** 177-generated code calls `AmtBaseCobolProgram` with a generation date
  and time that Federale's 177a runtime does not have (confirmed in their source on `main` and in the deployed DLLs), so the set
  is rebuilt against Federale's 177a DLLs (`Rebuild-SetAgainstRuntime.ps1`, flagged in source and in `REBUILT-FOR-177A.csv/.txt`).
  Results on the 177a runner (`Run-AllMockTests.ps1`): CFH-COPY_ASCII **PASS** (byte-identical to the card-derived reference);
  LECTIS, LOADIS, UNLOADIS run clean (smoke only, no reference); **FUSBA2 looped** until two converter defects were fixed
  (T3-025 `VALUE OF`, T3-026 define-scope and string arithmetic), then ran clean (revision 1.1, 5 records of 246 bytes);
  **RECAP** stops on `RSA$INIT` because its RDMS statements became comments (T3-027, deferred to the next phase by the owner).
  Re-expanding the six with the fixed converter changed only FUSBA2. The converter fixes are on disk and tested in a scratch
  copy; landing in `Build\Console` and the goldens needs an elevated shell. Merge with R&D's SsgConverter (started by Allard,
  progressed by us) is planned under MT-037 and waits for the R&D history. Delivery to `AFBUS_2200COBOL_AMT` is not started
  (MT-039; the app database also needs the reorganise step).

## 9. Decisions & corrections log

**261009 review** (after a fact-check of this epic against the VM):

- **Tool source of truth:** R&D repo
  [amt-go-net-mirror / Migration Tools](https://github.com/Avanade-Group-LMSH/amt-go-net-mirror/tree/develop/Migration%20Tools)
  (`EclConverter`, `CobolToAmt`, `PowerShellGenerator`/`Writer`, `ConverterSupport`, …). The installed
  drop is `E:\Repos\AMT` (standard AMT tools layout). Linked into the workspace as a read-only root.
- **B1 — LionDev F7 parse:** can be batched (load 1/5/10/20 programs into LionDev, F7 once). Workable
  but a bottleneck and manual; the generator processes one app at a time and one failing app blocks
  the queue (AMT172 Bugs 15–17). Check the R&D `CobolToAmt` importer (PR 15082) for a scripted route.
- **B2 — layout (supersedes §5's "move" proposal, resolves D7):** **start fresh** with the §5 target
  layout and bring parts in, rather than moving `Trial3/`/`SsgConverter/` in place. "Build on Trial 3"
  still holds for *content* — the Trial 3 pipeline and harnesses are the first things copied in — but
  Trial 3 keeps running untouched (MT-019/MT-021, weekly `/ssg-release`) until each part is proven in
  the new home. Then Trial 3 is frozen as a reference.
- **B3 — baseline:** once one program runs end to end, stop pulling new tool releases; cut and tag
  the pipeline routines and record the pinned AMT version + tool build + R&D commit.
- **B4 / D5 — build granularity:** revised recommendation — one C# build per **distinct SGS
  parameter set** (de-duplicated across call sites), not per call site and not one-per-template with
  runtime parameters. Reason: SSG values such as record lengths are generation-time and are baked into
  the COBOL; making them runtime parameters breaks the generation-time/runtime rule (§3). Confirm the
  real count of distinct parameter sets once runstreams are available.
- **C1 — tools in a controlled space:** `E:\Repos\AMT` linked to the workspace. Pinned copies of the
  tools actually used will go into the new layout's tools folder with a version manifest (binary
  storage policy — git LFS vs outside git — to decide).
- **Trial 1/2 asset library:** export prompt
  [docs/Plan/export-trial-asset-library.prompt.md](../../docs/Plan/export-trial-asset-library.prompt.md)
  runs in the AMT172/AMT175 workspaces, packages our builds (docs/runbooks/todo/issues, pipelines,
  prompts, instructions, plans) with an asset register, and transfers via `marky-T/177Xfer`. On this VM
  it lands in a library folder (`docs/Reference-Trials/` in §5) and feeds MT-029.
- **Landed 2026-10-11:** both libraries pulled from `marky-T/177Xfer`
  (`asset-library-AMT172-20261010` / `asset-library-AMT175-20261010`, via `git worktree` so the repo's
  own dirty `test-release-20261002` branch wasn't touched) into
  `docs/Reference-Trials/AssetLibrary-{AMT172,AMT175}-20261010/` — 708 + 891 files, register row
  counts verified against files on disk. Each includes its own `02-todo-issues/*.todo.extract.md`
  (done + open items pulled from checkboxes/status badges) — this is the direct input for **MT-029**
  (amalgamate Trial 1/2 ToDo items into the one list). **Notably, `07-other` in both libraries carries
  the `CFH-COPY-Trial11` C# source** (`Assurfed_Utilit_Cfh_Copy.Core.cs`/`.csproj`) — this is Target A's
  prior C# build referenced in §4C, not generic clutter; it shouldn't stay filed as `unknown`/`07-other`
  once the new layout's `Conversion/` exists.
- **UCOB/ACOB manual gap closed (2026-10-09):** 4 COBOL/UCOB compiler manuals added to
  `docs/Reference Docs/` and converted to `.md` via `pdftotext -layout` (same method as the existing
  manuals): ASCII COBOL Reference (`78307709-002`), UCS COBOL Compiler Vol 1: Statements
  (`78310448-005`), Vol 2: Compiler and System Interface — current edition (`78310455-022`) and prior
  2018 edition (`78310455-021`, kept in case an older Federale platform matches it). Resolves process-map
  item 10 for real this time, and gives the plan's open "signed-numeric/overpunch" and "UCOB vs ACOB"
  evidence items a manual to cite.
- **R&D tool source cloned (2026-10-12):** the authoritative repo is Azure DevOps
  `avanade-lt-coe/AMT_Products/_git/amt-go-net` (the earlier GitHub `amt-go-net-mirror` is a mirror).
  A shallow, blob-less sparse clone of branch `develop` (commit `50d4717`, 2026-10-09) is at
  `E:\Repos\amt-go-net-ref`, checked out for `Migration Tools` (about 30 MB, 33 tools) plus `Migration`
  (prefab and routines). It is outside `SsgTrial`, read-only by convention, and added to the workspace.
  Findings:
  - **All tools fit** (30 MB), so no need to pick a minimum set; the `.sln` and `.lutconfig` files are
    Visual Studio and test-runner files, not needed to read or build individual projects.
  - **The tools are not standalone.** Projects reference outside `Migration Tools` (`Amt.Net\libraries`,
    `CmdLets`, `migration\CobolPrefab`, `lionroutines`). Building the COBOL converter may need more of the
    repo; `Amt.Net` is 8,623 files, so fetch only the projects a build actually asks for.
  - **Our SsgConverter has drifted only slightly.** 17 of 20 library files are identical to R&D's
    `develop`; ours differs in `SymstreamProcessor.cs` (+149/-34), `SymstreamExpressionParser.cs`
    (+63/-33) and `SymstreamExpressionMigrator.cs` (+15/-15). Those diffs are our fixes and are the
    content to contribute back to R&D. Console: `Program.cs` and `Os2200ContentConverter.cs` differ.
  - **MT-004 is explained.** R&D's console uses plain `ProjectReference`s to sibling tools; our copy was
    extracted from a drop, hence `$(SsgDeps)`.
  - **`AmtPsEclLib.psm1` has moved on.** R&D's is 16,039 lines against our 15,701 (the AMT177 isolated
    copy). The authoritative source is `Migration Tools\EclConverter\CmdLets`.
  - **Contributing back is deferred (decided 2026-10-12).** Include the three library files and the two
    console files (`Program.cs` +23/-6, `Os2200ContentConverter.cs` +13/-2), but **do not push until our
    initial three conversion runs are done**, in case they need more changes. At that point we pick a
    new branch name off `develop` (R&D uses `feature/<team>/<topic>` and `release/amt1nn`) and R&D
    reviews through a PR. Nothing has been pushed.
  - **To do before raising that PR (revisit after the initial conversion runs):** compare our five
    changed files against R&D's `release/amt177` and `release/amt179` as well as `develop`. PR 11350 on
    `release/amt177` moved the SSG code into its own `SsgConverter` project and renamed the namespace
    (`Ecl.Symstream` to `Ecl.SsgConverter`), so the lines differ. The check shows whether R&D already
    fixed the same problems and which line they want ours on. Read-only on the clone, no push needed.
  - **COBOL converter console built (2026-10-12).** `CobolConverterConsole` 8.0.26273.50 builds clean
    (0 errors, 0 warnings) from the sparse clone into `E:\Repos\amt-go-net-ref\_build\CobolConverterConsole`.
    NuGet needed no credentials. It took extra sparse folders `Amt.Net/libraries/libs`,
    `Amt.Net/libraries/Asysco.Amt.AmtSharedDataModel`, `AmtLion/Lion/LionRepository` and
    `AmtLion/Lion/VsGenerator`, plus build flags `-p:SignAssembly=false -p:DelaySign=false` because the
    strong-name `.snk` keys are not in the repo (local build only; the resulting DLLs are unsigned).
    Not yet run on a real conversion.
  - **First COBOL conversion run done (2026-10-12).** The new console converted the MONTANT candidate
    (`Trial3/candidates/trial-03-montant`, already-expanded COBOL, no `COPY` statements) to a
    `.LionSource`: exit 0, 0 errors, 6 warnings, 6.5 KB. Evidence is in `_scratch/cobol-run1/`
    (settings, input, output, logs); the settings file is Trial 3's `trial-03-montant.settings` with
    paths changed and `GlobalCopyDir` empty. Findings:
    - **Prefab files:** the converter looks in `Y:\Migration\CobolPrefab` (R&D's drive), then in
      `<current directory>\LionRoutines\` (a fallback that uses the wrong subfolder name, an R&D bug
      worth reporting). `Y:` is just R&D's repo root mapped as a drive (the repo has `Migration\CobolPrefab`
      at its top level), a common AMT folder convention. **A `Y:` drive is not required for SSG-4:** we
      copy `Migration\CobolPrefab\*` into `<run folder>\LionRoutines\` and run from that folder. If a tool
      ever insists on `Y:`, `subst Y: E:\Repos\amt-go-net-ref` is the one-line alternative. The Reference
      Docs have no mention of the `Y:` drive or prefab files, so they give no further steer.
    - **Bug 14 reproduces in the new build:** the object name in the `.LionSource` is the file name
      `ASSURFED_UTILIT_MONTANT_SIGNE(P)`, not `PROGRAM-ID. MONTANT`. The existing rule stands: the
      candidate file name must equal the PROGRAM-ID before import.
    - **Header is the old format** (`EXPORT FILE VERSION=6`, date 2009-01-01), so AMT172 Bug 13
      (`BaseYear=0` crashes LionDev options) is expected to recur on import.
    - **Warnings that are source facts, not converter faults:** `REDEFINES SIZE MISMATCH` at lines 25
      and 30 (11 bytes redefining 80) is in MONTANT's own stub parameters.
    - **Exit codes:** the console returns 0 for warnings and 1 for errors. An earlier `-1` was an
      artefact of piping its output through PowerShell, so always capture with `Start-Process` or
      redirect rather than `| Select-Object`.
    - **Regression baseline exists on AMT172 (corrects an earlier statement here).** Our VM has no
      earlier `.LionSource`, but AMT172 reports 11 outputs on disk, for example `trial-03` MONTANT at
      6,507 B against our 6,578 B from the new build. Getting those files lets us compare the two console
      builds on the same input (AMT172 used 8.0.26125.50 and 8.0.26209.50; ours is 8.0.26273.50).
    - **Carry forward to the release README** (the one delivered with each release): Bug 14 behaviour,
      that the object name in a converted `.LionSource` is the file name, and the file name must equal
      the `PROGRAM-ID`, so the reader understands the formats. Also the old `EXPORT FILE VERSION=6` /
      2009 header.
    - **Carry forward to the runbook, later:** the console warnings seen on a clean run (customer
      settings not specified, XML comment elements in the macros file, `REDEFINES SIZE MISMATCH`).
      It is too early to write the runbook; first we work out the process.
  - **ECL runstreams: found on AMT172 (2026-10-12), not yet transferred.** The AMT172 session reports
    (not yet verified here):
    - **`RunsPrd`:** 1,080 files; 1,049 have `@SSG`, `@ASG`, `@USE` or `@XQT` lines; `@SSG` is in 291.
      17 distinct `*UTILIT` templates are called: CFH-COPY 47 calls in 37 runstreams, BABA 121,
      ARCHIFUSION 60, ARCHITAB2 60, FUSBA 32, CHABAN 30, RECAP 28, TABAN 23, SCAN 19, CONDIS2 18,
      TAPELD 14, LOADIS 10, UNLOADIS 5, FUSBA2 4, and CHAB100, LECTIS, EXTEUR 1 each.
    - **Not among our 20:** ARCHIFUSION and ARCHITAB2 (60 calls each) have no converted program here,
      and ARCHISEPARE and ARCHIFORMAT do not appear among the called templates. **Parked (2026-10-12):**
      the counts come from regex matches on `@SSG` lines in the AMT172 report and in the incoming plan
      (§4), not from a reading of the calling runstreams. Resolve it when we hit it, once `RunsPrd` is
      on this VM and we can see which runstream calls what.
    - **ECL was never converted.** The staged `ecl` outputs are 16 placeholder files of 92 to 101 bytes
      (a header comment only). No built `EclConverterConsole` was found there, only source. The Tier-1
      oracles stand in for `@USE` with `assign.json`. This confirms the gap, and it is the first time
      the ECL converter will actually be run.
    - **`find-ssg-ecl.ps1`** finds program names only, not the SGS parameter cards, and covers 13
      programs. A parameter-card parser is new work (plan Phase 3).
    - **`SSG Prd`** holds 43 SSG files on AMT172, against the 20 we have. **Scope decision
      (2026-10-12): only the 20 SSG/ECL/COBOL programs are the delivery and release requirement.** The 43
      are not a target. The earlier 16 can be converted to prove the pipeline and may pave the way for the
      next ~50 (to be confirmed), but they are not release deliverables. MT-003's "original 36 files"
      concern therefore does not widen the scope.
  - **Record-length proof was never done through SSG.** Only CFH-COPY was tried at a second record
    length (120), and it was done by editing the generated C# (`m_RecordSize = 120` in
    `Assurfed_Utilit_Cfh_Copy.Files.cs`), with a `.orig-80only.bak` backup, no 120-byte input file and
    no recorded result. So the `CFH-COPY-Trial11` C# is **not pure converter output**; treat it as
    hand-edited when we use it as Target A. No program has been run with the real `VIRM01_CO` shape
    (500-byte input, 135-byte output). This is the gap the two-mock-set rule in D5 closes.
  - **Copybooks:** only `ARCHIINSERT` includes any (`999-ESQL-ERR`, `ESQL-INVOKE`, `ESQL-USE`,
    `ESQL-USE-DYN`, `WS-ESQL-VAR`) and it has no `.settings` file. The `ssg-stub.macros.xml` entries
    (`FILLUN`, `FILLDEU`, `FIL1`, `FIL2`, `PAS`) stand in for bare SSG tokens, not for copybooks.
  - **Settings:** 17 `trial-NN` and 4 `trial3-*` files; all use `Env=4096`, `UseCobolAnalyser=true`,
    `DontIncludeFolderNames=true`. 11 have a `.LionSource` on disk; 9 do not; `trial3-archisepare.settings`
    is not valid JSON. Last `trial-05-lectis` log run had 16 error hits against 56 to 71 before, so
    LECTIS conversion was still being fixed.
  - **Not checked by AMT172:** the 2 UNKNOWN job logs, and per-trial error counts in the conversion logs.
    AMT175 was not asked. The 17 DONE versus 18 DONE count difference is not worth chasing (decided
    2026-10-12); we know where the bulk of the work stands.
  - **LionDev repository on this VM is probably empty (2026-10-12, read-only check).** `Lion.ini`
    points LionDev at SQL Server `VMFEDPE08`, repository `FEDERALE_REPOS`. Its own header says that
    database was created **empty** on 2026-09-21, because the Setup/"Sync Repository" tooling that builds
    the schema was not available. `LionDevGenNet` and `LionDevNet_Generator` are stopped. A schema check
    failed at login (`VMFEDPE08\MTRUMAN` is refused by SQL Server), so the current state is unconfirmed.
    The LionDev import step therefore needs: a working repository (schema built) or a different one,
    SQL access, and a decision that keeps it clear of the live `FA_AFBUS` and `FEDERALE_*` databases.
    Nothing was changed.
  - **AMT172 source pack reviewed (2026-10-12), not yet pushed.** Staged as branch
    `ssg4-source-pack-20261012` on `marky-T/177Xfer`: 4,438 files, 84.4 MiB, every file hash-checked
    against its source, `MANIFEST.csv` and a `* -text` `.gitattributes` included. Contents: `RunsPrd`
    1,080, `CopyPrd` 3,193, `SSG Prd` 43, 11 `.LionSource` runs (87 files), CFH-COPY Trial11 (23),
    CC results (12). Review findings:
    - **Unedited CFH-COPY C# exists on this VM.** AMT172 could not produce a diff because it has no
      unedited copy. `E:\Repos\AMT\Apps\AFBUS_2200COBOL_AMT\Development\Programs\Assurfed_Utilit_Cfh_Copy`
      (dated 2026-09-25) has no record-size parameter at all, while the AMT172 Trial11 copy has
      `m_RecordSize = 120` and a `recordSize = 80` constructor argument. 6 of the 9 shared files differ
      (`Core`, main, `Files`, `Info`, `Fd_Recin`, `Fd_Recout`); the other 3 are identical. This gives
      the exact hand-edit diff for Target A. It also suggests whoever built `AFBUS_2200COBOL_AMT` had a
      working LionDev generation of 8 programs, relevant to MT-009.
    - **The 120-byte edit probably never ran in Control Center.** AMT172's `.orig-80only.bak` is
      identical to the dll deployed there, so the deployed job is the 80-byte build. Inference, not
      checked.
    - **Template version risk (corrected 2026-10-12).** Our 20 SSG sources come from
      `2026-07-07_SSG\CreatingCobol`; `SSG Prd` and the runstreams are from `Codedrop 2025`. A hash
      comparison on the landed pack shows only `ARCHIFORMAT`, `ARCHISEPARE` and `CFH-COPY` are identical.
      But 11 of the other 17 (`BABA`, `CHAB100`, `CHABAN`, `CONDIS2`, `EXTEUR`, `FUSBA`, `FUSBA2`,
      `LOADIS_MULTI`, `RECAP`, `TABAN`, `UNLOADIS_MULTI`) have no name match in `SSG Prd` at all, so they
      are simply not in that drop, not a drifted version; the rest are different variants (for example
      `SCAN_ASCII` against `SCAN-VAR_ASCII`). There is no evidence of version drift. The real mapping is
      the one the ECL converter uses: `*UTILIT.<name>/ASCII` in a runstream looks up a skeleton called
      `UTILIT_<name>_ASCII`, which matches our `<name>_ASCII` files.
    - **Which of the 20 have a real runstream call** (template-name matches): `CFH-COPY`, `BABA`,
      `FUSBA`, `CHABAN`, `RECAP`, `TABAN`, `CONDIS2`, `SCAN`, `TAPELD`, `FUSBA2`, `CHAB100`, `EXTEUR`,
      `LECTIS`, and `LOADIS` / `UNLOADIS` (called under the shorter names, which also cover the
      `_MULTI` variants). `ARCHIFORMAT` and `ARCHISEPARE` have **no call in any of the 1,080
      runstreams**, so their ECL will be synthetic, like MONTANT.
    - **SSG templates can generate ECL.** `ARCHIFUSION` and `ARCHITAB2` (not in our 20) are SSG
      templates that produce ECL only (`#ASG`, `#USE`, `*IF`, `*SET`, no COBOL), each called in 3
      runstreams, with source in `Code_Source_20260804\...\RunPrd\ASSURFED_UTILIT\` (878 B and 2,489 B).
      This is real evidence for the plan's "Generated ECL" box. Parked until we hit it.
    - **"DONE" in `cc-final-results.txt` only means no `Error:` line in the job log**, not that
      outputs were compared. Same limitation as SSG-3 generally, so it is not a new concern.
    - **The two UNKNOWN failures** are `EXTEUR` (`Cannot convert value "NONE" to type "System.Int32"`,
      line 158) and `FUSBA_ASCII` (`Cannot index into a null array` in `Define_limpara`, line 50); both
      are already tracked (MT-012, T3-012).
    - **Duplicate in the pack:** the 22 CFH-COPY Trial11 files are byte-identical to `177Xfer` `main`
      (commit 65c9dc6), which we already hold.
    - **Converter builds:** no log records which of the two builds (8.0.26125.50 and 8.0.26209.50) made
      which run; runs span 2026-06-18 to 2026-08-21, so probably both.
    - **Copybooks for `ARCHIINSERT`:** `ESQL-INVOKE` and `ESQL-USE` exist as `TST_COMMONS_*_UCS.txt`
      (82 B and 244 B); `ESQL-USE-DYN` has no file; `999-ESQL-ERR` and `WS-ESQL-VAR` have only near
      matches. `ARCHIINSERT` is not one of our 20, so this is parked.
    - **Decisions (2026-10-12):** `marky-T/177Xfer` is **private** (confirmed). The 22 CFH-COPY Trial11
      files are dropped from the pack (duplicates of `177Xfer` `main`) and only the 18 KB `.bak` is
      kept. Extras to add: all candidate folders, macros, `ARCHIFUSION` and `ARCHITAB2` source, the 6
      other `.LionSource` outputs, and a SHA-256 list of our 20 SSG originals. GO given to AMT172;
      at the time of writing the branch had not yet appeared on the remote.
    - **Pack scope cut (2026-10-12, same day):** 4,438 files was too many (`CopyPrd` 3,193 files = 72% of
      files, 88% of bytes). Revised: drop `CopyPrd` (only `ARCHIINSERT` uses copybooks and it is not in
      our 20; the files stay on AMT172); cut `RunsPrd` to runstreams that call one of our 20 templates
      (about 250, including `VIRM01_CO`) plus a `RunsPrd-INDEX.csv` of all 1,080 (name, size, templates
      called); keep the rest. Target about 650 files. My earlier request for all of `CopyPrd` was a mistake.
    - **Landing plan on this VM:** pull the branch with `git worktree` (as for the asset libraries) and
      copy it to a folder **outside the SsgTrial repo**, `E:\Repos\ssg4-source`, not into `docs/`. It is
      84 MB of client copybooks and runstreams and has no place in this repo's history. Keep
      `MANIFEST.csv` beside it so every file's source and hash stay traceable.
    - **Pack landed and verified (2026-10-12).** Commit `7d5f1dd` on branch `ssg4-source-pack-20261012`:
      338 files, 5.4 MiB, copied to `E:\Repos\ssg4-source` (outside this repo): `01-RunsPrd` 170
      runstreams, `03-SSG-Prd` 43, `04-LionSource` 87, `05-CFH-COPY-Trial11` 23, `06-CC-results` 12, plus
      `MANIFEST.csv`, `RunsPrd-INDEX.csv` (all 1,080 files) and `.gitattributes`. 0 missing, 0 hash
      mismatches against the manifest. **Not in the pack** although requested: candidate folders,
      macros, `ARCHIFUSION`/`ARCHITAB2` source, the 6 other `.LionSource`, the SHA list. `CFH-COPY`
      Trial11 was kept (23 files, not trimmed to the `.bak`). `VIRM01_CO` is there with seven sibling
      `VIRM01_*` runstreams.
  - **Experiment E1 done (2026-10-12): the ECL converter works on a real runstream.**
    `EclConverterConsole /INPUTFILE:<runstream> /OUTPUT:<folder>` (installed build, 2026-10-07) converted
    `ASSURFED_F999RUN_VIRM01_CO(P).TXT` to a 25 KB PowerShell script on `AmtPsEclLib` (evidence in
    `_scratch/ecl-run1/`). It also writes `obsolete-codes.md` and an SSG stub. Findings:
    - **D2 is confirmed by the output.** The `@SSG` call becomes
      `Invoke-Ssg -Options "IA" -Skeleton "../../UTILIT_CFH-COPY_ASCII" -SgsFile "P$SGS\VIRM01"`, then
      `Asg`, `Use`, `Xqt "R, W" (".CFH-COPY")`, `Free`. So the PS1 calls the converted SSG skeleton for
      the SGS context and then starts the report, as the plan's D2 expected.
    - **The SSG skeleton is not converted by a single-file run.** It wrote `UTILIT_CFH-COPY_ASCII.ps1` as
      a 4-line stub: "NOT CONVERTED: source file not found in delivery". **Corrected after folder-mode
      runs (2026-10-12):** the converter finds a skeleton through its `RunstreamIndex`, built from the
      input folder's file names with the extension removed. `*UTILIT.CFH-COPY/ASCII` becomes the suffix
      `_UTILIT_CFH-COPY_ASCII`, and a file is matched only if its name **ends** with that suffix. The
      runstreams and SSG Prd files end in `(P)` (`..._VIRM01_CO(P).TXT`), so nothing matched. In a scratch
      copy with `(P)` removed from every name and our SSG sources added as
      `ASSURFED_UTILIT_<name>.TXT`, the skeletons were found: 3 of 17 converted (`CONDIS2_ASCII`,
      `EXTEUR`, `LECTIS_ASCII`), 14 failed inside the converter with `This is unexpected. DirectiveId:
      End` at line 2 or 5 (evidence in `_scratch/ecl-run4/`).
    - **Why 14 of 17 fail: the ECL converter bundles an older SsgConverter library.** Its
      `SsgConverter.dll` (44,544 B, 2026-10-07) is not ours (51,200 B, 2026-09-30). The failing sources
      open with `*DEFINE ... *END` blocks; the 3 that convert open with comments or `*SET`. Our
      standalone converter handles all 20, so our library changes (the +149/-34 line diff in
      `SymstreamProcessor.cs`) are what is missing. This is direct evidence that those fixes matter for
      R&D, and the strongest reason to contribute them back after the initial runs.
    - **`@ADD` includes: the other 910 runstreams will not help (corrects an earlier note).** Folder mode
      reports 5,235 unresolved `@ADD` lines for 305 distinct targets, and none of them exists anywhere in
      `RunsPrd` (all 1,080 files are `ASSURFED_*` or `AFLINC_*`). They live in other OS 2200 files that
      were never part of the drop: `F999TRANSF` (69 targets), `F999SYM` (61), `F999CONTROLE` (59),
      `F999STAR` (47), `F999PARA` (31), `SYS$*RUNS` (6, including `REPRISE` and `RESTART`, used 3,619
      times), the `CP*` files, `ESYS$AF*COM` and `*UTILIT`.
    - **The released app already holds converted versions of them (user pointed this out; verified
      2026-10-12).** `E:\Repos\Federale_InternalRelease\Scripts` has 2,796 files under `ASSURFED_F999`
      (`CONTROLE` 149, `PARA` 56, `RUN` 802, `RUN-D` 247, `STAR` 571, `SYM` 425, `TRANSF` 543) plus
      `SYS$_RUNS` (`REPRISE`, `REPDEL`, `RESTART`), `ASSURFED_UTILIT` (94, including `TRANSEXCEL` and
      converted skeletons such as `CFH-COPY_ASCII`, `BABA_ASCII`), `ESYS$AF_COM` and others. A name check
      finds **215 of the 305 unresolved targets** there as converted scripts; 90 are not (for example
      `CPAFPD03.DEPENSE`, `CPCCSA09.ACCEPT`). The original sources can be supplied if needed.
    - **R&D has already converted this runstream.** `Scripts\ASSURFED_F999\RUN\ASSURFED_F999RUN_VIRM01_CO.ps1`
      (982 lines, 2026-09-08) has the same `Invoke-Ssg` call as ours but with
      `-Skeleton "../../ASSURFED_UTILIT/UTILIT_CFH-COPY_ASCII"`; ours is 767 lines because 5,235 `@ADD`
      lines are TODO comments in our run. So the ECL layer for these runstreams was delivered by R&D
      already. **Open question:** what do we still need the ECL converter for, beyond the two programs with
      no runstream (`ARCHIFORMAT`, `ARCHISEPARE`) and a cross-check? To be answered before more ECL work.
    - **SSG and ECL converters are not intertwined (checked in R&D's source).** `EclConverter.csproj`
      references the `SsgConverter` library project; that library depends only on `PowerShellGenerator`
      and `ConverterSupport` (no ECL types); `EclConverter.cs` calls `SymstreamProcessor.Convert` through an
      `Os2200SsgContentConverter`. All 20 hunks of our `SymstreamProcessor.cs` diff sit under the one
      `namespace Ecl.SsgConverter`. So our library fixes flow into the ECL converter on a rebuild; the
      installed ECL console just ships an older build.
    - **Tested 2026-10-12: with our three files the ECL converter converts all 17 skeletons.** Three
      builds over the same input (170 runstreams plus our 17 SSG sources, `(P)` stripped):
      | Build | SSG external conversion |
      |---|---|
      | installed console (2026-10-07) | 3 succeeded, 14 errors |
      | clean build of R&D `develop` | 3 succeeded, 14 errors |
      | `develop` plus our 3 library files | **17 succeeded, 0 errors** |

      The R&D clone was not modified: builds are in `E:\Repos\amt-go-net-ref\_build\EclConverterConsole-develop`
      and, for ours, in a scratch copy `E:\Repos\amt-go-net-ours\_build\EclConverterConsole-ours`. Our files
      compiled with no change to the ECL adapter, so no interface breakage. Comparing the 17 skeletons with
      our standalone converter's goldens (comments and blank lines ignored), the **only** difference is
      `Fin` calls: the standalone output ends with `Fin` (a skeleton run as its own job), while the ECL
      converter leaves it out of a skeleton called from a runstream (sensible, because `Fin` inside a
      called skeleton would end the whole job). All other code lines match. Only one stub remains:
      `*UTILIT.TRANSEXCEL`, which is not one of our 17 and is already converted in the released app.
      This is the evidence for the R&D contribution, and it shows one library can serve both consoles.
    - **A pre-existing R&D bug found on the way:** the generated runstream `ASSURFED_F999RUN_FPGA01.ps1`
      has a PowerShell parse error (`Unexpected token '.DES'`) in all three builds, so it is not caused by
      our files. Worth passing to R&D; of 190 generated scripts it is the only one that does not parse.
    - **R&D questions now live in one place: tracker item MT-033** (9 items: our fixes, the `Fin`
      question, the FPGA01 parse bug, the prefab fallback bug, signing keys, the `(P)` suffix, scripted
      LionDev parse, the `@PRT` option, and the two old notes from the fix log). Add new ones there.
    - **ID collision fixed (2026-10-12).** The tracker file only defines MT-001 to MT-022; other
      documents already use MT-023 to MT-028 for the live batch runner (MT-025), ComScript revert
      (MT-024), French-text rule (MT-028) and others, and those rows are missing from the tracker. My
      four items from 2026-10-09/11 were renumbered to MT-029 to MT-032 and R&D questions took MT-033.
      Open housekeeping: the tracker file `docs/SSG-PowerShell-Trial-Progress.html` is **not tracked in
      git** (`??`), so nothing is recoverable from history, and its MT-023 to MT-028 rows need restoring
      from wherever they were written.
    - **Fin in skeletons:** no change of ours adds `Fin`; it is R&D's `EclMigrateOs2200` auto-append, and the
      ECL path suppresses it for partial runstreams. Recorded in the `@FIN` row of
      `SsgConverter/SsgConverter-COPILOT.md` and as item 2 of MT-033.
    - **Reference audit after the renumbering (2026-10-12).** 73 references to MT-023..MT-033 were checked
      across the docs (including the AMT177 tracker HTML), `.github` prompts, instructions and plans,
      `SsgConverter` (release tooling, LiveBatch, `KnownIssues.json`) and `Trial3`. The IDs other documents
      own are consistent with each other and untouched: MT-023 (BatchController marks a job Error on any
      console output), MT-024 (ComScript RID fix reverted by redeploys), MT-025 (live batch runner),
      MT-026 (job/joblog naming), MT-028 (French-text rule). MT-027 is not referenced anywhere. My items
      MT-029 to MT-033 are referenced consistently. **Resolved 2026-10-12:** rows MT-023 to MT-028 were
      restored in the tracker (reconstructed from the plans, prompts and code comments; MT-027 recorded as
      unused), so the anchors resolve. **Still open:** T3-013 to T3-019 are also missing from the tracker's
      issue register (T3-014 is not described anywhere on this VM).
    - **First COBOL conversion of the SSG-expanded programs (2026-10-12).** The 19 Tier-1 harness outputs
      were each renamed to their `PROGRAM-ID` and run through `CobolConverterConsole` 8.0.26273.50
      (evidence in `_scratch/cobol-run2/`, `summary.csv`). Of 20 programs: 9 convert with 0 errors
      (`CFH-COPY`, `CFH-COPY_ASCII`, `CHAB100_ASCII`, `CONDIS2_ASCII`, `FUSBA_ASCII`, `LOADIS_ASCII`,
      `SCAN_ASCII`, `TAPELD_ASCII`, `UNLOADIS_ASCII`), 9 have errors (`BABA_ASCII` 2, `CHABAN_ASCII` 1,
      `EXTEUR` 82, `FUSBA2_ASCII` 33, `LECTIS_ASCII` 2, `LOADIS_MULTI` 3, `RECAP` 13, `TABAN_ASCII` 6,
      `UNLOADIS_MULTI` 3), `ARCHIFORMAT` has an empty harness output, and `ARCHISEPARE`'s expanded text
      has no `PROGRAM-ID`.
    - **Most errors trace to placeholder SGS seeds, not to the converter.** In the Tier-1 seeds 133 of 312
      entries are `0` or empty. Examples: `LECTIS_ASCII` seeds `LKEY,1,1,1 = 0`, which expands to
      `02 FILLER PIC X(0)` (error 28, "Picture has illegal characters"); `CHABAN_ASCII` seeds the loop
      counts `LIST`, `NUMB` as `0`, so `03 ZCAR[*J] PIC X(80)` expands zero times and leaves `01 ZCAR.`
      with no sub-items (error 34). Same pattern for the "expected to have sub items" and "operand not
      declared" errors in `BABA_ASCII`, `FUSBA2_ASCII`, `RECAP`, `TABAN_ASCII`. Not yet explained and
      possibly genuine converter limits: `EXTEUR` "End of statement expected but REPLACE found", and
      `LOADIS_MULTI` / `UNLOADIS_MULTI` "End of statement expected but DATA found".
    - **The real SGS cards are in the runstreams.** In `VIRM01_CO` the `@SSG` line is followed by the cards,
      up to `@EOF`: `SGS`, `ASCII`, `INPUT INB,500,10`, `OUTPUT INC,135,10`,
      `FIELDIN 6,9 19,6 ...`, `FIELDOUT 11,9 20,6 ...`, `FIXE 1,10,TAX-CLASIQ`. So the missing piece is a
      parser that turns those cards into the SGS seed for a skeleton, replacing the hand-typed 0 values
      (this is the plan's Phase 3 SGS-card parser). With real values the SSG-expanded COBOL for the 15 or so
      programs that have runstream calls should have the real record lengths (500 and 135 here).
    - **SSG-expanded COBOL already exists for 19 of our 20 programs.** The Tier-1 harness
      (`SsgConverter/Trials/<P>/out/<P>.out.txt`) holds each program's expanded COBOL text (for example
      `CFH-COPY` 45 lines, `EXTEUR` 692), made with mock SGS seeds. Only `ARCHIFORMAT` is empty (0 lines).
      That text is the natural input to `CobolConverterConsole`, so the SSG to COBOL hand-off is ready to
      try.
    - **Scope as stated by the user (2026-10-12):** R&D has delivered the ECL layer for the runstreams, but
      has not touched our programs. SSG-4 must convert our programs and combine SSG, COBOL and ECL. The
      conversions still have to be run.
    - **Other warnings:** `@PRT: unrecognized option(s) 'C' ignored` twice. Sorts convert to
      `Sort-AddOutputFile`, `Sort-SetKey`, `Sort-SetRecordSize "500"`, using `AmtPsSortLib`. Statements with
      no AMT equivalent become comments tagged `OBS-*`.
    - **The SGS cards (`INPUT INB,500,10` and so on) are not in this script;** `Invoke-Ssg` reads them
      from `P$SGS\VIRM01`. Where that file's content comes from is still to find out.
  - **MT-009 stance:** do not set up a working `AFBUS_2200COBOL` on this VM (problematic last time);
    outside help only if it proves unavoidable.
  - **`E:\Repos\AMT` moved to `E:\Repos\z-old\AMT` (2026-10-12)** to clear the way for a clean LionDev set-up.
    Every `E:\Repos\AMT\...` path in this plan and in the registers now reads `E:\Repos\z-old\AMT\...`.
    Nothing in our scripts used it (checked); no running process, service binary, environment variable or
    registry value pointed at it, and the Federale services and Control Center were still healthy afterwards.
    The two stopped services `LionDevGenNet` and `LionDevNet_Generator` still point at
    `E:\Repos\AMT\Lion\LionDevGenNet.exe`, so they are stale until LionDev is reinstalled. A few empty
    folders remain under `E:\Repos\AMT\Apps\AFBUS_2200COBOL\` (Administrators-owned working folders of the
    batch controller; they cannot be deleted without elevation).
  - **Step 1 done (2026-10-12): real SGS cards through to `.LionSource`.** First scripts in the new
    layout, `Conversion/Pipeline/` (outputs kept outside the repo in `E:\Repos\ssg4-work`, as the cards
    are client data):
    - `Export-SgsCards.ps1`: reads the 170 runstreams; 371 `@SSG` calls, 359 on our converted programs
      (17 of 20; `ARCHIFORMAT`, `ARCHISEPARE` and plain `CFH-COPY` have none). Writes one card file per
      call plus `sgs-calls.csv`; joins continued cards (36 calls), flags quoted cards. Re-runs are
      byte-identical. `P$SGS\<run-id>` is unambiguous for only 48 calls: 87 runstreams make several
      calls and 124 run-ids cover 170 runstreams (`VIRM01` alone is 8), so the converter's single
      `-SgsFile "P$SGS\<run-id>"` per runstream cannot work as named (T3-020).
    - `Invoke-SsgExpansion.ps1`: runs a converted skeleton with AMT's own `AddTo-SgsList`,
      `GetSgsValue`, `CompareTypeSafe`, `RemoveFrom-SgsList`, `Sort-SgsList` (lifted unchanged from
      `AmtPsEclLib.psm1`) and the Tier-1 mock for output only. Deviations from AMT, both per the SSG
      manual: labels case-insensitive, `INFO$` filled from `@RUN` (T3-023).
    - `Invoke-CobolConversion.ps1`, `Invoke-RealCardBatch.ps1`: convert each expansion to `.LionSource`.
    - **Result, first call per program (17):** `CFH-COPY_ASCII` with the `VIRM01_CO` cards expands to
      `RECIN PIC X(500)`, `RECOUT PIC X(135)`, 10 field moves and the `TAX-CLASIQ` constant, and converts
      with 0 errors. 0 errors also for `FUSBA2`, `LECTIS`, `LOADIS`, `UNLOADIS`, `RECAP` (RECAP had 13
      with mock seeds). Fails: `BABA`, `CONDIS2` (T3-021); `FUSBA`, `SCAN` (T3-018 `-not`); `TAPELD`
      (`*DEFINE` called with `CADR`, not diagnosed); `CHABAN`, `CHAB100` (KI-2, T3-022); `TABAN` 4
      errors, `EXTEUR` 117 (REPLACE), `LOADIS_MULTI`/`UNLOADIS_MULTI` 3 (DATA) still to diagnose.
    - Most of these are converter or runtime defects that the Tier-1 mock hid (MT-020), not seed gaps.
      Evidence: `E:\Repos\ssg4-work\{sgs-cards,expanded,cobol,summary.csv}`.
    - **SGS card rules applied (2026-10-12).** `SgsCardChecks.ps1` / `Export-SgsCards.ps1` now apply SSG's
      own rules so AMT's `AddTo-SgsList` sees the cards SSG would have seen: continuation joined (36 calls),
      cut at an unquoted period (7 cards), spaces after a comma removed, `''` pairs dropped (2), last ` ;` card
      dropped. A deliberate, positive change, documented in the working-example README and checked by
      `Test-SgsCardRules.ps1` (manual examples plus real cards, PASS). Not fixable in the card: a quoted
      subfield containing a space or comma (24 cards), which stays a Warning. Re-running the real-card batch
      gave the same results as before (the first call per program contained none of the changed cards).
      Changes and warnings show at conversion time only; run-time logging is MT-034.
    - **Working example, in the repo (2026-10-12).** `Conversion/Pipeline/WorkingExample-CFH-COPY_ASCII/`: a
      22-line excerpt of `VIRM01_CO`, the pipeline run on it, and the checked-in results for every stage
      (cards, expanded COBOL, `.LionSource`). `Run-WorkingExample.ps1` regenerates and compares byte for
      byte (PASS, re-run identical). Stops at `.LionSource`: no mock data or expected output yet.

## 10. What this epic does *not* cover yet

Per-area detail (exact scripts, manifest schema diff, the E1–E4 experiment steps, the Phase 0
inventory ledger) is deliberately left out of this document — that's the next conversation, once
this epic and the asset register are reviewed.
