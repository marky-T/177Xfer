# AFBUS AB Suite → Lion Migration Plan (AMT175)

**Goal:** Re-run the AB Suite unload on the newer model `Export_PRD_ABSuite_20260807.model`
(contains fixes vs the June `prd.model`), convert to Lion, import into AMT175 LionDev,
generate C# (.NET 10), build, reorganize `AMT175_AFBUS`, and run AFBUS. Reuses the recovered
AMT172 pipeline (AbSuiteUnloadGui → PModel → LionDev import → reorganize).

**Started:** 2026-08-17 · **Lane:** AMT175 (`C:\Amt\Parallel\AMT175`)

Progress legend: `[x]` done · `[~]` in progress · `[ ]` todo

> **RESUME HERE (2026-08-17):** SplitPModel re-run with **Encryption=Decode** done (99% decoded;
> 1,494 errors = August-delta objects that June's `.bak` modeler DB can't decrypt; 35 files still
> `#ENCRYPTED#`). **AB Suite Load is RUNNING** on the decoded `C:\Amt\Migration\AMT175\PModelOut`
> → `AMT175_LINC` (~40+ min). When it finishes: note errors/exceptions, then **Convert To LION** →
> `AMT175_REPOS`. If downstream fails on the undecoded deltas, obtain an **August modeler `.bak`**
> and re-decode. Log: `C:\Amt\Migration\AMT175\Logs\absuite-load.log`.

> **UPDATE (2026-08-18):** AFBUS pipeline completed overnight. All phases done.
> **RESUME HERE:** Fix `Amt175_Generator` service (Access denied on CC install — use `New-Service`
> as LocalSystem, same pattern as File/Batch controllers), then run & verify AFBUS.

---

## Phase 3 — LionDev import into `AMT175_REPOS`  `[x]`
- [x] AB Suite Load from `C:\Amt\Migration\UnloadOut` → `AMT175_LINC` (v8.0.26188.0 tool):
      `00:09:28, errors 2, warnings 0, exceptions 0`. ✅
- [x] Convert To LION (Specification: AFBUS): `00:19:18, errors 3, warnings 1128, exceptions 0`.
      Started 16:59, ended 17:18 (2026-08-17). ✅
- [x] AMT Developer Studio opened: `AMT Enterprise Repository AFBUS (Default from Conversion)`.
      Full tree visible: Database, File Definitions, Forms, Global Definitions, Global Dictionaries,
      Global Routines, Imagelists, Reports, Scripting, Types, Web Services. ✅

## Phase 4 — Generate C# (.NET 10)  `[x]`
- [x] Generation of AMT175 AFBUS completed (from AMT Developer Studio / LionDev).
      Output: `C:\Amt\Parallel\AMT175\Apps\AMT175 AFBUS\Source_AMTLion\Binaries` —
      **3,148 files, 824 MB** (Application, Client, ClientBlazor, ClientGUI, Common, Reports,
      Server, ReoWorking).
- ⚠ `Amt175_Generator` service: registered as LocalSystem pointing at
      `C:\Amt\Parallel\AMT175\Lion\LionDevGenNet.exe` (v8.0.26188.0), StartMode Auto,
      but **Stopped**. CC install gave `Access denied` but service entry was created. Fix: just
      `Start-Service Amt175_Generator` (no New-Service needed — already registered correctly).

## Phase 5 — Build (.NET 10)  `[x]`
- [x] Build completed by LionDev generation (3,148 binary files produced). No separate
      `dotnet build` step required — LionDev generates and builds in one pass.

---

## Phase 0 — Prerequisites  `[x]` (complete)
- [x] `AMT175_AFBUS` DB created empty, ONLINE; registered in CC Databases (Test connection OK);
      creds `amt175_afbus_user` / `Asysco12345!`.
- [x] CC: Runtime behaviour `AMT175 Runtime`, Configuration `AMT175 Config`, Application
      `AMT175 AFBUS` (Lion OS 2200, base path `%SYSROOT%\Apps\%APPNAME%\Source_AMTLion\Binaries`).
