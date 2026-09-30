# ARCHIFORMAT

- **SSG source:** `source.txt` (from `SsgConverter/Examples/Input/ARCHIFORMAT.TXT`)
- **Converted PowerShell:** `script.ps1` (from `SsgConverter/Examples/Output/ARCHIFORMAT.ps1`)
- **Execution status:** tier1-only - ran to completion in the Tier-1 mock-shell harness only; never run against a real AmtPsEclLib or live Connect-Application.
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See `Tier1Mock/sgs-values/ARCHIFORMAT.sgs-values.json` for the parameter values used instead.
- **expected-output.*:** expected-output.dat copied from Trial3/fixtures/archiformat/expected.dat - CONFIRMED same SGS parameters as our seed (see GoldenReconciliation.json caveat: different execution engine, not a byte-diff proof).

## DISC designators (see ../../DiscDesignators.json for the full structured version)
- **fic-report** (input): ASSIGN DISC [filein,1,1,1]  ->  DISC ECL-FICREPORT; LABEL RECORD OMITTED; record length 132
- **fic-descript** (input): ASSIGN DISC [filein,1,2,1]  ->  DISC ECL-FICDESCRIPT; LABEL RECORD OMITTED; record length 132
- **fic-unload** (input): ASSIGN DISC [filein,1,3,1]  ->  DISC ECL-FICUNLOAD; LABEL RECORD OMITTED; record length 68 - Record length is a *SET-computed sum of SGS values, not a literal FD PIC.
- **fic-format** (output): ASSIGN DISC [fileout,1,1,1]  ->  DISC ECL-FICFORMAT; LABEL RECORD OMITTED; record length 69 - Matches the documented golden A=69 in repo memory.
