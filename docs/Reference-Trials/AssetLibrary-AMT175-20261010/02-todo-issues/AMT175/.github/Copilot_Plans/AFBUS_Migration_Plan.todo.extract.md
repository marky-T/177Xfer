# Done / open items extracted from AFBUS_Migration_Plan.md

Source: `06-plans/AMT175/.github/Copilot_Plans/AFBUS_Migration_Plan.md` (original: `C:\Amt\Parallel\AMT175\.github\Copilot_Plans\AFBUS_Migration_Plan.md`)

27 done / 13 open (markdown checkboxes)

## Phase 3 — LionDev import into `AMT175_REPOS`  `[x]`

- [x] AB Suite Load from `C:\Amt\Migration\UnloadOut` → `AMT175_LINC` (v8.0.26188.0 tool):
- [x] Convert To LION (Specification: AFBUS): `00:19:18, errors 3, warnings 1128, exceptions 0`.
- [x] AMT Developer Studio opened: `AMT Enterprise Repository AFBUS (Default from Conversion)`.

## Phase 4 — Generate C# (.NET 10)  `[x]`

- [x] Generation of AMT175 AFBUS completed (from AMT Developer Studio / LionDev).

## Phase 5 — Build (.NET 10)  `[x]`

- [x] Build completed by LionDev generation (3,148 binary files produced). No separate

## Phase 0 — Prerequisites  `[x]` (complete)

- [x] `AMT175_AFBUS` DB created empty, ONLINE; registered in CC Databases (Test connection OK);
- [x] CC: Runtime behaviour `AMT175 Runtime`, Configuration `AMT175 Config`, Application
- [x] .NET SDK 10.0.203 installed (side-by-side with 10.0.302/303).
- [x] Release LionDev present: `C:\Amt\Parallel\AMT175\Lion\LionDev.exe` (v8.0.26188.0).
- [x] New model downloaded: `C:\Amt\MainframeSource\Code_Source_20260804\Export_PRD_ABSuite_20260807.model`.
- [ ] Confirm AFBUS app **Admin account = (default)** (not `AMT175_ServiceAccount`).

## Phase 1 — AB Suite Unload (August model)  `[~]`

- [x] Repository DB = **`ModelRepos`** on `localhost` (confirmed: holds SP `UnisysLogicalModelerVersion`).
- [x] The `.model` file is **UTF-16 XML** (AB Suite Logical Modeler export), 840.5 MB — NOT a SQL backup.
- [x] SplitPModel REQUIRES the AB Suite schema in the target SQL DB (calls `UnisysLogicalModelerVersion`;
- [x] Restored `export-avanade.bak` → **`AMT175_MODELREPOS`** (lane-specific, ONLINE, schema present:
- [ ] Run **SplitPModel** (AbSuite unload tool → Split PModel tab): Input=`Export_PRD_ABSuite_20260807.model`,
- [ ] Verify PModelOut populated (Spec/Folders/Ispecs/Reports/Gsds/Dictionaries/Classes/GlobalLogic*).
- [ ] (TBD) Whether AB Suite Load consumes PModelOut directly, or an AbSuiteUnload → UnloadOut pass is needed first.

## Phase 2 — PModel / Split  `[ ]`

- [ ] Produce/verify `PModelOut\` (Classes/Dictionaries/Folders/GlobalLogic*/Gsds/Ispecs/Reports/Spec).

## Phase 2b — AMT175 LincToLion setup (NEW, required before Convert To LION)  `[~]`

- [x] Create empty DB `AMT175_LINC` (ONLINE); granted `amt175_repos_user` db_owner.
- [x] Create `C:\Amt\Parallel\AMT175\Lion\LincToLion.ini` (AMT175): `URL=http://localhost/AMT175`,

## Phase 3 — LionDev import into `AMT175_REPOS`  `[ ]`

- [ ] In AMT175 LionDev, "Importing Lion Source" with a **Lion** genset param file (mirror
- [ ] Verify AFBUS appears under AMT Enterprise Repository (AMT175 window).

## Phase 4 — Generate C# (.NET 10)  `[ ]`

- [ ] LionDev generate C# for AFBUS into `C:\Amt\Parallel\AMT175\Apps\AFBUS\Source_AMTLion\Binaries`

## Phase 5 — Build (.NET 10, small footprint)  `[ ]`

- [ ] `dotnet build` the generated AFBUS solution in Release (global.json pins 10.0.203).
- [ ] Do NOT build the whole `Amt-Lion.sln`. Clean `bin/obj` between chunks if disk tight.

## Phase 6 — Reorganize `AMT175_AFBUS`  `[x]`

- [x] Ran `C:\Amt\Parallel\AMT175\AmtTools\Reorganize\AmtReorganize.exe` → reorganized

## Phase 7 — Run & verify AFBUS  `[~]`

- [x] `AMT175_FileController` Running ✅ `AMT175_BatchController` Running ✅
- [x] `Amt175_Generator` Running ✅ Fix: `New-Service` with `/SERVICE` flag +
- [x] Register AFBUS application in AMT175 CC: base path
- [x] Start AFBUS in CC → Server Control: agent log `Current database: AMT175_AFBUS`,
- [x] **GEN complete (re-run)**: LionDev generate — 2580 objects, 1963 generated,
- [x] **Web deploy output located**: `...\Source_AMTLion\Binaries\ClientBlazor\WebClient\Server`

## Web serve — wire the Blazor UI to IIS (in progress `[~]`)

- [x] Copy `Sample_AppSettings.json` → `appsettings.json` in `WebClient\Server`.
- [x] Create IIS app pool `AMT175_AFBUS_WebPool` (No Managed Code); repoint the existing
- [x] **Fixed HTTP 403** — root cause was a **duplicate `/AMT175` definition**: a stray
- [x] **403 → app LIVE.** ANCM event 1032 "started successfully"; now HTTP 500. stdout log shows
- [ ] **Wire OIDC** (mirror working ControlCenterCore): in `WebClient\Server\appsettings.json`
- [ ] Host `WebApi` backend (`ClientBlazor\WebApi\BlazorWebAPI.exe`) and point `BlazorWebApi` in the
- [ ] Smoke-test: `http://localhost/AMT175/` → Keycloak login → AFBUS Lion login screen.
