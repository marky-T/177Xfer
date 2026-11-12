# 10 — MCP Distribution: Feed, `dnx` & Auth

Related: [MCP Servers](./04-mcp-servers.md) · [Repositories & Workspace](./03-repositories-and-workspace.md) · [Authoring Standard](./08-authoring-standard.md)

**In plain language:** instead of every engineer building the MCP servers from
source and pointing VS Code at `bin/Debug` exes, the servers are **published once
as .NET tools to a private NuGet feed**, and each machine **runs them straight
from that feed** with `dotnet dnx`. This doc is the authority on *how servers are
packaged, published, authenticated and consumed*. Doc 04 remains the authority on
*categories, `--settings` and config/secrets*.

> This supersedes the "Build from the repo → point at Debug exes" mechanism in
> doc 04. Source still lives in `amt-go-net/Tools.Net/MCP`; that is now the input
> to the **pipeline**, not something each engineer builds to run the servers.

## The model at a glance

```
source (Tools.Net/MCP)  ──►  pipeline packs as .NET tools  ──►  AMT_Mcp feed
                                                                     │
                          VS Code mcp.json  ◄── dotnet dnx restore ──┘
```

- **Package** — each server is a .NET tool (`PackAsTool`) and is **self-contained**
  (its nupkg bundles all dependency DLLs), so consuming it needs **only** the
  AMT_Mcp feed — not nuget.org.
- **Publish** — [`pipelines/amt-mcp.yml`](../../pipelines/amt-mcp.yml) builds and
  packs all 7 servers and pushes them to Azure Artifacts.
- **Consume** — `mcp.json` runs `dotnet dnx <packageId> --source <feed>`
  (**unpinned** = latest published version).

## The feed

Azure Artifacts feed **`AMT_Mcp`** in project **`AMT_Products`** (org
`avanade-lt-coe`). NuGet v3 index:

```
https://pkgs.dev.azure.com/avanade-lt-coe/AMT_Products/_packaging/AMT_Mcp/nuget/v3/index.json
```

## Package IDs

| Server | Package ID | Version (example) |
|---|---|---|
| LionRepository | `Asysco.Amt.Mcp.LionRepository` | `1.6.0` |
| AmtConfig | `Asysco.Amt.Mcp.AmtConfig` | `0.6.0` |
| AmtScript | `Asysco.Amt.Mcp.AmtScript` | `1.0.0` |
| EventViewer | `Asysco.Amt.Mcp.EventViewer` | `0.3.0` |
| IIS | `Asysco.Amt.Mcp.Iis` | `0.3.0` |
| Keycloak | `Asysco.Amt.Mcp.Keycloak` | `0.3.0` |
| NetDebug | `Asysco.Amt.Mcp.NetDebug` | `0.1.0` |

`ado` is **not** in the feed — it stays on npm (`npx @azure-devops/mcp`).

## Consuming a server in `mcp.json`

Generic server (no config):

```jsonc
"federale-net-debug": {
  "type": "stdio",
  "command": "dotnet",
  "args": ["dnx", "Asysco.Amt.Mcp.NetDebug",
           "--source", "https://pkgs.dev.azure.com/avanade-lt-coe/AMT_Products/_packaging/AMT_Mcp/nuget/v3/index.json",
           "--yes"]
}
```

Project-bound server (adds the `--settings` path from doc 04):

```jsonc
"federale-lion-repository": {
  "type": "stdio",
  "command": "dotnet",
  "args": ["dnx", "Asysco.Amt.Mcp.LionRepository",
           "--source", "https://pkgs.dev.azure.com/avanade-lt-coe/AMT_Products/_packaging/AMT_Mcp/nuget/v3/index.json",
           "--yes",
           "--settings", "${workspaceFolder:Federale_Migration}/amt-mcp/lion-repository.appsettings.json"]
}
```

Flag notes:
- **No `@version`** — the package ID is unpinned, so dnx resolves the **latest**
  published version. Append `@<version>` only to pin (see Versioning).
- **`--source`** (not `--add-source`) restricts restore to the feed only. Safe
  because the tool packages are self-contained; it avoids needless nuget.org
  lookups.
- **`--yes`** suppresses dnx's run-confirmation prompt — required, because VS Code
  launches the server with no console to answer a prompt.
