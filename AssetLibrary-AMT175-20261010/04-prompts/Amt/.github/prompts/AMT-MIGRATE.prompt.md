---
mode: agent
description: Run the AMT COBOL-to-Lion migration pipeline for a single SSG program
---

# AMT-MIGRATE — SSG Program Conversion

**Usage:** `/AMT-MIGRATE <SSG_ELEMENT_NAME>`
Example: `/AMT-MIGRATE TRI_ASCII`

---

## Context — load only these files

The following files contain everything needed. Do NOT perform broad workspace searches.

| Purpose | File |
|---------|------|
| Pipeline rules + naming conventions | `c:\Amt\.github\instructions\amt-cobol-migration.instructions.md` |
| Macro stub inventory | `c:\Amt\Migration\CobolConvert\macros\ssg-stub.macros.xml` |
| SSG program reference | `c:\Amt\Migration\SSG-COBOL-Reference.html` *(browser-view only if needed)* |
| Existing settings examples | `c:\Amt\Migration\CobolConvert\settings\` *(list dir only; read latest trial)* |

SSG source file location (pattern):
```
c:\Amt\MainframeSource\Codedrop 2025\SSG Prd\SSG Creating COBOL\ASSURFED_UTILIT_<SSG_ELEMENT_NAME>(P).TXT
```

---

## Steps

### 1 — Read the SSG source file
Read `ASSURFED_UTILIT_<SSG_ELEMENT_NAME>(P).TXT` from the SSG source folder above.

Identify:
- `PROGRAM-ID.` value — **this becomes the candidate filename and app/object name**
- All `*DEFINE`, `*IF`, `*ELSE`, `*END`, `*SET` directives → condition names
- All `[TOKEN,...]` ECL parameter tokens → parameter names
- Input/output FD record sizes (look for `PIC X(...)` near FD entries)

### 2 — Check the macro file
Read `c:\Amt\Migration\CobolConvert\macros\ssg-stub.macros.xml`.
List any tokens from Step 1 that are NOT already covered.

### 3 — Propose settings and overrides
Draft a new `.settings` JSON based on the most recent trial settings file.

Naming: `trial-NN-<program-id-lowercase>.settings`

Apply the `SSG_` / `ECL_` stub naming convention:
- `ECL_` prefix for `[TOKEN,...]` parameters (e.g. `ECL_INPUT_RECSIZE`)
- `SSG_` prefix for `*DEFINE` macro names (e.g. `SSG_ASCII`)
- Include a `*>` COBOL comment before each stubbed line carrying the original token verbatim

### 4 — Run the pipeline
```powershell
cd C:\Amt\Migration\CobolConvert\tools
.\Convert-SsgToLion.ps1 `
  -SettingsFile "C:\Amt\Migration\CobolConvert\settings\trial-NN-<programid>.settings" `
  -RawSourceDir "C:\Amt\MainframeSource\Codedrop 2025\SSG Prd\SSG Creating COBOL" `
  -ConditionValues @{ <from Step 1 analysis> } `
  -ParamOverrides  @{ <from Step 1 analysis> }
```

### 5 — Check output
- Inspect `BatchDir\<PROGRAMID>.TXT` for residual `[token]` patterns replaced with `1`
- Review the converter log in `c:\Amt\Migration\CobolConvert\logs\`
- Report error count and any unknown tokens requiring new macro entries

### 6 — Candidate file rule (Bug 14)
The candidate `.TXT` filename **must match PROGRAM-ID**, not the SSG element name.

### 7 — Update SSG-COBOL-Reference.html stub-map
Add a row for each new stub: stub name | original SSG/ECL token | C# tier | helper function.

---

## HTML Generation via Templates

After completing Steps 1–7, generate/update trial progress and reference HTML files using the shared template system.

**Template Package Location:** `C:\Amt\Parallel\templates\`

### 8 — Create trial content JSON
Create a JSON file conforming to `schema_v1.json` with:
- `templateVersion` (e.g., `v1`)
- `trialName` (pattern: `trial-NN-<name>`, e.g., `trial-03-payroll`)
- `generatedAt` (ISO 8601 timestamp)
- `programRows[]` — Array of program status objects with: `programId`, `ssgElementName`, `category`, `description`, `status` (enum: pending|in-progress|done|failed), `trialNumber`, `candidateBytes`, `candidateLink`, `notes`
- `commandMatrixRows[]` — Directive × program matrix rows with status badges
- `runbookEntries[]` — Program documentation blocks with tool name, usage examples, parameters

**File location:** `C:\Amt\Parallel\templates\examples\trial-NN-<name>_v1.json`

Reference: `C:\Amt\Parallel\templates\examples\trial-03-payroll_v1.json` (example)

### 9 — Run fill scripts
From `C:\Amt\Parallel\templates\tools\`, execute:

```powershell
# Generate trial progress tracker
.\Update-TrialProgress.ps1 `
  -ContentFile ../examples/trial-NN-<name>_v1.json `
  -OutputDir ./output

# Generate command matrix
.\Update-CommandMatrix.ps1 `
  -ContentFile ../examples/trial-NN-<name>_v1.json `
  -OutputDir ./output

# Generate PowerShell runbook reference
.\Update-PowerShellReference.ps1 `
  -ContentFile ../examples/trial-NN-<name>_v1.json `
  -OutputDir ./output
```

### 10 — Validate drift (Required)
Run validation on all three generated HTML files:

```powershell
.\Validate-TrialHTML.ps1 -HtmlFile ./output/SSG-Trial-Progress_*.html
.\Validate-TrialHTML.ps1 -HtmlFile ./output/SSG-ECL-Command-Matrix_*.html
.\Validate-TrialHTML.ps1 -HtmlFile ./output/SSG-ECL-PowerShell-Reference_*.html
```

**All three validations MUST PASS.** If any fail, layout corruption risk exists. Do not proceed until all pass.

---

## Definition of Done (Trial Completion)

A trial is complete when:
- ✅ All SSG programs converted to COBOL/Lion candidates (Steps 1–5)
- ✅ All new macro stubs added to `ssg-stub.macros.xml` (Step 2)
- ✅ All new stubs documented in SSG-COBOL-Reference.html (Step 7)
- ✅ Trial content JSON created and schema-validated (Step 8)
- ✅ All three HTML files generated and **drift-validated to PASS** (Steps 9–10)
- ✅ Generated HTML files tested in browser (manual verification)

---

## Do NOT
- Scan `MainframeSource/ProgPrd`, `CopyPrd`, `ScreensPrd`, or `RunsPrd` — not needed for SSG programs
- Scan `c:\Dev\amt-go-net-net8` — source reference only, not migration working area
- Read the entire `Working/` folder
- Load AI archive JSONL files
