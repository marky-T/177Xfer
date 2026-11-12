# 06 — Memory

Related: [Skills](./05-skills.md) · [Project Manifest](./07-project-manifest-and-configuration.md)

Memory is the project's **evolving brain** — decisions, root causes, gotchas that
change over time. It is deliberately split by **volatility**.

## Two kinds of memory

| Kind | Location | Committed? | How it updates |
|---|---|---|---|
| **Shared / durable** | `<Project>_Migration/memory/continuity.md` | **Yes** (via PR) | AI drafts a fact → human reviews the diff → commit |
| **Volatile / personal** | `<Project>_Migration/memory/local/` | **No** (gitignored) | AI reads at session start, rewrites freely; never committed |

Reads are automatic; **writes to shared memory are deliberate** — a human gate on
every committed fact is what keeps it reliable and non-volatile.

## The promotion rule

Churny, in-progress, or personal notes (e.g. smoke-test state) stay in
`memory/local/`. When a note becomes a **durable truth**, it is **promoted** as a
single reviewed line into `memory/continuity.md`, then committed. Volatile stays
local; durable graduates to shared.

## Files

```
<Project>_Migration/
  memory/
    continuity.md        # committed live project brain (invariants, decisions, findings, open threads)
    local/               # gitignored volatile scratch
      .gitignore         # ignores its own contents (*), keeps the folder
```

An instruction file (`.github/instructions/amity-memory.instructions.md`,
`applyTo: '**'`) tells the AI to read the manifest + `continuity.md` each session,
keep volatile notes in `memory/local/`, promote durable facts deliberately, and
never commit secrets or push without asking.

## What not to store

- Secrets, tokens, credentials, PII (memory is committed and team-visible).
- Raw chat transcripts — only distilled findings.
- Application source / build logic — that lives in the code repos.

## Shared AMITY memory vs built-in AI memory

Copilot's built-in memory (user/session/repo tiers) is **private to one person,
one machine, one tool** — it never crosses to a teammate and is vendor-specific.
That is the opposite of the goal (seniors' knowledge reaching juniors). AMITY's
`continuity.md` is the **shared** counterpart: committed, reviewed, tool-agnostic,
and cloned with the repo so a new engineer inherits the whole brain on day one.
Use built-in memory for personal preferences and volatile scratch (that is what
`memory/local/` mirrors); use `continuity.md` for the team brain.

## We use a file (kept simple)

`continuity.md` is a plain committed file — **no database**. An always-on
instruction points the AI at it, so it is read every session as a trivial file
read, and git gives review, history, and zero infra. This is the Macy's model and
it is deliberately kept simple: we are **not** adding a database or a formal decay
engine. If the file ever stops fitting in a session, the answer is curation
(below), not new infrastructure.

## Operating procedures (update / refine / clean up)

Three plain-English procedures keep the file useful. Reading is automatic; every
write is a reviewed diff (draft → you approve → commit) and nothing is pushed
without asking.

### 1. Update it (capture a finding)

- **When:** at the end of any session that produced something **durable** — a root
  cause, a decision, a gotcha, an approach you ruled out — or when you close a
  ticket. Churny / personal / in-progress notes go to `memory/local/` instead.
- **How:** say *"update AMITY with these findings"* (or *"close ticket X"*). The AI
  drafts **one line** under the right section (Architectural Invariants / Key
  Decisions / Defect Findings / Open Threads) with a metadata footer; you review
  and commit, alongside the related change if there is one.
- **Rule:** durable + team-relevant only; one fact, one line; no secrets/PII.

### 2. Refine it into a skill

- **When:** a fact describes a **repeatable procedure**, or the **same finding has
  recurred** (~2–3 times). That is the signal it should become reusable know-how,
  not just a memory line.
- **How:** say *"turn this into a skill"* / *"refine memory"* → the `refine-memory`
  (or `author-amity-skill`) skill creates/updates a skill — generic → `amt-go-net`,
  project-specific → the project repo — and replaces the fact with a one-line
  pointer. Prefer updating an existing skill over making a new one.

### 3. Clean it up (archive)

- **When:** the maintenance warning fires (more than ~30 facts, longer than ~400
  lines), or an issue is **solved**, an Open Thread is **done** (`- [x]`), or facts
  **duplicate**. Also a natural step when closing a ticket.
- **How:** say *"refine memory"* / *"clean up continuity.md"* → the `refine-memory`
  skill shows a plan, then **archives** faded facts to `memory/archive/` (never
  deletes), sweeps completed threads, and dedupes.
- **Cadence:** no fixed schedule — react to the warning, or do it when you close a
  ticket. Keep it simple.

The AI surfaces the maintenance warning automatically at session start (per
`amity-memory.instructions.md`); you decide when to act on it.

## Notes

- `continuity.md` stays short enough to load every session; keep it lean —
  curation (above) is what enforces that.
- Heavy detail lives in `memory/tickets/<id>.md` (linked from a one-line fact) and
  faded facts in `memory/archive/`; both are created on first use by `refine-memory`.
