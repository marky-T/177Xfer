# Reference Docs Register

**Generated:** 2026-10-08  
**Last updated:** 2026-10-12 — added the SSG Programming Reference Manual (78311784-010); corrected the label of 82252461-003
**Scope:** Inventory of reference documents in `docs/Reference Docs/` — source materials for the SsgTrial SSG→PowerShell conversion project.

---

## Overview

The `Reference Docs/` folder contains 33 files (17 `.md`, 10 `.pdf`, 5 `.docx`, 1 `.doc`; counted 2026-10-12) sourced from Unisys OS/2200 vendor manuals, Avanade AMT
training and migration guides, and internal trial pipeline documentation. Each document is categorized
by source, authority rating, and the subjects it is authoritative on.

**Authority levels:**
- **Primary/Vendor-official:** Official vendor documentation (Unisys, Avanade); direct from the platform vendor or contracted migration partner.
- **Secondary/Vendor-official:** Vendor training, guides, and tools documentation; authoritative on their respective products and processes, less comprehensive than primary references.
- **Internal/Project documentation:** Trial pipeline guides, setup documentation, and project-specific configurations; authoritative for this SsgTrial only.
- **Reference/Index:** Pointers to online resources; no content authority, use as locators.

---

## 1. Unisys OS/2200 Vendor Manuals

| Document | Converted | Pages | Authority | Source | Subjects |
|-----------|-----------|-------|-----------|--------|----------|
| [78307949-031.md](<Reference Docs/78307949-031.md>) | ✓ PDF→MD | 488 | Primary/Vendor-official | Unisys ClearPath OS 2200 (June 2026) | Executive Control Language (ECL), FURPUR scripting, OS/2200 job control, stream processing |
| [78310281-034.md](<Reference Docs/78310281-034.md>) | ✓ PDF→MD | 414 | Primary/Vendor-official | Unisys ClearPath OS 2200 (July 2020) | Exec System Software (ESS), operations, job scheduling, system management, OS/2200 runtime environment |
| [82252461-003.md](<Reference Docs/82252461-003.md>) | ✓ PDF→MD | 56 | Primary/Vendor-official | Unisys ClearPath Extension Kit for OS 2200 User's Guide, Level 3R1 | Native Control Programs; §5.2.2 has a short SSG/SGS overview and the `ssg.py` SGS parser. **Not the SSG manual** (re-corrected 2026-10-12: its own title page reads *ClearPath Extension Kit*; the 2026-10-09 relabel as the SSG manual was wrong — see 78311784-010) |
| [78311784-010.md](<Reference Docs/78311784-010.md>) | ✓ PDF→MD (pdftotext -layout) | 238 | Primary/Vendor-official | Unisys Symbolic Stream Generator (SSG) Programming Reference Manual, SSG level 24R4, ClearPath OS 2200 Release 20.0 (March 2023) | **The SSG manual.** `@SSG` options (Table 2–1: `A` continue on no-find, `I` list SGSs as input, `B` suppress the automatic `@ADD` of generated output), input from the runstream (§2.2, `SGS`/`SKEL` file-id statements), SGS format (§3.1.1: label, fields, subfields, quoting, `;` continuation), SGS references (§3.1.2), nondirective images and `#`→`@` conversion (§4.3, `NSIGNCHAR$`), all directives (§5). Added 2026-10-12 |
| [78307709-002.md](<Reference Docs/78307709-002.md>) | ✓ PDF→MD (pdftotext -layout) | 880 | Primary/Vendor-official | Unisys OS 2200 ASCII COBOL Programming Reference Manual, Level 7R3K (June 2010) | ASCII COBOL language reference — closes part of the "no COBOL compiler manual" gap (added 2026-10-09) |
| [78310448-005.md](<Reference Docs/78310448-005.md>) | ✓ PDF→MD (pdftotext -layout) | 624 | Primary/Vendor-official | Unisys UCS COBOL Compiler Programming Reference Manual, Volume 1: COBOL Statements, Level 12R2 (February 2015) | **UCOB** compiler — COBOL statement reference. Directly answers the plan's open `UCOB`/`ACOB` evidence item (added 2026-10-09) |
| [78310455-022.md](<Reference Docs/78310455-022.md>) | ✓ PDF→MD (pdftotext -layout) | 736 | Primary/Vendor-official | Unisys COBOL Compiler Programming Reference Manual, Volume 2: Compiler and System Interface, 12R4 (July 2020 — **current edition** per the vendor doc-library index) | **UCOB** compiler/system interface, signed-numeric (overpunch) representation — primary source for the plan's open codec question (added 2026-10-09) |
| [78310455-021.md](<Reference Docs/78310455-021.md>) | ✓ PDF→MD (pdftotext -layout) | 730 | Primary/Vendor-official (prior edition) | Same title as 78310455-022, 12R4 (July 2018 edition) | Superseded by 78310455-022 — kept only in case the earlier edition matches an older Federale platform version (added 2026-10-09) |

