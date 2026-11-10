# T3-059 probe: AMT's line-sequential reader merges lines (261105)

**Question:** why did CC job 1311 read 19 records from a 20-line file (CONDIS2S case `syn-d42-boundaries`)?
**Method:** the released `ASSURFED_UTILIT_CONDIS2_GN` in the mock runtime (Rebuild177a-spike set, mock file controller), as a
plain copy (`PG MOVE 1,L,1`). Input lines filled with one letter per line, so a merged record shows two letters with a CR LF
inside. `Probe-ReaderMerge.ps1 -Name <case> -Lengths <l1,l2,...> -RecLen <n>`; summary `results.csv`.

## Result
- **Reproduced offline:** the CC shape (18 × 8, then 4, 2) reads 19 records, the last `SSSS\r\nTT`, as in CC.
- **Derived rule** (fits 29 of 29 mock cases, with the predictions for `s`, `t`, `u`, `w`, `x`, `y`, `aa`, `bb` made before the run).
  It is not taken from source: the file controller's source is not in the R&D clone. `AmtReadFile.ReadLine(ending None, recordSize)`
  in `Amt.Net\Libraries\Libs\Files\AmtReadFile.cs` does read fixed-size records without looking for CR LF, which matches the mechanism.
  - The reader starts with L = the FD's maximum record size M (4001 for the generic programs).
  - While **every record read so far has had the same length**, a READ takes the next L bytes as one record when they are
    followed by CR LF, or when they are exactly the rest of the file (ending in CR LF). CR LFs inside are kept.
  - Otherwise it reads a plain line. After the first record, L = its length. Once a record of another length is read, the
    reader reads plain lines only.
- **Consequence:** a file whose records so far all have one length L loses records silently when a **group of shorter lines
  totals exactly L bytes including their inner CR LFs**: (4,2), (3,3), (5,1), (2,2) at the end of the file, (12,16) after
  30-byte lines, (10,8) after 20-byte lines. One differing line before the group prevents it (`aa`, `s`, `x`, `y`).
- **T3-040 is the same rule at the first read** (L = M = 4000): 136-byte lines 45 → 17 and 70-byte lines 100 → 100 are reproduced;
  67-byte lines give 43 against the 44 seen in the T3-040 spike (input detail of that spike not re-checked).
- Program-independent: CONDIS2_GN (mock) and CONDIS2_GS (CC) both show it; it is in the run time.

## Files
`Probe-ReaderMerge.ps1` (probe), `Test-ReaderRule.ps1` (the rule as a simulator, vs `results.csv`: `rule-vs-mock.txt`),
one folder per case (`input`, `parm`, `output`).

## CC confirmation (261105 21:11, job SSG4_CONDIS2S_CASES, CONDIS2S cases t3059-*)
Predictions made before the run, all exact: 30,12,16 -> 2; 8,8,8,6,4,2 -> 6; 8,8,4,2,4,2 -> 4; syn-d42-boundaries -> 19. A merged record is written with its CR LF inside, so the output still looks like the right number of lines.
