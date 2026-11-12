# AMITY Documentation

**AMITY** (AMT Integration & Toolchain Yard) is a version-controlled AI knowledge
layer for AMT migration projects. It captures the know-how of experienced
engineers — how to debug, how to run a root-cause analysis, how to install and
use the tooling and MCP servers, how to raise the right work item — so that AI
assistants (and new engineers) get the same guidance every time, on any project.

This folder is the **design reference** for what we are building. It is split into
small, focused documents so they stay clean as they grow.

> Status: **design phase**, being built on branch `feature/federale/114494-aimity`
> (Azure DevOps work item **114494**, project `AMT_Products`). First target
> project: **Federale**.

## Documents

| # | Document | Covers |
|---|---|---|
| 01 | [Overview & Goals](./01-overview-and-goals.md) | What AMITY is, the problem, goals, scope |
| 02 | [Architecture — Two Layers](./02-architecture-two-layers.md) | Shared AMT layer vs project layer, how they compose |
| 03 | [Repositories & Workspace](./03-repositories-and-workspace.md) | The repos, sibling convention, `.code-workspace`, paths |
| 04 | [MCP Servers](./04-mcp-servers.md) | Generic vs project-bound, `--settings`, single user-specific config, naming |
| 05 | [Skills](./05-skills.md) | Skill format/standard, planned skills, where they live |
| 06 | [Memory](./06-memory.md) | Committed vs volatile memory, read/promote rules |
| 07 | [Project Manifest & Configuration](./07-project-manifest-and-configuration.md) | `amity.project.json`, adding a new project |
| 08 | [Authoring Standard & Conventions](./08-authoring-standard.md) | The uniform "what is right" reference |
| 09 | [Status, Decisions & Roadmap](./09-status-decisions-roadmap.md) | What exists, open decisions, next steps |
| 10 | [MCP Distribution: Feed, `dnx` & Auth](./10-mcp-distribution-feed-and-auth.md) | Publishing servers as .NET tools, consuming via `dotnet dnx`, feed auth, versioning |
| 11 | [Instructions](./11-instructions.md) | The always-on steering layer: `applyTo` scoping, instruction vs skill vs memory, placement |
| 12 | [What Goes Where](./12-what-goes-where.md) | **Master placement reference** — every artifact + environment element, where it lives, whether it's committed |
| 13 | [Mechanisms & the Artifact Catalog](./13-mechanisms-and-catalog.md) | Prompts/slash-commands, agents/chat modes, toolsets, enabling settings; and the catalog of skills/instructions/agents AMITY needs |
| 14 | [Use Cases (end-to-end)](./14-use-cases.md) | Worked scenarios where agent + skill + instruction + profile + MCP + memory cooperate |

## Guiding principle

Existing files in the repos (per-repo `copilot-instructions.md`, ad-hoc skills,
scattered notes) are **context/inputs**, not the reference of what is correct.
The [Authoring Standard](./08-authoring-standard.md) is the authority; new
artifacts conform to it, and legacy files are distilled into it or retired.
