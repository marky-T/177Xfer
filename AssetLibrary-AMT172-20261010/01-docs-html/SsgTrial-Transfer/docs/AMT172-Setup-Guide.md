# AMT 172 — Installation & Migration Setup Guide

> **Living document** — updated as each phase completes.  
> Status: ✅ Done | 🔄 In Progress | ⏳ Pending | ⚠️ See Bug Log

**Last updated:** 2026-06-10  
**Environment:** Windows 11 Pro, localhost, Avanade migration project  
**AMT Version:** 172 (8.0.26125.0 RC1)

---

## Environment Overview

| Component | Value |
|-----------|-------|
| AMT install root | `C:\Amt\Working\` |
| AMT Tools | `C:\Amt\Working\AMTTools\` |
| Lion root | `C:\Amt\Working\Lion\` |
| SQL Server | localhost — SQL Server 2022 Developer, mixed-mode auth |
| IIS | Default Web Site → `/Working` → `http://localhost/Working` |
| Keycloak | `http://localhost:8080` — realm: master |
| Migration data | `C:\Amt\Migration\` |
| Source model | `C:\Amt\Migration\Source\prd.model` (834MB) |
| AB Suite MsSql backup | `C:\Amt\Migration\Source\export-avanade.bak` (299MB) |

---

## Phase 1 — SQL Server Setup ✅

### Step 1 — Install SQL Server 2022 Developer
- Enable mixed-mode authentication during setup
- Install SSMS

### Step 2 — Create WORKING_REPOS database
```sql
CREATE DATABASE WORKING_REPOS;
```
Lion main repository — initialized by LionDev (contains REV* tables after first LionDev run).

### Step 3 — Create WORKING_SYSTEM database
```sql
CREATE DATABASE WORKING_SYSTEM;
```
AMT system database — users, roles, component rights.

### Step 4 — Restore ModelRepos from export-avanade.bak
```sql
RESTORE DATABASE ModelRepos
  FROM DISK = 'C:\Amt\Migration\Source\export-avanade.bak'
  WITH MOVE 'LogicalDataName' TO 'C:\SQLData\ModelRepos.mdf',
       MOVE 'LogicalLogName'  TO 'C:\SQLData\ModelRepos_log.ldf',
       REPLACE;
```
> ⚠️ Bug #1 — Required DB for AB Suite Unload. WORKING_REPOS does NOT have the AB Suite schema (`UnisysLogicalModelerVersion` stored proc). Must use ModelRepos.

### Step 5 — Create WORKING_LINC database
```sql
CREATE DATABASE WORKING_LINC;
```
LincToLion temporary repository — schema initialized by LincToLionGui on first run.

### Step 6 — Create SQL logins
```sql
-- amt_repos_user
CREATE LOGIN amt_repos_user WITH PASSWORD = 'Asysco12345!', CHECK_POLICY = OFF;
USE WORKING_REPOS;  CREATE USER amt_repos_user FOR LOGIN amt_repos_user; ALTER ROLE db_owner ADD MEMBER amt_repos_user;
USE WORKING_LINC;   CREATE USER amt_repos_user FOR LOGIN amt_repos_user; ALTER ROLE db_owner ADD MEMBER amt_repos_user;
USE ModelRepos;     CREATE USER amt_repos_user FOR LOGIN amt_repos_user; ALTER ROLE db_owner ADD MEMBER amt_repos_user;

-- amt_system_user
CREATE LOGIN amt_system_user WITH PASSWORD = 'Asysco12345!', CHECK_POLICY = OFF;
USE WORKING_SYSTEM; CREATE USER amt_system_user FOR LOGIN amt_system_user; ALTER ROLE db_owner ADD MEMBER amt_system_user;
```

---

## Phase 2 — AMT 172 Install & Config ✅

### Step 7 — Install AMT 172
- Install AMT 172 (8.0.26125.0 RC1) to `C:\Amt\Working\`
- Tools land at `C:\Amt\Working\AMTTools\`
- Lion lands at `C:\Amt\Working\Lion\`

### Step 8 — Configure sys.ini
File: `C:\Amt\Working\Lion\sys.ini`
- Set DBSSYS=MSSQL, SERVERNAMEREPOSDB=localhost
- Set DBSNAME=WORKING_SYSTEM, DBUSER=amt_system_user

### Step 9 — Configure Lion.ini
File: `C:\Amt\Working\Lion\Lion.ini`
```ini
DBSSYS=MSSQL
SERVERNAMEREPOSDB=localhost
DBSNAME=WORKING_REPOS
DBUSER=amt_repos_user
DBPSSW=604050100106100084096034035036037038018
AMTTEST
```

---

## Phase 3 — IIS + ASP.NET Core ✅

### Step 10 — Install IIS + ASP.NET Core 8.0 Hosting Bundle
- Enable IIS via Windows Features
- Download and install [ASP.NET Core 8.0 Hosting Bundle](https://dotnet.microsoft.com/download/dotnet/8.0)

### Step 11 — Deploy ControlCenterCore
- Copy published output to `C:\Amt\Working\AMTTools\ControlCenterCore\`
- IIS: create application at `/Working/ControlCenter` pointing to above folder

### Step 12 — Deploy ControlCenterWebApi
- Copy published output to `C:\Amt\Working\AMTTools\ControlCenterWebApi\`
- IIS: create application at `/Working/ControlCenterBL`

### Step 13 — Fix RequireHttpsMetadata
In **both** `appsettings.json` files set:
```json
// ControlCenterCore — under Amt.Authentication.AmtOIDC.OIDC
"RequireHttpsMetadata": false

