---
title: "MT-009 — Build a COBOL/OS2200 application on AMT177 (Stage B prerequisite)"
date: "2026-09-16"
status: "procedure aligned to official ASYSCO guide (2026-09-16) — awaiting approval before any DB write"
owner: "MT"
area: "D (real runtime) — Stage B prerequisite"
---

# Plan: MT-009 — Build a COBOL/OS2200 application for Stage B

> **Procedure now follows the official ASYSCO AMT-COBOL admin guide** (captured locally 2026-09-16,
> see [Reference documentation](#reference-documentation)). No system-database write or application
> creation happens until the approach is explicitly approved (see [Change controls](#change-controls)).

## Reference documentation

The procedure below is taken from the **official ASYSCO HelpConsole 7 guide** "AMT Helpfiles for
COBOL" (`target=OS2200`), master index *Basic Runtime Environment Configuration*, captured to
`C:\Amt\Referenece\myasyscohelp\OS2200\` on 2026-09-16. Each procedure step cites its page there.

| Ref | Page (local file / site anchor) |
|-----|---------------------------------|
| **G-BRE** | `Basic-Runtime-Environment-Configuration.md` · `#.basic_runtime_environment_configuration` |
| **G-LOGIN** | `Creating-a-Login-Account.md` · `#.creating_a_lion_login_account` |
| **G-SVC** | `Installing-the-Basic-Services.md` · `#.installing_the_basic_services` |
| **G-CFG** | `Creating-a-Basic-Runtime-Configuration-Set.md` · `#.creating_a_basic_runtime_configuration_set` |
| **G-APPIDX** | `Adding-an-Application-to-the-Runtime-Environment.md` · `#.adding_an_application_to_the_runtime_environment` |
| **G-DB** | `Creating-and-adding-the-Application-Database.md` · `#.creating_and_adding_the_application_database` |
| **G-APP** | `Adding-an-Application-in-the-Control-Center.md` · `#.adding_the_application_in_the_control_center` |
| **G-TXN** | `Adding-the-Transaction-server-in-the-Control-Center.md` · `#.adding_the_application_server_in_the_control_center` |
| **G-IMPORT** | `Importing-Programs-in-the-Control-Center.md` · `#.importing_the_forms_and_jobs` |
| **G-TID** | `Defining-the-Transaction-IDs-in-the-Control-Center.md` · `#.defining_the_transaction_id_s_in_the_control_center` |
| **G-SEC** | `Setting-the-Security-rights-of-Programs-and-Transaction-IDs.md` · `#.setting_the_security_rights_of_the_forms_and_jobs` |
| **G-REO** | `Perform-Reorganization-and-start-Transaction-Server.md` · `#.perform_reorganization_and_start_transaction_server` |
| **G-APPCFG** | `Configuring-an-Application-in-the-Runtime-Environment.md` · `#.configuring_an_application_in_the_runtime_environment` |
| **G-COM** | `Connecting-to-an-Application.md` · `#.connecting_to_an_application` (COM API — Stage B background) |
| **W-DEV** | Azure DevOps wiki "AMT Development Environment Setup" → `C:\Amt\Referenece\Wiki\Wiki\AMT-Development-Environment-Setup.md` (LionDev/dev-tool app *generation* side; runtime-config page is "Coming Soon") |

## Purpose

Prepare AMT177 to run OS2200 SSG/ECL/COBOL reports through Control Center by creating a **separate
application** with `ApplicationKind = CobolOS2200`.

## Architecture constraint (confirmed 2026-09-10, see MT-009 on the progress tracker)

- `FEDERALE_APP` is an **ABSuite/LINC** application. Its catalog (`AMTSYSAVAILABLEJOB`, 5315 rows) holds
  **`AmtReport` DLL jobs only**; a live "Read all jobs from system" scan added **none** of our deployed
  PowerShell scripts (`CFH-COPY` = 0 of 5315 both before and after the scan).
- The COBOL/ECL reports (SsgConverter output) **must not** be registered against `FEDERALE_APP`.
- A **second, separate COBOL/OS2200 application** is required on AMT177.

## Reference implementation

Use the previous **`AMT175_AFBUS_COBOL`** application (`ApplicationKind=CobolOS2200`) as a **shape
reference only** — see `Trial3/run/AmtSettings.xml` (`AppName=AMT175_AFBUS_COBOL`, `IniFile=C:\Amt\
Parallel\AMT175\Sys.ini`, `ComScript`/`ComModule` under `C:\Amt\Parallel\AMT175\AmtTools\...`,
`TransactionServer=Grpc:localhost:4444`, `FileControllerName=FileController`,
`BatchControllerName=AMT175 BatchController`). Its `C:\Amt\Parallel\AMT175\...` paths are
**stale/prior-environment** and must not be copied verbatim onto AMT177. **The authoritative procedure
and field semantics are the official ASYSCO guide** ([Reference documentation](#reference-documentation)),
not this config.

## Procedure (official ASYSCO "Basic Runtime Environment Configuration" sequence, per **G-BRE**)

> The official master index **G-BRE** orders the work as: Login Account → Basic Services → Config Set →
> Add Application (a 7-step sub-procedure, **G-APPIDX**) → Configure Application. Steps 0a–0c below are
> **prerequisites** the guide requires but which AMT177 may already satisfy (it already runs
> `FEDERALE_APP`); **verify, don't blindly recreate** — a shared File/Batch/Print controller and a Login
> Account very likely already exist. Do **not** reuse `FEDERALE_APP`'s ABSuite config, but shared
> *infrastructure* services (controllers, queues, login account) are environment-wide, not per-app.

**Prerequisites (verify first; create only if absent)**

- **0a. Login Account** (**G-LOGIN**): `Security → Login Accounts`. An admin Windows account so the CC
  can (de)install/start/stop services. Likely already present for `FEDERALE_APP` — verify.
- **0b. Basic Services** (**G-SVC**): `System Configuration → Services` — File Controller, Batch
  Controller, Print Controller (+ optional Reorganize Service); plus a **Job Queue**
  (`Batch & Forms → JobQueues`, "Default Queue"), **Print Queue** and **Printer** (`Printers`). These
  are environment-wide; a running AMT177 almost certainly has them — verify, don't duplicate.
- **0c. Basic Runtime Configuration Set** (**G-CFG**): `System Configuration → System Setup` — a
  Basepaths + Logging + Runtime Behaviour config, combined under `Architecture → Configurations`.
  A new **CobolOS2200** app needs a Config Set selectable in step 3; reuse an existing suitable one or
  add a new set (do **not** point it at `FEDERALE_APP`'s ABSuite basepaths).

**Adding the application (official 7-step sub-procedure, per G-APPIDX)**

1. **Create + register the Application Database** (**G-DB**): create the SQL DB following the guide's
   naming convention `<AMT Environment>_<Database Name>` (e.g. `AMT177_AFBUS_COBOL` or similar), correct
   collation; then `System Configuration → Architecture → Databases → Add` (Type MsSql, Kind "User
   database", Reo credentials required) → **Test connection** → Ok.
2. **Confirm AMT177 field values before the CC steps** — resolve the concrete AMT177 equivalents of
   the shape reference in `Trial3/run/AmtSettings.xml` (DB server/name, `%SYSROOT%`/`%APPNAME%` base
   paths, controller service names, Transaction Server Grpc host:port, `Binaries\{Reports,Scripts,...}`).
   Report values (or gaps) before proceeding.
3. **Add the Application in the Control Center** (**G-APP**): `System Configuration → Architecture →
   Applications → Add`. **Name** = exactly the AMT-COBOL Developer Studio app name (drives `%APPNAME%`);
   **Application Kind** = *the COBOL + mainframe OS the app was migrated from* — i.e. **`CobolOS2200`**
   for our OS2200 reports (**G-APP** confirms this is the correct value, also visible in AMT Developer
   Studio → Application Origin). Properties tab: Application base path (`%SYSROOT%`/`%APPNAME%`),
   Userinterface webaddress (required, non-blank), Autostart, Admin account, **Database setting** (the
   DB from step 1), **Configuration setting** (the Config Set from 0c). Then add the app to the
   **Administrators** application role (`Security → Roles → Application roles`, per **G-APP**).
4. **Add the Transaction Server** (**G-TXN**): `System Configuration → Services → Transaction services
   → Add` — select the new application, set Grpc + debugger ports, Basepath to
   `..\AmtTools\TransactionServer`; then **(De)Install → Install service**.
5. **Associate + deploy our artefacts under the new app** — the wrapped
   `Scripts\SSGTRIAL\RUN\CFH-COPY.ps1` and `Scripts\Settings\AmtSettings.xml` (already on disk under
   `E:\Repos\Federale_InternalRelease\Scripts\`, orphaned since no COBOL app exists — see
   [260910-mt005-stageb-real-amt-job.md](260910-mt005-stageb-real-amt-job.md)). Place them under the new
   app's base path/binaries so the job scan can find them.
6. **Import Programs / Jobs** (**G-IMPORT**): `System Configuration → Batch → Available jobs → Read all
   jobs from system → Start Reading`. This is the vendor-documented form of our MT-008 finding; it
   catalogs COBOL programs **and scripts** in the runtime environment.
7. **(If needed) Define Transaction IDs** (**G-TID**): only for online/CICS-style transaction programs
   (Program Control Table). `CFH-COPY` is a **batch `Script` job**, so this step is **expected to be
   N/A** — skip unless an online program is involved.
8. **Set Security rights for the jobs** (**G-SEC**): `Security → Jobs → Jobs` → Administrators role →
   Edit → enable access to the newly imported jobs (incl. the `CFH-COPY` `Script` row) → Apply.
9. **Reorganize the app DB + start the Transaction Server** (**G-REO**):
   `..\<AMT Environment>\AmtTools\Reorganize\AmtReorganize.exe` (standalone → Connect → Analyze selected
   → Reo selected → Close); then `Applications → Server Control` → right-click the Transaction Server →
   **Startup server** (wait Stopped → Pending → Running).
10. **Configure the application** (**G-APPCFG**): confirm Roles/Users/Jobs/Component-activation so the
    app is usable, then **run the controlled Stage B test** — stage the `Extracts` input, Start Job
    `CFH-COPY`, and capture the result (joblog under the app's `Basepaths\Logs\<date>\`, Event Viewer,
    output). COM connect background: **G-COM**.

## Validation checklist

- [ ] The new application is **separate** from `FEDERALE_APP` (own DB, own app row).
- [ ] The application kind is `CobolOS2200` (per **G-APP**).
- [ ] Prerequisites present: Login Account (**G-LOGIN**), controllers + Job/Print Queue + Printer
      (**G-SVC**), a Config Set (**G-CFG**) not pointed at `FEDERALE_APP`’s ABSuite basepaths.
- [ ] App DB created + registered with correct collation, Reo credentials, Test connection OK (**G-DB**).
- [ ] Transaction Server added + installed as a Windows service (**G-TXN**).
- [ ] Required base paths and controllers resolve correctly.
- [ ] The SSG/ECL/COBOL scripts (`CFH-COPY`) are discovered by “Read all jobs from system” (**G-IMPORT**)
      and granted security rights (**G-SEC**), visible in Control Center.
- [ ] App DB reorganized and Transaction Server running (**G-REO**).
- [ ] The Stage B report runs under the COBOL application (**G-APPCFG**).
- [ ] **No `FEDERALE_APP` configuration or catalog entries are altered.**

## How this plan diverged from the official guide (and was corrected 2026-09-16)

The **original** MT-009 procedure (v1, this file’s pre-2026-09-16 revision) was written before the
official ASYSCO guide was located. It differed materially from the vendor procedure now on file:

- **Missing the runtime prerequisites.** v1 jumped straight to “create the application”; the official
  **G-BRE** sequence requires a Login Account (**G-LOGIN**), Basic Services + Queues + Printer
  (**G-SVC**), and a Config Set (**G-CFG**) to exist first. (On AMT177 these are likely already present
  from `FEDERALE_APP` — the corrected plan says *verify*, not recreate.)
- **“Start or register the application … not a raw DB insert unless that is the approved process”** (v1
  step 6) was an open question. **Resolved:** the approved process is the **Control Center UI**
  (`Architecture → Applications → Add`, **G-APP**) — *not* a raw `AMTSYSAPPLICATION` INSERT. The
  raw-SQL path seen in our own `docs/AMT172-Setup-Guide.html` Phase 12/13 (`AFBUS_2200COBOL`) is
  explicitly a **“Deviation from Manual”** in that doc and should **not** be followed.
- **Under-specified the DB step.** v1 conflated “confirm the DB entry” with creation; the guide splits
  it into *create the SQL DB (naming `<Env>_<Name>`, collation)* then *register it in CC → Databases*
  with three credential sections (Reo required) and Test connection (**G-DB**).
- **Omitted the Transaction Server + Reorganize + Server-Control start** as explicit gated steps; the
  guide makes these mandatory (**G-TXN**, **G-REO**) before the app can run.
- **Job discovery** — v1 called it “the Control Center application scan… or the app-scoped equivalent”;
  the guide names it precisely: `Batch → Available jobs → Read all jobs from system → Start Reading`
  (**G-IMPORT**), which also imports **scripts** (matches our MT-008 finding).
- **Transaction IDs (G-TID)** were not in v1 at all; the corrected plan includes the step but flags it
  **expected-N/A** for our batch `Script` job.

The **`AMT175_AFBUS_COBOL`** reference config in `Trial3/run/AmtSettings.xml` remains a **shape
reference only** (stale `C:\Amt\Parallel\AMT175\...` paths); it is consistent with the official
procedure (kind `CobolOS2200`, a Transaction Server, File/Batch controllers) but is not authoritative
for AMT177 field values — the official guide is.

## Change controls

- **Do not create the application or write to the system database** until this plan is explicitly
  approved. The approved *method* is now confirmed (Control Center UI, per **G-APP**); the *go-ahead to
  execute* is still required.
- **Follow the official guide** ([Reference documentation](#reference-documentation)) for every CC/DB
  action; do **not** use the raw-SQL `AMTSYSAPPLICATION` INSERT path (the `docs/AMT172-Setup-Guide.html`
  Phase 12/13 “Deviation from Manual”).
- **Back up** relevant configuration before making changes (Sys.ini, any new AmtSettings.xml, DB state
  if feasible) — see the repo's existing backup convention (`SsgConverter/_backup/...`).
- **Record configuration changes** in the project change log (this plan + the progress tracker MT-009
  row + session memory) **only after** they have been applied and validated — not speculatively.
- **If a field value or an AMT177-specific detail is missing, stop** and confirm it (ask the user / the
  AMT team) rather than guessing at DB schema or admin values. The *procedure* is no longer the gap;
  AMT177-specific *values* (DB server/name, base paths, ports, service names) and CC login (MT-007) are.

## Guardrails (carried from the trial's core rules)

- `E:\Repos\Federale_InternalRelease` outside of this workstream's explicit, approved writes remains
  effectively read-only reference; `FEDERALE_APP`, its DB rows, and the `ava` service account are
  never modified by this workstream.
- Every step must be idempotent/re-runnable and documented as it's proven (routine → `ssg-amtcc-runbook
  .instructions.md`; result → progress tracker via `/ssg-update-tracker`).
- Log any blocker as a `T3-nnn` issue and any newly-discovered required step as an `MT-nnn` ToDo, per
  [ssg-todo-issues.instructions.md](../instructions/ssg-todo-issues.instructions.md).

## Relevant files

- **Official ASYSCO guide (captured 2026-09-16):** `C:\Amt\Referenece\myasyscohelp\OS2200\` — 14
  pages, indexed by `Basic-Runtime-Environment-Configuration.md` (see
  [Reference documentation](#reference-documentation) for the per-step map).
- **Azure DevOps dev-setup wiki (captured 2026-09-16):** `C:\Amt\Referenece\Wiki\Wiki\AMT-Development-Environment-Setup.md`
  (LionDev/dev-tool side; its “AMT Runtime Application Configuration” page is “Coming Soon” — the
  official ASYSCO guide fills that gap).
- Tracker entry: [docs/SSG-PowerShell-Trial-Progress.html](../../docs/SSG-PowerShell-Trial-Progress.html) `#MT-009`
- Prior plan / findings: [260910-mt005-stageb-real-amt-job.md](260910-mt005-stageb-real-amt-job.md)
- Reference config (prior environment, shape only): `Trial3/run/AmtSettings.xml`
- Orphaned deployed artefacts (to associate in step 5): `E:\Repos\Federale_InternalRelease\Scripts\SSGTRIAL\RUN\CFH-COPY.ps1`,
  `E:\Repos\Federale_InternalRelease\Scripts\Settings\AmtSettings.xml`
- Area D instructions: [.github/instructions/ssg-amtcc-runbook.instructions.md](../instructions/ssg-amtcc-runbook.instructions.md)
