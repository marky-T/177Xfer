# Generic CFH-COPY — behaviour spec (spike step 0, 2026-10-20)

Source: the 47 real CFH-COPY calls, expanded with their own cards by `Invoke-SsgExpansion.ps1` (AMT's SGS functions):
`E:\Repos\ssg4-work\allcalls\expanded\CFH-COPY_ASCII__*.cob`; classification in `inventory.csv`, `shapes.txt`
(`Classify-CfhCalls.ps1`).

## Procedure shapes found

| Calls | Shape | Example |
|---|---|---|
| 18 | field moves only | AFPH12_L427 (80 → 22, 1 move) |
| 14 | field moves + constants (`FIXE`) | AFID01_L145, VIRM01_CO_L484 (500 → 135, 10 moves, 1 constant) |
| 9 | whole record (`MOVE RECIN TO RECOUT`) | CCSA09_L362 (80 → 30) |
| 1 | field moves + skip the first records (`STARTREC`) | RISH02_L379 (304 → 20, 3 moves, skip 1) |
| 5 | **expansion stops early** (no procedure division) | VIRA12_UL_L145: cards `FIXE 71,8,'        '` — a quoted constant with spaces (card limit, T3-028) |

42 of 47 are covered by the spec below; the 5 depend on T3-028 (what the skeleton does with a quoted all-space
constant) and are out of the spike.

## Behaviour (byte level)

Parameters: input name and length, output name and length; 0..13 moves (in-start, in-len, out-start, out-len);
0..7 constants (out-start, len, text); skip count (STARTREC − 1, default 0).

1. `OPEN INPUT` the input, `OPEN OUTPUT` the output.
2. Loop: set the output record to spaces (output length); `READ`, at end go to 7.
3. No moves: copy the input record to the output record (pad with spaces / truncate to the output length).
   Otherwise, for each move in card order: input bytes `in-start .. +in-len` to output `out-start .. +out-len`,
   alphanumeric MOVE rules (pad right with spaces / truncate right).
4. For each constant in card order: the text (padded/truncated to `len`) to output `out-start .. +len`, then replace
   every `<` by `;` in that slice.
5. Add 1 to the read count; if a skip count is set and read count ≤ skip count: add 1 to `REC-SKIPPED`, back to 2
   without writing.
6. Write the output record at exactly the output length; back to 2.
7. `DISPLAY '*CFH-COPY  FIN*'`, `DISPLAY '*NB-ENREG-LUS =' NB-LUS` (`PIC 9(10) COMP`), close both files,
   `DISPLAY REC-SKIPPED` (`PIC S9(6)`), stop.

Sizes seen: input ≤ 3,896, output ≤ 3,300, ≤ 13 moves, ≤ 7 constants.
