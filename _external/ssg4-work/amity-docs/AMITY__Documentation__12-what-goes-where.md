# 12 — What Goes Where (the placement reference)

Related: [Architecture](./02-architecture-two-layers.md) · [Skills](./05-skills.md) · [Memory](./06-memory.md) · [Instructions](./11-instructions.md) · [MCP Servers](./04-mcp-servers.md) · [Manifest](./07-project-manifest-and-configuration.md)

This is the **single source of truth** for *what goes where, when, and whether it
is committed* — across both the AI artifacts and the environment/config elements.
When in doubt, decide here.

## The two layers (recap)

- **Generic / platform** = `amt-go-net` — true for **any** AMT migration (.NET or Java).
- **Project / engagement** = `<Project>_Migration` (e.g. `Federale_Migration`) —
  true for **one** customer. Names its apps/screens/DBs/ADO project.

> **Placement test (applies to everything below):** if it would help a *different*
> AMT team unchanged → **generic** (`amt-go-net`). If it names a customer app,
> screen, DB, ADO project, credential, or path → **project** (`<Project>_Migration`).

## Part A — AI / knowledge artifacts

| Artifact | What it is | Layer | Path | Committed? | Add / update when |
|---|---|---|---|---|---|
| **Instruction** (`*.instructions.md`) | always-on **rule / gotcha** (auto-loaded via `applyTo`) | generic **or** project | `.github/instructions/` | **Yes** | a rule must apply automatically ([11](./11-instructions.md)) |
| **Skill** (`SKILL.md`) | a **procedure / how-to** (chosen on demand) | generic **or** project | `.github/skills/<name>/` | **Yes** | a stable procedure recurs ([05](./05-skills.md)) |
| **Agent** (`*.agent.md`) | an **orchestrated workflow / persona** that chains skills + tools | generic **or** project | `.github/agents/` | **Yes** | a repeatable multi-step workflow needs one entry point *(none yet in AMITY)* |
| **Prompt** (`*.prompt.md`) | a **reusable saved prompt** for a common ask | generic **or** project | `.github/prompts/` | **Yes** | the same request is issued repeatedly |
| **Memory — shared** (`continuity.md`) | **evolving project findings / decisions** | **project only** | `memory/continuity.md` | **Yes** | end of a session with a durable finding ([06](./06-memory.md)) |
| **Memory — volatile** | personal / in-progress scratch | project | `memory/local/` | **No** (gitignored) | freely; never committed |
| **Memory — archive / tickets** | faded facts / long distillations | project | `memory/archive/`, `memory/tickets/` | **Yes** | created by `refine-memory` |
| **Manifest** (`amity.project.json`) | project identity, MCP profile, runtime profile | project | repo root | **Yes** | identity / servers / runtime targets change ([07](./07-project-manifest-and-configuration.md)) |
| **Workspace** (`*.code-workspace`) | which repos mount together | project | repo root | **Yes** | the repo set changes |
| **Design docs** | AMITY design & reference (this set) | generic | `amt-go-net/AMITY/Documentation/` | **Yes** | the design changes |

**No generic `continuity.md` exists.** Generic *findings* are captured in the
project `continuity.md` first, then **refined** into a generic **skill**,
**instruction**, or **doc** in `amt-go-net` (bullet → one-line pointer). See
[06 — Memory](./06-memory.md) operating procedures.

## Part B — Environment / configuration elements

