# 07 — Project Manifest & Configuration

Related: [Architecture](./02-architecture-two-layers.md) · [MCP Servers](./04-mcp-servers.md) · [Memory](./06-memory.md)

Each project declares its identity in one committed file so the AI and the team
know what the project is, what tooling is active, and which repos it spans.

## `amity.project.json`

Lives at the root of `<Project>_Migration`. Purpose: the single declarative source
of project identity. Current shape (Federale):

```jsonc
{
  "amityProject": {
    "name": "Federale",
    "displayName": "Federale Assurance (FA) migration",
    "description": "Migrate Federale AbSuite/LINC, COBOL and ECL applications to Lion/AMT (.NET).",
    "ado": { "org": "avanade-lt-coe", "project": "Federale", "workItemLanguage": "en" },
    "git": { "branchPrefix": "feature/federale", "baseBranch": "develop" },
    "sharedAmity": "amt-go-net",
    "repos": [ /* name, role, relative path per repo */ ],
    "languages": { "source": ["COBOL", "AbSuite/LINC", "ECL"], "target": ["C#", "PowerShell"] },
    "mcp": {
      "inheritsShared": true,
      "capabilityProfile": "dotnet",          // "dotnet" | "java" — which shared servers apply
      "servers": { "net-debug": { "enabled": true }, "lion-repository": { "enabled": true } /* ... */ },
      "projectServers": [], "disabled": ["jira"]
    },
    "runtime": {                              // consumed by skill-with-profile skills
      "applications": [
        { "name": "AFBUS_AMT", "transactionServer": "<name>", "debugPort": 5005,
          "sysIni": "Settings/sys.ini", "controllerPool": "Working_ControlCenterBLPool" }
      ]
    },
    "features": { "jira": false },
    "workspace": "Federale.code-workspace",
    "memory": { "shared": "memory/continuity.md", "volatile": "memory/local/" }
  }
}
```

### Fields

| Field | Meaning |
|---|---|
| `ado` | ADO org + project → feeds "create a project issue" |
| `git` | Product-repo branch conventions: **`branchPrefix`** (feature branches are `<branchPrefix>/<ticket-id>-<description>`) and **`baseBranch`** (pull it fresh, then branch from it) — see "Branch Strategy" in `amt-go-net/.github/copilot-instructions.md` |
| `sharedAmity` | Sibling folder name of the shared layer (`amt-go-net`) |
| `repos` | Repos the workspace mounts, with roles |
| `languages` | Source/target languages (drives RCA/analysis context) |
| `mcp` | Inherit shared servers; **`capabilityProfile`** (`dotnet`/`java`) + **`servers`** enable-map decide which shared servers apply; list project-only + disabled |
| `runtime` | Project runtime targets (e.g. `applications[]`: app name, transaction-server, debug port, `sys.ini`, controller pool) read by `skill-with-profile` skills such as `debug-transaction-server` |
| `features` | Feature toggles (e.g. `jira: false`) |
| `workspace` | The `.code-workspace` file name |
| `memory` | Paths to committed + volatile memory |

## What makes a project distinct

The shared AMT layer is identical for every project. A project differs only in:
1. its **manifest** (identity, languages, active features),
2. its **`.vscode/mcp.json`** (project-bound servers + `amt-mcp/` configs),
3. its **`.code-workspace`** (which repos),
4. its **memory** and **project skills**.

## Adding a new project (e.g. CSM)

1. Create `CSM_Migration` (+ `CSM_Received`, `CSM_InternalRelease`).
2. Copy the manifest, set `name`, `ado.project`, `repos`, `languages`, features.
3. Add `CSM.code-workspace` (mount `amt-go-net` + the CSM repos).
4. Add `CSM_Migration/.vscode/mcp.json` with `csm-*` project-bound servers and
   `amt-mcp/*.appsettings.json.sample` config templates (each engineer copies a
   template to `*.appsettings.json`, which is gitignored).
5. Seed `memory/continuity.md`; enable any project-specific servers/features
   (e.g. a Jira server, if that project uses Jira).

The shared `amt-go-net` layer is reused **unchanged**.
