---
mode: agent
description: "Package, dry-run, and deliver a client release of the converted SSG→PowerShell programs (MT-017)"
argument-hint: "[-Programs <KEY,KEY,...> | -All] [-Target Internal|Client|Both]"
---

# /ssg-release — ${input:Programs}

Build and deliver a client release of the converted SSG → PowerShell programs, repeating the proven
2026-10-02 process (`MT-016`) mechanically. Design and rationale:
[261005-mt017-ssg-release-prompt.md](../Copilot_Plans/261005-mt017-ssg-release-prompt.md).

**Assets** live in `SsgConverter/Trials/Release/`. Do not re-author them per release — fix them in
place if they're wrong, so every future run inherits the fix.

## Inputs

- **`-Programs`** — explicit keys, e.g. `CFH-COPY,ARCHIFORMAT`.
- **`-All`** — every converted program in `Examples/Output` (**opt-in**, never a silent default).
- **`-Target`** — `Internal` (AMT172 proof), `Client` (Federale delivery), or `Both` (default).

### If the user gave neither `-Programs` nor `-All` — ask, don't guess

Run `SsgConverter/Trials/Release/Get-ReleaseCandidates.ps1` first, then put the choice to the user:

1. **State the release candidate up front** — the `NextReleaseLabel` and `Destination` it returned, so
   they know what is about to be built before choosing anything.
2. **Ask: release everything, or pick?**
   > *"Next release candidate is `release<YYYYMMDD>-rc.NN`, building to `<destination>`.
   > There are N converted programs (M ready). Release **all** of them, or **select** specific ones?"*
3. **If they choose "select"** — show the candidates as a **multi-select** (ask-questions tool with
   `multiSelect`), one option per program, pre-selecting the ready ones and marking any that aren't
   `Ready` (missing seed or original) so the reason is visible.
4. Proceed with their answer exactly as if it had been passed as `-Programs` / `-All`.

Never infer a program list from "whatever is in `Examples/Output`" without the user opting in — a
half-finished conversion must not ship just because it exists on disk.

## Steps

1. **Build.** `SsgConverter/Trials/Release/Build-Release.ps1 -Programs <keys>` (or `-All`)
   Aborts up front (MT-022) if the converter has drifted from `Examples/Output` - source edited
   without a rebuild, or the DLL rebuilt without regenerating `Examples/Output`. If so, run
   `SsgConverter/Trials/Reconvert-And-Verify.ps1 -Rebuild -RefreshDll -UpdateGoldens` first, then
   retry the build.
   Per program it verifies body + seed + original exist, parse-checks the body, and **re-runs the
   Tier-1 harness inline** (there is no trustworthy stored pass/fail — see the plan's Gap 1).
   Anything failing is **excluded and reported**; other programs still ship. A generated *wrapper*
   that fails parse-check aborts the whole build (generator defect, not a data issue).
   Report the included/excluded lists, and flag any program with a non-zero **unmocked** count — that
   means SGS keys its body looks up aren't seeded, which usually shows up as a live-run failure.

2. **Docs.** Fill `README.template.md` / `RELEASE-NOTES.template.md` into the release folder,
   substituting `{{RELEASE_LABEL}}`, `{{RELEASE_DATE}}`, `{{PROGRAM_COUNT}}`, the converter
   fingerprint (SHA-256 + size of `SsgConverter/Build/Console/SsgConverter.dll`), and the
   `{{PROGRAM_TABLE}}` — built from `build-manifest.json` (mechanical: Tier-1 result, line count,
   unmocked count) merged with `KnownIssues.json` (narrative column; blank for programs with no
   entry — that's normal). `{{CHANGELOG}}` = what changed vs. the previous `Scripts_SSG` commit on
   `Federale_InternalRelease`'s `main`; derive it by diff, don't recall it from memory.

3. **Dry-run the install.** `Mock-Install-Dryrun.ps1 -ReleaseDir <dest>`
   Runs the real wrappers + bodies against a mock runtime in the documented folder shape, with
   `AMT_RT`/`AMT_SETTINGS` unset so the relative fallback is what's under test.
   **If it fails: stop and report.** Do not ship past a new install-mechanics failure.

4. **Decide on live validation.** `Get-MechanicsFingerprint.ps1`
   - **Changed** → a live install test-proof is **required**. Say which file changed, force `Internal`
     into scope regardless of `-Target`, and do not deliver to the client first. *No question here —
     this case is not skippable.*
   - **Unchanged** → **ask the user**: proceed to client delivery citing the prior proof
     (date/JobId from `LastLiveValidation.json`), or run the AMT172 test-proof again anyway?
     Default = proceed and cite. Either way, record the choice verbatim in `RELEASE-NOTES.md`.

5. **Checkpoint before any push.** Confirm with the user: release label, included/excluded programs,
   dry-run result, live-validation decision, and target(s). **Never push without this.**

6. **Internal push** *(if `Internal` in scope)* — to `marky-T/177Xfer`: `git fetch`, branch off
   **`origin/main`**, stage **only** the release folder, commit, push, verify the remote tip.
   Then hand the user a paste-ready AMT172 validation prompt (use the release's `VALIDATION-PROMPT.md`
   as the basis). **Pause here** — the live run happens on their machine; it cannot be automated from
   this side. On a confirmed success, run
   `Get-MechanicsFingerprint.ps1 -Update -JobId <id> -ProgramKey <key>`.

7. **Client delivery** *(if `Client` in scope, and step 4 is satisfied)* — to
   `Federale_InternalRelease`: `git fetch`, branch off **`origin/main`** (never the local `main` —
   it drifts), copy the release payload **minus `VALIDATION-PROMPT.md`** into `Scripts_SSG/` as a
   whole-set overwrite, stage **only** that folder, verify nothing else is staged, commit, push.

8. **Hand off the PR — never open it yourself.** Give the user the branch name/URL and the generated
   changelog for the PR description.

9. **Close the loop.** Add/update the release's `MT-nnn` row in
   [the progress tracker](../../docs/SSG-PowerShell-Trial-Progress.html) §7, and reconcile any plan
   file whose status/checklist is now stale.

## Guardrails

- **Never push to `main`** on either remote; always a branch + human-opened PR.
- **Always branch off `origin/main` after an explicit `fetch`** — a local clone silently drifts
  between weekly runs (confirmed on `Federale_InternalRelease`, 2026-10-02).
- **`Federale_InternalRelease`'s `.git` is ACL-restricted.** Unelevated git writes fail with
  `fatal: unable to write new index file`. Detect this early and hand the user the exact **elevated**
  command instead of retrying — never attempt to elevate or change ACLs yourself.
- **Verify `git config user.name`/`user.email` are real before committing.** A missing identity makes
  `git commit` silently no-op; a placeholder identity reaches R&D's review.
- **Stage only the intended folder** — check `git diff --cached --name-only` shows nothing outside it
  before every commit.
- `SSG-Source/` and `Examples/Input` are **read-only**; the release only ever copies from them.
- **No Azure DevOps browser access** — confirm live repo/PR state via `git ls-remote`/`fetch` or a
  user-shared screenshot, never an assumption that a cached view is current.
- `E:\Repos\release_candidates\...` is **ephemeral staging**. The record of truth is the merged
  `Scripts_SSG` history on `Federale_InternalRelease`; `177Xfer` is an informal fast-track only.