- [x] .NET SDK 10.0.203 installed (side-by-side with 10.0.302/303).
- [x] Release LionDev present: `C:\Amt\Parallel\AMT175\Lion\LionDev.exe` (v8.0.26188.0).
- [x] New model downloaded: `C:\Amt\MainframeSource\Code_Source_20260804\Export_PRD_ABSuite_20260807.model`.
- [ ] Confirm AFBUS app **Admin account = (default)** (not `AMT175_ServiceAccount`).

## Phase 1 — AB Suite Unload (August model)  `[~]`

**DECISION (2026-08-17, user):** August delivered `.model` ONLY (no `.bak`). Drive from the
August `.model` via **SplitPModel** into a **lane-specific `AMT175_MODELREPOS`** DB (do NOT
touch shared `ModelRepos`/AMT172 baseline). Then AbSuiteUnload that DB.
Tool: `C:\Dev\amt-go-net-net8\Migration Tools\AbSuiteUnload\AbSuiteUnloadGui\bin\Release\net8.0-windows\AbSuiteUnloadGui.exe` (v8.0.26125.50, .NET 8)
Planned August chain:
```
Export_PRD_ABSuite_20260807.model
  -> [SplitPModel: Input=.model, MsSql=localhost/AMT175_MODELREPOS, Out=AMT175 PModelOut]
  -> AMT175_MODELREPOS (SQL) + PModelOut
  -> [AbSuiteUnload: MsSql=AMT175_MODELREPOS, Out=AMT175 UnloadOut]
  -> [AB Suite Load (AMT175 LincToLion.ini): Folder=AMT175 UnloadOut] -> AMT175_LINC
  -> [Convert To LION] -> AMT175_REPOS -> LionDev -> build -> reorganize -> run
```
⚠ To confirm: that SplitPModel WRITES to the MsSql DB (builds AMT175_MODELREPOS) — verifying in source.
- [x] Repository DB = **`ModelRepos`** on `localhost` (confirmed: holds SP `UnisysLogicalModelerVersion`).
      AbSuiteUnload (`UnloadMsSqlRepos.UnloadController` / `UnloadFromDbs.cs`) reads FROM this SQL
      DB and WRITES the XML/CSV output.
- [x] The `.model` file is **UTF-16 XML** (AB Suite Logical Modeler export), 840.5 MB — NOT a SQL backup.
- ⚠ **New prerequisite:** the `.model` XML is NOT the unloader's input. The August model must first be
      **loaded into `ModelRepos`** (AB Suite Logical Modeler import), THEN unloaded.

**Steps (August path):**
- [x] SplitPModel REQUIRES the AB Suite schema in the target SQL DB (calls `UnisysLogicalModelerVersion`;
      does not create schema). Confirmed via source.
- [x] Restored `export-avanade.bak` → **`AMT175_MODELREPOS`** (lane-specific, ONLINE, schema present:
      `UnisysLogicalModelerVersion` SP + 22 tables). Shared `ModelRepos` / AMT172 untouched.
- [ ] Run **SplitPModel** (AbSuite unload tool → Split PModel tab): Input=`Export_PRD_ABSuite_20260807.model`,
      MsSql server=`localhost`, MsSql database=`AMT175_MODELREPOS`, Output=`C:\Amt\Migration\AMT175\PModelOut`,
      Encryption=Remove, Sort/Clean=on. → August `PModelOut`.
- [ ] Verify PModelOut populated (Spec/Folders/Ispecs/Reports/Gsds/Dictionaries/Classes/GlobalLogic*).
- [ ] (TBD) Whether AB Suite Load consumes PModelOut directly, or an AbSuiteUnload → UnloadOut pass is needed first.

