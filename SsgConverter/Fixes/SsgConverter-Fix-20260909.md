# SsgConverter Fix — 2026-09-09

**Issue:** T3-001 (see the [progress tracker](../../docs/SSG-PowerShell-Trial-Progress.html) §6).
**Build affected:** source tree `SsgConverter/Source/SsgConverter/` (library `SsgConverter.dll`).
**Area:** B (converter C#), driven by the Area-A Tier-1 parse blocker.

## Symptom

Every SsgConverter-generated `.ps1` failed **PowerShell parsing** (0 execution possible). Across the
5 example outputs: ARCHISEPARE 219, BABA_ASCII 241, CFH-COPY 248, CHABAN_ASCII 202, UNLOADIS_ASCII
103 parse errors — dominated by `Unexpected token ')'`, `Missing closing ')'`, unexpected barewords
(`FILLER`, `ligne`, `SEQ`), and unbalanced `}`.

## Root cause

COBOL data-division / output lines were emitted by running the **whole line** through
`SymstreamExpressionToPowerShellExpression(...)` — i.e. migrated as an SSG *arithmetic/operator
expression*. Ordinary COBOL punctuation was then misread as PowerShell operators:

- hyphens in names (`PROGRAM-ID`, `ligne-unload`) → subtraction
- `PIC X(n)` parentheses → unbalanced `(`
- level-number digits adjacent to a name (`06 FILLER`, `1 ligne`, `1100-60EIS`) → invalid tokens

Two emit sites in `SymstreamProcessor.cs` were affected: the stand-alone bracket line
(`lines[i].StartsWith("[")`) and the plain-text output line (final `else if`).

Example — CFH-COPY line 16, before:
```powershell
DataLineOrNoStatement ((06 FILLER PIC  X( + ($FILLCTR + ").")))     # 248 parse errors in the file
```

## Fix

New `SymstreamProcessor.OutputLineToPowerShellExpression(line, globals, locals)` builds the line as a
concatenation of **verbatim double-quoted string segments** (literal text) and **only** the
`[bracketed]` references converted with variable context (so `[FILLCTR]`→`$FILLCTR`,
`[INPUT,1,1,1]`→`GetSgsValue("INPUT,1,1,1")` resolve exactly as before — **no semantic change** to
bracket handling). Both emit sites now call it.

Same CFH-COPY line, after:
```powershell
DataLineOrNoStatement ("                     06 FILLER PIC  X(" + ($FILLCTR) + ").  ")
```

### Files changed
- `Source/SsgConverter/SymstreamProcessor.cs` — added `OutputLineToPowerShellExpression` +
  `QuoteForPowerShellDoubleQuotedString`; routed both `DataLineOrNoStatement` emit sites through it.
- `Source/SsgConverter/SymstreamExpressionMigrator.cs` — made
  `SplitBracketedReferencesAndLiteralParts` public (reused by the new method).

## Verification (Tier-1 mock harness)

| Program | Parse errors before → after | Harness run | Emitted lines |
|---|---|---|---|
| ARCHISEPARE | 219 → **0** | completed, no throw | 143 |
| CFH-COPY | 248 → **0** | completed, no throw | 47 |
| BABA_ASCII | 241 → **0** | (parse only) | — |
| CHABAN_ASCII | 202 → **0** | (parse only) | — |
| UNLOADIS_ASCII | 103 → **0** | (parse only) | — |

Reconvert = 5 succeeded / 0 failed; only expected-taxonomy warnings (orphaned data line, missing
`@FIN` auto-appended, `@MAP`/`@ACOB` unknown processor).

## Repeatable routine

`SsgConverter/Trials/Reconvert-And-Verify.ps1` performs the whole loop:
`-Rebuild` (dotnet build library) → `-RefreshDll` (copy into Build\Console + Build\Gui, keeping a
one-time `SsgConverter.dll.orig`) → reconvert Examples\Input → parse-check → Tier-1 harness.
Use `-UpdateGoldens` to regenerate `Examples\Output` (backs up to `SsgConverter\_backup\` first).

## Deployment status / follow-ups

- **Source fix + library build: done and verified** (via a scratch console copy).
- **Deployed 2026-09-10** (ran with VS Code closed): `Build\Console\SsgConverter.dll` and
  `Build\Gui\SsgConverter.dll` refreshed to the fixed build (51200 bytes), and `Examples\Output`
  goldens regenerated — all 5 parse 0; ARCHISEPARE (143) + CFH-COPY (47) run OK in the harness.
  (While VS Code is open, its extensions hold OS read-locks on the loaded `.dll` and analysed `.ps1`
  files, so the overwrite must be done with VS Code closed via
  `SsgConverter\Trials\Reconvert-And-Verify.ps1 -Rebuild -RefreshDll -UpdateGoldens`.)
- **Known build gap (ToDo MT-004, pre-existing):** `Source/SsgConverterConsole/SsgConverterConsole.csproj`
  does not build standalone — it uses an undefined `$(SsgDeps)` property and two `ProjectReference`s
  to `..\..\..\EclConverter (1)\...` outside the repo. `ConverterSupport.dll`, `PowerShellGenerator.dll`,
  `PowerShellWriter.dll` are already in `Source/_deps/`; `ScriptLanguageVocabulary` /
  `EclConversionOptions` come from the external EclConverter projects. The library builds fine and the
  refresh routine only needs the library DLL, so the console rebuild is not required for this cycle.
