# LOADIS_MULTI

- **SSG source:** `source.txt` (from `SsgConverter/Examples/Input/LOADIS_MULTI.TXT`)
- **Converted PowerShell:** `script.ps1` (from `SsgConverter/Examples/Output/LOADIS_MULTI.ps1`)
- **Execution status:** tier1-only - ran to completion in the Tier-1 mock-shell harness only; never run against a real AmtPsEclLib or live Connect-Application.
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See `Tier1Mock/sgs-values/LOADIS_MULTI.sgs-values.json` for the parameter values used instead.
- **expected-output.*:** No Trial3 fixture applies to this program (no-manifest-entry).

## DISC designators (see ../../DiscDesignators.json for the full structured version)
- **BDE** (input): ASSIGN UNISERVO/DISC [INPUT,1,1,1]  ->  UNISERVO/DISC ECL-BDE1; LABEL RECORD STANDARD; record length 80
- **DISQ** (output (indexed)): ASSIGN A-SHARED-FILE or DISC [OUTPUT,1,1,1]  ->  DISC ECL-DISQ; LABEL RECORD STANDARD or OMITTED (conditional); record length 20
