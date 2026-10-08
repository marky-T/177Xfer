# Batch Harness Patterns — AmtPsEclLib / AmtSettings.xml

Reference for the PowerShell batch stream (Phase 2 / SsgConverter output).

> **Note (2026-08-18):** Phase 2 (SSG → PowerShell via SsgConverter) is **PARKED** for the
> 2026-07-07 drop — the drop contains only `CreatingCobol\` (COBOL-gen SSG), not batch symstreams.
> Revisit if a batch runstream/symstream folder is supplied.
> This document captures the pattern for when it does become needed.

## Stream overview

```
SSG batch symstream (.TXT)
    └─ SsgConverterConsole /INPUT:<folder> /OUTPUT:<folder>
           └─ generated .ps1 (uses AmtPsEclLib.psm1)
                  └─ AmtSettings.xml  (file assignments, job params)
                         └─ CC BatchController → runs .ps1
```

## SsgConverterConsole

**Path:** `C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\SsgConverter\SsgConverter\SsgConverterConsole\bin\Debug\net10.0\SsgConverterConsole.exe`

**CLI:**
```
SsgConverterConsole /INPUT:<folder> /OUTPUT:<folder> [/SETTINGSFILE:<file>]
    [/CLEAROUTPUT:TRUE] [/CONTINUEONERROR:TRUE]
    [/VERBOSE:0-3] [/LOGFILE:<path>] [/ENABLELOGFILE:TRUE]
```

**Detection rule:** First non-empty line starts with `#` or `*` = SSG symstream.  
**Wrong input:** `CreatingCobol\` files (COBOL-gen SSG) → CRASH `Index was outside the bounds of the array`

## AmtPsEclLib.psm1

Location: `C:\Amt\Parallel\AMT175\AmtTools\` (or equivalent lane)

Key functions (from `AMT_ECLtoPowershell\Overview Batch Jobs in AMT - from ECL to PowerShell.md`):

| Function | ECL equivalent |
|----------|---------------|
| `Open-AmtFile` | OPEN ECL statement |
| `Read-AmtFile` | READ ECL statement |
| `Write-AmtFile` | WRITE ECL statement |
| `Close-AmtFile` | CLOSE ECL statement |
| `Sort-AmtFile` | SORT ECL statement |

## AmtSettings.xml template

```xml
<?xml version="1.0" encoding="utf-8"?>
<AmtSettings>
  <JobName>REPLACE_JOB_NAME</JobName>
  <Files>
    <File>
      <LogicalName>FICHIN-1</LogicalName>
      <PhysicalName>$(InputDir)\input.dat</PhysicalName>
      <RecordLength>80</RecordLength>
    </File>
    <File>
      <LogicalName>FICHOUT-1</LogicalName>
      <PhysicalName>$(OutputDir)\output.dat</PhysicalName>
      <RecordLength>80</RecordLength>
    </File>
  </Files>
</AmtSettings>
```

## References

- `C:\Amt\AMT_ReferenceDocuments\AMT_ECLtoPowershell\Overview Batch Jobs in AMT - from ECL to PowerShell.md`
- `C:\Amt\AMT_ReferenceDocuments\AMT_LionReferenceDocs\` — ALPD, AICL
- `C:\Amt\Parallel\AMT175\.github\Copilot_Plans\Trial3_SSG_Conversion_Plan.md` — Phase 2 discovery notes
