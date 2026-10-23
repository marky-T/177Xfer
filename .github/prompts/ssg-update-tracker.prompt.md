---
mode: agent
description: "Update the SSG→PowerShell progress tracker HTML after a trial run or a proven change, from a combined checklist of what the work produced (run details, issues, process changes, ToDo, status/stats)."
argument-hint: "<Program or change> (e.g. CFH-COPY, 'Stage B route')"
---

# /ssg-update-tracker — sync the progress tracker

Update [docs/SSG-PowerShell-Trial-Progress.html](../../docs/SSG-PowerShell-Trial-Progress.html) to
reflect the work just done for **${input:target}**. This is the explicit mechanism that §8 of that page
refers to. Do it in a **single pass**, following the register conventions in
[ssg-todo-issues.instructions.md](../instructions/ssg-todo-issues.instructions.md).

## Checklist — apply each item that the just-completed work implies

Confirm the selection with the user first (pre-tick what the work implies); then apply only what changed:

1. **Trial-run details** — *important, once a run has completed.* Update the program's row in **§3**:
   parse errors before→after, run badge, emitted line count, unmocked `GetSgsValue` lookups,
   `Call-ExternalProgram` calls, and notes.
2. **Program status + stats** — *once a run has completed.* Set the **§3** badge
   (<code>runs</code> / <code>parses</code> / <code>pending</code>) and the run-detail figures; refresh
   the **§1** current-state box and the page's **Last updated** date.
3. **Record an issue** — *important.* Append a `T3-nnn` row to **§6** and cross-link it from **§3**.
4. **Process change** — *once a new/changed process is proven.* Update the **§5** routine and/or the
   **§5b/§5c** runbooks; if the change is to *how work is done*, also update the matching
   `*.instructions.md` / prompt so the docs and the regime stay in step.
5. **ToDo** — *lower priority.* Append or close an `MT-nnn` row in **§7** (with a `yymmdd` date), and
   link any related plan file in `.github/Copilot_Plans/`.

If an item does not apply, skip it and say so explicitly.

## Consistency check — do this every time, before reporting done

The program count (`N of 20`) is repeated in **at least 4 places** and has drifted before (an edit to
one spot without the others): the §1 success-box **opening sentence**, the §1 **milestone table** row,
the §3 **heading** (`Program Status — N Example Programs`), and the §3 **reconvert caption**
(`N succeeded / 0 failed`). After any edit that changes the count:

1. `grep`/`Select-String` the whole file for the pattern `\d+ of 20|Example Programs|succeeded / 0 failed`
   and confirm **every match uses the same N** — not just the spot you just edited.
2. If any mismatch is found, fix it in the same pass (don't leave it for a future session).
3. Only then report the update as done.

This is a known recurring drift, not a one-off — always re-check, even for a "small" count-only edit.

## Rules
- Ask the user to confirm the checklist selection before writing — unless they say "apply all".
- **Source of truth for the numbers:** the `Reconvert-And-Verify.ps1` summary and the Tier-1 harness
  output under `SsgConverter/Trials/<Program>/out/`. Never invent results — record only what was
  actually produced and reviewed.
- Use the page's existing chrome (`section-card`, `table.ref`, badges, success/info/warn boxes).
- After editing, reload the page and confirm the changed sections render.
- Do not restyle or restructure unrelated sections.
