# AMT177 SSG→PowerShell Trial Deployment Inventory

**Date:** 2026-09-08  
**Source Environment:** AMT172 / c:\Amt\Migration\  
**Target:** AMT177 VM (new deployment)

---

## Executive Summary

The entire SSG-COBOL → PowerShell conversion trial is **already packaged as a self-contained git repository** ready for distribution to AMT177. The Copilot session on the new VM can access it directly via git clone, or it can be bundled as a `.zip` for offline transfer if needed.

---

## Primary Deployment Object: SsgTrial-Transfer (Git Repository)

**Location:** `c:\Amt\Migration\SsgTrial-Transfer\`  
**Type:** Self-contained git repository  
**Status:** Ready to clone or bundle  
**Purpose:** Parallel conversion stream for 16 SSG-COBOL programs → PowerShell

### Quick Access via Git

```powershell
# On AMT177, if the repo is already accessible:
git clone <path-or-url> SsgTrial-Transfer
cd SsgTrial-Transfer
code SsgTrial.code-workspace
```

### Git Repository Structure

```
SsgTrial-Transfer/
├── .git/                          # Full git history
├── .github/                       # Copilot instructions/prompts
├── SsgTrial.code-workspace        # VS Code workspace config
├── README.md                      # Package overview + quick start
│
├── SsgConverter/                  # The converter tool (8.0.26188.0)
│   ├── README.md
│   ├── SsgConverter-COPILOT.md    # AI context file
│   ├── Build/
│   │   ├── Console/SsgConverterConsole.exe     (prebuilt)
│   │   └── Gui/SsgConverterGui.exe              (prebuilt)
│   ├── Source/                    # Full C# source code
│   ├── Examples/
│   │   ├── Input/                 # 5 sample SSG files
│   │   ├── Output/                # Expected .ps1 output
│   │   └── Settings/SsgConverterSettings-example.settings
│   └── Fixes/SsgConverter-Fix-20260820.md      # Fix log
│
├── Trial3/                        # Trial workspace (manifest-driven)
│   ├── README.md
│   ├── SsgTrial.code-workspace    # (copy of root)
│   ├── config/
│   │   └── pipeline.config.json   # ⚠️ EDIT PER MACHINE
│   ├── manifest/
│   │   └── programs.manifest.json # ✓ 16 programs, all validated
│   ├── tools/
│   │   ├── Run-EclPipeline.ps1
│   │   ├── Convert-SsgToLion.ps1
│   │   ├── Remove-SsgDirectives.ps1
│   │   └── refimpl/               # Reference oracle (Tier-1 proof)
│   │       ├── montant.ps1
│   │       ├── lectis.ps1
│   │       ├── tri_ascii.ps1
│   │       ├── architab1.ps1
│   │       ├── scan.ps1
│   │       ├── eclat.ps1
│   │       ├── compare2.ps1
│   │       ├── cfh-copy.ps1
│   │       ├── archiformat.ps1
│   │       ├── archisepare.ps1
│   │       ├── loadis_mult-nodup.ps1
│   │       ├── unloadis_mult.ps1
│   │       ├── unloadis_mult-nodup.ps1
│   │       └── tapeld_distrib.ps1
│   ├── settings/                  # Per-program .settings files
│   │   ├── trial-03-montant.settings
│   │   ├── trial-05-lectis.settings
│   │   ├── trial-06-sort-fichout-1.settings
│   │   ├── trial-07-architab1.settings
│   │   ├── trial-08-scan.settings
│   │   ├── trial-09-eclat.settings
│   │   ├── trial-10-compare2.settings
│   │   ├── trial-11-cfh-copy.settings
│   │   ├── trial-12-archisepare.settings
│   │   ├── trial-13-archiformat.settings
│   │   ├── trial-14-loadis-ascii.settings
│   │   ├── trial-15-unload-ascii.settings
│   │   ├── trial-16-unload-ascii-nodup.settings
│   │   └── trial-17-tapeld-distrib.settings
│   ├── candidates/                # Pre-processed COBOL (converted repo)
│   │   ├── trial-03-montant/
│   │   ├── trial-05-lectis/
│   │   ├── trial-06-tri-ascii/
│   │   ├── trial-07-architab1/
│   │   ├── trial-08-scan/
│   │   ├── trial-09-eclat/
│   │   ├── trial-10-compare2/
│   │   ├── trial-11-cfh-copy/
│   │   ├── trial-12-archisepare/
│   │   ├── trial-13-archiformat/
│   │   ├── trial-14-loadis-ascii/
│   │   ├── trial-15-unload-ascii/
│   │   ├── trial-16-unload-ascii-nodup/
│   │   └── trial-17-tapeld-distrib/
│   ├── fixtures/                  # Tier-1 proof input/expected files
│   │   ├── montant/
│   │   ├── lectis/
│   │   ├── tri_ascii/
│   │   ├── architab1/
│   │   ├── scan/
│   │   ├── eclat/
│   │   ├── compare2/
│   │   ├── cfh-copy/
│   │   ├── archiformat/
│   │   ├── archisepare/
│   │   ├── LOADIS_MULT-NODUP/
│   │   ├── UNLOADIS_MULT/
│   │   ├── UNLOADIS_MULT-NODUP/
│   │   └── TAPELD_DISTRIB/
│   ├── macros/
│   │   └── ssg-stub.macros.xml
│   ├── output/                    # Generated .LionSource (git-ignored)
│   ├── SSGConverter_Output/
│   ├── SSGConverter_Output_log/
│   ├── SSG_CobolConveter_Output/
│   ├── _baseline/
│   ├── _coboldeps/
│   ├── SSG_All_20_Ranked.md
│   ├── SSG_QUICK_REFERENCE.md
│   ├── SSG_COMPLEXITY_REPORT.md
│   └── SSG_Complexity_Metrics.csv
│
├── SSG-Source/                    # Raw OS2200 SSG/COBOL source (input)
│   ├── ASSURFED_UTILIT_MONTANT_SIGNE(P).TXT
│   ├── ASSURFED_UTILIT_LECTIS_MULT(P).TXT
│   ├── ASSURFED_UTILIT_TRI_ASCII(P).TXT
│   ├── ASSURFED_UTILIT_ARCHITAB1(P).TXT
│   ├── ASSURFED_UTILIT_SCAN-VAR_ASCII(P).TXT
│   ├── ASSURFED_UTILIT_ECLAT(P).TXT
│   ├── ASSURFED_UTILIT_COMPARE2_ASCII(P).TXT
│   ├── ASSURFED_UTILIT_CFH-COPY(P).TXT
│   ├── ASSURFED_UTILIT_ARCHIFORMAT(P).TXT
│   ├── ASSURFED_UTILIT_ARCHISEPARE(P).TXT
│   ├── ASSURFED_UTILIT_LOADIS_MULT-NODUP(P).TXT
│   ├── ASSURFED_UTILIT_UNLOADIS_MULT(P).TXT
│   ├── ASSURFED_UTILIT_UNLOADIS_MULT-NODUP(P).TXT
│   └── ASSURFED_UTILIT_TAPELD_DISTRIB(P).TXT
│
└── docs/                          # Reference guides (HTML/MD)
    ├── AMT172-Setup-Guide.md
    ├── AMT172-Setup-Guide.html
    ├── AMT175-Setup-Guide.html
    ├── SSG-COBOL-Reference.html
    ├── SSG-ECL-Command-Matrix.html
    ├── SSG-ECL-PowerShell-Reference.html
    └── SSG-Trial-Progress.html
