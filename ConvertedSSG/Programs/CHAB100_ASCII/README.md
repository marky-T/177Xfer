# CHAB100_ASCII

- **SSG source:** `source.txt` (from `SsgConverter/Examples/Input/CHAB100_ASCII.TXT`)
- **Converted PowerShell:** `script.ps1` (from `SsgConverter/Examples/Output/CHAB100_ASCII.ps1`)
- **Execution status:** tier1-only - ran to completion in the Tier-1 mock-shell harness only; never run against a real AmtPsEclLib or live Connect-Application.
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See `Tier1Mock/sgs-values/CHAB100_ASCII.sgs-values.json` for the parameter values used instead.
- **expected-output.*:** No Trial3 fixture applies to this program (no-manifest-entry).

## DISC designators (see ../../DiscDesignators.json for the full structured version)
- **FIC** (output): ASSIGN DISC [OUTPUT,1,1,1]; LABEL RECORD STANDARD; record length [OUTPUT,1,1,2] (unresolved) - GAP: no sgs-values.json key resolved for OUTPUT,1,1,*.
- **CAR** (input): ASSIGN CARD-READER  ->  CARD-READER; LABEL RECORD OMITTED; record length 80
- **PRI** (output-print): ASSIGN PRINTER  ->  PRINTER; LABEL RECORD OMITTED; record length 100 - Conditional.
