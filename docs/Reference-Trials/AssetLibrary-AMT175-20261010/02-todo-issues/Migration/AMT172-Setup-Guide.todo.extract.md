# Done / open items extracted from AMT172-Setup-Guide.html

Source: `01-docs-html/Migration/AMT172-Setup-Guide.html` (original: `C:\Amt\Migration\AMT172-Setup-Guide.html`)

12 done / 2 not done (HTML status badges)

## Migration Pipeline Status

| # | Tool | Input | Output | Time | Status |
|---|---|---|---|---|---|
| 1 | SplitPModel | prd.model (834MB) | PModelOut (8,241 files) | 49s | ✓ Done |
| 2 | AbSuiteUnloadGui | ModelRepos (SQL) | UnloadOut (8,245 files) | 3m 17s | ✓ Done |
| 3 | LincToLionGui → AB Suite Load | UnloadOut | WORKING_LINC | 47m 3s | ✓ Done |
| 4 | LionDevGenNet → C# Gen | WORKING_REPOS + .LionSource | C# source (AFBUS_COBOL) | 5m 35s build | ✓ Done |
| 4b | dotnet runtime trial | FILEIN-1.DAT (80-char records) | FILEOUT-1.DAT (246 bytes) | 2.5s | ✓ Done |
| 5 | CobolConverterGui | ProgPrd COBOL (3,246 files) | Converted output | — | ✓ Done |
| 6 | ApplicationCenter setup | — | amt-ac Keycloak clients | — | ⌛ Pending |

## Phase 10 — LionDevGenNet C# Generation

| # | Step | Tool | Time | Status |
|---|---|---|---|---|
| 1 | Convert To LION (WORKING_LINC → WORKING_REPOS) | LincToLionGui | 25m 23s | ✓ Done |
| 2 | Install & start LionDevNet_Generator service | sc.exe create | — | ✓ Done |
| 3 | Generate C# from WORKING_REPOS | LionDev.exe | — | ✓ Done |
| 4 | Register AFBUS + Reorganize database | Control Center + AmtReorganize | 2h 0m (+4h debug) | ✓ Done |

## Trial Results (2026-06-16)

| Trial | Source | Type | Errors | Output | Result |
|---|---|---|---|---|---|
| Trial 01 | `UPRD_SRC_R1105.txt` | Pure COBOL subprogram (22 lines) | 0 | `trial-01.lionsrc` — 5,502 bytes | ✓ Clean |
| Trial 02 | `ASSURFED_UTILIT_COMPARE2_ASCII(P).TXT` | SSG-generated COBOL (`*DEFINE`/`*IF` macros) | 104 | `trial-02-ssg.lionsrc` — 22,188 bytes | ⚠ Partial |
| Trial 03 | `ASSURFED_UTILIT_MONTANT_SIGNE(P).TXT` | SSG-COBOL + Option A: `Remove-SsgDirectives.ps1` pre-processor 64→47 lines: 17 SSG lines stripped, 19 token substitutions | 0 | `trial-03-montant.LionSource` — 6,582 bytes | ✓ Clean |