**Notes:** These manuals are Unisys-published specifications and reference materials for the OS/2200 mainframe platform. Essential for understanding the source environment (ECL, batch jobs, stream processing, COBOL compilation via UCOB) that the SSG→PowerShell conversion aims to replicate in Windows/AMT. The 4 COBOL/UCOB manuals (added 2026-10-09) directly close the Trial 4 epic's "no compiler manual" gap — see [261009-trial4-epic-strategy.md](../.github/Copilot_Plans/261009-trial4-epic-strategy.md) §6 item 10.

### 1b. Unisys Documentation Library Index

| Document | Converted | Pages | Authority | Source | Subjects |
|-----------|-----------|-------|-----------|--------|----------|
| [00_HOME.md](<Reference Docs/00_HOME.md>) | ✓ PDF→MD (pdftotext -layout) | 6 | Reference/Index | Unisys ClearPath OS 2200 Release 19.0 Product Documentation Library (added 2026-10-10) | Master title/part-number index for the full ClearPath OS 2200 Release 19.0 manual set — use to confirm a part number or find a manual not yet pulled into this folder |

**Notes:** Not authoritative content itself — a locator, same role as [ONLINE-MANUALS.md](<Reference Docs/ONLINE-MANUALS.md>) in §3 but for the Unisys (not AMT) manual set. This is what confirmed `78310455-022` is the current edition over `-021`. (It was also cited as confirming `82252461-003` is the SSG manual; that was wrong — the SSG manual is `78311784-010`, added 2026-10-12.)

---

## 2. Avanade AMT Training & Product Documentation

| Document | Converted | Authority | Source | Subjects |
|-----------|-----------|-----------|--------|----------|
| [AMT Installation and Configuration (AICL).md](<Reference Docs/AMT Installation and Configuration (AICL).md>) | ✓ DOCX→MD | Secondary/Vendor-official | Avanade AMT 6 Training Manual | AMT installation, system prerequisites, configuration, network setup, IIS integration, deployment architecture |
| [AMT-LION Primary Developer Training (ALPD).md](<Reference Docs/AMT-LION Primary Developer Training (ALPD).md>) | native MD | Secondary/Vendor-official | Avanade AMT 6 Training Manual | LION IDE, application development, UI design, forms, controls, screen layout, debugging, LION object model |
| [Migrate AMT LION to Csharp.md](<Reference Docs/Migrate AMT LION to Csharp.md>) | ✓ DOCX→MD | Secondary/Vendor-official | Asysco (Avanade affiliate) Migration Guide | LION→C#/.NET migration strategy, development workflow, version control, build & deploy, testing, go-live process, infrastructure planning |
| [OS2200 COBOL to AMT LION Tech Specs.md](<Reference Docs/OS2200 COBOL to AMT LION Tech Specs.md>) | ✓ DOCX→MD | Primary/Vendor-official | Asysco (Avanade affiliate) Migration Technology | OS/2200 COBOL migration methodology, mainframe application conversion, batch processing, runtime environment, Asysco migration service model |
| [OS2200 COBOL to AMT LION Tech Specs.docx](<Reference Docs/OS2200 COBOL to AMT LION Tech Specs.docx>) | — (source) | Primary/Vendor-official | Asysco (Avanade affiliate) | Same as Markdown version above |
| [OS2200 COBOL to AMT LION Tech Specs.doc](<Reference Docs/OS2200 COBOL to AMT LION Tech Specs.doc>) | — (legacy binary) | Primary/Vendor-official | Asysco (Avanade affiliate) | Same as Markdown version above; legacy Word format (not converted; use .docx or .md instead) |
| [Overview Batch Jobs in AMT - from ECL to PowerShell.md](<Reference Docs/Overview Batch Jobs in AMT - from ECL to PowerShell.md>) | ✓ DOCX→MD | Secondary/Vendor-official | Avanade AMT 6 Training Manual | PowerShell scripting, batch job execution, ECL→PowerShell conversion, AMT runtime, debugging, error handling, ControlCenter integration |
| [ECL to PowerShell (E2P).archived-20260626-080543.md](<Reference Docs/ECL to PowerShell (E2P).archived-20260626-080543.md>) | ✓ DOCX→MD | Secondary/Vendor-official (archived) | Avanade AMT Training | PowerShell, ECL scripting, batch jobs, runtime libraries; **archived 2026-06-26** (likely superseded by Overview Batch Jobs doc) |
| [ECL to PowerShell (E2P).archived-20260626-080543.docx](<Reference Docs/ECL to PowerShell (E2P).archived-20260626-080543.docx>) | — (source) | Secondary/Vendor-official (archived) | Avanade AMT | Same as Markdown version above |
| [Avanade_AMT_COBOL_FileConverter_.md](<Reference Docs/Avanade_AMT_COBOL_FileConverter_.md>) | ✓ PDF→MD | Secondary/Vendor-official | Avanade/Asysco AMT COBOL FileConverter Training Manual | COBOL file conversion, record layouts, batch file handling, data migration, file format preservation |

