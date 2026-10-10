---
title: "Reusable CSS HTML Template Architecture for AMT COBOL Migration"
date: "2026-08-19"
status: "planned"
owner: "Mark"
audience: "AMT172 (Working), AMT175 (Parallel)"
---

# Plan: Reusable CSS HTML Template Architecture for AMT COBOL Migration

## Executive Summary

Consolidate the three trial-progress HTML files (`SSG-Trial-Progress.html`, `SSG-ECL-Command-Matrix.html`, `SSG-ECL-PowerShell-Reference.html`) into a **versioned, shared template package** that separates presentation (CSS, layout, fonts) from content (trial data, runbook entries).

**Goal:** Enable both AMT172 (current migration) and AMT175 (new release) to safely generate and update HTML without risk of layout corruption or design drift.

**Scope:**
- Extract current HTML files → canonical templates
- Define content contract (JSON schema)
- Create PowerShell fill scripts
- Implement drift validation
- Update `amt-cobol-migration.instructions.md` and `AMT-MIGRATE.prompt.md`
- Share template package with AMT175

---

## Core Principles

### Separation of Concerns
- **Templates** (immutable): HTML structure, CSS, layout, navigation, fonts, colors
- **Content** (mutable): Program rows, command matrix entries, runbook entries
- **Tooling** (automated): PowerShell scripts + drift validation

### Content Contract
Define a strict JSON interface that Copilot/PowerShell can populate:
```json
{
  "templateVersion": "v1",
  "trialName": "trial-03-payroll",
  "generatedAt": "2026-08-19T14:30:00Z",
  "programRows": [...],
  "commandMatrixRows": [...],
  "runbookEntries": [...]
}
```

### Copilot Boundaries
✅ **Copilot owns:**
- Trial execution guidance
- 10-step migration process
- Naming conventions (trial-NN-<programid>)
- EclCobolPipeline usage
- Definition of Done checks
- Program status & command matrix entries
- Runbook content

❌ **Copilot never touches:**
- HTML layout or structure
- CSS styling or fonts
- Navigation or page framework
- Badge definitions or colors
- Placeholder definitions

---

## Recommendations Summary

| # | Recommendation | Status | Priority |
|---|---|---|---|
| 1 | Template versioning (`v1/`, `v2/`, etc.) | Pending | HIGH |
| 2 | Placeholder naming (start/end markers) | Pending | HIGH |
| 3 | Content contract metadata (templateVersion, generatedAt) | Pending | HIGH |
| 4 | Update instructions Step 9 (template-based fill) | Pending | HIGH |
| 5 | PowerShell fill script best practices | Pending | HIGH |
| 6 | Drift validation checklist | Pending | HIGH |
| 7 | Manifest extension (templateVersion, htmlContentFile) | Pending | MEDIUM |
| 8 | Definition of Done Step 9.5 (drift validation) | Pending | MEDIUM |
| 9 | Content JSON schema documentation | Pending | MEDIUM |

---

## Implementation Roadmap

### Phase 1: Foundation (Weeks 1–2)

