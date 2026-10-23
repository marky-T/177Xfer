---
title: "MT-025 — Single-job live-batch runner for many SSG programs (flat file list)"
date: "2026-10-06"
status: "PLANNED (rev 2, 2026-10-06) — architecture decided; watchdog + observability added after review. One empirical test (Phase 0) needed before build."
owner: "MT"
area: "D (real runtime) — new orchestration capability, building toward a future select/convert/test/release/install pipeline"
---

# Plan: MT-025 — live-batch runner

## Context / ask

Immediate ask: **one** Control Center job registration that, when started, runs a **flat file list**
of program keys through a real, live `-LIVE.ps1` execution each — "the same job repeats for each
script" — rather than registering/clicking Start Job 20 separate times. Failures should not need a
bespoke handler per failure type: just **record that it happened** (a message) into **a log file**,
and keep going to the next program. This is explicitly step 1 of a larger end-goal (not built now):
an automated **select → convert → test → release → install** pipeline, where "a live run of one
program with mocked-file-proof" is a gate inside that pipeline. Today's scope is only the
multi-program live-execution runner piece.

## Decisive finding: why "one shared process, try/catch per program" is NOT viable

Checked whether a single long-running PowerShell process could call `Initialize` **once**, then loop
calling each program's body directly, wrapping each call in `try/catch` to survive a failure and
continue to the next program (this would avoid N separate DB connections). **This does not work,
confirmed by reading `AmtPsEclLib.psm1` directly, not by assumption:**

- `Abort` (the real AMT function) unconditionally calls `Cleanup $true`, which **always ends in a hard
  `Exit 0`/`Exit 1`** (`AmtPsEclLib.psm1` ~L3076-3220). `Exit` terminates the **entire process** — it
  is not a .NET exception, so **no `try/catch` at any scope can stop it**.
- `Abort` is called directly from **166+ call sites inside `AmtPsEclLib.psm1` itself** for entirely
  ordinary runtime conditions a converted report can legitimately hit — file not found, invalid print
  option, invalid SGS option, etc. (grep confirmed; none of the 20 converted bodies call `Abort`
  directly themselves, but the **library functions the bodies call** do, routinely).
- Net effect: if program #7 of 20 hits any one of these ordinary conditions, the **whole batch process
  exits immediately** — losing the results for programs #8-20 — regardless of any try/catch we add
  around the body call.

**Conclusion: each program MUST run in its own OS process.** One failing program's `Exit` then only
kills its own child process; the parent orchestrator (and the rest of the list) is unaffected. This
also means the orchestrator does **not** need to duplicate any `Initialize`/SGS-seeding logic — it
can simply invoke the existing, already-fixed, already-individually-proven `<KEY>-LIVE.ps1` wrapper
files unchanged, each as its own process.

## Architecture (recommended: Option B)

```
Control Center "Start Job" (one registration, e.g. T3_RunLiveBatch)
        |
        v
Run-LiveBatch.ps1  (the orchestrator — this plan's new deliverable)
        | reads a flat file list of program keys
        | for each key, in order:
        |   - Start-Process pwsh -File <KEY>-LIVE.ps1 (its OWN process, own Initialize/Fin, own
        |     Set-Jobname) -RedirectStandardOutput/-Error to a per-program capture file
        |   - wait for it, record exit code + duration
        |   - on nonzero exit: look up KnownIssues.json[key] for a friendly note if one exists;
        |     otherwise just record the raw captured error text verbatim - no bespoke handling
        |   - append one line to progress.log (so a human can `Get-Content -Wait` it live)
        |   - continue to the next key regardless of outcome
        v
LiveBatchRuns\<yyyyMMdd-HHmmss>\{progress.log, results.csv, <KEY>.out.txt, <KEY>.err.txt (x20)}
```

### Why this reuses, not duplicates, everything already built
- The per-program `<KEY>-LIVE.ps1` files are untouched — same ones already deployed, same
  `Set-Jobname -> Initialize -> seed SGS -> & body -> Fin` skeleton, same MT-023 `Write-JobLog` fix.
  No SGS-flattening logic needs to be re-implemented or kept in sync (avoids a second T3-012-class
  drift risk).
- `KnownIssues.json` (already exists, already used in release notes) **is** the "stubbed error
  messages we'll build up as errors occur" table the ask describes — no new mechanism needed, just a
  lookup at result-recording time. An unmatched failure just carries its raw error text; add an entry
  to `KnownIssues.json` later if/when it recurs, rather than writing a handler now.
- Output capture mirrors the existing Tier-1 harness convention (`out/<Program>.out.txt` /
  `.error.txt`) for consistency with how results are already inspected elsewhere in this repo.

