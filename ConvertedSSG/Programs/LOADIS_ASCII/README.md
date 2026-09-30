# LOADIS_ASCII

- **SSG source:** `source.txt` (from `SsgConverter/Examples/Input/LOADIS_ASCII.TXT`)
- **Converted PowerShell:** `script.ps1` (from `SsgConverter/Examples/Output/LOADIS_ASCII.ps1`)
- **Execution status:** tier1-only - ran to completion in the Tier-1 mock-shell harness only; never run against a real AmtPsEclLib or live Connect-Application.
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See `Tier1Mock/sgs-values/LOADIS_ASCII.sgs-values.json` for the parameter values used instead.
- **expected-output.*:** A Trial3 fixture exists (Trial3/fixtures/LOADIS_MULT-NODUP) with an OVERLAPPING but not fully-matched parameter set - not copied here to avoid implying a confirmed golden. See GoldenReconciliation.json.

## DISC designators (see ../../DiscDesignators.json for the full structured version)
- **BDE[*I]** (input (multiple)): ASSIGN UNISERVO/DISC [INPUT,1,1,1]  ->  UNISERVO/DISC ECL-BDE1; LABEL RECORD STANDARD; record length 80
- **DISQ** (output (indexed)): ASSIGN DISC [OUTPUT,1,1,1]  ->  DISC ECL-DISQ; LABEL RECORD STANDARD; record length 20
