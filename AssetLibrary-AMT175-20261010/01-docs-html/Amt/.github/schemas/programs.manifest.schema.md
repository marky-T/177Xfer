# programs.manifest.json Schema

**Location:** `C:\Amt\Migration\EclCobolPipeline\manifest\programs.manifest.json`  
**Version:** 1.0  
**Last Updated:** 2026-08-19

## Overview

The manifest is a JSON document containing metadata for each program in the ECL→COBOL→C# conversion pipeline. Each entry drives the proof runner, candidate generation, and (as of v1.0.1) HTML template generation.

## Top-Level Structure

```json
{
  "_description": "...",
  "_markerConvention": "...",
  "programs": [ {...}, {...}, ... ]
}
```

## Program Object Schema

Each program object in the `programs[]` array has the following structure:

### Core Fields (Required)

| Field | Type | Example | Purpose |
|-------|------|---------|---------|
| `key` | string | `"MONTANT"` | SSG element name; used as lowercased dir name (`montant`) for fixtures/refimpl |
| `description` | string | `"MONTANT_SIGNE numeric-edit utility"` | Human-readable description |
| `programId` | string | `"MONTANT"` | COBOL PROGRAM-ID value |
| `sourceFile` | string | `"ASSURFED_UTILIT_MONTANT_SIGNE(P).TXT"` | Mainframe source filename |
| `settingsFile` | string | `"trial-03-montant.settings"` | ECL pipeline settings file |
| `candidateDir` | string | `"trial-03-montant"` | Output directory for generated candidate |
| `outputName` | string | `"trial-03-montant.LionSource"` | Candidate output filename |
| `status` | enum | `"done"` | One of: `pending`, `in-progress`, `done`, `failed` |

### Pipeline Configuration (Required)

| Field | Type | Example | Purpose |
|-------|------|---------|---------|
| `paramOverrides` | object | `{"[INPUT,1,1,1]": "FICHIN-1", ...}` | ECL token substitutions for `Remove-SsgDirectives.ps1` |
| `conditionValues` | object | `{"ASCII": "1", "LKEY": "2", ...}` | SSG `*IF` condition values for conditional branch evaluation |
| `notes` | string | `"Override set captured from trial-05 LECTIS run."` | Implementation notes |

### Proof Configuration (Required when status="done")

| Field | Type | Example | Purpose |
|-------|------|---------|---------|
| `proof` | object | See section below | Tier-1 proof harness configuration |
| `proof.executor` | string | `"refimpl"` | Proof executor type (`refimpl` = oracle reference implementation) |
| `proof.refImpl` | string | `"tools/refimpl/montant.ps1"` | Path to reference implementation script |
| `proof.fixtureDir` | string | `"fixtures/montant"` | Path to fixtures directory |
| `proof.inputSpec` | string | `"80-char fixed records, CRLF-delimited; ..."` | Input data specification and format |
| `proof.fileAssignments` | object | `{"FILEIN-1": "input.dat", ...}` | Map of ECL file assignments to fixture filenames |
| `proof.expectedFile` | string | `"fixtures/montant/expected.dat"` | Path to expected output (golden truth) |
| `proof.notes` | string | `"Tier-1 golden hand-derived..."` | Proof methodology notes |

### HTML Generation (Optional, added v1.0.1)

**Purpose:** Tracks which trial HTML files this program contributes to, enabling drift detection and version management.

| Field | Type | Example | Purpose |
|-------|------|---------|---------|
| `htmlGenerationConfig` | object | See section below | Template generation metadata |
| `htmlGenerationConfig.templateVersion` | string | `"v1"` | Template version (must match `SSG-Trial-Progress_v1.html` etc.) |
| `htmlGenerationConfig.contentJsonFile` | string | `"trial-03-payroll_v1.json"` | Path to trial JSON content file (relative to `templates/examples/`) |
| `htmlGenerationConfig.generatedHTMLFiles` | array | `["SSG-Trial-Progress_20260819-135716.html", ...]` | List of generated output filenames (for audit trail) |

**When to include:** Add `htmlGenerationConfig` after the manifest `status` field is set to `"done"` and HTML content has been prepared.