**Recovered full chain (from June screenshots):**
```
ModelRepos (SQL, AB Suite)
  -> [AbSuite unload tool: Unload MsSql; server=localhost db=ModelRepos out=UnloadOut] -> C:\Amt\Migration\UnloadOut
  -> [AbSuite unload tool: Split PModel] -> PModelOut
  -> [Linc To Lion: AB Suite Load, Folder=UnloadOut, parts Spec/Dct/Gsd/Glg/Isp/Pro/Rep/Class] -> LINC DB
  -> [Linc To Lion: Convert To LION] -> Lion repo (AMT175_REPOS)
  -> [LionDev generate] -> build -> [AmtReorganize AMT175_AFBUS] -> run
```
- Unload MsSql tab inputs: MsSql server, MsSql database, Output folder (NO .model field).
- June AB Suite Load read Folder `C:\Amt\Migration\UnloadOut`; log to `C:\Temp\LincToLion\AbsuiteLoad_*`.
- ⚠ REMAINING GAP: neither AMT tool imports the 840MB `.model` XML into `ModelRepos`. The model
  is loaded into `ModelRepos` by an EXTERNAL step (likely Unisys AB Suite Logical Modeler, or a
  ModelRepos DB restore). MUST confirm with user how June loaded it before processing August.

## Phase 2 — PModel / Split  `[ ]`
- [ ] Produce/verify `PModelOut\` (Classes/Dictionaries/Folders/GlobalLogic*/Gsds/Ispecs/Reports/Spec).

## Phase 2b — AMT175 LincToLion setup (NEW, required before Convert To LION)  `[~]`
The AB Suite→Lion flow uses TWO repos: shared **`ModelRepos`** (AB Suite modeler, 22 tables) +
a per-lane **LINC/LionGen** DB. AMT172 uses `WORKING_LINC` + `C:\Amt\Working\Lion\LincToLion.ini`
(`URL=http://localhost/Working`, `DBSNAME=WORKING_LINC`, `DBUSER=amt_repos_user`). AMT175 has
NEITHER yet. ⚠ Never run the LincToLion tool with the Working ini — it would target AMT172.
- [x] Create empty DB `AMT175_LINC` (ONLINE); granted `amt175_repos_user` db_owner.
- [x] Create `C:\Amt\Parallel\AMT175\Lion\LincToLion.ini` (AMT175): `URL=http://localhost/AMT175`,
      `VIRTUALFOLDER=AMT175`, `DBSNAME=AMT175_LINC`, `SERVERNAMEREPOSDB=localhost`,
      `LIONDEVNETSERVICENAME=Amt175_Generator`, `DBUSER=amt175_repos_user` (encrypted pw reused
      from AMT175 Lion.ini). ⚠ VALIDATE by loading in LincToLionGui Setup + Save Settings
      (confirms encrypted pw + schema on first run).

## Phase 3 — LionDev import into `AMT175_REPOS`  `[ ]`
- [ ] In AMT175 LionDev, "Importing Lion Source" with a **Lion** genset param file (mirror
      `LionDevImport\afbus_import.txt` but `APPNAME`/`GENSET=AFBUS`, `DATAFILE=TRUE`).
- [ ] Verify AFBUS appears under AMT Enterprise Repository (AMT175 window).

## Phase 4 — Generate C# (.NET 10)  `[ ]`
- [ ] LionDev generate C# for AFBUS into `C:\Amt\Parallel\AMT175\Apps\AFBUS\Source_AMTLion\Binaries`
      (LionDevGenNet / VsGenerator; verify generator `Amt175_Generator`).

## Phase 5 — Build (.NET 10, small footprint)  `[ ]`
- [ ] `dotnet build` the generated AFBUS solution in Release (global.json pins 10.0.203).
- [ ] Do NOT build the whole `Amt-Lion.sln`. Clean `bin/obj` between chunks if disk tight.

## Phase 6 — Reorganize `AMT175_AFBUS`  `[x]`
- [x] Ran `C:\Amt\Parallel\AMT175\AmtTools\Reorganize\AmtReorganize.exe` → reorganized
      `AMT175_AFBUS` successfully. **322 tables created.** ✅