**Notes:** These documents are Avanade-published training and product guides. The **Migrate LION to C#** and **OS2200 COBOL to AMT LION Tech Specs** are Asysco materials (Asysco is a Unisys migration partner now part of Avanade), making them authoritative on the OS/2200→AMT migration path. The **ECL to PowerShell** doc is marked archived (suffix `-archived-20260626-080543`); use the **Overview Batch Jobs** doc for current PowerShell scripting guidance.

---

## 3. AMT Online Help Index

| Document | Converted | Authority | Source | Subjects |
|-----------|-----------|-----------|--------|----------|
| [ONLINE-MANUALS.md](<Reference Docs/ONLINE-MANUALS.md>) | native MD | Reference/Index | Avanade AMT Help Portal | Links to online AMT help (LION, COBOL OS-2200, AMT-specific COBOL subjects); use as directory |

**Notes:** This is a pointer to the Asysco online help portal (`https://help.myasysco.com/`). It is not authoritative content itself, but a reference index for accessing the full AMT documentation suite online.

---

## 4. Internal Trial Pipeline Documentation

| Document | Converted | Authority | Source | Subjects |
|-----------|-----------|-----------|--------|----------|
| [Migration CobolToC/README.md](<Reference Docs/Migration CobolToC/README.md>) | native MD | Internal/Project documentation | SsgTrial / Federale AMT172/175 pipeline | Trial pipeline architecture, SSG→COBOL→LionSource→C# conversion flow, tool versions, source drop locations, known gotchas (BOM bug, variant mismatch) |
| [Migration CobolToC/Trial-Setup-Guide.md](<Reference Docs/Migration CobolToC/Trial-Setup-Guide.md>) | native MD | Internal/Project documentation | SsgTrial / Federale AMT172/175 pipeline | Step-by-step trial setup (source analysis, SSG directives, pilot script, pipeline execution), prerequisites, validation checks |
| [Migration CobolToC/converter-settings-guide.md](<Reference Docs/Migration CobolToC/converter-settings-guide.md>) | native MD | Internal/Project documentation | SsgTrial / Federale AMT172/175 pipeline | CobolConverterConsole `.settings` file schema, field reference, configuration examples |
| [Migration CobolToC/batch-harness-patterns.md](<Reference Docs/Migration CobolToC/batch-harness-patterns.md>) | native MD | Internal/Project documentation | SsgTrial / Federale AMT172/175 pipeline | AmtPsEclLib patterns, AmtSettings.xml structure, BatchController integration, PowerShell runtime patterns |

