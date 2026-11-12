# 01 — Overview & Goals

Related: [README](./README.md) · [Architecture](./02-architecture-two-layers.md)

## In plain language

Much of what makes an AMT migration go smoothly lives only in the heads of a few
experienced engineers, or in personal notes: how to debug the generator or the
transaction server, how to do a proper root-cause analysis, how to install and
use our tools and MCP servers, how to raise the right work item. **AMITY turns
that tacit knowledge into a shared, version-controlled "AI brain"** that GitHub
Copilot (and other assistants) load automatically — so a new engineer gets the
same guidance an experienced one would give, without having to ask.

## The problem

- Knowledge is tacit and scattered; onboarding is slow and inconsistent.
- AI instructions were duplicated per repository and drifted apart.
- Reusing setup across projects meant copy-and-strip, which rots quickly.
- Generic AI advice ignores AMT architecture, tooling, and constraints.

## Goals

1. **Capture experienced-engineer skills** as reusable, AI-consumable procedures
   (debugging, RCA, installation, tooling usage, work-item conventions).
2. **Reuse across projects**: one shared AMT knowledge base, plus a thin,
   swappable per-project layer (Federale now, e.g. CSM next).
3. **Uniform and clean**: one authoring standard, one canonical place per fact.
4. **Low-friction**: setup is a documented one-time step per machine; day-to-day,
   the AI reads the shared context automatically.

## Scope

**In scope**
- The two-layer knowledge structure (shared AMT + per-project).
- Skills, instructions, memory, project manifest, MCP server configuration.
- A VS Code workspace per project that wires the repos together.

**Out of scope (for now)**
- Rewriting or migrating application source in the sibling repos.
- Porting the full multi-agent troubleshoot orchestrator (tracked separately if needed).

## Tracking

Azure DevOps work item **114494** (`AMT_Products`) — *"AMITY: reusable two-layer
AI knowledge & skills platform"*. Acceptance criteria there map to the
[roadmap](./09-status-decisions-roadmap.md).
