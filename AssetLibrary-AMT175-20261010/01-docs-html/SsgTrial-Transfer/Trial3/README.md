# Trial3 — EclCobolPipeline

A self-contained, **repeatable** ECL / SSG-COBOL / PowerShell conversion stream.
This is the hived-off "parallel conversion-stream" activity carved out of the
AMT 172 migration. It turns Unisys 2200 SSG macro-COBOL hybrid source
(`ASSURFED_*.TXT`) into clean COBOL and then into Lion source via the
`CobolConverterConsole` tool — driven entirely from a manifest so the whole set
can be re-run with a single command.

> Companion documentation: [../docs/SSG-ECL-PowerShell-Reference.html](../docs/SSG-ECL-PowerShell-Reference.html)

## Layout

| Path | Purpose |
|------|---------|
| `config/pipeline.config.json` | Environment paths: converter exe, GlobalCopyDir, raw SSG source, repo dirs. **Edit per machine.** |
| `manifest/programs.manifest.json` | One entry per ECL/SSG program: source, settings, candidate dir, ECL param overrides, SSG condition values. |
| `tools/Run-EclPipeline.ps1` | Manifest-driven, idempotent driver. |
| `tools/Convert-SsgToLion.ps1` | Per-program wrapper: SSG pre-process → converter. *(copied from CobolConvert)* |
| `tools/Remove-SsgDirectives.ps1` | SSG `*DEFINE`/`*IF`/`*SET`/`*END` stripper. *(copied from CobolConvert)* |
| `settings/` | Per-program `.settings` JSON. *(copied)* |
| `macros/` | `ssg-stub.macros.xml` stub corpus. *(copied)* |
| `candidates/` | Pre-processed PROGRAM-ID-named COBOL candidates — the "converted COBOL repo". *(copied)* |
| `output/` | Generated `.LionSource` artefacts. **Regenerated; git-ignored.** |

## Design decisions

- **Copied, not moved** — originals remain untouched in
  `C:\Amt\Migration\CobolConvert`.
- **Converter exe by config path** — the binary is never vendored; set
  `converterConsolePath` in `config/pipeline.config.json`.
- **Portable settings** — the driver rewrites each `.settings`
  `BatchDir` / `OutputFile` / `GlobalCopyDir` to repo-relative paths at run time,
  so the repo can be cloned anywhere and re-run.
- **Lineage markers** — generated stub identifiers carry `ECL_` / `SSG_`
  prefixes so the ECL/SSG origin survives into generated C# for AMT visual
  comparison.

## Usage

```powershell
cd C:\Amt\Migration\EclCobolPipeline\tools

# Show the resolved plan without running the converter
.\Run-EclPipeline.ps1 -ListOnly

# Run a single program
.\Run-EclPipeline.ps1 -Program LECTIS

# Run every validated ('done') program
.\Run-EclPipeline.ps1

# Include 'planned' entries too
.\Run-EclPipeline.ps1 -IncludePlanned
```

## Known follow-ups (out of v1 scaffold scope)

- Confirm `paramOverrides` / `conditionValues` for MONTANT and TRI_ASCII against
  their validated trial runs (currently empty in the manifest).
- Add the `ARCHITAB1` settings + candidate folder (status `planned`).
- Optional: git init + CI/regression harness.
