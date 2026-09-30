# FUSBA2_ASCII

- **SSG source:** `source.txt` (from `SsgConverter/Examples/Input/FUSBA2_ASCII.TXT`)
- **Converted PowerShell:** `script.ps1` (from `SsgConverter/Examples/Output/FUSBA2_ASCII.ps1`)
- **Execution status:** tier1-only - ran to completion in the Tier-1 mock-shell harness only; never run against a real AmtPsEclLib or live Connect-Application.
- **mock-input.*:** not applicable - our Tier-1 harness has no real file I/O, only SGS-parameter + line-emission mocking. See `Tier1Mock/sgs-values/FUSBA2_ASCII.sgs-values.json` for the parameter values used instead.
- **expected-output.*:** No Trial3 fixture applies to this program (no-manifest-entry).

## DISC designators (see ../../DiscDesignators.json for the full structured version)
- **TAPEIN[*INPUTCT]** (input): ASSIGN UNISERVO/DISC/CARD-READER [INPUT,1,INPUTCT,1]; LABEL RECORD STANDARD or OMITTED (conditional); record length [INPUT,1,IMP,2] (unresolved) - GAP: same *LOOP-count-is-0 issue as FUSBA_ASCII/BABA_ASCII. Also recall FUSBA2_ASCII's PROGRAM-ID is dynamic ('FUSION-[OUTPUT,1,1,1]') per the Area C naming note.
- **TAPEOUT[*OUTPUTCT]** (output): ASSIGN UNISERVO/DISC [OUTPUT,1,OUTPUTCT,1]; LABEL RECORD STANDARD; record length [OUTPUT,1,OUTPCT,2] (unresolved) - Same loop-count gap.
