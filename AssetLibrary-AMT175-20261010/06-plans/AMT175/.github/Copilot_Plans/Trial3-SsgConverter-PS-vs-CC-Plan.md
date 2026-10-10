# Trial 3 — Run SsgConverter PS Scripts Against AMT175 CC

**Goal:** Run the 5 SsgConverter-generated PowerShell scripts (from the release package,
2026-08-21) against AMT175 Control Center, verify output.

**Scripts in scope:** ARCHISEPARE, CFH-COPY, UNLOADIS_ASCII, CHABAN_ASCII, BABA_ASCII
Source: `C:\Amt\SsgConverter-Release-20260821\Examples\Output\`

---

## Phase 0 — Restore clean state (prerequisite)

- [ ] Reboot the machine — ApplicationServer crash loop from 2026-08-19 left services failed.
- [ ] After reboot: verify CC opens at `http://localhost/AMT175/ControlCenter`
- [ ] Verify AMT175 AFBUS_COBOL app is listed and started in CC
- [ ] Verify `Trial3\run\Run-Chaban.ps1` is still intact (last known-good harness)

---

## Phase 1 — Triage the 5 scripts

- [ ] Inspect each `.ps1` in Examples\Output\ — identify meaningful executable PS content vs mostly comments
- [ ] Pilot choice: `CHABAN_ASCII.ps1` — only script with a prior successful CC run (C# version) to compare against

| Script | SSG content converted | Notes |
|---|---|---|
| ARCHISEPARE.ps1 | $A-$E size calcs + *IF logic | Mostly orphaned COBOL data lines |
| CFH-COPY.ps1 | TBD | Needs inspection |
| UNLOADIS_ASCII.ps1 | SSG *IF/*SET logic | Also has COBOL->C# version from Phase 3 |
| CHABAN_ASCII.ps1 | SSG *IF/*SET logic | C# version ran successfully in CC |
| BABA_ASCII.ps1 | TBD | New program, no prior run |

---

## Phase 2 — Deploy pilot script (CHABAN_ASCII)

- [ ] Copy `CHABAN_ASCII.ps1` to AMT175 script path (same location as Run-Chaban.ps1)
- [ ] Create `AmtSettings.xml` for CHABAN_ASCII — file assignments from CHABAN param overrides (FICHOUT-1, NUMB, MOD, FLDSEL)
- [ ] Register the script in CC — **exact registration path unconfirmed, needs reference doc read**
- [ ] Confirm `AmtPsEclLib.psm1` / `AmtPsSortLib.psm1` deployed in AMT175 lane (scripts call GetSgsValue, DataLineOrNoStatement — will throw if library missing)

---

## Phase 3 — Run and verify

- [ ] Run via pwsh.exe 7.6.3 (NOT powershell.exe 5.1 — .NET 10 assemblies required)
- [ ] Compare FICHOUT-1 output with C# CHABAN output — should be equivalent
- [ ] Log pass/fail in Trial3_SSG_Conversion_Plan.md
- [ ] Update HTML report via templates\tools\Update-TrialProgress.ps1

---

## Open questions

1. Exact CC registration steps for a PS batch script (ComScript? BatchController? direct module?)
   — check `C:\Amt\AMT_ReferenceDocuments\AMT_ECLtoPowershell\Overview Batch Jobs in AMT - from ECL to PowerShell.md`
2. Is `AmtPsEclLib.psm1` / `AmtPsSortLib.psm1` deployed in the AMT175 lane already?

## Status: Phase 0 in progress
