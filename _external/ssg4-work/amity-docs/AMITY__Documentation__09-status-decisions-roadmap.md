# 09 — Status, Decisions & Roadmap

Related: [README](./README.md) · [Overview](./01-overview-and-goals.md)

## Already built (on `feature/federale/114494-aimity`)

**Shared AMT layer — `amt-go-net`:**
- `.vscode/mcp.json` — **empty** (no server definitions); each project owns its
  servers. Servers are published as .NET tools to the `AMT_Mcp` Azure Artifacts
  feed by `pipelines/amt-mcp.yml` and consumed via `dotnet dnx`.
- `.github/skills/install-amt-mcp-servers/SKILL.md` — build + wire the MCP servers.
- `.github/skills/debug-transaction-server/SKILL.md` — `skill-with-profile`: debug the
  transaction server, target resolved from the project profile.
- `.github/skills/author-amity-skill/SKILL.md` — the meta-skill for creating/placing/wiring AMITY skills.
- `.github/skills/refine-memory/SKILL.md` — curate `continuity.md`; promote findings to skills; archive stale facts.
- MCP server code change: `--settings <path>` support in
  `LionRepositoryMCP`, `AmtScriptMCP`, `AmtConfigurationManagerMCP`, `KeyCloakMCP`
  (the servers also still accept an optional `*.local.json` overlay, but the
  project no longer uses it — see change log). `PackAsTool` on all 7 servers.
  Build: 0 errors.

**Project layer — `Federale_Migration`:**
- `Federale.code-workspace` — 4 sibling folders, relative paths.
- `.vscode/mcp.json` — **all** servers, `federale-` prefixed and unpinned (latest
  from feed): `federale-ado`, `federale-iis`, `federale-event-viewer`,
  `federale-net-debug`, `federale-lion-repository`, `federale-amt-config`,
  `federale-amt-script`, `federale-keycloak` (project-bound ones via `--settings`).
- `amt-mcp/*.appsettings.json.sample` (committed templates, `.sample` last) +
  `*.appsettings.json` (gitignored, USER-SPECIFIC — all values incl. secrets).
  No sharable base + no `.local` overlay: nothing in `amt-mcp/` is committed
  except the `.sample` templates.
- `amity.project.json` — project manifest (incl. `mcp.capabilityProfile` + `servers`
  enable-map and a `runtime.applications[]` profile for `skill-with-profile` skills).
- `memory/continuity.md` (seed) + `memory/local/.gitignore` (volatile).
- `.github/instructions/amity-memory.instructions.md` (reads manifest + memory each
  session; warns when `continuity.md` is due for maintenance).
- `.gitignore` — ignore `/amt-mcp/*.json`; un-ignore `/.vscode/mcp.json`.

## Open decisions

| # | Decision | Proposal |
|---|---|---|
| 1 | Adopt `AGENTS.md` as canonical steering + thin `copilot-instructions.md` pointer | **Yes** (tool-agnostic paradigm) |
| 2 | Absorb existing coding standards into `AGENTS.md` + `coding-standards.instructions.md`, retire the big body | **Yes** |
| 3 | Write `AMITY-STANDARD.md` as the single authoring reference | Covered by [08 — Authoring Standard](./08-authoring-standard.md); decide if a separate template file is also wanted |
| 4 | Memory decay/review + git hooks | **Adopted lightweight**: `refine-memory` curation skill + session-start maintenance warning; full decay/CI deferred |
| 5 | CI floor (memory-lint) | GitHub-Actions floor N/A on ADO; rely on local checks or port to an Azure Pipeline later |
| 6 | Skill taxonomy: `pure-generic` / `skill-with-profile` / `pure-project`; generic skills read project data from the manifest | **Adopted** |
| 7 | MCP `capabilityProfile` (`dotnet`/`java`) selects which shared servers apply (Java drops `net-debug`, keeps converter/generator) | **Adopted** |
| 8 | Memory store: file (`continuity.md`) vs database-via-MCP | **File only** — kept simple (the Macy's model); no database and no formal decay engine. Curation is the `refine-memory` skill + a session-start maintenance warning |

## To verify empirically

- Multi-root workspace picks up each member folder's `.vscode/mcp.json`.
- `${workspaceFolder:amt-go-net}` resolves from within `amt-go-net`'s own
  `.vscode/mcp.json`. Fallback: inline servers in the `.code-workspace`.
- Project-bound servers connect with `--settings` pointing at the user's
  `<name>.appsettings.json` when the workspace is opened (build/exe paths already
  verified; `--settings` honored).

## Roadmap (maps to WI 114494 acceptance criteria)

1. Lock decisions 1–3 above.
2. Write clean `AGENTS.md` for both layers; convert `copilot-instructions.md` to
   thin pointers; distill coding standards into an instruction file.
3. Author the planned shared skills: `debug-generator`,
   `debug-transaction-server`, `root-cause-analysis`, `create-amt-work-item`.
4. Author project skills: `create-federale-issue` (+ smoke-test/pipeline skills).
5. Re-fit already-created Federale artifacts to the
   [Authoring Standard](./08-authoring-standard.md).
6. Validate end-to-end: a new engineer, using only AMITY, installs the tooling and
   follows one debug + one RCA workflow.

## Change log

- 2026-09-15 — Initial design docs; MCP two-layer config + `--settings` overlay
  pattern built and verified.
- 2026-09-16 — MCP config collapsed to a **single user-specific file per server**
  (`<name>.appsettings.json`, gitignored) with only `<name>.appsettings.json.sample`
  committed; dropped the base + `.local` overlay (no sharable config). `.gitignore`
  now ignores `/amt-mcp/*.json`.
- 2026-09-17 — Skill taxonomy (`pure-generic` / `skill-with-profile` / `pure-project`)
  + the Skill + Profile pattern; created `debug-transaction-server`,
  `author-amity-skill`, `refine-memory`; manifest gains `mcp.capabilityProfile` +
  `servers` enable-map + `runtime.applications[]`; memory maintenance-warning
  convention added to `amity-memory.instructions.md`; memory kept **file-only**
  (Macy's model, no database) with `refine-memory` curation + operating procedures
  (update / refine-to-skill / clean-up) documented (decision 8); added docs
  **11 (Instructions)** and **12 (What Goes Where \u2014 master placement reference)**.- 2026-09-17 — Added doc **13 (Mechanisms & the Artifact Catalog)**: prompts/slash-
  commands, agents/chat modes, toolsets, enabling settings; and the catalog of
  skills/instructions/agents to build (incl. `debug-batch` + proposed Debug
  Online/Batch agents). Agents adopted as **optional, never required**.
- 2026-09-17 — Built flagship **Use Case A (online transaction debug)**: created the
  **AMT Debug (Online)** agent + the `amt-tooling` generic instruction; filled the
  Federale runtime profile (`WorkingAfbusTransactionServer`, via amt-config MCP);
  seeded FA_AFBUS domain facts in `continuity.md`; added doc **14 (Use Cases)**.
