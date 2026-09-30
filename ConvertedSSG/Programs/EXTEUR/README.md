# EXTEUR

- **SSG source:** `source.txt` (from `SsgConverter/Examples/Input/EXTEUR.TXT`)
- **Converted PowerShell:** `script.ps1` (from `SsgConverter/Examples/Output/EXTEUR.ps1`)
- **Execution status:** tier1-only - ran to completion in the Tier-1 mock-shell harness only; never run against a real AmtPsEclLib or live Connect-Application.
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See `Tier1Mock/sgs-values/EXTEUR.sgs-values.json` for the parameter values used instead.
- **expected-output.*:** No Trial3 fixture applies to this program (no-manifest-entry).

## DISC designators (see ../../DiscDesignators.json for the full structured version)
- **INA** (input): ASSIGN DISC INA (literal)  ->  DISC INA; LABEL RECORD STANDARD; record length [LONG,1,1,1] (unresolved) - GAP: BLOCK/LONG brackets unresolved.
- **OUTA** (output): ASSIGN DISC OUTA (literal)  ->  DISC OUTA; LABEL RECORD STANDARD; record length [LONG,1,1,1] (unresolved) - Same gap as INA.
- **ANOA** (output): ASSIGN DISC ANOA (literal)  ->  DISC ANOA; LABEL RECORD ; record length  (unresolved) - FD details not distinctly captured - needs closer read.
- **LISTE** (output-print): ASSIGN PRINTER  ->  PRINTER; LABEL RECORD ; record length  (unresolved)
