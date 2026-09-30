# CONDIS2_ASCII

- **SSG source:** `source.txt` (from `SsgConverter/Examples/Input/CONDIS2_ASCII.TXT`)
- **Converted PowerShell:** `script.ps1` (from `SsgConverter/Examples/Output/CONDIS2_ASCII.ps1`)
- **Execution status:** tier1-only - ran to completion in the Tier-1 mock-shell harness only; never run against a real AmtPsEclLib or live Connect-Application.
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See `Tier1Mock/sgs-values/CONDIS2_ASCII.sgs-values.json` for the parameter values used instead.
- **expected-output.*:** No Trial3 fixture applies to this program (no-manifest-entry).

## DISC designators (see ../../DiscDesignators.json for the full structured version)
- **FILEIN** (input): ASSIGN DISC FILEIN (literal, not a bracket)  ->  DISC FILEIN; LABEL RECORD STANDARD; record length [FILEIN,1,1,1] (unresolved) - GAP: BLOCK/length brackets unresolved against current sgs-values.json.
- **FILEOUT** (output): ASSIGN DISC FILEOUT (literal, not a bracket)  ->  DISC FILEOUT; LABEL RECORD STANDARD; record length [FILEOUT,1,1,1] (unresolved) - Same gap as FILEIN.
