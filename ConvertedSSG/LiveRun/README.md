# T3 Live Tier-3 Run — Results (AMT172, 2026-09-30 / 2026-10-01)

Shared back from AMT172 to AMT177/178 after running the 20-program `T3ConvertedSSG-20` bundle as
**genuine Tier-3 jobs** (real `Connect-Application`, real CC Start Job / BatchController pipeline) —
the first time any program in this bundle has been run that way on either side of the handoff.

Everything in `Programs/`, `manifest.json`, `DiscDesignators.json`, `GoldenReconciliation.json` is
unchanged from the original handoff. This folder (`LiveRun/`) and the two modified `RealRuntime/`
files are the only additions from this round.

## TL;DR

- **18 of 20 programs: DONE**, confirmed twice — once standalone (`pwsh -ExecutionPolicy Bypass`)
  and once again through the **real CC → Start Job → BatchController pipeline** (not a mock harness).
- **2 of 20 programs still fail** (`EXTEUR`, `FUSBA_ASCII`) — identically in both standalone and CC
  runs, confirming these are genuine per-program data/seed issues, not pipeline/runtime bugs.
- **2 root-cause bugs found and fixed** in the shared runtime (see below) — both are likely present
  in the AMT177/178 environment too, since they're generic to how the bundle is structured, not
  AMT172-specific.

## What is the "wrapper" pattern?

Every program in the bundle (`Programs/<KEY>/script.ps1`) is **body-only** SsgConverter codegen —
it calls runtime functions like `GetSgsValue`, `DataLineOrNoStatement`, `CompareTypeSafe`,
`Process-Skip`, but has no job-control shell around it (no `Connect-Application`, no `Fin`). It's
designed to be *called*, not run standalone, so as-is it can't be registered as a real CC job.

A "wrapper" (`<KEY>-LIVE.ps1`, see `Wrappers/`) is a small script supplying exactly that missing
shell, following the standard AMT ECL job pattern:

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

The wrapper never touches or duplicates the body script's logic — it just gives it a real AMT
session and pre-populates the SGS values the body reads via `GetSgsValue`, exactly as CC's own
`StartSSG` job-control would in production. `CFH-COPY-LIVE.ps1` and `HelloWorld-LIVE.ps1` were
hand-written; the other 19 were generated mechanically by `Generate-T3-Live-Wrappers.ps1`, which
converts each program's already-known `Tier1Mock/sgs-values/<KEY>.sgs-values.json` (the same
parameter values already proven correct for the Tier-1 mock-shell run) into the matching
`AddTo-SgsList` lines — so every wrapper's SGS seed is derived from data already known to be
correct for that program, not guessed.

## Two root-cause bugs found and fixed

### 1. Zone.Identifier / execution-policy block (generic — affects every script, any content)

**Symptom:** any script run via a real CC Start Job (not a bare interactive `pwsh` session) failed
with a confusing cascading error — `Abort: You cannot call a method on a null-valued expression` at
`AmtPsEclLib.psm1:3390`, plus `Could not write to the Windows Event Log: Unable to find type
[Asysco.Amt.Libs.Support.AmtEventLog]`. This reproduced even on the **trivial Hello World skeleton**
with no SsgConverter body at all, proving it was never program-specific.

**Root cause:** `RealRuntime/EclOptions.psm1` carried a **Zone.Identifier** (mark-of-the-web NTFS
alternate-data-stream) from being copied in from another folder. A bare `pwsh -ExecutionPolicy
Bypass` session ignores this, but **BatchController launches scripts without that override**, so
the default PowerShell execution policy blocked the file as "not digitally signed" — that is the
*real* first error. The `Abort`/event-log/null-valued-expression messages are just the `Trap`/
`Abort` error handler cascading while trying (and failing) to log that first error — a red herring.
This real first error is only visible in the **main** `AmtBatchController_Trace.Log`, not the
per-job `_AGENT_` trace log, and no job log file gets written at all when this happens.

**Fix:** `Unblock-File` on every `.psm1`/`.ps1` under `RealRuntime/` and `Binaries/Scripts/`
(`Get-Item -Stream Zone.Identifier` to check; `Unblock-File` to clear). Worth checking the
AMT177/178 side for the same issue — any file transferred/copied between machines or folders on
Windows can pick up this stream.

### 2. Missing `Log-Message` function (affects CONDIS2_ASCII, TABAN_ASCII, RECAP, TAPELD_ASCII)

**Symptom:** `The term 'Log-Message' is not recognized as a name of a cmdlet, function, script
file, or executable program.`

**Root cause:** SsgConverter emits diagnostic calls like
`Log-Message ("...") '([LogMessageType]::Information)'` in several programs, but no implementation
exists anywhere in the bundled runtime. Note the second argument arrives as the **literal string**
`"([LogMessageType]::Information)"` — not an evaluated enum — apparently an SsgConverter quoting
quirk, so any stub must accept `[string]`, not a real `[LogMessageType]` type.