```

---

## The 16 Trial Programs

All defined in `Trial3/manifest/programs.manifest.json`. Status: **ALL VALIDATED (done)** ✓

| # | Key | Program Name | Source File | Settings File | Status |
|---|-----|--------------|-------------|---------------|--------|
| 1 | MONTANT | MONTANT_SIGNE (numeric) | ASSURFED_UTILIT_MONTANT_SIGNE(P).TXT | trial-03-montant.settings | ✓ PASS |
| 2 | LECTIS | LECTIS_MULT (multi-key) | ASSURFED_UTILIT_LECTIS_MULT(P).TXT | trial-05-lectis.settings | ✓ PASS |
| 3 | TRI_ASCII | SORT (sort utility) | ASSURFED_UTILIT_TRI_ASCII(P).TXT | trial-06-sort-fichout-1.settings | ✓ PASS |
| 4 | ARCHITAB1 | ARCHITAB1 (table) | ASSURFED_UTILIT_ARCHITAB1(P).TXT | trial-07-architab1.settings | ✓ PASS |
| 5 | SCAN | SCAN (pattern scan) | ASSURFED_UTILIT_SCAN-VAR_ASCII(P).TXT | trial-08-scan.settings | ✓ PASS |
| 6 | ECLAT | ECLAT (merge) | ASSURFED_UTILIT_ECLAT(P).TXT | trial-09-eclat.settings | ✓ PASS |
| 7 | COMPARE2 | COMPARE2_ASCII (compare) | ASSURFED_UTILIT_COMPARE2_ASCII(P).TXT | trial-10-compare2.settings | ✓ PASS |
| 8 | CFH-COPY | CFH-COPY (file copy) | ASSURFED_UTILIT_CFH-COPY(P).TXT | trial-11-cfh-copy.settings | ✓ PASS |
| 9 | ARCHISEPARE | ARCHISEPARE (separator) | ASSURFED_UTILIT_ARCHISEPARE(P).TXT | trial-12-archisepare.settings | ✓ PASS |
| 10 | ARCHIFORMAT | ARCHIFORMAT (formatter) | ASSURFED_UTILIT_ARCHIFORMAT(P).TXT | trial-13-archiformat.settings | ✓ PASS |
| 11 | LOADIS_MULT-NODUP | LOADIS (load IS) | ASSURFED_UTILIT_LOADIS_MULT-NODUP(P).TXT | trial-14-loadis-ascii.settings | ✓ PASS |
| 12 | UNLOADIS_MULT | UNLOADIS (unload IS) | ASSURFED_UTILIT_UNLOADIS_MULT(P).TXT | trial-15-unload-ascii.settings | ✓ PASS |
| 13 | UNLOADIS_MULT-NODUP | UNLOADIS-NODUP | ASSURFED_UTILIT_UNLOADIS_MULT-NODUP(P).TXT | trial-16-unload-ascii-nodup.settings | ✓ PASS |
| 14 | TAPELD_DISTRIB | TAPELD (copy variant) | ASSURFED_UTILIT_TAPELD_DISTRIB(P).TXT | trial-17-tapeld-distrib.settings | ✓ PASS |
| 15 | (reserved) | — | — | — | — |
| 16 | (reserved) | — | — | — | — |

---

## Network Accessibility Checklist

### Scenario A: Shared Network Path  
**If AMT172 and AMT177 are on the same network:**

✓ **Direct git clone:** 
```powershell
git clone file:///\\amtshare\migration\SsgTrial-Transfer
```

✓ **Mapped drive:**
```powershell
git clone Z:\Amt\Migration\SsgTrial-Transfer
```

✓ **Copilot on AMT177 can see it:** YES (if network path is accessible)

---

### Scenario B: No Direct Network Access  
**If AMT177 is isolated or on a different network:**

✗ **Copilot on AMT177 can see it:** NO  
✓ **Solution: Bundle as .zip and transfer**

#### Step 1: Create deployment package on AMT172

```powershell
cd c:\Amt\Migration
# Remove large build artifacts to reduce size
Remove-Item SsgTrial-Transfer\Trial3\output -Recurse -Force
Remove-Item SsgTrial-Transfer\Trial3\SSGConverter_Output* -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item SsgTrial-Transfer\Trial3\_baseline -Recurse -Force -ErrorAction SilentlyContinue

