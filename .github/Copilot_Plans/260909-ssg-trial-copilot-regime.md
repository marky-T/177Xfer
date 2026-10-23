---
title: "SSG→PS Trial — Copilot Regime (CI + 3 areas + process prompts)"
date: "2026-09-09"
status: "in-progress"
owner: "Mark"
---

# Plan: Copilot regime for the SSG→PowerShell trial

Model the working regime on the AMT examples in `C:\Amt\Temp` (one always-on **CI** +
task **prompts**), but grounded in this VM's real assets. Ships incrementally: the CI is
done first; the three area instructions and the `/ssg-*` prompts follow.

## Done in this pass
- **CI (always-on):** [.github/copilot-instructions.md](../copilot-instructions.md) — session-start,
  environment, guardrails, the three-area map, the Area-A "standard trial process", key files, and
  current status.
- **Discovery fix (prior turn):** `chat.useCustomizationsInParentRepositories: true` in the
  `.code-workspace`, so `.github/**` customizations load despite `.github/` being a sibling root.

## Discovery / placement rules (apply to every file below)
- All customizations live under repo-root `.github/` (instructions in `.github/instructions/`,
  prompts in `.github/prompts/`), discovered via the parent-repo setting above.
- **Multi-root gotcha:** `applyTo` globs match relative to each opened folder root (e.g. a file in
  the SsgConverter root is `Source/Foo.cs`, not `SsgConverter/Source/Foo.cs`). Use **`**/`-anchored**
  globs so they match regardless of which root a file sits in. (This is the exact bug that made the
  old `applyTo: "Amt/Migration/**"` never fire.)
- Prompt prefix: **`/ssg-*`** (user-confirmed).

## Area A — Run trials on converted PowerShell
- **Instructions:** `.github/instructions/ssg-run-trials.instructions.md`
  - `applyTo: "**/Trials/**"`; description keyword-rich ("run converted SSG PowerShell, Tier-1 mock
    harness, parse-check, diff vs golden").
  - Content: the standard trial process (already summarised in the CI), the mock runtime surface
    (`GetSgsValue`, `DataLineOrNoStatement`, `Call-ExternalProgram`, `CompareTypeSafe`, `Sort-SgsList`,
    `Fin`, `Abort`), `sgs-values.json` seeding from Trial3 manifest, PS 5.1 gotchas.
- **Prompt:** `.github/prompts/ssg-run-trial.prompt.md` — `/ssg-run-trial <Program>`
  (`mode: agent`): orient → parse-check → `Run-SsgPsTrial.ps1 -Program <P> -Diff` → review → record.

## Area B — Change the SsgConverter (C#)
- **Instructions:** `.github/instructions/ssg-converter-dev.instructions.md`
  - `applyTo: "**/Source/**"`; description ("modify SsgConverter C#, expression parser/migrator,
    rebuild, re-verify examples").
  - Content: source map (`SymstreamProcessor.cs`, `SymstreamExpressionParser.cs`,
    `SymstreamExpressionMigrator.cs`, `Expressions/`, `Enums/`, `Exceptions/`), build
    (`dotnet build Source\SsgConverter.slnx -c Debug`, `_deps` must stay), the KI-1..3 "don't fix
    without a failing test" rule, and the verify loop (re-run console on `Examples/Input`, diff vs
    `Examples/Output`, then re-run Area A parse-check).
- **Prompt:** `.github/prompts/ssg-fix-converter.prompt.md` — `/ssg-fix-converter <issue>`
  (`mode: agent`): reproduce with a failing case → scoped fix → rebuild → re-verify examples → re-run
  the Tier-1 parse-check. First target: the level-number `DataLineOrNoStatement` parse bug.

## Area C — Reconvert SSG-COBOL → PowerShell
- **Instructions:** `.github/instructions/ssg-reconvert.instructions.md`
  - `applyTo: ["**/Examples/**", "**/manifest/**", "**/config/**"]`; description ("re-run
    SsgConverterConsole, settings file, input/output folders, warning taxonomy").
  - Content: settings-file format, console invocation, the warning taxonomy + expected comments from
    the COPILOT spec, and the MT-003 note (only 5 of 36 inputs present; decide the runnable set).
- **Prompt:** `.github/prompts/ssg-reconvert.prompt.md` — `/ssg-reconvert <Program>`
  (`mode: agent`): confirm input present → run console with a settings file → review warnings against
  the taxonomy → hand the fresh output to Area A.

## Process prompts (cross-area)
- `.github/prompts/ssg-session-start.prompt.md` — `/ssg-session-start` (`mode: agent`): load the CI,
  restate goal + current status, ask which area, confirm before acting.
- `.github/prompts/ssg-review.prompt.md` — `/ssg-review <area|program>` (`mode: ask`): compare work
  done vs. process, list deviations / open risks / corrections; "accepted — proceed" when clean.
- *(optional)* `.github/prompts/ssg-guardrail.prompt.md` — `/ssg-guardrail` (`mode: ask`): flag
  edits to `SSG-Source/`, reliance on stale `C:\Amt` paths, pipeline runs past `-ListOnly`, KI fixes
  without a test, or any touch of the live AMT177/FEDERALE_APP app.

## Retire (pending user OK — inventory already provided)
- `.github/prompts/AMT-MIGRATE.prompt.md` (old CobolConvert pipeline, all `C:\Amt` paths).
- `.github/instructions/amt-cobol-migration.instructions.md` (never-matching `applyTo`, no
  `description`); salvage the portable parts first: key-vs-programId, Bug 14/15, `Run-EclProof.ps1`
  behaviours, PS 5.1 gotchas → fold into the Area-A/C instructions.

## Build order
1. ✅ CI + this plan.
2. ✅ Area A instructions + `/ssg-run-trial` (unblocks the current parse-error work).
3. ✅ `/ssg-session-start` + `/ssg-review` (the process loop).
4. ✅ Area B instructions + `/ssg-fix-converter` (for the converter fix).
5. ✅ Area C instructions + `/ssg-reconvert`.
6. ✅ Retired the two old AMT files — salvaged portable concepts, backed up to `C:\Amt\Temp\Retired\`,
   originals deleted from the repo (2026-09-10, with VS Code closed).
