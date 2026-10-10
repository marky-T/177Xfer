# AMT172 / Working lane — agent scope

This workspace is the **AMT172 "Working" lane** and its **SSG‑COBOL → C#/PowerShell conversion**
work. Keep searches, reads and reasoning inside the relevant folders below so sessions stay fast
and don't pull in the parallel AMT175/AMT177 lanes.

## In scope — search and read here

| Area | Path | What it holds |
|------|------|---------------|
| AMT172 runtime lane | `Working/` | Live AMT172 install: `AMTTools/`, `Apps/`, `Files/`, `Lion/`, `Setup/`, `SystemLogging/`. App `AFBUS_2200COBOL`, DB `WORKING_SYSTEM`. Large binary tree — read specific files by path; it is intentionally excluded from bulk indexing in `.copilotignore`. |
| SSG‑COBOL conversion | `Migration/` | The conversion pipeline and trials: `EclCobolPipeline/`, `CobolConvert/`, `Trial3/`, `tools/`, plus the `SSG-*.html` / `AMT172-Setup-Guide.*` reference pages. |
| AMT reference docs | `AMT_ReferenceDocuments/` | Authoritative AMT docs — especially `AMT_ECLtoPowershell/` (ECL→PowerShell batch job mechanics) and selected `AMTLionReferenceDocs/` guides. |
| Agent config | `.github/` | `instructions/`, `prompts/`, `Copilot_Plans/`, `schemas/`. |

## Out of scope — do NOT search or read

- **`Parallel/`** — the AMT175 / AMT177 lanes and their templates. Not part of AMT172; ignore unless
  the user explicitly asks about a parallel lane.
- **`Working/OneDrive_2026-06-08/`** — a stale OneDrive snapshot; never a source of truth.
- Bulk mainframe source and build/output artefacts already excluded in `.copilotignore`
  (`MainframeSource/Codedrop 2025/…`, `**/bin/`, `**/obj/`, `Events/`, generated `Migration/*Out/`, etc.).

## Working notes

- The authoritative conversion runbook is `Migration/.github`-adjacent
  [amt-cobol-migration.instructions.md](instructions/amt-cobol-migration.instructions.md) (`applyTo: Amt/Migration/**`).
- The end‑to‑end Control Center / BatchController execution model is documented in
  `Migration/SSG-ECL-PowerShell-Reference.html` (§6b Control Center Runbook) and
  `AMT_ReferenceDocuments/AMT_ECLtoPowershell/Overview Batch Jobs in AMT - from ECL to PowerShell.md`.
- When a task clearly targets a parallel lane, tell the user it's out of this workspace's scope
  rather than searching `Parallel/`.

> To actually reduce the folders indexed/searched (not just guide the agent), the hard lever is
> [`.copilotignore`](../.copilotignore) — `Parallel/` and `Working/OneDrive_2026-06-08/` are excluded there.
