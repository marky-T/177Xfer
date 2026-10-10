# Trial Setup Guide

Step-by-step process for converting one SSG/COBOL program through the full Trial 3 pipeline.

## Prerequisites

- `CobolConverterConsole.exe` runnable (see [README.md](README.md) for path)
- `Remove-SsgDirectives.ps1` available at `C:\Amt\Migration\Templates\`
- Source file exists in `C:\Amt\MainframeSource\2026-07-07_SSG\CreatingCobol\<PROGRAM>.TXT`
- (Overlap programs) Trial 2 source diffed against new drop — discrepancies noted

---

## Step 1 — Source Analysis

1. Open `C:\Amt\MainframeSource\2026-07-07_SSG\CreatingCobol\<PROGRAM>.TXT`
2. Record:
   - `PROGRAM-ID.` value (used for candidate filename and settings file)
   - All SSG directives: `*IF`/`*ELSE`/`*END`, `*SET`, `*DEFINE`, `*LOOP`, `*INCREMENT`
   - All ECL tokens: `[INPUT,x,x,x]`, `[OUTPUT,x,x,x]`, `[LKEY,x,x,x]`, custom tokens
   - Conditional branches — note which conditions must be true/false for your variant
3. Choose `paramOverrides` (concrete values for each `[TOKEN]`) and `conditionValues` (true/false for each `*IF` condition)
4. Prefer the ASCII variant where applicable (`ASCII=1`)

---

## Step 2 — Pilot Script

1. Copy `C:\Amt\Migration\Templates\trial-pilot-template.ps1` → `Trial3\tools\Run-Pilot-<PROGRAM>.ps1`
2. Fill in `$programKey`, `$programId`, `$paramOverrides`, `$conditionValues`
3. Create settings file path: `Trial3\settings\trial3-NN-<programid-lowercase>.settings`

---

## Step 3 — Run the Pipeline

```powershell
cd C:\Amt\Migration\Trial3\tools
.\Run-Pilot-<PROGRAM>.ps1
```

Check:
- `candidates\trial3-<programid>\<PROGRAM-ID>.TXT` — no residual `[token]` patterns
  ```powershell
  Select-String '\[' candidates\trial3-<programid>\<PROGRAM-ID>.TXT
  ```
- `output\trial3-<programid>.LionSource` — non-zero size; contains `<OBJECT=<PROGRAM-ID>,COBOL PROGRAM>`

---

## Step 4 — Fixtures

```
fixtures\<key-lowercase>\
    input.dat       # hand-crafted test input matching inputSpec
    expected.dat    # hand-derived golden output
    assign.json     # { "FICHIN-1": "input.dat", "FICHOUT-1": "output.dat", ... }
```

Verify byte counts:
```powershell
(Get-Item fixtures\<key>\expected.dat).Length
```

---

## Step 5 — Refimpl Oracle

1. Write `tools\refimpl\<key-lowercase>.ps1` — PowerShell that mimics program logic
2. Run standalone; confirm output bytes match `expected.dat`
3. Only proceed to proof once standalone match is confirmed

---

## Step 6 — Proof

```powershell
.\Run-EclProof.ps1 -Program <PROGRAM-ID>
# Expected: PASS diff=0
```

---

## Step 7 — Manifest

Update `manifest\programs.manifest.json`:

```json
{
  "key": "<PROGRAM_KEY>",
  "status": "done",
  "proof": {
    "executor": "refimpl",
    "refImpl": "tools/refimpl/<key-lowercase>.ps1",
    "fixtureDir": "fixtures/<key-lowercase>",
    "inputSpec": "<describe input format and column layout>",
    "fileAssignments": { "FICHIN-1": "input.dat" },
    "expectedFile": "fixtures/<key-lowercase>/expected.dat",
    "notes": "<proof methodology>"
  }
}
```

---

## Step 8 — HTML Generation via Templates

1. Prepare trial JSON at `C:\Amt\Parallel\templates\examples\trial-03-<name>_v1.json`  
   (conforming to `C:\Amt\Parallel\templates\schema_v1.json`)
2. Run fill scripts:
   ```powershell
   cd C:\Amt\Parallel\templates\tools
   .\Update-TrialProgress.ps1     -ContentFile ../examples/trial-03-<name>_v1.json -OutputDir ../output
   .\Update-CommandMatrix.ps1     -ContentFile ../examples/trial-03-<name>_v1.json -OutputDir ../output
   .\Update-PowerShellReference.ps1 -ContentFile ../examples/trial-03-<name>_v1.json -OutputDir ../output
   ```
3. Validate each output:
   ```powershell
   .\Validate-TrialHTML.ps1 -HtmlFile ../output/SSG-Trial-Progress_<timestamp>.html
   ```
4. Add `htmlGenerationConfig` to manifest entry

---

## Naming conventions

| Item | Convention | Example |
|------|-----------|---------|
| programKey | SSG element name (uppercase) | `UNLOADIS_ASCII` |
| programId | COBOL PROGRAM-ID | `UNLOAD-ASCII` |
| candidateDir | `trial3-<programid-lowercase>` | `trial3-unload-ascii` |
| settingsFile | `trial3-NN-<programid-lowercase>.settings` | `trial3-15-unload-ascii.settings` |
| fixtureDir | `fixtures/<key-lowercase>/` | `fixtures/unloadis_ascii/` |
| refImpl | `tools/refimpl/<key-lowercase>.ps1` | `tools/refimpl/unloadis_ascii.ps1` |
