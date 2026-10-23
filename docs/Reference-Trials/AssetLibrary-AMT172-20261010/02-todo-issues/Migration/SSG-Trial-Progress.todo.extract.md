# Done / open items extracted from SSG-Trial-Progress.html

Source: `01-docs-html/Migration/SSG-Trial-Progress.html` (original: `C:\Amt\Migration\SSG-Trial-Progress.html`)

11 done / 16 not done (HTML status badges)

## 2 · The 16 Programs — Trial Progress

| Program | Category | Likely Purpose | A — SSG-ECL Pipeline (Convert+Proof Tier-1) | B — AMT Runtime (Tier-2) |
|---|---|---|---|---|
| `MONTANT_SIGNE` | Numeric | Extract N signed S9 amount fields from fixed-width records; multiply each by +1 (sign-normalisation); write to output. PROGRAM-ID: `MONTANT`. | ✓ PASS trial-03  \|  328 B  \|  4 records ↗ Example 1  \|  ↗ Runbook | ✓ PASS job 740  \|  328 B  \|  byte-identical (diff=0) staged Extracts\ECL-TAPEIN.DAT — ↗ §6b |
| `LECTIS_MULT` | Read | Multi-key indexed read (`ORGANIZATION INDEXED` / `ACCESS MODE DYNAMIC`). Tier-1 treats as flat-sequential: `START > LOW-VALUES` + `READ NEXT` = full scan. PROGRAM-ID: `LECTIS`. | ✓ PASS trial-05  \|  463 B  \|  3 records ↗ Example 2  \|  ↗ Runbook | — pending |
| `TRI_ASCII` | Sort | Sort ASCII records by parameterised key column. PROGRAM-ID: `SORT-FICHOUT-1` (driven by `[OUTPUT,1,1,1]` override). Sort key: cols 1–8 ascending ASCII. | ✓ PASS trial-06  \|  246 B  \|  3 records ↗ Example 3  \|  ↗ Runbook | — pending |
| `ARCHITAB1` | Archive | Archive table processing (single table type). Outputs 80-char records for `ARCHITAB2`. Uses `#ucob,is` compile directive (not SSG template style). PROGRAM-ID: `ARCHITAB1`. | ✓ PASS trial-07  \|  246 B  \|  3 records ↗ Candidate  \|  ↗ Runbook  \|  ECL stub rule — from Trial 07 | ✓ struct job 1002  \|  246 B / 3 recs  \|  struct match (date-masked) params differ (`1` vs `ECL-*`) — ↗ §6b |
| `CFH-COPY` | Field copy | Copy and reformat selected fields from INPUT to OUTPUT using FIELDIN / FIELDOUT position-length specification pairs. ASCII mode variant confirmed in ECL. | ✓ PASS trial-11 246b | ✓ PASS job 737  \|  246 B  \|  byte-identical (diff=0) staged Extracts\ECL-TAPEIN.DAT — ↗ §6b |
| `ARCHIFORMAT` | Archive | Format records for archive output. | ✓ PASS trial-13 689b candidate | — pending |
| `ARCHIINSERT` | Archive | Insert records into archive file. | — pending | — pending |
| `ARCHISEPARE` | Archive | Separate / split archive records. | ✓ PASS trial-12 9902b candidate | — pending |
| `COMPARE2_ASCII` | Compare | Compare two ASCII sequential files; report differences. Trial-02 source was used for early converter testing. | ✓ PASS trial-10 1206b candidate | — pending |
| `CONDIS_ASCII` | Condition | Conditional ASCII data processing or filtering. | — pending | — pending |
| `ECLAT` | Split / Distribute | Archive-extraction merge: matched records → FARCHIVE; unmatched table records → FENCOURS. (PROGRAM-ID UGXB02. ECL search hits for “ECLAT” are often French words.) | ✓ PASS trial-09 162 B | ✓ trial-09 |
| `LOADIS_MULT-NODUP` | Load | Load IS (Information Store) without duplicates from multiple input streams. | ✓ PASS trial-14 95b candidate | exec-only job 739  \|  indexed load OK  \|  output not byte-comparable .DAT + .Index + ._CLEG — ↗ §6b |
| `SCAN-VAR_ASCII` | Scan | Scan variable-length ASCII records. | ✓ PASS trial-08 trial-08  \|  732 B  \|  3 records ↗ Candidate | — pending |
| `TAPELD_DISTRIB` | Tape / Load | Load and distribute data from tape input. | ✓ PASS trial-17 246b candidate | — pending |
| `UNLOADIS_MULT` | Unload | Multi-stream unload from IS files. | ✓ PASS trial-15 290b candidate | — pending |
| `UNLOADIS_MULT-NODUP` | Unload | Multi-stream unload from IS without duplicates. | — pending | — pending |

## 3 · How to Update This Page

| Event | Column A action | Column B action |
|---|---|---|
| Manifest entry created + `status=planned` | Change to ◯ planned · trial-NN | — |
| `Convert-SsgToLion.ps1` produces 0-error candidate; fixtures + refimpl written; `Run-EclProof` PASS | Change to ✓ PASS · trial-NN · NNNBytes + add links to runbook / example | — |
| Generated C# builds and runs under AMT runtime (Tier-2) | — | Change to ✓ PASS + add trial/build ref |
