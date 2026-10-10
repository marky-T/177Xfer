# Plan: CFH_COPY mock-file run (AFBUS_2200COBOL, Tier‑2 sanity check)

**Status:** input staged, awaiting user to click Start Job in CC.

## Actions taken (2026‑09‑30)

1. Ran Step 1 (stage input) — `ECL-TAPEIN.DAT` copied from the `cfh-copy` fixture, confirmed on
   disk at **246 bytes** (3× 80‑char records + CRLF), timestamp `30/06/2026 14:27:50`.
2. Ran Step 2 (clear stale output) — `ECL-TAPEOUT.DAT`, `.Index`, `._CLEG` (LOADIS leftovers)
   removed; `Get-ChildItem Extracts\ECL-TAPE*` now shows only `ECL-TAPEIN.DAT`.
3. **Pending:** Step 3 (CC → Jobs → Start Job → `AFBUS_2200COBOL` → `ASSURFED_UTILIT_CFH_COPY` →
   Start job) and Step 4 (verify) — to be done by the user in the CC UI.
4. **Run completed (2026-09-30)** — JobId 1006, RequestId 1069, Status Done, ExitCode 0, 0.358s.
   `ECL-TAPEOUT.DAT` = 246 bytes, byte-identical to `ECL-TAPEIN.DAT` (`Compare-Object` → no diffs).
   Confirmed via `AmtBatchController_AGENT_1_Filecontroller_Trace.Log` (`AmtAfcResultReadRecord` ×2,
   `AmtAfcResultCreate`/`DirCreate`) and `AmtBatchController_AGENT_1_Trace.Log`
   (`ReportFinishedReply {"ExitCode":0,"JobState":19}`).
5. **Recorded in the reference doc** — added a reconfirmation entry + verification-methods list to
   `Migration/SSG-ECL-PowerShell-Reference.html` §6b "Tier 2 results", and updated the stale JOBID
   (737 → 1006) in the §7 testability map. Note: `AMTSYSAVAILABLEJOB` IDs shifted from 736‑742/1002
   to 1004‑1013 at some point — the environment appears to have been rebuilt/re-registered since the
   doc was last updated; treat old JOBID references elsewhere as stale.

**Status: complete.**

## Context

Confirmed (2026‑09‑30) that the 8 `AmtReport` jobs under CC app `AFBUS_2200COBOL` are genuinely
LionDev-generated, not bypassed — each has a matching `.sln` under
`Working/Apps/AFBUS_2200SSGCOBOL/Source_AMTLion/Development/Programs/` (source lives under the
`2200SSGCOBOL`-named folder; compiled DLLs deploy to `Apps/AFBUS_2200COBOL/Binaries/Reports/`).
`AFBUS_COBOL NEW APPLICATION` in LionDev is a separate, unrelated app.

Goal: run **one** of these 8 reports with a mock input, just to prove it progresses far enough to
read a file — does not need a clean/complete pass. Picked **CFH_COPY** (simplest: single input
`ECL-TAPEIN` → single output `ECL-TAPEOUT`, plain 80‑byte record copy, no `*IF`/loop branches).

## Steps

1. **Stage input** — copy the known-good fixture to the designator path:
   ```powershell
   Copy-Item 'C:\Amt\Migration\EclCobolPipeline\fixtures\cfh-copy\input.dat' 'C:\Amt\Working\Lion\Files\Extracts\ECL-TAPEIN.DAT' -Force
   ```
2. **Clear stale output** — `ECL-TAPEOUT.DAT` (+ `.Index`/`._CLEG` sidecars) are leftover from the
   earlier LOADIS indexed-file run sharing the same designator name; clear so the fresh result isn't
   ambiguous:
   ```powershell
   Remove-Item 'C:\Amt\Working\Lion\Files\Extracts\ECL-TAPEOUT.DAT*' -Force -ErrorAction SilentlyContinue
   ```
3. **Run in CC** — Jobs → Start Job → Application `AFBUS_2200COBOL` → `ASSURFED_UTILIT_CFH_COPY` →
   **Start job**.
4. **Verify** — check Job Management for status (Done/Completed is a bonus, not required — just
   needs to show it read `ECL-TAPEIN.DAT`), then inspect
   `C:\Amt\Working\Lion\Files\Extracts\ECL-TAPEOUT.DAT`.

## Designators (verified from generated source)

`Assurfed_Utilit_Cfh_Copy.Files.cs`:
```
m_Tapein.SetOptions("ECL-TAPEIN", false, false, false, AmtFileRecordEnding.Default);
m_Tapeout.SetOptions("ECL-TAPEOUT", false, false, false, AmtFileRecordEnding.Default);
```

## Next step after this proves out

This was a stepping stone before the Trial‑3 PowerShell work — running a `.ps1` (`AmtPsEclLib`) job
via CC. A `Script`-type job already exists for that: `AMTSYSAVAILABLEJOB` JobId **1003
`T3_RUN_SSGPS`**, `File = C:\Amt\Migration\T3ConvertedSSG\Converted...`, app `AFBUS_2200COBOL` — not
yet inspected/run.
