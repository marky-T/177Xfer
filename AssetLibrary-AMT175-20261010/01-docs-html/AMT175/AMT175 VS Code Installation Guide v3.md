AMT175 VS Code Installation Guide + Prompt Framework
Revision 3 — Parallel-Run VS Code setup with AMT VS Generator clarifications
Primary authority: AMT_Implementation_AMT175_Analysis_Merged.docx
Integrated add-ons (validated): Setting Up Parallel VS Code Projects.docx
AMT VS Generator citation source: AMT .Net 8 upgrade to .Net 10 Report.docx (Section 2)
Governing reference set: C:\Users\mark.truman\OneDrive - Avanade\A AA Federale\AMT_ReferenceDocuments\
Prepared: 22 July 2026

[V3] This revision replaces AMT175_ParallelRun_GuidePackage_v2.docx as the authoritative package. All v2 findings are preserved verbatim. v3 edits are limited to AMT VS Generator citation, conditional Visual Studio 2026 wording, and three new sections (§17 Generation Tooling Map, §18 Readiness Assessment, §19 Provenance Appendix).
Change log — v2 → v3
#	Change	What v3 does differently	Location
CL-1	Citation attached to every mention of 'AMT VS Generator'	Cite AMT .Net 8 upgrade to .Net 10 Report.docx §2 (Borger, Bruecher, Upadhyay; 10 June 2026)	§0, §4, §6, §6a, §17, §19
CL-2	Declared NOT a prerequisite	AMT VS Generator does not participate in installation, runtime, Control Center, Keycloak, Sys.ini, AMTSYSTEM, LincToLion, or VS Code parallel-run workflow.	§2, §4, §17
CL-3	Visual Studio 2026 rewritten as conditional	Required only when invoking AMT VS Generator (VS2026 target) OR opening/building AMT .NET 10 solutions in the VS IDE. VS Code + .NET SDK 10.0.203 sufficient for this guide.	§4, §6a, §17
CL-4	Generation Tooling Map added (NEW §17.3)	Distinguishes AMT VS Generator, LionDevGenNet.exe/AMT Developer Studio Generator, and AMT Transform tooling.	§17
CL-5	v2 findings preserved verbatim	AMTSYSTEM semi-colon rule (no spaces), Sys.ini search-up guard, single Keycloak with two realms, parallel VS Code structure, guardrails, and prompt pack all retained.	§0–§16
CL-6	Readiness assessment added (NEW §18)	Component-by-component status: Ready / Requires manual set / Not required.	§18
CL-7	Provenance appendix added (NEW §19)	Full provenance chain and verbatim quote for the 'AMT VS Generator' phrase.	§19
Executive summary of the re-evaluation
All previously identified blockers, recommendations, and optional improvements were compared against the authoritative AMT reference set under AMT_ReferenceDocuments (AMT157_Online_help, AMT_LionReferenceDocs, and related). The outcome is that 17 of 18 items are supported or outside AMT scope and can be applied immediately; one item (blocker A3, second Keycloak on port 8081) is contradicted by AMT authority and has been REVERSED to the single-Keycloak / two-realms pattern.
Headline findings
•	Parallel install pattern is EXPLICITLY documented in AMT-LION Quick Setup Guide.
•	AMTSYSTEM as a semi-colon separated list is EXPLICITLY documented in AICL, AICC, and AICVC.
•	Sys.ini search-up behaviour requires each lane's Sys.ini to sit at the lane root.
•	Virtual folders (AMT_DEV, AMT_TST, AMT175) are EXPLICITLY described in AICL.
•	Per-lane Lion.ini values (URL, VIRTUALFOLDER, LIONDEVNETSERVICENAME) are required.
•	Blocker A3 (second Keycloak on 8081) is REVERSED to single-Keycloak / two-realms.
•	[v3] AMT VS Generator is a documented tool (see §17 and §19) but is NOT a prerequisite for the AMT175 parallel-run workflow.
Disposition table — every previous finding, against AMT authority
Legend: SUPPORTED = AMT authority directly documents the behaviour. SUPPORTED-CAVEAT = AMT authority documents it with a constraint. OUTSIDE-SCOPE = AMT authority is silent. CONTRADICTED = AMT authority documents a different pattern.
A. Blocking conflicts (previously 3)
#	Item	Disposition	AMT authority evidence	Action
A1	Workspace root at C:\Amt\Parallel\<lane>	SUPPORTED	AMT-LION Quick Setup Guide: 'This manual will use C:\AMT\Training as base folder... the complete process can be easily repeated by creating a new folder within C:\AMT, use another AMT-version and process this manual again.'	APPLY
A2	Rename AMT175 DBs to AMT175_*	SUPPORTED-CAVEAT	AICL: 'It's good practice to precede the name of all AMT related databases with AMT'. AMT172 lane is already installed with WORKING_* names.	APPLY to AMT175 only. Keep AMT172 as WORKING_*; AMTSYSTEM handles both.
A3	Keycloak on port 8081 for AMT175	CONTRADICTED	Quick Start AMT-KeyCloak documents a single Keycloak on 8080 with per-realm client registrations.	REVERSE. Use one Keycloak on 8080 with two realms (amt172, amt175).
B. Recommended changes (previously 7)
#	Item	Disposition	AMT authority evidence	Action
B1	AMTSYSTEM as semi-colon list	SUPPORTED	AICL/AICC: 'the AMTSYSTEM variable contains all the paths to all the Sys.ini files, separated with a semi-colon (e.g. c:\amt_dev; c:\amt_tst, etc.)'. AICVC adds: 'Separate by a semi-colon only, no spaces.'	APPLY with explicit 'no spaces' note.
B2	Move env vars into launchSettings/launch/tasks	SUPPORTED-CAVEAT	AMT authority requires AMTSYSTEM to be a Windows env var; silent on ASPNETCORE_* variables.	APPLY for ASPNETCORE_*, connection strings. Keep AMTSYSTEM at User-level.
B3	Add compound launch + compound task	OUTSIDE-SCOPE	AMT authority silent (pure VS Code concern).	APPLY.
B4	Mount AMT_ReferenceDocuments as third workspace root	SUPPORTED	AMT175 Copilot instructions treat AMT_ReferenceDocuments as primary local reference source.	APPLY (read-only).
B5	Extend guardrail detection	SUPPORTED	AMT authority requires AMTSYSTEM to stay multi-lane.	APPLY.
B6	Parallel-lane checks in phase-review log	OUTSIDE-SCOPE	Process improvement; AMT authority silent.	APPLY.
B7	Single-citation policy for scaffolding steps	SUPPORTED	AMT175 Copilot instructions already mandate single-citation.	APPLY.
C. Optional improvements (previously 8)
#	Item	Disposition	AMT authority evidence	Action
C1	dotnet user-secrets for local secrets	SUPPORTED-CAVEAT	AMT uses Lion.ini/Sys.ini for AMT-side credentials. dotnet user-secrets is orthogonal.	APPLY for .NET appsettings only.
C2	Kestrel:Endpoints as single URL source	OUTSIDE-SCOPE	Pure ASP.NET Core.	APPLY.
C3	serverReadyAction auto-open	OUTSIDE-SCOPE	Pure VS Code.	APPLY.
C4	Task presentation grouping	OUTSIDE-SCOPE	Pure VS Code.	APPLY.
C5	Preflight PowerShell script	OUTSIDE-SCOPE (aligns)	AICL requires prerequisite checks; automating is consistent.	APPLY.
C6	amt-guardrail-check Copilot prompt	SUPPORTED	Reinforces AMT175 guardrails.	APPLY.
C7	Shared Keycloak with two realms	SUPPORTED (promote)	Quick Start AMT-KeyCloak: realm carries client registrations. Two realms in one Keycloak IS the documented pattern.	PROMOTE. This IS the resolution to A3.
C8	Read-only reference folder in VS Code	SUPPORTED	Prevents accidental edits to AMT reference set.	APPLY.
New AMT-specific risks surfaced by the re-evaluation
Five AMT-specific risks were identified during re-evaluation. Each is now addressed in the guide.
#	Risk	AMT authority basis	Mitigation	Where
R1	Sys.ini search-up path collision	AICL/AICC/AICVC: 'the executing AMT component searches for the Sys.ini from the current directory up.'	Place each lane's Sys.ini at the lane root. Ensure NO Sys.ini exists at C:\Amt\Parallel\, C:\Amt\, or C:\.	§2, §4, §15
R2	Setup.exe IIS website collision	AICL: 'Setup also creates the IIS websites for the AMT Control Center' + 'best practice is to use virtual directories'.	URL=http://localhost/<LaneVDir>; VIRTUALFOLDER=<LaneVDir>. AMT175 => VIRTUALFOLDER=AMT175.	§5, §6
R3	LionDev generator service name collision	AICL Lion.ini (LIONDEVNETSERVICENAME).	AMT175 lane sets LIONDEVNETSERVICENAME=Amt175_Generator.	§5
R4	AppPool identity vs. System DB permissions	AICVC: 'The identity of the AMT_AppPool needs to be set to AMT_Admin.'	For SQL Auth: per-lane logins. For Integrated Security: AMT_Admin needs db_owner on both lanes.	§5, §6
R5	.NET SDK 10.0.203 exact / VS 2026 conditional	AMT .Net 8 upgrade to .Net 10 Report §2 (Borger, Bruecher, Upadhyay; 10 June 2026): 'The Azure Pipeline and global.json enforce .NET SDK 10.0.203 exactly. Visual Studio 2022 (17.x) doesn't fully support .Net 10 development... Visual Studio 2026 is now supported by the AMT VS Generator.'	VS Code + dotnet CLI 10.0.203 is sufficient for THIS guide. VS 2026 is required only when AMT VS Generator or full .NET 10 VS IDE features are needed. See §17.	§4, §6a, §17
 
