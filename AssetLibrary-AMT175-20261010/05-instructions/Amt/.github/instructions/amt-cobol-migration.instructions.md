---
applyTo: "Amt/Migration/**"
---

# AMT COBOL Migration — Agent Instructions

## Active pipeline (EclCobolPipeline)

The current trial pipeline is **EclCobolPipeline** — do NOT reference old CobolConvert paths for new trials.

| Script | Role | Path |
|--------|------|------|
| `Run-EclPipeline.ps1` | Orchestrates Remove-SsgDirectives → candidate file | `C:\Amt\Migration\EclCobolPipeline\tools\` |
| `Run-EclProof.ps1` | Manifest-driven proof runner; executor = refimpl oracle | same folder |
| `Remove-SsgDirectives.ps1` | Strips SSG directives; substitutes `[param]` tokens | same folder |

Key paths:
- Manifest: `C:\Amt\Migration\EclCobolPipeline\manifest\programs.manifest.json`
- Fixtures: `C:\Amt\Migration\EclCobolPipeline\fixtures\<key-lowercase>\`
- Refimpl oracle: `C:\Amt\Migration\EclCobolPipeline\tools\refimpl\<key-lowercase>.ps1`
- Candidates: `C:\Amt\Migration\EclCobolPipeline\candidates\trial-NN-<programid-lowercase>\`

> **key vs programId**: `key` = manifest `key` field = SSG element name visible in the progress HTML (e.g. `LOADIS_MULT-NODUP` → lowercased to `loadis_mult-nodup`). `programId` = COBOL `PROGRAM-ID.` value (e.g. `LOADIS-ASCII`). **The proof harness derives fixture and refimpl paths from the `key`** — not the programId. Candidate dirs and settings files use the programId.

## Shared migration resources

| Resource | Path | Purpose |
|----------|------|---------|
| **Templates** | `C:\Amt\Migration\Templates\` | Reusable pilot scripts, settings, SSG stripper |
| **Reference docs** | `C:\Amt\AMT_ReferenceDocuments\Migration\` | Trial-Setup-Guide, converter-settings-guide, batch-harness-patterns |
| **HTML templates** | `C:\Amt\Parallel\templates\` | Schema, fill scripts, drift validation |

When starting a new trial: copy `trial-pilot-template.ps1` and `trial-settings-template.json` from `Templates\`, then follow `AMT_ReferenceDocuments\Migration\Trial-Setup-Guide.md`.  
For HTML output: use fill scripts in `C:\Amt\Parallel\templates\tools\` with JSON conforming to `schema_v1.json`.

## Trial naming convention

| Element | Convention |
|---------|------------|
| Trial number | Sequential `NN`; tracked in manifest + HTML badge |
| Settings key | `trial-NN-<programid-lowercase>` |
| Candidate dir | `EclCobolPipeline/candidates/trial-NN-<programid-lowercase>/` |
| Fixture dir | `EclCobolPipeline/fixtures/<key-lowercase>/` |
| Refimpl oracle | `EclCobolPipeline/tools/refimpl/<key-lowercase>.ps1` |

## Standard trial process

Complete all 10 steps in order. Do not skip any.

1. **Source analysis** — read the mainframe SSG source; identify PROGRAM-ID, all SSG directives (`*IF`/`*SET`/`*INCREMENT`/`*DEFINE`/`*LOOP` etc.), all ECL tokens (`[PARAM]`, `[INPUT]`, `[OUTPUT]`, custom); note conditional branches and loops.
2. **Simplification plan** — choose concrete `paramOverrides` and `conditionValues`; prefer minimal complexity (e.g. ASCII=1, INPUT,1=1, KEYIS=2). If a pre-analysis block (paramOverrides + conditionValues) is already recorded in memory notes for this program, treat it as pre-confirmed and proceed directly. Only confirm with user when no pre-analysis exists.
3. **Pipeline** — run `Run-EclPipeline.ps1` with `-SettingsFile` and the chosen overrides; inspect candidate for residual `[token]` patterns.
4. **Candidate verification** — check generated `.TXT` for correct field sizes and conditional branches; verify all `*SET [*varname]` computations match expected arithmetic.
5. **Fixtures** — create `fixtures/<key>/input.dat`, `expected.dat`, `assign.json`; verify byte count: `(Get-Item expected.dat).Length`.
6. **Refimpl oracle** — write `tools/refimpl/<key>.ps1`; run standalone first; confirm output matches hand-derived `expected.dat` before running the proof harness.
7. **Proof** — run `.\tools\Run-EclProof.ps1 -Program <PROGRAMID>`; must produce `PASS diff=0`.
8. **Manifest** — set `"status": "done"` + add full `"proof"` block (executor, refImpl, fixtureDir, inputSpec, fileAssignments, expectedFile, expectedBytes, expectedLines, notes).
9. **HTML generation via templates** (replaces manual HTML editing):
   - Prepare JSON content file conforming to `C:\Amt\Parallel\templates\schema_v1.json` with trial data (programRows, commandMatrixRows, runbookEntries)
   - Run fill scripts from `C:\Amt\Parallel\templates\tools\`:
     - `Update-TrialProgress.ps1` → generates `SSG-Trial-Progress_*.html` with all program status rows
     - `Update-CommandMatrix.ps1` → generates `SSG-ECL-Command-Matrix_*.html` with directive matrix
     - `Update-PowerShellReference.ps1` → generates `SSG-ECL-PowerShell-Reference_*.html` with runbook entries
   - Validate generated HTML: `Validate-TrialHTML.ps1` must pass all 7 drift checks (CSS, nav, placeholders, headers, footer, badges, DOCTYPE)
   - See `C:\Amt\Parallel\templates\README.md` for template package documentation, content contract, and examples
9.5. **Drift validation pass requirement** — all three generated HTML files must pass `Validate-TrialHTML.ps1` drift check before publishing to trial folder. This prevents CSS/layout corruption.
10. **Session-end `-ListOnly` check** — run `.\tools\Run-EclProof.ps1 -ListOnly`; confirm READY count is N+1 vs session start. **Do NOT skip this step.**

## Definition of done (per trial)

A trial is complete only when ALL of the following hold:
- `PASS diff=0` from `Run-EclProof.ps1`
- Manifest: `"status": "done"` + full proof block
- HTML generation: All three files generated via template fill scripts
- Drift validation: All three generated HTML files pass `Validate-TrialHTML.ps1` (7-point check)
- `SSG-Trial-Progress.html`: PASS badge with byte count + trial link
- `SSG-ECL-Command-Matrix.html`: program column filled (Sections 2+3) + pattern badges updated (Section 4)
- `SSG-ECL-PowerShell-Reference.html`: runbook entry present with documentation
- `-ListOnly` READY count = N+1

## Key naming rule (Bug 14)

The candidate `.TXT` filename **must match the PROGRAM-ID** in the COBOL source, not the
SSG element name. Example: SSG element `LECTIS_MULT` has `PROGRAM-ID. LECTIS.` — the
candidate file must be named `LECTIS.TXT`.

## After conversion — before generation (Bug 15)

After importing the `.LionSource` file into LionDev, always run:
**Logic Status → Select All → F7 (Parse)** before clicking Generate.
Skipping this leaves REVGENSETDATA empty and generates empty C# files.

## Macro file inventory (CobolConvert — legacy)

`CobolConvert\macros\ssg-stub.macros.xml` tracks bare-word tokens for the old CobolConvert pipeline.
Not needed for EclCobolPipeline trials. Update only if processing a program via the old CobolConvert path.

## PowerShell 5.1 gotchas (HTML fill scripts)

- **No Unicode in string literals.** Characters such as `→` (U+2192) are misread by PS5.1 as Win-1252 0x92 = `'`, closing the string. Use ASCII alternatives (e.g. `->`) instead.
- **Avoid backtick line continuation in inline terminal commands.** The terminal tool frequently truncates multi-line commands with `` ` `` continuation. For fixture creation and multi-step work, write a `.ps1` script file and run with `powershell -File`. Prefer single-line commands otherwise.
- **Use `<td class="directive"><code>` as row key prefix** when locating directive rows in HTML tables. A bare `<code>` prefix matches description-paragraph text before the actual directive row.
- **`'0'..'9'` yields integers.** Use an explicit `@('0','1',...)` array when hashtable keys must be strings.
- **Wrap pipeline results in `@()`** before `.Count` under `Set-StrictMode -Version 2`.
- **Multiline regex matching:** Use `[System.Text.RegularExpressions.RegexOptions]::Singleline` flag when matching patterns across newlines (e.g. `[regex]::Replace($text, $pattern, $replacement, [RegexOptions]::Singleline)`). The `-replace` operator and `-match`/`-notmatch` don't support multiline matching without explicit flags.

## HTML Generation via Templates

The three trial HTML files (`SSG-Trial-Progress.html`, `SSG-ECL-Command-Matrix.html`, `SSG-ECL-PowerShell-Reference.html`) are now generated automatically from templates instead of manual editing. This prevents layout corruption and ensures consistency across AMT172 and AMT175.

**Template package location:** `C:\Amt\Parallel\templates\`

### Template architecture

- **Immutable sections:** CSS `<style>` blocks with color variables, navigation bars with fixed layout, page structure, badge classes, font declarations. These sections are never modified by fill scripts.
- **Mutable sections:** Placeholder-marked content areas (program status rows, directive matrix rows, runbook entries). Fill scripts replace these sections with generated content via JSON input.
- **Placeholder markers:** HTML comment pairs `<!-- @slot:slotName:start -->` ... `<!-- @slot:slotName:end -->` delimit mutable content. Markers are removed during replacement, not included in output.

### Workflow

1. **Create JSON content file** conforming to `schema_v1.json` with trial data:
   - `templateVersion`: "v1" (must match template version)
   - `trialName`: "trial-NN-<programid-lowercase>"
   - `generatedAt`: ISO 8601 timestamp
   - `programRows[]`: Array of program status objects (programId, status enum, trial number, byte count, candidate link, notes)
   - `commandMatrixRows[]`: Array of directive groups with program column mappings (directive name, description, column values)
   - `runbookEntries[]`: Array of tool documentation (tool name, description, usage, parameters, outputs)
   - See examples in `C:\Amt\Parallel\templates\examples\trial-03-payroll_v1.json` and `trial-04-loadis_v1.json`

2. **Run fill scripts** from `C:\Amt\Parallel\templates\tools\`:
   ```powershell
   .\Update-TrialProgress.ps1 -ContentFile ./trial-03-payroll_v1.json -OutputDir ./output
   .\Update-CommandMatrix.ps1 -ContentFile ./trial-03-payroll_v1.json -OutputDir ./output
   .\Update-PowerShellReference.ps1 -ContentFile ./trial-03-payroll_v1.json -OutputDir ./output
   ```

3. **Validate output** — all three files must pass drift check:
   ```powershell
   .\Validate-TrialHTML.ps1 -HtmlFile ./output/SSG-Trial-Progress_*.html
   .\Validate-TrialHTML.ps1 -HtmlFile ./output/SSG-ECL-Command-Matrix_*.html
   .\Validate-TrialHTML.ps1 -HtmlFile ./output/SSG-ECL-PowerShell-Reference_*.html
   ```

### Validation (7-point drift check)

All generated HTML must pass these checks:
1. CSS `<style>` block present and intact
2. Nav element with correct color/structure
3. No remaining placeholder markers (`@slot:` patterns)
4. H1 page header present
5. Footer structure intact
6. Badge CSS classes (`.badge-done`, `.badge-prog`, `.badge-pend`) defined
7. HTML DOCTYPE and overall structure valid

**Drift validation is mandatory before publishing.** It prevents accidental layout corruption and ensures template immutable sections remain unchanged.

### Troubleshooting

- **"Placeholder markers still present in output"**: Use `[regex]::Replace()` with `[RegexOptions]::Singleline` flag, not `-replace` operator. The `-replace` operator doesn't handle multiline content correctly in PS5.1.
- **Schema validation failed**: Check JSON syntax, ensure all required fields are present (templateVersion, trialName, generatedAt). Validate against `schema_v1.json` before running fill scripts.
- **CSS or nav color corrupted**: This indicates an immutable section was modified. Regenerate from clean template using `Select-TemplateVersion.ps1 -Version v1` to get the canonical template path.

### For new projects (AMT175, future releases)

1. Clone the entire template package folder: `C:\Amt\Parallel\templates\` → `C:\Amt\Parallel\AMT175-templates\`
2. Update template version suffix if needed: rename `*_v1.html` → `*_v2.html` (increment schema version in `schema_vN.json` accordingly)
3. Use same workflow with new template path
4. Keep templates in shared location for consistency, or copy to project-specific folder

For detailed documentation, examples, and FAQ, see `C:\Amt\Parallel\templates\README.md`.

## Run-EclProof.ps1 — key behaviours

- `assign.json` format: `{ "jobname": "...", "fileAssignments": { "LOGICAL_KEY": "relative-filename" } }`
- `$assignedIn` = first `fileAssignments` path that **exists** on disk (source data for executor)
- `$assignedOut` = last `fileAssignments` path that does **not** exist (where executor writes output)
- Without `-IncludePlanned`, only programs with `"status": "done"` and a `"proof"` block are run
- `-ListOnly` enumerates all manifest programs + READY / PENDING counts; run at session start and end
