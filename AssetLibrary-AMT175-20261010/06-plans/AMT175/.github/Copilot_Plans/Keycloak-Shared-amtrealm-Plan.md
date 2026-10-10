# Plan: Shared Keycloak realm `amtrealm` for AMT172 + AMT175 (+ future AMT177)

Status: approved 2026-09-02 — implementation in progress.

## Goal
One shared Keycloak server (`:8080`) with ONE shared realm `amtrealm` and one shared
client pair used by all AMT lanes. Stand up on AMT175 first, then wire AMT172 to the
same realm/clients/secret. Future AMT177 reuses the same registrations.

## Authoritative sources
- **.NET wiki** (AMT .NET/1729 IDP-Keycloak, Sietze Koonstra) — PRIMARY for this product.
- Java wiki (AMT Java/1535) — secondary/reference only (different product, Angular:4200).
- `Quick start guide AMT-KeyCloak.docx` — already summarised in AMT175-Setup-Guide.html §3.

## Deviation from repo instructions (approved)
- `.github/copilot-instructions.md` originally said: Keycloak ONE server `:8080`, **two
  realms** (`amt172` + `amt175`).
- This plan consolidates to **one shared realm `amtrealm`** — approved by user as the new
  "AMT standard procedure" (the repo was set up without R&D's shared-setup guidance).
- Action: correct `copilot-instructions.md` + user memory to the shared-realm standard.

## Locked decisions
- Shared realm name: `amtrealm` (lowercase — Keycloak convention). Authority =
  `http://localhost:8080/realms/amtrealm` (case-sensitive; must match everywhere).
- Realm built **manually** per the .NET wiki (no import/config file needed).
- AMT172 CC URL: `http://localhost/working/controlcenter/`
- AMT175 CC URL: `http://localhost/AMT175/ControlCenter/`
- Two-client model per .NET wiki:
  - `amt-cc-api` — API resource server: OIDC, ALL auth flows DISABLED, no client auth.
  - `amt-cc` — CC app: Client Authentication ON (confidential); holds redirect URIs.
  - Client scope `amt-cc-api-scope` with an Audience mapper → Included Client Audience
    `amt-cc-api`; assigned to `amt-cc` as **Optional** (confidential client).
- One shared `amt-cc` client holds BOTH lanes' redirect URIs / web origins
  (wiki tip: multiple redirect URIs allowed). ONE `amt-cc-api`, ONE scope per API.

## Root cause found (why AMT175 was "broken")
- `ControlCenterWebApi/appsettings.json` validated `Audience: amt-cc`, but the audience
  mapper on `amt-cc-api-scope` emits `amt-cc-api` → token audience mismatch → rejected.
- Fix: WebApi `Audience` `amt-cc` → `amt-cc-api`.
- .NET wiki: "Avoid using the confidential client as an audience."

## Current AMT175 state (verified)
- Core `appsettings.json`: realm `amt175`, ClientId `amt-cc`, Scope `amt-cc-api-scope`,
  ClientSecret present, RequireHttpsMetadata false, cookie `.Amt.CC.AMT175.Auth`
  (already lane-distinct — no cookie collision).
- WebApi `appsettings.json`: realm `amt175`, Audience `amt-cc` (WRONG),
  RequireHttpsMetadata false.

## Steps

### Phase 0 — Persist plan
0. Save this plan under `.github/Copilot_Plans/`.  (this file)

### Phase 1 — KC running + real admin (start from tempadmin)
1. Ensure shared KC running on `:8080` (JAVA_HOME set; `kc.bat start-dev`). Skip
   download/extract (already installed).
2. `bin\kc.bat bootstrap-admin user` → `tempadmin`; log in; create real `admin` user +
   password; assign realm admin role; delete `tempadmin`; re-login as `admin`.

### Phase 2 — Build shared realm MANUALLY (.NET wiki)
3. Create realm `amtrealm` (top-left dropdown → Create realm).
4. Create client `amt-cc-api` (OIDC): Capability config → DISABLE all auth flows; no
   client auth (OAuth2 resource server). Save.
5. Create client `amt-cc` (OIDC): Capability config → Client Authentication ON
   (confidential). Login settings redirect URIs/web origins added in Phase 3.
6. Create client scope `amt-cc-api-scope`; Mappers → Configure a new mapper → Audience;
   Name "AMT CC API Audience mapper"; Included Client Audience = `amt-cc-api`. Save.
7. Clients → `amt-cc` → Client scopes → Add client scope → `amt-cc-api-scope` as
   **Optional**.

### Phase 3 — Shared client redirect URIs + secret
8. On `amt-cc`, add BOTH lanes' Valid redirect URIs + Web origins:
   - AMT175: `http://localhost/AMT175/ControlCenter/*`  + origin `.../ControlCenter`
   - AMT172: `http://localhost/working/controlcenter/*`  + origin `.../controlcenter`
9. `amt-cc` → Credentials tab → copy the client secret (shared by both lanes).

### Phase 4 — Wire AMT175 appsettings + user
10. Core `appsettings.json`: Authority realm `amt175` → `amtrealm`; ClientSecret → new
    shared secret. (ClientId `amt-cc`, Scope `amt-cc-api-scope`, RequireHttpsMetadata
    false already correct; cookie already lane-distinct.)
11. WebApi `appsettings.json`: Authority realm → `amtrealm`; Audience `amt-cc` →
    `amt-cc-api`.
12. Create realm user + password for login. Reconcile `AMTSYSIDENTITYTRANSLATION`; grant
    admin role via the Control Center UI (never direct `AMTSYS*` SQL).

### Phase 5 — Verify AMT175
13. Restart IIS / app pool. Hit CC URL → redirect to KC login → sign in → lands in CC.
    Check `http://localhost:8080/realms/amtrealm/.well-known/openid-configuration`.

### Phase 6 — AMT172 (wiring only; redirect URIs already added in step 8)
14. AMT172 Core `appsettings.json`: Authority realm → `amtrealm`; ClientId `amt-cc`;
    Scope `amt-cc-api-scope`; ClientSecret → shared secret; RequireHttpsMetadata false;
    ensure lane-distinct cookie name.
15. AMT172 WebApi `appsettings.json`: Authority realm → `amtrealm`; Audience →
    `amt-cc-api`; RequireHttpsMetadata false.
16. Verify AMT172 login end-to-end.

### Phase 7 — Docs + memory
17. Update `AMT175-Setup-Guide.html` `#keycloak-full` with an "Issues & Resolutions"
    subsection: (a) WebApi Audience `amt-cc` → `amt-cc-api` root cause; (b) shared
    `amtrealm` model replacing per-lane realms; (c) two-client model + optional scope.
    Each entry: exactly ONE citation per copilot-instructions.
18. Correct `.github/copilot-instructions.md` (two realms → shared `amtrealm`) + user
    memory note.

## Compliance notes (copilot-instructions)
- No direct SQL against `AMTSYS*`; admin granted via Control Center UI.
- No assumed `ROLEID`; no `AMTSYSCOMPONENTINROLE` INSERT.
- One KC server on `:8080` (not `:8081`); distinct IIS virtual folders per lane.
- Shared realm `amtrealm` is the approved deviation (see above).

## Open items
- New shared `amt-cc` client secret unknown until Phase 3 (Credentials tab) — appsettings
  ClientSecret to be pasted after the client is created.
- Confirm AMT172 cookie name is lane-distinct (avoid same-host collision on localhost).