## Phase 7 — Run & verify AFBUS  `[~]`
- [x] `AMT175_FileController` Running ✅ `AMT175_BatchController` Running ✅
- [x] `Amt175_Generator` Running ✅ Fix: `New-Service` with `/SERVICE` flag +
      `reg add ... AppDirectory = C:\Amt\Parallel\AMT175\Lion`. Root cause: without /SERVICE
      the exe never called ServiceBase.Run() so SCM timed out (30s); without AppDirectory
      it couldn’t find Lion.ini in System32 working dir.
- [x] Register AFBUS application in AMT175 CC: base path
      `%SYSROOT%\Apps\AMT175 AFBUS\Source_AMTLion\Binaries`, DB `AMT175_AFBUS`,
      `AMT175 Config` → `AMT175_AFBUS`. ✅
- [x] Start AFBUS in CC → Server Control: agent log `Current database: AMT175_AFBUS`,
      `Connected to ApplicationServer`. (Orange icons = harmless AmtImpersonation.Dispose
      NullRef from CC poll thread.) ✅
- [x] **GEN complete (re-run)**: LionDev generate — 2580 objects, 1963 generated,
      "NO REO NEEDED", **Web deployment FRENCH → Done**. ✅
- [x] **Web deploy output located**: `...\Source_AMTLion\Binaries\ClientBlazor\WebClient\Server`
      now populated (154 files incl. `wwwroot`, `BlazorWebClient.Server.dll/.exe`, `web.config`,
      `Sample_AppSettings.json`). ✅

### Web serve — wire the Blazor UI to IIS (in progress `[~]`)
- **Finding:** the **Working lane has NO web deployment** (no `BlazorWebClient.Server.exe`
  anywhere under `C:\Amt\Working\Apps`) — AMT175 is *ahead* of Working; no Working reference
  to copy.
- **Host model:** the AFBUS UI generated as **two framework-dependent ASP.NET Core apps**:
  - Front-end: `...\ClientBlazor\WebClient\Server\` (`BlazorWebClient.Server.dll`,
    talks to Lion via `BusinessLogicAdapterLion` → ApplicationServer:4444).
  - Backend: `...\ClientBlazor\WebApi\` (`BlazorWebAPI.exe`).
  - Both use `web.config` → `AspNetCoreModuleV2`, `hostingModel=inprocess`, `processPath=dotnet`
    — identical model to the working ControlCenterCore app.
- **Prereq CONFIRMED:** `AspNetCoreModuleV2` installed at
  `C:\Program Files\IIS\Asp.Net Core Module\V2\`; ControlCenter already runs in-process under IIS.
- [x] Copy `Sample_AppSettings.json` → `appsettings.json` in `WebClient\Server`.
- [x] Create IIS app pool `AMT175_AFBUS_WebPool` (No Managed Code); repoint the existing
      `/AMT175` **application** root at `...\ClientBlazor\WebClient\Server`; grant `IIS_IUSRS` RX.
- [x] **Fixed HTTP 403** — root cause was a **duplicate `/AMT175` definition**: a stray
      *virtual directory* `/AMT175`→`C:\Amt\Parallel\AMT175` in the ROOT site app (DefaultAppPool)
      shadowed the `/AMT175` *application* → IIS 403.18 (URL crossing pools; Blazor `web.config`
      never applied). Removed the stray vdir via `ServerManager` (`$rootApp.VirtualDirectories`)
      — surgically, leaving the `/AMT175` app + ControlCenter/ControlCenterBL children intact.
- [x] **403 → app LIVE.** ANCM event 1032 "started successfully"; now HTTP 500. stdout log shows
      the app runs and the 500 is purely: `System.ArgumentException: The value cannot be an empty
      string. (Parameter 'ClientId')` at `OpenIdConnectOptions.Validate()` — i.e. the OIDC block
      in `appsettings.json` is still the empty sample. **Hosting is DONE; only OIDC config left.**
- **⏸ PARKED 2026-08-18 — resume later this week.** Hosting is DONE (403 fixed, app live, HTTP 500 =
  empty OIDC only). RESUME HERE: create the `amt175` Keycloak client + fill `appsettings.json` OIDC,
  then host WebApi. All exact steps below. Nothing else in AFBUS blocks on this.
- [ ] **Wire OIDC** (mirror working ControlCenterCore): in `WebClient\Server\appsettings.json`
      `Amt.Authentication.AmtOIDC.OIDC` set `Authority=http://localhost:8080/realms/amt175`,
      `RequireHttpsMetadata=false`, `ClientId=<new amt175 client e.g. amt-afbus>`,
      `ClientSecret=<from Keycloak>`, `Scope=[<afbus-api-scope>]`; cookie `.Amt.Blazor.AFBUS.Auth`.
      Create the Keycloak client in realm `amt175`: confidential, redirect URIs
      `http://localhost/AMT175/signin-oidc`, post-logout `http://localhost/AMT175/signout-callback-oidc`,
      web origins `http://localhost`. (CC uses `amt-cc` / scope `amt-cc-api-scope` for reference.)