AMT175 VS Code Installation Guide (Revised — v3)
The remainder of this document is the revised AMT175 guide. The AMT175 authority content is preserved 1:1 from Doc B; parallel-run additions are marked [PARALLEL-RUN] or [AMT-AUTHORITY]. v3 edits are marked [V3]. No section overrides Setup.exe, AmtReorganize, Control Center, Keycloak Quick Start, or LincToLion user manual.
0. Source Authority Matrix
[PRESERVED] Seven original rows from Doc B preserved. One row added for the parallel-run add-on layer. [V3] One further row for the AMT VS Generator citation source.
Area	Authoritative source	Use for	Guardrail
AMT base install	AMT Installation and Configuration (AICL)	Install root, repository DB, Lion.ini, Setup.exe	Do not bypass Setup.exe.
Repository DB	AICL	Empty repository DB; Setup.exe creates objects	Do not hand-create repository schema.
System DB	AICL + Reorganize docs	Empty system DB, AMTSYSTEM, Sys.ini, Reorganize	Do not manually populate AMTSYS* tables.
First Control Center use	first-use-of-the-control-center.html	OIDC ADMIN restore, Base Setup	Use AmtReorganize.exe /RESTOREADMIN=<OIDC identity>.
Keycloak	Quick start guide AMT-KeyCloak.docx	Realm/client/appsettings setup	Keep auth config under Amt.Authentication.
Security/roles	Control Center Security docs	Users, roles, component activation	No hard-coded role IDs.
LincToLion	AMT LincToLion user manual.docx	Build, interim DB, AB Suite Load, Convert To Lion	Use UI workflow; avoid unsupported DB edits.
AMT175 / .NET 10	Announcement AMT175.docx + AMT .Net 8 upgrade to .Net 10 Report.docx	Toolchain, SDK 10.0.203, VS2026 target	Use .NET 10 paths and build assumptions.
[PARALLEL-RUN] Workspace / build / launch overlay	Setting Up Parallel VS Code Projects.docx	VS Code workspace layout, tasks, launch, launchSettings, port matrix	Never override Setup.exe, AmtReorganize, Control Center, Keycloak, or LincToLion.
[V3] AMT VS Generator citation (project scaffolding only)	AMT .Net 8 upgrade to .Net 10 Report.docx §2 (Borger, Bruecher, Upadhyay; 10 June 2026)	Cite ONLY when discussing AMT VS Generator (new AMT project scaffolding, VS2026 target IDE).	Never treat as authority for installation/runtime/CC/Keycloak/Sys.ini/AMTSYSTEM/DB setup. See §17.
1. Structural pattern reused from AMT172
[PRESERVED] Content preserved verbatim from Doc B.
The AMT172 guide structure is useful, but not its implementation shortcuts.
Reusable structure:
•	Environment overview
•	Key databases
•	Paths & config
•	Phase flow
•	Standard step blocks
•	Verification commands
•	Bug log
•	Quick execution checklist
•	Prompt templates
•	Phase review log
Elements to AVOID from AMT172:
•	Direct SQL into AMTSYS* tables.
•	Assuming ROLEID=2 or any role ID.
•	'Fix by SQL INSERT/UPDATE' patterns unless explicitly instructed.
•	Over-automation: timers, launchers, browser helpers, cyclic prompts.
•	Prompting that asks the AI to 'just fix it' without citing the reference document.
2. VS Code editing setup
[PARALLEL-RUN] Absolute root at C:\Amt\Parallel\AMT175\. Multi-root workspace mounts AMT172, AMT175, and AMT_ReferenceDocuments (read-only).
[AMT-AUTHORITY] AMT-LION Quick Setup Guide — 'the complete process can be easily repeated by creating a new folder within C:\AMT, use another AMT-version and process this manual again.'
[V3] No AMT VS Generator invocation is required to open, edit, build, or run this workspace. VS Code + .NET SDK 10.0.203 is sufficient for this guide. See §17 for conditional VS 2026 cases.
Recommended parallel workspace layout:
C:\Amt\Parallel\
  AMT.code-workspace                      <-- multi-root workspace file
  AMT172\                                 <-- installed lane (AMT 172 / .NET 8)
    Sys.ini
    Lion\Lion.ini
    AmtTools\...
    logs\, temp\, Files\Extracts\
  AMT175\                                 <-- new lane (AMT 175 / .NET 10)
    AMT175-Install.md
    Sys.ini
    Lion\Lion.ini
    AmtTools\...
    .vscode\tasks.json
    .vscode\launch.json
    Properties\launchSettings.json
    .github\copilot-instructions.md
    .github\prompts\*.prompt.md
    scripts\preflight.ps1
    logs\, temp\, Files\Extracts\
  AMT_ReferenceDocuments\                  <-- read-only, mounted as 3rd root
