AMT175 VS Code Installation Guide + Prompt Framework
The key design decision is: use AMT172-Setup-Guide.html only as a structural template, never as implementation authority. That guide has a useful pattern — environment overview, database table, phase flow, status markers, verification blocks and bug log — but it also contains the exact problem we need to prevent: SQL shortcuts into AMTSYS* tables, hard-coded role IDs, timer/launcher automation, and direct fix-by-SQL patterns in places where the AMT reference material describes Setup.exe, Reorganize, Control Center, Keycloak and LincToLion workflows instead. The reference baseline for AMT175 should be AMT Installation and Configuration (AICL).docx, first-use-of-the-control-center.html, Quick start guide AMT-KeyCloak.docx, AMT LincToLion user manual.docx, Announcement AMT175.docx, and AMT .Net 8 upgrade to .Net 10 Report.docx. {5002}
VS Code is a good fit for this because Markdown files support headings, outline navigation, preview, path completions, validation, Mermaid diagrams, and code fences; Copilot custom instructions can be placed in .github/copilot-instructions.md, while reusable prompt files can be placed under .github/prompts as .prompt.md slash commands. {5002}
Copy-ready file: AMT175-Install.md
# AMT175 Installation & Setup Guide

> Purpose: Build AMT175 from authoritative AMT reference documents, using the AMT172 guide only as a documentation structure pattern.
> Primary authority: AICL, Control Center docs, Keycloak setup, Reorganize docs, LincToLion manual, AMT175 release notes.
> Non-authority: AMT172-generated setup guide content, especially direct SQL shortcuts and automation workarounds.

---

## 0. Source Authority Matrix

| Area | Authoritative source | Use for | Guardrail |
|---|---|---|---|
| AMT base install | `AMT Installation and Configuration (AICL)` | Install root, repository DB, `Lion.ini`, Setup.exe | Do not bypass Setup.exe |
| Repository DB | AICL | Empty repository DB; Setup.exe creates objects | Do not hand-create repository schema |
| System DB | AICL + Reorganize docs | Empty system DB, `AMTSYSTEM`, `Sys.ini`, Reorganize | Do not manually populate AMTSYS tables |
| First Control Center use | `first-use-of-the-control-center` | OIDC ADMIN restore, Base Setup | Use `AmtReorganize.exe /RESTOREADMIN=<OIDC identity>` |
| Keycloak | `Quick start guide AMT-KeyCloak` | Realm/client/appsettings setup | Keep auth config under `Amt.Authentication` |
| Security/roles | Control Center Security docs | Users, roles, component activation | No hard-coded role IDs |
| LincToLion | `AMT LincToLion user manual` | Build, interim DB, AB Suite Load, Convert To Lion | Use UI workflow; avoid unsupported DB edits |
| AMT175/.NET 10 | AMT175 announcement + .NET 10 report | Toolchain, SDK, VS target | Use .NET 10 paths and build assumptions |

---

## 1. Structural Pattern Reused from AMT172

The AMT172 guide structure is useful, but not its implementation shortcuts.

### Reusable structure

- Environment Overview
- Key Databases
- Paths & Config
- Phase Flow
- Standard Step Blocks
- Verification Commands
- Bug Log
- Quick Execution Checklist
- Prompt Templates
- Phase Review Log

### Elements to avoid from AMT172

- Direct SQL into `AMTSYS*` tables.
- Assuming `ROLEID=2` or any role ID.
- “Fix by SQL INSERT/UPDATE” patterns unless the AMT reference docs explicitly instruct it.
- Over-automation: timers, launchers, browser helpers, cyclic prompts.
- Prompting that asks the AI to “just fix it” without citing the reference document.

---

## 2. VS Code Editing Setup

Recommended workspace layout:

```text
amt175-setup/
  AMT175-Install.md
  references/
    AICL.md
    ControlCenter.md
    Keycloak.md
    LincToLion.md
    Reorganize.md
  logs/
    phase-0-preflight.md
    phase-1-base-install.md
    phase-2-ssg-converter.md
    phase-3-controlcenter-keycloak.md
    phase-4-runtime.md
  .github/
    copilot-instructions.md
    prompts/
      amt-phase-plan.prompt.md
      amt-step-execute.prompt.md
      amt-phase-review.prompt.md
      amt-guardrail-check.prompt.md
VS Code usage: - Use Markdown headings for foldable sections. - Use task checkboxes for execution state. - Use fenced code blocks for PowerShell, SQL, JSON, INI, and log snippets. - Use the Outline panel to navigate phases. - Use Markdown preview side-by-side while editing. - Store reusable Copilot prompts in .github/prompts/*.prompt.md.
3. Standard Step Block Template
Use this for every install step.
### Step X.Y — <Step name>

**Status:** ⌛ Pending  
**Classification:** Tool | Manual | Script  
**Authority:** <reference doc + section>  
**Goal:** <what this step achieves>  

**Inputs**
- <file/path/config/user input>

**Action**
1. <manual/tool/script action>
2. <manual/tool/script action>

**Verification**
```powershell
# command here
Expected result
Notes / Risks
Deviation log - None, or explain why this differs from the reference doc.

Status markers:

| Marker | Meaning |
|---|---|
| ✓ Done | Verified and recorded |
| ↻ In Progress | Started, not verified |
| ⌛ Pending | Not started |
| ⚠ Review | Possible deviation |
| ✗ Invalid | Violates guardrail |

---

## 4. Environment Overview

> Fill values during Phase 0. Do not commit secrets.

| Item | Value |
|---|---|
| AMT version | AMT175 |
| Runtime target | .NET 10 |
| Repository DB | `<REPOS_DB>` |
| System DB | `<SYSTEM_DB>` |
| LincToLion interim DB | `<LINCTOLION_DB>` |
| AMT root | `<AMT_ROOT>` |
| Lion root | `<AMT_ROOT>\Lion` |
| Sys.ini | `<AMT_ROOT>\Sys.ini` |
| Control Center URL | `<CONTROL_CENTER_URL>` |
| Keycloak URL | `http://localhost:8080` or agreed environment URL |
| Keycloak realm | `<REALM_NAME>` |
| Application name | `<APP_NAME>` |

---

## 5. Key Databases

| DB | Purpose | Created by | Populated by | Verification |
|---|---|---|---|---|
| Repository DB | AMT Developer/Lion repository | Empty SQL DB | Setup.exe | Tables exist after Setup.exe |
| System DB | Runtime configuration, users, roles, jobs | Empty SQL DB | AmtReorganize | System tables exist after Reorganize |
| LincToLion DB | AB Suite interim conversion | Empty SQL DB | LincToLion first run | LincToLion tables exist |
| Application DB | Runtime application DB | Empty SQL DB + Control Center registration | AmtReorganize | App tables/system tables exist |

---

## 6. Phase-Driven Execution Model

### Phase 0 — Preflight

**Goal:** Confirm authoritative inputs before touching install state.  
**Required inputs**
- AMT175 installer/repo location.
- AICL / Control Center / Reorganize docs.
- Keycloak setup material.
- LincToLion manual.
- AMT175 release notes and .NET 10 requirements.
- Target database names and install paths.

**Expected outputs**
- Source authority matrix completed.
- Toolchain confirmed.
- No AMT172 implementation content accepted as authority.