- **`--settings <path>`** is forwarded to the tool (project-bound servers only).

## Authentication

The feed is private, so restore needs the **Azure Artifacts Credential Provider**.
It is **not** bundled with the .NET SDK and **not** the Windows login — install it
once per machine:

```powershell
iex "& { $(irm https://aka.ms/install-artifacts-credprovider.ps1) }"
```

Behaviour once installed:
- With an existing Azure DevOps / Entra sign-in, auth is **silent (MSAL Silent)** —
  no browser, no PAT. The token is cached and reused.
- VS Code launches the server **non-interactively**, so the **first** restore of a
  new package/version must have a usable cached token. If none exists, run one
  interactive restore in a terminal to seed it:
  `dotnet dnx <id> --source <feed> --interactive --yes`
- CI uses a PAT via the pipeline's `NuGetAuthenticate` / `publishVstsFeed`, not
  interactive.

Where it lives (it is just a NuGet plugin — nothing runs in the background):
- **Plugin DLLs:** `%USERPROFILE%\.nuget\plugins\netcore\CredentialProvider.Microsoft\`
  (used by `dotnet`/`dnx`) and `…\netfx\…` (classic `nuget.exe`). Verify with
  `Get-ChildItem "$env:USERPROFILE\.nuget\plugins" -Recurse -Filter CredentialProvider.Microsoft.dll`.
- **Cached token:** `%LOCALAPPDATA%\MicrosoftCredentialProvider\SessionTokenCache.dat`
  — this is why non-interactive VS Code launches work.
- **Force re-auth** (expired token / wrong account): delete that cache file, then
  restore once with `--interactive`.

**Per-developer prerequisite:** credential provider installed + signed in to Azure
DevOps. `.NET 10 SDK` must also be present (that is what provides `dotnet dnx`).

## Versioning & distribution

- **Default = unpinned.** `mcp.json` omits `@version`, so dnx resolves the
  **latest** published version from the feed. That is the whole point of packaging
  the servers: publish once, everyone gets the newest on the next server reload.
- dnx caches the resolved version in the global NuGet folder
  (`%USERPROFILE%\.nuget\packages`); a **running** server keeps its version until
  the MCP servers are reloaded (or VS Code restarts), when it re-checks the feed.
- Publishing is just: raise `McpServerVersion` → pipeline packs & pushes → users
  pick it up on reload. Published versions are **immutable** (a version can't be
  overwritten), and **prereleases are excluded** unless a server adds `--prerelease`.
- **Optional pinning.** For a reproducibility-critical server, append `@<version>`
  to freeze it; bumping it then becomes a deliberate one-line commit.

## The publish pipeline

[`pipelines/amt-mcp.yml`](../../pipelines/amt-mcp.yml): install .NET 10 → restore →
build `MCP Servers.sln` → pack the 7 tool projects → push `*.nupkg` to the feed.

- `feedName` **must** be `AMT_Products/AMT_Mcp` (the real feed name).
- Triggers on `develop` for `Tools.Net/MCP/**`.
- Auth to the feed is handled by the task's `publishVstsFeed` (build-service
  identity) — no PAT in the YAML.

## Local simulation (offline / fast iteration)

`C:\Tools\simulate-amt-mcp-pipeline.ps1` mirrors the pipeline against the working
tree: restore → build → pack → push to a **local folder feed**
(`C:\Tools\LocalMcpFeed`) → optional `dnx` handshake. During development you can
point `--source`/`--add-source` at that folder instead of the real feed.

The script also **evicts the packed packages from the global NuGet cache**, because
dnx will otherwise keep serving a stale same-version copy after a repack.

## Gotchas

- **Running server locks its cache.** A live MCP server (launched by VS Code) holds
  file locks under `…\.nuget\packages\<id>\<ver>\…`; clearing/replacing that cache
  fails until the server process is stopped.
- **Same-version repack isn't seen** until the global cache entry is evicted (local
  sim does this; the real feed avoids it by bumping the version).
- **`dnx` requires the .NET 10 SDK.** Machines with only .NET 8/9 have no `dnx`.
- **Self-contained packages** mean `--source <feed>` alone is enough — no nuget.org
  needed for restore.
