# Per-Program Trial Checklist — Definition of Done

Copy this file into `Trial3\docs\checklist-<PROGRAM>.md` and tick off each item.

Program: `<PROGRAM_KEY>` / PROGRAM-ID: `<PROGRAM-ID>` / Trial: `trial3-NN`

---

## Phase 1 — Source Analysis
- [ ] Read raw SSG source; identify PROGRAM-ID, all `*IF`/`*SET`/`*DEFINE`/`*LOOP` directives
- [ ] Identify all ECL tokens `[PARAM]`, `[INPUT]`, `[OUTPUT]` and custom tokens
- [ ] Note conditional branches; choose `paramOverrides` + `conditionValues`
- [ ] Compare source vs Trial 2 equivalent (if overlap program) — diff and note differences

## Phase 2 — Candidate Generation
- [ ] Pilot script created at `tools\Run-Pilot-<PROGRAM>.ps1`
- [ ] Settings file created at `settings\trial3-NN-<programid>.settings`
- [ ] `Remove-SsgDirectives.ps1` runs without error
- [ ] Candidate file is BOM-free (first bytes ≠ 239 187 191)
- [ ] No residual `[token]` patterns in candidate (`Select-String '\[' <candidate>`)
- [ ] `CobolConverterConsole` produces non-zero `.LionSource` output

## Phase 3 — Fixtures
- [ ] `fixtures/<key>/input.dat` created; byte count documented
- [ ] `fixtures/<key>/expected.dat` hand-derived; byte count verified
- [ ] `fixtures/<key>/assign.json` file assignments recorded

## Phase 4 — Refimpl Oracle
- [ ] `tools/refimpl/<key>.ps1` written and runs standalone
- [ ] Oracle output matches `expected.dat` (diff = 0)

## Phase 5 — Proof
- [ ] `Run-EclProof.ps1 -Program <PROGRAMID>` → PASS diff=0
- [ ] No warnings in proof output

## Phase 6 — Manifest
- [ ] Manifest entry `status` updated to `"done"`
- [ ] Full `proof` block added (executor, refImpl, fixtureDir, inputSpec, fileAssignments, expectedFile, notes)

## Phase 7 — HTML Generation
- [ ] Trial JSON content file prepared (`templates/examples/trial-03-<name>_v1.json`)
- [ ] `Update-TrialProgress.ps1` runs successfully → HTML generated
- [ ] `Update-CommandMatrix.ps1` runs successfully → HTML generated
- [ ] `Update-PowerShellReference.ps1` runs successfully → HTML generated
- [ ] `Validate-TrialHTML.ps1` PASS on all three generated files
- [ ] `htmlGenerationConfig` added to manifest entry

## Done ✅
All boxes ticked = program complete. Commit: manifest + fixtures + refimpl + settings + generated HTML.
