# SCAN generic program (MT-043, runbook C12)

**Skeleton** `*UTILIT.SCAN/ASCII` (`SsgConverter\Examples\Input\SCAN_ASCII.TXT`), 19 calls, `@XQT TPF$.SCAN`. Prints
the input file: per record a count line (`**  n**`; on the 4th printed record and every 9th after it the ruler `F-LINE`), then the
record in 100-byte lines; at the end `** END SCAN **  RECORDS READ FROM <input> = n RECORD MATCHING = m`.

Cards used by the 19 calls: `INPUT name,len,blk` and, in 12 calls, `IF R < n` (print only records 1..n-1, read all).
The Y2K / NOCONT / INDIC / other IF forms are refused by the parameter writer (none in use).

**Generic program** `ASSURFED-UTILIT-SCAN-GN` (`gen\ASSURFED-UTILIT-SCAN-GN.cob`): reads `SCANIN` (varying, max 4001,
T3-040; alias to the call's INPUT name), prints with the skeleton's own lines and statements.
**Parameter file** `SCANPARM` (80 bytes, `gen\ScanParm.ps1`): `IN<len5>`, `MN<'RECORDS READ FROM name = ' in 37>`, `MX<n10>`.

**T3-045 (converter):** the skeleton builds the IF statement between `*EDIT ON &` and `*EDIT OFF`; SsgConverter drops that
block, so every expansion with `IF R < n` prints all records. The generic program takes the limit from the card.

**Checks**
- `check\Test-ScanParm.ps1`: 19/19 MATCH (length and end-line name vs expansion, limit vs the IF card).
- Print checks with TAPELD: `..\SCANGROUP\cc\Prepare-ScanGroupCc.ps1` -> job `SSG4_SCANGRP_PRINTS`, `Test-CcPrints.ps1`:
  generic print == static reference print (SCAN-RA from -d_VIRD36_MJ_L292; SCAN-RB from PBDA04_L132 with the IF put
  back) and == the text model (`..\SCANGROUP\cc\PrintModels.ps1`).
