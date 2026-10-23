---
description: "Use when logging a bug/issue or raising a new pipeline function / feature request in the SSG→PowerShell trial. Defines the T3-nnn issue register and the MT-nnn ToDo list, their conventions, and where they are displayed."
---

# SSG → PowerShell Trial — Issues & ToDo registers

Two running registers track defects and forward work. Both are **displayed** at the base of
[docs/SSG-PowerShell-Trial-Progress.html](../../docs/SSG-PowerShell-Trial-Progress.html)
(§6 Issues, §7 ToDo) and cross-referenced from the program-status table (§3).

## Issues (bugs) — `T3-nnn`

- **ID:** `T3-nnn` (`T3` = Trial3), zero-padded 3 digits, incrementing (`T3-001`, `T3-002`, …).
- **Fields:** ID · Created (`yymmdd`) · Area (A/B/C) · Issue (symptom + cause + fix) · Status (open / fixed).
- Add a row when a bug is found while converting or running a program. **Keep fixed issues** for the record.
- Cross-link the ID from the program's row in §3 so the blocker is traceable both ways.
- Area tag: converter defect = **B**, mock/harness gap = **A**, reconvert/config gap = **C**.

## ToDo — `MT-nnn`

- **ID:** `<initials>-nnn` — the letter prefix is the **creator's initials** (so any developer can add
  items and be identified as author), zero-padded 3 digits. The current author's prefix is `MT`.
- **Fields:** ID · Created (`yymmdd`) · Item · Status (open / done / target).
- Add a row when a **new pipeline function is required** or a **feature is considered**. This list is
  expected to grow as the pipeline matures toward the AMT Control Center target.
- This is the renamed successor to the old `G-n` gap list: `G-1`→`MT-001`, `G-2`→`MT-002`, `G-3`→`MT-003`
  (console-build gap = `MT-004`).

## When a new feature / pipeline request or bug is raised

1. Choose the next free number in the relevant register (`T3-` for a bug; `<initials>-` for a ToDo/feature).
2. Write the row: `yymmdd` created date + a one-line title and short detail.
3. Add it to [docs/SSG-PowerShell-Trial-Progress.html](../../docs/SSG-PowerShell-Trial-Progress.html)
   (§6 Issues or §7 ToDo), and cross-link from §3 if it blocks a specific program.
4. Keep the Asset Register ([docs/Asset-Register.md](../../docs/Asset-Register.md)) in step for the
   `MT-nnn` items it already lists.