**Notes:** These four files are project-internal documentation from the AMT172/175 trial environment (Federale). They describe the trial pipeline (SSG→COBOL→LionSource→C#) and are authoritative only for this specific project. The README flags known issues (BOM encoding, variant mismatches) and references stale paths (e.g., `C:\Amt\Migration\...`) that **have not been verified on the SsgTrial VM** (`E:\Repos\SsgTrial\`). Use these as guides but cross-check paths and tool locations against the current environment.

---

## 5. Document Format & Availability Summary

| Format | Count | Status | Notes |
|--------|-------|--------|-------|
| Markdown (.md) | 23 | ✓ All readable | Includes 6 original .md files + 4 DOCX-converted + 9 PDF-converted + 4 Migration CobolToC subfolder files |
| DOCX (.docx) | 6 | ✓ Source retained | Originals kept; .md conversions also available |
| PDF (.pdf) | 9 | ✓ Source retained | Originals kept; .md conversions also available |
| DOC (.doc) | 1 | ✓ Source retained | Legacy binary Word format; .docx and .md versions available as alternatives |

**Conversion method:** DOCX files extracted via System.IO.Compression (word/document.xml parsing); PDF files extracted via Poppler `pdftotext` v25.07.0 with `-layout` flag.

---

## 6. Authority and Use Recommendations

### For OS/2200 source environment understanding:
- **Primary:** [78307949-031.md](<Reference Docs/78307949-031.md>) (ECL), [78311784-010.md](<Reference Docs/78311784-010.md>) (SSG), [78310281-034.md](<Reference Docs/78310281-034.md>) (operations), [82252461-003.md](<Reference Docs/82252461-003.md>) (extensions)
- **Secondary:** [OS2200 COBOL to AMT LION Tech Specs.md](<Reference Docs/OS2200 COBOL to AMT LION Tech Specs.md>) (migration context)

### For AMT product knowledge:
- **Primary:** [AMT-LION Primary Developer Training (ALPD).md](<Reference Docs/AMT-LION Primary Developer Training (ALPD).md>) (LION IDE), [OS2200 COBOL to AMT LION Tech Specs.md](<Reference Docs/OS2200 COBOL to AMT LION Tech Specs.md>) (architecture)
- **Secondary:** [AMT Installation and Configuration (AICL).md](<Reference Docs/AMT Installation and Configuration (AICL).md>) (deployment), [Overview Batch Jobs in AMT - from ECL to PowerShell.md](<Reference Docs/Overview Batch Jobs in AMT - from ECL to PowerShell.md>) (PowerShell scripting)

### For SsgTrial trial process:
- **Primary:** [Migration CobolToC/README.md](<Reference Docs/Migration CobolToC/README.md>), [Migration CobolToC/Trial-Setup-Guide.md](<Reference Docs/Migration CobolToC/Trial-Setup-Guide.md>) (pipeline, setup)
- **Supporting:** [Migration CobolToC/converter-settings-guide.md](<Reference Docs/Migration CobolToC/converter-settings-guide.md>), [Migration CobolToC/batch-harness-patterns.md](<Reference Docs/Migration CobolToC/batch-harness-patterns.md>) (configuration, runtime patterns)

### Archived / Superseded:
- [ECL to PowerShell (E2P).archived-20260626-080543.md](<Reference Docs/ECL to PowerShell (E2P).archived-20260626-080543.md>) — Use [Overview Batch Jobs in AMT - from ECL to PowerShell.md](<Reference Docs/Overview Batch Jobs in AMT - from ECL to PowerShell.md>) instead.

---

## 7. Notes

- **File list current as of 2026-10-08.** This register describes the 22 documents (18 Markdown equivalents + 4 binary originals retained) in `docs/Reference Docs/`. The folder is not yet committed to git.
- **Stale paths:** Internal documents (Migration CobolToC section) reference paths from the AMT172/175 source environment (`C:\Amt\Migration\...`, `C:\Dev\amt-go-net-net8\...`). These paths have **not** been verified on the SsgTrial VM (`E:\Repos\SsgTrial\`). Treat them as reference only; verify against the current environment before use.
- **Authority rating rationale:** Unisys vendor manuals are Primary because they are official platform specifications. Avanade/Asysco guides are Secondary because they are applied/training material (authoritative on their products and methodologies, but derived from/dependent on the primary OS/2200 specs). Internal trial documents are Project-scoped because they document only this trial's pipeline and configuration choices.

