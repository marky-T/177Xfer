# AMT172 SSG-COBOL Migration Pipeline — Shared Reference

This folder contains the **definitive reference documentation and core tools** for the Federale SSG-COBOL-to-C# migration pipeline. All files are ready for handoff, sharing, and team onboarding.

---

## Reference Documentation

### **AMT172-Setup-Guide.html**
Complete installation and infrastructure setup for AMT 172 RC1, Keycloak, SQL Server, Control Center, and LionDev.
Covers 11 phases from database provisioning to COBOL deployment, with troubleshooting and credential summary. **[Credentials obfuscated]**

### **SSG-ECL-PowerShell-Reference.html**
Authoritative runbook for the pre-processor pipeline: `Remove-SsgDirectives.ps1` → `Convert-SsgToLion.ps1` → `CobolConverterConsole.exe`.
Covers execution model (3 proof tiers), ECL parameter substitution, SSG condition handling, and 17+ worked trial examples (MONTANT through TAPELD).

### **SSG-COBOL-Reference.html**
Deep technical reference for SSG-COBOL syntax transformation patterns, macro expansion, COBOL-compatibility quirks, and generated C# tier mappings.
Documents the actual program behaviors, file I/O semantics, and traceability from SSG template → converted COBOL → LionSource → C#.

### **SSG-ECL-Command-Matrix.html**
Quick-reference matrix of ECL directives, SSG macro directives, and their pre-processor handling rules.
Maps ECL job-control constructs to PowerShell equivalents and shows which patterns trigger which pipeline capabilities.

### **SSG-Trial-Progress.html**
Status dashboard of all 17+ program migration trials, including completion markers, test results, and known issues.
Visual roadmap showing which programs have passed Tier-1, Tier-2, or LionSource conversion stages.

---

## Pipeline Tools

### **Remove-SsgDirectives.ps1**
Core SSG macro preprocessing engine that strips directives (*IF/*DEFINE/*INCREMENT), substitutes [ECL_param] tokens, and handles multi-variant SSG sources.
Supports 17+ directive patterns, N-operand arithmetic, condition stacks, branchTaken flags, and -AnnotateStubs traceability comments. **~12KB, production-grade**

### **Convert-SsgToLion.ps1**
Orchestrator wrapper that drives the full pipeline: reads .settings JSON → invokes Remove-SsgDirectives.ps1 → calls CobolConverterConsole.exe → reports output.
Accepts -ParamOverrides and -ConditionValues hashtables to customize each program run. **~6KB, stable**

### **ssg-stub.macros.xml**
Safety-net macro stubs for residual bare-word tokens not captured by [param] patterns.
Tracks inventory of catch-all substitutions (e.g. FILLUN→01, FILLDEU→01) to prevent converter errors; updated per program family.

### **Federale_CC_Startup.ps1**
Bootstrap script that starts the complete Control Center stack in dependency order: Keycloak → IIS → AmtFileController → AmtBatchController → AmtApplicationServer.
Elevated privileges required; includes service health checks and known-issue recovery steps. **[Credentials obfuscated in this copy; original unchanged]**

---

## Quick Start

### **For Reference Lookups**
1. **Pipeline architecture?** → `SSG-ECL-PowerShell-Reference.html` §2 (Execution Model)
2. **COBOL transformation patterns?** → `SSG-COBOL-Reference.html` (search by directive or file type)
3. **Which programs work?** → `SSG-Trial-Progress.html` (visual status board)
4. **Setup steps?** → `AMT172-Setup-Guide.html` (11-phase checklist)

### **For Running a Conversion**
```powershell
# Example: Convert MONTANT_SIGNE (trial-03)
.\Convert-SsgToLion.ps1 `
  -SettingsFile "C:\Amt\Migration\CobolConvert\settings\trial-03-montant.settings" `
  -RawSourceDir "C:\Amt\MainframeSource\Codedrop 2025\SSG Prd\SSG Creating COBOL" `
  -ParamOverrides @{
      '[INPUT,1,1,1]'  = 'FILEIN-1'
      '[INPUT,1,1,2]'  = '80'
      '[OUTPUT,1,1,1]' = 'FILEOUT-1'
  } `
  -ConditionValues @{ 'ASCII' = 1 }
```

### **For Tier-2 (Control Center) Testing**
1. Start stack: `Federale_CC_Startup.ps1` (elevated)
2. Stage fixture: `Copy-Item input.dat "C:\Amt\Working\Lion\Files\Extracts\ECL-TAPEIN.DAT"`
3. CC UI: Jobs → Start Job → select program → Start
4. Collect output: `Copy-Item "C:\Amt\Working\Lion\Files\Extracts\ECL-TAPEOUT.DAT" output.dat`
5. Validate: `diff output.dat expected.dat` (mask date fields if applicable)

---

## Credential Safety

⚠️ **This folder contains obfuscated credentials for sharing.**

| Original File | Shared File | Obfuscated |
|---|---|---|
| `c:\Amt\Migration\tools\Federale_CC_Startup.ps1` | `Federale_CC_Startup.ps1` | ✅ Passwords → `[***OBFUSCATED_PASSWORD***]` |
| `c:\Amt\Migration\AMT172-Setup-Guide.html` | `AMT172-Setup-Guide.html` | ✅ Credentials → placeholders |

**Original source files remain unchanged.** Restore real credentials locally before running scripts.

---

## File Sizes & Metadata

| File | Size | Type | Purpose |
|------|------|------|---------|
| AMT172-Setup-Guide.html | 287 KB | Reference | Full infrastructure setup guide |
| SSG-ECL-PowerShell-Reference.html | 102 KB | Reference | Pipeline + pre-processor runbook |
| SSG-COBOL-Reference.html | 85 KB | Reference | Program transformation patterns |
| SSG-ECL-Command-Matrix.html | 81 KB | Reference | Directive mapping matrix |
| SSG-Trial-Progress.html | 25 KB | Reference | Trial status dashboard |
| Remove-SsgDirectives.ps1 | 12 KB | Script | Core preprocessing engine |
| Federale_CC_Startup.ps1 | 8 KB | Script | Control Center bootstrap |
| Convert-SsgToLion.ps1 | 6 KB | Script | Pipeline orchestrator |
| ssg-stub.macros.xml | 4 KB | Config | Macro stub inventory |

**Total: ~610 KB** — compact, self-contained, ready for distribution.

---

## Support & Troubleshooting

- **Pre-processor issues?** → `SSG-ECL-PowerShell-Reference.html` §7 (Troubleshooting)
- **Converter errors?** → `SSG-COBOL-Reference.html` (search error code)
- **Control Center won't start?** → `Federale_CC_Startup.ps1` comments + §5 (Known Gotchas)
- **Program-specific help?** → `SSG-Trial-Progress.html` (find trial number) → look up in reference

---

**Last Updated:** 2026-08-12  
**AMT Version:** 8.0.26125.0 RC1  
**Platform:** Federale Migration (SSG-COBOL → Lion → C#)
