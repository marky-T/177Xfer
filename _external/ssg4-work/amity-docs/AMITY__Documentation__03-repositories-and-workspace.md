# 03 — Repositories & Workspace

Related: [Architecture](./02-architecture-two-layers.md) · [MCP Servers](./04-mcp-servers.md)

## Repositories (Federale example)

| Repo | Role |
|---|---|
| `amt-go-net` | AMT toolchain sources **+ shared AMT-layer AMITY** (`AMITY/`, MCP server sources + `AMT_Mcp` feed/pipeline, toolchain skills; no server definitions of its own) |
| `Federale_Received` | Pristine received sources (COBOL, AbSuite/LINC, ECL) |
| `Federale_Migration` | Settings, scripts, manuals **+ project-layer AMITY** (manifest, project memory, project skills, **all** MCP servers in `.vscode/mcp.json`) |
| `Federale_InternalRelease` | The converted application (C# + PowerShell) |

Another project (e.g. CSM) uses the **same** `amt-go-net` plus its own
`CSM_Received` / `CSM_Migration` / `CSM_InternalRelease`.

## Sibling-clone convention

**Rule #1 of setup:** clone all of a project's repos as **siblings under one base
path**. The base path may differ per engineer (`C:\Users\<you>\source\repos`,
`C:\Repos`, …) — only the sibling relationship matters.

This makes everything path-independent:
- The `.code-workspace` uses **relative** folder paths (`../amt-go-net`), which
  resolve regardless of the base path.
- MCP configs use `${workspaceFolder:<name>}` variables (see
  [MCP Servers](./04-mcp-servers.md)), never absolute paths.

If repos genuinely cannot be siblings, a per-user base-path env var is the
fallback — but the sibling convention is preferred and documented as the norm.

## The workspace file

Each project commits a `<Project>.code-workspace` in its `_Migration` repo. It
mounts the repos with relative paths and **names** each folder — the name is what
`${workspaceFolder:<name>}` resolves against.

```jsonc
// Federale.code-workspace (in Federale_Migration)
{
  "folders": [
    { "path": "../amt-go-net", "name": "amt-go-net" },
    { "path": "../Federale_Received", "name": "Federale_Received" },
    { "path": ".", "name": "Federale_Migration" },
    { "path": "../Federale_InternalRelease", "name": "Federale_InternalRelease" }
  ],
  "settings": {}
}
```

Engineers **open the `.code-workspace`**, not an individual folder — the
named-folder MCP variables only resolve inside the multi-root workspace.

## Per-machine setup (one time)

1. Clone the project's repos as siblings under one base path.
2. Install the Azure Artifacts Credential Provider so `dotnet dnx` can restore the
   MCP servers from the `AMT_Mcp` feed (see [MCP Servers](./04-mcp-servers.md)).
3. Copy each project-bound server's `<name>.appsettings.json.sample` →
   `<name>.appsettings.json` (gitignored) and fill in your environment. Configure
   them in dependency order (keycloak → amt-config → amt-script; lion-repository is
   standalone) — most values can be discovered with the previous server's tools.
   See [MCP Servers → Setup order](./04-mcp-servers.md).
4. Open `<Project>.code-workspace`; trust the MCP servers when prompted.

A dedicated **install skill** automates steps 2–4.

## To verify empirically

- That a multi-root workspace picks up each member folder's `.vscode/mcp.json`.
- That `${workspaceFolder:amt-go-net}` resolves from within `amt-go-net`'s own
  `.vscode/mcp.json`. If not, the fallback is to inline the servers in the
  `.code-workspace`. Tracked in [Status & Decisions](./09-status-decisions-roadmap.md).