**Verification checkpoints**
```powershell
dotnet --list-sdks
dotnet --list-runtimes
node --version
sqlcmd -S localhost -E -Q "SELECT @@VERSION"
Stop rule: Do not proceed if any required reference document is missing.
Phase 1 — AMT175 Base Install
Goal: Install AMT175 using repository + Setup.exe workflow.
Required inputs - Empty repository DB. - Lion.ini configured for repository DB. - Setup.exe / installer files. - AMT install path.
Expected outputs - AMT install root created. - Repository tables created by Setup.exe. - IIS/Control Center folders created by Setup.exe where applicable. - AMT version verified.
Verification checkpoints
Test-Path "<AMT_ROOT>\Lion\LionDev.exe"
Test-Path "<AMT_ROOT>\AMTTools\ControlCenterCore"
sqlcmd -S localhost -d <REPOS_DB> -E -Q "SELECT COUNT(*) AS TableCount FROM sys.tables"
Guardrail - ✗ Invalid: “Create AMT repository tables manually.” - ✓ Correct: “Create empty DB, configure Lion.ini, run Setup.exe.”
Phase 2 — SSG Converter Milestone STOP POINT
Goal: Prove the converter path before runtime configuration continues.
Required inputs - Source COBOL/SSG samples. - Converter settings. - Copybook path. - Output folder.
Expected outputs - Converter runs. - Output artifacts recorded. - Known errors classified as expected/unexpected. - STOP POINT review completed.
Verification checkpoints
Get-ChildItem "<CONVERTER_OUTPUT>" -Recurse -File | Measure-Object
Get-Content "<CONVERTER_LOG>" -Tail 50
Stop rule: Do not move to Control Center/System DB setup until the converter review prompt has passed.
Phase 3 — Control Center + System DB + Keycloak
Goal: Configure runtime administration using official Control Center/Reorganize/Keycloak flow.
Required inputs - Empty System DB. - AMTSYSTEM environment variable. - Sys.ini. - Keycloak realm/client configuration. - Control Center URL.
Expected outputs - System DB reorganized. - OIDC login working. - ADMIN restore handled by Reorganize if required. - Base Setup completed in Control Center. - Security reviewed via Control Center UI.
Verification checkpoints
[Environment]::GetEnvironmentVariable("AMTSYSTEM","Machine")
Test-Path "<AMT_ROOT>\Sys.ini"
sqlcmd -S localhost -d <SYSTEM_DB> -E -Q "SELECT COUNT(*) AS TableCount FROM sys.tables"
Invoke-WebRequest "<CONTROL_CENTER_URL>" -UseBasicParsing
Guardrail - ✗ Invalid: INSERT INTO AMTSYSUSERINROLE ... ROLEID=2 - ✗ Invalid: INSERT INTO AMTSYSCOMPONENTINROLE - ✓ Correct: use Control Center Security screens, or documented Reorganize /RESTOREADMIN.
Phase 4 — Application Runtime + Run Converted Program
Goal: Register application, reorganize app DB, start runtime components, run converted program.
Required inputs - Converted/generated application output. - Application DB. - Control Center application definition. - Configuration set. - Runtime paths.
Expected outputs - Application registered in Control Center. - Application DB reorganized. - Runtime services configured. - Program run verified.
Verification checkpoints
sqlcmd -S localhost -d <APP_DB> -E -Q "SELECT COUNT(*) AS TableCount FROM sys.tables"
Test-Path "<APP_ROOT>\Binaries"
Get-Service | Where-Object Name -like "*AMT*"
7. Guardrail Layer
Hard rules
•	AMT reference docs override AMT172 guide content.
•	Do not use direct SQL against AMTSYS* tables unless the reference doc explicitly says to.
•	Do not assume role IDs.
•	Do not bypass Setup.exe for repository initialization.
•	Do not bypass AmtReorganize for System/Application DB creation.
•	Do not “repair” Control Center security by database inserts.
•	Do not automate steps until the manual/reference workflow has been proven once.
•	Do not proceed past phase gates without review.
Detection patterns
Flag these as invalid:
INSERT\s+INTO\s+.*AMTSYS
UPDATE\s+.*AMTSYS
DELETE\s+FROM\s+.*AMTSYS
ROLEID\s*=\s*\d+
AMTSYSCOMPONENTINROLE
AMTSYSUSERINROLE
AMTSYSIDENTITYTRANSLATION
bypass\s+Setup\.exe
skip\s+Reorganize
Convert\s+All
Correction patterns
Invalid suggestion	Correct replacement
Insert ADMIN role mapping by SQL	Use Control Center Security UI or documented Reorganize restore admin
Hard-code ROLEID=2	Resolve role via Control Center, not ID
Create repo tables manually	Create empty DB, run Setup.exe
Create system tables manually	Create empty DB, configure Sys.ini, run AmtReorganize
Use Convert All after prior timer issue	Use documented/manual LincToLion Start workflow and record result
“Fix it quickly by SQL”	Stop, identify reference workflow, then proceed
8. Prompt Templates
8.1 Workspace custom instruction: .github/copilot-instructions.md
# AMT175 Setup Assistant Instructions

You are assisting with AMT175 installation and setup.

Authoritative sources:
- AICL
- Control Center documentation
- Reorganize documentation
- Keycloak setup guide
- LincToLion manual
- AMT175 release notes / .NET 10 report

Non-authoritative source:
- AMT172 generated setup guide. Use it only for structure, never for implementation authority.

Rules:
- Do not suggest direct SQL against AMTSYS* tables.
- Do not assume role IDs.
- Do not bypass Setup.exe.
- Do not bypass AmtReorganize.
- Prefer Setup.exe, Reorganize, Control Center, Keycloak, and LincToLion documented workflows.
- Every step must include: authority, inputs, action, verification, expected result, risks.
- If a proposed action differs from reference docs, mark it as ⚠ Review and explain why.
8.2 Phase planning prompt: .github/prompts/amt-phase-plan.prompt.md
---
name: amt-phase-plan
description: Plan an AMT175 install phase using authoritative AMT references
agent: ask
---

Plan Phase ${input:phaseName} for AMT175.

Use only these authorities unless I explicitly attach another reference:
- AICL
- Control Center docs
- Reorganize docs
- Keycloak setup guide
- LincToLion manual
- AMT175 release notes / .NET 10 report

Do not use AMT172 implementation details as authority.

Return:
1. Required inputs
2. Expected outputs
3. Step blocks
4. Verification commands
5. Risks
6. Guardrail checks
7. Stop/go criteria

Do not suggest direct SQL on AMTSYS* tables.
Do not assume role IDs.
Prefer Setup.exe, AmtReorganize, Control Center, Keycloak, and LincToLion documented workflows.
8.3 Step execution prompt: .github/prompts/amt-step-execute.prompt.md
---
name: amt-step-execute
description: Execute one AMT175 guide step safely
agent: ask
---

For this AMT175 step:

${selection}

Check:
- What reference document authorizes it?
- Is it tool/manual/script?
- What exact verification proves it worked?
- Does it violate any guardrail?
- Does it suggest direct SQL into AMTSYS*?
- Does it bypass Setup.exe or Reorganize?

Return:
- Status marker
- Corrected action block
- Verification block
- Any deviation log entry
8.4 Phase review prompt: .github/prompts/amt-phase-review.prompt.md
---
name: amt-phase-review
description: Review completed AMT175 phase against reference docs
agent: ask
---

Review Phase ${input:phaseName}.

Compare:
1. Actions actually taken
2. Reference-doc workflow
3. Verification evidence
4. Deviations
5. Open risks
6. Corrections required before next phase

Rules:
- Do not introduce new implementation ideas unless required to correct a deviation.
- Do not re-open already verified steps unless evidence contradicts them.
- Focus on reducing rework and preventing cyclic prompting.
- If no correction is required, say: "Phase accepted — proceed."
8.5 Good vs bad prompts
Bad:
Fix the Control Center login by inserting the ADMIN user into the right AMTSYS tables.
Good:
Using the Control Center first-use and Reorganize documentation as authority, explain the supported way to map my OIDC identity to ADMIN for initial setup. Do not suggest direct SQL into AMTSYS tables.
Bad:
The role ID was 2 last time; add all component rights with SQL.
Good:
Using the Control Center Security docs, describe the supported UI workflow to grant Control Center administrator permissions. Do not assume role IDs.
Bad:
Skip Setup.exe and create the AMT repository schema manually.
Good:
Using AICL as authority, define the repository DB setup flow: empty DB, Lion.ini, Setup.exe, verification.
9. Lightweight Review Loop
After each phase: - Paste completed steps and logs. - Run /amt-phase-review phaseName=. - Accept only one of: - Phase accepted — proceed. - Phase blocked — correction required. - If blocked, fix only the listed deviations. - Do not re-plan the whole phase unless the reference document changed.
Review log template:
## Review — Phase X

**Result:** Phase accepted | Phase blocked  
**Reference docs checked:**
- <doc>
- <doc>

**Evidence reviewed**
- <log/path/screenshot/command output>

**Deviations**
- None | list

**Corrections before next phase**
- None | list

**Decision**
- Proceed | Stop
10. Quick Execution Checklist
Phase 0 — Preflight
•	AMT175 release/source confirmed
•	AICL available
•	Control Center docs available
•	Reorganize docs available
•	Keycloak guide available
•	LincToLion manual available
•	.NET 10 / VS tooling confirmed
•	DB names agreed
•	Paths agreed
•	Guardrails reviewed
Phase 1 — AMT175 Base Install
•	Empty repository DB created
•	Repository DB collation checked
•	Lion.ini configured
•	Setup.exe run as Administrator
•	Repository tables verified
•	Install paths verified
•	Phase review passed
Phase 2 — SSG Converter STOP POINT
•	Converter inputs staged
•	Settings file created
•	Converter run completed
•	Output counted
•	Errors classified
•	STOP POINT review passed
Phase 3 — Control Center + System DB + Keycloak
•	Empty System DB created
•	AMTSYSTEM set
•	Sys.ini configured
•	System DB reorganized
•	Keycloak realm/client setup completed
•	Appsettings updated
•	Control Center login verified
•	ADMIN restore handled via Reorganize if required
•	Base Setup completed
•	Security configured through UI
•	Phase review passed
Phase 4 — Runtime + Converted Program
•	App DB created
•	App registered in Control Center
•	Configuration set linked
•	App DB reorganized
•	Runtime services configured
•	Converted program run
•	Output verified
•	Bug log updated
________________________________________
Why this fixes the AMT172 problem
This guide keeps the good AMT172 structure — overview, key DBs, phase flow, status markers, verification, quick reference and bug log — while removing the unsafe implementation style. The official Control Center first-use flow instead describes OIDC user creation, the /RESTOREADMIN=<OIDC identity> Reorganize parameter, and Base Setup through Control Center; the security material describes role-based configuration through Control Center rather than role-ID SQL assumptions.

## 11. Local Reference Path

The following path is now treated as a confirmed local fact for this setup model and should be used directly in the VS Code working rules:

```text
C:\Amt\AMT_ReferenceDocuments
This path should be treated as the primary local source location for AMT installation, Control Center, Keycloak, LincToLion, ECL/PowerShell, and site-survey reference material. This is the specific addition from the second document that should be added to the preferred first document without changing the first document’s structure. {5003}
Recommended local source tree:
C:\Amt\AMT_ReferenceDocuments
  AMT157_Online_help
  AMT_LionReferenceDocs
  AMT_EclToPowershell
  AMTSiteSurveyReferenceDocs