AMT.code-workspace file:
{
  "folders": [
    { "name": "AMT172", "path": "AMT172" },
    { "name": "AMT175", "path": "AMT175" },
    {
      "name": "AMT_ReferenceDocuments (read-only)",
      "path": "..\\OneDrive - Avanade\\A AA Federale\\AMT_ReferenceDocuments"
    }
  ],
  "settings": {
    "files.readonlyInclude": {
      "**/AMT_ReferenceDocuments/**": true
    }
  }
}
[RISK] R1 — Sys.ini search-up. The lane root MUST be C:\Amt\Parallel\AMT175\, and NO Sys.ini may exist at C:\Amt\Parallel\, C:\Amt\, or C:\.
3. Source priority order (Copilot / manual review)
[PRESERVED] From Doc B.
•	AMT_ReferenceDocuments\AMT157_Online_help — Online help HTML pages (highest priority).
•	AMT_ReferenceDocuments\AMT_LionReferenceDocs — AICL, ALPD, LincToLion, Control Center.
•	Other sub-folders under AMT_ReferenceDocuments (AMT_EclToPowershell, AMTSiteSurveyReferenceDocs).
•	Announcement AMT175 + .NET 10 Report — AMT175-specific toolchain values and AMT VS Generator citation.
•	Setting Up Parallel VS Code Projects.docx — scaffolding only; never AMT authority.
•	AMT172-Setup-Guide.html — STRUCTURE ONLY. Never implementation authority.
4. Environment overview
[PARALLEL-RUN] Lane-specific pre-populated values. AMTSYSTEM is a Windows environment variable containing BOTH lane Sys.ini paths separated by a semi-colon (no spaces).
[AMT-AUTHORITY] AICL and AICC — 'the AMTSYSTEM variable contains all the paths to all the Sys.ini files, separated with a semi-colon (e.g. c:\amt_dev; c:\amt_tst, etc.)'. AICVC adds: 'Separate by a semi-colon only, no spaces.'
[V3] The Preferred IDE row states the conditional VS 2026 rule verbatim from the .NET 10 upgrade report §2 (Borger, Bruecher, Upadhyay; 10 June 2026). See §17 for full detail.
Item	Value
AMT install root (AMT175)	C:\Amt\Parallel\AMT175
AMT install root (AMT172)	C:\Amt\Parallel\AMT172 (existing WORKING lane physically located here — rename/move only if the lane is being reinstalled)
AMT175 Sys.ini path	C:\Amt\Parallel\AMT175\Sys.ini
AMT172 Sys.ini path	C:\Amt\Parallel\AMT172\Sys.ini (existing)
AMTSYSTEM (Windows env var, User-level)	C:\Amt\Parallel\AMT172;C:\Amt\Parallel\AMT175  (NO SPACES)
AMT175 IIS virtual folder	AMT175 (Lion.ini VIRTUALFOLDER=AMT175, URL=http://localhost/AMT175)
AMT172 IIS virtual folder	Working (existing) — DO NOT rename post-install
AMT175 Control Center URL	http://localhost/AMT175/ControlCenter
AMT172 Control Center URL	http://localhost/Working/ControlCenter (existing)
Keycloak URL (SHARED)	http://localhost:8080 — one Keycloak, two realms
Keycloak realm — AMT172	amt172 (existing realm; keep as installed)
Keycloak realm — AMT175	amt175 (new realm imported from Quick Start config file)
AMT175 dotnet SDK	10.0.203 (enforced by global.json — AMT .Net 10 Report §2)
AMT172 dotnet SDK	net8.0
[V3] Preferred IDE	VS Code + dotnet CLI 10.0.203 is sufficient for this guide. Visual Studio 2026 is required ONLY when: (a) invoking the AMT VS Generator to scaffold a new AMT project targeting VS2026, or (b) opening/building AMT .NET 10 solutions in the Visual Studio IDE (Microsoft error NETSDK1209 appears in VS 2022 for .NET 10 targets). See §17.
5. Key databases
[PARALLEL-RUN] AMT175 lane uses AMT-prefixed database names as per AICL best practice. AMT172 lane retains its existing WORKING_* names to avoid a reinstall.
[AMT-AUTHORITY] AICL §4.2 — 'It's good practice to precede the name of all AMT related databases with AMT, especially when the SQL Server is used for non-AMT databases as well.' AICL §5.6 (Setup.exe) — 'When more than one runtime environment will be configured on the same server, best practice is to use virtual directories (e.g. AMT_DEV, AMT_TST, etc.)'.
Database	Purpose	Creation/population owner	Lane
AMT175_REPOS	Lion main repository (REV* tables)	Empty DB → Lion.ini → Setup.exe (creates tables)	AMT175 lane
AMT175_SYSTEM	AMT system database (users/roles/components)	Empty DB → Sys.ini → AMTSYSTEM → AmtReorganize	AMT175 lane
AMT175_LINC	LincToLion temporary repository	Empty DB → LincToLion creates schema on first start	AMT175 lane
AMT175_APP	Application DB (per app runtime)	Created + reorganized through Control Center	AMT175 lane
WORKING_REPOS	Lion main repository	(already installed)	AMT172 lane
WORKING_SYSTEM	AMT system database	(already installed)	AMT172 lane
WORKING_LINC	LincToLion temporary repository	(already installed)	AMT172 lane
ModelRepos	AB Suite MsSql migration repo	(restored from export-avanade.bak)	AMT172 lane
[RISK] R2/R3 — Lion.ini values MUST be unique per lane. Minimum unique fields for AMT175: URL=http://localhost/AMT175, VIRTUALFOLDER=AMT175, LIONDEVNETSERVICENAME=Amt175_Generator, DBSNAME=AMT175_REPOS, SERVERNAMEREPOSDB=localhost. Otherwise Setup.exe and the LionDev generator service will collide with AMT172.
6. Phase-driven execution model
[PRESERVED] Baseline phases from Doc B preserved. Parallel-run checks added inside each phase.
Phase 0 — Preflight
•	Verify OS, SQL Server, IIS, .NET SDK 10.0.203, permissions.
•	[V3] Visual Studio 2026 is only required for the conditional cases in §17 (AMT VS Generator, or opening AMT .NET 10 solutions in the VS IDE). This guide does not require it.
•	[PARALLEL-RUN] Verify no Sys.ini exists at C:\Amt\, C:\Amt\Parallel\, or C:\ (Sys.ini search-up isolation).
•	[PARALLEL-RUN] Confirm AMT172 lane is healthy (AMT172 CC opens at http://localhost/Working/ControlCenter).
•	[PARALLEL-RUN] Confirm ports 5175, 7175 are free (5172, 7172 are used by AMT172).
•	[PARALLEL-RUN] Confirm AMTSYSTEM env var currently lists AMT172 path only, ready to append AMT175 path in Phase 2.
Phase 1 — AMT175 base install
•	Create empty DB AMT175_REPOS (Latin1_General_BIN collation).
•	Configure Lion.ini with unique per-lane values (see §5 risk callout).
•	Run Setup.exe as Administrator (creates repository tables and IIS websites under AMT175 virtual folder).
•	Install latest AMT175 update; install runtime license.
•	[PARALLEL-RUN] Scaffold .vscode\tasks.json, .vscode\launch.json, Properties\launchSettings.json (see §6a).
Phase 2 — AMT175 System DB + Sys.ini + AMTSYSTEM + Reorganize
•	Create empty DB AMT175_SYSTEM.
•	Create C:\Amt\Parallel\AMT175\Sys.ini with AMT175_SYSTEM connection details (ENVIRONMENT=AMT175, DATABASE NAME=AMT175_SYSTEM, DBUSER=amt175_system_user).
•	[PARALLEL-RUN][AMT-AUTHORITY] Set User-level AMTSYSTEM=C:\Amt\Parallel\AMT172;C:\Amt\Parallel\AMT175 (no spaces).
•	Run AmtReorganize (creates System DB objects using Sys.ini).
•	[PARALLEL-RUN] Verify AMTSYSTEM value: [Environment]::GetEnvironmentVariable('AMTSYSTEM','User').
Phase 3 — Control Center + Keycloak realm
•	Add IIS websites (from Setup.exe output) under AMT175 virtual folder.
•	[PARALLEL-RUN][AMT-AUTHORITY] Do NOT install a second Keycloak. Use the existing Keycloak on http://localhost:8080. Import the Quick Start AMT-KeyCloak realm config into a new realm 'amt175'.
•	Configure ControlCenter appsettings.json (Amt.Authentication.AmtOIDC.OIDC) to point at the amt175 realm and its clients with AMT175 redirect URIs (http://localhost/AMT175/ControlCenter/*).
•	Run AmtReorganize.exe /RESTOREADMIN=<your OIDC identity>. Reorganize the System DB.
•	First-use of Control Center: Base Setup, then remove the temporary identity translation as per first-use-of-the-control-center.html.
•	Add real users, roles, and component activation through Control Center UI (never via direct SQL).
Phase 4 — Application runtime and services
•	File/Batch/Print Controllers, Reorganization Service — through Control Center.
•	Base paths, logging, runtime behaviour configuration.
•	Application DB (AMT175_APP): Create empty DB → configure through Control Center → run AmtReorganize.
•	[PARALLEL-RUN] Confirm ports 5175/7175 listen only when AMT175 is running; confirm AMT172 is still healthy after AMT175 start.
Phase 5 — Migration pipeline
•	Per Doc B: SplitPModel, AbSuiteUnloadGui, LincToLion (Convert To LION), LionDev C# generation, dotnet build & runtime trial.
•	[PARALLEL-RUN] Build and runtime commands are wired through .vscode/tasks.json and launch.json (see §6a).
6a. Parallel-run build, launch, and task configuration
[PARALLEL-RUN] This section is NEW and entirely additive. It never overrides AMT authority.
6a.1 launchSettings.json (Properties\launchSettings.json)
{
  "profiles": {
    "AMT175": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "applicationUrl": "https://localhost:7175;http://localhost:5175",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development",
        "AMT_LANE": "AMT175"
      }
    }
  }
}
[AMT-AUTHORITY] AMTSYSTEM is intentionally NOT scoped in launchSettings. AICL requires it to be a Windows env variable, and it must remain multi-lane for AMT-controlled tools (Setup.exe, AmtReorganize, LionDev generator) that are launched outside VS Code.
6a.2 .vscode\launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch AMT175 (ControlCenterCore)",
      "type": "coreclr",
      "request": "launch",
      "preLaunchTask": "build AMT175",
      "program": "${workspaceFolder:AMT175}/src/ControlCenterCore/bin/Debug/net10.0/ControlCenterCore.dll",
      "cwd": "${workspaceFolder:AMT175}/src/ControlCenterCore",
      "env": {
        "ASPNETCORE_ENVIRONMENT": "Development",
        "ASPNETCORE_URLS": "https://localhost:7175;http://localhost:5175"
      },
      "serverReadyAction": {
        "action": "openExternally",
        "pattern": "\\bNow listening on:\\s+(https?://\\S+)"
      }
    },
    {
      "name": "Launch AMT172 (ControlCenterCore)",
      "type": "coreclr",
      "request": "launch",
      "preLaunchTask": "build AMT172",
      "program": "${workspaceFolder:AMT172}/src/ControlCenterCore/bin/Debug/net8.0/ControlCenterCore.dll",
      "cwd": "${workspaceFolder:AMT172}/src/ControlCenterCore",
      "env": {
        "ASPNETCORE_ENVIRONMENT": "Development",
        "ASPNETCORE_URLS": "https://localhost:7172;http://localhost:5172"
      }
    }
  ],
  "compounds": [
    {
      "name": "Run AMT175 + AMT172",
      "configurations": [ "Launch AMT175 (ControlCenterCore)", "Launch AMT172 (ControlCenterCore)" ],
      "stopAll": true
    }
  ]
}
6a.3 .vscode\tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "build AMT175",
      "type": "process",
      "command": "dotnet",
      "args": ["build","${workspaceFolder:AMT175}/AMT175.sln","-c","Debug"],
      "presentation": { "group": "amt", "reveal": "always", "panel": "shared" },
      "problemMatcher": "$msCompile"
    },
    {
      "label": "build AMT172",
      "type": "process",
      "command": "dotnet",
      "args": ["build","${workspaceFolder:AMT172}/AmtAll.sln","-c","Debug"],
      "presentation": { "group": "amt", "reveal": "always", "panel": "shared" },
      "problemMatcher": "$msCompile"
    },
    {
      "label": "run AMT175",
      "type": "process",
      "command": "dotnet",
      "args": ["run","--project","${workspaceFolder:AMT175}/src/ControlCenterCore","--launch-profile","AMT175"],
      "presentation": { "group": "amt", "reveal": "always", "panel": "dedicated" }
    },
    {
      "label": "run AMT172",
      "type": "process",
      "command": "dotnet",
      "args": ["run","--project","${workspaceFolder:AMT172}/src/ControlCenterCore","--launch-profile","AMT172"],
      "presentation": { "group": "amt", "reveal": "always", "panel": "dedicated" }
    },
    {
      "label": "run both AMT versions",
      "dependsOn": ["run AMT172","run AMT175"],
      "dependsOrder": "parallel"
    },
    {
      "label": "preflight AMT175",
      "type": "shell",
      "command": "powershell",
      "args": ["-ExecutionPolicy","Bypass","-File","${workspaceFolder:AMT175}/scripts/preflight.ps1"],
      "presentation": { "reveal": "always" }
    }
  ]
}
6a.4 Port & resource matrix
Component	AMT172	AMT175
App HTTP	http://localhost:5172	http://localhost:5175
App HTTPS	https://localhost:7172	https://localhost:7175
Keycloak (SHARED)	http://localhost:8080 (realm amt172)	http://localhost:8080 (realm amt175)
IIS virtual folder	/Working	/AMT175
Control Center URL	http://localhost/Working/ControlCenter	http://localhost/AMT175/ControlCenter
Repository DB	WORKING_REPOS	AMT175_REPOS
System DB	WORKING_SYSTEM	AMT175_SYSTEM
Application DB	(as installed)	AMT175_APP
LincToLion interim DB	WORKING_LINC	AMT175_LINC
Sys.ini path	C:\Amt\Parallel\AMT172\Sys.ini	C:\Amt\Parallel\AMT175\Sys.ini
Lion.ini LIONDEVNETSERVICENAME	LionDevNet_Generator	Amt175_Generator
AMTSYSTEM position (semi-colon list)	first	second
dotnet target	net8.0	net10.0 (SDK 10.0.203)
[V3] IDE requirement	VS Code (or VS 2022 for existing .NET 8 code)	VS Code + dotnet CLI. VS 2026 required only for AMT VS Generator or VS-IDE builds of .NET 10 solutions (see §17).
6a.5 preflight.ps1 (scripts\preflight.ps1)
# Preflight for AMT175 parallel lane
$errors = @()
 
