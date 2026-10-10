# AFBUS-COBOL Runbook — AMT177 (model on the correct AB Suite AFBUS)

**Purpose.** Stand up the **AFBUS COBOL** application (SSG/ECL‑COBOL → C#) on the AMT177 VM the
*supported* way, by mirroring the shape of the **already‑correctly‑installed AB Suite AFBUS** app.
The AMT172/Working install of `AFBUS_2200COBOL` reached the same end‑state but **took manual
shortcuts** (direct `AMTSYS*` SQL, hand DLL drops, identity‑row edits). This runbook keeps the
Working end‑state as the *target to verify against* while using the reference‑manual method to get
there.

**How to read.** Section A = LionDev COBOL base. Section B = AMT/CC registration with a
**"Working did X by hand → AMT177 supported equivalent"** column. Every step names its manual
citation where one exists (priority: `AMT157_Online_help` HTML first, then `AMT_LionReferenceDocs`).

> Sourced from session history: `b6d784a9` (LionDev→C# layer), `821b6a12` (clean COBOL app+DB
> registration on AMT175, the supported method), `b546270b`/`796ece48` (Working `AFBUS_2200COBOL`
> end‑state facts), and `SSG-ECL-PowerShell-Reference.html` §6b/§7.

---

## Point 1 — Model on the AB Suite AFBUS (the reference end‑state)

AMT177 already has a correctly‑installed **AB Suite AFBUS**. Use it as the template for the COBOL
variant. Capture these from the working AB Suite app first, then reproduce for COBOL:

| Attribute | AB Suite AFBUS (read from AMT177) | AFBUS‑COBOL target (mirror) |
|---|---|---|
| CC application name | `FEDERALE_APP` / `AFBUS` (as installed) | `AFBUS_2200COBOL` (or your `<ENV>` convention) |
| Application kind | Lion OS 2200 | **Cobol OS 2200** |
| Application DB | the AB Suite app DB | separate `<ENV>_AFBUS_2200COBOL` DB |
| Base path | `%SYSROOT%\Apps\%APPNAME%\Source_AMTLion\Binaries` | same pattern, COBOL app name |
| Repository | AMT Enterprise Repository (has AFBUS) | same repository, add COBOL app |
| System DB / Sys.ini | shared lane `<ENV>_SYSTEM`, `Sys.ini` | **shared — do not duplicate** |

> On AMT172/Working the repository held `AFBUS`, **`AFBUS_2200COBOL`**, `AFBUS_COBOL`, `PATH2`
> side‑by‑side (session `821b6a12`, AMT172 reference window). COBOL is an **additional app + its own
> app DB in the same lane**, not a new lane.

**Reference:** `AMT157_Online_help\architecture-applications.html`,
`architecture-databases.html`, `adding-the-application-in-the-control-center.html`.

---

## Section A — AFBUS‑COBOL base in LionDeveloper (all recorded steps)

The COBOL business logic is generated to C# by **LionDev (AMT Developer Studio)**. The pipeline that
feeds it (SSG → clean COBOL → `.LionSource`) is the EclCobolPipeline; from `.LionSource` onward:

### A1. Import the `.LionSource` into the repository
- LionDev → **Import Lion Source** into the AMT Enterprise Repository (the COBOL app node).
- **Reference:** `lionsource-files-importing.html`, `liondev-importing-and-exporting.html`,
  `importing-and-exporting-lion-sources.html`.

### A2. Parse before generate (mandatory)
- **Logic Status → Select All → F7 (Parse)**, then **Generate**.
- ⚠ **Bug 15 (hard rule):** skipping Parse leaves `REVGENSETDATA` empty and generates **empty C#**.
- ⚠ **Bug 14 (hard rule):** the imported object/candidate name **must equal the COBOL PROGRAM‑ID**
  (e.g. element `LOADIS_MULT-NODUP` → `PROGRAM-ID. LOADIS-ASCII`), or generation fails with
  *"Could not find source with name…"*.
- **Reference:** `logic-status.html`, `generating-an-amt-lion-application.html`,
  `generating-the-application.html`, `selecting-objects-for-generation.html`.
  Migration‑specific: `AMT_LionReferenceDocs\Migrate AMT LION to Csharp.md`,
  `AMT_LionReferenceDocs\OS2200 COBOL to AMT LION Tech Specs.md`.

### A3. What generation produces
- C# under `…\Apps\<AFBUS_COBOL_APP>\Source_AMTLion\Development\Programs\<Program>\…` including
  `<Program>.Files.cs` with `SetOptions("<designator>", …)` calls that bind the DISC file
  designators (e.g. `ECL-TAPEIN`/`ECL-TAPEOUT`). These designators are **baked into the compiled
  DLL** and are what the runtime resolves at run time (session `b6d784a9`).

### A4. Build → deploy the report DLL
- Compile; place the DLL in the app's **`…\Binaries\Reports\`** with a **bare filename** `FILE`.
- **Reference:** `deploying-your-applications.html`, `updating-runtime-applications.html`.

> **App‑name note:** on Working the LionDev *source* app was `AFBUS_2200SSGCOBOL` while the CC
> *runtime* app was `AFBUS_2200COBOL`. Decide up front whether AMT177 keeps that split or unifies
> the names — mirror whatever the AB Suite AFBUS convention is.

---

## Section B — AMT/CC registration: supported method vs Working's manual shortcuts

**Point 2 + Point 3 combined.** Left column = the reference‑manual step to run on AMT177.
Right column = what Working did by hand (do **not** repeat on AMT177).

### B1. Create + register the COBOL application database
- **Supported (AMT177):** CC → **Architecture → Databases → Add** `<ENV>_AFBUS_2200COBOL`
  (server `localhost`, MsSql, app DB user, **Test connection**). Create the empty DB first via
  `CREATE DATABASE` + a SQL login only.
  **Reference:** `creating-and-adding-the-application-database.html`, `architecture-databases.html`.
- **Working did (avoid):** app DB present but registered/populated with less ceremony; on the AMT175
  redo this was explicitly done the clean way with the guardrail *no `AMTSYS*` SQL, no `AmtReorganize`
  bypass* (session `821b6a12`).

### B2. Add the COBOL application in CC
- **Supported (AMT177):** CC → **Architecture → Applications → Add** → kind **Cobol OS 2200**,
  base path `%SYSROOT%\Apps\%APPNAME%\Source_AMTLion\Binaries`, point to the COBOL app DB, set the
  Admin account to **(default)**.
  **Reference:** `adding-the-application-in-the-control-center.html`, `architecture-applications.html`.
- **Working did (avoid):** direct `AMTSYSAPPLICATION` insert (APPID 5, `APPLICATIONKIND` 4,
  `AUTOSTART` T, `DATABASEID` 4). **AMT177: do not hand‑insert `AMTSYSAPPLICATION`.**

### B3. Reorganize the COBOL app DB (build its schema)
- **Supported (AMT177):** run **`AmtReorganize.exe`** (GUI; it reads `Sys.ini` → `ENVIRONMENT` →
  `<ENV>_SYSTEM`) against `<ENV>_AFBUS_2200COBOL`, **or** headless
  `AmtReoConsole.exe /APP=AFBUS_2200COBOL`. Confirm the reorg results tab shows schema build.
  **Reference:** `command-line-interface-reorganization.html`, `executing-the-reorganization.html`,
  `reorganizing-the-database.html`, `AMT_LionReferenceDocs\AMT Installation and Configuration (AICL).md`.
- **Working did:** same tool (this part was legitimate) — `AmtReoConsole.exe /APP=AFBUS_2200COBOL`
  built `WORKING_AFBUS_2200COBOL` (DATABASEID 4).

### B4. Register each report as a job
- **Supported (AMT177):** with DLLs in `Binaries\Reports\`, let the BatchController pick them up;
  jobs land in `AMTSYSAVAILABLEJOB` as **TYPE 3 (AmtReport)**, `FILE` = bare filename, Default Queue.
  **Reference:** `available-jobs.html`, `batch-control.html`, `jobs-start-job.html`.
- **Working did (avoid):** direct `AMTSYSAVAILABLEJOB` inserts + a **`Restart-Service
  AmtBatchController`** to force re‑sync (auto‑sync is off). On AMT177, prefer the CC/tool refresh;
  only restart the BatchController if a newly deployed DLL doesn't appear.

### B5. Activate the jobs for security
- **Supported (AMT177):** CC → **Security → Jobs → Activate All** (role Users) — else jobs never
  appear under Start Job.
  **Reference:** `security-jobs.html`, `setting-the-security-rights-of-the-forms-and-jobs.html`.
- **Working did:** same (Activate All) — legitimate.

### B6. First Control Center login / admin identity
- **Supported (AMT177):** `AmtReorganize.exe /RESTOREADMIN=<OIDC identity>` → reorganize the System
  DB → the OIDC user is mapped to ADMIN on next CC login (reo results must show the
  *"Reo was started with Restore Admin option / Mapping … for IdentityName …"* lines).
  **Reference:** `AMT157_Online_help\first-use-of-the-control-center.html` (and the live
  `https://help.myasysco.com/cobol-os2200/first-use-of-the-control-center.html`), `identity-translation.html`.
- **Working did (avoid):** hand‑editing the `AMTSYSIDENTITYTRANSLATION` row. **AMT177: use
  `/RESTOREADMIN`, not a manual row edit.**

---

## Point 3 — "Working forced X → AMT177 supported equivalent" (quick table)

| # | Working (AMT172) manual shortcut | AMT177 supported equivalent | Citation |
|---|---|---|---|
| 1 | Direct `AMTSYSAPPLICATION` insert | CC → Architecture → Applications → Add | `adding-the-application-in-the-control-center.html` |
| 2 | Direct `AMTSYSAVAILABLEJOB` insert + service restart | Deploy to `Binaries\Reports\`; CC job refresh | `available-jobs.html`, `batch-control.html` |
| 3 | Hand DB register | CC → Architecture → Databases → Add + Test connection | `creating-and-adding-the-application-database.html` |
| 4 | `AMTSYSIDENTITYTRANSLATION` row edit | `AmtReorganize /RESTOREADMIN=<identity>` | `first-use-of-the-control-center.html` |
| 5 | Manual `Binaries\Common\*` subfolder creation (watcher gap) | Verify against AB Suite AFBUS app's folder set | `deploying-your-applications.html` |

---

## Input/output staging (unchanged for the C# report path)

- Stage fixtures at **`%SYSTEMBASEPATH%\Files\Extracts\<designator>.DAT`** before Start Job; collect
  the output from the same folder by the output designator. Designators come from the generated
  `<Program>.Files.cs` `SetOptions(...)`. On AMT177 (`SYSTEMBASEPATH = …\AFBUS_AMT`) that is
  `…\AFBUS_AMT\Files\Extracts\<designator>.DAT`.
- **Reference:** `file-services.html`, `SSG-ECL-PowerShell-Reference.html#controlcentrerunbook` §6b.

> **Note — PowerShell (Tier‑3) reports differ:** a converted `.ps1` using `AmtPsEclLib` resolves
> files via its own `Asg`/`Use`/`Qual` calls and must run under `AmtPowershellHost` (net8/PS7.4),
> not the DLL path. See `AMT157_Online_help\powershell-inside-batchcontroller.html`,
> `script-folders.html`, `script-file.html`. This runbook is the **C# DLL (Tier‑2)** path.

---

## Known gotchas (carry over from Working)

- **FileController won't start** → `AMTSYSFILECONTROLLER.SERVICENAME` must be exactly `FileController`.
- **Missing `Binaries\Common\*` subfolders halt batch execution** (assembly‑watcher throws) — mirror
  the AB Suite AFBUS app's full `Common\*` folder set.
- **CC Server‑Control Start/Stop buttons are broken** (impersonation NRE) — start services from an
  elevated shell / startup script.
- **Newly deployed DLL not visible** → `Restart-Service <lane>BatchController` to rebuild the report
  pool (last resort, not a first move).

---

## Manual citation index (local paths)

- AICL — `AMT_ReferenceDocuments\AMT_LionReferenceDocs\AMT Installation and Configuration (AICL).md`
- ALPD — `AMT_ReferenceDocuments\AMT_LionReferenceDocs\AMT-LION Primary Developer Training (ALPD).md`
- C# migration — `AMT_ReferenceDocuments\AMT_LionReferenceDocs\Migrate AMT LION to Csharp.md`
- COBOL→LION — `AMT_ReferenceDocuments\AMT_LionReferenceDocs\OS2200 COBOL to AMT LION Tech Specs.md`
- Online help — `AMT_ReferenceDocuments\AMT157_Online_help\<page>.html` (pages named per step above)
