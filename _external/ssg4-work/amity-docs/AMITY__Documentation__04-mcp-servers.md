# 04 — MCP Servers

Related: [Architecture](./02-architecture-two-layers.md) · [Repositories & Workspace](./03-repositories-and-workspace.md) · [Skills](./05-skills.md) · [Distribution & Feed](./10-mcp-distribution-feed-and-auth.md)

MCP servers give the AI its tools (Azure DevOps, Lion repository, AMT config, …).
AMITY sorts them into **two kinds** (generic vs project-bound) but **defines them
all in the project**, each with a project-prefixed name.

## Distribution (single source of truth)

All AMT MCP servers have source in `amt-go-net/Tools.Net/MCP` with a solution
`MCP Servers.sln`. They are **published as .NET tools to the `AMT_Mcp` Azure
Artifacts feed** and consumed via `dotnet dnx` — see
[Distribution: Feed, `dnx` & Auth](./10-mcp-distribution-feed-and-auth.md) for the
feed URL, package IDs, authentication and versioning. `mcp.json` therefore uses
`command: "dotnet"` with `args: ["dnx", "<packageId>", "--source", "<feed>", "--yes", …]`
— **unpinned**, so each server runs the latest published version.

Every server is defined in the **project's** `.vscode/mcp.json`; the shared
`amt-go-net` repo defines **no** servers of its own (its `.vscode/mcp.json` is
empty). This keeps a project self-sufficient and its committed config collision-free.

## Two kinds (both defined in the project)

Both kinds live in the **project's** `.vscode/mcp.json` and **every** name is
`<project>-` prefixed. The kind only tells you whether the server needs
`--settings`.

### Generic (project-agnostic)

Project-agnostic tools — no per-project config:

| Server (Federale) | Source | Purpose |
|---|---|---|
| `federale-ado` | npm `@azure-devops/mcp` (no build) | Azure DevOps work items / repos / PRs |
| `federale-iis` | `IISMCP` | IIS sites & app pools |
| `federale-event-viewer` | `EventViewerMCP` | Windows Event Log |
| `federale-net-debug` | `NetDebugMCP` | Attach/inspect .NET processes (packaged `net10.0`, Windows-only at runtime) |

### Project-bound

The shared tool package pointed at a **specific project's** database/runtime via
`--settings <path>`:

| Server (Federale) | Source | Connects to |
|---|---|---|
| `federale-lion-repository` | `LionRepositoryMCP` | that project's Lion repository DB |
| `federale-amt-config` | `AmtConfigurationManagerMCP` | that project's ControlCenter BL + Keycloak |
| `federale-amt-script` | `AmtScriptMCP` | that project's AMT runtime (`sys.ini`) |
| `federale-keycloak` | `KeyCloakMCP` | that project's Keycloak (admin credentials) |

Naming rule: **every** server is `<project>-<server>` (e.g. `federale-ado`,
`federale-lion-repository`). A future project uses `csm-…`, so committed configs
never collide across workspace folders, the user-level `mcp.json`, or projects.

## Capability profile (target language)

The manifest's `mcp.capabilityProfile` (`dotnet` | `java`) plus a `servers`
enable-map declare **which** shared servers apply to a project, so the same
generic skills degrade gracefully across target languages:

| Capability | `.NET` project (Federale) | `Java` project (Macy's-style) |
|---|---|---|
| `lion-repository`, `amt-config`, `amt-script`, `keycloak`, `iis` | enabled | enabled (runtime is still AMT) |
| `net-debug` | enabled | **disabled** (no .NET debugger \u2014 use Java tooling) |
| converter / generator skills | apply | apply (Java is a converter target too) |

A skill's `requires:` frontmatter is checked against this map: a `skill-with-profile`
that needs `net-debug` (e.g. `debug-transaction-server`) tells a `java` project to
use the Java debugger instead of failing. See
[Project Manifest](./07-project-manifest-and-configuration.md) and
[Authoring Standard](./08-authoring-standard.md).

## The `--settings` mechanism

Each project-bound server accepts `--settings <path>` and reads its config from
there; without the flag it falls back to `appsettings.json` next to the binary
(backward compatible). All 7 packaged servers support this, including
`federale-keycloak`.

```jsonc
"federale-lion-repository": {
  "type": "stdio",
  "command": "dotnet",
  "args": ["dnx", "Asysco.Amt.Mcp.LionRepository", "--source", "https://pkgs.dev.azure.com/avanade-lt-coe/AMT_Products/_packaging/AMT_Mcp/nuget/v3/index.json", "--yes", "--settings", "${workspaceFolder:Federale_Migration}/amt-mcp/lion-repository.appsettings.json"]
}
```

## Config files & secrets (per project)

There is **no sharable config** — every value (server URLs, DB names, paths,
credentials) can differ per machine, so each server has a **single user-specific
file** and only the template is committed. Under `<Project>_Migration/amt-mcp/`,
per project-bound server:

- `<name>.appsettings.json.sample` — **committed** template with placeholders
  (`CHANGE_ME`) and inline notes. The **only** config file checked in.
- `<name>.appsettings.json` — **gitignored**, USER-SPECIFIC. Each engineer copies
  it from the `.sample` and fills in their environment, **including any secret**
  (DB password, Keycloak client/admin secret).

`mcp.json` points `--settings` at `<name>.appsettings.json`. `amt-script` has no
secret, but its config (paths, app name) is still user-specific, so it follows the
same copy-from-`.sample` rule.

`.gitignore` rules in the project repo:
```
/amt-mcp/*.json              # all real configs are user-specific — never committed
/.vscode/*                   # ignore VS Code folder…
!/.vscode/mcp.json           # …except the shared MCP config
```
The `.json.sample` templates end in `.sample`, so `/amt-mcp/*.json` does **not**
match them — they stay committed. (Repo convention puts `.sample` last, matching
git-hook samples like `pre-commit.sample`.)

## Setup order & where values come from

Configure the project-bound servers in dependency order — each server's values can
be **discovered with the previous one's tools**, so only a few are truly
hand-supplied. (The install skill
[`install-amt-mcp-servers`](../../.github/skills/install-amt-mcp-servers/SKILL.md)
has the tool-by-tool detail.)

1. **keycloak** (root of trust) — all hand-supplied: `BaseUrl`, `AdminUsername`,
   `AdminPassword`, `DefaultRealm` (`master`). Auth is a password grant via `admin-cli`.
2. **amt-config** — derived from keycloak (+ the generic `iis` server):
   - `KeycloakTokenUrl` = `{BaseUrl}/realms/{realm}/protocol/openid-connect/token`; the
     AMT realm (e.g. `AmtWorking`, **not** `master`) comes from keycloak `list_realms`.
   - `ClientId` = the confidential client (e.g. `amt-config-mcp`) from keycloak
     `list_clients`. **On a fresh system it may not exist** — create it (`create_client`,
     confidential + `serviceAccountsEnabled`) and grant it the ControlCenterBL audience/roles.
   - `ClientSecret` from keycloak `get_client_secret` (or `regenerate_client_secret`).
   - `ControlCenterBlUrl` from `iis` `list_sites` + `list_applications` (the `/…/ControlCenterBL` app).
3. **amt-script** — `AppName` + `ApplicationKind` from amt-config `list_applications`;
   `SysIniFile` is a local path.
4. **lion-repository** — standalone; hand-supplied SQL host + Lion **developer repository**
   DB (e.g. `WORKING_REPOS`), which is *not* among amt-config's (runtime) database settings.

**Re-derive per machine — never copy another machine's values.** Realm name, `ClientId`
(may be absent), ControlCenterBL host/port/path, and the SQL host all vary. Always
hand-supplied: Keycloak admin creds, the `sys.ini` path, and the repository DB login.

## One project file owns all servers

A multi-root workspace aggregates every folder's `.vscode/mcp.json`. Because the
shared `amt-go-net` folder now defines **no** servers, opening
`<Project>.code-workspace` yields exactly the project's own `federale-*` servers —
nothing to merge or collide. Server names being `<project>-` prefixed keeps them
unique even against a populated user-level `mcp.json` or another project. Federale
uses **no Jira**, so no Jira server is present.
