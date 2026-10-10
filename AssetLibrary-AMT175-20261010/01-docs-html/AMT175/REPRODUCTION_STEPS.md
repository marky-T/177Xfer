# AMT175 CC "Not Authorized" — Reproduction Guide
## Issue: RESTOREADMIN correctly writes identity translation; CC rejects login

**Session date:** 2026-07-24/27  
**AMT build:** 8.0.26188.0  
**Keycloak:** 25.0.6  
**Issue:** `http://localhost/AMT175/ControlCenter/notauthorized.html` after login despite valid RESTOREADMIN mapping

---

## RESOLUTION (2026-08-10)

Control Center now opens. The following combination resolved the "not authorized" failure.

### What actually fixed it

1. **`RequireHttpsMetadata: false` added to the CC core config.**
   - Copied from [ControlCenterWebApi/appsettings.json](AmtTools/ControlCenterWebApi/appsettings.json#L9) (line 9)
     into [ControlCenterCore/appsettings.json](AmtTools/ControlCenterCore/appsettings.json#L20) (line 20),
     inside `Amt.Authentication.AmtOIDC.OIDC`.
   - ✅ Verified present in both files as of 2026-08-10.

2. **Direct DB fix in `AMTSYSIDENTITYTRANSLATION` (⚠ Review — non-standard).**
   - The R&D helper set the row so `IdentityName` and `UserName` are **both `marky-t`**
     (user recollection — confirm exact values in the DB).
   - Flagged by R&D as **very non-standard practice**; done because it was hard to
     second-guess what earlier steps had already applied.
   - ⚠ This is a direct `AMTSYS*` write and violates the v3 guardrails
     (`.github/copilot-instructions.md`). Recorded here as the observed workaround, not an endorsed step.

3. **Promoted `marky-t` to admin via the Control Center UI** (not via SQL) once CC opened.
   - Verified in CC (2026-08-10) — `Security → Users → MARKY-T → Edit → User roles`:
     `MARKY-T` is **activated** in both `Administrators` and `Users` roles.
   - Cross-checked via `Security → Users → Role Users` with `Role = Administrators`:
     both `ADMIN` and `MARKY-T` show as activated Administrators.
   - Note: the `MARKY-T` user's **Full name** displays as a GUID
     (`8c15df08-911c-4cff-b6b6-25f...`), i.e. the OIDC subject/identity, not a display name.

### Other recommendations captured

- **Start Keycloak via PowerShell** (see PART 2.0 for the `kc.bat start-dev` command).
- **Single realm for all AMT.** Current machine has **two** realms — `amt172`/working and `amt175`.
  Recommendation is to consolidate to one realm for all AMT lanes.
  ⚠ Review against the parallel-run rules in `.github/copilot-instructions.md`,
  which currently document one Keycloak server on `8080` with **two realms** (`amt172` + `amt175`).

> Verify DB values before relying on step 2: `SELECT IdentityName, UserName FROM AMT175_SYSTEM.dbo.AMTSYSIDENTITYTRANSLATION`.

---

## PART 1: Environment Setup

### 1.1 Database Facts
- **DB Server:** localhost (MSSQL)
- **AMT175_SYSTEM DB:** Created via AmtReorganize (Phase 2)
- **Isolation:** Two parallel lanes — `WORKING_SYSTEM` (AMT172), `AMT175_SYSTEM` (this issue)

### 1.2 Lane Configuration Files

**`C:\Amt\Parallel\AMT175\sys.ini`** (lowercase — case-sensitive)
```ini
[DATABASE SERVER]
ENVIRONMENT=AMT175
SYSTEMBASEPATH=C:\\Amt\\Parallel\\AMT175
SERVER TYPE=MSSQL
SERVER NAME NET=localhost
DATABASE NAME=AMT175_SYSTEM
DBUSER=753089101108041047045087107113107108093101087109107093106
DBPSSW=073052102108102086098036037038039040020
SCHEMA=
FILEGROUP=
DATASCHEME=
TABLENAME-PREFIX=FALSE
```
**Note:** `SYSTEMBASEPATH` must be **lane root** (`C:\\Amt\\Parallel\\AMT175`), not `\Lion`.

**Machine Environment Variable `AMTSYSTEM`** (no spaces)
```
C:\Amt\Working;C:\Amt\Parallel\AMT175
```

### 1.3 Setting and Verifying the AMTSYSTEM Environment Variable

**Purpose:** Machine-level env var read by all AMT services (running as LocalSystem). Must include **both** lane root paths separated by semicolon, **no spaces**.

**How to Set It (Choose One):**

#### Option 1: PowerShell (elevated) — Permanent
```powershell
[Environment]::SetEnvironmentVariable(
    'AMTSYSTEM',
    'C:\Amt\Working;C:\Amt\Parallel\AMT175',
    'Machine'
)
```
Then close and reopen PowerShell to pick up the change.

#### Option 2: Windows GUI — Permanent
1. Windows Key → Search `environment`
2. Select **Edit the system environment variables**
3. Click **Environment Variables** button
4. Under **System variables**, click **New**
5. **Variable name:** `AMTSYSTEM`
6. **Variable value:** `C:\Amt\Working;C:\Amt\Parallel\AMT175` (semicolon, no spaces)
7. **OK** → **OK** → Close and reopen any open PowerShell/CMD windows

#### Option 3: Registry (PowerShell, elevated) — Permanent
```powershell
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' `
    -Name 'AMTSYSTEM' `
    -Value 'C:\Amt\Working;C:\Amt\Parallel\AMT175'
```
Then reboot or sign out/in.

**How to Test the Current Value:**

#### Test 1: PowerShell
```powershell
[Environment]::GetEnvironmentVariable('AMTSYSTEM', 'Machine')
```
**Expected output:**
```
C:\Amt\Working;C:\Amt\Parallel\AMT175
```

#### Test 2: Command Prompt
```cmd
echo %AMTSYSTEM%
```
**Expected output:**
```
C:\Amt\Working;C:\Amt\Parallel\AMT175
```

#### Test 3: Verify Both Paths Exist
```powershell
$amtpaths = [Environment]::GetEnvironmentVariable('AMTSYSTEM', 'Machine') -split ';'
foreach ($p in $amtpaths) {
    $exists = Test-Path $p
    Write-Host "$p : $(if ($exists) { 'EXISTS' } else { 'MISSING' })"
}
```
**Expected output:**
```
C:\Amt\Working : EXISTS
C:\Amt\Parallel\AMT175 : EXISTS
```

**When to Verify:**
- ✅ **Before** running `AmtReorganize.exe`
- ✅ **Before** starting Control Center services
- ✅ **After** setting the variable (to confirm it was written)
- ✅ **After** reboot (to confirm it persists)

**Troubleshooting:**
- If `AMTSYSTEM` is empty or missing, AmtReorganize may fail with "license not found" or similar
- If only one path is listed (e.g., only `C:\Amt\Working`), AMT175 services won't find the `sys.ini` at `C:\Amt\Parallel\AMT175`
- If paths contain spaces around the semicolon (e.g., `C:\Amt\Working ; C:\Amt\Parallel\AMT175`), parsing will fail

### 1.4 Control Center Configuration

**File:** `C:\Amt\Parallel\AMT175\AmtTools\ControlCenterCore\appsettings.json`  
**Relevant section:**
```json
"Amt": {
  "Authentication": {
    "AmtOIDC": {
      "Enabled": true,
      "OIDC": {
        "Authority": "http://localhost:8080/realms/amt175",
        "ClientId": "amt-cc",
        "ClientSecret": "[secret from Keycloak]",
        "RequireHttpsMetadata": false,
        "Scopes": ["openid", "profile", "email", "amt-cc-api-scope"]
      }
    }
  }
}
```

#### Validating OIDC Configuration

**Three settings must match Keycloak exactly:**

**1. Authority URL**
```
http://localhost:8080/realms/amt175
```
**Test:** Open this URL in browser. Should return OpenID Connect discovery metadata (JSON):
```
http://localhost:8080/realms/amt175/.well-known/openid-configuration
```
**Expected:** 200 OK, returns JSON with `issuer`, `authorization_endpoint`, `token_endpoint`, etc.

**2. ClientId**
```
amt-cc
```
**Verify in Keycloak:**
1. Open Keycloak console: `http://localhost:8080/`
2. Realm: `amt175`
3. Clients → Select `amt-cc`
4. Copy **Client ID** field (should be `amt-cc`)

**3. ClientSecret**
```
[secret from Keycloak]
```
**Retrieve from Keycloak:**
1. Open Keycloak console: `http://localhost:8080/`
2. Realm: `amt175`
3. Clients → Select `amt-cc`
4. Tab: **Credentials**
5. Copy value from **Client Secret** field
6. Paste into appsettings.json replacing `[secret from Keycloak]`

**Validate All Three Together:**

Run this PowerShell script to test OIDC endpoint connectivity:
```powershell
$authority = "http://localhost:8080/realms/amt175"
$metadata_url = "$authority/.well-known/openid-configuration"

try {
    $response = Invoke-WebRequest -Uri $metadata_url -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "[OK] Authority is reachable" -ForegroundColor Green
        $metadata = $response.Content | ConvertFrom-Json
        Write-Host "  Issuer: $($metadata.issuer)" -ForegroundColor Gray
        Write-Host "  Auth endpoint: $($metadata.authorization_endpoint)" -ForegroundColor Gray
        Write-Host "  Token endpoint: $($metadata.token_endpoint)" -ForegroundColor Gray
    }
} catch {
    Write-Host "[FAIL] Authority unreachable: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  • Is Keycloak running on port 8080?" -ForegroundColor Yellow
    Write-Host "  • Is amt175 realm created?" -ForegroundColor Yellow
}
```

**Troubleshooting:**
- If Authority test fails → Keycloak is not running or amt175 realm doesn't exist
- If ClientId is wrong → CC will return OIDC error during redirect
- If ClientSecret is wrong → CC token validation will fail (401 Unauthorized)
- If Scopes are wrong → CC will return "Invalid scopes" error on login

---

## PART 2: Keycloak Setup (amt175 realm)

### 2.0 Starting Keycloak Manually

**Prerequisites:**
- Keycloak 25.0.6 installed at `C:\Tools\keycloak-25.0.6-fresh\keycloak-25.0.6`
- Port 8080 is available (check: `netstat -ano | findstr :8080`)

**Startup Command (PowerShell):**
```powershell
$env:KC_BOOTSTRAP_ADMIN_USERNAME='admin'
$env:KC_BOOTSTRAP_ADMIN_PASSWORD='admin'
cd 'C:\Tools\keycloak-25.0.6-fresh\keycloak-25.0.6'
.\bin\kc.bat start-dev --http-port=8080 --hostname=localhost --hostname-strict=false --db=dev-file
```

**Expected Output (successful startup):**
```
2026-07-28 16:41:48,657 INFO  [org.infinispan.CONTAINER] (ForkJoinPool.commonPool-worker-1) ISPN000556: Starting user marshaller 'org.infinispan.jboss.marshalling.core.JBossUserMarshaller'
2026-07-28 16:41:49,788 INFO  [org.keycloak.broker.provider.AbstractIdentityProviderMapper] (main) Registering class org.keycloak.broker.provider.mappersync.ConfigSyncEventListener
2026-07-28 16:41:49,821 INFO  [org.keycloak.connections.infinispan.DefaultInfinispanConnectionProviderFactory] (main) Node name: node_710625, Site name: null
2026-07-28 16:41:50,987 INFO  [io.quarkus] (main) Keycloak 25.0.6 on JVM (powered by Quarkus 3.8.5) started in 7.361s. Listening on: http://0.0.0.0:8080. Management interface listening on http://0.0.0.0:9000.
2026-07-28 16:41:50,987 INFO  [io.quarkus] (main) Profile dev activated.
2026-07-28 16:41:50,988 INFO  [io.quarkus] (main) Installed features: [agroal, cdi, hibernate-orm, jdbc-h2, keycloak, logging-gelf, narayana-jta, reactive-routes, resteasy-reactive, resteasy-reactive-jackson, smallrye-context-propagation, vertx]
2026-07-28 16:41:50,991 WARN  [org.keycloak.quarkus.runtime.KeycloakMain] (main) Running the server in development mode. DO NOT use this configuration in production.
```

**Key line to watch for:**
```
Listening on: http://0.0.0.0:8080. Management interface listening on http://0.0.0.0:9000.
```

**Status:** ✅ Keycloak is ready when you see "Listening on: http://0.0.0.0:8080"

**Note:** Keep this terminal open — Keycloak will continue running. Open a new PowerShell window for subsequent commands.

### 2.0a Accessing the Keycloak Console

**URL:** `http://localhost:8080/`  
**Credentials:** admin / admin

**What to Verify in Keycloak Console:**

**1. Check Realm `amt175` exists:**
- Click realm dropdown (top-left, currently showing "master")
- Should see `amt175` listed
- If missing → Create it (see section 2.1)

**2. Check Users:**
- Left menu → **Users**
- Should see three users:
  - `amt175admin` (emailVerified = true)
  - `amt175user` (emailVerified = true)
  - `marky-t` (emailVerified = true)
- All should have email `mark.truman@avanade.com`
- If missing → Create them (see section 2.4)

**3. Check Client `amt-cc`:**
- Left menu → **Clients**
- Should see `amt-cc` listed
- Click it to verify:
  - **Settings tab:**
    - Client type = OpenID Connect
    - Standard Flow Enabled = ON
    - Valid Redirect URIs contains `http://localhost/AMT175/ControlCenter/*`
    - Post Logout Redirect URIs contains `http://localhost/AMT175/ControlCenter/`
  - **Credentials tab:**
    - Copy the **Client Secret** value (you'll need this for appsettings.json)
  - **Client Scopes tab:**
    - Should see `amt-cc-api-scope` listed as **Default**
- If missing or misconfigured → Create/fix it (see sections 2.2-2.3)

**Quick Validation Script (PowerShell):**
```powershell
$kc_url = "http://localhost:8080/realms/amt175/.well-known/openid-configuration"
try {
    $resp = Invoke-WebRequest -Uri $kc_url -UseBasicParsing -TimeoutSec 3
    Write-Host "[OK] Keycloak is responding" -ForegroundColor Green
    Write-Host "  Realm: amt175" -ForegroundColor Gray
} catch {
    Write-Host "[FAIL] Keycloak not responding: $($_.Exception.Message)" -ForegroundColor Red
}
```

---

### 2.1 Realm Creation
- **Realm name:** `amt175` (created from scratch, bare)
- **Settings:** `duplicateEmailsAllowed=true`, `loginWithEmailAllowed=false`

### 2.2 Client (`amt-cc`)
- **Client ID:** `amt-cc`
- **Type:** OpenID Connect
- **Standard Flow:** ON
- **Valid Redirect URIs:** `http://localhost/AMT175/ControlCenter/*`
- **Post-logout Redirect:** `http://localhost/AMT175/ControlCenter/`

### 2.3 Client Scope (`amt-cc-api-scope`)
- **Name:** `amt-cc-api-scope`
- **Type:** openid-connect
- **Protocol Mapper:** `oidc-audience-mapper` (audience=`amt-cc`)
- **Attached to client `amt-cc`:** as DEFAULT scope

### 2.4 Users (created via `create-amt175-users.ps1`)
| Username | Email | Password | Status |
|---|---|---|---|
| `amt175admin` | mark.truman@avanade.com | Asysco12345! | enabled, emailVerified |
| `amt175user` | mark.truman@avanade.com | Asysco12345! | enabled, emailVerified |
| `marky-t` | mark.truman@avanade.com | Asysco12345! | enabled, emailVerified |

**Token claim test (direct grant):** All three users authenticate and return JWT tokens with `preferred_username=<username>` (lowercase).

---

## PART 3: AmtReorganize RESTOREADMIN Execution

### 3.1 Command
**From:** `C:\Amt\Parallel\AMT175\AmtTools\Reorganize\`
```powershell
.\AmtReorganize.exe /RESTOREADMIN=amt175admin
```

### 3.2 Tool Dialogs
1. **Connect:** Run mode = "Running as standalone program", Reorganize service = (blank) → **Yes**
2. **Analyze application:** System DB selected → **Analyze selected**
3. **Reorganize application:** System DB selected → **Reo selected**

### 3.3 Reorganize Results Output (SUCCESS)
```
Time: 2026-07-24 14:43:28
Message: "Reo was started with Restore Admin option"
Message: "Restoring user "ADMIN"..."
Message: "User "ADMIN" found."
Message: "Role "Administrators" found for user "ADMIN"."
Message: "Mapping updated for IdentityName "AMT175ADMIN" to user "ADMIN"."
Message: "Done restoring ADMIN use and mapping to identity "{adminIdentityName}"."
Message: "Reorganize database AMT175_SYSTEM done."
```

**Interpretation:** Tool output matches the documented "Restore Admin" flow exactly. Mapping is written to DB.

### 3.4 Database Verification (SQL Query)
```sql
SELECT * FROM AMT175_SYSTEM.dbo.AMTSYSIDENTITYTRANSLATION
```

**Result:**
```
IdentityName: AMT175ADMIN
UserName: ADMIN
```

**Status:** ✅ Translation row exists and correctly maps `AMT175ADMIN` → `ADMIN`.

---

## PART 4: Control Center Login Test

### 4.1 Attempt
- **URL:** `http://localhost/AMT175/ControlCenter`
- **Browser:** Fresh incognito (no cached sessions)
- **CC proxy:** Redirects to `http://localhost:8080/realms/amt175/protocol/openid-connect/auth?...`
- **Keycloak login:** User enters credentials → **login succeeds** (token issued)
- **CC callback:** OIDC callback returns with ID token containing `preferred_username=amt175admin`

### 4.2 Result
- **HTTP Status:** 200 OK
- **Page content:** "You are not authorized to use Control Center"
- **URL:** `http://localhost/AMT175/ControlCenter/notauthorized.html`

### 4.3 Database Check (After Login Attempt)
```sql
SELECT * FROM AMT175_SYSTEM.dbo.AMTSYSUSER WHERE USERFULLNAME = 'amt175admin'
```

**Result:** User auto-added with role **User** (not ADMIN). Identity translation was not applied by CC.

---

## PART 5: Comparison with Working Lane (AMT172)

### 5.1 WORKING_SYSTEM (AMT172 — uses direct SQL, NOT RESTOREADMIN)
```sql
SELECT * FROM WORKING_SYSTEM.dbo.AMTSYSIDENTITYTRANSLATION
```
**Result:** Empty (no translation table entries).

**How AMT172 succeeded (from guide):**
1. Direct INSERT into `AMTSYSIDENTITYTRANSLATION` (`marky-t` → `ADMIN`)
2. Direct INSERT into `AMTSYSUSERINROLE` (ADMIN role 2)
3. Direct INSERT into `AMTSYSCOMPONENTINROLE` (113 components to role 2)

**Note:** This violates the v3 guardrails (no direct AMTSYS* SQL), but proves the mechanism works on this machine.

### 5.2 Hypothesis
- **RESTOREADMIN mechanism:** Correctly writes `AMTSYSIDENTITYTRANSLATION` ✅
- **CC behavior:** Does not read / does not honor `AMTSYSIDENTITYTRANSLATION` table ❌
- **Build-specific issue:** AMT 8.0.26188.0 may have a known limitation or config flag not documented in online help

### 5.3 Supporting observation (from resolution, 2026-08-10)
- The auto-created `MARKY-T` user's **Full name** in CC is the OIDC subject **GUID**
  (`8c15df08-911c-4cff-b6b6-25f...`), not a display name.
- This indicates CC created/keyed the user from the OIDC token's `sub` claim (or raw identity)
  rather than resolving the login through `AMTSYSIDENTITYTRANSLATION` → existing `ADMIN` user.
- Consistent with 5.2: the translation row was written but **not applied** at login, so CC
  fell back to auto-provisioning a new user (default role `User`) instead of mapping to `ADMIN`.
- The working fix bypassed this path entirely — the identity was reconciled directly in the DB
  and the role was then granted through the CC UI (see RESOLUTION, top of document).

---

## PART 6: Evidence Summary

| Item | File/Query | Finding |
|---|---|---|
| **sys.ini** | `C:\Amt\Parallel\AMT175\sys.ini` | Correct, lowercase, lane-root basepath |
| **AMTSYSTEM** | Machine env var | Both lanes listed, no spaces |
| **appsettings.json** | CC config | Authority = `http://localhost:8080/realms/amt175` ✅ |
| **Keycloak realm** | `amt175` | Created, users exist, login works ✅ |
| **RESTOREADMIN output** | Reorganize.Log | "Mapping updated" message present ✅ |
| **DB translation row** | `AMTSYSIDENTITYTRANSLATION` | `AMT175ADMIN → ADMIN` exists ✅ |
| **CC response** | notauthorized.html | Auto-added as User, not ADMIN ❌ |
| **AMT172 comparison** | `WORKING_SYSTEM` | Uses direct SQL, translation table empty |

---

## PART 7: Reproduction Steps (Condensed)

1. Create `AMT175_SYSTEM` DB via AmtReorganize schema.
2. Write `sys.ini` with lane-root `SYSTEMBASEPATH`.
3. Set `AMTSYSTEM` environment variable to include both lanes.
4. Create `amt175` Keycloak realm with `amt-cc` client + `amt-cc-api-scope`.
5. Create user `amt175admin` in `amt175` realm.
6. Update CC `appsettings.json` with `Authority: http://localhost:8080/realms/amt175`.
7. Run `AmtReorganize.exe /RESTOREADMIN=amt175admin` → connect → analyze → reorganize → close.
8. Verify: `SELECT * FROM AMTSYSIDENTITYTRANSLATION` shows `AMT175ADMIN → ADMIN`.
9. **Result:** Fresh incognito login as `amt175admin` → "not authorized" (user auto-added as User role, translation not applied).

---

## PART 8: Questions for Support

1. **Does AMT 8.0.26188.0 read `AMTSYSIDENTITYTRANSLATION` from CC?** Or is there an alternate identity-resolution table/mechanism?
2. **Is there a config flag or license setting** that enables/disables RESTOREADMIN processing in this build?
3. **Why does the Restore Admin reorganize succeed** (output shows correct messages, mapping written) **but CC doesn't apply it?**
4. **Is the direct-SQL approach (used in AMT172 guide)** the expected workaround for this build, or a known bypass for a product issue?

---

## Attachments (Session Evidence)

- **Reorganize results screenshot** — shows "Reo was started with Restore Admin option" + full message sequence
- **Keycloak console users list** — shows `amt175admin` exists + login succeeds
- **SSMS query results** — `AMTSYSIDENTITYTRANSLATION` row confirmed
- **CC appsettings.json** (excerpt) — OIDC config correct
- **Reorganize.Log tail** (2026-07-24 14:43:28) — full restore admin output