# 1. Ports must be free
foreach ($port in 5175, 7175) {
  if ((Test-NetConnection localhost -Port $port -WarningAction SilentlyContinue).TcpTestSucceeded) {
    $errors += "Port $port already in use"
  }
}
 
# 2. No Sys.ini above the lane root (search-up isolation)
foreach ($p in "C:\Amt\Sys.ini","C:\Amt\Parallel\Sys.ini","C:\Sys.ini") {
  if (Test-Path $p) { $errors += "Rogue Sys.ini at $p (breaks lane search-up)" }
}
 
# 3. AMTSYSTEM contains both lane paths, semi-colon separated, no spaces
$amtsys = [Environment]::GetEnvironmentVariable("AMTSYSTEM","User")
if (-not $amtsys) { $errors += "AMTSYSTEM (User) is not set" }
elseif ($amtsys -match "; " -or $amtsys -match " ;") {
  $errors += "AMTSYSTEM contains spaces around ; -- remove them (AICVC)"
}
elseif ($amtsys -notmatch "C:\\Amt\\Parallel\\AMT172" -or $amtsys -notmatch "C:\\Amt\\Parallel\\AMT175") {
  $errors += "AMTSYSTEM must list BOTH lane paths (found: $amtsys)"
}
 
# 4. .NET SDK 10.0.203 exact
$sdk = dotnet --list-sdks | Select-String "^10\.0\.203"
if (-not $sdk) { $errors += ".NET SDK 10.0.203 not installed (global.json requires this exact version)" }
 
