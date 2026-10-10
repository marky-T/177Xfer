# AMT COBOL Migration HTML Template Package — v1

**Version:** v1  
**Created:** 2026-08-19  
**Last Updated:** 2026-08-19  
**Status:** Foundation (Phase 1)

---

## Overview

This template package provides **canonical HTML templates** for the AMT COBOL-to-C# migration trial pipeline. The templates separate **presentation** (immutable CSS, layout, fonts, navigation) from **content** (mutable trial data, program status, runbook entries).

### Core Principle

**Copilot generates content; PowerShell fills templates.**

Copilot:
- Manages the 10-step trial process
- Generates content JSON (trial status, command matrix entries, runbook entries)
- Never touches HTML, CSS, or layout

PowerShell fill scripts:
- Load template HTML
- Validate content JSON against `schema_v1.json`
- Replace placeholders with populated content
- Generate final HTML artifacts
- Validate drift (no layout/CSS changes)

---

## Template Files

| File | Purpose | Audience |
|------|---------|----------|
| `SSG-Trial-Progress_v1.html` | Trial progress tracker (status badges, candidate links) | Project manager, QE lead |
| `SSG-ECL-Command-Matrix_v1.html` | SSG directive reference matrix (Sections 2–3: programs, Section 4: patterns) | Developer, migration engineer |
| `SSG-ECL-PowerShell-Reference_v1.html` | PowerShell runbook (tools, scripts, cmdlets) | Developer, DevOps engineer |

---

## Placeholder Slots

Placeholders are marked with HTML comments using the format:
```html
<!-- @slot:slotName:start -->
<!-- Content will be injected here -->
<!-- @slot:slotName:end -->
```

### Slot: `programRows` (SSG-Trial-Progress_v1.html)

**Location:** Main progress table, tbody  
**Content Type:** Array of program status objects from JSON `programRows[]`  
**Injected By:** `Update-TrialProgress.ps1`

**Example HTML row (rendered output):**
```html
<tr>
  <td>LOADIS-ASCII</td>
  <td>LOADIS_MULT-NODUP</td>
  <td><span class="badge badge-done">✓ PASS trial-03 15428b</span></td>
  <td>
    <a href="../EclCobolPipeline/candidates/trial-03-loadis-ascii/LOADIS-ASCII.TXT">
      View candidate
    </a>
  </td>
  <td>Fixed field offset calculations</td>
</tr>
```

**Schema Reference:**
```json
{
  "programRows": [
    {
      "programId": "LOADIS-ASCII",
      "ssgElementName": "LOADIS_MULT-NODUP",
      "status": "done",
      "trialNumber": 3,
      "candidateBytes": 15428,
      "candidateLink": "../EclCobolPipeline/candidates/trial-03-loadis-ascii/LOADIS-ASCII.TXT",
      "notes": "Fixed field offset calculations"
    }
  ]
}
```

---

### Slot: `commandMatrixRows` (SSG-ECL-Command-Matrix_v1.html)

**Location:** Matrix table, tbody  
**Content Type:** Array of directive objects from JSON `commandMatrixRows[]`  
**Injected By:** `Update-CommandMatrix.ps1`

**Sections:**
- **Section 2** (Columns 2+): Program-specific cells (one per programId)
- **Section 3** (last row): Summary/notes
- **Section 4** (badges): Pattern classifications

**Example HTML row (Section 2–3):**
```html
<tr>
  <td class="directive"><code>*IF</code></td>
  <td class="directive-desc">Conditional branch on compile-time flag</td>
  <td class="cell">Used (branch A)</td>
  <td class="cell">Used (branch B)</td>
  <td class="cell">Unused</td>
</tr>
```

**Example HTML row (Section 4 patterns):**
```html
<tr class="pattern-row">
  <td class="directive"><code>*SET</code></td>
  <td class="directive-desc">Set variable value</td>
  <td colspan="3" class="cell">
    <span class="badge badge-info">arithmetic</span>
    <span class="badge badge-info">conditional</span>
  </td>
</tr>
```

**Schema Reference:**
```json
{
  "commandMatrixRows": [
    {
      "directiveName": "*IF",
      "description": "Conditional branch on compile-time flag",
      "programColumns": {
        "LOADIS-ASCII": "Used (branch A)",
        "PAYROLL-STD": "Used (branch B)",
        "TELLER-UTIL": "Unused"
      },
      "patternBadges": ["conditional", "control-flow"]
    }
  ]
}
```