This addition is intended to make the VS Code workspace and Copilot prompts point to the correct local source folder instead of relying only on linked SharePoint files or generic “AMT reference docs” language. {5003}
12. Source Priority & Usage
When a step is created for the AMT175 guide, sources should be checked in the following order:
1.	C:\Amt\AMT_ReferenceDocuments\AMT157_Online_help
2.	C:\Amt\AMT_ReferenceDocuments\AMT_LionReferenceDocs
3.	Other folders under C:\Amt\AMT_ReferenceDocuments, including AMT_EclToPowershell and AMTSiteSurveyReferenceDocs {5003}
This preserves the original document’s authority model, but makes the priority explicit and local-folder driven. It also keeps AMT172-Setup-Guide.html in a structural-only role, not an implementation-authority role. {5002}{5003}
Recommended usage rule:
Use online help first when a matching HTML page exists.
If no matching online help page exists, use the Lion reference documents.
If neither exists, use another document from C:\Amt\AMT_ReferenceDocuments.
If no supporting source exists, mark the step as <em>n.cite</em>.
13. Citation Policy
Every generated AMT175 guide step should include exactly one citation. This is the main functional addition from the second document and can be added as a policy section without changing the original document’s earlier flow. {5003}
Citation format
Use this form:
Citation: <relative-path-from-AMT_ReferenceDocuments> — <page/section/heading>
Examples:
Citation: AMT157_Online_help/first-use-of-the-control-center.html — Restore admin
Citation: AMT_LionReferenceDocs/AMT Installation and Configuration (AICL).docx — Running Setup.exe
Citation: AMT_LionReferenceDocs/AMT LincToLion user manual.docx — SQL Server preparations
Citation: <em>n.cite</em>
These examples come directly from the second document’s new citation model. {5003}
Single-citation rule
•	Each step must have exactly one citation.
•	If multiple sources support the step, choose the highest-priority source only.
•	If no supporting source exists, use:
Citation: <em>n.cite</em>
•	Do not use generic citations such as “AMT docs”.
•	Do not cite multiple sources in one step.
•	Do not use AMT172-Setup-Guide.html as a step citation authority. {5003}
Recommended readability tweak for the step template
Because the first document already uses Authority, and because preserving that original layout matters, the cleanest reading is to keep both Authority and Citation rather than replacing Authority. This avoids changing the earlier sections while still adding the new citation behavior. This section therefore adds a recommended refinement rather than rewriting the original template. {5002}{5003}
Recommended future step block format:
### Step X.Y — <Step name>

