---
mode: agent
description: Transfer and condense a Copilot session between workspaces via a portable handoff doc.
---

# Session handoff — condense & resume

A reusable, workspace-agnostic protocol for carrying context from one Copilot
session into the next. Two directions: **CONDENSE** (end of a session) and
**RESUME** (start of the next). Invoke with `/session-handoff` and say which one.

---

## RESUME — start of a new session

Do this **before anything else**:

1. Look for a handoff doc in this repo (in priority order):
   - `.github/Copilot_Plans/SESSION-HANDOFF-*.md`
   - `.github/SESSION-HANDOFF.md`
   - any `*SESSION-HANDOFF*.md` at the repo root or under `.github/`.
2. Read it fully. Treat its "verified facts" as established — **do not re-investigate**
   things it already settled.
3. If it lists a prior-session index (session IDs / topics), query the session store
   for deep dives instead of re-deriving from files.
4. Briefly confirm to the user what you absorbed and what the open threads are.

## CONDENSE — end of a session (produce/update the handoff doc)

Write or update a single markdown file at
`.github/Copilot_Plans/SESSION-HANDOFF-<TAG>.md` (`<TAG>` = short lane/project id).
Optimise for the **next agent**, not a human reader. Rules:

- **Terse and factual.** Tables and bullets over prose. Every claim should be
  something a fresh session can act on without re-checking.
- **Only durable knowledge.** Skip play-by-play. Capture decisions, verified
  environment facts, working commands, and dead ends — not the narrative.
- **Link, don't paste.** Reference files by path/line rather than quoting them.
- **Mark confidence.** Tag facts as VERIFIED / ASSUMED / UNPROVEN.
- **Idempotent.** If the doc exists, merge and prune stale entries instead of
  appending duplicates.

Use this skeleton:

```markdown
# Session handoff — <TAG> (read me first)

**For the next Copilot session in this workspace.** Workspace root is `<path>`.

## 1. Environment facts (verified)
| Thing | Value |
|---|---|
| ... | ... |

## 2. Config already in place — don't redo
- scope/instructions, ignore files, workspace settings...

## 3. Core knowledge / execution model
- the hard-won mechanics a new session would otherwise waste time rediscovering.

## 4. Key artifacts produced this session
- path — what it is / why it matters.

## 5. Reference docs (searchable)
- authoritative sources + one-line pointers.

## 6. Prior-session index (query the session store, don't re-derive)
- `<sessionId-prefix>` — topic.

## 7. Open threads / next steps
- what's unfinished, with the smallest next action for each.
```

## Optional — transplant the literal chat transcript (unofficial, finicky)

Only if the user explicitly wants the raw message history, not just the condensed doc:

1. Session store lives at
   `%APPDATA%\Code\User\workspaceStorage\<hash>\chatSessions\<sessionId>.jsonl`.
2. Steps: open the target workspace once (so it gets a `workspaceStorage` hash) →
   find the new hash → **close VS Code completely** → copy the `.jsonl` into the new
   hash's `chatSessions\` folder → reopen.
3. Caveat: unsupported and can break across VS Code versions. The condensed handoff
   doc is the reliable path; offer the transcript only as a fallback.
