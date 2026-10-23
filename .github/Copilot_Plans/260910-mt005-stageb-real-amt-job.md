---
title: "MT-005 Stage B — run CFH-COPY as a real AMT job (Initialize / Connect-Application / Control Center)"
date: "2026-09-10"
status: "scoped — standalone pwsh unsupported (net8 deps closure); CC/BatchController route next"
owner: "MT"
area: "D (real runtime) — Stage B"
---

# Plan: MT-005 Stage B — CFH-COPY under the real AMT runtime

Bring up the **full** AMT job context so the converted `CFH-COPY.ps1` runs as a real AMT job —
producing the artefacts an isolated Stage A cannot: an **AMT joblog** under
`AmtTools\Basepaths\Logs\<date>\` and **Windows Event Viewer** records.

> Context (confirmed by user 2026-09-10): this is an **isolated AMT177 VM** with **our own copy**
> of AMT / Control Center at `E:\Repos\Federale_InternalRelease` — *not* the Federale client site.
> Nothing here affects other users; converted software is shared only once bundled to GitHub.
> Therefore Stage B (real `Initialize` / `Connect-Application` / CC) is legitimately runnable here.

## Update 2026-09-10 — AMT training-doc confirmation (reshapes the approach)

Answers from the AMT172/175 Copilot (sourced to the official doc *"Overview Batch Jobs in AMT — from
ECL to PowerShell"* §6.1–6.5 + `AmtPsEclLib.psm1` L585–618, which matches our isolated copy):

- **The PowerShell report path is standard and documented** — §6.4 "from an online/batch program →
  handled by AMT BatchController" and §6.5 "from AMT ControlCenter (also adds the script to job
  requests)". It is not dormant *in principle*, but the companion `SSG-ECL-PowerShell-Reference.html
  §2` marks **Tier‑3 full PowerShell ECL orchestration as "optional / not yet exercised"** in that
  repo — i.e. documented but unproven in the environment.
- **The script drives its own AMT bring-up, not the host.** The documented skeleton is:
  `Set-Jobname` → `Initialize $AmtSettingsFile` → `Trap{…}` → *body* → `Fin`. `Initialize` (L585–618)
  is what does `Add-Type ComScript.dll` → `New Comscript` → **`Connect-Application`**, and assigns
  `RequestId` / `JobNumber` / `BatchId` via `Get-RequestId` / `Get-JobNumber` / `Get-BatchId`.
- **Therefore our B3 harness *is* the documented model** — running the converted `.ps1` with the
  standard skeleton against the live services is exactly how AMT runs a PowerShell report. The Control
  Center only adds the **job-request/queue wrapper** on top (`Xqt` / CC → Start Job → insert
  `AMTSYSBATCHREQUEST`, usercode impersonation, queues) — it does not change the in-script
  Initialize→body→Fin.

**Revised plan of record:** do **B3 first** (script-driven `Initialize`, the proven model) to get a
real `Connect-Application` + joblog; then, optionally, add the CC job-request wrapper (register the
script, CC → Start Job) as a second, fuller step. Minimal proof to mirror = the training doc's
**Exercise 1** hello-world script (`Set-Jobname`/`Initialize`/`Fin`) — run that first to validate the
settings + connection before CFH-COPY.

## Update 2026-09-10 (2) — B3 attempted; standalone pwsh is NOT the supported host

B3 was built and run live. `Connect-Application` resolved settings/app and reached the **DB connect**,
then failed on the .NET dependency closure (confirmed by the AMT Copilot, grounded in the binaries):

- The DB connection is owned by the native **MsSql wrapper** `Asysco.Amt.AmtSqlServerWrapper.dll`
  (`AmtTools\SqlServerWrapper`), selected by `SERVER TYPE=MSSQL` in `Sys.ini`. Its `.deps.json` pins a
  **.NET 8** closure: `Microsoft.Data.SqlClient 6.1.4` + `Microsoft.Data.SqlClient.SNI.runtime 6.0.2`
  (`runtimes/win-x64/native/…SNI.dll`). Bare `pwsh` has no `.deps.json` → can't bind the platform/native
  SNI → *"not supported on this platform."* Hand-`Add-Type`ing DLLs then pulls mismatched transitive
  versions (the `…Extensions.Abstractions 7.0.0.0` error) — reverted.
- **Correction:** `AmtPowershellHost` targets **.NET 8 / PowerShell SDK 7.4.14**, *not* net10. Our pwsh
  7.6.6 / net10 run was itself a runtime mismatch.
- **Conclusion:** a standalone `pwsh` run is **not** a supported host. `AmtPowershellHost.exe` (via
  BatchController/CC) is the only process shipping the correct net8 closure. Our `AmtSettings.xml` +
  `Run-StageB.ps1` are correct as *script/settings* — they were just run in the wrong host.

**Decision: proceed with the CC / BatchController route (option 1).** The full developer walkthrough is
the tracker's **§5c "AMT Control Center Run Process"**. Execution checklist:

0. **(Tier-3 unknowns to confirm first)** `AMTSYSAVAILABLEJOB.TYPE` for a PowerShell script + interpreter
   routing to `AmtPowershellHost`; where the `.ps1` must physically live; whether Tier-3 is enabled in
   this build. (Ask the AMT Copilot before any DB write.)
1. Confirm services up (`Get-Service Federale*`).
2. Deploy `CFH-COPY.ps1` to the app's Scripts group (path per step 0).
3. Register in `AMTSYSAVAILABLEJOB` (+ `AMTSYSAPPLICATION` already has `FEDERALE_APP`).
4. `Restart-Service FederaleBatchController` (elevated) so it rescans.
5. CC → Security → Jobs → Activate.
6. Stage `ECL-TAPEIN.DAT` fixture under `<working base>\Lion\Files\Extracts\`.
7. CC → Jobs → Start Job → FEDERALE_APP → CFH-COPY → Start (inserts `AMTSYSBATCHREQUEST`).
8. Monitor CC Batch Control + joblog `AmtTools\Basepaths\Logs\<date>\`; collect `ECL-TAPEOUT` output.

## What Stage B adds over Stage A

Stage A skips `Initialize`. Stage B calls `Initialize(<AmtSettings.xml>)` (AmtPsEclLib L497), which:
1. Reads `AmtSettings.xml` → sets `$global:AppName / SysIniFile / ComScriptDll / ApplicationKind /
   UseJobLog / WarningRcw2435 / …`.
2. `Add-Type -Path $global:ComScriptDll` → loads **ComScript.dll**.
3. `New-Object Asysco.Amt.Scripting.Comscript` → creates the COM object.
4. **`Connect-Application`** → connects to the running application (AppName + TransactionServer
   `Grpc:localhost:60115`).
5. Creates COM path/message/file/report/print/database objects.
6. `Create-InitialJobLog` / `Init-JobLog` → **the joblog** (the artefact the user was looking for).
7. `Get-PathsForCurrentApp`, `Initialize-IpfSystemVariables`, `Sort-Init`, `Create-TempFolder`.
8. Reads global SGS from `..\P$SGS\_ALL_`.

The end-of-job COM cleanup (`$global:Com.RemoveNonPrintedFiles`, L3157) that bounded Stage A then
completes for real, because `$global:Com` is a live COM object.

## Findings so far (landscape)

- **ComScript.dll** present at (candidate for the settings `ComScript` path — matches the
  `.sample` `...AMTTools\ComScript\ComScript.dll` shape):
  `E:\Repos\Federale_InternalRelease\AmtTools\ComScript\ComScript.dll`
  (also under `AFBUS_AMT\Binaries\...` and the `AmtFramework\...\bin\{Debug,Release}\net10.0\`).
- **AmtCOMModule.dll**: `E:\Repos\Federale_InternalRelease\AmtTools\ComModule\AmtCOMModule.dll`.
- **No live `AmtSettings.xml`** found in the Federale tree — only
  `Scripts\Settings\AmtSettings.xml.sample` and the in-workspace `Trial3\run\AmtSettings.xml`
  (needs review — may be a usable starting point).
- Running-server layout exists: `AFBUS_AMT\Binaries\Working\ServerWorking\{TransactionServer,
  Amt_VMFEDPE…_8031_*}\` + WorkerPools → the app normally runs as **services / server processes**.
- App identity appears to be `AFBUS_AMT` / FEDERALE — DB `FA_AFBUS`, service account `ava`
  (per CI). **Do not** change the DB or `ava`.

## Approach (staged, stop-on-blocker)

1. **Settings.** Locate or compose a working `AmtSettings.xml` for this VM (start from
   `Trial3\run\AmtSettings.xml` and/or the `.sample`, repoint `ComScript` →
   `AmtTools\ComScript\ComScript.dll`, `IniFile` → the VM's real `sys.ini`, `AppName` → the VM's
   app, `TransactionServer` → the VM's endpoint). Keep it in `Trials/RealRuntime/` (do not edit
   Federale files).
2. **Services.** Determine whether the AMT application / TransactionServer / FileController / Control
   Center are **running** (services or processes). If not, find the supported start method (CC UI or
   a start script). Do **not** force-start with elevation silently — if a UAC/admin step is needed,
   surface it to the user.
3. **`Run-StageB.ps1`** (new, `Trials/RealRuntime/`): import the isolated `AmtPsEclLib.psm1`, call
   `Initialize <AmtSettings.xml>`, seed SGS (as Stage A), stage the TAPEIN input, run
   `Examples/Output/CFH-COPY.ps1`, let `Fin` complete the real COM cleanup. Idempotent.
4. **Run + capture.** Run CFH-COPY; capture: the new joblog file under
   `AmtTools\Basepaths\Logs\<date>\`, any Event Viewer entry, exit status, and emitted output.
5. **Record.** Add a **Stage B runbook** (`id="stageb-runbook"`) to the tracker §5b mirroring the
   Stage A runbook, note the joblog/Event-Viewer location, flip **MT-005** toward done, update memory.

## Risks / unknowns

- `Connect-Application` may require the app services + DB online and reachable at
  `Grpc:localhost:60115`; if down, Stage B blocks until they're started.
- COM (`Add-Type ComScript.dll` + `New-Object`) may need matching bitness / .NET 10 runtime and the
  COM registration the server install provides.
- `Initialize` may reference paths (sys.ini, base paths) that must exist on this VM.
- If a step needs elevation or a live login (`ava`), stop and ask — never route secrets through tools.

## Guardrails

- Only ever read/copy from `E:\Repos\Federale_InternalRelease`; keep new artefacts under
  `SsgConverter/Trials/RealRuntime/`. Do not modify the `FA_AFBUS` DB or the `ava` account.
- Every step idempotent and re-runnable; log any blocker as a `T3-nnn` issue and any gap as `MT-nnn`.

## Relevant files
- `SsgConverter/Trials/RealRuntime/{Run-StageA.ps1 (done), Run-StageB.ps1 (new), AmtSettings.xml (new)}`
- `SsgConverter/Trials/RealRuntime/AmtPsEclLib.psm1` (isolated copy; `Initialize` L497, cleanup L3157)
- `docs/SSG-PowerShell-Trial-Progress.html` §5b runbooks + MT-005
- reference: `E:\Repos\Federale_InternalRelease\{AmtTools\ComScript\ComScript.dll, Scripts\Settings\AmtSettings.xml.sample}`
