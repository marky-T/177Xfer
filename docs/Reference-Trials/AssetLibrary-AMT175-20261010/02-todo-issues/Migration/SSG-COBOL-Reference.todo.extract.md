# Done / open items extracted from SSG-COBOL-Reference.html

Source: `01-docs-html/Migration/SSG-COBOL-Reference.html` (original: `C:\Amt\Migration\SSG-COBOL-Reference.html`)

4 done / 14 not done (HTML status badges)

## 5. The 16 ASSURFED Utility Programs

| Program | Category | Likely Purpose | Status |
|---|---|---|---|
| `MONTANT_SIGNE` | Numeric | Extract N signed numeric (S9) amount fields from fixed-width records; multiply each by +1 (sign-normalisation); write to output. PROGRAM-ID: MONTANT. | ✓ Example 1 |
| `CFH-COPY` | Field copy | Copy and reformat selected fields from INPUT to OUTPUT using FIELDIN / FIELDOUT position-length specification pairs. ASCII mode variant confirmed in ECL. | Partially known |
| `ARCHIFORMAT` | Archive | Format records for archive output. | Pending |
| `ARCHIINSERT` | Archive | Insert records into archive file. | Pending |
| `ARCHISEPARE` | Archive | Separate / split archive records. | Pending |
| `ARCHITAB1` | Archive | Archive table processing (single table type). | Pending |
| `COMPARE2_ASCII` | Compare | Compare two ASCII sequential files; report differences. (Trial 02 source used for early converter testing.) | Pending |
| `CONDIS_ASCII` | Condition | Conditional ASCII data processing or filtering. | Pending |
| `ECLAT` | Split / Distribute | Split (éclatement) and distribute records across multiple output streams. (Note: ECL search hits for "ECLAT" are often French words — not calls to this program.) | Pending |
| `LECTIS_MULT` | Read | Multi-stream read from IS (Information Store) files. | ✓ Example 2 |
| `LOADIS_MULT-NODUP` | Load | Load IS without duplicates from multiple input streams. | Pending |
| `SCAN-VAR_ASCII` | Scan | Scan variable-length ASCII records. | Pending |
| `TAPELD_DISTRIB` | Tape / Load | Load and distribute data from tape input. | Pending |
| `TRI_ASCII` | Sort | Sort ASCII records. | Pending |
| `UNLOADIS_MULT` | Unload | Multi-stream unload from IS files. | Pending |
| `UNLOADIS_MULT-NODUP` | Unload | Multi-stream unload from IS without duplicates. | Pending |

## 6. Worked Examples

| # | Program | Description | Status |
|---|---|---|---|
| 1 | MONTANT_SIGNE | Numeric amount field extractor — stubbed macros (TRIAL04) | ✓ Done |
| 2 | LECTIS_MULT | IS file multi-stream reader — IS-file API, CARTE key-list mode, T3/T4/T_KEY/T_KEYS/T_COND transforms (TRIAL05) | ✓ Done |
