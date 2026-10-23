---
mode: agent
description: "Start an SSG→PowerShell trial session — orient to current status, pick a work area, confirm before acting"
argument-hint: "Any notes on where you left off (optional)"
---

# /ssg-session-start

Begin an SSG→PowerShell trial session. Do this before any work:

1. Load the always-on [copilot-instructions.md](../copilot-instructions.md) and confirm you have the
   **Current status** and **Core rules** sections.

2. State the current position:
   - Goal: convert SSG source → PowerShell, run it in the Tier-1 mock harness, fix what blocks it —
     keeping the trial separate from the live AMT177/FEDERALE_APP app.
   - Where things stand (from **Current status** + the newest file in
     [.github/Copilot_Plans/](../Copilot_Plans/)).
   - What was last completed.

3. Identify which **work area** the user's intent falls under:
   - **A** — run trials on converted PS → `/ssg-run-trial`
   - **B** — change the SsgConverter C# → `/ssg-fix-converter`
   - **C** — reconvert SSG-COBOL → PS → `/ssg-reconvert`
   - **D** — run under the real AMT runtime (Stage A/B, Control Center) → `/ssg-e2e`; building the
     COBOL/OS2200 application (MT-009) → `/ssg-build-afbus-cobol`

4. Ask: *"Continue from <current status> via Area <A/B/C/D>, or has something changed?"* — then stop
   and wait. Do not start work until the user confirms.

Once work is done and reviewed, sync the progress tracker via
[`/ssg-update-tracker`](ssg-update-tracker.prompt.md) rather than hand-editing it.

## Guardrails
- `SSG-Source/` read-only. Treat `C:\Amt\...` / `C:\Dev\...` paths as stale.
- Do not wire into or modify the live AMT177/FEDERALE_APP app, `FA_AFBUS` DB, or `ava` account.
- Do not run Trial3's pipeline past `-ListOnly` (ToDo MT-002).
