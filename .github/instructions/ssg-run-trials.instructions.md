---
name: "SSG Area A — Run PowerShell trials"
description: "Use when running or debugging SsgConverter-generated PowerShell in the Tier-1 mock harness: parse-checking converted .ps1, Run-SsgPsTrial.ps1, sgs-values.json, diffing against Trial3 goldens. Area A of the SSG→PS trial."
applyTo: "**/Trials/**"
---

# Area A — Run trials on converted PowerShell (Tier-1 mock harness)

Prove that a SsgConverter-generated `.ps1` parses and runs, with no live AMT stack. See the
always-on [copilot-instructions.md](../copilot-instructions.md) for guardrails and current status.

## Layout

| Item | Path |
|------|------|
| Harness driver | `SsgConverter/Trials/Tier1Mock/Run-SsgPsTrial.ps1` |
| Mock runtime | `SsgConverter/Trials/Tier1Mock/SsgPsMockLib.psm1` |
| Per-program value table | `SsgConverter/Trials/<Program>/sgs-values.json` |
| Run output | `SsgConverter/Trials/<Program>/out/<Program>.out.txt` (+ `.error.txt` on failure) |
| Script under test | `SsgConverter/Examples/Output/<Program>.ps1` |
| Cross-check golden | `Trial3/candidates/*<Program>*` |

`<Program>` = the `Examples/Output/<Program>.ps1` base name (e.g. `ARCHISEPARE`, `CFH-COPY`).

## Standard process

1. **Orient.** Confirm `Examples/Output/<Program>.ps1` and `Trials/<Program>/sgs-values.json` both
   exist. If the value table is missing, seed it (see below).
2. **Parse-check FIRST — syntax only, no execution.** A converted script must reach **0 parse
   errors** before running is meaningful:
   ```powershell
   $e = $null
   [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$null, [ref]$e)
   $e.Count   # must be 0
   ```
   Record the count. If > 0, this is an **Area B** (converter) problem — report the first few errors
   and stop; do not hand-edit the generated `.ps1`.
3. **Run the harness** from `SsgConverter/Trials/Tier1Mock/`:
   ```powershell
   .\Run-SsgPsTrial.ps1 -Program <Program> [-Diff]
   ```
   Idempotent: it re-imports the mock, calls `Reset-SgsMock` (no state leaks between runs), and
   overwrites `out/<Program>.out.txt`.
4. **Review** the harness summary: emitted line count, **unmocked `GetSgsValue` lookups** (each
   means a key missing from `sgs-values.json`, defaulted to `0`), and `Call-ExternalProgram` calls.
   With `-Diff`, compare emitted lines against the matching `Trial3/candidates/*<Program>*` golden.
5. **Record result.** PASS only when parse = 0 **and** the diff is acceptable. Otherwise record
   *blocked + root cause*. Never mark done on a script that fails to parse.
6. **Prove repeatability.** Re-run twice — `out/<Program>.out.txt` must be byte-identical.
7. **Closing action — update the tracker.** Once the run has completed **and the user has reviewed it**,
   sync [docs/SSG-PowerShell-Trial-Progress.html](../../docs/SSG-PowerShell-Trial-Progress.html) via
   the [`/ssg-update-tracker`](../prompts/ssg-update-tracker.prompt.md) prompt (or directly): §3 program
   status + stats, §1 current-state, the *Last updated* date, plus any `T3-nnn` issue (§6) or `MT-nnn`
   ToDo (§7) the run surfaced. This is the explicit step behind §8's "kept in step" note.

## Seeding `sgs-values.json`

Values come from the Trial3 manifest for that program (`paramOverrides` with brackets stripped +
`conditionValues` merged). Keys are the raw SGS lookup strings (case-insensitive), e.g.:
```json
{
  "_source": "Trial3/manifest/programs.manifest.json - key ARCHISEPARE",
  "filein,1,1,1": "ECL-CHERCHEUSE",
  "key,1,2,1": "0",
  "rsz,1,1,1": "40"
}
```
A `GetSgsValue` warning in the run output tells you exactly which key to add.

> Manifest entries are keyed by the SSG element **key**, which can differ from the COBOL `programId`
> (see the key-vs-programId note in [ssg-reconvert.instructions.md](ssg-reconvert.instructions.md)).
> Match the program you're actually running.

## Mock runtime surface (what the harness implements)

`GetSgsValue` (mocked lookup, warns + returns `0` on a miss) · `DataLineOrNoStatement` (captures the
emitted candidate line) · `CompareTypeSafe` (numeric if both parse, else case-insensitive string) ·
`Process-Skip` (always `$false` — no JUMP/label state) · `Call-ExternalProgram` (records `@UCOB`/
`@MAP` calls, invokes nothing) · `Fin` (no-op) · `Abort` (throws, to fail loudly) ·
`AddTo-SgsList` / `RemoveFrom-SgsList` / `Sort-SgsList` (recorded, not enforced).

If a converted script calls a primitive **not** in this list, that's a harness gap — add the mock to
`SsgPsMockLib.psm1`; do not stub it inside the generated `.ps1`.

## PowerShell gotchas (5.1 is the real target host; test there too)

- **Always `${var}` when an interpolated variable is followed by `_` or any identifier-legal
  character.** `"$jobName_*.log"` parses as a variable literally named `$jobName_` (underscore is a
  valid identifier char), *not* `$jobName` + `_`. Undefined + `Set-StrictMode` => *"The variable
  '$jobName_' cannot be retrieved because it has not been set."* Write `"${jobName}_*.log"`. This cost
  a long mis-investigation — see [T3-015](../../docs/SSG-PowerShell-Trial-Progress.html#T3-015).
- No non-ASCII in string literals — PS 5.1 misreads e.g. `→` and truncates the string. Use ASCII.
- Avoid backtick line-continuation in inline terminal commands (frequently truncated); prefer a
  `.ps1` file run with `powershell -File`, or single-line commands.
- `'0'..'9'` yields integers — use an explicit `@('0','1',...)` array when keys must be strings.
- Wrap pipeline results in `@()` before `.Count` under `Set-StrictMode`.

## Do not

- Hand-edit `Examples/Output/<Program>.ps1` to get a pass — a parse/semantic defect there is an
  Area B converter fix.
- Run Trial3's `Run-EclPipeline.ps1` past `-ListOnly` (missing `CobolConverterConsole.exe` — ToDo MT-002).