---

### Slot: `runbookEntries` (SSG-ECL-PowerShell-Reference_v1.html)

**Location:** Main content area (after TOC, repeating sections)  
**Content Type:** Array of runbook objects from JSON `runbookEntries[]`  
**Injected By:** `Update-PowerShellReference.ps1`

**Example HTML section:**
```html
<div class="section-card">
  <h3>Run-EclPipeline.ps1</h3>
  <p>Orchestrates the SSG→ECL→Candidate pipeline. Applies directives, macro substitutions, and token replacements.</p>
  
  <div class="code-wrap">
    <div class="code-label">Example</div>
    <pre>.\Run-EclPipeline.ps1 `
  -SettingsFile "trial-03-loadis.settings" `
  -ConditionValues @{ ASCII=1; KEYIS=2 }</pre>
  </div>
  
  <h4>Parameters</h4>
  <table class="ref">
    <tr>
      <th>Name</th>
      <th>Type</th>
      <th>Description</th>
    </tr>
    <tr>
      <td><code>-SettingsFile</code></td>
      <td>String</td>
      <td>Path to trial settings JSON</td>
    </tr>
  </table>
  
  <h4>Outputs</h4>
  <p>Generates candidate .TXT file and log in EclCobolPipeline/Logs/</p>
</div>
```

**Schema Reference:**
```json
{
  "runbookEntries": [
    {
      "toolName": "Run-EclPipeline.ps1",
      "description": "Orchestrates the SSG->ECL->Candidate pipeline.",
      "usageExample": ".\\Run-EclPipeline.ps1 -SettingsFile trial-03-loadis.settings -ConditionValues @{ ASCII=1; KEYIS=2 }",
      "parameters": [
        {
          "name": "SettingsFile",
          "type": "String",
          "description": "Path to trial settings JSON",
          "required": true
        }
      ],
      "outputs": "Candidate .TXT file + log in EclCobolPipeline/Logs/",
      "notes": "Exit code 0 = success, non-zero = error. Check log for details."
    }
  ]
}
```

---

## Immutable Sections (NEVER MODIFIED)

The following sections are **read-only** and must not be altered by fill scripts:

| Element | Why | Consequence if Modified |
|---------|-----|------------------------|
| `<style>` block (CSS) | Defines all colors, fonts, layout | Page styling breaks |
| `<link rel="stylesheet">` tags | External font/CSS references | Missing fonts, broken layout |
| `<nav>` structure | Navigation sidebar, TOC | Users cannot navigate |
| `<header>`, `<footer>` elements | Page frame | Page structure corrupted |
| Page titles (`<h1>`) | Page identity | Users confused about which page |
| `@font-face` declarations | Google Fonts, system fonts | Typography fails |
| Badge CSS classes (`.badge-done`, `.badge-pend`, etc.) | Status indicator colors | Wrong colors for status |

**Drift validation checks all of these before publishing.**

---

## Content Contract (schema_v1.json)

The JSON content file **must** conform to `schema_v1.json`. Key rules:

### Required Fields

```json
{
  "templateVersion": "v1",              // ← Must match this schema version
  "trialName": "trial-03-loadis",       // ← Pattern: trial-NN-<programid-lowercase>
  "generatedAt": "2026-08-19T14:30:00Z" // ← ISO 8601 datetime
}
```

### Field Validation

| Field | Constraint | Example |
|-------|-----------|---------|
| `templateVersion` | Must match schema version (v1) | `"v1"` |
| `trialName` | Pattern: `trial-\d+-[a-z]+` | `trial-03-loadis` |
| `generatedAt` | ISO 8601 datetime | `2026-08-19T14:30:00Z` |
| `programId` | Matches COBOL PROGRAM-ID | `LOADIS-ASCII` |
| `ssgElementName` | Manifest key, lowercase version | `loadis_mult-nodup` |
| `status` | One of: pending, in-progress, done, failed | `done` |
| `directiveName` | SSG directive with `*` prefix | `*IF`, `*SET`, `*LOOP` |

### Example Content File

**File:** `trial-03-loadis_v1.json`