**Status:** ⌛ Pending  
**Classification:** Tool | Manual | Script  
**Authority:** <reference doc + section>  
**Citation:** <exactly one source, or `<em>n.cite</em>`>  
**Goal:** <what this step achieves>
This keeps the original wording and adds the new traceability field in the least disruptive way. {5003}
14. Updated Copilot Instructions
The first document already includes a Copilot instruction block. To preserve the preferred layout, the cleanest change is to append these as updated rules rather than replace the earlier block. The content below can be added as an addendum section in the document and then copied into the workspace instruction file as needed. {5002}{5003}
Addendum for .github/copilot-instructions.md
## Primary local reference source

The authoritative AMT reference documents are physically located at:
`C:\Amt\AMT_ReferenceDocuments`

## Source priority order

When generating or reviewing any AMT175 guide step, search and cite sources in this order:
1. `C:\Amt\AMT_ReferenceDocuments\AMT157_Online_help`
2. `C:\Amt\AMT_ReferenceDocuments\AMT_LionReferenceDocs`
3. Other folders under `C:\Amt\AMT_ReferenceDocuments`

## Citation rule

Every generated AMT175 guide step must include exactly one citation.

Allowed values:
- `Citation: AMT157_Online_help/first-use-of-the-control-center.html — Restore admin`
- `Citation: <em>n.cite</em>`

Rules:
- Do not write “AMT docs” as a citation.
- Do not cite multiple documents for one step.
- Do not mix online help, AICL, and AMT172 in one citation field.
- If multiple sources support a step, choose the highest-priority source only.
- If the instruction is inferred from experience or from AMT172 structural reuse, mark it as `Citation: <em>n.cite</em>`.
Citation validation rules for prompts and reviews
The following validation logic can be added to planning, execution, and review prompts:
- Each step must have exactly one Citation field.
- More than one citation in a step is invalid.
- Zero citations in a step is invalid.
- Generic citations such as “AMT docs” are invalid.
- If no source is found, the only valid fallback is: Citation: <em>n.cite</em>
Minimal prompt addendum
The following lines can be appended to the existing prompt templates from the first document:
Use only documents from C:\Amt\AMT_ReferenceDocuments.
Provide exactly one citation per step.
Prefer AMT157_Online_help first, then AMT_LionReferenceDocs, then other local reference folders.
If none exists, output: Citation: <em>n.cite</em>.
This preserves the original prompt names and prompt layout from the first document, while adding the newer local-path and citation enforcement rules from the second document. {5003}
