# SSG-4 conversion process — SSG/ECL/COBOL source to a running C# program

One page for the whole chain, in order. Each step says **who or what** does it, the **inputs and outputs**, and where the
script lives. Decisions and evidence are in the
[epic](../.github/Copilot_Plans/261009-trial4-epic-strategy.md); defects and open items are in the
[tracker](../docs/SSG-PowerShell-Trial-Progress.html) (T3-nnn issues, MT-nnn ToDo). The one end-to-end worked example,
with checked-in results, is [WorkingExample-CFH-COPY_ASCII](Pipeline/WorkingExample-CFH-COPY_ASCII/README.md).

Status marks: **done** = proven on CFH-COPY_ASCII (real VIRM01 cards); **pending** = not built or not yet run.

## Run it (the driver)

`Pipeline/Invoke-Ssg4Release.ps1` runs the chain in two halves, with the LionDev step (manual) in the middle. Both stages stop on the
first failure and change nothing in Federale.

1. `pwsh -NoProfile -File Conversion\Pipeline\Invoke-Ssg4Release.ps1 -Stage Prepare` expands the skeletons with the cards, converts the
   COBOL into one application `.LionSource` (`E:\Repos\ssg4-work\release`), says whether it differs from the one imported last time
   (`-Previous`), and prints the LionDev steps with the exact file path.
2. In LionDev 177: import, **Get newest** on every object, generate **Whole system** (Step 5 below).
3. `pwsh -NoProfile -File Conversion\Pipeline\Invoke-Ssg4Release.ps1 -Stage Verify` checks every generated DLL is newer than the
   `.LionSource` (it refuses otherwise), rebuilds against Federale's 177a runtime, runs `Run-AllMockTests.ps1`, and stages the delivery
   package in `E:\AMT_Work\Delivery\AFBUS_2200COBOL_AMT-<date>` (`New-DeliveryPackage.ps1`: program DLLs, application DLLs, the
   `REBUILT-FOR-177A` flag files, `manifest.csv` with SHA256, `DELIVERY-NOTES.txt`). RECAP is left out (`-ExcludeFromPackage`, T3-027).
   It warns when a mock test fails.

Checked 2026-10-13: Prepare reproduces the imported revision 1.1 exactly (no difference); Verify passed end to end on the generated set
(CFH-COPY PASS, four smoke runs clean, RECAP exit 1 as known).

## The chain

