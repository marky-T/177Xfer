---
mode: agent
description: "Govern and control the MT-009 build of a separate COBOL/OS2200 (AFBUS_COBOL-style) AMT177 application for Stage B — gated, approval-first, not a free-run build script"
argument-hint: "Optional: which procedure step to resume at (defaults to step 1)"
---

# /ssg-build-afbus-cobol — build the COBOL/OS2200 application (MT-009)

Drive the **MT-009** workstream: build a separate AMT177 application with `ApplicationKind =
CobolOS2200` so OS2200 SSG/ECL/COBOL reports (our SsgConverter output) can run through Control Center,
without ever touching `FEDERALE_APP` (the existing ABSuite/LINC application).

This prompt is written to be run **in a fresh session**. Do not assume prior context — orient first.

## 0. Orient (always do this first)

1. Load [copilot-instructions.md](../copilot-instructions.md) for the always-on guardrails and
   current status.
2. Load the governing plan:
   [.github/Copilot_Plans/260916-mt009-build-cobol-application.md](../Copilot_Plans/260916-mt009-build-cobol-application.md).
   **Treat that plan as the source of truth for the procedure** — if it has changed since this prompt
   was written, follow the plan file, not a stale copy of it here.
3. Load [ssg-amtcc-runbook.instructions.md](../instructions/ssg-amtcc-runbook.instructions.md) (Area D)
   for the Stage A/B guardrails this workstream builds on.
4. Check the progress tracker's `MT-009` row and `#run-cfh-copy-cc` runbook in
   [docs/SSG-PowerShell-Trial-Progress.html](../../docs/SSG-PowerShell-Trial-Progress.html) for the
   latest recorded status, and check for any newer plan file in `.github/Copilot_Plans/` touching
   MT-009 or Stage B.
5. State to the user: current plan status, which procedure step you believe comes next (or the one
   given in `${input:step}`), and what evidence supports that. **Then stop and ask for confirmation**
   before doing anything else.

## Architecture constraint (do not violate)

- `FEDERALE_APP` is an **ABSuite/LINC** application. Its catalog holds `AmtReport` DLL jobs only — a
  live scan confirmed it does **not** register PowerShell/COBOL scripts.
- The COBOL/ECL reports **must never** be registered, deployed, or run against `FEDERALE_APP`.
- Everything in this workstream targets a **new, separate** application.

## Procedure (from the MT-009 plan — follow it there for full detail)

Work through these gates **one at a time**, confirming with the user before crossing any change-control
boundary (see below). Do not skip ahead.

1. **Review Trial3** for the build/config steps used to create `AMT175_AFBUS_COBOL` (manifest, config,
   setup notes) and any available AMT admin documentation on application creation. Report findings
   before proceeding — if material is missing or ambiguous, **stop and say so** (see Change Controls).
2. **Confirm the required application DB entry, base paths, controllers, binaries, and scripts
   layout** for the AMT177 equivalent. Report the concrete values found (or the gaps).
3. **Create a separate AMT177 application** (`ApplicationKind = CobolOS2200`) — **only after** step 1–2
   are reviewed and the user has explicitly approved proceeding.
4. **Replicate only the COBOL-host-required settings** — never copy ABSuite-specific config from
   `FEDERALE_APP`.
5. **Associate the deployed artefacts** — `Scripts\SSGTRIAL\RUN\CFH-COPY.ps1` and
   `Scripts\Settings\AmtSettings.xml` (already on disk from the prior Stage B attempt) — with the new
   application.
6. **Start or register the application** through the approved AMT administration process (not a raw
   DB insert unless that is itself the approved process).
7. **Run the Control Center application scan** against the new application.
8. **Confirm the scripts are discovered and catalogued** (a `Script`-type `CFH-COPY` row appears).
9. **Run a controlled Stage B test** and capture the result (joblog, Event Viewer, output).

## Change controls (hard gates — do not bypass)

- **Do not create the application or write to the system database** until step 1–2 have been reviewed
  **and the user has explicitly approved** the specific approach.
- **Back up** relevant configuration before making changes.
- **Record configuration changes** (plan file, tracker `MT-009`, session memory) **only after** they
  have been applied and validated — never speculatively.
- **If the reference material is incomplete, stop** and obtain the approved AMT application-build
  procedure (ask the user / the AMT Copilot) rather than guessing at DB schema or admin steps.
- Never touch `FEDERALE_APP` configuration, its catalog rows, the `FA_AFBUS`/`FEDERALE_SYSTEM` DB
  outside this new application's own rows, or the `ava` service account.

## Validation checklist (confirm all before declaring MT-009 done)

- [ ] The new application is separate from `FEDERALE_APP`.
- [ ] The application kind is `CobolOS2200`.
- [ ] Required base paths and controllers resolve correctly.
- [ ] The SSG/ECL/COBOL scripts (`CFH-COPY`) are visible in Control Center.
- [ ] The Stage B report runs under the COBOL application.
- [ ] No `FEDERALE_APP` configuration or catalog entries were altered.

## Closing action

Once a step (or the whole workstream) is completed **and reviewed by the user**, run
[`/ssg-update-tracker`](ssg-update-tracker.prompt.md) to sync `MT-009`, the `#run-cfh-copy-cc` /
`#stageb-runbook` entries, and any new `T3-nnn` issue this surfaced.