**Fix:** added a minimal no-op stub to `RealRuntime/AmtPsCustomerLib.psm1` — already the bundle's
designated empty customer-extension module (the comment at the top of that file literally says
"the extension point for customer-specific functions"), auto-imported by `AmtPsEclLib.psm1`:

```powershell
function Log-Message {
  param([string]$Message, [string]$Level = '')
  Write-Host "[Log-Message] $Message $Level"
}
```

## Full per-program results

| Program | Standalone (`pwsh -ExecutionPolicy Bypass`) | Real CC Start Job | JOBID | Notes |
|---|---|---|---|---|
| CFH-COPY | PASS | DONE | 1060 | First breakthrough |
| (Hello World isolation test) | PASS | DONE | 1061 | Proved the Zone.Identifier issue was generic |
| ARCHIFORMAT | PASS | DONE | 1062 | |
| ARCHISEPARE | PASS | DONE | 1063 | |
| BABA_ASCII | PASS | DONE | 1064 | |
| CFH-COPY_ASCII | PASS | DONE | 1065 | |
| CHAB100_ASCII | PASS | DONE | 1066 | |
| CHABAN_ASCII | PASS | DONE | 1067 | |
| CONDIS2_ASCII | PASS (needed Log-Message fix) | DONE | 1068 | |
| EXTEUR | **FAIL** | **FAIL** (identical error) | 1069 | `Cannot convert value "NONE" to type "System.Int32"` at line 158 — SGS seed issue |
| FUSBA_ASCII | **FAIL** | **FAIL** (identical error) | 1070 | `Cannot index into a null array` in `Define_limpara` at line 50 — SGS seed issue |
| FUSBA2_ASCII | PASS | DONE | 1071 | |
| LECTIS_ASCII | PASS | DONE | 1072 | |
| LOADIS_ASCII | PASS | DONE | 1073 | |
| LOADIS_MULTI | PASS | DONE | 1074 | |
| RECAP | PASS (needed Log-Message fix) | DONE | 1075 | |
| SCAN_ASCII | PASS | DONE | 1077 | |
| TABAN_ASCII | PASS (needed Log-Message fix) | DONE | 1078 | |
| TAPELD_ASCII | PASS (needed Log-Message fix) | DONE | 1079 | |
| UNLOADIS_ASCII | PASS | DONE | 1080 | |
| UNLOADIS_MULTI | PASS | DONE | 1081 | |

CC "Status" column note: for TYPE=1 Script jobs, CC sometimes shows **Error** even when
`ExitCode=0` and the job log is clean — it appears to flag any captured `Write-Host`/console output
as "Error" regardless of severity. Don't trust the Status column alone; check `ExitCode` and the
job log under `Files\Logging\<date>\<JobName>_*.log`.

## Remaining open issues (not pipeline bugs — need a closer look at these two programs specifically)

- **EXTEUR**: one of the SGS values converted from `Tier1Mock/sgs-values/EXTEUR.sgs-values.json` is
  the literal string `"NONE"` where the script expects a real integer default at line 158. Needs a
  program-specific override in the seed, not a runtime fix.
- **FUSBA_ASCII**: `Define_limpara` at line 50 indexes into an array that isn't populated by the
  generic seed conversion — needs a closer look at what shape of SGS value that function actually
  expects (may need an occurrence/array-style seed rather than a scalar).

## Files in this folder

| File | Purpose |
|---|---|
| `Generate-T3-Live-Wrappers.ps1` | Reads each program's `Tier1Mock/sgs-values/<KEY>.sgs-values.json` and mechanically generates the matching `<KEY>-LIVE.ps1` wrapper into `Wrappers/`. |
| `Wrappers/*.ps1` | All 21 wrapper scripts (20 programs + the Hello World isolation test) — the actual files registered and run as CC jobs. |
| `Run-All-T3-Live-Standalone.ps1` | Batch-runs all wrappers via bare `pwsh` for a fast pass/fail pre-check before registering as CC jobs. |
| `Run-T3-CFH-COPY-Live.ps1` / `Run-T3-HelloWorld-Live.ps1` | The two hand-written wrappers (source of truth the generator's output pattern was based on). |
| `AmtSettings-AFBUS2200COBOL.xml` | Working `AmtSettings.xml` proven against AMT172's `AFBUS_2200COBOL` app — field-by-field reference for building your own. |
| `Register-T3-20-Scripts.sql` / `Register-T3-20-Live-Wrappers.sql` | SQL used to register the body scripts and the live wrappers as `AMTSYSAVAILABLEJOB` (`TYPE=1`, "Script" job) CC jobs on AMT172. |

Related reference doc (not in this repo): `SSG-ECL-PowerShell-Reference.html` §6c on the AMT172 side
has the full narrative write-up with this same table, plus screenshots-equivalent detail for every
program already covered by the Tier-1 mock-shell work.