## Example: Complete Program Entry

```json
{
  "key": "MONTANT",
  "description": "MONTANT_SIGNE numeric-edit utility",
  "programId": "MONTANT",
  "sourceFile": "ASSURFED_UTILIT_MONTANT_SIGNE(P).TXT",
  "settingsFile": "trial-03-montant.settings",
  "candidateDir": "trial-03-montant",
  "outputName": "trial-03-montant.LionSource",
  "paramOverrides": {},
  "conditionValues": {},
  "status": "done",
  "notes": "Intentionally empty: MONTANT_SIGNE is the built-in baseline...",
  "proof": {
    "executor": "refimpl",
    "refImpl": "tools/refimpl/montant.ps1",
    "fixtureDir": "fixtures/montant",
    "inputSpec": "80-char fixed records, CRLF-delimited...",
    "fileAssignments": {
      "FILEIN-1": "input.dat",
      "FILEOUT-1": "output.dat"
    },
    "expectedFile": "fixtures/montant/expected.dat",
    "notes": "Tier-1 golden hand-derived independently..."
  },
  "htmlGenerationConfig": {
    "templateVersion": "v1",
    "contentJsonFile": "trial-03-payroll_v1.json",
    "generatedHTMLFiles": [
      "SSG-Trial-Progress_20260819-135716.html",
      "SSG-ECL-Command-Matrix_20260819-140658.html",
      "SSG-ECL-PowerShell-Reference_20260819-140742.html"
    ]
  }
}
```

## Version History

### v1.0.1 (2026-08-19)
- **Added:** `htmlGenerationConfig` section for template-driven HTML generation
- **Rationale:** Enable multi-project HTML reuse (AMT172/AMT175) with version tracking and drift detection
- **Backward compatible:** `htmlGenerationConfig` is optional; existing manifests work unchanged

### v1.0 (earlier)
- **Core fields:** key, description, programId, sourceFile, settingsFile, candidateDir, outputName, paramOverrides, conditionValues, status, notes, proof

## Migration Guide

**For existing programs:** The `htmlGenerationConfig` section is optional and can be added incrementally as you prepare trial JSON content files.

**Steps to add `htmlGenerationConfig` to an existing program:**

1. Prepare trial JSON conforming to `C:\Amt\Parallel\templates\schema_v1.json` (see template README)
2. Run fill scripts from `C:\Amt\Parallel\templates\tools\`:
   - `Update-TrialProgress.ps1`
   - `Update-CommandMatrix.ps1`
   - `Update-PowerShellReference.ps1`
3. Note the generated HTML filenames (timestamped)
4. Add `htmlGenerationConfig` section to the program's manifest entry:
   ```json
   "htmlGenerationConfig": {
     "templateVersion": "v1",
     "contentJsonFile": "trial-03-payroll_v1.json",
     "generatedHTMLFiles": [
       "SSG-Trial-Progress_20260819-135716.html",
       "SSG-ECL-Command-Matrix_20260819-140658.html",
       "SSG-ECL-PowerShell-Reference_20260819-140742.html"
     ]
   }
   ```
5. Commit the manifest update with the trial JSON and generated HTML files

## Validation Rules

- `templateVersion` must match the version suffix of the template files (e.g., `"v1"` for `SSG-Trial-Progress_v1.html`)
- `contentJsonFile` must reference a file conforming to the schema at `C:\Amt\Parallel\templates\schema_v1.json`
- `generatedHTMLFiles` is an audit trail; tools should validate these files exist and pass drift validation before considering the generation successful
- If `htmlGenerationConfig.templateVersion` does not match currently-deployed template version, tools must warn or fail (configurable)

## See Also

- [Template System README](../../Parallel/templates/README.md) — Comprehensive guide to HTML template generation
- [Template Schema](../../Parallel/templates/schema_v1.json) — JSON Schema Draft 7 for trial content files
- [amt-cobol-migration.instructions.md](./instructions/amt-cobol-migration.instructions.md) — Step 9 HTML Generation via Templates
- [AMT-MIGRATE.prompt.md](./prompts/AMT-MIGRATE.prompt.md) — Agent workflow including HTML generation section
