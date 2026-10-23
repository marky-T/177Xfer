# SSG → PowerShell Conversion Trial — Copilot Instructions

Always-on guidance for the **SsgTrial** workspace. This is the conversion/trial regime for
turning OS2200 **SSG (Symbiont Stream Generator)** source into **PowerShell**, proving the output
runs, and improving the converter. It runs on a *new VM*, separate from the live AMT application.

> Authority: this file + [docs/Asset-Register.md](../docs/Asset-Register.md) describe the **real**
> layout on this VM. Any path beginning `C:\Amt\...`, `C:\Dev\amt-go-net-net8\...`,
> `C:\Amt\Parallel\...` in older docs/prompts is **source-environment / stale** — do not treat it as
> present. (`C:\Amt` on this VM holds only a `Temp` folder of example files.)

---

## Naming: SSG-3 and SSG-4

- **SSG-4** is the shorthand for the current effort (Trial 4): converting SSG, ECL and COBOL as one
  pipeline on AMT's own converters. Plan: [Copilot_Plans/261009-trial4-epic-strategy.md](Copilot_Plans/261009-trial4-epic-strategy.md).
- **SSG-3** is the SSG-only work in `Trial3/` and `SsgConverter/` described by the rest of this file.
  It stays live (weekly `/ssg-release`, MT-019, MT-021) until SSG-4 is proven, then is frozen.
- Label anything actively used for SSG-4 as SSG-4. Do not rename existing folders or files.
- SSG-4 status (2026-10-12): R&D tool source cloned at `E:\Repos\amt-go-net-ref` (outside this repo);
  `CobolConverterConsole` built and run once on MONTANT (evidence in `_scratch/cobol-run1`); ECL
  runstreams not on this VM; the AMT172/AMT175 asset libraries are in `docs/Reference-Trials/`.

---

## Session start

On the first message of a session (unless the user says otherwise):
1. Restate the goal: **convert SSG source → PowerShell, run it in a Tier-1 mock harness, and fix
   whatever blocks it** (converter or harness), keeping the trial separate from the live AMT app.
2. State current position from the **Current status** section below and the most recent plan in
   [.github/Copilot_Plans/](Copilot_Plans/).
3. Identify which of the **three work areas** the request falls under (A / B / C, below).
4. Ask: *"Continue from <current status>, or has something changed?"* before doing work.

---

## Environment (this VM)

- Repo root: `E:\Repos\SsgTrial` (single git repo; opened as the multi-root `SsgTrial.code-workspace`
  with folders `Trial3`, `SsgConverter`, `SSG-Source`, `docs`, `.github`).
- Customization discovery relies on `chat.useCustomizationsInParentRepositories: true` (set in the
  `.code-workspace`) because `.github/` is a sibling folder, not nested inside an opened root.
- The live AMT environment (**AMT177 / FEDERALE_APP**, at `E:\Repos\Federale_InternalRelease`) is
  **separate by design**. Do **not** wire the trial into it, and do **not** modify its config, the
  `FA_AFBUS` DB, or the `ava` service account, unless explicitly asked.

---

## Core rules (guardrails)

- `SSG-Source/` is **read-only reference** — never edit files there.
- Treat every `C:\Amt\...` / `C:\Dev\amt-go-net-net8\...` path as **stale/unconfirmed**; verify on
  this VM before relying on it.
- Do **not** run Trial3's pipeline past `-ListOnly`: it needs `CobolConverterConsole.exe` and a
  `globalCopyDir` that are **not present** on this VM (ToDo MT-002). Flag this rather than faking a run.
- Do **not** "fix" SsgConverter known issues **KI-1/KI-2/KI-3** (see
  [SsgConverter/SsgConverter-COPILOT.md](../SsgConverter/SsgConverter-COPILOT.md)) without a
  confirmed failing test case.
- The prebuilt `SsgConverter/Build/Console` and `Build/Gui` binaries are verified working — no
  rebuild needed unless changing converter source (Area B).
- Prefer the repeatable harness/scripts over ad-hoc one-liners; every trial step must be idempotent
  and re-runnable to byte-identical output.