### MT-023 lesson applied to the orchestrator itself
The orchestrator is **also** a CC Script job — it must not repeat the MT-023 bug on itself. It must
**never** write to the console (`Write-Host`) for its own progress; everything goes to `progress.log`
on disk. This also means the orchestrator does **not** need `Initialize`/`Write-JobLog` for itself at
all (it never touches the DB directly) — simpler than the per-program wrappers, not a smaller version
of them.

### List selection (kept deliberately simple for v1)
No dependency on how Control Center's "Commandline (script) parameter" field reaches the script (that
channel has never been used by anything in this repo and its exact passing mechanism — argv vs an
`AMT*` env var — is unconfirmed). V1 reads from **one well-known default flat file**
(`RunList.txt`, sitting next to the orchestrator, one `<KEY>` per line, blank lines and `#comment`
lines ignored). To run "all 20" vs a selected subset: **edit that file's content** before clicking
Start Job. A later, optional enhancement (not v1) could explore the CC parameter channel to avoid the
file-edit step — flagged as a nice-to-have, not a blocker.

## Open item requiring one empirical test before relying on this for a full unattended 20-program run

**Does a `pwsh.exe` child process spawned *from inside* an already-BatchController-hosted script count
as a "supported host" for `Connect-Application`**, or does it behave like the documented "bare pwsh is
not a supported host" case (T3-013/MT-005's original, narrower finding — about a *desktop-launched*
bare pwsh, never tested for a *child-of-a-hosted-process* pwsh)? This is answered in minutes, not
guessed:

