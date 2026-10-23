---
mode: agent
description: "Reconvert an SSG source program to PowerShell with SsgConverterConsole and review warnings (Area C)"
argument-hint: "<Program> (e.g. CFH-COPY)"
---

# /ssg-reconvert — ${input:Program}

Regenerate PowerShell for **${input:Program}** and review the run. Follow
[ssg-reconvert.instructions.md](../instructions/ssg-reconvert.instructions.md).

## Steps

1. **Confirm the input exists.** Check `SsgConverter/Examples/Input` for `${input:Program}`. Only 5
   inputs are present locally (ToDo MT-003); if it's not there, source it from `SSG-Source/` first and say
   so — don't assume it exists.

2. **Prepare a settings file** pointing `InputFolder` at `SsgConverter/Examples/Input` and
   `OutputFolder` at a **scratch** dir (e.g. `SsgConverter/Examples/VerifyOutput`) so the golden is
   preserved. `VerboseLevel:2`, `EnableLogFile:true`, `ContinueOnException:true`.

3. **Run the console:**
   ```powershell
   SsgConverter/Build/Console/SsgConverterConsole.exe /SETTINGSFILE:"<settings>"
   ```

4. **Verify.** Diff the fresh `${input:Program}.ps1` vs `SsgConverter/Examples/Output/${input:Program}.ps1`.

5. **Review the log against the taxonomy** — separate expected comments (`# Orphaned data line:`,
   `# Embedded content (unconverted):`, `# NOT IMPLEMENTED:`) and no-action warnings from real errors
   (`Error converting`, `IMPORTANT-WORKAROUND applied`).

6. **Hand off to Area A** — run `/ssg-run-trial ${input:Program}`; report parse-error count and result.

## Guardrails
- Read-only against `SSG-Source/` and `Examples/Input`.
- Never write to `Examples/Output` during a verification run.
