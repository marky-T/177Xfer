# CFH-COPY_ASCII

- **SSG source:** `source.txt` (from `SsgConverter/Examples/Input/CFH-COPY_ASCII.TXT`)
- **Converted PowerShell:** `script.ps1` (from `SsgConverter/Examples/Output/CFH-COPY_ASCII.ps1`)
- **Execution status:** tier1-only - ran to completion in the Tier-1 mock-shell harness only; never run against a real AmtPsEclLib or live Connect-Application.
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See `Tier1Mock/sgs-values/CFH-COPY_ASCII.sgs-values.json` for the parameter values used instead.
- **expected-output.*:** GAP: a same-named Trial3 fixture exists (Trial3/fixtures/cfh-copy) but uses DIFFERENT SGS parameters than our seed - deliberately NOT copied here. See GoldenReconciliation.json.

## DISC designators (see ../../DiscDesignators.json for the full structured version)
- **TAPEIN** (input): ASSIGN DISC [INPUT,1,1,1]; LABEL RECORD STANDARD; record length [INPUT,1,1,2] (unresolved) - GAP: SsgConverter/Trials/CFH-COPY_ASCII/sgs-values.json not checked/present for this key set - resolve before final bundle.
- **TAPEOUT** (output): ASSIGN DISC [OUTPUT,1,1,1]; LABEL RECORD OMITTED; record length [OUTPUT,1,1,2] (unresolved) - Same gap as TAPEIN. DISP-1 (ASCII) variant of CFH-COPY.
- **PRINTOUT** (output-print): ASSIGN PRINTER  ->  PRINTER; LABEL RECORD OMITTED; record length 132 - Conditional, same as CFH-COPY.