```json
{
  "templateVersion": "v1",
  "trialName": "trial-03-loadis",
  "generatedAt": "2026-08-19T14:30:00Z",
  "programRows": [
    {
      "programId": "LOADIS-ASCII",
      "ssgElementName": "LOADIS_MULT-NODUP",
      "status": "done",
      "trialNumber": 3,
      "candidateBytes": 15428,
      "candidateLink": "../EclCobolPipeline/candidates/trial-03-loadis-ascii/LOADIS-ASCII.TXT",
      "notes": "Fixed field offset calculations in OCCURS clause"
    },
    {
      "programId": "PAYROLL-STD",
      "ssgElementName": "PAYROLL_CALC",
      "status": "in-progress",
      "trialNumber": 3,
      "candidateBytes": 0,
      "candidateLink": "",
      "notes": "Pipeline running, checking arithmetic expressions"
    }
  ],
  "commandMatrixRows": [
    {
      "directiveName": "*IF",
      "description": "Conditional branch on compile-time flag",
      "programColumns": {
        "LOADIS-ASCII": "Used (branch A)",
        "PAYROLL-STD": "Used (branch B)"
      },
      "patternBadges": ["conditional"]
    },
    {
      "directiveName": "*SET",
      "description": "Set variable to compile-time expression value",
      "programColumns": {
        "LOADIS-ASCII": "Used (3 times)",
        "PAYROLL-STD": "Used (1 time)"
      },
      "patternBadges": ["arithmetic", "variable-assignment"]
    }
  ],
  "runbookEntries": [
    {
      "toolName": "Run-EclPipeline.ps1",
      "description": "Orchestrates the SSG->ECL->Candidate pipeline. Applies all directives and macro substitutions.",
      "usageExample": ".\\Run-EclPipeline.ps1 -SettingsFile trial-03-loadis.settings -ConditionValues @{ ASCII=1; KEYIS=2 }",
      "parameters": [
        {
          "name": "SettingsFile",
          "type": "String",
          "description": "Path to trial settings JSON file",
          "required": true
        },
        {
          "name": "ConditionValues",
          "type": "Hashtable",
          "description": "Compile-time condition assignments",
          "required": false
        }
      ],
      "outputs": "Candidate .TXT file in EclCobolPipeline/candidates/<trial>/ + execution log",
      "notes": "Exit code 0 = success. Check log for any unknown tokens or errors."
    }
  ]
}
```

---

## Fill Scripts (tools/)

PowerShell scripts in `tools/` directory handle content injection and validation.

### `Update-TrialProgress.ps1`

```powershell
.\Update-TrialProgress.ps1 `
  -ContentFile "trial-03-loadis_v1.json" `
  -TemplateVersion "v1" `
  -OutputDir ".\generated"
```

- Loads `SSG-Trial-Progress_v1.html`
- Validates JSON against `schema_v1.json`
- Replaces `@slot:programRows` placeholder
- Generates `SSG-Trial-Progress_trial-03_20260819.html`
- Runs drift validation

### `Update-CommandMatrix.ps1`

```powershell
.\Update-CommandMatrix.ps1 `
  -ContentFile "trial-03-loadis_v1.json" `
  -TemplateVersion "v1" `
  -OutputDir ".\generated"
```

- Loads `SSG-ECL-Command-Matrix_v1.html`
- Populates Sections 2–3 (program columns)
- Updates Section 4 (pattern badges)
- Runs drift validation

### `Update-PowerShellReference.ps1`

```powershell
.\Update-PowerShellReference.ps1 `
  -ContentFile "trial-03-loadis_v1.json" `
  -TemplateVersion "v1" `
  -OutputDir ".\generated"
```

- Loads `SSG-ECL-PowerShell-Reference_v1.html`
- Generates runbook sections from `runbookEntries[]`
- Validates PS5.1 compliance (no Unicode in examples)
- Runs drift validation

### `Validate-TrialHTML.ps1`

```powershell
.\Validate-TrialHTML.ps1 `
  -GeneratedHTML "SSG-Trial-Progress_trial-03_20260819.html" `
  -OriginalTemplate "SSG-Trial-Progress_v1.html"
