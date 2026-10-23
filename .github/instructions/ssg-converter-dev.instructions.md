---
name: "SSG Area B — Change the SsgConverter (C#)"
description: "Use when modifying the SsgConverter C# source: expression parser/migrator/processor, rebuilding the console, and re-verifying example outputs. Area B of the SSG→PS trial. Covers the KI-1..3 rule and the level-number parse bug."
applyTo: "**/Source/**"
---

# Area B — Change the SsgConverter (C#)

Only enter Area B with a **confirmed failing case**. See the always-on
[copilot-instructions.md](../copilot-instructions.md) for guardrails and current status, and
[SsgConverter/SsgConverter-COPILOT.md](../../SsgConverter/SsgConverter-COPILOT.md) for the behaviour
spec, warning taxonomy, and known issues.

## Source map — `SsgConverter/Source/SsgConverter/`

| File | Role |
|------|------|
| `SymstreamProcessor.cs` | Top-level directive processing (`*IF`/`*SET`/`*DEFINE`/`*LOOP`, data lines) |
| `SymstreamExpressionParser.cs` | Parses SSG expressions (KI-1 lives here) |
| `SymstreamExpressionMigrator.cs` | Emits the PowerShell for a parsed expression |
| `StreamGenerationStatements.cs` | Statement/emit helpers |
| `IContentLineConverter.cs`, `Expressions/`, `Enums/`, `Exceptions/` | Support types |

Console/GUI entry projects: `Source/SsgConverterConsole/`, `Source/SsgConverterGui/`.
Support DLLs in `Source/_deps/` are **not on NuGet** — never delete them.

## Change → verify loop

1. **Reproduce first.** Capture the exact failing input line + current wrong output (and, for a
   runtime defect, the parse-error or exception). No repro → no change (this is the KI-1..3 rule).
2. **Edit** the smallest responsible unit in the files above.
2a. **Verify the edit reached disk before building.** In-session a write-locked `.cs` (C# service) can
   leave the change in an unsaved editor buffer while disk keeps the old text — `dotnet build` then
   compiles the stale file. Confirm with the terminal (`Get-Content <file>` / check `LastWriteTime`).
   If it didn't flush, patch on disk with **VS Code closed** (see `Trials/Deploy-T3-003.ps1`); do not
   rely on a buffer flush (a flush on close can corrupt the file — this happened with T3-003).
3. **Rebuild** the console:
   ```powershell
   dotnet build SsgConverter/Source/SsgConverter.slnx -c Debug
   ```
   (The prebuilt `Build/Console` binaries are only refreshed by an explicit rebuild/publish — the
   verify step below runs the newly built exe under `Source/.../bin/Debug`.)
3a. **Verify the DLL actually changed** — compare the rebuilt `SsgConverter.dll` size/SHA256 to the
   previous one. An **identical hash means the change didn't compile** (almost always the not-flushed
   issue above), so don't trust a "0 errors" build alone.
4. **Re-verify the examples** — reconvert `SsgConverter/Examples/Input` and diff against
   `SsgConverter/Examples/Output` (5/5 must still match unless you intentionally changed a golden;
   if so, regenerate and eyeball every diff). This is an Area C run — see
   [ssg-reconvert.instructions.md](ssg-reconvert.instructions.md).
5. **Re-run the Tier-1 parse-check** (Area A) on the affected program(s) — the real acceptance test
   is `parse errors: 0`, not just "converter didn't throw".

## Known issues — do NOT fix without a confirmed failing test case

- **KI-1** — missing empty-right guard for trailing `OR`/`AND`/`XOR` in `SymstreamExpressionParser.cs`.
- **KI-2** — `*DIVIDE GIVING quotient,remainder` assigns modulo to the wrong variable
  (`SymstreamProcessor.cs`).
- **KI-3** — mixed ECL+SSG+COBOL files: SSG `*SET` converts; the ECL section is intentionally left as
  `# Embedded content (unconverted):`.

## First target (open work)

The current Area-A blocker: COBOL data-division level lines are emitted as bare
`DataLineOrNoStatement (01 LISTE PIC X(132).)` — a numeral adjacent to a bareword, which is a hard
PowerShell parse error. All 5 example outputs fail this way (103–248 errors). The emit path for
data/orphaned lines needs to quote the payload (or emit it as a single string argument) so the
generated `.ps1` parses. Reproduce, fix, rebuild, then re-run the Area-A parse-check.

## Guardrails
- `SSG-Source/` and `Examples/Input` are read-only reference — never edit inputs to dodge a bug.
- Keep changes scoped to the reported defect; don't refactor unrelated converter code.