# Create zip (with git metadata intact)
Compress-Archive -Path SsgTrial-Transfer -DestinationPath SsgTrial-Transfer-DEPLOYMENT-2026-09-08.zip

# Verify size
(Get-Item SsgTrial-Transfer-DEPLOYMENT-2026-09-08.zip).Length / 1MB
```

**Expected package size:** ~35–50 MB (pre-built exes included)

#### Step 2: Transfer to AMT177

- **USB Drive:** Copy `.zip` to USB
- **Network share:** If temporary access exists, copy to intermediate server
- **Cloud storage:** Upload to shared OneDrive/Teams if available

#### Step 3: Extract and configure on AMT177

```powershell
# Extract
Expand-Archive -Path SsgTrial-Transfer-DEPLOYMENT-2026-09-08.zip -DestinationPath c:\Amt\Migration\

# Initialize git (optional; re-enable history)
cd c:\Amt\Migration\SsgTrial-Transfer
git status  # Should show the full history

# Configure for local machine
.\Copilot_on_AMT177_NEXT_STEPS.md  # See below
```

---

## Pre-Deployment Configuration Template

**File to edit on AMT177 after extraction:**  
`Trial3/config/pipeline.config.json`

```json
{
  "converterConsolePath": "C:\\Amt\\Migration\\SsgTrial-Transfer\\SsgConverter\\Build\\Console\\SsgConverterConsole.exe",
  "globalCopyDir": "C:\\Amt\\Codedrop 2025\\CopyPrd",  /* ← Adjust to AMT177 paths */
  "ssgSourceDir": "C:\\Amt\\Migration\\SsgTrial-Transfer\\SSG-Source",
  "candidateDir": "C:\\Amt\\Migration\\SsgTrial-Transfer\\Trial3\\candidates",
  "outputDir": "C:\\Amt\\Migration\\SsgTrial-Transfer\\Trial3\\output",
  "settingsTemplateDir": "C:\\Amt\\Migration\\SsgTrial-Transfer\\Trial3\\settings"
}
```

**Key paths to verify on AMT177:**
- `globalCopyDir` — must point to shared COBOL copybook repository (e.g., `Codedrop 2025\CopyPrd` from mainframe source)
- `converterConsolePath` — should be correct as-is (uses relative path in package)

---

## What the Copilot on AMT177 Can Access

### ✓ Always Accessible (within SsgTrial-Transfer)

1. **SsgConverter tool**
   - Pre-built Console/GUI executables (no build needed)
   - C# source code (if rebuild required)
   - Settings examples

2. **Trial3 workspace**
   - Manifest (all 16 programs fully defined)
   - Settings files (per-program configuration)
   - Pre-processed candidate COBOL files
   - Tier-1 proof fixtures (input/expected)
   - Reference oracle scripts (refimpl/*.ps1)
   - PowerShell pipeline scripts

3. **Raw SSG source files**
   - All 14 source files (ASSURFED_UTILIT_*.TXT)

4. **Reference documentation**
   - HTML guides (SSG-COBOL-Reference, SSG-ECL-PowerShell-Reference, etc.)
   - Setup guides (AMT172/AMT175)
   - Copilot instructions (.github/)

### ✗ NOT in Package (May Need External Access)

1. **CobolConverterConsole.exe** (from AMT core)
   - Must be installed on AMT177 separately
   - Path configured in `pipeline.config.json`

2. **Global COBOL copybook repository**
   - `Codedrop 2025\CopyPrd` from mainframe source corpus
   - Must exist on AMT177 or be mounted from shared drive

3. **AMT172/AMT175 application binaries**
   - Not included (scope: trial workspace only)

---

## Verification Checklist for Copilot on AMT177

After extracting SsgTrial-Transfer, run this verification:

```powershell
cd c:\Amt\Migration\SsgTrial-Transfer

