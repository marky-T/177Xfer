# Done / open items extracted from SSG-ECL-PowerShell-Reference.html

Source: `01-docs-html/Migration/SSG-ECL-PowerShell-Reference.html` (original: `C:\Amt\Migration\SSG-ECL-PowerShell-Reference.html`)

18 done / 16 not done (HTML status badges)

## 2 · Execution Model — Execute vs. Orchestrate

| Layer | What it does | Needed to run MONTANT's logic? |
|---|---|---|
| AMT .NET runtime (the C# framework) | Actually executes the converted program — the file `READ`/`WRITE`, the `COMPUTE`, the sort API, indexed-file I/O | Yes — this is what runs the code |
| AMT PowerShell ECL framework (`AmtPsEclLib`) | Job control migrated from the ECL runstream: sets up file assignments (`FILEIN-1` → a path), then `Xqt`s the program via the BatchController | No — it kicks off and wires the program; it does not run the COBOL logic |

## Three proof tiers

| Tier | What runs | PowerShell / AMT stack? |
|---|---|---|
| Tier 1 — mock-shell now | A thin harness that stands in for the PowerShell + BatchController orchestration — it provides the input/output files directly and runs the logic (reference oracle now). Proves report contents. | None needed |
| Tier 2 — AMT .NET runtime done | Runs the actual converted C# under the AMT .NET runtime — the deployed program DLL is `Xqt`ed by the Control Center BatchController as a real batch job (app `AFBUS_2200COBOL`). Proven end-to-end (2026-07-18): MONTANT ran Queued → Running → Completed and its output was byte-identical to the Tier-1 golden. Inputs/outputs resolve as `%SYSROOT%\Files\Extracts\<designator>.DAT` — stage each fixture input there and collect the output from the same place. See §6b Control Center Runbook. | AMT .NET runtime + Control Center (no PowerShell ECL needed) |
| Tier 3 — full PowerShell ECL orchestration optional | Run the converted PowerShell ECL script that sets file assignments and `Xqt`s the program through the BatchController — reproducing the real operational invocation. | This is where `AmtPsEclLib` is actually used |

## Marker & lineage convention

| Marker | Form | Where | Reaches AMT / C#? | Status |
|---|---|---|---|---|
| Code lineage | `ECL_` / `SSG_` prefix on stub identifiers | annotated COBOL stubs → `.LionSource` → generated `.cs` | Yes (when applied) | From Trial 07 |
| Documentation | `ECLREF` HTML-comment pairs; `eclref-` on new ids/classes | inserted fragments in the guide / this reference set | No | Active |

## 7 · Tier 2 testability map (deployed programs)

| Program (JOBID) | Designators (`Files.cs`) | Tier 2 status |
|---|---|---|
| MONTANT_SIGNE (740) | `ECL-TAPEIN, ECL-TAPEOUT` | ✓ PASS diff=0 |
| CFH_COPY (737) | `ECL-TAPEIN, ECL-TAPEOUT` | ✓ PASS diff=0 |
| ARCHITAB1 (1002) | `1` (single output) | struct pure output; param divergence |
| LOADIS_MULT_NODUP (739) | `ECL-TAPEIN, ECL-TAPEOUT` | exec-only indexed output (see note) |
| ARCHIFORMAT (736) | `1, 1, 1, 1` (all collide) | blocked needs regen |
| COMPARE2_ASCII (738) | `ECL-TAPEIN, 80` | blocked IN2 designator = 80 |
| TAPELD_DISTRIB (741) | `ECL-TAPEIN` (no output) | blocked output designator missing |
| TRI_ASCII (742) | `…SORTFILE, 1, ECL-TAPEOUT` | blocked input designator = 1 |

## Testability map (all 10 programs, 2026-09-18)

| Program | Emitted lines | Warnings | Baseline on our side? | Status | Run via CC? |
|---|---|---|---|---|---|
| ARCHIFORMAT | 0 (by design) | 0 | trial-13-archiformat (SET-values only) | ✓ PASS | ✓ JOBID 1003 |
| CFH-COPY | 45 | 0 | trial-11-cfh-copy | ✓ PASS structural parity | ✓ RequestId 1040 |
| ARCHISEPARE | 143 | 0 | trial-12-archisepare (208 lines) | diverges 85 diff rows | ✓ JOBID 1003 |
| LOADIS_ASCII | 69 | 0 | trial-14-loadis-ascii (65 lines) | diverges 108 diff rows | ✓ JOBID 1003 |
| LOADIS_MULTI | 96 | 0 | trial-14-loadis-ascii (65 lines) | diverges 141 diff rows | ✓ JOBID 1003 |
| UNLOADIS_ASCII | 63 | 0 | trial-15-unload-ascii (65 lines) | diverges 98 diff rows | ✓ JOBID 1003 |
| UNLOADIS_MULTI | 64 | 0 | trial-16-unload-ascii-nodup (65 lines) | diverges 123 diff rows | ✓ JOBID 1003 |
| CHAB100_ASCII | 212 | 0 | none — new program | ran clean unverified | ✓ JOBID 1003 |
| CHABAN_ASCII | 132 | 0 | none — new program | ran clean unverified | ✓ JOBID 1003 |
| BABA_ASCII | 48 | 30 | none — new program | weak seed values incomplete | ✓ JOBID 1003 |