// ControlCenterWebApi — under Amt.Authentication.JWT  
"RequireHttpsMetadata": false
```
> Keycloak runs HTTP only — this must be false or auth fails.

### Step 14 — Set ASPNETCORE_ENVIRONMENT
In ControlCenterCore `Web.Config`:
```xml
<environmentVariable name="ASPNETCORE_ENVIRONMENT" value="Development" />
```

### Step 15 — IIS App Pool Recycle (no admin rights workaround)
```powershell
# Touch Web.Config to trigger recycle
(Get-Item "C:\Amt\Working\AMTTools\ControlCenterCore\Web.Config").LastWriteTime = Get-Date
```

---

## Phase 4 — Keycloak 26.2.5 ✅

### Step 16 — Install Keycloak
- Install to `C:\Keycloak\keycloak-26.2.5\`
- Install Microsoft JDK 21 to `C:\Program Files\Microsoft\jdk-21.0.11.10-hotspot`

### Step 17 — Start Keycloak (run after every reboot)
```powershell
$env:JAVA_HOME = "C:\Program Files\Microsoft\jdk-21.0.11.10-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
Set-Location "C:\Keycloak\keycloak-26.2.5\bin"
Start-Process -FilePath "cmd.exe" -ArgumentList "/c kc.bat start-dev --http-port 8080 > C:\Keycloak\keycloak.log 2>&1" -WindowStyle Minimized
```

### Step 18 — Create amt-cc client
In Keycloak admin (`http://localhost:8080`) → master realm → Clients → Create:
- Client ID: `amt-cc`
- Standard Flow: **ON**
- Valid redirect URIs: `http://localhost/Working/ControlCenter/*`
- Valid post-logout redirect URIs: `http://localhost/Working/ControlCenter/`
- Web origins: `http://localhost`

### Step 19 — Create amt-cc-api client + scope
- Client ID: `amt-cc-api`
- Create client scope: `amt-cc-api-scope`
- Add scope to `amt-cc` client as **Default** (NOT Optional)
> ⚠️ If scope is Optional → audience missing from token → "Session no longer valid"

### Step 20 — Create Keycloak user
- Username: `marky-t` in master realm

---

## Phase 5 — AMT User Authorization ✅

### Step 21 — Map Keycloak identity → AMT user
```sql
INSERT INTO WORKING_SYSTEM.dbo.AMTSYSIDENTITYTRANSLATION (IDENTITYNAME, USERNAME, USERDOMAIN)
VALUES ('marky-t', 'ADMIN', '');
```
AMT uses `preferred_username` claim from Keycloak token.

### Step 22 — Add user to Administrators role
```sql
-- First run Control Center so AMT auto-creates the user row, then:
INSERT INTO WORKING_SYSTEM.dbo.AMTSYSUSERINROLE (USERID, ROLEID)
SELECT USERID, 2 FROM WORKING_SYSTEM.dbo.AMTSYSUSER WHERE USERNAME = 'ADMIN';
```

### Step 23 — Grant all component rights to Administrators
```sql
INSERT INTO WORKING_SYSTEM.dbo.AMTSYSCOMPONENTINROLE (ROLEID, COMPONENTID)
SELECT 2, COMPONENTID FROM WORKING_SYSTEM.dbo.AMTSYSCOMPONENT;
-- Grants 113 component rights
```

---

## Phase 6 — Split PModel ✅