```

**Checks:**
- ✅ All `<link rel="stylesheet">` tags present
- ✅ All `<style>` blocks untouched
- ✅ Navigation structure unchanged
- ✅ No placeholder tags remain
- ✅ Font declarations intact
- ✅ No extra HTML elements outside slots
- ✅ Template version matches manifest

**Exit Codes:**
- `0` = All checks passed
- `1` = Drift detected (log details)

### `Select-TemplateVersion.ps1`

```powershell
$latestVersion = .\Select-TemplateVersion.ps1  # Returns "v1"
$specificVersion = .\Select-TemplateVersion.ps1 -Version "v2"  # Returns "v2" if exists
```

- Lists available template versions
- Returns latest by default
- Supports explicit version selection

---

## PowerShell 5.1 Compliance Rules

**Required for this team (Windows Server 2019):**

- ❌ **NO Unicode in string literals.** Characters like `→`, `✓`, `✗` are misread as Win-1252.  
  ✅ **USE:** ASCII alternatives (`->`, `PASS`, `FAILED`)

- ❌ **NO backtick line continuation in terminal commands.**  
  ✅ **USE:** Write multi-line commands as `.ps1` files

- ❌ **NO bare pipeline results before `.Count`.**  
  ✅ **WRAP:** `@(pipeline-result).Count`

- ❌ **NO Unicode in `@('0'..'9')` range expressions.**  
  ✅ **USE:** `@('0','1','2',...,'9')` as explicit array

---

## Version Management

### Current Version
- **v1** — Active (created 2026-08-19)
- Supports: Trial-03, Trial-04, etc.

### Creating a New Version (when needed)

1. **Copy templates:**
   ```powershell
   Copy-Item "SSG-Trial-Progress_v1.html" "SSG-Trial-Progress_v2.html"
   Copy-Item "schema_v1.json" "schema_v2.json"
   ```

2. **Update schema** (e.g., add new fields to `programRows`)

3. **Update fill scripts** to reference new version

4. **Test end-to-end** before marking v2 as default

5. **Keep old versions** for backward compatibility (old trials can still regenerate with v1)

---

## Troubleshooting

### "Placeholder not found" Error

**Symptom:** Fill script says `@slot:programRows` not found  
**Cause:** Template file corrupted or placeholder deleted  
**Fix:** Re-copy original HTML from `C:\Amt\Migration\` and re-apply placeholders

### Drift Validation Fails

**Symptom:** `Validate-TrialHTML.ps1` fails after fill script completes  
**Cause:** CSS/layout accidentally modified during injection  
**Fix:** Check generated HTML for extra/modified `<style>` blocks; regenerate from template

### Content JSON Fails Validation

**Symptom:** `ConvertFrom-Json` succeeds but schema validation fails  
**Cause:** Missing required fields or wrong data types  
**Fix:** Compare against `schema_v1.json`; check field constraints table

### Unicode Characters in Runbook Entries

**Symptom:** PowerShell script fails with encoding errors on Windows  
**Cause:** Runbook example contains `→`, `✓`, etc.  
**Fix:** Replace with ASCII: `->`, `PASS`, `DONE`

---

## Quick Start

### For Trial-03

1. **Create content JSON:**
   ```
   Copy examples/trial-03-payroll_v1.json -> trial-03-payroll_v1.json
   Edit trial-03-payroll_v1.json with your data
   ```

2. **Run fill scripts:**
   ```powershell
   .\tools\Update-TrialProgress.ps1 -ContentFile trial-03-payroll_v1.json -TemplateVersion v1 -OutputDir .
   .\tools\Update-CommandMatrix.ps1 -ContentFile trial-03-payroll_v1.json -TemplateVersion v1 -OutputDir .
   .\tools\Update-PowerShellReference.ps1 -ContentFile trial-03-payroll_v1.json -TemplateVersion v1 -OutputDir .
   ```

3. **Validate:**
   ```powershell
   .\tools\Validate-TrialHTML.ps1 -GeneratedHTML SSG-Trial-Progress_trial-03_*.html -OriginalTemplate SSG-Trial-Progress_v1.html
   ```

4. **Publish:**
   - Open generated HTML files in browser
   - Verify styling, layout, content accuracy
   - Move to final location (e.g., `C:\Amt\Migration\`)

---

## References

- **Schema:** [schema_v1.json](schema_v1.json)
- **Content Examples:** [examples/](examples/)
- **Fill Scripts:** [tools/](tools/)
- **Original Files:** `C:\Amt\Migration\{SSG-Trial-Progress,SSG-ECL-Command-Matrix,SSG-ECL-PowerShell-Reference}.html`
- **Manifest:** `C:\Amt\Migration\EclCobolPipeline\manifest\programs.manifest.json`

---

## Support & Escalation

- **Questions:** Refer to [HANDOFF.md](HANDOFF.md)
- **Bugs/Drift:** Run `Validate-TrialHTML.ps1` and check log
- **New Feature:** Update schema_v2.json and test end-to-end before release
