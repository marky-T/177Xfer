# 11 — Instructions

Related: [Skills](./05-skills.md) · [Memory](./06-memory.md) · [What Goes Where](./12-what-goes-where.md) · [Authoring Standard](./08-authoring-standard.md)

Instructions are AMITY's **always-on steering layer** — the *only* artifact type
VS Code injects into the model **automatically**. Skills are chosen on demand;
memory is read because an instruction says to; **instructions just apply.**

## The mechanism

An instruction is a file at `.github/instructions/<area>.instructions.md` with
YAML frontmatter carrying an `applyTo` glob:

```yaml
---
applyTo: '**'
---
# … the rule text …
```

VS Code aggregates every workspace folder's `.github/instructions/*.instructions.md`
and **injects the body into the model's context whenever an in-scope file matches
`applyTo`** (`**` = every request). This is the same mechanism that makes
`memory/continuity.md` get read — the `amity-memory` instruction points the AI at
it. So instructions are the hook the rest of AMITY hangs off.

## Instruction vs Skill vs Memory (pick by *how it should load*)

| Type | Loaded… | Holds | Chosen by |
|---|---|---|---|
| **Instruction** | **automatically** (always if `applyTo:'**'`, else when a path matches) | always-on **rules / constraints / gotchas** | file-path glob |
| **Skill** | **on demand** | a **procedure / how-to** | its `description` matching intent |
| **Memory** | read as a file (an instruction points at it) | **evolving findings / decisions** | session start |

- Always-apply, no one has to ask → **instruction**.
- "When the task is X, do these steps" → **skill**.
- A finding that changes over time → **memory**.

## What belongs in an instruction

- Hard rules & constraints: *"never `git push` without an explicit request"*,
  *"fix upstream, regenerate downstream"*.
- Tool-usage rules & gotchas: *"never call the lion-repository MCP in parallel"*,
  *"after writing fresh files, run saveAll before build (0-byte-on-disk trap)"*.
- Coding standards (the `m_` prefix, CLR types, brace style).
- Workflow steering: *"read `amity.project.json` + `continuity.md` at session start"*.

**Not** an instruction: a multi-step procedure (that's a **skill**), an evolving
finding (that's **memory**), or long reference material (that's a **doc**).

## `applyTo` scoping — the discipline that matters

Every `applyTo:'**'` instruction is injected on **every** request, spending
context budget continuously. So:

| Use | For |
|---|---|
| `applyTo:'**'` | truly universal rules only (memory rules, coding standards) — keep them **short and few** |
| `applyTo:'**/*.cbl'` | rules that apply only to certain files (COBOL fixed-format) |
| `applyTo:'CobolMigration/**'` | rules for one area of one project |

Path-scope whenever a rule is only relevant to certain files — it keeps the
always-on set lean.

## Two-layer placement (same rule as skills)

- **Generic** rule (any AMT project) → `amt-go-net/.github/instructions/`.
- **Project** rule (names a customer app/DB/ADO project) →
  `<Project>_Migration/.github/instructions/`.

VS Code merges both, so a project workspace gets the union.

## Current + planned instructions

| Instruction | Layer | Purpose | Status |
|---|---|---|---|
| `lion-repository-mcp.instructions.md` | generic (`amt-go-net`) | how to use the lion-repository MCP; no-parallel rule | **created** |
| `amity-memory.instructions.md` | project (`Federale_Migration`) | read/write/curate memory; maintenance warning | **created** |
| `amt-tooling.instructions.md` | generic | MCP/tooling gotchas (stale-server `create_object`, 0-byte-file saveAll) | planned |
| `coding-standards.instructions.md` | generic | the Asysco standards distilled from `copilot-instructions.md` | planned |
| `ado-defaults.instructions.md` | project | ADO org/project defaults for work-item actions | planned |

## `copilot-instructions.md` vs `instructions/*.md` vs `AGENTS.md`

- **`.github/copilot-instructions.md`** — one per repo, auto-loaded every request:
  repo-wide orientation. Per the [Authoring Standard](./08-authoring-standard.md)
  it becomes a **thin pointer** to `AGENTS.md`.
- **`AGENTS.md`** — the canonical, tool-agnostic hard-rules file (≤200 lines).
- **`.github/instructions/*.instructions.md`** — **scoped** rules selected by
  `applyTo`; the right home for area- or concern-specific steering.

## Authoring checklist

- [ ] Name `<area>.instructions.md`; one concern per file.
- [ ] Set `applyTo` as narrow as correctness allows (avoid gratuitous `**`).
- [ ] Keep it short — it may load on every request.
- [ ] Placement: generic → `amt-go-net`, project → `<Project>_Migration`.
- [ ] It's a **rule**, not a procedure (skill) or a finding (memory).
- [ ] No secrets/PII (committed + team-visible).