- **Diagnose before theorising — two rules bought the hard way ([T3-015](../docs/SSG-PowerShell-Trial-Progress.html#T3-015)):**
  1. **Never call a specific, named runtime error a "red herring" until you have grepped our own code
     for that exact symbol.** An error naming `$jobName_` was dismissed as vendor noise through many
     live round-trips; it was our own string-interpolation bug, stated plainly in every failure.
  2. **Elapsed-time clustering across runs is not evidence of an external timer** when every run
     shares one code path — it usually means *our* code dies at the same point. Establish where our
     code fails before attributing behaviour to a vendor component. Treat a result that contradicts
     the current theory (e.g. a timing that halves after *our* change) as falsifying it, not as a
     detail to explain away.
- When a **bug** is found or a **new pipeline function / feature** is requested, log it per
  [instructions/ssg-todo-issues.instructions.md](instructions/ssg-todo-issues.instructions.md)
  (bug → `T3-nnn`, ToDo/feature → `MT-nnn`) and record it on the
  [progress tracker](../docs/SSG-PowerShell-Trial-Progress.html) §6/§7.
- **Keep the progress tracker in step.** After a reviewed run or a proven process change, sync
  [docs/SSG-PowerShell-Trial-Progress.html](../docs/SSG-PowerShell-Trial-Progress.html) via the
  [`/ssg-update-tracker`](prompts/ssg-update-tracker.prompt.md) prompt (the closing action in the Area A/D
  instructions): §3 status/stats, §1 current-state, *Last updated*, runbooks (§5b/§5c), and any `T3-nnn`/`MT-nnn`.

---

## Work areas

| Area | Scope | Entry point (`/ssg-*` prompt) |
|------|-------|----------------------------------------|
| **A — Run trials on converted PS** | `SsgConverter/Trials/**`, Trial3 goldens | `/ssg-run-trial <Program>` |
| **B — Change the SsgConverter (C#)** | `SsgConverter/Source/**` | `/ssg-fix-converter <issue>` |
| **C — Reconvert SSG-COBOL → PS** | `SsgConverter/Examples/**`, `Trial3/manifest/**`, `Trial3/config/**` | `/ssg-reconvert <Program>` |
| **D — Run under the real AMT runtime** | `SsgConverter/Trials/RealRuntime/**` (isolated `AmtPsEclLib`); Stage A vs Stage B | `/ssg-e2e <Program>` |

Deep, per-area detail lives in area `*.instructions.md` files and prompts, rolled out per
[.github/Copilot_Plans/260909-ssg-trial-copilot-regime.md](Copilot_Plans/260909-ssg-trial-copilot-regime.md).

---

## Standard trial process (Area A — Tier-1 PowerShell trial)

Run from `SsgConverter/Trials/Tier1Mock/`. The harness mocks the AMT PowerShell runtime
(`GetSgsValue`, `DataLineOrNoStatement`, `Call-ExternalProgram`, …) so a converted `.ps1` runs with
no AMT stack.

1. **Select & orient** — pick a program (key = the `Examples/Output/<Program>.ps1` base name, e.g.
   `ARCHISEPARE`, `CFH-COPY`). Confirm `SsgConverter/Trials/<Program>/sgs-values.json` exists; if
   not, seed it from the Trial3 manifest `paramOverrides` / `conditionValues` for that program.
2. **Parse-check first** — syntax-only, no execution:
   `[System.Management.Automation.Language.Parser]::ParseFile(<path>, [ref]$null, [ref]$errs)`.
   Record the error count. A converted script must reach **0 parse errors** before it can run.
3. **Run the harness** — `.\Run-SsgPsTrial.ps1 -Program <Program> [-Diff]`. Idempotent: resets mock
   state, writes `Trials/<Program>/out/<Program>.out.txt` (and `.error.txt` on failure).
4. **Review** — emitted line count, unmocked `GetSgsValue` lookups, `Call-ExternalProgram` calls;
   with `-Diff`, compare against the matching `Trial3/candidates/*<Program>*` golden.
5. **Record result** — PASS only when parse = 0 and the diff is acceptable; otherwise record
   *blocked + root cause*. Never mark done on a script that fails to parse.
6. **Prove repeatability** — re-run twice; output must be byte-identical.

---

## Key files

| Purpose | Path |
|---------|------|
| Converter behaviour spec / warning taxonomy / KI-1..3 | [SsgConverter/SsgConverter-COPILOT.md](../SsgConverter/SsgConverter-COPILOT.md) |
| Converter console (verified) | `SsgConverter/Build/Console/SsgConverterConsole.exe` |
| Converter source (Area B) | `SsgConverter/Source/SsgConverter/` (`SymstreamProcessor.cs`, `SymstreamExpressionParser.cs`, `SymstreamExpressionMigrator.cs`) |
| Converter fix log | [SsgConverter/Fixes/SsgConverter-Fix-20260820.md](../SsgConverter/Fixes/SsgConverter-Fix-20260820.md) |
| Example input / golden output / settings | `SsgConverter/Examples/{Input,Output,Settings}/` |
| Tier-1 harness (Area A) | `SsgConverter/Trials/Tier1Mock/{Run-SsgPsTrial.ps1,SsgPsMockLib.psm1}` |
| Real-runtime Stage A (Area D) | `SsgConverter/Trials/RealRuntime/{Run-StageA.ps1, AmtPsEclLib.psm1 (isolated copy)}` · [instructions/ssg-amtcc-runbook.instructions.md](instructions/ssg-amtcc-runbook.instructions.md) |
| Trial3 pipeline | `Trial3/tools/{Run-EclPipeline.ps1,Run-EclProof.ps1}` |
| Trial3 manifest (14 programs) | `Trial3/manifest/programs.manifest.json` |
| Trial3 config (has stale paths — MT-002) | `Trial3/config/pipeline.config.json` |
| Asset inventory (ToDo MT-001.., renamed from G-n) | [docs/Asset-Register.md](../docs/Asset-Register.md) |
| Issues (`T3-nnn`) & ToDo (`MT-nnn`) registers + how to log | [docs/SSG-PowerShell-Trial-Progress.html](../docs/SSG-PowerShell-Trial-Progress.html) §6/§7 · [instructions/ssg-todo-issues.instructions.md](instructions/ssg-todo-issues.instructions.md) |

---

## Current status (2026-09-09)

- **Area A parse blocker FIXED (Area B).** Data-division/output lines were being migrated as SSG
  *expressions*; now emitted as literal strings with only `[bracket]` refs substituted. All 5 example
  outputs went **219/241/248/202/103 → 0 parse errors**; ARCHISEPARE (143 lines) and CFH-COPY (47)
  run clean in the Tier-1 harness. See [SsgConverter/Fixes/SsgConverter-Fix-20260909.md](../SsgConverter/Fixes/SsgConverter-Fix-20260909.md).
- **Landing DONE (2026-09-10).** `Reconvert-And-Verify.ps1 -Rebuild -RefreshDll -UpdateGoldens` ran
  with VS Code closed: `Build\Console` + `Build\Gui` `SsgConverter.dll` refreshed (51200) and
  `Examples\Output` goldens regenerated — all 5 parse 0, ARCHISEPARE + CFH-COPY run OK.
- **Open ToDo** (registers on the [progress tracker](../docs/SSG-PowerShell-Trial-Progress.html) §7; renamed from G-n): **MT-001** repo-scoped CI/prompts (done), **MT-002** Trial3 config
  points at a missing `CobolConverterConsole.exe` / `globalCopyDir`, **MT-003** only 5 of the original 36
  converter input files are present locally, **MT-004** `SsgConverterConsole.csproj` doesn't build
  standalone (undefined `$(SsgDeps)` + external EclConverter project refs) — library builds fine.
- **Open issue** (progress tracker §6): none blocking. **20 of 20 example programs converted, all run
  clean in Tier-1** (2026-09-30) — the trial's example set is complete: ARCHISEPARE, CFH-COPY, BABA_ASCII, CHABAN_ASCII, UNLOADIS_ASCII,
  ARCHIFORMAT, LOADIS_ASCII, UNLOADIS_MULTI, CHAB100_ASCII, LOADIS_MULTI, LECTIS_ASCII, FUSBA2_ASCII,
  CFH-COPY_ASCII, FUSBA_ASCII, RECAP, TABAN_ASCII, TAPELD_ASCII, CONDIS2_ASCII, EXTEUR, SCAN_ASCII.
  Issues fixed: T3-001
  (data-line), T3-002 (`Hdg` mock), T3-003 (`Clear-Variable`→`$name = 0`), T3-004 (`SetC` mock), T3-005
  (harness error-file lock), T3-006 (`GetSgsValue` typed-value coercion), T3-007 (Hashtable
  `.Keys`/`.ContainsKey` ETS-shadowing when a seeded key matches a real member name, e.g. `KEYS` —
  fixed via `.PSBase.*` in `SsgPsMockLib.psm1`/`Run-SsgPsTrial.ps1`), T3-008 (missing `Log-Message`
  mock primitive), T3-009 (leading-`+` `*INCREMENT` variable name, e.g. `*Increment +I ...` —
  mismatched `For` loop declare/condition; fixed in `SymstreamProcessor.cs`, independently confirmed
  by both CONDIS2_ASCII and EXTEUR).
- **Area D (real runtime) Stage A DONE for CFH-COPY (2026-09-10).** `Trials/RealRuntime/Run-StageA.ps1`
  runs the converter output against the **real** (isolated-copy) `AmtPsEclLib` with no COM/app: full
  body executes to FIN/End Job/Script Done (exit 0). The one init flag needed is
  `$global:WarningRcw2435=$false` (Initialize-scope, not module-load). Only the end-of-job COM cleanup
  (`$global:Com.RemoveNonPrintedFiles`, AmtPsEclLib L3157) remains — a Stage B concern. `Initialize`
  itself is **not** isolated (it `Add-Type`s ComScript.dll + `Connect-Application`s the live app) = Stage B.
  MT-005 covers this; drive it with `/ssg-e2e`.

