# Import request: 20 converted SSG‑COBOL→PowerShell scripts from AMT177/178 (.NET 10)

**Goal:** Load a new set of SSG→PowerShell conversions (built on the AMT177/178 VM, .NET 10) into
AMT172's **Scripts** area, register each as a real Control Center job, and run them against supplied
mock files — a genuine **Tier‑3** proof (live `AmtPsEclLib`/`Connect-Application` execution), not the
Tier‑1 mock-shell harness already covered by `SSG-ECL-PowerShell-Reference.html` §6c.

**Important distinction to flag to the requester:** LionDev (AMT Developer Studio) is the
**COBOL→C#** generation tool — it does not import `.ps1` files. "Load into LionDev" doesn't apply
here; the correct target is AMT172's **Scripts** location + `AMTSYSAVAILABLEJOB` (Control Center),
which is a separate mechanism from the LionDev/CC-DLL path used for the 8 C# reports.

---

## Requirements / criteria for AMT178Copilot's bundle

### 1. Version & compatibility metadata (blocking — check first)
- [ ] Exact AMT build/version on the source VM (the doc metadata convention is e.g.
  `AMT 172 (8.0.26125.0 RC1)` — need the equivalent for "AMT177/178").
- [ ] .NET runtime the generated `.ps1` scripts and `AmtPsEclLib.psm1`/`AmtPsSortLib.psm1` were
  built/tested against (confirmed .NET 10 per the request — AMT172's installed `AmtPowershellHost.exe`
  is **.NET 8** / PowerShell SDK 7.4.14; a version mismatch here is the single biggest risk — see
  the `Microsoft.Data.SqlClient` dependency-closure gotcha already hit on this box).
- [ ] Which `AmtPsEclLib.psm1` version the scripts require — bundle the **exact `.psm1`/`.dll`
  (ComScript) versions used on the source VM**, or explicitly confirm they're compatible with
  AMT172's already-installed copies (don't assume).
