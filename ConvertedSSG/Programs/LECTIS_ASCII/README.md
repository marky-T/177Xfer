# LECTIS_ASCII

- **SSG source:** `source.txt` (from `SsgConverter/Examples/Input/LECTIS_ASCII.TXT`)
- **Converted PowerShell:** `script.ps1` (from `SsgConverter/Examples/Output/LECTIS_ASCII.ps1`)
- **Execution status:** tier1-only - ran to completion in the Tier-1 mock-shell harness only; never run against a real AmtPsEclLib or live Connect-Application.
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See `Tier1Mock/sgs-values/LECTIS_ASCII.sgs-values.json` for the parameter values used instead.
- **expected-output.*:** expected-output.dat copied from Trial3/fixtures/lectis/expected.dat - CONFIRMED same SGS parameters as our seed (see GoldenReconciliation.json caveat: different execution engine, not a byte-diff proof).

## DISC designators (see ../../DiscDesignators.json for the full structured version)
- **[INPUT,1,1,1] (indexed)** (input): ASSIGN DISC [INPUT,1,1,1]  ->  DISC FICHIN-1; LABEL RECORD STANDARD; record length 120 - PROGRAM-ID is 'LECTIS' (no _ASCII) but script filename is LECTIS_ASCII.ps1 - see naming note.
- **IMP** (output-print): ASSIGN PRINTER  ->  PRINTER; LABEL RECORD OMITTED; record length 100 - USAGE DISPLAY-1 (ASCII).
- **CARTE** (input): ASSIGN CARD-READER  ->  CARD-READER; LABEL RECORD OMITTED; record length  (unresolved) - dynamic: key-dependent size, conditional file. NOTE: this program has a mocked SGS condition literally named 'KEYS' - the exact case the T3-007 .PSBase.Keys fix guards against; make sure AMT172's own harness (if any) has the equivalent fix.