| # | Step | Who / what | Input | Output | Status |
|---|------|-----------|-------|--------|--------|
| 0 | One-off environment | You + `LionDevSetup/` | AMT 177 installer (`8.0.26230.0`), SQL Server | LionDev 177 at `E:\Amt`, repository DB `AMT_REPOS177`, `Y:` mapping to `E:\AMT_Y177\CSharpNet`, work folders (the 179 install and `AMT_REPOS` are kept for rollback) | done |
| 1 | Export the SGS cards | `Pipeline/Export-SgsCards.ps1` | Runstreams (`-RunstreamDir`, default `E:\Repos\ssg4-source\01-RunsPrd`) | `<OutDir>\calls\*.sgs`, `sgs-calls.csv`, `sgs-warnings.csv` | done |
| 2 | Convert the SSG skeleton | `SsgConverterConsole` (SSG-3 converter) | SSG source | `SsgConverter/Examples/Output/<Program>.ps1` | done (20 of 20); fixes T3-025/T3-026 landed in `Build\Console`, `Build\Gui` and the goldens 2026-10-13 |
| 3 | Expand skeleton + cards to COBOL | `Pipeline/Invoke-SsgExpansion.ps1` | converted `.ps1`, one `.sgs` card file, `-RunInfo run-id,account,project` | `<Program>.cob` | done |
| 4 | COBOL to `.LionSource` | `Pipeline/Invoke-CobolConversion.ps1` | `.cob`, `-Name`, `-BaseYear` (default 1957) | `<WorkDir>\out\<Name>.LionSource`, logs, `.xrf` | done |
| 3+4 | Batch of steps 3 and 4 | `Pipeline/Invoke-RealCardBatch.ps1` | `sgs-calls.csv` | `<WorkDir>\summary.csv` plus the files above | done (17 programs, first call each) |
| 3+4 | **One application, one program per skeleton** | `Pipeline/Build-AppLionSource.ps1` (`-SkeletonDir` to use converted skeletons from another folder) | `sgs-calls.csv`, `-Programs` (default: the six) | `<WorkDir>\expanded\ASSURFED-UTILIT-<KEY>.cob`, `<WorkDir>\cobol\out\AFBUS_2200COBOL.LionSource`, `selection.csv` | done (six programs, `E:\Repos\ssg4-work\app2`) |
| 5 | Import, validate, generate | **You, in LionDev 177** | `.LionSource` | `E:\AMT_Work\Apps177\Binaries\Programs\ASSURFED_UTILIT_<KEY>.dll` (+ application DLLs) | done for the six (revision 1.1) |
| 5b | Rebuild against Federale's 177a runtime | `Pipeline/MockTest/Rebuild-SetAgainstRuntime.ps1 -Application AFBUS_2200COBOL` | the generated projects | `E:\AMT_Work\Rebuild177a\AFBUS_2200COBOL\Binaries\Programs` plus `REBUILT-FOR-177A.csv/.txt` | done. **Required**: see "Versions" below |
| 6 | Mock test | `Pipeline/MockTest/Run-AllMockTests.ps1` (one command), or `New-CopyMockTest.ps1` + `Run-MockCase.ps1` per case | the program's cards | CFH-COPY: PASS/FAIL against an independent reference; the other five: smoke runs only | CFH-COPY **PASS** on the 177a runner; four of five smoke runs clean, RECAP blocked (T3-027) |
| 7 | Deliver | You, with go-ahead | the rebuilt DLLs | into Federale's C# set-up (`AFBUS_2200COBOL_AMT`) | pending (MT-039). The app database also needs the reorganise step (the generator says so for DMS schema 1.1) |
| 8 | Run via real AMT Control Center | You, with go-ahead (register + Start Job) | the delivered DLLs | a genuine CC job run (not the mock harness) | pending (MT-009). This is Objective 1 of the [epic](../.github/Copilot_Plans/261009-trial4-epic-strategy.md#2-objectives-what-done-means-for-trial-4) — "runs in the real AMT Control Center" — not yet attempted for any SSG-4 program. Step 6's mock tests (`Run-AllMockTests.ps1`) run the DLL directly against a mock system DB + mock file controller; that is **not** the same as a CC job (no `Set-Jobname`/`Connect-Application`/BatchController involved) |

### Step 1 — cards
Each `@SSG` call's cards are written to their own file. SSG's own rules are applied first so AMT sees what SSG would have
seen: continuations (` ;` or `,;`) joined, cut at an unquoted period, spaces after a comma removed, `''…''` pairs dropped.
Every change is listed in `sgs-warnings.csv` (Severity *Changed*); things that cannot be fixed in the card (a quoted
subfield containing a space) are *Warning*. `Test-SgsCardRules.ps1` checks the rules against the manual's examples (12 checks).

### Step 3 — expansion
Runs the converted skeleton with **AMT's own** `AddTo-SgsList`, `GetSgsValue`, `CompareTypeSafe`, `RemoveFrom-SgsList` and
`Sort-SgsList` lifted from `SsgConverter/Trials/RealRuntime/AmtPsEclLib.psm1`, so the output is what AMT would produce.
Labels are case-insensitive (SSG rule, T3-023) and `INFO$` is filled from `-RunInfo`.

### Step 4 — COBOL conversion
Uses the R&D `CobolConverterConsole` built at `E:\Repos\amt-go-net-ref\_build\CobolConverterConsole`. Check `Errors` in the
result before importing: 6 of the first 17 programs convert with 0 errors; the rest are blocked by converter defects
(T3-018, T3-021, T3-022, and TAPELD, TABAN, EXTEUR, the MULTI pair).

### Step 5 — LionDev 177 (manual, one object at a time)
1. In LionDev, **File > Import > Lion Source File**. `ALLOW-DECODED-LIONSOURCE` must be on in `Lion.ini`, or a converter-produced file is refused. With *Skip duplicate objects* ticked there is no list: every object loads as the next revision (`1.0 as 1.1`), changed or not.
2. **View > Generation Sets**: a named set (here `MsSql177`: Local source folder `E:\AMT_Work\Apps177`, Script folder `E:\AMT_Work\Script177`, MsSql, Vs2026). There is no output folder field; the generator writes `Binaries` and `Development` under the local source folder, so use a new folder per LionDev version.
3. **Get newest** on every imported object: each program on the *Programs* tab **and** the application options under
   *System > Application*. Without this the generator says "Object is not available in this generation set" or
   "Application options object … See Revision Control". Revision Control must show no "* New *".
4. Start `LionDevGenNet.exe` (the generator window) **after** `Lion.ini` has a working `DBPSSW`; a window started earlier read an empty password and left every request waiting. Stop the `LionDevNet_Generator` service first: only one generator may run at a time. Then **F6**, *Programs*, **Whole system**.
5. Check `Generated : n Not Generated : 0` in the status grid and the generator log (`<local source>\Development\Log\<date>\_Generate <date>.Log`). "IT'S NECESSARY TO RUN THE DATABASE REORGANIZE" appears when the DMS schema revision changed.
6. Keep a copy of the output before generating again (`E:\AMT_Work\Snapshots\Apps177-rev1.0` was taken before revision 1.1).

### Step 6 — mock test
There is no real production data, so inputs are generated and the expected result is derived **from the cards only**, not from
the COBOL or the C# (so the test can fail if the conversion is wrong). `New-CopyMockTest.ps1 -Cards <calls\x.sgs> -OutDir <dir>`
writes `input\` and `expected\`; `-Actual <file>` compares a real output byte for byte. Running the DLL needs an AMT system
database and an application defined in it: the generated program has no standalone mode. The isolated mock system on this box
(`AMT_MOCKSYS` + `AMT_MOCKAPP`, `E:\AMT_Work\MockSystem`, MT-036) provides that. Test two record shapes per program (for CFH-COPY:
VIRM01 500/135 and PBDA04 700/700).

**One command:** `pwsh -NoProfile -File Conversion\Pipeline\MockTest\Run-AllMockTests.ps1` starts and stops its own hidden mock
file controller. Part 1 runs CFH-COPY_ASCII (call AFPH12 line 427) and compares with the reference. Part 2 smoke-runs the other five
(`Run-SmokeSet.ps1`: made-up input from the cards, a fresh file controller per case, 45 s limit): it shows that a program loads,
opens its files and ends, **not** that its output is right. A killed or failed run leaves its files locked in the file controller
(`IO error 95 Timeout action Open/Create`), which is why each smoke case gets a fresh one.

Part 3 (`Run-ReferenceTests.ps1`) compares output with an expected file worked out **independently of the C#**, from the cards and the
skeleton's COBOL: FUSBA2_ASCII (an update merge of two key-sorted files, modelled from its COBOL loop; 14 MAJ and 39 INP records, 13 updated;
PASS) and a LOADIS_ASCII then UNLOADIS_ASCII round trip (40 records into an indexed file and back, byte-identical; PASS). A note-only case
shows LOADIS silently skipping out-of-order keys (T3-029). LECTIS_ASCII has only a smoke run (its output goes to the printer). Each test program
is built from **one call's cards**, so a reference test only covers that call's record layout (FUSBA2: VIRD03 line 766; LOADIS: CLOA49 line 141;
UNLOADIS: CLOA43 line 473). `Run-ProgramCase.ps1` runs one program on prepared inputs and compares one output file byte for byte.

**All calls, not just the first** (`Invoke-RealCardBatch.ps1 -CallsPerProgram 100`, 2026-10-13): of the 65 exported calls of the five release
programs, 59 expand and convert with 0 errors (FUSBA2 4/4, LECTIS 1/1, LOADIS 9/9, UNLOADIS 4/4, CFH-COPY 41/47). The six CFH-COPY failures are
card-handling limits (T3-028).

**Running a program in the mock system** (everything from `E:\AMT_Work\MockSystem`, never Federale's `AmtTools`):
1. One-off: `Create-MockSystemDb.sql` and `Create-MockAppDb.sql` (SSMS as `ava`), mock `Sys.ini` with the `LionDev` password, copies of the tools (`Reo\`, `Cfg\`, `FC\`) each with that `Sys.ini` beside the exe, `Run\` = copy of `Apps\Binaries\Programs` + `Complete-MockRunner.ps1` + the `MockSystemTool` build.
2. One-off, with `MockSystemTool.dll ... --ini Run\Sys.ini`: `seed` (base path, logging, runtime behaviour, config, application), `seed-db --db-name AMT_MOCKAPP`, `seed-fc`. Create the system tables with `Reo\AmtReoConsole.exe /APP=SYSTEM`, the application tables with `/APP=CFHCOPYASCII` (slow: the imported model has about 18,800 actions; 7 views fail on name case, harmless here).
3. Each run: start `FC\AmtFileController.exe /VS /N:MockFileController` (console, port 18132) and leave it running; put the input in `E:\AMT_Work\MockTest\Extracts\` **as `<NAME>.DAT`** (AMT adds `.DAT` to the logical file name: `INB` is read from `INB.DAT`, `INC` is written to `INC.DAT`); run `MockSystemTool.dll run --ini Run\Sys.ini --dll Run\<PROGRAM>.dll`; compare with `New-CopyMockTest.ps1 -Actual <...>\INC.DAT`. Close the file controller afterwards (it listens on all interfaces).

### Step 7 — deliver into Federale (MT-039, done 2026-10-20 for the 13-program Batch 4 set)
This is the VM's own copy of Control Center, so changes here are ours to make; each still needs an elevated shell for the service
restart. What was learned doing it:
1. **The application's own base path decides where DLLs go, not the shared Basepaths set.** In Control Center → *System Configuration →
   Architecture → Applications → `AFBUS_2200COBOL_AMT` → Properties* the *Application base path* is `%APPROOT%`. COBOL program jobs are
   found at `%APPROOT%\programs\<name>.dll` (job type `AmtCobolProgram`, `AMTSYSAVAILABLEJOB`/`AMTSYSPROCESSJOB` `JOBTYPE` 5). For
   `FEDERALE_APP` the base path ends in `\Binaries`; for `AFBUS_2200COBOL_AMT` it had to be changed to
   `E:\Repos\AMT\Apps\AFBUS_2200COBOL_AMT\Binaries`. The Basepaths set (`default`: Script/Extract/Print/Logging paths) is shared by both
   applications and has no programs path; do not edit it. The `_AMT` suffix is just the registered application name (the manual
   ties the folder to the name; there is no automatic suffix rule).
2. **Back up what's there first**, same discipline as MT-039's `FirstRelease-20261013` backup, before overwriting anything.
3. **Copy the delivery package** (`E:\AMT_Work\Delivery\AFBUS_2200COBOL_AMT-<date>\Binaries\{Application,Programs}\*`) into
   `E:\Repos\AMT\Apps\AFBUS_2200COBOL_AMT\Binaries\` (`_scratch\Deliver-ToAmtFolder.ps1`) — flat, application DLLs
   (`AFBUS_2200COBOL.Application.dll`/`.Database.dll`) alongside every program DLL in `Programs\`. The first release also carried about
   23 AMT runtime/support DLLs beside its programs; the 9 that exist in Federale's `Programs` folder (`Asysco.Amt.Runtime`, `Libs`,
   `AmtSharedDataModel`, ...) were added with `_scratch\Add-RuntimeDlls.ps1`.
   Clean-up that was needed first: two orphaned process jobs (30 and 31, of the deleted application 4) were re-queued on every
   BatchController start and invisible in Control Center; they were removed with `Conversion\Pipeline\ControlCenter\Remove-OrphanProcessJobs.sql`
   (diagnostics: `Read-JobConfig.sql`, both run in SSMS as `ava`).
4. **Reorganize the application database (needed: done 2026-10-20).** Without it every job ends with a bug report
   `Invalid object name 'dbo.AMTSYSCRITICALREPORT'` (the output is still correct). Use the GUI `E:\Amt\AMTTools\Reorganize\AmtReorganize.exe`:
   - It needs the runtime licence at `E:\Amt\AmtRuntime.lic` (copy of `C:\Amt\lic\AmtRuntime.lic`; the install root had none).
   - It is the **177** build, so it can only load the **177** `AFBUS_2200COBOL.Application.dll` / `.Database.dll` (runtime 8.0.26230.0), not the 177a
     rebuilds (8.0.26230.50: "Could not load ... Asysco.Amt.Runtime 8.0.26230.50"). For the reorganize put the 177 originals from
     `E:\AMT_Work\Apps177\Binaries\Application` into `<APPROOT>\Application`; the programs in `Programs` keep the 177a rebuilds
     (`_scratch\Swap-ReoDlls.ps1` keeps the rebuilds in `Application.rebuilt-177a`).
   - Stop the Federale services first (the tool warns "There are users within the database"), pick **only** `AFBUS_2200COBOL_AMT`
     (`VMFEDPE08 : AFBUS_2200COBOL_AMT : MSSQL [dbo]`), *Analyze selected*, then *Reo selected*. Never *Reo all*, and never reorganize
     `System` or `FEDERALE_APP` (ABSuite, its DLL is not a Lion object DLL).
   - Result: it created `AMTSYSCRITICALREPORT`, `AMTSYSDMS2200DBKEY`, `AMTSYSSESSIONDATA`, `AMTSYSSESSIONFORMDATA`, the sequence
     `seq_amtsysuniquenumber` and the function `AMT_ENCRYPT` in the application database.
5. **Restart `FederaleBatchController`** (elevated) so it picks up the new binaries — no live auto-sync (same lesson as Step 5's "two
   generators"/MT-023 class of gotcha).

### Step 8 — run via real Control Center (MT-009, 2026-10-20: all 13 run after the reorganize; 6 PASS, 5 smoke clean, TABAN/CHAB100 fail as in mock) — pilot one program first
Step-by-step runbook and the 2026-10-20 run record: [docs/SSG4-ControlCenter-Runbook.html](../docs/SSG4-ControlCenter-Runbook.html).
`Invoke-CcPilot.ps1` now covers all 13 programs; `Grant-ExtractsAccess.ps1` (once, elevated) lets an unelevated shell clean job outputs.
Objective 1 of the [epic](../.github/Copilot_Plans/261009-trial4-epic-strategy.md): the proof is a genuine CC job run whose output
matches the **same independent reference** Step 6 already derived from the cards (not "ran without error"). **Pilot with
`CFH-COPY_ASCII` only** before touching the other 12 shippable programs — it already has a proven byte-identical mock result
(VIRM01 cards, Step 6) to compare against, and the `AmtCobolProgram` job type has never been exercised here (unlike `AmtReport`/
`Script`, which SSG-3 already proved — see §5c). Confirm each assumption below live; don't carry over SSG-3's PowerShell-job mechanics
unchecked.
0. **Prerequisites: Keycloak and the Federale services must be up before Control Center will log you in.**
   - Check Keycloak: `pwsh -NoProfile -File _scratch\Check-Keycloak.ps1` (port 8080 listening, and `http://localhost:8080/realms/Federale/.well-known/openid-configuration` returns 200).
   - If it is not up, start it in its own console and leave that window open (dev mode, not a service):
     `cd C:\Tools\keycloak-26.7.2` then `bin\kc.bat start-dev`.
   - Then, from an **elevated** PowerShell: `cd E:\Repos\SsgTrial\SsgConverter\Trials\RealRuntime` then `.\Manage-FederaleServices.ps1 -Action Restart` (use `Restart`, not `Start`: `Start` skips services that are already running, so BatchController would not reload newly copied DLLs). Cold-start order is Keycloak, then the Federale services.
   - Open `http://localhost:5120` and log in yourself (Keycloak realm `Federale`); the password is never typed into chat or a saved file.
1. **Register (confirmed 2026-10-20).** Restart the Federale services after the base-path change, then *System Configuration → Batch &
   Forms → **AvailableJobs*** (not AvailableForms: the forms scan reports "Forms path not found ...\Server\bin" for a batch-only app, which
   is harmless) → Application `AFBUS_2200COBOL_AMT` → *Read all jobs from system* → Refresh. Result: 54 jobs added, including all 13
   `ASSURFED_UTILIT_*` programs as type `AmtCobolProgram` (JobIds 5396–5408, file `%APPROOT%\programs\<name>.dll`), plus 41 `Script`
   jobs from the shared Script path. No SQL insert is needed.
2. **Activate (confirmed 2026-10-20).** *Security → Jobs* showed the 13 programs already ticked for role Administrators; they appear under
   *Jobs → Start Job*.
3. **The real `Extracts` folder** is the shared Basepaths `Extract path`: `E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Extracts`
   (shared with `FEDERALE_APP`, which holds old SSG-3 files; a separate Basepaths set and Configuration for this application is a later
   isolation step).
4. **Stage the input** with `pwsh -NoProfile -File Conversion\Pipeline\ControlCenter\Invoke-CcPilot.ps1 -Pilot CFH-COPY_ASCII -Action Stage`: it copies the mock
   test input `E:\AMT_Work\MockTest\AFPH12_L427\input\INASC` (call AFPH12 line 427: 25 records, 2,050 bytes) to `INASC.DAT` in that folder, and
   refuses to run if `INASC.DAT` or `OUTASC.DAT` already exist (`-Action Clean` removes a pilot's own files). The program writes `OUTASC.DAT`;
   `-Action Compare` (step 7) byte-compares it with `E:\AMT_Work\MockTest\AFPH12_L427\expected\OUTASC`. A second pilot, an indexed-file round trip,
   uses `-Pilot LOADIS_ASCII` (stages `B010SINAUTCL.DAT`, 40 records of 204 bytes; writes `OUTCLOA49.DAT` + `.Index`) and then
   `-Pilot UNLOADIS_ASCII` (stages the LOADIS output as its input `FSCR001ATO.DAT`; writes `OUT.DAT`, compared with the independent expected file).
5. **Start the job.** Control Center → *Jobs → Start Job* → `AFBUS_2200COBOL_AMT` → the job → *Start*.
6. **Monitor.** Control Center *Job Management*; on any ambiguity check `FederaleBatchController.Log` first (T3-010 lesson: the real
   first error only appears in the main trace, not the per-job log), then the per-job joblog under `AmtTools\Basepaths\Logs\<date>\`.
7. **Collect and compare.** `pwsh -NoProfile -File Conversion\Pipeline\ControlCenter\Invoke-CcPilot.ps1 -Pilot <name> -Action Compare` reads the output from
   the `Extracts` folder and byte-compares it against the expected file, printing which kind of reference it is — a clean exit is not proof by itself, the byte-compare is.
8. **Only after CFH-COPY_ASCII passes this way**, repeat steps 1–7 for the rest of the shippable set (CONDIS2_ASCII, CHABAN_ASCII,
   BABA_ASCII, FUSBA_ASCII, FUSBA2_ASCII, LECTIS_ASCII, LOADIS_ASCII, LOADIS_MULTI, UNLOADIS_ASCII, UNLOADIS_MULTI; RECAP excluded,
   T3-027; TABAN_ASCII and CHAB100_ASCII flagged — both already fail their own build-call smoke test, T3-027/T3-032 — confirm whether
   to include them in this pass or wait for a fix).

## Versions: LionDev 177 against Federale 177a (MT-038)

LionDev here is now **AMT 177** (`8.0.26230.0`, "AMT 177 - 260818", from the 177 Setup media); it was 179 before. Federale's
runtime is **177a** (`8.0.26230.50`). They are **not** the same API: 177-generated programs call the
`AmtBaseCobolProgram` constructor with two extra arguments (generation date and time), and Federale's 177a runtime only has the
five-argument constructor (confirmed in the `Federale_InternalRelease` source, `main`, and in the deployed DLLs). A 177
program on a 177a runtime fails at start with `MissingMethodException`. So the generated set must be rebuilt:

1. `Rebuild-SetAgainstRuntime.ps1 -Application AFBUS_2200COBOL` copies the generated projects to a scratch folder, swaps the
   `Y:\` project references for **copies** of Federale's 177a DLLs, drops the two generation-stamp arguments from every
   `base(...)` call and builds each program. Federale's folders are only read.
2. **Flag:** each rebuilt source gets a `// REBUILT-FOR-177A ...` comment above `base(...)`, and the output folder gets
   `REBUILT-FOR-177A.csv` (program, dropped date and time) and `.txt`. Effect: the `GenDate`/`GenTime` system items are not set;
   none of the six programs read them. This is a workaround, **not LionDev's own output**: regenerate with a matching 177a
   LionDev when one exists (ask R&D which build 177a is).
3. The result references 177a and runs on Federale's 177a libraries in `E:\AMT_Work\MockSystem\Run177` (`Run177own` holds the
   177 libraries, for testing logic at 177 only).
4. Output name: the class says `base("<NAME>", ...)`, so each DLL is shipped as `<NAME>.dll` (the script renames it).
5. **Naming:** programs are `ASSURFED-UTILIT-<KEY>` (class and DLL `ASSURFED_UTILIT_<KEY>`), one application
   `AFBUS_2200COBOL`. How Federale maps the runstream's `.CFH-COPY` call to a program is not yet known (open discovery item;
   not reconciled on purpose, owner decision 2026-10-13).
