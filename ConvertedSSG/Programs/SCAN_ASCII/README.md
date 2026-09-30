# SCAN_ASCII

- **SSG source:** `source.txt` (from `SsgConverter/Examples/Input/SCAN_ASCII.TXT`)
- **Converted PowerShell:** `script.ps1` (from `SsgConverter/Examples/Output/SCAN_ASCII.ps1`)
- **Execution status:** tier1-only - ran to completion in the Tier-1 mock-shell harness only; never run against a real AmtPsEclLib or live Connect-Application.
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See `Tier1Mock/sgs-values/SCAN_ASCII.sgs-values.json` for the parameter values used instead.
- **expected-output.*:** GAP: a same-named Trial3 fixture exists (Trial3/fixtures/scan) but uses DIFFERENT SGS parameters than our seed - deliberately NOT copied here. See GoldenReconciliation.json.

## DISC designators (see ../../DiscDesignators.json for the full structured version)
- **TAPEIN[*INPUTCT]** (input): ASSIGN DISC/UNISERVO [INPUT,1,INPUTCT,1]; LABEL RECORD OMITTED or STANDARD (conditional); record length [INPUT,1,IMP,2] (unresolved) - GAP: same *LOOP-count pattern as BABA_ASCII/FUSBA*_ASCII - unresolved at current seed.
- **TAPEOUT[*OUTPUTCT]** (output): ASSIGN DISC/UNISERVO [OUTPUT,1,OUTPUTCT,1]; LABEL RECORD STANDARD; record length [OUTPUT,1,OUTPCT,2] (unresolved) - Same loop-count gap.
- **PRT** (output-print): ASSIGN PRINTER  ->  PRINTER; LABEL RECORD ; record length  (unresolved)
