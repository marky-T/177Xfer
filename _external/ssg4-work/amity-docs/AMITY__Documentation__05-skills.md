# 05 — Skills

Related: [MCP Servers](./04-mcp-servers.md) · [Memory](./06-memory.md) · [Authoring Standard](./08-authoring-standard.md)

**Skills capture the stable know-how of experienced engineers** as reusable
procedures the AI follows instead of re-deriving them each time. They are the
primary vehicle for "how to debug", "how to run an RCA", "how to install X".

## Skill vs memory vs instructions (do not mix)

| Type | Holds | Example |
|---|---|---|
| **Skill** | a **stable procedure** / how-to | "how to debug the generator" |
| **Memory** | **evolving** findings & decisions | "MZ-xxxxx root cause + fix" |
| **Instructions** | always-on **steering** rules | "read memory at session start" |

A stable procedure is a skill. A finding that changes over time is
[memory](./06-memory.md). An always-apply rule is an instruction.

## Format (the standard)

Skills are Copilot-discoverable at `.github/skills/<kebab-name>/SKILL.md` with
YAML frontmatter and a fixed section skeleton:

```markdown
---
name: <kebab-name>
description: <what it does + WHEN to use it, so the AI can select it>
---

# <Title>

## Purpose
## Prerequisites
## Steps
## Where things live / Config
## Gotchas
## Re-run when
```

The `name`/`description` frontmatter and the path are the VS Code platform
standard (required for discovery). The section skeleton is the AMITY convention —
see [Authoring Standard](./08-authoring-standard.md).

## Three kinds of skill

| Kind | Where | Reads project config? | Example |
|---|---|---|---|
| `pure-generic` | shared (`amt-go-net`) | no | `install-amt-mcp-servers`, `author-amity-skill`, `refine-memory` |
| `skill-with-profile` | shared procedure + project data | **yes** — from `amity.project.json` | `debug-transaction-server` |
| `pure-project` | project (`<Project>_Migration`) | self-contained (data inline) | `cobol-generator-error-analysis` |

## The Skill + Profile pattern (generic procedure + project data)

Many procedures are identical across projects but need project-specific **values**
(application name, transaction-server name, debug port, DB name, paths). Do **not**
fork the skill per project — that is how instruction drift starts. Split it:

- the **generic skill** (shared layer) holds the **procedure** and reads its values
  from the project **profile**;
- the **profile** is a block in `<Project>_Migration/amity.project.json` (e.g.
  `runtime.applications[]`) holding the **data**.

The skill declares where its data lives via a `profile:` frontmatter pointer and
opens with a *"resolve the target from the profile"* step. Improve the procedure
once → every project benefits; add a new app → change only the profile.

> A generic skill wired to a project's profile is what we call an **AMITY skill**.
> The `author-amity-skill` skill is the full authoring procedure; the frontmatter
> keys are in the [Authoring Standard](./08-authoring-standard.md).

## Skill inventory

**Shared AMT layer** (`amt-go-net/.github/skills/`):

| Skill | Kind | Purpose | Status |
|---|---|---|---|
| `install-amt-mcp-servers` | pure-generic | Build the MCP servers + wire them into a workspace | **created** |
| `author-amity-skill` | pure-generic | Create/place/wire a new AMITY skill (the meta-skill) | **created** |
| `refine-memory` | pure-generic | Curate `continuity.md`; promote findings to skills; archive stale facts | **created** |
| `debug-transaction-server` | skill-with-profile | Debug the transaction server (target from the project profile) | **created** |
| `debug-generator` | skill-with-profile | How to debug the Lion/AMT generator | planned |
| `root-cause-analysis` | pure-generic | How to run an RCA across the migration layers | planned |
| `create-amt-work-item` | pure-generic | How to raise a User Story in `AMT_Products` | planned |

**Project layer** (`<Project>_Migration/.github/skills/`):

| Skill | Kind | Purpose | Status |
|---|---|---|---|
| `cobol-generator-error-analysis` | pure-project | Analyse Lion/AMT generation errors, build repros, raise Federale issues | **created** |
| `issue-to-product-story` | pure-project | Turn a Federale issue into an `AMT_Products` story/bug | **created** |
| `create-federale-issue` | pure-project | Raise an issue in the Federale ADO project | planned |

## Where a skill lives

- Toolchain-general procedure → **shared layer** (`amt-go-net`).
- Project-specific procedure (names a customer app/screen/DB/ADO project) →
  **project layer** (`<Project>_Migration`).
- Same procedure, only the values differ → **`skill-with-profile`** in the shared
  layer + a profile block in the project manifest (never a per-project fork).