### Step 24 — Copy source model
```powershell
# prd.model should already be at:
# C:\Amt\Migration\Source\prd.model  (834MB)
```

### Step 25 — Run SplitPModel
- Tool: `C:\Amt\Working\AMTTools\SplitPModel\SplitPModel.exe` (or via Control Center)
- Input: `C:\Amt\Migration\Source\prd.model`
- Output: `C:\Amt\Migration\PModelOut\`
- Result: **8,241 files**, 10 folders, 49 sec, 0 errors

---

## Phase 7 — AB Suite Unload MsSql ✅

### Step 26 — Build AbSuiteUnloadGui
```powershell
dotnet build "C:\Dev\amt-go-net-net8\Migration Tools\AbSuiteUnload\AbSuiteUnloadGui\AbSuiteUnloadGui.csproj" -c Release
```

### Step 27 — Configure Default.Settings
File: `C:\Dev\amt-go-net-net8\Migration Tools\AbSuiteUnload\AbSuiteUnloadGui\bin\Release\net8.0-windows\Default.Settings`
- Set `Database=ModelRepos`  
> ⚠️ Bug #1 — Default was WORKING_REPOS which lacks AB Suite schema. Must be ModelRepos.

### Step 28 — Run Unload MsSql
- Launch `AbSuiteUnloadGui.exe`
- Source: ModelRepos (localhost)
- Output folder: `C:\Amt\Migration\UnloadOut\`
- Result: **8,245 files**, 3m 17s, 0 errors, 0 warnings

---

## Phase 8 — LincToLionGui Setup ✅

### Step 29 — Build LincToLionGui
```powershell
dotnet build "C:\Dev\amt-go-net-net8\AmtLion\Lion\LincToLionGui\LincToLionGui.csproj" -c Release
```

### Step 30 — Create LincToLion.ini
File: `C:\Amt\Working\Lion\LincToLion.ini` — copy of Lion.ini with DBSNAME changed:
```ini
DBSSYS=MSSQL
SERVERNAMEREPOSDB=localhost
DBSNAME=WORKING_LINC
DBUSER=amt_repos_user
DBPSSW=604050100106100084096034035036037038018
AMTTEST
```

### Step 31 — Configure exe folder Lion.ini
```powershell
$d = "C:\Dev\amt-go-net-net8\AmtLion\Lion\LincToLionGui\bin\Release\net8.0-windows"
# Lion.ini must point to WORKING_REPOS (for CheckReoDev after LincStartUp)
Copy-Item "C:\Amt\Working\Lion\Lion.ini" "$d\Lion.ini" -Force
```
> ⚠️ Bug #2 — If this points to WORKING_LINC, app auto-closes silently (CheckReoDev fails).

### Step 32 — Set registry for LionGen dialog default
```powershell
Set-ItemProperty -Path "HKCU:\Software\Asysco\LincToLion" `
  -Name "Conv Temp Ini File" `
  -Value "C:\Amt\Working\Lion\LincToLion.ini"