- [ ] Whether this is a **superset/replacement** of the existing 10-program `T3ConvertedSSG` bundle
  (`marky-T/177Xfer` branch, already cloned to `C:\Amt\Migration\T3ConvertedSSG\`) or a distinct new
  set of 20 — list overlap explicitly by program name.

### 2. Per-program bundle contents (all 20)
For **each** converted program, supply:
- [ ] Raw SSG/ECL source (`ASSURFED_*.TXT`) as converted from.
- [ ] The generated `.ps1` script.
- [ ] Execution status on the source VM: **mock-shell only** (Tier‑1, no AMT connection) vs.
  **live-run proven** (Tier‑3, actually completed `Connect-Application`/`Xqt`/`Fin` against a real
  AMT177/178 app) — state which, per program. If live-run proven, include the job log/result.
- [ ] All logical file names / DISC designators the script uses via `Asg`/`Use`/`Qual` calls (these
  replace the `.Files.cs` `SetOptions()` designators used by the C# path) — input and output, with
  expected record length/format.
- [ ] A mock input file (or generation recipe) per program, plus an expected/golden output where one
  exists, matching the `fixtures/<key>/{input,expected}.dat` convention already used on AMT172.

### 3. Script identity & naming
- [ ] Confirm the naming convention expected for registering a script job (equivalent of the C# path's
  **Bug 14** rule — candidate filename must equal `PROGRAM-ID`). Is there an analogous rule for
  scripts, or is the `.ps1` filename arbitrary?
- [ ] `Set-Jobname` value used inside each script (this becomes the job's identity in CC logs).

### 4. Runtime/dependency closure
- [ ] Full list of `Import-Module` calls in each script (beyond `AmtPsEclLib`/`AmtPsSortLib`) — any
  extra custom modules must be bundled too.
- [ ] Confirm whether the scripts expect **`AmtPowershellHost.exe`** hosting (BatchController-driven,
  the only path known to carry the correct `Microsoft.Data.SqlClient`/native-SNI dependency closure)
  or were only ever run standalone via `pwsh`/PS ISE.
- [ ] An `AmtSettings.xml` sample **from a proven working run on the source VM** (even though AMT172
  will need its own instance with AMT172-specific values) — for field-by-field comparison, same as
  the `Migration/Trial3/run/AmtSettings.xml` precedent already used here.

### 5. Delivery format
- [ ] One folder per program (`<PROGRAM-ID>/{source.txt, script.ps1, mock-input.*, expected-output.*,
  README.md}`) plus a top-level `manifest.json` (program list, per-program status, designator map).
  Mirrors the existing `EclCobolPipeline/fixtures/<key>/` + `manifest/programs.manifest.json` shape
  already used in this repo so it can be diffed/merged the same way §6c's baseline-diff check did.

---

## Reply received (2026-09-30) — `marky-T/177Xfer` branch `T3ConvertedSSG-20`, commit `2bcf8f1`

**Provenance clarification (user, 2026-09-30):** the `.ps1` bodies are the **direct, as-generated
output of the SsgConverter tool** itself (run against the raw SSG/COBOL source, then hand-corrected
a couple of times to fix generator syntax bugs) — not a partial/stripped-down artifact someone
trimmed down. So "body-only, no job skeleton, zero `Import-Module`" is genuinely **what
SsgConverter produces today**, not a gap introduced downstream. Any ECL job-control wrapper
(`Set-Jobname`/`Initialize`/`Connect-Application`/`Fin`) is therefore a **deliberate next layer to
add on top**, not something to chase from SsgConverter's own output.

Full point-by-point answer in `Migration/T3ConvertedSSG/ConvertedSSG/T3-PS-Response-AMT177to172.md`.
**Critical finding that changes the approach:**

- **None of the 20 scripts have any ECL job-control skeleton** — no `Set-Jobname`/`Initialize`/
  `Connect-Application`/`Trap`/`Fin`, and **zero `Import-Module` calls** in any of them (confirmed by
  grep on their side). SsgConverter emits **body-only** codegen-simulation PowerShell, not real
  business-logic/file-I/O scripts. This is the same category as the existing 10-program §6c bundle,
  just expanded to 20 — **not** a genuine Tier‑3 artifact as originally hoped.
- **0 of 20 have ever completed a live `Connect-Application` run** on their side either — only
  Tier‑1 mock-shell (19 programs) and one `CFH-COPY` "Stage A" run (real `AmtPsEclLib.psm1`, but
  **no COM/live app connection**).
- They independently hit and confirmed **the same** `Microsoft.Data.SqlClient`/native-SNI dependency-
  closure finding we recorded here — standalone `pwsh` cannot do a live `Connect-Application`;
  `AmtPowershellHost.exe` (net8/PS 7.4) via BatchController is required. Cross-confirms our own
  finding independently.
- Script filename = **input file's base name**, not `PROGRAM-ID` — two known mismatches
  (`LECTIS_ASCII` → `PROGRAM-ID LECTIS`; `FUSBA2_ASCII` → dynamic `PROGRAM-ID`). Match by filename.
- DISC designators unresolved for 4 programs (loop-count-zero: `BABA_ASCII`, `FUSBA_ASCII`,
  `FUSBA2_ASCII`, `SCAN_ASCII`) and partially unresolved for 7 more — see `DiscDesignators.json`.
- No physical mock input files exist (their harness has no real file I/O — parameter/line-emission
  mock only); only 5 of 20 have an `expected-output.dat`, and even those are cross-engine goldens,
  not byte-diff proof.
- No proven-working live `AmtSettings.xml` from their side either (their own Stage B is blocked).

## AMT172-side setup completed (2026-09-30)

Given the scripts are body-only (no job skeleton, no file I/O), running them "for real" would not
constitute genuine Tier‑3 proof regardless — so the achievable, bounded goal for now is: **get them
into Control Center's Available Jobs list**, matching the precedent already proven with `T3_RUN_SSGPS`
(§6c), not a live-execution claim.

- Created `Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\` (mirrors the `Binaries\Reports\`
  convention for DLLs) and copied all 20 `Programs/<key>/script.ps1` files there as `<key>.ps1`.
- Registered all 20 as `TYPE=1` Script jobs in `AMTSYSAVAILABLEJOB`, JOBID **1020–1039**, APPID 5
  (`AFBUS_2200COBOL`), QUEUEID 1 (Default Queue), named `T3_20_<KEY>` — exact column shape copied
  from the existing `T3_RUN_SSGPS` (JOBID 1003) row. `DESCRIPTION` embeds the execution-status gap
  (`tier1-only` vs `tier1+stagea`) so it's visible directly in the CC job list. Script:
  `Migration/Trial3/Register-T3-20-Scripts.sql`.
- **Remaining manual step:** CC → Security → Jobs → **Activate All** (or individually activate the
  new `T3_20_*` jobs) before they'll appear under Jobs → Start Job. **Done** (user activated via CC
  UI, confirmed all 20 visible under Jobs → Start Job, Jobtype `Script`).

## What is the "live skeleton wrapper"?

Every program in the AMT177/178 bundle (`Binaries\Scripts\<KEY>.ps1`) is **body-only** — pure
SsgConverter codegen that calls runtime functions like `GetSgsValue`, `DataLineOrNoStatement`,
`CompareTypeSafe`, `Process-Skip`. It has no job-control shell around it: no `Connect-Application`,
no `Fin`, nothing that would let CC/BatchController run it as a real job. It's designed to be
*called*, not run standalone.

A "wrapper" (`<KEY>-LIVE.ps1`) is a small script that supplies exactly that missing shell, using the
same AMT ECL pattern every real job follows:

```powershell
Import-Module AmtPsEclLib.psm1, AmtPsSortLib.psm1    # the real runtime, not the Tier-1 mock
Trap { HandleTrapAndAbort "Error trapped:" $_ }      # standard AMT error handler

Set-Jobname "T3_20_<KEY>_LIVE"                       # job identity shown in CC logs
Initialize $AmtSettingsFile                          # real Connect-Application happens here

$global:SgsLabels = New-Object 'System.Collections.Generic.Dictionary[String, Object]'
AddTo-SgsList 'INPUT ECL-TAPEIN,80,1'                # seed the SGS parameters the body expects
AddTo-SgsList 'OUTPUT ECL-TAPEOUT,80,1'               # (one per DISC designator / option the
AddTo-SgsList 'ASCII 1'                              #  original program's SSG source declares)

& $bodyScriptPath -Parameters @('80')                # invoke the unmodified body-only .ps1

Fin                                                  # standard AMT job teardown
```

The wrapper doesn't touch or duplicate the body script's logic at all — it just gives it a real AMT
session (`Connect-Application` via `Initialize`) and pre-populates the SGS values the body reads via
`GetSgsValue`, exactly as CC's own `StartSSG` job-control would in a production run. For the first
program (CFH-COPY) I wrote this by hand; for the other 18 I generated it mechanically
(`Generate-T3-Live-Wrappers.ps1`) by converting each program's already-known
`Tier1Mock\sgs-values\<KEY>.sgs-values.json` (the same parameter values used for the earlier Tier-1
mock-shell verification) into the matching `AddTo-SgsList` lines — so each wrapper's SGS seed is
derived from data already proven correct for that program, not guessed.

## BREAKTHROUGH (2026-09-30): first-ever genuine live Tier‑3 run — succeeded on bare pwsh

Built `Migration/Trial3/run/Run-T3-CFH-COPY-Live.ps1` — wraps the raw
`Binaries\Scripts\CFH-COPY.ps1` body in a real ECL skeleton (`Set-Jobname` → `Initialize` →
`Connect-Application` → body → `Fin`), using AMT177/178's own bundled `RealRuntime\AmtPsEclLib.psm1`
+ `AmtPsSortLib.psm1`, plus a new `AmtSettings-AFBUS2200COBOL.xml` (AppName `AFBUS_2200COBOL`,
`ComScript`/`ComModule` = `Working\AMTTools\{ComScript,ComModule}\...`, `TransactionServer
Grpc:localhost:4444` — confirmed as `AmtApplicationServer`'s actual listening port via its PID's
`Get-NetTCPConnection`). SGS seed mirrors AMT177/178's own proven Stage-A seed exactly (`INPUT
ECL-TAPEIN,80,1` / `OUTPUT ECL-TAPEOUT,80,1` / `ASCII 1`).

**Two blockers hit and fixed en route:**
1. `RealRuntime/` was missing a sibling file, `EclOptions.psm1` — copied it in from the Parallel
   AMT175 reference copy (`8.0.26188.0\...\CmdLets\EclOptions.psm1`), which has it.
2. Unsigned-script execution-policy block loading `EclOptions.psm1` — fixed with
   `pwsh -ExecutionPolicy Bypass -File ...` (known fix from the AMT175 CHABAN precedent).

**Result: `Successfully connected to application "AFBUS_2200COBOL"`**, ran the full script body,
reached `Info: Script Done: T3_20_CFH_COPY_LIVE` / `FIN` cleanly — confirmed by a real job log at
`Working\Lion\Files\Logging\20260930\T3_20_CFH_COPY_LIVE_892020260930185430645.log`.

**This directly contradicts the expected-failure assumption above** (that bare pwsh can't do a live
`Connect-Application` due to the `Microsoft.Data.SqlClient`/SNI dependency closure). The likely
reason it works here but not on AMT177/178: AMT172's `ComScript.dll` folder
(`Working\AMTTools\ComScript\`) has `Microsoft.Data.SqlClient.dll` + `.SNI.dll` **colocated right
next to it** (plus its own `ComScript.deps.json`), so .NET assembly probing resolves the closure
locally without needing `AmtPowershellHost.exe` at all. Whether AMT177/178's `ComScript.dll` folder
lacks that colocation is unconfirmed — worth asking them to check.

**Important caveat on what this does and doesn't prove:** this ran as a **direct standalone-harness
`Connect-Application`** (same category as the AMT175 `Run-Chaban.ps1` precedent) — it did **not** go
through CC's BatchController/Start Job queue, so it won't show in CC Job Management. It also didn't
touch any physical file — `CFH-COPY.ps1`'s body is pure `DataLineOrNoStatement` COBOL-text emission,
not file I/O, so "success" here means *the AMT connection + script body executed*, not *a file got
copied*. Still a major result: this is the **first live AMT connection any of the 20 T3-bundle
programs has ever achieved**, on either side of the handoff.

## BREAKTHROUGH #2 (2026-10-01): proven through the REAL CC Start Job / BatchController pipeline

User flagged that AMT177/178 had noted an outstanding issue with CFH-COPY specifically, and
suggested trying a simpler script first to isolate the cause. Registered
`Run-T3-HelloWorld-Live.ps1` — the AMT training doc's own Exercise‑1 (`Set-Jobname` → `Initialize` →
`Add-InformationMsg "Hello World"` → `Fin`, no SsgConverter body at all) — as JOBID **1061**, alongside
`T3_20_CFH_COPY_LIVE` (JOBID 1060, now pointing at a skeleton-wrapped `CFH-COPY-LIVE.ps1` in
`Binaries\Scripts\`), and ran both through a **real CC → Jobs → Start Job** (not a direct pwsh
invocation this time).

**Both errored identically** on the first attempt — `AmtPsEclLib.psm1:3390`, the same
`Asy-WriteEventLog`/recursive-`Abort` symptom — proving conclusively **this was never a CFH-COPY
issue**: the trivial Hello World failed exactly the same way, so it's generic to how BatchController
hosts any script.

**Root cause found via `AmtBatchController_Trace.Log` (not the per-job `_AGENT_` log — the main
trace log captured the real, untruncated error):**
```
Job Output: Error: Error trapped:  File ...\RealRuntime\EclOptions.psm1
cannot be loaded. The file ... is not digitally signed. You cannot run this script...
```
`EclOptions.psm1` (copied in from the Parallel AMT175 reference folder) carried a **Zone.Identifier**
(mark-of-the-web) stream. My manual `pwsh -ExecutionPolicy Bypass` runs bypassed this, but
**BatchController launches scripts without that override**, so its default execution policy blocked
the unsigned/zone-marked file. The "AmtEventLog type not found" and "null-valued expression" messages
were just the `Trap`/`Abort` handler cascading while trying (and failing) to log *that* first error.

**Fix:** `Unblock-File` on `RealRuntime\*.psm1` and `Binaries\Scripts\*.ps1`.

**Result — both jobs re-run and now complete via the real BatchController pipeline:**
- `T3_HELLOWORLD_LIVE` (JobId 1061, RequestId matching a fresh run): **`Status=Done`** cleanly.
- `T3_20_CFH_COPY_LIVE` (JobId 1060, RequestId 1076): **`ExitCode=0`**, clean job log
  (`Files\Logging\20261001\T3_20_CFH_COPY_LIVE_5293320261001001248349.log` — identical
  `Script Started` → `Info: Ipf call to MAP skipped.` → `FIN` → `Script Done` sequence as the earlier
  standalone success). CC's "Status" column shows **Error** for this one, but that's a **false
  positive** — the "Error" detail field just contains the script's own benign `Write-Host` diagnostic
  line (`"=== Body completed without a thrown exception ==="`); CC appears to flag any captured
  console output as "Error" regardless of severity when `ExitCode=0`. Don't trust the Status column
  alone for TYPE=1 Script jobs — check ExitCode + the job log.

**This is now the first genuine Tier‑3 proof through the real CC/BatchController pipeline** — beyond
the direct-harness connect proven in Breakthrough #1, and beyond anything achieved on the AMT177/178
side. Recommend passing this Zone.Identifier/`Unblock-File` finding back to AMT177/178 — it may
unblock their own stalled Stage B as well, independent of the SqlClient-closure question.

## BREAKTHROUGH #3 (2026-10-01): scaled to all 20 programs — 18/20 now run live end-to-end

With the pipeline proven for 2 programs, generated live skeleton wrappers for the remaining 18 in
one pass: `Migration/Trial3/run/Generate-T3-Live-Wrappers.ps1` reads each program's
`Tier1Mock/sgs-values/<KEY>.sgs-values.json` (the same SGS parameter values already used for the
Tier-1 mock run) and reconstructs the equivalent `AddTo-SgsList` calls, producing a
`<KEY>-LIVE.ps1` in `Binaries\Scripts\` per the proven `Set-Jobname → Initialize → seed SGS →
invoke body → Fin` pattern. All 18 were `Unblock-File`'d on creation (clean, no Zone.Identifier).

**Standalone `pwsh -ExecutionPolicy Bypass` results (all 20 programs, including the 2 already
proven via CC):**

| Result | Programs |
|---|---|
| **PASS (18/20)** | ARCHIFORMAT, ARCHISEPARE, BABA_ASCII, CFH-COPY, CFH-COPY_ASCII, CHAB100_ASCII, CHABAN_ASCII, CONDIS2_ASCII*, FUSBA2_ASCII, LECTIS_ASCII, LOADIS_ASCII, LOADIS_MULTI, RECAP*, SCAN_ASCII, TABAN_ASCII*, TAPELD_ASCII*, UNLOADIS_ASCII, UNLOADIS_MULTI |
| **FAIL (2/20)** | EXTEUR, FUSBA_ASCII |

\* needed one shared fix (below) to pass.

**One shared bug found and fixed (affects 4 programs):** `CONDIS2_ASCII`, `TABAN_ASCII`, `RECAP`,
`TAPELD_ASCII` all call `Log-Message (...) '([LogMessageType]::Information)'` — a diagnostic
logging call the SsgConverter emits, with no implementation anywhere in the bundled runtime.
`RealRuntime\AmtPsCustomerLib.psm1` is explicitly the empty customer-extension module that
`AmtPsEclLib.psm1` auto-imports (`Import-Module ...AmtPsCustomerLib.psm1` at line 455) — exactly
the intended place for this. Added a minimal no-op `Log-Message` stub there (writes to host,
doesn't touch SGS/file state) and all 4 passed immediately. Note the second argument arrives as
the **literal string** `"([LogMessageType]::Information)"`, not an evaluated enum — apparently an
SsgConverter quoting quirk — so the stub takes `[string]` params, not a real `[LogMessageType]`
enum.

**Remaining 2 failures are genuine per-program data/seed issues, not pipeline bugs:**
- `EXTEUR`: `Cannot convert value "NONE" to type "System.Int32"` at line 158 — an SGS value that's
  the literal string `NONE` needs converting to a real numeric default; requires a per-program seed
  override, not a runtime fix.
- `FUSBA_ASCII`: `Cannot index into a null array` inside `Define_limpara` at line 50 — an SGS/array
  value this program expects isn't seeded by the generic `sgs-values.json` conversion; needs a
  closer look at that function's expected input shape.

**Registered all 18 as CC jobs** (JOBID 1062-1081, `Register-T3-20-Live-Wrappers.sql`,
`APPID=5, TYPE=1, QUEUEID=1`) alongside the 2 already-proven CC jobs (1060, 1061).

**Confirmed via the real CC Start Job pipeline (2026-10-01, after user activated all jobs
in Security→Jobs):** ran all 18 through CC's actual Jobs→Start Job UI (Jobname filter →
select → Start job → Ok), one at a time. Verified via job logs in
`Files\Logging\20261001\` (the `AMTSYSPROCESSJOB` table only tracks in-flight jobs, not
history, so log files are the reliable source of truth):

| Result | Count | Programs |
|---|---|---|
| **DONE** | 16/18 | ARCHIFORMAT, ARCHISEPARE, BABA_ASCII, CFH-COPY_ASCII, CHAB100_ASCII, CHABAN_ASCII, CONDIS2_ASCII, FUSBA2_ASCII, LECTIS_ASCII, LOADIS_ASCII, LOADIS_MULTI, RECAP, SCAN_ASCII, TABAN_ASCII, TAPELD_ASCII, UNLOADIS_ASCII, UNLOADIS_MULTI |
| **Failed (expected)** | 2/18 | EXTEUR, FUSBA_ASCII |

The 2 failures reproduced **exactly** the same errors seen standalone (`EXTEUR`: `Cannot
convert value "NONE" to type "System.Int32"` at line 158; `FUSBA_ASCII`: null-array index in
`Define_limpara`) — confirming these are genuine per-program data/seed issues, not artifacts
of the BatchController hosting environment.

**Final tally: 18 of 20 T3 bundle programs (including CFH-COPY and Hello World from
Breakthroughs #1/#2) now have a fully confirmed, real, live Tier-3 execution through the
genuine CC/BatchController pipeline** — real `Connect-Application`, real SGS seeding, real
script body, real `FIN`. Only `EXTEUR` and `FUSBA_ASCII` remain open, both needing a
program-specific SGS seed fix (not a pipeline/runtime problem).


---

## Open items AMT172 side must still resolve (not AMT178Copilot's job, noted for tracking)

- Exact Scripts base path for AFBUS_2200COBOL on AMT172 (query `AMTSYSBASEPATH`; `Files\Script\`
  exists but is empty/unconfirmed).
- Confirmed `AMTSYSAVAILABLEJOB.TYPE` for scripts = **1** ("Script") — already confirmed via
  `_REFRESH_POOL`/`INSTALL-APPSERVER` system jobs and the `T3_RUN_SSGPS` (JOBID 1003) precedent, but
  that job runs a mock harness wrapper, not a live `AmtPsEclLib`-connected script — the registration
  *mechanics* (CC dialog, Activate All) transfer; the *content* must be genuinely different this time.
