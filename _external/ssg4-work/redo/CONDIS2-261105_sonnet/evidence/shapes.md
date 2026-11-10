# CONDIS2 - G1 shapes of the real calls

Source: `sgs-calls.csv` (ProgramKey = CONDIS2_ASCII), cards in `E:\Repos\ssg4-work\sgs-cards\calls`, expansions in `percall\allcalls`. Script: `generic\check\Classify-CondisCalls.ps1`. Calls: 18.

## Per call

| Call | Shape | In len | Out len | CASE | OTHERWISE | MOVE cards (fields) | CONST cards (fields) | Date codes | Quoted/space values | Expansion |
|---|---|---|---|---|---|---|---|---|---|---|
| AUMH01_D3_L87 | A: no CASE | 408 | 400 | 0 | 0 | 1 (9) | 0 (0) | D42=4 | 0 | expanded |
| AUPA02_MJ_L68 | A: no CASE | 204 | 214 | 0 | 0 | 1 (10) | 0 (0) | D24=2 D68=3 | 0 | expanded |
| AUPA02_MJ_L95 | A: no CASE | 300 | 314 | 0 | 0 | 1 (13) | 0 (0) | D24=4 D68=3 | 0 | expanded |
| CLOA20_L83 | A: no CASE | 408 | 400 | 0 | 0 | 1 (9) | 0 (0) | D42=4 | 0 | expanded |
| CLOA47_L326 | A: no CASE | 120 | 120 | 0 | 0 | 1 (12) | 0 (0) | D42=2 | 0 | expanded |
| INTA01_MJ_L84 | A: no CASE | 200 | 212 | 0 | 0 | 1 (10) | 0 (0) | D24=2 D68=4 | 0 | expanded |
| INTA01_MJ_L269 | A: no CASE | 300 | 314 | 0 | 0 | 1 (13) | 0 (0) | D24=4 D68=3 | 0 | expanded |
| LRSJ01_L71 | A: no CASE | 500 | 500 | 0 | 0 | 1 (10) | 0 (0) | D42=4 | 0 | expanded |
| LRSJ01_L98 | A: no CASE | 202 | 200 | 0 | 0 | 1 (3) | 0 (0) | D42=1 | 0 | expanded |
| LRSJ01_L124 | A: no CASE | 100 | 100 | 0 | 0 | 1 (3) | 0 (0) | D42=1 | 0 | expanded |
| PAIJ01_BD_L58 | A: no CASE | 80 | 200 | 0 | 0 | 1 (12) | 1 (1) | D42=2 | 0 | expanded |
| PAIJ01_UL_L85 | C: CASE + OTHERWISE | 220 | 200 | 4 | 1 | 5 (37) | 0 (0) | D42=15 | 6 | EXPANSION FAILED |
| SINM05_L106 | A: no CASE | 314 | 300 | 0 | 0 | 1 (14) | 0 (0) | D42=7 | 0 | expanded |
| VIRJ01_UE_L850 | C: CASE + OTHERWISE | 132 | 132 | 34 | 1 | 35 (138) | 35 (103) |  | 0 | expanded |
| -d_VIGD03_L894 | C: CASE + OTHERWISE | 231 | 231 | 1 | 1 | 2 (4) | 0 (0) |  | 0 | expanded |
| -d_VIGD03_L1030 | C: CASE + OTHERWISE | 231 | 231 | 1 | 1 | 2 (4) | 0 (0) |  | 0 | expanded |
| -d_VIGD13_L899 | C: CASE + OTHERWISE | 231 | 231 | 1 | 1 | 2 (4) | 0 (0) |  | 0 | expanded |
| -d_VIGD13_L1035 | C: CASE + OTHERWISE | 231 | 231 | 1 | 1 | 2 (4) | 0 (0) |  | 0 | expanded |

## Groups

| Calls | Shape | Calls (ids) |
|---|---|---|
| 12 | A: no CASE | AUMH01_D3_L87, AUPA02_MJ_L68, AUPA02_MJ_L95, CLOA20_L83, CLOA47_L326, INTA01_MJ_L84, INTA01_MJ_L269, LRSJ01_L71, LRSJ01_L98, LRSJ01_L124, PAIJ01_BD_L58, SINM05_L106 |
| 6 | C: CASE + OTHERWISE | PAIJ01_UL_L85, VIRJ01_UE_L850, -d_VIGD03_L894, -d_VIGD03_L1030, -d_VIGD13_L899, -d_VIGD13_L1035 |

## Date codes used by the real calls

| Code | Fields over all calls |
|---|---|
| D24 | 12 |
| D42 | 40 |
| D68 | 13 |

Codes in the skeleton not used by any real call: D22A, D22B, D66A, D66B, D86

## Extremes

- Input record length: 80..500; output record length: 100..500
- PG cards per call: 1..105; CASE cards per call: max 34; fields on one PG card: max 14
- Input length differs from output length in: AUMH01_D3_L87, AUPA02_MJ_L68, AUPA02_MJ_L95, CLOA20_L83, INTA01_MJ_L84, INTA01_MJ_L269, LRSJ01_L98, PAIJ01_BD_L58, PAIJ01_UL_L85, SINM05_L106

## Card-set checks (skeleton lines 4-96, V1-V7) and unusual layouts per call

| Call | Skeleton check violations | Unusual layout (no skeleton check) |
|---|---|---|
| AUMH01_D3_L87 | none | none |
| AUPA02_MJ_L68 | none | none |
| AUPA02_MJ_L95 | none | none |
| CLOA20_L83 | none | none |
| CLOA47_L326 | none | none |
| INTA01_MJ_L84 | none | none |
| INTA01_MJ_L269 | none | none |
| LRSJ01_L71 | none | none |
| LRSJ01_L98 | none | none |
| LRSJ01_L124 | none | none |
| PAIJ01_BD_L58 | none | none |
| PAIJ01_UL_L85 | none | none |
| SINM05_L106 | none | none |
| VIRJ01_UE_L850 | none | none |
| -d_VIGD03_L894 | none | none |
| -d_VIGD03_L1030 | none | none |
| -d_VIGD13_L899 | none | none |
| -d_VIGD13_L1035 | none | none |

Calls with OTHERWISE: 6; of these with OTHERWISE before any CASE: 0; with a CASE after OTHERWISE: 0; with MOVE/CONST before the first CASE: 0; OTHERWISE with fields: 0; calls violating a skeleton check: 0.

## Notes

- Field order inside a PG card is significant: MOVE fields are applied in card order, so a later field overwrites an earlier one where output ranges overlap.
- Every real call has FILEIN and FILEOUT records of a fixed length (FILEIN,1,1,1 / FILEOUT,1,1,1); the input and output lengths differ in most calls (the date codes D24/D42/D68 change the field width).
- Only D24, D42 and D68 occur in real calls. D22A, D22B, D66A, D66B and D86 are in the skeleton only (test data needed).
- PAIJ01_UL_L85 (the only call with quoted space values, 6 of them in CASE conditions): the per-call expansion fails (the shared SGS code splits a card at every space, so PG,I,J,1 is empty; T3-028). The cards are parsed here with the shared raw-card splitter (GnHandoff.ps1), which keeps the quoted spaces.
- CASE values in VIRJ01_UE_L850 include non-ASCII Windows-1252 characters (e-acute, e-grave) and punctuation (`{ } ! ?`): the parameter file must be Windows-1252.
