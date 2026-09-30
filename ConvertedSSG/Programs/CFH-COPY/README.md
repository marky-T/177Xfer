# CFH-COPY

- **SSG source:** `source.txt` (from `SsgConverter/Examples/Input/CFH-COPY.TXT`)
- **Converted PowerShell:** `script.ps1` (from `SsgConverter/Examples/Output/CFH-COPY.ps1`)
- **Execution status:** tier1+stagea - ran to completion in the Tier-1 mock harness AND against the real (isolated-copy) AmtPsEclLib with no COM/live app (Stage A); never a live Connect-Application run.
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See `Tier1Mock/sgs-values/CFH-COPY.sgs-values.json` for the parameter values used instead.
- **expected-output.*:** expected-output.dat copied from Trial3/fixtures/cfh-copy/expected.dat - CONFIRMED same SGS parameters as our seed (see GoldenReconciliation.json caveat: different execution engine, not a byte-diff proof).

## DISC designators (see ../../DiscDesignators.json for the full structured version)
- **TAPEIN** (input): ASSIGN UNISERVO [INPUT,1,1,1]  ->  UNISERVO ECL-TAPEIN; LABEL RECORD STANDARD; record length 80
- **TAPEOUT** (output): ASSIGN MASS-STORAGE [OUTPUT,1,1,1]  ->  MASS-STORAGE ECL-TAPEOUT; LABEL RECORD OMITTED; record length 80
- **PRINTOUT** (output-print): ASSIGN PRINTER  ->  PRINTER; LABEL RECORD OMITTED; record length 132 - Conditional on [PRINT]>0 and OUTPUT device not already PRINTER.
