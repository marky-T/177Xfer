# AMT175 Setup Assistant Instructions

You are assisting with the **AMT175** installation and setup, running as a
**parallel lane** alongside an existing **AMT172** lane on the same machine.

Authority: `AMT175 VS Code Installation Guide v3.md` (v3) supersedes
`AMT_Implementation_AMT175_Analysis_Merged.md` (baseline / Doc B). Where the two
differ, v3 wins.

## Authoritative sources

Use only these, in this priority order:

1. `C:\Amt\AMT_ReferenceDocuments\AMT157_Online_help` — online help HTML pages (highest priority)
2. `C:\Amt\AMT_ReferenceDocuments\AMT_LionReferenceDocs` — AICL, ALPD, LincToLion, Control Center, migration specs
3. Other folders under `C:\Amt\AMT_ReferenceDocuments` (`AMT_ECLtoPowershell`, `AMTSiteSurveyReferenceDocs`)
4. `Announcement AMT175` + `AMT .Net 8 upgrade to .Net 10 Report.docx` — AMT175 toolchain values and AMT VS Generator citation

## Non-authoritative sources

- The AMT172 generated setup guide / `AMT172-Setup-Guide.html`. Use it for
  **structure only**, never as implementation authority.
- `Setting Up Parallel VS Code Projects.docx` — scaffolding only, never AMT authority.

## Core rules

- Do not suggest direct SQL against `AMTSYS*` tables.
- Do not assume role IDs (e.g. `ROLEID=2`).
- Do not grant component rights by INSERT into `AMTSYSCOMPONENTINROLE`.
- Do not bypass `Setup.exe` for repository setup.
- Do not bypass `AmtReorganize` for System/Application DB creation.
- Prefer `Setup.exe`, `AmtReorganize`, Control Center, Keycloak, and LincToLion
  documented workflows.
- Every step must include: authority, inputs, action, verification, expected
  result, risks — plus exactly one Citation (see below).
- If a proposed action differs from the reference docs, mark it `⚠ Review` and
  explain why.

## Citation rule

Every generated AMT175 guide step must include **exactly one** citation.

Format:
`Citation: <relative-path-from-AMT_ReferenceDocuments> — <page/section/heading>`

Allowed examples:
- `Citation: AMT157_Online_help/first-use-of-the-control-center.html — Restore admin`
- `Citation: AMT_LionReferenceDocs/AMT Installation and Configuration (AICL).md — Running Setup.exe`
- `Citation: <em>n.cite</em>`

Rules:
- Do not write “AMT docs” as a citation.
- Do not cite multiple documents for one step; choose the highest-priority source only.
- Do not use `AMT172-Setup-Guide.html` as a step citation authority.
- If the step is inferred from experience or parallel-run scaffolding only, use
  `Citation: <em>n.cite</em>`.

## Parallel-run rules (AMT172 + AMT175 on one machine)

- `AMTSYSTEM` is a Machine-level Windows env var containing BOTH lane `Sys.ini`
  paths, separated by a semi-colon (**no spaces**). Machine scope is required so
  AMT runtime services (LocalSystem) read both lanes.
  Citation: AICL/AICC/AICVC.
- Each lane has its own `Sys.ini` at the lane root: `C:\Amt\Parallel\<LANE>\Sys.ini`.
- Each lane has its own `Lion.ini` with UNIQUE: `URL`, `VIRTUALFOLDER`,
  `LIONDEVNETSERVICENAME`, `DBSNAME`.
- `ASPNETCORE_URLS`, `ASPNETCORE_ENVIRONMENT`, and connection strings are scoped
  in `launchSettings.json` / `launch.json` / `tasks.json` — never at machine scope.
- Keycloak: ONE server on `8080`, two realms (`amt172` and `amt175`). Do not spin
  up a second Keycloak on `8081`.
- AMT VS Generator is NOT part of this installation/runtime workflow. It is only
  invoked to scaffold a NEW AMT project (VS2026 target). Citation for any AMT VS
  Generator reference: `AMT .Net 8 upgrade to .Net 10 Report.docx` Section 2
  (Borger, Bruecher, Upadhyay; 10 June 2026).