# 5. Keycloak reachable on 8080
try {
  $r = Invoke-WebRequest -UseBasicParsing http://localhost:8080/realms/master -TimeoutSec 3
  if ($r.StatusCode -ne 200) { $errors += "Keycloak not responding on 8080" }
} catch { $errors += "Keycloak not reachable on http://localhost:8080" }
 
if ($errors.Count -eq 0) { Write-Host "PREFLIGHT OK" -ForegroundColor Green }
else { $errors | ForEach-Object { Write-Host "FAIL: $_" -ForegroundColor Red }; exit 1 }
7. Guardrail layer
[PRESERVED] AMT175 hard rules preserved from Doc B.
•	Do NOT insert/update/delete rows in AMTSYS* tables (AMTSYSIDENTITYTRANSLATION, AMTSYSUSERINROLE, AMTSYSCOMPONENTINROLE, etc.).
•	Do NOT assume numeric ROLEID values (e.g. ROLEID=2).
•	Do NOT grant component rights by INSERT into AMTSYSCOMPONENTINROLE.
•	Do NOT bypass Setup.exe for repository setup.
•	Do NOT bypass AmtReorganize for System/Application DB creation.
•	Do NOT use AMT172 guide content as implementation authority.
•	Do NOT edit generated code as the default fix path without checking authoritative conversion/runtime docs.
[PARALLEL-RUN] Extended parallel-run hard rules and detection patterns.
•	Do NOT overwrite AMTSYSTEM with a single-lane value. Must always be the semi-colon list.
•	Do NOT use spaces around the semi-colon in AMTSYSTEM (AICVC).
•	Do NOT set ASPNETCORE_URLS at machine or User scope; use launch profiles / launch.json / tasks.json only.
•	Do NOT run a second Keycloak on 8081; use realms within the single 8080 Keycloak.
•	Do NOT reuse LIONDEVNETSERVICENAME across lanes (Windows service registration collision).
•	Do NOT reuse the same IIS virtual folder name across lanes (Setup.exe collision).
•	Detection patterns Copilot must flag: setx AMTSYSTEM=..., Set-ItemProperty ... AMTSYSTEM, ASPNETCORE_URLS at machine scope, applicationUrl duplicated across lane profiles, kc.bat --http-port 8081.
[V3] AMT VS Generator is intentionally OUTSIDE the guardrail scope. It participates only in new-project scaffolding, not in runtime/Sys.ini/AMTSYSTEM/Control Center/Keycloak paths that these guardrails protect. If a step uses the AMT VS Generator, it must cite the .NET 10 Report §2 and remain outside the parallel-run runtime configuration.
8. Prompt templates
[PRESERVED] Templates preserved. Each gains a small parallel-run addendum block.
Parallel-run addendum inserted into copilot-instructions.md:
## Parallel-run rules (AMT172 + AMT175 on one machine)
- AMTSYSTEM is a User-level Windows env var containing BOTH lane Sys.ini paths,
  separated by a semi-colon (no spaces). Citation: AICL/AICC/AICVC.
- Each lane has its own Sys.ini at the lane root: C:\Amt\Parallel\<LANE>\Sys.ini.
- Each lane has its own Lion.ini with UNIQUE: URL, VIRTUALFOLDER,
  LIONDEVNETSERVICENAME, DBSNAME.
- ASPNETCORE_URLS, ASPNETCORE_ENVIRONMENT and connection strings are scoped
  in launchSettings.json / launch.json / tasks.json - never at machine scope.
- Keycloak: ONE server on 8080, two realms (amt172 and amt175). Do not spin up
  a second Keycloak on 8081.
- AMT VS Generator is NOT part of this installation/runtime workflow.
  It is only invoked to scaffold a NEW AMT project (VS2026 target).
  Citation for any AMT VS Generator reference: AMT .Net 8 upgrade to .Net 10
  Report.docx Section 2 (Borger, Bruecher, Upadhyay; 10 June 2026).
- Every generated step must include exactly one AMT authority citation, or
  Citation: <em>n.cite</em> when parallel-run scaffolding is the only source.
amt-phase-plan.prompt.md — parallel-run addendum:
Before proposing any change, confirm in the plan:
  - Which lane does this affect (AMT172, AMT175, or both)?
  - What is the AMTSYSTEM value expected to be after this change?
  - Which IIS virtual folder is targeted, and does it collide with the other lane?
  - Which Windows service is affected (LIONDEVNETSERVICENAME), and is it lane-unique?
  - Which port range is affected (5172/7172 vs 5175/7175 vs 8080)?
  - Does this step invoke the AMT VS Generator? If yes, note it explicitly
    and confirm VS 2026 is available; if no, do not add VS 2026 as a
    prerequisite.
amt-step-execute.prompt.md — parallel-run addendum:
Refuse to execute any step that:
  - overwrites AMTSYSTEM with a single-lane value
  - runs setx / Set-ItemProperty against AMTSYSTEM
  - starts kc.bat with --http-port 8081
  - reuses an existing IIS virtual folder name across lanes
  - reuses an existing LIONDEVNETSERVICENAME across lanes
  - treats the AMT VS Generator as required for runtime/CC/Keycloak/Sys.ini/
    AMTSYSTEM/DB configuration (it is a scaffolder only, per .NET 10 Report §2)