- [ ] Host `WebApi` backend (`ClientBlazor\WebApi\BlazorWebAPI.exe`) and point `BlazorWebApi` in the
      front-end appsettings at it (`Port=0` = IIS-hosted).
- [ ] Smoke-test: `http://localhost/AMT175/` → Keycloak login → AFBUS Lion login screen.

## Deferred — COBOL 2200 track (separate)
- Create `AMT175_AFBUS_2200COBOL` (+ `AFBUS_COBOL`) DBs, `Cobol OS 2200` app; use CobolToAmt /
  Dms2200CobolGenerator / SsgConverter pipeline (NOT LincToLion). Add when the COBOL phase starts.

---

## Key facts / paths
- New model: `C:\Amt\MainframeSource\Code_Source_20260804\Export_PRD_ABSuite_20260807.model`
- Old model: `C:\Amt\Migration\Source\prd.model` (~874 MB, June)
- Recovered outputs: `C:\Amt\Migration\{UnloadOut,PModelOut,LionDevImport,Logs}`
- Unload tools repo: `C:\Dev\amt-go-net-net8\Migration Tools\` (AbSuiteUnload + converters)
- LionDev: `C:\Amt\Parallel\AMT175\Lion\LionDev.exe`
- Reorganize: `C:\Amt\Parallel\AMT175\AmtTools\Reorganize\AmtReorganize.exe`

## Open questions / risks
1. Repository DB for AbSuiteUnload — which DB, is the Unisys Logical Modeler schema present?
   MUST confirm before Phase 1 (June bug report failed on missing SP `UnisysLogicalModelerVersion`).
2. Exact AbSuiteUnloadGui settings (input/output/DB) — recover from its settings file / June run.
3. Lion genset params for AFBUS (recovered `afbus_import.txt` was the COBOL variant).
4. Disk 30 GB — monitor during unload/generate/build; archive June `UnloadOut` if needed.
5. Generator service `Amt175_Generator` not found as a Windows service earlier — verify before Phase 4.

## Change log
- 2026-08-17 — Plan created; Phase 0 complete; starting Phase 1 (repository DB investigation).
- 2026-08-17 — Phase 1 investigation: repository DB = `ModelRepos` (localhost, has
  `UnisysLogicalModelerVersion` SP). `.model` = 840 MB UTF-16 XML AB Suite export. Discovered
  new prerequisite: August model must be loaded into `ModelRepos` before unload. Open question:
  which tool/step loads the model XML into `ModelRepos`.
- 2026-08-17 — Tools identified: **AbSuite unload tool v33** (`AbSuiteUnloadGui.exe`, tabs
  Unload MsSql / Split PModel) + **AMT Linc To Lion** tool (AB Suite Load, Convert To LION).
  Two-repo model: shared `ModelRepos` + per-lane LINC DB. `AMT175_LINC` and AMT175
  `LincToLion.ini` are MISSING (Working uses `WORKING_LINC`). Added Phase 2b setup. Next:
  view the AbSuite unload tool's **Unload MsSql** tab to see model+DB inputs.
- 2026-08-17 — Recovered full chain from June screenshots (`C:\Amt\Migration\screenshots`):
  ModelRepos -> UnloadOut -> Split PModel -> AB Suite Load (Folder=UnloadOut) -> Convert To
  LION -> LionDev. Confirmed Unload MsSql tab has NO `.model` input. REMAINING GAP: how the
  `.model` XML is loaded into `ModelRepos` (external/Unisys) — pending user confirmation.
- 2026-08-17 — GUARDRAIL (user): AMT172-Setup-Guide.html is a RECORD, not authority; it had
  unconfirmed steps that caused rework. Validate every step against AMT157 online help /
  AMT_LionReferenceDocs (AICL, LincToLion, migration specs) with a citation.
- 2026-08-17 — GAP RESOLVED (from 172 record, re-validate): `ModelRepos` was RESTORED from
  `export-avanade.bak` in the client Codedrop zip (`C:\Amt\MainframeSource\Codedrop 2025\`);
  `prd.model` feeds SplitPModel. For August, need that codedrop's `.bak`.
- 2026-08-17 — Phase 2b: created `AMT175_LINC` (ONLINE) + granted `amt175_repos_user`; wrote
  `C:\Amt\Parallel\AMT175\Lion\LincToLion.ini` (AMT175 values, reused encrypted pw). Pending
  validation via LincToLionGui Save Settings.
- 2026-08-17 — August has `.model` only, NO `.bak` (only June `export-avanade.bak`). SplitPModel.cs
  reads `.model` and splits to XML; AbSuiteUnload reads SQL. DECISION (user): August path =
  `.model` -> SplitPModel -> lane-specific `AMT175_MODELREPOS` -> AbSuiteUnload -> UnloadOut ->
  AB Suite Load -> Convert To LION. Verifying SplitPModel writes to MsSql.
- 2026-08-17 — Restored `export-avanade.bak` -> `AMT175_MODELREPOS` (ONLINE, schema OK). SplitPModel
  (Encryption=Remove) -> 8262 files BUT content `#ENCRYPTED#` (root <ExportSortedCleaned>).
  AB Suite Load on that -> 8263 NREs (fail). Root cause: needed **Decode**, not Remove.