- Every generated step must include exactly one AMT authority citation, or
  `Citation: <em>n.cite</em>` when parallel-run scaffolding is the only source.

## Parallel-run hard rules (reject these)

- Overwriting `AMTSYSTEM` with a single-lane value.
- `setx` / `Set-ItemProperty` against `AMTSYSTEM`.
- Spaces around the semi-colon in `AMTSYSTEM`.
- `ASPNETCORE_URLS` at machine or User scope.
- Starting `kc.bat` with `--http-port 8081`.
- Reusing an IIS virtual folder name across lanes.
- Reusing `LIONDEVNETSERVICENAME` across lanes.
- Treating the AMT VS Generator as required for runtime / Control Center /
  Keycloak / `Sys.ini` / `AMTSYSTEM` / DB configuration.

Detection patterns to flag: `setx AMTSYSTEM=...`, `Set-ItemProperty ... AMTSYSTEM`,
`ASPNETCORE_URLS` at machine scope, `applicationUrl` duplicated across lane
profiles, `kc.bat --http-port 8081`, `INSERT|UPDATE|DELETE ... AMTSYS*`,
`ROLEID = <n>`.

## Lane facts (AMT175)

- Install root: `C:\Amt\Parallel\AMT175`
- `Sys.ini`: `C:\Amt\Parallel\AMT175\Sys.ini`
- `AMTSYSTEM` (Machine): `C:\Amt\Parallel\AMT172;C:\Amt\Parallel\AMT175` (no spaces)
- IIS virtual folder: `AMT175` — Control Center at `http://localhost/AMT175/ControlCenter`
- Ports: HTTP `5175`, HTTPS `7175` (AMT172 owns `5172`/`7172`)
- Keycloak: `http://localhost:8080`, realm `amt175`
- .NET SDK: `10.0.203` exact (enforced by `global.json`)
- Databases: `AMT175_REPOS`, `AMT175_SYSTEM`, `AMT175_LINC`, `AMT175_APP`
- `LIONDEVNETSERVICENAME`: `Amt175_Generator`

VS Code + .NET SDK 10.0.203 is sufficient for this guide. Visual Studio 2026 is
required ONLY for (a) invoking the AMT VS Generator to scaffold a new AMT project,
or (b) opening/building AMT .NET 10 solutions in the Visual Studio IDE.

## AMT install setup steps (cross-lane — required for Control Center to open)

These are mandatory AMT install steps for EVERY lane (AMT172 and AMT175). They were
re-derived on the AMT175 lane during the Control Center "not authorized" incident; capture
them for any future AMT build based on this lane.

- Control Center OIDC over HTTP Keycloak: `"RequireHttpsMetadata": false` must be present in
  BOTH Control Center config files, or login fails / Control Center will not open:
  - `AmtTools\ControlCenterCore\appsettings.json` → inside `Amt.Authentication.AmtOIDC.OIDC`.
  - `AmtTools\ControlCenterWebApi\appsettings.json` → inside `Amt.Authentication.JWT`.
  A fresh publish may ship it only in the WebApi (JWT) file — copy it into the Core OIDC block.
  Citation: REPRODUCTION_STEPS.md — RESOLUTION (2026-08-10).
- Identity resolution: Control Center maps the Keycloak login to an AMT user via
  `AMTSYSIDENTITYTRANSLATION`. If a valid login lands on `notauthorized.html` and the user is
  auto-added with role "User", the translation is not being applied (observed on build
  8.0.26188.0 where `AmtReorganize /RESTOREADMIN` wrote the row but CC did not honor it).
  Reconcile the translation, then grant the admin role through the Control Center UI — never
  by direct `AMTSYS*` SQL (see Core rules / Parallel-run hard rules above).
  Citation: REPRODUCTION_STEPS.md — PART 4/PART 5, RESOLUTION.
- AMT172 cross-reference: the AMT172 guide already documents the `RequireHttpsMetadata` step
  (Phase 3, Step 13) and an identity-translation step (Phase 5, Step 21). Treat both lanes as
  requiring these steps; do not assume AMT172 "skipped" them.
  Citation: <em>n.cite</em>
