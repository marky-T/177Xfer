# ARCHISEPARE

- **SSG source:** `source.txt` (from `SsgConverter/Examples/Input/ARCHISEPARE`)
- **Converted PowerShell:** `script.ps1` (from `SsgConverter/Examples/Output/ARCHISEPARE.ps1`)
- **Execution status:** tier1-only - ran to completion in the Tier-1 mock-shell harness only; never run against a real AmtPsEclLib or live Connect-Application.
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See `Tier1Mock/sgs-values/ARCHISEPARE.sgs-values.json` for the parameter values used instead.
- **expected-output.*:** expected-output.dat copied from Trial3/fixtures/archisepare/expected.dat - CONFIRMED same SGS parameters as our seed (see GoldenReconciliation.json caveat: different execution engine, not a byte-diff proof).

## DISC designators (see ../../DiscDesignators.json for the full structured version)
- **chercheuse** (input): ASSIGN DISC [filein,1,1,1]  ->  DISC ECL-CHERCHEUSE; LABEL RECORD OMITTED; record length 10
- **ficunload** (input): ASSIGN DISC [filein,1,2,1]  ->  DISC ECL-FICUNLOAD; LABEL RECORD OMITTED; record length  (unresolved) - dynamic: 9(10) + X(30) sub-fields, not a single literal.
- **ficarchi** (output): ASSIGN DISC [fileout,1,1,1]  ->  DISC ECL-FICARCHI; LABEL RECORD OMITTED; record length 72
- **ficnarchi** (output): ASSIGN DISC [fileout,1,2,1]  ->  DISC ECL-FICNARCHI; LABEL RECORD OMITTED; record length 40
