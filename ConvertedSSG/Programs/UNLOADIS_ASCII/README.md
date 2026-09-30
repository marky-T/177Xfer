# UNLOADIS_ASCII

- **SSG source:** `source.txt` (from `SsgConverter/Examples/Input/UNLOADIS_ASCII.TXT`)
- **Converted PowerShell:** `script.ps1` (from `SsgConverter/Examples/Output/UNLOADIS_ASCII.ps1`)
- **Execution status:** tier1-only - ran to completion in the Tier-1 mock-shell harness only; never run against a real AmtPsEclLib or live Connect-Application.
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See `Tier1Mock/sgs-values/UNLOADIS_ASCII.sgs-values.json` for the parameter values used instead.
- **expected-output.*:** No Trial3 fixture applies to this program (no-manifest-entry).

## DISC designators (see ../../DiscDesignators.json for the full structured version)
- **BDE** (output): ASSIGN INTERCHANGE or DISC [OUTPUT,1,1,1]  ->  DISC ECL-OUTPUT; LABEL RECORD STANDARD or OMITTED (conditional); record length 80
- **DISQ** (input (indexed)): ASSIGN DISC [INPUT,1,1,1]  ->  DISC ECL-INPUT; LABEL RECORD STANDARD; record length 80
