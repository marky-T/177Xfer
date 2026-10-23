# Done / open items extracted from T3-PS-Import-Requirements-AMT177to172.md

Source: `06-plans/Amt/.github/Copilot_Plans/T3-PS-Import-Requirements-AMT177to172.md` (original: `C:\Amt\.github\Copilot_Plans\T3-PS-Import-Requirements-AMT177to172.md`)

0 done / 15 open (markdown checkboxes)

## 1. Version & compatibility metadata (blocking — check first)

- [ ] Exact AMT build/version on the source VM (the doc metadata convention is e.g.
- [ ] .NET runtime the generated `.ps1` scripts and `AmtPsEclLib.psm1`/`AmtPsSortLib.psm1` were
- [ ] Which `AmtPsEclLib.psm1` version the scripts require — bundle the **exact `.psm1`/`.dll`
- [ ] Whether this is a **superset/replacement** of the existing 10-program `T3ConvertedSSG` bundle

## 2. Per-program bundle contents (all 20)

- [ ] Raw SSG/ECL source (`ASSURFED_*.TXT`) as converted from.
- [ ] The generated `.ps1` script.
- [ ] Execution status on the source VM: **mock-shell only** (Tier‑1, no AMT connection) vs.
- [ ] All logical file names / DISC designators the script uses via `Asg`/`Use`/`Qual` calls (these
- [ ] A mock input file (or generation recipe) per program, plus an expected/golden output where one

## 3. Script identity & naming

- [ ] Confirm the naming convention expected for registering a script job (equivalent of the C# path's
- [ ] `Set-Jobname` value used inside each script (this becomes the job's identity in CC logs).

## 4. Runtime/dependency closure

- [ ] Full list of `Import-Module` calls in each script (beyond `AmtPsEclLib`/`AmtPsSortLib`) — any
- [ ] Confirm whether the scripts expect **`AmtPowershellHost.exe`** hosting (BatchController-driven,
- [ ] An `AmtSettings.xml` sample **from a proven working run on the source VM** (even though AMT172

## 5. Delivery format

- [ ] One folder per program (`<PROGRAM-ID>/{source.txt, script.ps1, mock-input.*, expected-output.*,
