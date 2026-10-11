# Done / open items extracted from Trial3-SsgConverter-PS-vs-CC-Plan.md

Source: `06-plans/AMT175/.github/Copilot_Plans/Trial3-SsgConverter-PS-vs-CC-Plan.md` (original: `C:\Amt\Parallel\AMT175\.github\Copilot_Plans\Trial3-SsgConverter-PS-vs-CC-Plan.md`)

0 done / 14 open (markdown checkboxes)

## Phase 0 — Restore clean state (prerequisite)

- [ ] Reboot the machine — ApplicationServer crash loop from 2026-08-19 left services failed.
- [ ] After reboot: verify CC opens at `http://localhost/AMT175/ControlCenter`
- [ ] Verify AMT175 AFBUS_COBOL app is listed and started in CC
- [ ] Verify `Trial3\run\Run-Chaban.ps1` is still intact (last known-good harness)

## Phase 1 — Triage the 5 scripts

- [ ] Inspect each `.ps1` in Examples\Output\ — identify meaningful executable PS content vs mostly comments
- [ ] Pilot choice: `CHABAN_ASCII.ps1` — only script with a prior successful CC run (C# version) to compare against

## Phase 2 — Deploy pilot script (CHABAN_ASCII)

- [ ] Copy `CHABAN_ASCII.ps1` to AMT175 script path (same location as Run-Chaban.ps1)
- [ ] Create `AmtSettings.xml` for CHABAN_ASCII — file assignments from CHABAN param overrides (FICHOUT-1, NUMB, MOD, FLDSEL)
- [ ] Register the script in CC — **exact registration path unconfirmed, needs reference doc read**
- [ ] Confirm `AmtPsEclLib.psm1` / `AmtPsSortLib.psm1` deployed in AMT175 lane (scripts call GetSgsValue, DataLineOrNoStatement — will throw if library missing)

## Phase 3 — Run and verify

- [ ] Run via pwsh.exe 7.6.3 (NOT powershell.exe 5.1 — .NET 10 assemblies required)
- [ ] Compare FICHOUT-1 output with C# CHABAN output — should be equivalent
- [ ] Log pass/fail in Trial3_SSG_Conversion_Plan.md
- [ ] Update HTML report via templates\tools\Update-TrialProgress.ps1