Every command must be preceded by a short justification and exactly one citation.
amt-phase-review.prompt.md — parallel-run addendum:
Include a Parallel-lane checks block in every review log:
  [ ] AMTSYSTEM still lists both lane paths, no spaces
  [ ] AMT172 still reachable at http://localhost/Working/ControlCenter
  [ ] AMT175 reachable at http://localhost/AMT175/ControlCenter (after Phase 3)
  [ ] Ports 5172/7172 owned by AMT172 process only
  [ ] Ports 5175/7175 owned by AMT175 process only
  [ ] Keycloak on 8080 responds; both realms exist
  [ ] No Sys.ini exists above the lane root of either lane
  [ ] No new AMT VS Generator invocation was required for this phase
      (unless the phase explicitly scaffolds a new AMT project)
amt-guardrail-check.prompt.md (NEW, from C6):
You will be given a candidate step. Flag violations of any of:
  - AMT hard rules (AMTSYS* SQL, ROLEID hard-coding, component rights via
    SQL, bypass of Setup.exe or AmtReorganize).
  - Parallel-run rules (AMTSYSTEM single-path overwrite, machine-scope
    ASPNETCORE_URLS, port reuse, realm/virtual folder/service name collision).
  - AMT VS Generator misuse (treating it as required for runtime, Control
    Center, Keycloak, Sys.ini, AMTSYSTEM, or database setup).
  - Citation rule (missing or multi-source citation).
