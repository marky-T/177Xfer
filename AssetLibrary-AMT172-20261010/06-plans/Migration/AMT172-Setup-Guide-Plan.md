# Plan: HTML Guide — Content Fixes + Phase Accordion + Step Timers

**TL;DR:** Full rewrite of `AMT172-Setup-Guide.html` incorporating three verified content fixes, a phase-level accordion with nav controls, and per-step stopwatch timers with a live accumulated total. All changes are self-contained in the single HTML file, zero external dependencies maintained.

---

## Phase A — Content Fixes

1. **Step 8 `sys.ini`** — fix path `C:\Amt\Working\Lion\sys.ini` → `C:\Amt\Working\sys.ini` and replace the bullet list / wrong key names with a correct ini code block using real keys (`ENVIRONMENT`, `SERVER TYPE`, `SERVER NAME NET`, `DATABASE NAME`) plus a note that DBUSER/DBPSSW are encrypted by AMT on first run
2. **Step 9 Lion.ini** — replace the 6-line abbreviated block with the full 16-line content verified from disk (adds `HTTPSENABLED`, `URL`, `VIRTUALFOLDER`, `WEBSITEROOT`, `LIONDEVNETSERVICENAME`, `LIONDEVNETSERVERNAME`) — note added that LIONDEVNET lines are relevant for Phase 10
3. **Step 30 LincToLion.ini** — same as above, full 16 lines, `DBSNAME=WORKING_LINC`

---

## Phase B — Phase Accordion

1. Add `.phase-collapsed` CSS rule to hide all `.step`, `p`, and `table` children when collapsed
2. Inject `▼` + `onclick="togglePhase(this)"` into every numbered phase header (phases 1–12). `#env` and `#pipeline` are **not** collapsible (no steps, just cards/tables)
3. Add two nav buttons: **▼ Expand All** / **▶ Collapse All** — just above the "Overview" section label in the left nav

---

## Phase C — Step Timers + Accumulated Total

1. **Per-step**: inject `00:00` + `▶` into every step header (stop-propagation so clicking the timer doesn't toggle the step). States: idle `▶` → running `⏹` → paused `▶` + a small `×` reset link
2. **Accumulated total**: `00:00` in the nav sidebar, updates live as any timer ticks
3. **localStorage persistence** — key `amt172-timer-{N}` per step, saved every 10 seconds + on stop. Restored on page load

---

## Phase D — Activity-Based Auto-Timing (added Jun 10 2026)

- `toggle()` extended: auto-starts step timer when a step is expanded, auto-stops when collapsed
- Manual ▶/⏹ buttons remain for override (pause mid-step, start before opening, etc.)
- Limitation: timer keeps running if step is left open — user must collapse to stop. Noted as PoC.

---

## Relevant Files

| File | Notes |
|------|-------|
| `C:\Amt\Migration\AMT172-Setup-Guide.html` | The deliverable — single self-contained file |
| `C:\Amt\Working\sys.ini` | Env root (NOT Lion\) — verified keys |
| `C:\Amt\Working\Lion\Lion.ini` | 16 lines, DBSNAME=WORKING_REPOS |
| `C:\Amt\Working\Lion\LincToLion.ini` | 16 lines, DBSNAME=WORKING_LINC |

---

## Verification Checklist

- [ ] Open in browser → all phase headers show `▼`, click collapses
- [ ] Nav "Collapse All" → all phases hide; "Expand All" → all show
- [ ] Click `▶` on any step timer → counts up, nav accumulated counter updates live
- [ ] Reload page → timer values persist from localStorage
- [ ] Step 8 code block shows `ENVIRONMENT`, `SERVER TYPE`, `SERVER NAME NET` (not Lion.ini keys)
- [ ] Steps 9 and 30 show all 16 lines including `LIONDEVNETSERVICENAME=LionDevNet_Generator`
- [ ] Open step → timer auto-starts; collapse → timer auto-stops

---

## Decisions

- Phase 11 stays as stub — expand when that work begins
- Timer buttons sit **in the step header** so they're accessible even when the step is collapsed
- `#env` and `#pipeline` sections are NOT collapsible (reference tables, not procedural steps)
- No changes to `AMT172-Setup-Guide.md`
- Activity-based timing is PoC — "Mark Done" button considered as future improvement

---

## Build Approach

HTML built in 9 PowerShell `Add-Content` chunks (~100–150 lines each) to avoid HTTP/2 stream timeout.
Single-quoted here-strings `@'...'@` used throughout — no PowerShell interpolation.
HTML entities (`&lt;`, `&gt;`, `&amp;`) written literally inside `<pre>` blocks.

| Chunk | Content | Status |
|-------|---------|--------|
| 1 | DOCTYPE + head + full CSS | ✅ Done |
| 2 | `<body>` + nav + main header + legend | ✅ Done |
| 3 | Environment section + Pipeline table | ✅ Done |
| 4 | Phase 1 steps 1–6 (SQL Server) | ✅ Done |
| 5 | Phase 2 steps 7–9 (sys.ini FIXED, Lion.ini FULL) + Phase 3 steps 10–12 | ✅ Done |
| 6 | Phase 3 steps 13–15 + Phase 4 steps 16–20 (Keycloak) | ✅ Done |
| 7 | Phase 5–7 steps 21–28 | ✅ Done |
| 8 | Phase 8 steps 29–34 (LincToLionGui, LincToLion.ini FULL) + Phases 9–12 stubs | ✅ Done |
| 9 | Bug Log + Quick Reference + Credentials + `</main>` + JavaScript | ✅ Done |

**Final file:** `C:\Amt\Migration\AMT172-Setup-Guide.html` — 74,289 bytes / 920 lines