- 2026-08-17 — Re-ran SplitPModel **Encryption=Decode** (MsSql=AMT175_MODELREPOS): 5:02, errors 1494,
  exceptions 0. Decoded OK (VRB900 readable). 8227/8262 clean, 35 still #ENCRYPTED#, 1494 decode
  errors = August deltas not in June modeler DB. User: carry on. **AB Suite Load now RUNNING** on
  decoded PModelOut -> AMT175_LINC.
- 2026-08-18 — Overnight (June UnloadOut path): AB Suite Load 0 exc, Convert To LION 0 exc /1128 warn,
  LionDev generate, AmtReorganize 322 tables — all OK. AFBUS started in CC (Current database:
  AMT175_AFBUS, Connected to ApplicationServer).
- 2026-08-18 — GEN re-run in LionDev: 2580 objects, 1963 generated, NO REO NEEDED, Web deployment
  FRENCH Done. Web output landed in `ClientBlazor\WebClient\Server` (154 files) — NOT the old
  `Lion\Support\LionScreens\Web` the IIS `/AMT175` vdir points at (that path doesn't exist = the 403).
- 2026-08-18 — WEB-SERVE findings: (a) **Working has NO web deployment** (no BlazorWebClient.Server.exe
  under C:\Amt\Working\Apps) — AMT175 is ahead, no Working reference. (b) AFBUS UI = two ASP.NET Core
  apps (`ClientBlazor\WebClient\Server` Blazor front-end + `ClientBlazor\WebApi` BlazorWebAPI.exe),
  both AspNetCoreModuleV2 in-process (same as ControlCenterCore). (c) Prereq CONFIRMED: ASP.NET Core
  Module V2 installed; ControlCenter already hosts in-process. NEXT: copy Sample_AppSettings.json ->
  appsettings.json, set OIDC (realm amt175) + BlazorWebApi, repoint IIS `/AMT175` vdir at
  `ClientBlazor\WebClient\Server`, host WebApi, smoke-test.
