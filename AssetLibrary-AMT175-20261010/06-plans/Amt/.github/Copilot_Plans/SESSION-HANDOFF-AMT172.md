# Session handoff — AMT172 / Working lane (read me first)

**For the next Copilot session in this workspace.** This captures what a prior session already
established so you don't re-investigate. Workspace root is `c:\Amt`; this is the **AMT172 "Working"
lane** and its **SSG/ECL‑COBOL → C#/PowerShell** conversion work.

---

## 1. Environment facts (verified)

| Thing | Value |
|---|---|
| Lane | AMT172 = `C:\Amt\Working` (runtime: `AMTTools/`, `Apps/`, `Files/`, `Lion/`, `Setup/`, `SystemLogging/`) |
| CC runtime app | `AFBUS_2200COBOL` (APPID 5, APPLICATIONKIND 4 = *Cobol OS 2200*, DATABASEID 4) |
| LionDev source app | `AFBUS_2200SSGCOBOL` (C# under `Apps\…\Source_AMTLion\Development\Programs\`) |
| System DB | `WORKING_SYSTEM`; app DB `WORKING_AFBUS_2200COBOL`; `SERVER TYPE=MSSQL` (`sys.ini`) |
| SYSTEMBASEPATH | `C:\Amt\Working\Lion` → designator files at `Lion\Files\Extracts\<designator>.DAT` |
| CC URL | `http://localhost/Working/ControlCenter/` · Keycloak `:8080` |
| Startup | `Migration/tools/Federale_CC_Startup.ps1` (elevated): Keycloak → IIS → FileController → BatchController → ApplicationServer |

## 2. Scope config already in place — don't redo

- [.github/copilot-instructions.md](../copilot-instructions.md) — scopes agent to `Working/`,
  `Migration/`, `AMT_ReferenceDocuments/`, `.github/`; excludes `Parallel/` (AMT175/177) and
  `Working/OneDrive_2026-06-08/`.
- [.copilotignore](../../.copilotignore) — hard index/search exclusions: `Working/` bulk, `Parallel/`,
  `MainframeSource/Codedrop 2025/*` trees, `Migration/AMT175/`, `Migration/SsgTrial-Transfer/`,
  generated `*Out/`/`output/`/`logs/`, `SsgConverter-Release-*`, `bin`/`obj`/`.git`. Allow‑lists the
  four Lion manuals (see §6) + `AMT_ECLtoPowershell/*.md`.
- `working-AMT172.code-workspace` (root `.` = `c:\Amt`) with matching `search.exclude`.
  ⚠ A malformed duplicate `working-AMT172.code-workspace..code-workspace` exists — delete it.

## 3. Execution model (how converted programs run in CC) — the core knowledge

- **Tier‑2 (PROVEN) — C# DLL via BatchController.** LionDev generates a C# report DLL → deploy to
  `Lion\Binaries\Reports\` (bare‑filename `FILE`) → register in `AMTSYSAVAILABLEJOB` (TYPE 3
  AmtReport) → CC → Jobs → Start Job. BatchController runs it in‑process via `LoadAndRunReport`
  (params `LOADINBATCHCONTROLLER /R:19 /USEWORKINGDIR`). Stage inputs at
  `Lion\Files\Extracts\<designator>.DAT` (designators from `<Program>.Files.cs` `SetOptions(...)`);
  collect output from the same folder. MONTANT + CFH_COPY = byte‑identical PASSes (2026‑07‑18);
  LOADIS = execution pass (indexed output, see [LOADIS_CC_TRIAL_RESULT.txt](../../Working/LOADIS_CC_TRIAL_RESULT.txt)).
  Full runbook: `Migration/SSG-ECL-PowerShell-Reference.html` §6b.
- **Tier‑3 (SUPPORTED, UNPROVEN here) — PowerShell via `AmtPowershellHost.exe`.** For converted
  `.ps1` reports using `AmtPsEclLib`. The DB connection is made by the native AMT **MsSql wrapper**
  (`AMTTools\SqlServerWrapper\Asysco.Amt.AmtSqlServerWrapper.dll`), whose `.deps.json` pins
  `Microsoft.Data.SqlClient 6.1.4` + `SNI.runtime 6.0.2` on **.NET 8**. `AmtPowershellHost.exe` is
  **net8 / PS SDK 7.4.14** (NOT net10/pwsh 7.6) and ships the same closure. A bare `pwsh` run fails
  with *"Microsoft.Data.SqlClient is not supported on this platform"* because it has no deps.json for
  the native SNI — so the supported host is `AmtPowershellHost` (via BatchController/CC), not bare pwsh.

## 4. LionDeveloper C# generation

Import `.LionSource` into the AMT Enterprise Repository → **Logic Status → Select All → F7 (Parse) →
Generate** → compile → deploy DLL. Two hard rules: **Bug 14** (candidate/object name must equal COBOL
`PROGRAM-ID`) and **Bug 15** (Parse before Generate, else empty C#). See §7 of the reference HTML.

## 5. Key artifact produced this session

- [.github/Copilot_Plans/AFBUSCobol-AMT177-Setup-Runbook.md](AFBUSCobol-AMT177-Setup-Runbook.md) —
  how to stand up AFBUS‑COBOL on the AMT177 VM the **supported** way (model on AMT177's correct AB
  Suite AFBUS), with a **"Working forced X → AMT177 supported equivalent"** table. Working took
  shortcuts (direct `AMTSYSAPPLICATION`/`AMTSYSAVAILABLEJOB`/`AMTSYSIDENTITYTRANSLATION` SQL, manual
  DLL drops); the supported path is CC Architecture UI + `AmtReorganize` + `/RESTOREADMIN`.

## 6. Reference docs (now searchable)

- `AMT_ReferenceDocuments/AMT_LionReferenceDocs/` — AICL, ALPD, `Migrate AMT LION to Csharp.md`,
  `OS2200 COBOL to AMT LION Tech Specs.md`.
- `AMT_ReferenceDocuments/AMT_ECLtoPowershell/Overview Batch Jobs in AMT - from ECL to PowerShell.md`
  — authoritative PS/ECL batch mechanics (`Import‑Module AmtPsEclLib` → `Initialize` →
  `Connect-Application` → `Xqt`/`Fin`; `AmtSettings.xml` fields).
- `AMT_ReferenceDocuments/AMT157_Online_help/*.html` (excluded from index; open by path) — cited pages
  incl. `first-use-of-the-control-center.html`, `command-line-interface-reorganization.html`,
  `adding-the-application-in-the-control-center.html`, `available-jobs.html`, `security-jobs.html`,
  `logic-status.html`, `powershell-inside-batchcontroller.html`, `script-folders.html`.
- Working `AmtSettings.xml` sample (a real successful CHABAN run): `Migration/Trial3/run/AmtSettings.xml`.

## 7. Prior-session index (for deep dives — query the session store, don't re-derive)

Use the session store (`copilot_sessionStoreSql`, SQLite/FTS5) rather than searching files:
- `796ece48…` LOADIS CC run · `b546270b…` trial reviews + AFBUS facts · `3c1fa3b4…` Tier‑2/Tier‑3
  mechanism · `b6d784a9…` LionDev→C# layer · `1848632e…` AmtPsEclLib architecture ·
  `821b6a12…` **AMT175 clean COBOL app+DB registration (the supported method)** ·
  `2161c78d…` working AmtSettings.xml / direct‑connect harness.

## 8. Open threads / next steps

- Tier‑3 PS path never proven in this repo — the documented Exercise‑1 hello‑world (`Add-InformationMsg`)
  loaded + started via CC is the smallest test to confirm the `AMTSYSAVAILABLEJOB` script TYPE +
  script base path empirically (needs a live FEDERALE DB query on the VM).
- AFBUS‑COBOL on AMT177: execute the runbook (§5) against the correct AB Suite AFBUS install.
- Housekeeping: delete the malformed `working-AMT172.code-workspace..code-workspace`.
