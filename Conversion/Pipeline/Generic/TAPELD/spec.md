# TAPELD generic program (MT-043, runbook C13)

**Skeleton** `*UTILIT.TAPELD/ASCII` (`SsgConverter\Examples\Input\TAPELD_ASCII.TXT`), 14 calls, `@XQT TPF$.`
(Check-ReportName gives `TPF$`). A CFH-COPY variant (program `CFH-COPY`) printing to `PRINTER`: per record the FIELDIN
fields moved to FIELDOUT positions; with `STITRE` the FIXE items are a page title, printed `AFTER PAGE` whenever the line
counter (start 58, reset 5) passes 57, also once more at end of file if it just passed 57.

All 14 calls: `INPUT name,len`, `OUTPUT PRINTER,132,1`, FIELDIN/FIELDOUT pairs, FIXE titles, `STITRE YES`. Refused by the
parameter writer (none in use): Y2K, EURO, PRINT, SUPCOM, REPSIM, STARTFIELD, STARTREC, MAXCOPY, numeric fields, FIXE
without STITRE, FIXE NUM/ZONE, other OUTPUT, CARDREADER.

**Generic program** `ASSURFED-UTILIT-TAPELD-GN` (`gen\ASSURFED-UTILIT-TAPELD-GN.cob`): reads `TAPLIN` (varying, max 4001;
alias to the call's INPUT name), prints `TAPEOUT` (132).
**Parameter file** `TAPPARM` (250 bytes, `gen\TapeldParm.ps1`): `IN<len5>`, `OU<len5>`, `MV<in5><len5><out5><len5>`,
`FX<pos5><len5><text>`, `ST`. FIXE comes from the raw card (GnHandoff `Get-GnSgsCards`): AddTo-SgsList splits quoted
titles at their spaces (T3-028; why all 14 expansions fail). SSG card rules kept: `'MATRICULE';` (PBDA04_L339) is an
embedded semicolon, not a continuation, so that call's 4th title line is a separate SGS and is not printed;
`'Dern. paiem.'` in an 11-byte item is cut to 11 (-d_VIRD50_PI_L579).

**Checks**
- `check\Test-TapeldParm.ps1`: 14/14 MATCH against expansions of the cards with quoted spaces as `~` (turned back).
- Print checks with SCAN (`..\SCANGROUP`): TAPELD-RA (PBDA04_L805, 120 records, 3 title pages) and TAPELD-RB
  (VIRA12_PI_L590, 53 records, end-of-file title) are those expansions with the spaces restored.
