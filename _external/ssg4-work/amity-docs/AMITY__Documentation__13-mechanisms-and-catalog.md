# 13 — Mechanisms & the Artifact Catalog

Related: [Skills](./05-skills.md) · [Instructions](./11-instructions.md) · [What Goes Where](./12-what-goes-where.md) · [Status & Roadmap](./09-status-decisions-roadmap.md)

This doc has two jobs: (1) list **every VS Code customization mechanism** AMITY can
use and how each *surfaces*, and (2) define the **catalog of skills / instructions
/ agents** AMITY should actually build for AMT migration work.

## Part 1 — The mechanisms and how they surface

| Mechanism | File | Surfaces as | Loads | Use for |
|---|---|---|---|---|
| **Instruction** | `.github/instructions/*.instructions.md` | injected by `applyTo` | **automatic** | always-on rules/gotchas ([11](./11-instructions.md)) |
| **Skill** | `.github/skills/<name>/SKILL.md` | model picks by `description` | **on demand** | a procedure/how-to ([05](./05-skills.md)) |
| **Prompt / slash command** | `.github/prompts/*.prompt.md` | **`/name`** in chat | **user-triggered** | a canned, repeatable request |
| **Agent / chat mode** | `.github/agents/*.agent.md` | mode picker / `@name` | **user-selected** | a focused workflow persona |
| **Toolset** | `*.toolsets.jsonc` | referenced by agents | with the agent | grouping tools an agent may use |
| **Enabling settings** | `.vscode/settings.json` (`chat.promptFiles`, `chat.instructionFilesLocations`, `chat.modeFilesLocations`) | — | config | turning on / relocating the above |

The distinction that matters: **instruction = always-on rule**, **skill = model
auto-selects a procedure**, **prompt = *you* trigger a canned task with `/`**,
**agent = *you* switch into a focused mode**.

## Part 2 — Prompts & slash commands

A prompt file `foo.prompt.md` becomes **`/foo`** in chat — a saved, user-invoked
request. Use one when the *same ask* recurs and you want a shortcut rather than a
procedure the model auto-selects. Examples worth having later: `/new-federale-issue`,
`/rca <id>`, `/standup`. Both repos already have an (empty) `.github/prompts/`.

## Part 3 — Agents / chat modes

An agent is **not new capability** — it's a focused chat mode that bundles a
**persona/instruction + a curated tool set (+ optional pinned model)** so a
specific task is streamlined. It composes existing skills and MCP tools; it does
not replace them.

- **When to use an agent (vs a skill):** the task is a *mode of working* the user
  deliberately enters — a debugging session, an RCA pass, a review — benefiting
  from a constrained tool set and a steady persona. A one-off procedure stays a
  **skill**; an agent is the *front door* that pulls in the right skills/tools.
- **Home:** generic → `amt-go-net/.github/agents/`, project → `<Project>_Migration/.github/agents/`.
- **Optional by design:** agents are never required — plain chat + skills still work.
- **Precedent:** Macy's AMITY uses agents heavily (a Troubleshoot orchestrator with
  9 subagents + a Logger, plus Commit / PR-Review / Implement-Story agents).

## Part 4 — Toolsets & enabling settings (environment)

- **Toolsets** (`*.toolsets.jsonc`) name a group of tools an agent is allowed to
  use — handy to keep an agent focused (e.g. a Debug agent limited to
  `net-debug` + `amt-config` + `amt-script`).
- **Enabling settings** live in `.vscode/settings.json` and switch these features
  on or point them at custom folders (`chat.promptFiles`,
  `chat.instructionFilesLocations`, `chat.modeFilesLocations`). Treat them as
  committed project config (non-secret) — see [12 — What Goes Where](./12-what-goes-where.md).

## Part 5 — The AMITY artifact catalog (what we need)

What to build, by task area. **Type**: instruction / skill / agent / prompt.
**Layer**: generic (`amt-go-net`) or project (`<Project>_Migration`).

### Runtime debugging
| Artifact | Type | Layer | Status |
|---|---|---|---|
| `debug-transaction-server` (online) | skill-with-profile | generic | **created** |
| `debug-batch` (batch controller / job / ECL) | skill-with-profile | generic | **needed** |
| **AMT Debug (Online)** | agent | generic | proposed |
| **AMT Debug (Batch)** | agent | generic | proposed |

### Conversion & generation
| Artifact | Type | Layer | Status |
|---|---|---|---|
| `run-converter` | skill-with-profile | generic | planned |
| `run-generator` | skill-with-profile | generic | planned |
| `debug-generator` | skill-with-profile | generic | planned |
| `cobol-generator-error-analysis` | skill | project | **created** |
| generation known-issues | instruction/doc | generic | planned |

### Configuration & environment
| Artifact | Type | Layer | Status |
|---|---|---|---|
| `install-amt-mcp-servers` | skill | generic | **created** |
| `configure-amt-runtime` (transaction/program controls, roles) | skill | generic | planned |
| `clean-sessions-and-stations` | skill | generic | planned |

### Work items & RCA
| Artifact | Type | Layer | Status |
|---|---|---|---|
| `root-cause-analysis` | skill (later maybe an agent) | generic | planned |
| `issue-to-product-story` | skill | project | **created** |
| `create-federale-issue` | skill | project | planned |

### Meta / memory
| Artifact | Type | Layer | Status |
|---|---|---|---|
| `author-amity-skill` | skill | generic | **created** |
| `refine-memory` | skill | generic | **created** |

### Instructions (always-on)
| Artifact | Layer | Status |
|---|---|---|
| `lion-repository-mcp` | generic | **created** |
| `amity-memory` | project | **created** |
| `amt-tooling` (MCP/tooling gotchas) | generic | planned |
| `coding-standards` (Asysco standards) | generic | planned |
| `ado-defaults` | project | planned |

## Part 6 — Selection guide (which mechanism?)

| I want… | Use a… |
|---|---|
| a rule that always applies | **instruction** |
| a procedure the AI follows for a task | **skill** |
| a shortcut I type (`/…`) for a recurring ask | **prompt** |
| a focused mode that bundles skills + a tool set for a task area | **agent** |
| to limit which tools an agent may use | **toolset** |
