---
mode: ask
description: "Review completed SSG→PowerShell trial work (an area or a program) against the standard process"
argument-hint: "<area or program> (e.g. 'Area A', 'ARCHISEPARE')"
---

# /ssg-review — review ${input:target}

Review the work for **${input:target}** without doing new implementation. Compare:

1. **Actions actually taken** — files changed, commands run, results captured.
2. **Standard process** — did it follow the Area's `*.instructions.md` (parse-check first for Area A;
   failing-case-before-fix for Area B; warning-taxonomy review for Area C)?
3. **Evidence** — parse-error counts, harness output, diffs vs Trial3 goldens, byte-identical re-run.
4. **Deviations** — anything skipped or done differently, and whether it matters.
5. **Open risks** — including any of the standing ToDo items (MT-001..) or open issues (T3-nnn) touched.
6. **Corrections required before proceeding.**

## Rules
- Do not introduce new implementation ideas unless needed to correct a deviation.
- Do not re-open already-verified steps unless evidence contradicts them.
- Flag any breach of the core guardrails (edits to `SSG-Source/`, reliance on stale `C:\Amt` paths,
  pipeline run past `-ListOnly`, a KI-1..3 "fix" without a failing test, or any touch of the live
  AMT177/FEDERALE_APP app).
- If nothing needs changing, say: **"Review accepted — proceed."**
