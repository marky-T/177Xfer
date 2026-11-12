# 08 — Authoring Standard & Conventions

Related: [README](./README.md) · [Skills](./05-skills.md) · [Memory](./06-memory.md)

This document is the **authority** for how AMITY artifacts are written. New
artifacts conform to it. Existing files are **inputs/context**, not references of
what is correct; where they disagree, the standard wins and they get distilled
into it or retired.

## The rule

> Do not extend or mirror legacy files just because they exist. Build clean,
> uniform artifacts to this standard. Legacy files (per-repo
> `copilot-instructions.md`, ad-hoc skills, scattered notes) are context only.

## Canonical artifact set

| Artifact | Format / location | One per |
|---|---|---|
| **Steering** | `AGENTS.md` (canonical, vendor-neutral, ≤200 lines) + thin `.github/copilot-instructions.md` pointer | layer |
| **Skills** | `.github/skills/<kebab>/SKILL.md` (frontmatter + fixed skeleton) | procedure |
| **Instructions** | `.github/instructions/<area>.instructions.md` (`applyTo`) — see [11 — Instructions](./11-instructions.md) | concern |
| **Agents** | `.github/agents/<name>.agent.md` | orchestrated workflow |
| **Prompts** | `.github/prompts/<name>.prompt.md` | reusable ask |
| **Memory** | `memory/continuity.md` + `memory/local/` | project |
| **Manifest** | `amity.project.json` (fixed schema) | project |
| **MCP config** | `.vscode/mcp.json` | layer |

> For the full **what-goes-where / committed-or-not** matrix across artifacts
> **and** environment elements (MCP servers, settings, repos, logins, secrets),
> see [12 — What Goes Where](./12-what-goes-where.md).

## Steering: AGENTS.md is canonical

- `AGENTS.md` holds the hard rules and is tool-agnostic.
- `copilot-instructions.md` becomes a **thin pointer** to `AGENTS.md` (no
  duplicated rules), so Copilot reads the canonical content.
- Existing large `copilot-instructions.md` bodies (e.g. the coding standards) are
  **distilled** into `AGENTS.md` + a `coding-standards.instructions.md`, then the
  original is reduced to a pointer.

## Naming conventions

| Thing | Convention | Example |
|---|---|---|
| Skill folder | `kebab-case` | `install-amt-mcp-servers` |
| Instruction file | `<area>.instructions.md` | `coding-standards.instructions.md` |
| Project-bound MCP server | `<project>-<server>` | `federale-lion-repository` |
| User-specific config | `*.appsettings.json` (gitignored) | `lion-repository.appsettings.json` |
| Committed sample | `*.<ext>.sample` (`.sample` last) | `lion-repository.appsettings.json.sample` |

## Skill frontmatter & kinds

Beyond the platform-required `name` + `description`, AMITY skills carry a few
convention keys so their layer, kind, and wiring are explicit:

```yaml
---
name: <kebab-name>
layer: generic | project
kind: pure-generic | skill-with-profile | pure-project
requires: [<mcp-capability>, ...]                 # optional; MCP capabilities needed
profile: amity.project.json#/<json/pointer>       # skill-with-profile only
description: >-
  What it does + USE WHEN ... + DO NOT USE FOR ...
---
```

- **`kind`** — prefer `skill-with-profile` over a `pure-project` fork whenever the
  procedure is generic and only the values differ (see [Skills](./05-skills.md)).
- **`requires`** — lets a skill degrade gracefully against the project's
  `mcp.capabilityProfile` (e.g. `net-debug` is disabled for a `java` project).
- **`profile`** — a JSON pointer into `amity.project.json` telling the skill where
  its project data lives.

## Content principles

- **One fact, one place.** Steering ≠ memory ≠ skill. Do not repeat a rule across
  types.
- **Skills = stable procedure; memory = evolving finding; instructions = always-on
  rule.**
- **Small, focused files.** Split large documents (like this set) rather than
  growing one file.
- **No secrets in committed files.** Ever.
- **Plain-language intro first** on anything a non-expert might read.

## Legacy files: disposition

| File | Disposition |
|---|---|
| `amt-go-net/.github/copilot-instructions.md` | distill coding standards into `AGENTS.md` + `coding-standards.instructions.md`; reduce to a pointer |
| `<Project>_Migration/.github/copilot-instructions.md` | same treatment |
| `board-insights` skill | keep functional; reformat to the SKILL skeleton when next touched |
| Artifacts already created for Federale | re-fit to this standard as it lands |