**Phase 0 test:** register the orchestrator as a CC job, give it a `RunList.txt` containing just
`CFH-COPY`, Start Job, confirm the child process reaches `Script Done` / exit 0 exactly like a direct
Start Job does. If it does not, fall back to **Option A**: drive each program via the AMT Control
Center **REST API** (`Start Job` + poll status per key) instead of raw child processes — this
guarantees each run takes the exact, already-proven BatchController path (indistinguishable from a
human clicking Start Job), at the cost of exploring/building against that API (auth, start/poll
endpoints — unexplored in this repo so far, `REST API Consumables`/`REST API Providers` tabs exist in
CC but haven't been used). Not needed unless Phase 0 fails.

## Build phases

1. **Phase 0 (empirical, ~10 min):** the host-support test above, with just `CFH-COPY`. Gate for
   everything else.
2. **Phase 1:** `Run-LiveBatch.ps1` — reads `RunList.txt`, loops, spawns children, captures
   stdout/stderr per program, writes `progress.log` + `results.csv`, looks up `KnownIssues.json`.
   Keep it in the repo (`SsgConverter/Trials/Release/` alongside the other release tooling, or a new
   `SsgConverter/Trials/LiveBatch/` folder — TBD, lean toward a new folder since this is a distinct
   capability from the release-build tooling) so it ships with future releases rather than being a
   one-off script.
3. **Phase 2:** deploy the orchestrator alongside the existing wrappers (`Scripts\SSGTRIAL\RUN\`, same
   2-folders-below convention) and register it once via Read-all-jobs-from-system.
4. **Phase 3 — controlled test run:** `RunList.txt` with **3 programs**: one known-good
   (`CFH-COPY`), one with a documented live seed gap (`FUSBA_ASCII`, per RELEASE-NOTES — a genuine,
   expected failure), and one more known-good after it. Confirms both success recording AND that a
   failure genuinely does not stop the batch, using a real, already-understood failure rather than an
   artificial one.
5. **Phase 4 — full rollout (also the BASELINE run):** `RunList.txt` with all 20, unattended, with
   watchdog thresholds set deliberately generous (see below). Review `results.csv` + `progress.log`
   together with per-program `.out/.err` captures and harvested joblogs for anything unexpected.
   **This run's recorded elapsed/CPU per program becomes the baseline table** used to set real
   per-program thresholds for subsequent runs.
6. **Phase 5:** fold findings into the tracker (new `T3-nnn` for any newly-discovered failure,
   `KnownIssues.json` updates for recurring ones) and close MT-025.

---

# Review additions (rev 2) — watchdog & observability

Two requirements added on review: (a) detect and kill a program that is **burning disproportionate
CPU** for the mock files supplied, or is **doing nothing** (high elapsed, no progress); (b) emit
**progress messages** showing where a program opened files, touched the DB, or accepted input.

## First — three risk assumptions CHECKED against the code (not assumed)

Before designing watchdog rules, I verified what can actually hang or run away. Two expected risks
turned out to be **non-risks**, which changes where the watchdog effort should go:

| Checked | Finding | Verdict |
|---|---|---|
| Do any bodies call the blocking `Accept` (operator input)? | 3 textual hits across `ARCHIFORMAT`/`ARCHISEPARE`, but **all are COBOL text being generated**, not PowerShell calls — 2 are `# Orphaned data line:` comments, 1 is a string inside `DataLineOrNoStatement("... accept date-i from date yyyymmdd ")`. **No body calls the real `Accept` function.** | ❌ not a hang risk |
| Does `Call-ExternalProgram` spawn real child processes? (48 call sites across 19 of 20 bodies — `ucob`, `MAP`, `ACOB`) | **It is currently a dummy no-op.** Its own docstring says *"Does not do anything yet"*; the body is just `Add-InformationMsg "Ipf call to $Filename skipped."` with the real `Start-Process` line **commented out** (`AmtPsEclLib.psm1` L13966+). | ❌ no child processes today — but see note |
| Can a converted body loop forever? | **Yes — this is the real runaway risk, and it has precedent.** `T3-009` was exactly a mismatched `For` loop declare/condition in converted output. Bodies also contain **4 508** `DataLineOrNoStatement` call sites, so a bad loop can also generate unbounded output. | ✅ genuine — watchdog justified |

**Net:** the watchdog is justified, but for **converted-code loop defects**, not for operator input or
external programs. Design for that primarily — while keeping the kill implementation tree-safe anyway,
because that commented-out `Start-Process` is clearly intended to be enabled later, and the watchdog
shouldn't silently become wrong the day it is.

## Watchdog design

Sequential execution means the orchestrator can simply poll the one active child.

**Per-program limits**, resolved in this order: `RunList.txt` inline override → `BatchConfig.json`
per-program entry → global default.

| Signal | Meaning | Default (first run) |
|---|---|---|
| `MaxElapsedSec` | hard wall-clock cap, any cause | generous (e.g. 600) |
| `MaxCpuSec` | cumulative `TotalProcessorTime` cap | generous (e.g. 300) |
| `StallSec` | no *progress* (see below) for this long | e.g. 120 |

**Classification on kill** — record *which* rule fired, so the result is diagnostic rather than just
"failed":
- **`KilledRunaway`** — CPU time ≈ elapsed time (sustained ~1 core busy) and a cap was hit → suspect
  an infinite loop in converted output (the T3-009 class of defect).
- **`KilledStalled`** — elapsed grew but **CPU barely moved AND no progress signal** → suspect a
  blocking wait (DB, file lock, network).
- **`KilledTimeout`** — `MaxElapsedSec` hit without matching either pattern cleanly.

**Progress signal for stall detection (no body modification needed):** the per-program joblog file
(`Basepaths\Logs\<yyyymmdd>\T3_20_<KEY>_LIVE_*.log`) is written continuously by the runtime. The
orchestrator samples its **size + LastWriteTime** every few seconds. Growing = alive and progressing;
static for `StallSec` while CPU is also flat = genuinely stalled. This gives "is it doing anything?"
for free, without instrumenting the converted bodies at all.

**Thresholds cannot be set correctly before the first run — and the plan says so.** There is no
existing per-program live timing data (Tier-1 timings are not comparable: different host, mocked SGS,
no DB). So: Phase 4 runs with deliberately generous caps purely to *collect* elapsed/CPU per program,
and those real numbers then populate `BatchConfig.json` for subsequent runs (e.g. cap ≈ 3× observed
baseline). Anything else would be guessing a number and calling it a threshold.

**Kill implementation:** `taskkill /T /F /PID <pid>` (tree kill) rather than `Stop-Process`, for the
forward-compatibility reason above. Verify the process actually exited before moving on; if it does
not, record `KillFailed` and **stop the batch** — continuing past a process we failed to kill risks
the next program contending with it.

> ⚠ **Honest caveat that must be recorded with any kill.** A killed program never reaches `Fin`, so
> `Cleanup` never runs: COM objects are not disposed, the joblog handle is not closed,
> `RemoveNonPrintedFiles` is not called, the temp folder is not deleted, and assigned files are not
> released. A `Killed*` result therefore means **the environment may be left dirty**, and later
> programs in the same batch could be affected by that residue. The orchestrator must flag this
> prominently in `progress.log`/`results.csv` (not treat a kill as a clean "failed" result), and any
> batch containing a kill should be treated as suspect rather than authoritative. Whether a service
> restart is needed after a kill is **unverified** — worth testing once deliberately rather than
> assuming either way.

## Observability — progress messages (file opens, DB, inputs)

### The large free win: turn on Debug logging
`Write-JobLog` gates every message on `if ($Severity -le $global:LoggingSeverity)`, and the enum is
`Error=0, Warning=1, Info=2, Debug=3` (`AmtPsEclLib.psm1` L397). The live
`AmtSettings.xml` currently sets `<LoggingSeverity>Info</LoggingSeverity>` — so **28 existing
Debug-level log points in the runtime are being suppressed today**. Setting it to `Debug` unlocks
exactly the visibility asked for, with **no code changes anywhere**:

| Already-present Debug log point | Gives us |
|---|---|
| `Found assigned file : <name>` (L2676); usename→full-path mapping (L6954, L6964) | **where it opened files** |
| `File-Exists: <file>, result:` (L2529); `Create-Folders:` (L2038, L2052) | file probing / folder creation |
| `:::: <Statement>` and `<Statement>` (L5579, L5583); `Skipped <Statement>` (L5575) | **ECL statement-level trace — where it got to** |
| `Start SSG` / `End SSG` (L10706, L10768) | SSG generation phase boundaries |
| `GetJobNumber`, `GetRequestId`, `GetBatchId`, `GetInitiatingUser` (L1653-1742) | job/DB context establishment |
| `SW<n> T/F` (L7237-7240); `Get-JobValue` (L2886); `Get-CompletedOK` (L3421) | switch + task state |

Already visible at `Info` today (confirmed in the real CFH-COPY joblog): `Script Started`,
`[Sort-Init] Initializing Sort`, `Ipf call to <X> skipped.`, `FIN`, `End Job`, `Script Done` — so
**external-program call attempts are already logged** even though they're no-ops.

Make it a **per-batch toggle** (`-Verbose`-style switch writing the setting, restored afterward), not
a permanent change: Debug logging will substantially increase joblog size, and the 4 508
`DataLineOrNoStatement` sites mean statement tracing can be voluminous on the bigger programs.
Decision deferred to implementation: either point the batch at its **own copy** of `AmtSettings.xml`
(cleaner — no mutation of shared config, and the wrapper already supports `AMT_SETTINGS`) or
temporarily edit and restore the shared one. **Prefer the own-copy approach** — it avoids touching
shared config that other jobs depend on, and sidesteps restoring state if the batch is interrupted.

### Harvest, don't re-instrument
The runtime already writes a complete per-program joblog. The orchestrator should **copy each
program's joblog into the batch results folder** at the end of that program (resolving it by the
`Set-Jobname` value `T3_20_<KEY>_LIVE`), so one results folder holds everything for a run. Writing new
instrumentation into the converted bodies is explicitly rejected — they must stay pristine converter
output (and a parallel instrumentation path would drift, the same way T3-012 drifted).

### Orchestrator-level heartbeat
Every poll interval, append a heartbeat line to `progress.log`:
`<timestamp> <KEY> elapsed=<s> cpu=<s> joblog=<bytes> state=<Running|Stalled?>`.
This gives a live "where is it now" view (`Get-Content -Wait progress.log`) and, critically, leaves a
**record of how far it got** even for a program that is later killed — otherwise a killed run tells
you nothing about where it died.

## Revised results schema

`results.csv` per program: `Key, StartTime, EndTime, ElapsedSec, CpuSec, ExitCode, Outcome, Rule,
JobLogBytes, KnownIssue, ErrorSummary` — where `Outcome` ∈ `Ok | Failed | KilledRunaway |
KilledStalled | KilledTimeout | KillFailed`, and `Rule` names the threshold that fired (empty for
clean runs). Keeping CPU/elapsed for **successful** runs too is what makes the baseline table
possible.

## Revised phase additions
- **Phase 1** additionally implements: polling loop, the three limits, classification, tree-kill,
  joblog harvesting, heartbeat lines, `BatchConfig.json`.
- **Phase 3** additionally verifies the watchdog *fires correctly* — rather than waiting to discover
  it on a real defect, add a deliberate throwaway test entry (a tiny script that spins forever) to
  confirm `KilledRunaway` triggers, is recorded, and the batch **continues** to the next program.
  Testing the safety net on a known input is the only way to know it works.
- **Phase 4** is explicitly the **baseline-collection** run (see above).

## Still out of scope (unchanged)
The wider select/convert/test/release/install pipeline; mocked-file-proof as an automated gate; CC
REST API exploration (only if Phase 0 fails); parallel execution.


## Relevant files
- Existing, unchanged, reused as-is: `AmtTools\Basepaths\Scripts\SSGTRIAL\RUN\<KEY>-LIVE.ps1` (all 20)
- Existing, reused as-is: `SsgConverter/Trials/Release/KnownIssues.json`
- New: `Run-LiveBatch.ps1`, `RunList.txt` (default list)
- Precedent for output-capture convention: `SsgConverter/Trials/Tier1Mock/Run-SsgPsTrial.ps1`
  (`out/<Program>.out.txt`/`.error.txt`)
- Root cause this design is built around: `SsgConverter/Trials/RealRuntime/AmtPsEclLib.psm1`
  (`Abort`/`Cleanup`, ~L3076-3220)
- Tracker: `docs/SSG-PowerShell-Trial-Progress.html` §7 (MT-025, this plan)