| Element | What it is | Where | Committed? | Notes |
|---|---|---|---|---|
| **MCP server definitions** | which servers run + their `dnx` args | `<Project>_Migration/.vscode/mcp.json` | **Yes** | project-prefixed (`federale-…`), unpinned ([04](./04-mcp-servers.md)) |
| **MCP server source** | the server code | `amt-go-net/Tools.Net/MCP` | **Yes** | published to the `AMT_Mcp` feed ([10](./10-mcp-distribution-feed-and-auth.md)) |
| **Server settings (real)** | connection strings, DB names, paths, **credentials** | `<Project>_Migration/amt-mcp/<name>.appsettings.json` | **No** (gitignored) | **user-specific**; one per project-bound server |
| **Server settings (template)** | placeholders + notes | `<Project>_Migration/amt-mcp/<name>.appsettings.json.sample` | **Yes** | `CHANGE_ME` placeholders; the only config checked in |
| **Repositories** | received / migration / output / toolchain | sibling folders per `manifest.repos` | each has **its own** git | roles: received *(pristine)*, migration *(settings/scripts + AMITY)*, output *(converted)*, `amt-go-net` *(toolchain + shared AMITY)* |
| **Runtime targets** | app name, transaction-server, debug port, `sys.ini`, pool | `amity.project.json` → `runtime.applications[]` | **Yes** | **non-secret** only; read by `skill-with-profile` skills |
| **Capability profile** | target language + enabled servers | `amity.project.json` → `mcp.capabilityProfile` + `servers` | **Yes** | `dotnet` enables `net-debug`; `java` disables it |
| **Login names / credentials / secrets / PATs / tokens** | Keycloak admin, DB creds, feed PATs | **only** in gitignored `*.appsettings.json` or the OS/user secret store | **NEVER** | never in memory, skills, instructions, docs, or the manifest |

## Secrets — the one hard rule

**No secret, credential, login name, token, PAT, or PII ever goes in a committed
file.** They live only in the gitignored `amt-mcp/<name>.appsettings.json` (copied
from the committed `.sample`) or in the OS/user secret store. Committed files
(`continuity.md`, skills, instructions, docs, manifest, `.code-workspace`,
`mcp.json`, `*.sample`) are team-visible and must stay clean.

## Quick decision guide ("I have X — where does it go?")

| I have… | It goes to… |
|---|---|
| a **durable finding** (root cause, decision, gotcha) | `continuity.md` (one line). If **generic**, refine into an `amt-go-net` skill/instruction/doc and leave a pointer |
| a **rule that must always apply** | an **instruction** (`.github/instructions/`) — generic → `amt-go-net`, project → project |
| a **repeatable procedure** | a **skill** — generic (+ profile if only values differ) or project |
| a **multi-step workflow chaining skills/tools** | an **agent** (`.github/agents/`) |
| a **connection value / path / non-secret runtime target** | `amity.project.json` (`runtime` / `mcp`) or a server `*.appsettings.json` |
| a **secret / login / token** | **gitignored** `*.appsettings.json` or secret store — never committed |
| a **new project** | a new `<Name>_Migration` (manifest + workspace + `.vscode/mcp.json` + `amt-mcp/*.sample` + seed `memory/`) — reuse `amt-go-net` unchanged ([07](./07-project-manifest-and-configuration.md)) |
| a **new MCP tool / server** | source in `amt-go-net/Tools.Net/MCP`, published to the feed, referenced in the project `mcp.json` |

## Generic vs project — worked examples

| Knowledge | Type | Home |
|---|---|---|
| "never call lion-repository MCP in parallel" | rule | **generic instruction** (`amt-go-net`) — already exists |
| `create_object` generic error = stale server; 0-byte files → saveAll before build | rule | **generic instruction** (`amt-go-net`, planned `amt-tooling`) |
| Generator native-int copy-param typed `AmtVariable` (`RegisterVariableUsageInCopy`) | product defect | AMT_Products work item + generator known-issues **doc/skill** (`amt-go-net`) |
| AFBUS transaction-server name / debug port | env target | **project** manifest `runtime.applications[]` |
| TXN001 routing decision, AFLINC gateway behaviour | project finding | **project** `continuity.md` (`Federale_Migration`) |
| Keycloak admin password, Lion DB connection string | secret | **gitignored** `amt-mcp/*.appsettings.json` — never committed |