```
> ⚠️ Bug #3 — Default was Lion.ini (WORKING_REPOS). That DB has no PARAM table → "Invalid object name PARAM" error.

### Step 33 — Copy Lion.lic to exe folder
```powershell
$d = "C:\Dev\amt-go-net-net8\AmtLion\Lion\LincToLionGui\bin\Release\net8.0-windows"
Copy-Item "C:\Amt\Working\Lion\Lion.lic" "$d\Lion.lic" -Force
```
> ⚠️ Bug #4 — Without Lion.lic, app shows "No Lion developer license" and closes.

### Step 34 — Launch LincToLionGui
```powershell
$d = "C:\Dev\amt-go-net-net8\AmtLion\Lion\LincToLionGui\bin\Release\net8.0-windows"
Start-Process -FilePath "$d\LincToLionGui.exe" -WorkingDirectory $d
# When dialog appears, enter: C:\Amt\Working\Lion\LincToLion.ini
```

**Result:** ✅ App opens fully, licensed, "AMT Linc To Lion Version: AMT 172a - 260505 - 8.0.26125.50"

---

## Phase 9 — AB Suite Load (Lion) 🔄

### Step 35 — Click AB Suite Load in LincToLionGui
- Button: **AB Suite Load**
- Model Folder: `C:\Amt\Migration\UnloadOut`
- Load flags: Spec ✓ Dct ✓ Gsd ✓ Glg ✓ Ispec ✓ Profile ✓ Report ✓ Class ✓
- Click **Start**
- Log: `C:\Amt\Migration\Logs\linctolion.log`

---

## Phase 10 — LionDevGenNet C# Generation ⏳

> **Next:** After AB Suite Load completes, use LionDevGenNet to generate C# from WORKING_REPOS.

---

## Phase 11 — ApplicationCenter Keycloak Clients ⏳

Clients to create: `amt-ac`, `amt-ac-api`, scope `amt-ac-api-scope`  
Follow same pattern as Phase 4 amt-cc setup.

---

## Phase 12 — COBOL Converter ⏳

- Source: ProgPrd COBOL — 3,246 .txt files (OneDrive, cloud-only)
- Tool: CobolConverterGui — not yet built
- 13 ECL/RunsPrd files cached at `C:\Amt\Migration\Source\RunsPrd\`

---

## Bug Log

| # | Phase | Symptom | Root Cause | Fix |
|---|-------|---------|-----------|-----|
| 1 | Phase 7 (Unload) | "UnisysLogicalModelerVersion not found" | AbSuiteUnloadGui pointed at WORKING_REPOS — no AB Suite schema | Change `Default.Settings` `Database=ModelRepos`; restore export-avanade.bak as ModelRepos |
| 2 | Phase 8 (LincToLionGui) | App auto-closes silently | exe folder `Lion.ini` → WORKING_LINC; `CheckReoDev` fails (needs REV* tables in WORKING_REPOS) | `Copy-Item "C:\Amt\Working\Lion\Lion.ini" "$d\Lion.ini" -Force` |
| 3 | Phase 8 (LincToLionGui) | "Invalid object name 'PARAM'" | Registry `Conv Temp Ini File` = Lion.ini (WORKING_REPOS) — no LincToLion schema | `Set-ItemProperty "HKCU:\Software\Asysco\LincToLion" "Conv Temp Ini File" "C:\Amt\Working\Lion\LincToLion.ini"` |
| 4 | Phase 8 (LincToLionGui) | "No Lion developer license" | `Lion.lic` missing from exe folder | `Copy-Item "C:\Amt\Working\Lion\Lion.lic" "$d\Lion.lic" -Force` |
| 5 | Phase 8 (LincToLionGui) | App auto-closes if LionGen.ini present in exe folder | LionGen.ini skips dialog → `GetParam` fails silently (WORKING_LINC schema not yet ready at that point) | Remove `LionGen.ini` from exe folder; always use dialog |
| 6 | Phase 4 (Keycloak) | "Session no longer valid" after login | `amt-cc-api-scope` set as Optional instead of Default — audience missing from JWT | Set scope to **Default** in amt-cc client scopes |

---

## Quick Reference — Key File Locations

```
C:\Amt\Working\
  Lion\
    Lion.ini           → WORKING_REPOS (LionDev, LionDevGenNet)
    LincToLion.ini     → WORKING_LINC  (LincToLionGui LionGen dialog)
    Lion.lic           → Dev license (copy to exe folders as needed)
    AmtRuntime.lic     → Runtime license
  AMTTools\
    ControlCenterCore\         → IIS /Working/ControlCenter
    ControlCenterWebApi\       → IIS /Working/ControlCenterBL

C:\Amt\Migration\
  Source\
    prd.model                  (834MB — AB Suite model)
    export-avanade.bak         (299MB — restored as ModelRepos)
    RunsPrd\                   (13 cached ECL files)
  PModelOut\                   (8,241 files — Split PModel output)
  UnloadOut\                   (8,245 files — AB Suite Unload output)
  Logs\                        (tool run logs)
  AMT172-Setup-Guide.md        (this file)

C:\Dev\amt-go-net-net8\AmtLion\Lion\LincToLionGui\bin\Release\net8.0-windows\
  Lion.ini    → WORKING_REPOS  (copy from C:\Amt\Working\Lion\Lion.ini)
  Lion.lic    → dev license    (copy from C:\Amt\Working\Lion\Lion.lic)
  *** NO LionGen.ini here ***   (causes silent crash — use dialog instead)

C:\Keycloak\keycloak-26.2.5\  → Keycloak server
C:\Program Files\Microsoft\jdk-21.0.11.10-hotspot  → Java for Keycloak
```

---

## Quick Reference — Credentials

| Service | User | Password / Secret |
|---------|------|-------------------|
| SQL | amt_repos_user | Asysco12345! |
| SQL | amt_system_user | Asysco12345! |
| Keycloak admin | marky-t | (local) |
| amt-cc client secret | — | 4wZGeo0JseKuMNajj1Nrlj8KIKdVVuf8 |
| AMT app user | ADMIN | — |