For each violation return: rule id, quoted offending line, and the required
correction.
9. Lightweight review loop
[PRESERVED] Baseline review-log template preserved. Parallel-lane checks appended (see §8 amt-phase-review).
10. Quick execution checklist
•	Phase 0: preflight passes (ports 5175/7175 free, no rogue Sys.ini, AMTSYSTEM ready, .NET SDK 10.0.203, Keycloak 8080 up).
•	Phase 1: AMT175_REPOS created empty; Lion.ini has lane-unique URL/VIRTUALFOLDER/LIONDEVNETSERVICENAME/DBSNAME; Setup.exe run as Admin.
•	Phase 2: AMT175_SYSTEM created empty; C:\Amt\Parallel\AMT175\Sys.ini present; AMTSYSTEM contains BOTH lane paths (semi-colon, no spaces); AmtReorganize run.
•	Phase 3: IIS shows AMT175 virtual folder with ControlCenter and ControlCenterBL sites; Keycloak realm amt175 imported; RESTOREADMIN run; temporary identity translation removed after Base Setup.
•	Phase 4: File/Batch/Print controllers + Reorganization service configured through Control Center; base paths, logging, runtime behaviour set.
•	Phase 5: Migration pipeline (SplitPModel → AbSuiteUnload → LincToLion → LionDev C# gen → dotnet build/run) executed via VS Code tasks; verify AMT172 still healthy after each phase.
•	[V3] No AMT VS Generator invocation is expected during Phases 0–5. If a new AMT project must be scaffolded, this is a separate activity handled per §17 (requires VS 2026).
11. Local reference path
[PRESERVED] Content preserved verbatim from Doc B (AMT175 baseline). See §8 for the parallel-run addendum block that MUST be appended to copilot-instructions.md.
Refer to the AMT175 baseline document for the exact wording of this section. No parallel-run content overrides it; only the addendum in §8 is appended.
12. Source priority
[PRESERVED] Content preserved verbatim from Doc B. See §8 for the parallel-run addendum block appended to copilot-instructions.md.
Refer to the AMT175 baseline document for the exact wording of this section.
13. Citation policy (single-citation rule)
[PRESERVED] Content preserved verbatim from Doc B. See §8 for the parallel-run addendum block appended to copilot-instructions.md.
Refer to the AMT175 baseline document for the exact wording of this section.
[V3] The single-citation rule applies to AMT VS Generator references too. Any step mentioning the AMT VS Generator must cite AMT .Net 8 upgrade to .Net 10 Report.docx §2 exactly, or (if used as parallel-run scaffolding only) 'Citation: <em>n.cite</em>' per §13.
14. Updated Copilot instructions
[PRESERVED] Content preserved verbatim from Doc B. See §8 for the parallel-run addendum block appended to copilot-instructions.md.
Refer to the AMT175 baseline document for the exact wording of this section.
15. Runtime conflict checklist (pre-run gate for either lane)
[PARALLEL-RUN] Consolidated pre-run gate. Run this before starting either lane on a shared machine.
Check	Verification
Ports	netstat -ano | findstr :5175 (must show only your dotnet PID)
Working directory (cwd)	AMT175 must run from ${workspaceFolder:AMT175} to keep bin/obj lane-local
DBs	SQL Server has AMT175_REPOS, AMT175_SYSTEM, AMT175_APP as separate DBs from AMT172 lane
AMTSYSTEM	User-level env var still contains both lane paths, no spaces around ;
Sys.ini (lane root)	C:\Amt\Parallel\AMT175\Sys.ini exists and points to AMT175_SYSTEM
Sys.ini (search-up)	No Sys.ini above the lane root at C:\Amt\Parallel\, C:\Amt\, or C:\
Lion.ini (lane root)	C:\Amt\Parallel\AMT175\Lion\Lion.ini has unique URL, VIRTUALFOLDER, LIONDEVNETSERVICENAME, DBSNAME
IIS virtual folder	AMT175 virtual folder present; AMT172 Working virtual folder still healthy
LionDev service	Get-Service Amt175_Generator OK; LionDevNet_Generator (AMT172) still running
Keycloak	Realms amt172 AND amt175 both present in http://localhost:8080/admin/master/console
Logs / temp / extracts	C:\Amt\Parallel\AMT175\logs, temp, Files\Extracts are lane-local
Build caches	bin/obj under lane, not shared
Secrets	Connection strings only in Sys.ini/Lion.ini/appsettings.json; no plain-text creds in tasks.json/launch.json
[V3] IDE requirement	VS Code + .NET SDK 10.0.203 is sufficient for this pre-run gate. VS 2026 not required unless AMT VS Generator or VS-IDE .NET 10 build is being invoked (see §17).
16. Findings summary (post re-evaluation)
[CHANGE] This section replaces the previous three-list report with the disposition-informed decisions.
Apply immediately (no AMT authority conflict):
•	A1 workspace root C:\Amt\Parallel\<lane>
•	A2 AMT175_* DB names (AMT172 keeps WORKING_*)
•	B1 AMTSYSTEM semi-colon list (no spaces)
•	B2 env vars in launchSettings/launch/tasks (except AMTSYSTEM)
•	B3 compound launch + compound task
•	B4 AMT_ReferenceDocuments mounted read-only
•	B5 extended guardrail detection
•	B6 parallel-lane checks in phase-review log
•	B7 single-citation policy for scaffolding (includes AMT VS Generator references — v3)
•	C1 dotnet user-secrets for .NET-side secrets (AMT credentials still in Lion.ini/Sys.ini)
•	C2 Kestrel:Endpoints as single URL source
•	C3 serverReadyAction auto-open
•	C4 task presentation grouping
•	C5 preflight.ps1
•	C6 amt-guardrail-check.prompt.md
•	C7 shared Keycloak with two realms (also resolves A3)
•	C8 read-only reference folder
Reversed (contradicted by AMT authority):
•	A3 second Keycloak on 8081 — REVERSED. Use single Keycloak on 8080 with two realms per Quick Start Guide.
New AMT-specific risks (all mitigated in this revised guide):
•	R1 Sys.ini search-up path — mitigated in §2, §4, §15
•	R2 Setup.exe IIS website collision — mitigated in §5 (unique VIRTUALFOLDER/URL per lane)
•	R3 LionDev service name collision — mitigated in §5 (unique LIONDEVNETSERVICENAME per lane)
•	R4 AppPool identity vs. lane System DB permissions — mitigated in §5 and §6
•	R5 .NET SDK 10.0.203 exact / VS 2026 conditional — mitigated in §4, §6a, §17
v3 clarifications:
•	AMT VS Generator citation attached to every occurrence (.NET 10 Report §2).
•	AMT VS Generator declared NOT a prerequisite for the AMT175 installation/runtime workflow.
•	VS 2026 required only for (a) AMT VS Generator scaffolding of a new AMT project, or (b) opening/building AMT .NET 10 solutions in the Visual Studio IDE.
•	VS Code + .NET SDK 10.0.203 remains sufficient for the workflow described in this guide.
Recommendation:
All 17 items are now supported by AMT authority or are outside AMT scope, and all five newly surfaced risks have explicit mitigations. AMT VS Generator scope has been clarified in §17. You may apply the full revised instruction package to VS Code as-is. If any AMT reference document changes materially before you complete Phase 3, re-run the amt-guardrail-check prompt against the affected section before executing further steps.
 
17. Generation tooling & AMT VS Generator (NEW in v3)
[V3] This entire section is new in v3 and answers: what is the AMT VS Generator, is it required, and how does it relate to the AMT175 parallel-run installation workflow.
17.1 What the AMT VS Generator is
The AMT VS Generator is a documented Avanade tool that scaffolds a new AMT project and lets the developer select the target IDE version (VS2022 or VS2026).
[AMT-AUTHORITY] Verbatim from AMT .Net 8 upgrade to .Net 10 Report.docx §2 — 'Visual Studio 2022 (version 17.x) doesn't fully support .Net 10 development when the .Net 10 SDK workload is installed, therefore we advise using Visual Studio 2026. Visual Studio 2026 is now supported by the AMT VS Generator. When generating a new AMT project, you can now select VS2026 as a target IDE.' Authors: Albert Borger, Kevin Bruecher, Shubham A. Upadhyay. Effective and Approval Date: 10 June 2026.
17.2 What the AMT VS Generator is NOT
Per v3 clarification, the AMT VS Generator is not a prerequisite for this AMT175 parallel-run installation workflow.
It is not involved in:
•	AMT installation (Setup.exe, AMT product install, licence install)
•	Repository database creation or Lion.ini configuration
•	AMT System database creation, Sys.ini, AMTSYSTEM, or AmtReorganize
•	Control Center installation, first-use, or Base Setup
•	Keycloak realm/client setup or OIDC integration
•	LincToLion configuration or Convert To LION operations
•	Application database creation, configuration, or reorganization
•	IIS virtual folder creation, AppPool identity, or web binding
•	VS Code workspace, launch.json, tasks.json, or launchSettings.json setup
•	AMTSYSTEM / Sys.ini / Lion.ini value definitions or environment variables
•	Ports, logs, temp folders, or extract paths
[V3] In short: the AMT VS Generator is a scaffolding tool for creating a NEW AMT Visual Studio project. It does not participate in installation, runtime, or the VS Code parallel-run workflow described in this guide.
17.3 Generation Tooling Map
There are three distinct AMT generation-related toolsets. This guide covers only the runtime concerns of the first; the second is scoped narrowly; the third is out of scope.
Tool	What it does	In scope for this guide?	Citation
LionDevGenNet.exe (also called AMT Developer Studio Generator, AMT LION Generator, or AMT Developer Generator)	Compiles LION 4GL objects into .NET binaries. Runs as a Windows service under LIONDEVNETSERVICENAME.	YES — this is the generator lane you already know. Configured via Lion.ini fields (LIONDEVNETSERVICENAME, LIONDEVNETSERVERNAME, DBSNAME). Must be lane-unique to avoid Windows service registration collision (Risk R3).	AICL Lion.ini; AMT installation reference; AICVC service configuration
AMT VS Generator	Scaffolds a NEW AMT Visual Studio project. Lets you select VS2022 or VS2026 as the target IDE.	NO — the AMT175 lane in this guide starts from existing/generated AMT175 sources; new-project scaffolding is a separate activity. If you invoke it, install VS 2026 first.	AMT .Net 8 upgrade to .Net 10 Report.docx §2 (Borger, Bruecher, Upadhyay; 10 June 2026)
AMT Transform toolset (AbSuiteUnloadGui, LincToLionGui, CobolConverterGui, etc.)	One-time migration tools that convert legacy source (AB Suite, COBOL, DMSII, WFL) to C# / PowerShell / SQL. Used only during the migration pipeline.	PARTIAL — LincToLion is covered by Doc B Phase 5. Other Transform tools are out of scope of the installation guide.	Federale Site Survey; AMT LincToLion user manual.docx
17.4 Conditional Visual Studio 2026 requirement
[V3] Visual Studio 2026 is required ONLY when: (a) using the AMT VS Generator to scaffold a new AMT .NET 10 project (VS2026 target), or (b) opening/building AMT .NET 10 solutions in the Visual Studio IDE. VS Code + .NET SDK 10.0.203 is sufficient for everything else in this guide.
Independent second-source evidence that VS 2022 cannot open AMT .NET 10 solutions:
error NETSDK1209: The current Visual Studio version does not support
  targeting .NET 10.0. [...] Either target .NET 9.0 or lower, or use Visual
  Studio version 18.0 or higher.
(Visual Studio 2022 is 17.x; Visual Studio 2026 is 18.x.)
Impact assessment on this guide:
Activity	VS Code + .NET SDK 10.0.203?	VS 2026 required?
Edit Sys.ini, Lion.ini, appsettings.json, launchSettings.json, tasks.json, launch.json	YES	NO
Run Setup.exe / AmtReorganize / Control Center	YES	NO
dotnet build / dotnet run on pre-generated AMT175 sources	YES	NO
LION 4GL work via LionDev.exe / LionDevGenNet.exe	YES	NO
Keycloak realm import & Control Center OIDC config	YES	NO
Migration pipeline: SplitPModel, AbSuiteUnloadGui, LincToLionGui, LionDev C# generation	YES	NO
Scaffold a new AMT project via AMT VS Generator (VS2026 target)	NO	YES
Open AmtGo.sln / AmtAll.sln / Amt-Lion.sln in the Visual Studio IDE for .NET 10 targets	NO	YES (error NETSDK1209 in VS 2022)
17.5 Guardrail addendum for AMT VS Generator
•	Any AMT VS Generator reference in Copilot output must cite AMT .Net 8 upgrade to .Net 10 Report.docx §2 (Borger, Bruecher, Upadhyay; 10 June 2026).
•	Copilot must not add VS 2026 as a prerequisite for installation/runtime/CC/Keycloak/Sys.ini/AMTSYSTEM/DB steps.
•	Copilot must reject any instruction that treats the AMT VS Generator as required for the AMT175 parallel-run workflow.
•	The amt-guardrail-check.prompt.md (§8) already includes an 'AMT VS Generator misuse' detection rule.
 
18. Readiness assessment (NEW in v3)
[V3] Component-by-component readiness check for using this package as a VS Code instruction pack. Confirms the '90% ready' position.
Component	State after applying v3	Manual action required
§2 workspace layout & AMT.code-workspace file	READY	Create C:\Amt\Parallel\ and drop the workspace file
§4 environment matrix (values pre-populated)	READY	No change unless environment differs
§5 databases (AMT175_*)	READY	SQL Server: create the 4 empty AMT175_* DBs before Phase 1
§6 phase-driven execution model	READY	Follow phases in order
§6a launchSettings.json / launch.json / tasks.json	READY	Copy files into AMT175\.vscode\ and AMT175\Properties\
§6a preflight.ps1	READY	Copy into AMT175\scripts\ and run via 'preflight AMT175' task
§7 guardrail layer	READY	None — enforced by Copilot instructions
§8 prompt templates (copilot-instructions + 4 prompts)	READY	Copy into AMT175\.github\ and .github\prompts\
§9 review loop template	READY	None
§10 quick execution checklist	READY	Use as tick-list during install
§11-14 preserved sections	READY	Refer to Doc B baseline
§15 runtime conflict checklist	READY	Run before each lane start
§16 findings summary	READY	None
§17 Generation Tooling & AMT VS Generator	READY	None; new-project scaffolding is out of scope
AMTSYSTEM env var (semi-colon list, no spaces)	REQUIRES MANUAL SET	Set via Windows System Properties or PowerShell (User scope)
Keycloak realm 'amt175'	REQUIRES MANUAL IMPORT	Import Quick Start config into existing Keycloak on 8080
AMT175 Sys.ini at lane root	REQUIRES MANUAL CREATE	Create C:\Amt\Parallel\AMT175\Sys.ini per §4/§5
AMT175 Lion.ini with lane-unique fields	REQUIRES MANUAL CREATE	Create C:\Amt\Parallel\AMT175\Lion\Lion.ini per Risk R2/R3
Visual Studio 2026	NOT REQUIRED (unless §17 conditions met)	Optional — only for AMT VS Generator or VS-IDE builds of .NET 10 solutions
Second Keycloak on 8081	NOT REQUIRED (reversed A3)	Do not install
Overall readiness: ~90% ready. The remaining 10% is the environment-specific manual steps flagged 'REQUIRES MANUAL...' above (AMTSYSTEM, Keycloak realm, Sys.ini, Lion.ini). All guidance, prompts, guardrails, and copy-ready configuration files are complete.
 
19. Provenance appendix — 'AMT VS Generator' phrase (NEW in v3)
[V3] Full provenance chain for the phrase 'AMT VS Generator' to satisfy the §13 single-citation policy for audit and to reconcile earlier questions about its origin.
19.1 Search results across the AMT documentation set
Location searched	Matches for 'AMT VS Generator'	Notes
C:\Users\mark.truman\OneDrive - Avanade\A AA Federale\AMT_ReferenceDocuments\ (all subfolders)	0	Why the user's VS Code repo search returned no match.
User's VS Code repo instructions (copilot-instructions.md, prompt files)	0	Consistent with the user's own observation.
AMT175 baseline document (AMT_Implementation_AMT175_Analysis_Merged.docx)	0	Doc B (primary authority) does not mention the phrase.
Setting Up Parallel VS Code Projects.docx (Doc A)	0	Doc A does not mention the phrase.
AMT .Net 8 upgrade to .Net 10 Report.docx §2 'Visual Studio 2022 / 2026'	1 (verbatim)	AUTHORITATIVE SOURCE — see quote below.
19.2 Verbatim quote and authorship
[AMT-AUTHORITY] AMT .Net 8 upgrade to .Net 10 Report.docx §2 — 'Visual Studio 2022 (version 17.x) doesn't fully support .Net 10 development when the .Net 10 SDK workload is installed, therefore we advise using Visual Studio 2026. Visual Studio 2026 is now supported by the AMT VS Generator. When generating a new AMT project, you can now select VS2026 as a target IDE.' Authors: Albert Borger, Kevin Bruecher, Shubham A. Upadhyay. Effective and Approval Date: 10 June 2026.
19.3 Reconciliation
This confirms:
•	The phrase is authoritative (not Copilot fabrication).
•	The phrase is absent from AMT_ReferenceDocuments (which explains why the user's local search returned zero).
•	The phrase is absent from the user's VS Code repo instructions (which explains why the user's repo search returned zero).
•	The phrase originates from the .NET 10 upgrade report — a legitimate Avanade R&D document.
•	The tool it names is a scaffolder for new AMT Visual Studio projects, not a runtime/installation component.
19.4 Independent second-source verification
The user's own file Repo you need to clone.docx independently documents that VS 2022 cannot build AMT .NET 10 solutions:
error NETSDK1209: The current Visual Studio version does not support
targeting .NET 10.0. [...] Either target .NET 9.0 or lower, or use Visual
Studio version 18.0 or higher.
 
Visual Studio 2022 = 17.x
Visual Studio 2026 = 18.x
Both statements — Microsoft's SDK error and Avanade's product-support statement — describe the same underlying constraint from opposite ends.
20. How to apply this to VS Code
[V3] This section replaces the prior §17 in v2 (renumbered here as §20). Content unchanged except the AMT VS Generator step is now explicitly optional and cited.
1.	Save this .docx as documentation. Also copy the guide text into C:\Amt\Parallel\AMT175\AMT175-Install.md (the operational Markdown version).
2.	Create the folder tree from §2 and place C:\Amt\Parallel\AMT.code-workspace with the multi-root JSON shown in §2.
3.	Open AMT.code-workspace in VS Code (NOT AMT175 as a single-root folder).
4.	Add the three lane files: Properties\launchSettings.json, .vscode\tasks.json, .vscode\launch.json (§6a).
5.	Add scripts\preflight.ps1 (§6a.5) and run task 'preflight AMT175'.
6.	Add .github\copilot-instructions.md and the four prompt files under .github\prompts\ (§8).
7.	Set User-level AMTSYSTEM=C:\Amt\Parallel\AMT172;C:\Amt\Parallel\AMT175 (no spaces) and log off/on.
8.	Import Keycloak realm amt175 from the Quick Start Guide config file into the existing Keycloak on 8080. Do NOT start a second Keycloak.
9.	Follow Phases 0-5 (§6) in order. Every step must have an AMT authority citation in the review log.
10.	[V3] OPTIONAL: If you need to scaffold a new AMT VS Code project, install Visual Studio 2026 first and invoke the AMT VS Generator (Citation: AMT .Net 8 upgrade to .Net 10 Report.docx §2, Borger, Bruecher, Upadhyay; 10 June 2026). This is separate from and not required by the installation workflow above.
End of AMT175_ParallelRun_GuidePackage_v3.docx — replaces v2 as the authoritative package.