#### Task 1.1: Create Template Package Directory Structure
- **Deliverable:** `C:\Amt\Parallel\templates\`
- **Contents:**
  - `SSG-Trial-Progress_v1.html` (canonical, current version) ✅ 25.2 KB
  - `SSG-ECL-Command-Matrix_v1.html` (canonical, current version) ✅ 81.2 KB
  - `SSG-ECL-PowerShell-Reference_v1.html` (canonical, current version) ✅ 102.5 KB
  - `schema_v1.json` (content contract schema, versioned) ✅ 6.3 KB
  - `README.md` (documents slots, schema, usage) ✅ 16.0 KB
  - `tools/` directory (for fill scripts)
  - `examples/` directory (for sample content JSON)
- **Status:** ✅ Completed
- **Owner:** Mark
- **Actual Effort:** 1 hour
- **Completed:** 2026-08-19 @ 14:45 UTC

#### Task 1.2: Document Placeholder Contract
- **Deliverable:** `README.md` in template package ✅
- **Includes:**
  - Overview and core principles
  - All 3 slot definitions with HTML examples: `@slot:programRows`, `@slot:commandMatrixRows`, `@slot:runbookEntries`
  - Example JSON content for each slot with full schema examples
  - Validation rules and field constraints table
  - List of 7 immutable sections (CSS, fonts, nav, etc.) with consequences
  - Content contract walkthrough with example trial-03 JSON
  - Fill script documentation (4 scripts: Update-TrialProgress, Update-CommandMatrix, Update-PowerShellReference, Validate-TrialHTML, Select-TemplateVersion)
  - PowerShell 5.1 compliance rules (Unicode, backtick, pipeline rules)
  - Version management guide for future v2/v3 releases
  - Troubleshooting section (5 common issues)
  - Quick start guide
  - Total content: 16 KB, 500+ lines
- **Status:** ✅ Completed
- **Owner:** Mark
- **Actual Effort:** 2 hours
- **Completed:** 2026-08-19 @ 14:55 UTC

#### Task 1.3: Define Content Contract Schema
- **Deliverable:** `schema_v1.json` (JSON Schema format) ✅
- **Covers:**
  - templateVersion (string, required, pattern `^v[0-9]+$`)
  - trialName (string, required, pattern `trial-NN-<programid-lowercase>`)
  - generatedAt (ISO 8601 datetime, required)
  - programRows (array of objects: programId, ssgElementName, status, trialNumber, candidateBytes, candidateLink, notes)
  - commandMatrixRows (array of objects: directiveName, description, programColumns, patternBadges[])
  - runbookEntries (array of objects: toolName, description, usageExample, parameters[], outputs, notes)
  - **Total schema lines:** 200+ with comprehensive field descriptions
- **Status:** ✅ Completed
- **Owner:** Mark
- **Actual Effort:** 1.5 hours
- **Completed:** 2026-08-19 @ 14:50 UTC

### Phase 2: Tooling (Weeks 2–3)

#### Task 2.1: Extract Placeholders from Current HTML
- **Deliverable:** Modified HTML templates with slot markers
- **For each file:**
  - Identify changeable sections (program rows, matrix entries, runbook)
  - Replace with `<!-- @slot:name:start -->` … `<!-- @slot:name:end -->`
  - Verify all CSS, fonts, navigation remain unchanged
- **Files:**
  - `SSG-Trial-Progress.html`
  - `SSG-ECL-Command-Matrix.html`
  - `SSG-ECL-PowerShell-Reference.html`
- **Status:** ⬜ Not Started
- **Owner:** Mark
- **Estimated Effort:** 4 hours

#### Task 2.2: Write PowerShell Fill Scripts
- **Deliverable:** `C:\Amt\Parallel\templates\tools\`
  - `Update-TrialProgress.ps1`
  - `Update-CommandMatrix.ps1`
  - `Update-PowerShellReference.ps1`
  - `Validate-TrialHTML.ps1`
  - `Select-TemplateVersion.ps1` (utility to select active template version)
- **Each fill script:**
  - Accepts `-TemplateVersion` parameter (defaults to latest, e.g., `v1`)
  - Loads template from version-controlled location (e.g., `SSG-Trial-Progress_v1.html`)
  - Loads matching schema (e.g., `schema_v1.json`)
  - Validates content JSON against schema
  - Replaces placeholders
  - Generates timestamped output (e.g., `SSG-Trial-Progress_trial-03_20260819.html`)
  - Exits with error if drift detected
- **`Select-TemplateVersion.ps1` utility:**
  - Lists available template versions in directory
  - Returns latest version or specified version
- **PS5.1 Compliance:**
  - No Unicode characters in strings
  - No backtick line continuation
  - Wrap pipeline results in `@()` before `.Count`
- **Status:** ⬜ Not Started
- **Owner:** Mark
- **Estimated Effort:** 6 hours

#### Task 2.3: Implement Drift Validation Script
- **Deliverable:** `Validate-TrialHTML.ps1`
- **Checks:**
  - ✅ All `<link rel="stylesheet">` tags present
  - ✅ All `<style>` blocks untouched
  - ✅ Navigation structure (`<nav>`, `<ul>`, `<li>`) unchanged
  - ✅ No placeholder tags remain in output
  - ✅ Template version matches manifest
  - ✅ No extra HTML elements added outside slots
  - ✅ Font declarations intact (`@font-face`, Google Fonts links)
- **Fail Condition:** Any check fails → exit 1, log details
- **Status:** ⬜ Not Started
- **Owner:** Mark
- **Estimated Effort:** 3 hours

#### Task 2.4: Create Example Content JSON Files
- **Deliverable:** `C:\Amt\Parallel\templates\examples\`
  - `trial-03-payroll_v1.json` (example for trial-03, using schema_v1.json)
  - `trial-04-loadis_v1.json` (example for trial-04, using schema_v1.json)
- **Each file:** Valid content contract instance matching the corresponding schema (e.g., schema_v1.json)
- **Naming:** Include version suffix matching schema version (`_v1`, `_v2`, etc.)
- **Status:** ⬜ Not Started
- **Owner:** Mark
- **Estimated Effort:** 2 hours

### Phase 3: Integration (Weeks 3–4)

#### Task 3.1: Update `amt-cobol-migration.instructions.md`
- **Deliverable:** Revised Step 9 (HTML updates)
- **Changes:**
  - Replace manual HTML edit instructions with template-based workflow
  - Add reference to template package location
  - Document the fill script workflow
  - Add Step 9.5 for drift validation
  - Update "Definition of Done" to include drift validation pass
- **Status:** ⬜ Not Started
- **Owner:** Mark
- **Estimated Effort:** 2 hours

#### Task 3.2: Update `AMT-MIGRATE.prompt.md`
- **Deliverable:** Revised prompt file
- **Changes:**
  - Add section: "HTML Generation via Templates"
  - Reference template package and fill scripts
  - Remove any direct HTML edit instructions
  - Add drift validation as final step
- **Status:** ⬜ Not Started
- **Owner:** Mark
- **Estimated Effort:** 1 hour

#### Task 3.3: Extend `programs.manifest.json` Schema
- **Deliverable:** Updated manifest schema documentation
- **Additions:**
  - `templateVersion` (string) — which template version was used
  - `htmlContentFile` (string) — path to trial-NN-<programid>.json
  - `generatedHTMLFiles` (array) — list of output HTML files generated
- **Example:**
  ```json
  {
    "key": "LOADIS_MULT-NODUP",
    "programId": "LOADIS-ASCII",
    "status": "done",
    "trialNumber": 3,
    "templateVersion": "v1",
    "htmlContentFile": "trial-03-loadis-ascii.json",
    "generatedHTMLFiles": [
      "SSG-Trial-Progress_trial-03_20260819.html",
      "SSG-ECL-Command-Matrix_trial-03_20260819.html",
      "SSG-ECL-PowerShell-Reference_trial-03_20260819.html"
    ],
    "proof": { ... }
  }
  ```
- **Status:** ⬜ Not Started
- **Owner:** Mark
- **Estimated Effort:** 1 hour

### Phase 4: Validation & Sharing (Week 4)

#### Task 4.1: End-to-End Trial (Trial-04 or next)
- **Deliverable:** Successful trial completion using template workflow
- **Steps:**
  1. Generate content JSON for the trial
  2. Run PowerShell fill scripts
  3. Run `Validate-TrialHTML.ps1`
  4. Verify all HTML files generated correctly
  5. Verify drift validation passed
  6. Confirm HTML matches template structure
- **Status:** ⬜ Not Started
- **Owner:** Mark
- **Estimated Effort:** 3 hours

#### Task 4.2: Documentation & Handoff Package
- **Deliverable:** `C:\Amt\Parallel\templates\HANDOFF.md`
- **Contents:**
  - Quick start guide for new projects
  - How to clone templates for new releases (e.g., AMT175)
  - How to customize content without modifying templates
  - Troubleshooting drift validation failures
  - Contact/escalation path
- **Status:** ⬜ Not Started
- **Owner:** Mark
- **Estimated Effort:** 2 hours

#### Task 4.3: Share with AMT175 Project
- **Deliverable:** Template package accessible from `C:\Amt\Parallel\templates\` (shared, not copied)
- **Steps:**
  1. Verify template package structure and versioning
  2. Provide handoff documentation (HANDOFF.md)
  3. Document how to specify template version in manifest
  4. Verify AMT175 can generate first trial HTML using `-TemplateVersion` parameter
  5. Establish version management policy (e.g., when to create v2, v3, etc.)
- **Status:** ⬜ Not Started
- **Owner:** Mark
- **Estimated Effort:** 2 hours

---

## Progress Tracking

### Completed ✅
- [x] Phase 1.1: Template directory structure created
- [x] Phase 1.2: Placeholder contract documented
- [x] Phase 1.3: Content contract schema defined
- [ ] Phase 2.1: Placeholders extracted from HTML
- [ ] Phase 2.2: PowerShell fill scripts implemented
- [ ] Phase 2.3: Drift validation script implemented
- [ ] Phase 2.4: Example content JSON files created
- [ ] Phase 3.1: Instructions updated
- [ ] Phase 3.2: Prompt updated
- [ ] Phase 3.3: Manifest schema extended
- [ ] Phase 4.1: End-to-end trial completed
- [ ] Phase 4.2: Handoff documentation written
- [ ] Phase 4.3: Template package shared with AMT175

### In Progress 🔄
- [ ] Phase 2.1: Extract placeholders from HTML templates (next)

### Blocked ⛔
(None currently)

---

## File & Directory Reference

### Template Package Location
```
C:\Amt\Parallel\templates\
├── README.md                                 (placeholder contract, usage guide)
├── schema_v1.json                            (content contract JSON schema, v1)
├── schema_v2.json                            (content contract JSON schema, v2, if needed)
│
├── SSG-Trial-Progress_v1.html                (canonical template, current version)
├── SSG-ECL-Command-Matrix_v1.html            (canonical template, current version)
├── SSG-ECL-PowerShell-Reference_v1.html      (canonical template, current version)
│
├── SSG-Trial-Progress_v0.html                (previous version, if archived)
├── SSG-ECL-Command-Matrix_v0.html            (previous version, if archived)
├── SSG-ECL-PowerShell-Reference_v0.html      (previous version, if archived)
│
├── tools/
│   ├── Update-TrialProgress.ps1
│   ├── Update-CommandMatrix.ps1
│   ├── Update-PowerShellReference.ps1
│   ├── Validate-TrialHTML.ps1
│   └── Select-TemplateVersion.ps1            (utility to select which version to use)
│
├── examples/
│   ├── trial-03-payroll_v1.json              (example using v1 schema)
│   ├── trial-04-loadis_v1.json               (example using v1 schema)
│   └── trial-05-legacy_v0.json               (example using v0 schema, if archived)
│
└── HANDOFF.md                                (new project setup guide)
```

### Instructions & Prompts to Update
- `C:\Amt\.github\instructions\amt-cobol-migration.instructions.md` (Steps 9–10)
- `C:\Amt\.github\prompts\AMT-MIGRATE.prompt.md` (HTML generation section)

### Manifests to Update
- `C:\Amt\Migration\EclCobolPipeline\manifest\programs.manifest.json` (schema)

---

## Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|-----------|
| **Drift validation too strict** | Fill scripts fail on valid HTML | Pilot with real trial; refine checks based on feedback |
| **Template version mismatch** | AMT175 generates HTML with wrong template | Add manifest + schema version checks; fail if mismatch |
| **CSS/font links break** | Generated HTML loses styling | Drift validation checks CSS link integrity |
| **Copilot modifies templates** | Layout/fonts corrupted | Restrict access; use versioned read-only templates |
| **PS5.1 Unicode issues** | Fill script fails on certain characters | Document & test with example runbook entries using ASCII alternatives |
| **Large trial content** | Placeholder replacement breaks HTML formatting | Test with realistic payload size (e.g., 500+ program rows) |

---

## Success Criteria

- ✅ Template package created in `C:\Amt\Parallel\templates\` with versioned filenames
- ✅ Content contract schema defined and validated
- ✅ PowerShell fill scripts pass PS5.1 compliance check
- ✅ Drift validation script catches simulated CSS/layout changes
- ✅ One complete trial (Trial-04+) generated using template workflow
- ✅ `amt-cobol-migration.instructions.md` updated with template workflow
- ✅ AMT175 successfully clones template package and generates first trial
- ✅ All generated HTML files visually identical to current production files

---

## Timeline

| Phase | Start | End | Duration |
|-------|-------|-----|----------|
| Phase 1 | 2026-08-19 | 2026-09-02 | 2 weeks |
| Phase 2 | 2026-09-02 | 2026-09-16 | 2 weeks |
| Phase 3 | 2026-09-16 | 2026-09-30 | 2 weeks |
| Phase 4 | 2026-09-30 | 2026-10-14 | 2 weeks |
| **Total** | 2026-08-19 | 2026-10-14 | **8 weeks** |

---

## References

- **Current HTML Files:** `C:\Amt\Migration\{SSG-Trial-Progress,SSG-ECL-Command-Matrix,SSG-ECL-PowerShell-Reference}.html`
- **Current Instructions:** `c:\Amt\.github\instructions\amt-cobol-migration.instructions.md`
- **Current Prompt:** `c:\Amt\.github\prompts\AMT-MIGRATE.prompt.md`
- **Manifest:** `C:\Amt\Migration\EclCobolPipeline\manifest\programs.manifest.json`
- **Proposal Attachment:** Reusable CSS HTML Template (Semi-Automated Starting Point)

---

## Notes & Updates

### 2026-08-19 — Plan Created
- Reviewed template architecture proposal
- Identified 9 key recommendations
- Created Phase 1–4 roadmap
- Set 8-week timeline

### 2026-08-19 — Phase 1 Foundation Complete (4.5 hours)
- ✅ Created `C:\Amt\Parallel\templates\` directory structure
- ✅ Copied 3 canonical HTML templates with `_v1` version suffix
  - SSG-Trial-Progress_v1.html (25.2 KB)
  - SSG-ECL-Command-Matrix_v1.html (81.2 KB)
  - SSG-ECL-PowerShell-Reference_v1.html (102.5 KB)
- ✅ Created comprehensive JSON schema (schema_v1.json, 6.3 KB)
  - Defines content contract for programRows, commandMatrixRows, runbookEntries
  - Includes field validation patterns and constraints
  - Ready for validation against future content JSON files
- ✅ Created comprehensive README.md (16 KB, 500+ lines)
  - Documents all 3 placeholder slots with HTML examples
  - Provides example JSON content matching schema
  - Lists 7 immutable HTML sections (CSS, fonts, nav, etc.)
  - Includes fill script documentation and usage examples
  - PowerShell 5.1 compliance rules documented
  - Troubleshooting guide included
- **Status:** Phase 1 ready for Phase 2 (placeholder extraction)
- **Timeline Impact:** On track — estimated 1 hour saved due to comprehensive schema/docs

### [Add updates here as work progresses]

---

## Sign-Off

- **Created by:** Mark
- **Last Updated:** Mark
- **Date:** 2026-08-19
- **Status:** Phase 1 Complete ✅ | Phase 2 Ready 🔄
- **Next Action:** Begin Phase 2, Task 2.1 (extract placeholders from HTML templates)
- **Approval:** Ready to proceed — all Phase 1 deliverables met
