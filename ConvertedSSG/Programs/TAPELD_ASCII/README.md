# TAPELD_ASCII

- **SSG source:** `source.txt` (from `SsgConverter/Examples/Input/TAPELD_ASCII.TXT`)
- **Converted PowerShell:** `script.ps1` (from `SsgConverter/Examples/Output/TAPELD_ASCII.ps1`)
- **Execution status:** tier1-only - ran to completion in the Tier-1 mock-shell harness only; never run against a real AmtPsEclLib or live Connect-Application.
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See `Tier1Mock/sgs-values/TAPELD_ASCII.sgs-values.json` for the parameter values used instead.
- **expected-output.*:** expected-output.dat copied from Trial3/fixtures/TAPELD_DISTRIB/expected.dat - CONFIRMED same SGS parameters as our seed (see GoldenReconciliation.json caveat: different execution engine, not a byte-diff proof).

## DISC designators (see ../../DiscDesignators.json for the full structured version)
- **TAPEIN** (input): ASSIGN DISC [INPUT,1,1,1] or CARD-READER; LABEL RECORD OMITTED or STANDARD (conditional); record length [INPUT,1,1,2] (unresolved) - GAP: brackets unresolved against current sgs-values.json.
- **TAPEOUT** (output): ASSIGN DISC or CARD-PUNCH [OUTPUT,1,1,1]; LABEL RECORD OMITTED; record length [OUTPUT,1,1,2] (unresolved) - Same gap as TAPEIN.
- **PRINTOUT** (output-print): ASSIGN PRINTER  ->  PRINTER; LABEL RECORD OMITTED; record length 132 - Conditional.
