---
mode: agent
description: "Fix a defect in the SsgConverter C# source, rebuild, and re-verify (Area B)"
argument-hint: "<issue> (e.g. 'level-number parse bug', 'KI-2 divide')"
---

# /ssg-fix-converter — ${input:issue}

Fix **${input:issue}** in the SsgConverter C# source. Follow
[ssg-converter-dev.instructions.md](../instructions/ssg-converter-dev.instructions.md).

## Steps

1. **Reproduce first.** Show the exact failing SSG input line, the current (wrong) generated output,
   and the resulting parse error / exception. If you cannot produce a concrete failing case, STOP and
   report — a KI-1..3 item must not be touched without one.

2. **Locate** the responsible code in `SsgConverter/Source/SsgConverter/`
   (`SymstreamProcessor.cs`, `SymstreamExpressionParser.cs`, `SymstreamExpressionMigrator.cs`,
   `StreamGenerationStatements.cs`). Explain the root cause in one or two sentences before editing.

3. **Make the smallest fix.** Don't refactor unrelated code. Never delete anything under
   `Source/_deps/`.

4. **Rebuild:**
   ```powershell
   dotnet build SsgConverter/Source/SsgConverter.slnx -c Debug
   ```

5. **Re-verify examples (Area C).** Reconvert `SsgConverter/Examples/Input` and diff vs
   `SsgConverter/Examples/Output`; account for every changed line.

6. **Acceptance = Area A parse-check.** Re-run the Tier-1 parse-check on the affected program(s);
   success is **parse errors: 0**, then a clean harness run.

7. **Report** root cause, the change, and before/after parse-error counts. Note if any golden output
   legitimately changed.

## Guardrails
- Read-only against `SSG-Source/` and `Examples/Input`.
- Scope strictly to the reported defect.