6. Older, per-call route (179): `Rebuild-AgainstRuntime.ps1`, one application per call. Superseded by the above.

## Known gotchas

| Topic | What happens | What to do |
|-------|--------------|-----------|
| **BaseYear** | The COBOL converter writes `BaseYear=0` into the `.LionSource`; LionDev's *Options* screen then crashes ("un-representable DateTime"). | Convert with `-BaseYear 1957` (the default). Only a year can be stored, not a date. An application already imported with 0: patch the `REVDATA` row (`OBJTYPE=123`, `LINENR=1`, `BaseYear=0@` to `BaseYear=1957@`) or delete it and re-import. |
| **`AMTSYSTEM`** | The machine-level `AMTSYSTEM` variable points at **Federale's** `AmtTools`. AMT tools read it from the *machine* scope only, so setting `$env:AMTSYSTEM` in a terminal does nothing. On 2026-10-13 `AmtReoConsole /APP=SYSTEM` went to `FEDERALE_SYSTEM` this way (analysis only; it stopped because services were connected; nothing changed). | Lookup order is the `/I:<file>` argument, then a `Sys.ini` **beside the exe**, then the machine variable. Run any AMT tool from a **copy** of its folder with the mock `Sys.ini` beside it (`E:\AMT_Work\MockSystem\Reo`, `\Cfg`). First run `/ANALYZEONLY` and check the first log line names the mock database. |
| **LionDev password** | `Lion.ini` `DBPSSW` empty gives "Login failed for user 'LionDev'". An encrypted value copied from another `Lion.ini` silently fails. | Type the password plain once; LionDev/Setup then stores it encrypted. Never paste it into chat or a saved file. `Create-RepositoryDb.sql` reads it from the `LIONDEV_PWD` environment variable. |
| **Get newest** | A new generation set does not contain imported objects until each is fetched. | Step 5.3, on every object, every time a new set is made. |
| **Two generators** | The service and the window both running makes the window's messages unreliable. | Stop the service, use the window. |
| **`E:\Amt` is AMT-only** | Setup does a clean install of its root folder. | Work files go in `E:\AMT_Work`, `E:\AMT_Y`. |
| **Y: drive** | Generated projects reference `Y:\Amt.Net\Libraries\...`. | `Y:` is a persistent registry DOS device to `E:\AMT_Y\CSharpNet`, global after a reboot. |
| **Federale is separate** | The live Federale AMT (`FEDERALE_SYSTEM`, services) is not part of this work. | Do not run AMT tools without the isolation above; do not change its configuration. |
| **Card parsing limits** | AMT's `AddTo-SgsList` splits only on spaces and commas (MT-033 item 12). | Step 1 rewrites what it can and warns on the rest; do not assume a *Warning* card expanded correctly. |
| **Run-time warnings** | Card changes and warnings are not in the AMT job log, only in `sgs-warnings.csv` (MT-034). | Read `sgs-warnings.csv` alongside any run. |
| **SQL tools** | SSMS needs *Trust server certificate*; `sqlcmd` needs `-C`; `ava` is used only to create things. | — |
| **Converter files are protected** | Existing files under `SsgConverter\Build` and `Source` are read-only for an unelevated shell (rename, overwrite and delete are refused); VS Code can still save a source file. An edit made with an editor tool can sit unsaved for about a minute. | Check the file on disk (`LastWriteTime`, `Select-String`) before building. Landing a new `SsgConverter.dll` into `Build\Console` and `Build\Gui` and regenerating the goldens (`Trials\Reconvert-And-Verify.ps1 -Rebuild -RefreshDll -UpdateGoldens`) needs an **elevated** shell. Test in a scratch copy first (`_scratch\Test-ValueOfFix.ps1` pattern). |
| **Database statements in COBOL** | `ENTER MASM 'ACOB$RDMR' ...` (RDMS) statements become C# comments, and `CALL 'RSA$INIT'` becomes a call to a program that does not exist (RECAP, T3-027). | Deferred to the next phase (owner decision 2026-10-13): database queries wait unless very light. |

## Where things live

| Thing | Path |
|-------|------|
| Pipeline scripts | `Conversion/Pipeline/` |
| Mock test and mock system SQL | `Conversion/Pipeline/MockTest/` |
| LionDev setup, preflight, repository SQL | `Conversion/LionDevSetup/` |
| Working example (checked-in results) | `Conversion/Pipeline/WorkingExample-CFH-COPY_ASCII/` |
| Scratch work (not in git) | `E:\Repos\ssg4-work`, `E:\AMT_Work\{Apps,Script,MockTest,MockSystem}` |
| R&D tool source (read-only) | `E:\Repos\amt-go-net-ref` |
