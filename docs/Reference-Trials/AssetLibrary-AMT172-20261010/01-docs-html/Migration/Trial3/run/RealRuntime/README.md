# RealRuntime/ — isolated `AmtPsEclLib` reference (NOT a live config)

These files are an **isolated copy** (copied once, never the live module) of the AMT177 runtime
libraries, used only for our own **Stage A** proof (see `docs/SSG-PowerShell-Trial-Progress.html`
§5b "Stage A runbook"): running a converted `.ps1` against the *real* `AmtPsEclLib` with **no
COM/live-app connection** — not a live `Connect-Application` run.

| File | Role |
|------|------|
| `AmtPsEclLib.psm1` | Isolated copy of the real ECL runtime module (provenance: copied from `Federale_InternalRelease` on AMT177, never modified). |
| `AmtPsSortLib.psm1`, `AmtPsCustomerLib.psm1` | Same isolated-copy provenance, sibling modules. |
| `AmtSettings.xml` | **Minimal, non-live** settings crafted for the isolated Stage A run only — do **not** treat as a proven-working live config. |
| `Run-StageA.ps1` | The Stage A runbook script: imports the isolated module, sets `$global:WarningRcw2435=$false`, seeds `$global:SgsLabels`, runs a converted program, captures output to `FIN`/`End Job`/`Script Done`. |

## What this does NOT prove

- **Not a live run.** `Initialize` in the real `AmtPsEclLib` (not exercised here) does
  `Add-Type ComScript` → `Connect-Application` against a live AMT app — that's **Stage B**, which
  is what AMT172's own Control Center trial is for.
- **Only `CFH-COPY` has been run this way** (see `manifest.json` / `GoldenReconciliation.json`); the
  other 19 programs have only reached the Tier-1 mock-shell (`Tier1Mock/`).
- **`AmtSettings.xml` here is not a proven live-run config** — our own Stage B is itself blocked on
  this VM (no second `ApplicationKind=CobolOS2200` application exists yet; see MT-009 in the tracker
  snapshot). Field-compare it against your own working config; do not reuse it as-is.
