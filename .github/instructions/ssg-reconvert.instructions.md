---
name: "SSG Area C — Reconvert SSG-COBOL → PowerShell"
description: "Use when re-running SsgConverterConsole to (re)generate PowerShell from SSG source: settings file, input/output folders, reviewing the warning taxonomy, verifying examples. Area C of the SSG→PS trial."
applyTo: ["**/Examples/**", "**/manifest/**", "**/config/**"]
---

# Area C — Reconvert SSG-COBOL → PowerShell

Regenerate `.ps1` from SSG source with `SsgConverterConsole.exe`, then hand the output to Area A.
See the always-on [copilot-instructions.md](../copilot-instructions.md) and the behaviour spec in
[SsgConverter/SsgConverter-COPILOT.md](../../SsgConverter/SsgConverter-COPILOT.md).

## Run the console

```powershell
SsgConverter/Build/Console/SsgConverterConsole.exe /SETTINGSFILE:"<path-to>.settings"
```
Or with explicit parameters:
```powershell
SsgConverter/Build/Console/SsgConverterConsole.exe /INPUT:"<in>" /OUTPUT:"<out>" `
  /CONTINUEONERROR:TRUE /VERBOSE:2 /ENABLELOGFILE:TRUE /LOGFILE:"<out>"
```

## Settings file (XML) — update paths per machine

The template `SsgConverter/Examples/Settings/SsgConverterSettings-example.settings` still carries the
**stale** `C:\SsgConverter-Release-20260821\...` paths — repoint `InputFolder` / `OutputFolder` /
`LogFile` at real repo paths before use.

| Element | Verification-run value |
|---------|------------------------|
| `InputFolder` | `SsgConverter/Examples/Input` |
| `OutputFolder` | a scratch dir (e.g. `SsgConverter/Examples/VerifyOutput`) — **not** `Examples/Output`, so the golden stays intact for diffing |
| `ClearOutputFolder` | `false` |
| `ContinueOnException` | `true` |
| `VerboseLevel` | `2` |
| `LogFile` | a folder path → auto-timestamped log per run |
| `EnableLogFile` | `true` |

## Verify the run

1. Diff the fresh output against the golden `SsgConverter/Examples/Output/<Program>.ps1` (5/5 examples
   must match unless a converter change intentionally moved a golden).
2. Read the log and classify every message against the taxonomy — do **not** treat expected
   comments as errors:
   - Expected in output: `# Orphaned data line:` (COBOL after `#ucob`), `# Embedded content
     (unconverted):` (ECL runstream), `# NOT IMPLEMENTED: *directive`.
   - Log warnings (mostly no-action): `No SSG directives recognised` (file is plain COBOL — remove
     from input), `Orphaned data line`, `Missing @FIN — auto-appended`, `ECL parse failed for
     content block` (review; may need the ECL converter).
   - Real errors: `Error converting <name>:` and `IMPORTANT-WORKAROUND applied` (`*ITERATE` targeting
     an outer loop — the `.ps1` is semantically different there; see Fix 11 in the fix log).
3. Hand the regenerated program to **Area A** (`/ssg-run-trial <Program>`) — the real test is that it
   parses (0 errors) and runs.

## MT-003 — which inputs exist

Only **5** input files are present locally (`ARCHISEPARE`, `BABA_ASCII.TXT`, `CFH-COPY.TXT`,
`CHABAN_ASCII.TXT`, `UNLOADIS_ASCII.TXT`). The historical "36-file run" inputs are **not** on this
VM. To convert anything else, source it from `SSG-Source/` (read-only, different naming) first;
don't assume the other ~31 files are present.

## Manifest naming — key vs programId

When reading `Trial3/manifest/programs.manifest.json`, two identifiers are **not** interchangeable
(carried over from the EclCobolPipeline conventions):

- **key** = the manifest `key` field = the SSG element name (e.g. `LOADIS_MULT-NODUP`). Fixture,
  refimpl and `sgs-values.json` paths derive from the **key** (lowercased).
- **programId** = the COBOL `PROGRAM-ID.` value (e.g. `LECTIS` for SSG element `LECTIS_MULT`).
  Candidate/settings filenames in the Trial3/EclCobolPipeline convention use the **programId** — the
  "candidate filename must match PROGRAM-ID" rule.

> **SsgConverterConsole output naming (verified 2026-09-24, `SsgConverterConsole/Program.cs` L121/L160):**
> `Examples/Output/<Program>.ps1`'s base name is always the **input file's base name**
> (`Path.GetFileNameWithoutExtension(ssgFile)`), **not** the COBOL `PROGRAM-ID`. These usually match
> for the 10 example programs already converted (e.g. `CFH-COPY.TXT` → `PROGRAM-ID. 'CFH-COPY'.` →
> `CFH-COPY.ps1`), so the coincidence is easy to miss — but it isn't guaranteed and can't be assumed:
> `LECTIS_ASCII.TXT`'s `PROGRAM-ID` is `LECTIS` (no `_ASCII`), yet its output is `LECTIS_ASCII.ps1`
> (from the input filename). `FUSBA2_ASCII.TXT` goes further — its `PROGRAM-ID` is **dynamic**,
> `FUSION-[OUTPUT,1,1,1]` (an SGS bracket reference resolved only at run time), so a `PROGRAM-ID`-based
> output name wouldn't even be static. Always use the **input file's base name** to predict/locate the
> `Examples/Output/<Program>.ps1` that Area A (`/ssg-run-trial`) will look for.

## Guardrails
- `SSG-Source/` and `Examples/Input` are read-only — never edit inputs.
- Don't overwrite `Examples/Output` goldens during a verification run — use a scratch output folder.