# 1. Check folder structure
Test-Path "SsgConverter\Build\Console\SsgConverterConsole.exe"  # Should be TRUE
Test-Path "Trial3\manifest\programs.manifest.json"              # Should be TRUE
Test-Path "Trial3\tools\Run-EclPipeline.ps1"                    # Should be TRUE
Test-Path "SSG-Source\ASSURFED_UTILIT_MONTANT_SIGNE(P).TXT"     # Should be TRUE

# 2. Validate manifest
$manifest = Get-Content Trial3\manifest\programs.manifest.json | ConvertFrom-Json
$manifest.programs.Length  # Should be 14 (reserving 15-16)

# 3. Check all settings files exist
$manifest.programs | ForEach-Object {
  $settingsPath = "Trial3\settings\$($_.settingsFile)"
  if (-not (Test-Path $settingsPath)) {
    Write-Warning "Missing: $settingsPath"
  }
}

# 4. List refimpl oracles
Get-ChildItem Trial3\tools\refimpl\*.ps1 | Measure-Object  # Should show 14 files

# 5. Display quick start
Get-Content README.md -Head 50
```

---

## Deployment Timeline

1. **Quick access via git (if network path accessible):** ✓ **Immediate** (0 minutes)
2. **Bundle as .zip and transfer:** ~**30 minutes** (compress, transfer, extract, configure)
3. **Full validation run (14 programs Tier-1 proof):** ~**15–20 minutes** (depends on compute)

---

## Support Resources

| Need | Location |
|------|----------|
| **Get started guide** | `SsgTrial-Transfer/README.md` |
| **How to run the pipeline** | `SsgTrial-Transfer/Trial3/README.md` |
| **SsgConverter tool docs** | `SsgTrial-Transfer/SsgConverter/README.md` |
| **AI context for SsgConverter** | `SsgTrial-Transfer/SsgConverter/SsgConverter-COPILOT.md` |
| **Copilot instructions for the trial** | `SsgTrial-Transfer/.github/instructions/` |
| **Reference: SSG/COBOL patterns** | `docs/SSG-COBOL-Reference.html` |
| **Reference: ECL/PowerShell execution** | `docs/SSG-ECL-PowerShell-Reference.html` |
| **Trial progress tracker** | `docs/SSG-Trial-Progress.html` |

---

## Contact & Questions

If the Copilot on AMT177 cannot access the git repository or has issues with the bundle:

1. **Verify network connectivity** → Try manual git clone with full URL
2. **Check path permissions** → Ensure read access to source and write access to destination
3. **Review configuration** → Edit `Trial3/config/pipeline.config.json` and re-run `Run-EclPipeline.ps1 -ListOnly`
4. **Consult reference docs** → All 14 programs have worked examples in the fixtures and reference implementations

---

**Generated:** 2026-09-08  
**Package:** SsgTrial-Transfer (git repository)  
**Status:** Ready for distribution to AMT177  
**Next Action:** Provide git URL or .zip file to AMT177 Copilot session
