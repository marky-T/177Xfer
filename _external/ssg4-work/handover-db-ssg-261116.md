# Copilot handover: DB SSG utilities (RECAP, TABAN, EXTEUR), 261116

**Paste into a fresh session:**

> Read `E:\Repos\ssg4-work\handover-db-ssg-261116.md` and the plan
> `.github/Copilot_Plans/261116-db-ssg-programs-plan.md`, then do the "Job for this session" below. Stop at each gate.

## Where we are

- Plan written 261116 (owner: good to share with Allard / Eddy / Hagop **after** this session records the issues).
- Probe done 261116, evidence in `E:\Repos\ssg4-work\db-probe-261116\` (`expansion.csv`, `conversion-summary.csv`,
  `expanded\`, `cobol\out\*.LionSource`, `cobol\logs\*.stdout.txt`). Inputs: cards
  `E:\Repos\ssg4-work\sgs-cards\sgs-calls.csv` (ProgramKey RECAP / TABAN_ASCII / EXTEUR), skeleton sources
  `SsgConverter\Examples\Input\{RECAP,TABAN_ASCII,EXTEUR}.TXT`.
- Results: RECAP 28 calls → 14 distinct → 11 convert clean, 3 fail `PIC X(0)`; TABAN 27 → 26 → all clean;
  EXTEUR 1 → fails, 99 errors (`INVOKE TABLE EU001 OF AFLINC FROM REPOSITORY`, T3-037) + 17 `END-IF` errors.
- Database: RECAP/TABAN only open an RDMS read session (`UDSSRC`, qualifier `AFLINC`) for routine `EUU003`; no
  query of their own. EXTEUR: `SELECT C_PHA_EUR FROM EU001`. Missing in FEDERALE_APP: `CDTOAF`, `ABORT`, `EREABT$`.
  Present: `Euu003.dll`, `Msgerr.dll`, `Bloace.dll` (in `Federale_InternalRelease\AFBUS_AMT\Binaries\Programs`).
- Known issues already logged: T3-023 (INFO$ blanked; labels part fixed by R&D PR 16391), T3-027 (RSA$INIT /
  ACOB$RDMR become comments), T3-037 (EXTEUR INVOKE TABLE), MT-052 (RSA/UnloadSql).
- Next free ids (261116): **T3-066**, **MT-069**.

## Job for this session: record the conversion issues, fix those we can, then build RECAP as a generic program

1. **Re-check the probe is repeatable**: re-run the conversion for one RECAP clean call, one RECAP `X(0)` call
   (COCM03 L523), one TABAN call and EXTEUR into a new folder; error and warning counts must match
   `conversion-summary.csv`. If not, stop and report.
2. **Classify every finding** (Area E classes: CONVERTER_DEFECT, UNSUPPORTED_SOURCE_CONSTRUCT,
   FEDERALE_SOURCE_AMBIGUITY, UNRESOLVED_UNISYS_SEMANTIC, AMT_PLATFORM_ADAPTATION, …), each with the call, the
   line in the expanded COBOL, the converter message and the source line in the skeleton:
   - `PIC X(0)` (RECAP skeleton line 157, `*SET A2 TO [FIELDOUT,1,I,2] - 1`; real cards with a 1-byte FIELDOUT field).
   - EXTEUR `END-IF` errors (17): where, and is it COBOL-85 text in an ACOB program?
   - EXTEUR `INVOKE TABLE` (existing T3-037: add today's evidence, do not duplicate).
   - `RSA$INIT` / `ENTER MASM 'ACOB$RDMR'` (existing T3-027: add today's evidence).
   - Missing routines `CDTOAF`, `ABORT`, `EREABT$`; present `EUU003`, `MSGERR`, `BLOACE`.
   - Warnings worth noting (TABAN: numeric vs SPACE compares, 7–29 per program): note only, no T3.
3. **Log them** per `ssg-todo-issues.instructions.md`: new `T3-nnn` only for a new confirmed problem; extend
   T3-027 / T3-037 rows otherwise; one `MT-069` row "DB SSG utilities RECAP/TABAN/EXTEUR: plan + probe" linking the
   plan and the T3s. Also a short line in the plan §1 for each new T3.
3a. **Fix what we can, now (owner 261116: log and fix, don't put off).** For each logged issue decide:
   - **Fix now** when the fix is ours and needs no shared decision: our own scripts, our SsgConverter (Area B, via
     `/ssg-fix-converter`, with the failing case as its test), our hand-off / generic-program design, our docs.
     Make the fix, re-run the same probe calls, show before/after counts, and mark the T3 fixed with the evidence.
   - **Shared decision first** (log, add to the team note, do not fix): R&D's CobolConverterConsole or ECL converter
     (`amt-go-net`, waits for the MT-058 merge decision), AMT runtime (`AmtPsEclLib`), FEDERALE_APP programs or
     database, shared pipeline scripts (Area E: needs the owner's go-ahead and a full regression), anything that
     changes Federale's source or cards.
   - A skeleton/card fact (e.g. `PIC X(0)` from a 1-byte field) is not "fixed" by changing the source: decide how the
     **generic program** handles it (spec + model), and only ask Eddy if the OS 2200 behaviour is unknown.
   **Gate:** list the fix-now items and the planned change before editing; owner approves.
4. **Board check** (`/ssg-board-ticket` rules): which findings meet the trigger (root cause confirmed, R&D product).
   List them in `docs/RnD-Tickets/board-candidates.md`; do not create anything.
5. **Build the generic program (owner 261116: building it is how we find the real issues).** After 3a's gate (and step 4), run
   `/ssg-generic-utility RECAP` (one utility per run; RECAP first: 28 calls, 14 shapes, the `X(0)` case). Go
   G1 → G8 with every gate; at each step **log any issue it raises and fix it under 3a's rule** (fix ours now, defer
   only shared decisions). Points to settle in G2's spec, each with a claim class:
   - the RDMS session (`RSA$INIT`, `ACOB$RDMR` BEGIN/USE/END THREAD, GETERROR): AMT_PLATFORM_ADAPTATION (AMT uses
     the application's own connection) unless the team says otherwise;
   - the `EUU003` call (amount conversion via `EUW002`): the generic program calls it as on OS 2200; its behaviour is
     UNKNOWN until Q1 is answered, so the model must not invent it (record what AMT's `Euu003` does);
   - `PIC X(0)` from a 1-byte FIELDOUT field: how the generic program lays out that field;
   - `ABORT`: map to AMT's abort, as the other generic programs do;
   - schema choice from INFO$ project id (T3-023 part 2).
   The CC run (G8) needs `EUU003` reachable from the program's application: if it is not in AFBUS_2200COBOL_AMT, stop
   at G7 and add it to the team questions (Q2) rather than copying FEDERALE_APP's DLL.
   Then TABAN (`CDTOAF` missing) in a later run; EXTEUR only after EU001 is answered.
6. **Team note**: only what still needs the team after 3a and 5. Copy the plan's §1 (probe results), §3 (questions),
   the fixed items (one line each, "fixed, T3-nnn") and the open T3 ids into
   `E:\Repos\ssg4-work\db-ssg-questions-for-team-261116.md`, same layout as
   `archive-missing-ssg-for-eddy-261116.md`. **Gate:** owner reviews before sharing with Allard / Eddy / Hagop.
7. Hand the owner the commit commands (plan + tracker + candidates + RECAP work); then `/ssg-backup`.

## Rules (from the instructions)
- Area E: no shared pipeline script changes (`Invoke-SsgExpansion.ps1`, `Invoke-CobolConversion.ps1`, …).
- `SSG-Source/` and `SsgConverter\Examples\Input` are read-only. Scratch stays in `ssg4-work`.
- Control Center runs and LionDev imports only as `/ssg-generic-utility` steps the owner does (operations checklist); no ADO writes.
- Never edit generated C#; never change a check to make it pass.
- The owner commits SsgTrial (elevated).

## Report back (for the update thread)
At the end, write `E:\Repos\ssg4-work\report-db-ssg-<yyMMdd>.md` with:
- the gate reached for RECAP (G1–G8) and what stopped it, if anything;
- issues found: T3 ids, one line each, marked **fixed** (with before/after evidence) or **open — who decides**;
- MT rows added or changed; board candidates added;
- the team note path and whether the owner approved it;
- commits made (hashes) and the `/ssg-backup` commit;
- the next step (TABAN, EXTEUR, or answers awaited).
The owner pastes this file into the update thread.
