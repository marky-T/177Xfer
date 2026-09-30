# UNLOADIS_MULTI

- **SSG source:** `source.txt` (from `SsgConverter/Examples/Input/UNLOADIS_MULTI.txt`)
- **Converted PowerShell:** `script.ps1` (from `SsgConverter/Examples/Output/UNLOADIS_MULTI.ps1`)
- **Execution status:** tier1-only - ran to completion in the Tier-1 mock-shell harness only; never run against a real AmtPsEclLib or live Connect-Application.
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See `Tier1Mock/sgs-values/UNLOADIS_MULTI.sgs-values.json` for the parameter values used instead.
- **expected-output.*:** A Trial3 fixture exists (Trial3/fixtures/UNLOADIS_MULT) with an OVERLAPPING but not fully-matched parameter set - not copied here to avoid implying a confirmed golden. See GoldenReconciliation.json.

## DISC designators (see ../../DiscDesignators.json for the full structured version)
- **BDE** (output): ASSIGN INTERCHANGE or DISC [OUTPUT,1,1,1]  ->  DISC ECL-BDE1; LABEL RECORD STANDARD or OMITTED (conditional); record length 80
- **DISQ** (input (indexed)): ASSIGN A-SHARED-FILE or DISC [INPUT,1,1,1]  ->  DISC ECL-DISQ; LABEL RECORD OMITTED or STANDARD (conditional); record length 20
