---
title: "MT-017 — Build a repeatable /ssg-release prompt (weekly client release automation)"
date: "2026-10-05"
status: "IMPLEMENTED 2026-10-05 — /ssg-release prompt + SsgConverter/Trials/Release/ assets built and smoke-tested; ready for first real weekly run"
owner: "MT"
area: "cross-cutting (C reconvert, D real-runtime facts) — new delivery-automation prompt"
---

# Plan: MT-017 — `/ssg-release` prompt

> **Implemented 2026-10-05.** This plan's design is now built: `.github/prompts/ssg-release.prompt.md`
> plus the supporting assets in `SsgConverter/Trials/Release/`. It automates the manual process used on
> 2026-10-02 (tracked as `MT-016`) so it can run **every Thursday/Friday** against the then-current
> converted SSG set. All 8 design decisions below were resolved before implementation; see
> [Implementation notes](#implementation-notes-2026-10-05) for what was built and the one deliberate
> deviation.

## Context

On 2026-10-02 ([MT-016](../../docs/SSG-PowerShell-Trial-Progress.html#MT-016)) the full release cycle
was done **by hand, interactively**: build the package → mock-test the install → push an internal
test-release branch → hand off a validation prompt to AMT172 → receive their live-run result → fold
findings back into the docs → re-push → deliver a client-facing copy into `Federale_InternalRelease` as
a PR. That took most of a session and needed several rounds of git troubleshooting (ACL/elevation,
author identity, a stray internal file). The ask now is to turn that into a **single repeatable
prompt** (`/ssg-release`) so the same cadence can run weekly without re-deriving the process each time.

## What actually happened on 2026-10-02 (the process to repeat)

Recapped precisely from the session, in order:

1. **Inventory** the currently-converted set: `SsgConverter/Examples/Output/*.ps1` (bodies),
   `SsgConverter/Examples/Input/*` (originals), `SsgConverter/Trials/<Program>/sgs-values.json` (SGS
   seeds) — confirmed all three exist per program before including it.
2. **Author a portable wrapper generator** (`Generate-Release-Wrappers.ps1`) that reads
   `SgsSeeds/<KEY>.sgs-values.json` + `Bodies/<KEY>.ps1` and emits `Wrappers/<KEY>-LIVE.ps1`:
   `Set-Jobname → Initialize → seed SGS → & <body> → Fin`, resolving the body from the **live CC Script
   basepath** (`$global:AmtPath.ScriptPath`) and the runtime/settings from `AMT_RT`/`AMT_SETTINGS` env
   vars (with a documented, depth-sensitive relative fallback). Had to fix a real bug here: use
   `.PSBase.Keys`/`.PSBase.Contains()` throughout, not `.Keys`/`.Contains()` — a seed label can
   literally be named `KEYS` and silently break enumeration (the same T3-007 hazard as the Tier-1
   mock).
3. **Assemble the release folder**: `Bodies/`, `Wrappers/`, `SgsSeeds/`, the generator script,
   `2_OriginalSource/`, `README.md`, `RELEASE-NOTES.md` — one folder per release, versioned
   (`release<YYYYMMDD>-rc.NN`).
4. **Parse-check every generated wrapper** (0 errors required before proceeding).
5. **Write/maintain two docs**: `README.md` (layout, prerequisites, install/run steps, a prominent
   "Required runtime setup" callout, regeneration instructions, provenance) and `RELEASE-NOTES.md`
   (converter build fingerprint, 3-tier testing method, a **per-program** status + known-issues table,
   cross-cutting issues, "what this does not yet claim").
6. **Mock install dry-run** (1–2 programs, no real AMT app): a throwaway mock `AmtPsEclLib.psm1`
   providing just enough of `Set-Jobname`/`Initialize`/`Abort`/`HandleTrapAndAbort` to exercise the real
   wrapper + body end-to-end, seeding SGS via the existing Tier-1 `SsgPsMockLib.psm1`. This caught 2
   real install-mechanics risks *before* shipping (flat body placement; prefer explicit env vars over
   the relative fallback) — folded back into the docs as the emphasised "Required runtime setup"
   section.
7. **Push an internal test-release branch** to `marky-T/177Xfer` (branched off `main`, so it carries
   only the release payload) — confirmed clean (fetch, branch-off, stage-only-the-new-folder, commit,
   push, verify remote tip).
8. **Hand off a validation prompt** to the AMT172 Copilot session (a separate, paste-ready prompt — not
   committed into the release) asking them to pull the branch, read the README's required-setup
   section, install **one** program, register + run it live, and report back deviations.
9. **Receive + fold in AMT172's live-validation feedback**: they ran `CFH-COPY` live (`Script Started →
   FIN → Script Done`, exit 0) and supplied a reusable, environment-agnostic validation checklist.
   Reviewed it, added two refinements from the real run (stage inputs only if the body genuinely does
   file I/O; register/run the wrapper, never the body), committed it into the release as
   `VALIDATION-PROMPT.md`, recorded the live result in `RELEASE-NOTES.md`, re-pushed.
10. **Deliver the client-facing copy**: confirmed the real client repo (`Federale_InternalRelease`,
    Azure DevOps) and its existing `Scripts/` layout live, branched off `origin/main`, copied the
    release payload in as a new top-level `Scripts_SSG/` folder (sibling to `Scripts/`, per R&D's
    layout request) — **minus** the internal `VALIDATION-PROMPT.md` — staged **only** that folder,
    committed, pushed, and the user opened PR !14791 (reviewed and approved). **Caught a real
    repo-freshness gap here**: the local clone's `main` was genuinely stale vs. the true remote `main`
    (confirmed via a screenshot of the Azure DevOps UI — the real `main` had newer content, e.g.
    `BSP_AMT`/`reo.zip`, that the local clone lacked). Branching off `origin/main` (after an explicit
    `git fetch`), not the possibly-stale local `main`, avoided basing the delivery on old content — but
    this was only caught because the user happened to share a screenshot; nothing automated checked it.
    **I have no direct browser access to Azure DevOps** — confirming the live repo state depends on
    either a user-shared screenshot or local git commands (`fetch`, `ls-remote`), never an assumption
    that a previously-cloned local `main` is current.
11. **Fixed process friction along the way** (worth keeping as documented gotchas in the prompt, not
    re-discovering them every week): `Federale_InternalRelease`'s `.git` is ACL-restricted for
    non-admin processes (`fatal: unable to write new index file`) — git ops there need an **elevated**
    terminal; a missing git identity silently no-ops `git commit` (checked, not assumed); correcting an
    already-pushed commit's author requires a `reset --soft`-and-recommit + `push --force-with-lease`,
    scoped only to the one folder being delivered.
12. **Closed the loop**: updated the progress tracker (`MT-016` row) and the originating plan
    (`MT-010`) to reflect the finished, live-validated, merged state — including fixing a stale
    `Phases` checklist that still said `[NOT STARTED]` after the work was actually done.

## Design for `/ssg-release`

Modelled on the existing `/ssg-*` prompts ([ssg-reconvert.prompt.md](../prompts/ssg-reconvert.prompt.md),
[ssg-e2e.prompt.md](../prompts/ssg-e2e.prompt.md)) and the MT-010 precedent of a repo-tracked,
idempotent assembly script (`Build-AMT172HandoffBundle.ps1`). Proposed shape:

### New prompt file
`.github/prompts/ssg-release.prompt.md` — `mode: agent`, two required/primary arguments:
`-Programs <key1,key2,...>` (mandatory, no "all" default — decision 2) and `-Target
Internal|Client|Both` (default `Both` — decision 1). Release label defaults to
`release<YYYYMMDD>-rc.01`, auto-incrementing `.rc.NN` if run twice the same day.

### New repo-tracked assets (so the process is mechanical, not re-authored each week)
- `SsgConverter/Trials/Release/Build-Release.ps1` — the repeatable assembler (today's scratch
  `_build-release.ps1`, promoted into the repo). Takes the **mandatory** `-Programs` list (decision 2)
  — no implicit "everything in `Examples/Output`" default — and for each key verifies a body, seed,
  and original all exist, parse-checks the body, and **runs the Tier-1 harness inline**
  (`Trials/Tier1Mock/Run-SsgPsTrial.ps1 -Program <KEY>`) to re-prove it at release time rather than
  trusting any stored status (see [Gap 1](#gap-1-tier-1-status-is-not-machine-readable-resolved));
  anything failing these checks is **excluded and reported**, never silently shipped (decision 3).
- `SsgConverter/Trials/Release/Generate-Release-Wrappers.ps1` — the wrapper generator, promoted from
  the release folder into the repo (single source of truth, copied into each release's
  `1_ConvertedScripts/` at build time rather than hand-authored per release).
- `SsgConverter/Trials/Release/Mock-Install-Dryrun.ps1` + its mock `AmtPsEclLib.psm1`/
  `AmtPsSortLib.psm1` — promoted from today's scratch `_mock-install-test.ps1` + mock libs, so every
  release re-validates install mechanics (flat body placement, env-var resolution) before shipping,
  automatically, not as an ad hoc one-off.
- `SsgConverter/Trials/Release/README.template.md` / `RELEASE-NOTES.template.md` — templates carrying
  the static sections (layout, prerequisites, "Required runtime setup", testing method) with
  placeholders for the per-release variable content (program count, converter fingerprint, per-program
  table, live-validation result, changelog). Reduces re-typing and drift between releases.
- `SsgConverter/Trials/Release/VALIDATION-PROMPT.md` — kept as a stable template (AMT172's
  environment-agnostic checklist, already refined once) copied as-is into each internal test-release
  push; not regenerated from scratch each week (may still be hand-refined if a future live run
  surfaces something new).
- `SsgConverter/Trials/Release/KnownIssues.json` — **new (decision 6)**: per-program narrative
  known-issues text (e.g. "SCAN_ASCII's conditional path is unexercised"), keyed by program key,
  merged into the mechanically-generated per-program table at build time. Hand-maintained; a program
  with no entry just gets an empty cell.
- `SsgConverter/Trials/Release/LastLiveValidation.json` — **new (decision 7)**: the mechanics-change
  state file (`date`, `jobId`, `programKey`, `mechanicsFingerprint`) described under
  [Mechanics-change detection](#mechanics-change-detection-for-decision-7) above — lets the prompt
  decide automatically whether a fresh AMT172 loop is required.

### Prompt steps (revised to match the resolved decisions)
1. Require `-Programs` (no default); resolve the release label. Confirm the destination is a **new,
   empty** folder.
2. Run `Build-Release.ps1` against exactly the requested `-Programs` — for each key: verify body/seed/
   original exist, parse-check the body, and **run the Tier-1 harness inline** to re-prove it at
   release time (see [Gap 1](#gap-1-tier-1-status-is-not-machine-readable-resolved)); **exclude and
   report** anything that fails any of these (decision 3). Then run `Generate-Release-Wrappers.ps1` and
   parse-check every wrapper (abort the run on any parse error — do not ship a broken wrapper).
3. Populate `README.md`/`RELEASE-NOTES.md` from the templates: mechanical per-program status columns
   (parse, Tier-1, live-validation-if-known) + `KnownIssues.json` merged in for the narrative column
   (decision 6); generate the **changelog** section by diffing this release's `-Programs`/content
   against the previous `Scripts_SSG` commit on `Federale_InternalRelease`'s `main` (decision 8).
4. Run `Mock-Install-Dryrun.ps1` against 1–2 representative programs; **stop and report** if it finds a
   new install-mechanics issue (don't silently ship past a new dry-run failure).
5. **Compute the mechanics fingerprint** and compare to `LastLiveValidation.json` (decision 7):
   - **Changed** — state that a fresh install test-proof is required (naming which mechanics file(s)
     changed), force `-Target` to include `Internal` regardless of what was requested. No question —
     this case is not skippable.
   - **Unchanged** — **ask the user**: proceed straight to client delivery citing the prior validation
     (`<date>`/JobId `<id>`), or run the AMT172 install test-proof again anyway? Default = proceed and
     cite; either way the choice is written verbatim into `RELEASE-NOTES.md`.
6. **Checkpoint — ask before any push** (per operational safety: pushing to a shared remote). Confirm
   with the user: release label, resolved program list (incl. anything excluded + why), dry-run
   result, target(s), before touching git.
7. *(If `Internal` is in scope)* Push the internal test-release branch to `marky-T/177Xfer` (fetch,
   branch off `main`, stage only the release folder, commit, push, verify remote tip — same verified
   sequence as MT-016; no retention/archival concern for this branch — decision 5).
8. *(If `Internal` is in scope)* Offer the paste-ready **AMT172 hand-off prompt** (adapted from the one
   used 2026-10-02), not committed to the branch.
9. *(If `Internal` is in scope)* **Pause for the human loop**: AMT172 installs/validates live and
   reports back — this cannot be automated from this side (no access to their environment). On
   confirmed success, update `LastLiveValidation.json` with the new date/jobId/fingerprint.
10. *(If `Client` is in scope)* **Checkpoint — confirm client delivery.** Only after explicit go-ahead
    (and only once the mechanics-fingerprint gate in step 5 is satisfied): fetch `origin/main` fresh
    (never trust a possibly-stale local `main`), branch off it, copy the release payload minus
    `VALIDATION-PROMPT.md` into `Scripts_SSG/` as a **whole-set overwrite** (decision 8), stage
    **only** that folder, commit, push. Flag the known ACL/elevation requirement up front rather than
    letting it fail first.
11. **Never auto-open the PR** — hand the user the exact branch name/URL and let them open/approve it
    in Azure DevOps themselves (shared-infra, human-approval boundary). Remind them the PR description
    should include the generated changelog.
12. Update the progress tracker (`MT-nnn` row for the release) and cross-reference any plan file whose
    "Phases"/status needs reconciling — repeating the MT-010 lesson: don't leave a checklist stale
    once work is actually done.

## Decisions (resolved 2026-10-05)

1. **Scope per run — sequential by default, skippable for minor updates.** The ideal path is still
   Internal (AMT172 proof) **then** Client delivery, in that order with a checkpoint between — that
   won't happen for every release. `/ssg-release` takes `-Target Internal|Client|Both` (default
   `Both`, run sequentially with the checkpoint). A `Client`-only run is allowed for a minor/
   single-program update, but whether it is *permitted to skip* AMT172 re-validation is decided by the
   **mechanics fingerprint gate** (decision 7), not by a flag the caller can simply assert — see
   [Gap 2](#gap-2-redundant-skip-flag-resolved) below.
2. **No auto-discovery — explicit program list every run.** `/ssg-release -Programs <key1,key2,...>`
   is **mandatory**; there is no "ship everything in `Examples/Output`" default. This is deliberately
   safer than last time's assumption — a half-finished conversion sitting in `Examples/Output` must
   never ship just because it exists there.
3. **Untested programs are excluded automatically**, not flagged-and-shipped. If a requested key in
   `-Programs` has no `sgs-values.json`, fails parse-check, or doesn't pass Tier-1, it's **dropped
   from the release and reported** — the run does not fail outright (other requested programs still
   ship), but that program is never silently included. **How "passes Tier-1" is determined is a real
   gap — see [Gap 1](#gap-1-tier-1-status-is-not-machine-readable-resolved) below**; resolved by
   running the Tier-1 harness inline during the build rather than trusting any stored record.
4. **Versioning stays `release<YYYYMMDD>-rc.NN`** — no change.
5. **Record of truth = `Federale_InternalRelease`'s merged `Scripts_SSG` history (via PRs on `main`).**
   `marky-T/177Xfer` is confirmed as an informal fast-track for the AMT172 validation loop only — its
   branches need no retention/archival policy; they can accumulate or be cleaned up later without
   concern. `E:\Repos\release_candidates\...` stays ephemeral local staging, as already planned.
6. **Per-program table: mechanical columns + a human-maintained `KnownIssues.json`.** The generator
   produces the parse/Tier-1/live-validation status columns automatically; a
   `SsgConverter/Trials/Release/KnownIssues.json` (keyed by program) supplies the narrative
   known-issues text, merged in at build time. A program with no entry in that file just gets an empty
   known-issues cell — not an error, since most programs genuinely have none.
7. **AMT172 live-validation: only when wrapper/runtime mechanics change, not every week.** Needs a
   concrete "has anything that matters changed?" test, not a judgement call each time — see
   [Mechanics-change detection](#mechanics-change-detection-for-decision-7) below for the actual
   mechanism. When unchanged, a `Client`-only run is allowed to cite the **prior** live-validation
   result in `RELEASE-NOTES.md` rather than re-earning it.
8. **Client delivery: whole-set overwrite + a changelog.** Every delivered release replaces the full
   `Scripts_SSG/` content (simple, always-consistent — no partial/diff-only file touches), but the PR
   description (and a `CHANGELOG` section in `RELEASE-NOTES.md`) states what's new/changed since the
   **previous** `Scripts_SSG` commit on `main`, derived by diffing against it (not hand-recalled).

### Mechanics-change detection (for decision 7)

To decide whether a release needs a fresh AMT172 live-validation loop or can cite a prior one, track a
small state file: `SsgConverter/Trials/Release/LastLiveValidation.json` —
`{ "date": "...", "jobId": "...", "programKey": "...", "mechanicsFingerprint": "<sha256>" }`. The
fingerprint is a hash of the files that actually determine *install/runtime mechanics* (not program
content): `Generate-Release-Wrappers.ps1`, the wrapper's env-var/basepath-resolution logic, and
`Mock-Install-Dryrun.ps1`'s mock libs. Each `/ssg-release` run recomputes the fingerprint and compares
it to the stored one.

**The prompt asks the user — but the fingerprint frames the question.** The computed result decides
*whether there is a real choice to make*, so the user is never asked to adjudicate something the tool
already knows, and never able to wave through a genuinely unproven change:

- **Mismatch (mechanics changed)** → **no question asked.** The release must go through the
  Internal → AMT172 loop before any `Client` delivery, regardless of the `-Target` requested. The
  prompt *states* this and names which mechanics file(s) changed, so it's explainable, not arbitrary.
  (This is the case that must not be skippable — shipping never-proven wrapper mechanics to the client
  is exactly what the loop exists to prevent.)
- **Match (mechanics unchanged)** → **the prompt asks**, because here there genuinely is discretion:
  > *Mechanics are unchanged since the last live validation (`<date>`, JobId `<id>`). This looks like a
  > minor/content-only update. Proceed straight to client delivery citing that prior validation, or run
  > the AMT172 install test-proof again anyway?*

  Default is **proceed and cite** (the common weekly case). Choosing a re-proof anyway is always
  allowed — a user may want extra assurance when the release adds several new programs, or before a
  milestone delivery. Whichever is chosen, `RELEASE-NOTES.md` states it explicitly: either this
  release's own live-validation result, or the cited prior one — never silently omitting which.

On a fresh AMT172 live-validation success, the prompt updates `LastLiveValidation.json` with the new
date/jobId/fingerprint.

## Gaps found during plan review (2026-10-05) — both resolved

Verified the plan's factual claims against the repo before signing it off. All 8 artefacts proposed
for promotion still exist on disk (generator, scratch orchestrator, mock-install harness + both mock
libs, and the three release docs). Two design gaps surfaced:

### Gap 1 — "Tier-1 status" is not machine-readable (resolved)

Decision 3 assumed `Build-Release.ps1` could check that a program "has passed Tier-1". **It can't,
as written.** There is no machine-readable Tier-1 pass/fail record anywhere in the repo:
`SsgConverter/Trials/` holds only `DiscDesignators.json` and `GoldenReconciliation.json` (neither
carries run status), and the 21 `Trials/<Program>/out/*.out.txt` files are raw output captures, not
verdicts. The authoritative Tier-1 status today lives as **hand-written prose** in the progress
tracker's §3 table — not parseable, and liable to drift from reality.

**Resolution:** `Build-Release.ps1` **runs the Tier-1 harness inline** for each requested program
(`Trials/Tier1Mock/Run-SsgPsTrial.ps1 -Program <KEY>`) as part of the release build, and gates on the
*live* result — rather than trusting a stored record that could be stale. This is strictly better than
a status file: it re-proves each program at release time (catching a regression introduced since the
last manual run), and it produces the exact figures the per-program table needs (emitted line count,
unmocked-lookup count) as a by-product. A program whose inline Tier-1 run fails is excluded and
reported, per decision 3. *(Optional follow-up, not required: have the harness also emit a small
`result.json` per program so the figures don't have to be re-scraped from console output.)*

### Gap 2 — redundant skip flag (resolved)

Decision 1 originally required a `-SkipAmt172Validation` flag for a `Client`-only run, while decision 7
independently gates the same thing on the mechanics fingerprint. Two mechanisms controlling one
outcome invites them to disagree — e.g. the flag says "minor, skip it" while the fingerprint says the
install mechanics genuinely changed and have never been proven live. Whichever the prompt checked
first would silently win, and in the worst case never-validated wrapper mechanics ship to the client.

**Resolution:** drop the flag; keep **one** mechanism, and have the prompt **ask** rather than assert.
`-Target` expresses *intent*; the fingerprint decides whether there is a real choice to make, and the
prompt asks the user only in the case where there is one (mechanics unchanged → "minor update, cite the
prior proof — or re-run the install test-proof anyway?"). Where mechanics *did* change, no question is
asked and the Internal loop is required. The user still has the final say in the discretionary case,
but can't accidentally override a genuine safety check — see
[Mechanics-change detection](#mechanics-change-detection-for-decision-7).

## Implementation notes (2026-10-05)

Built and smoke-tested. Delivered:

| File | Role |
|------|------|
| `.github/prompts/ssg-release.prompt.md` | the `/ssg-release` prompt (mandatory `-Programs`, `-Target`) |
| `SsgConverter/Trials/Release/Build-Release.ps1` | assembler + per-program fitness gate |
| `SsgConverter/Trials/Release/Invoke-Tier1Check.ps1` | inline Tier-1 re-proof, one child process per program |
| `SsgConverter/Trials/Release/Generate-Release-Wrappers.ps1` | wrapper generator (promoted, byte-identical to the AMT172-validated one) |
| `SsgConverter/Trials/Release/Mock-Install-Dryrun.ps1` | install-mechanics dry-run |
| `SsgConverter/Trials/Release/MockRuntime/*.psm1` | mock `AmtPsEclLib`/`AmtPsSortLib` for that dry-run |
| `SsgConverter/Trials/Release/Get-MechanicsFingerprint.ps1` | the decision-7 gate (`-Update` records a validation) |
| `SsgConverter/Trials/Release/{README,RELEASE-NOTES}.template.md` | release docs templates |
| `SsgConverter/Trials/Release/KnownIssues.json` | narrative known-issues, merged into the program table |
| `SsgConverter/Trials/Release/LastLiveValidation.json` | seeded with the real 2026-10-02 AMT172 proof (JobId 1085) |
| `SsgConverter/Trials/Release/VALIDATION-PROMPT.md` | stable AMT172 validation checklist |

**Smoke-test results.** `Build-Release.ps1 -Programs CFH-COPY,UNLOADIS_ASCII` → both passed the inline
Tier-1 gate (45 / 63 emitted lines, 0 unmocked each), 2 wrappers generated, all parse 0.
`Mock-Install-Dryrun.ps1` → both `exit=0 PASS`. `Get-MechanicsFingerprint.ps1` → correctly reports
*unchanged* against the seeded 2026-10-02 state, i.e. the discretionary "ask the user" path.
Fitness gate verified negatively too: a bogus key was **excluded with reasons** while the valid
program still shipped (`Included: 1, Excluded: 1`) — it degrades, it doesn't crash or silently ship.

### Deliberate deviation — fingerprint scope narrowed

The plan draft listed the mock libs and `Mock-Install-Dryrun.ps1` as part of the mechanics
fingerprint. **Implemented over `Generate-Release-Wrappers.ps1` only.** Rationale: the mock harness is
local pre-ship scaffolding that never reaches the client, so editing it cannot invalidate what AMT172
proved — including it would force an expensive cross-machine re-validation every time we tweak our own
test harness. What AMT172 actually validated is the *generated wrapper*, so the generator alone defines
the fingerprint. (Verified the promoted generator is byte-identical to the one in
`release20261002-rc.01`, so the seeded state file legitimately applies.) Documented in-script.

## Guardrails (carried over from MT-016, apply to every run)
- Never push directly to `main` on either remote — always a branch, human opens/approves the PR.
- **Always `git fetch` and branch off the remote `origin/main`, never a possibly-stale local `main`.**
  A local clone can silently drift between weekly runs (confirmed happening to `Federale_InternalRelease`
  on 2026-10-02) — verify via `git ls-remote origin main` vs. local `origin/main` before branching, every
  run, not just the first time.
- Never attempt the `Federale_InternalRelease` git writes from an unelevated terminal — detect the ACL
  failure mode early and hand the user the exact elevated command, as done 2026-10-02.
- Verify git identity (`user.name`/`user.email`) is real before any commit that will be reviewed by
  R&D — don't let a placeholder slip through again.
- Stage **only** the intended release folder in both repos — verify `git diff --cached --name-only`
  shows nothing outside it before every commit (the pattern that caught/prevented drift today).
- `SSG-Source` / `Examples/Input` remain read-only; the release only ever copies from them.
- Parse-check every generated wrapper; never ship one with parse errors.
- Keep the progress tracker and any referenced plan file's status/checklist in sync with reality after
  every run (the MT-010 staleness lesson).
- **No direct Azure DevOps browser access.** Confirming the live state of `Federale_InternalRelease`
  (e.g. whether a PR merged, what `main` currently contains) relies on the user sharing a screenshot or
  on local git commands against the real remote — never assume a cached/local view is current.

## Relevant files (today's artefacts to promote into the repo, per the design above)
- `E:\Repos\release_candidates\release20261002-rc.01\1_ConvertedScripts\Generate-Release-Wrappers.ps1`
- `E:\Repos\SsgTrial\docs\_build-release.ps1` (scratch orchestrator → becomes `Build-Release.ps1`)
- `E:\Repos\SsgTrial\docs\_mock-install-test.ps1` + `E:\Repos\_mock_amt_install\Scripts\Libraries\
  AmtPsEclLib.psm1`/`AmtPsSortLib.psm1` (scratch mock harness → becomes `Mock-Install-Dryrun.ps1` +
  tracked mock libs)
- `E:\Repos\release_candidates\release20261002-rc.01\{README.md,RELEASE-NOTES.md,VALIDATION-PROMPT.md}`
  (today's instance → becomes the templates)
- Existing precedent: `SsgConverter/Trials/Build-AMT172HandoffBundle.ps1` (MT-010's assembler, same
  "repeatable, idempotent" pattern to follow)
- Tracker: [docs/SSG-PowerShell-Trial-Progress.html](../../docs/SSG-PowerShell-Trial-Progress.html)
  §7 (`MT-017`)
