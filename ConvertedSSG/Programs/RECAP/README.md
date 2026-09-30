# RECAP

- **SSG source:** `source.txt` (from `SsgConverter/Examples/Input/RECAP.TXT`)
- **Converted PowerShell:** `script.ps1` (from `SsgConverter/Examples/Output/RECAP.ps1`)
- **Execution status:** tier1-only - ran to completion in the Tier-1 mock-shell harness only; never run against a real AmtPsEclLib or live Connect-Application.
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See `Tier1Mock/sgs-values/RECAP.sgs-values.json` for the parameter values used instead.
- **expected-output.*:** No Trial3 fixture applies to this program (no-manifest-entry).

## DISC designators (see ../../DiscDesignators.json for the full structured version)
- **TAPEIN** (input): ASSIGN DISC [INPUT,1,1,1]; LABEL RECORD STANDARD; record length [INPUT,1,1,2] (unresolved) - GAP: brackets unresolved against current sgs-values.json.
- **TAPEOUT** (output): ASSIGN DISC [OUTPUT,1,1,1]; LABEL RECORD STANDARD; record length [OUTPUT,1,1,2] (unresolved) - Same gap as TAPEIN.
