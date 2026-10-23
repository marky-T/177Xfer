# SSG-4 — How a mainframe report runs (assumed execution model)

> **Status: draft, 2026-10-12.** This is our working definition of how a Federale SSG/ECL report runs
> on OS 2200 and how that maps onto AMT. It will become a section of the SSG-4 runbook once the process
> is worked out. Every statement carries an evidence label (epic §3):
> **MANUAL** = proven by a Unisys manual, **SOURCE** = observed in Federale source/runstreams,
> **AMT** = observed in AMT's runtime/tools, **DERIVED** = working model, **ASSUMPTION**, **UNKNOWN**.
>
> **Decision (2026-10-12): we assume the same model as AMT.** SGS cards are read at *run time* by
> AMT's runtime (`Invoke-Ssg` → `StartSSG` / `Add-Sgs` / `AddTo-SgsList` → `GetSgsValue`), exactly as
> AMT converts and runs `@SSG`. We do not invent a different mechanism.

## 1. Terms

| Term | Meaning |
|---|---|
| **Runstream** | An ECL job, `@RUN` … `@FIN`, scheduled by the operator/scheduler. Example: `ASSURFED_F999RUN_VIRM01_CO`. |
| **Report / program** | A compiled COBOL program run by `@XQT`. In AMT: a C# DLL started by `Xqt`. |
| **Skeleton** | An SSG template: COBOL and ECL text mixed with SSG directives (`*IF`, `*SET`, `*INCREMENT` …) and `[label,…]` references. Example: `*UTILIT.CFH-COPY/ASCII`. |
| **SGS** (Stream Generation Statement, "SGS card") | One parameter line: a **label**, then **fields** separated by spaces, each split into **subfields** by commas. Referenced in a skeleton as `[label,statement,field,subfield]`. |
| **SSG** (Symbolic Stream Generator) | The `@SSG` processor: combines a skeleton with SGSs and writes out a generated stream. |

## 2. A typical SSG/ECL report step on OS 2200

Worked example: `VIRM01_CO` (653 lines, 15 `@XQT`, 43 `@ADD`, **1** `@SSG`). SOURCE.

```
@SSG,IA  *UTILIT.CFH-COPY/ASCII         <- run skeleton CFH-COPY/ASCII ...
SGS                                      <- ... with these SGS cards
ASCII
INPUT      INB,500,10
OUTPUT     INC,135,10
FIELDIN  6,9 19,6 403,2 57,8 65,4 113,24 161,24 405,16 421,24 265,8
FIELDOUT  11,9 20,6 26,2 28,8 36,4 40,24 64,24 88,16 104,24 128,8
FIXE 1,10,TAX-CLASIQ
@EOF                                     <- end of SGS input
@ASG,A     I006VRM01ATT.                 <- input file
@USE       INB,I006VRM01ATT.             <- bind internal name INB to it
@DELETE,C  I006VRM01ATC.
@CAT,P     I006VRM01ATC,F/0/POS/4000     <- create output file
@ASG,A     I006VRM01ATC.
@USE       INC,I006VRM01ATC              <- bind internal name INC to it
@XQT,WR    .CFH-COPY                     <- run the program SSG just built
@FREE      I006VRM01ATC.
@FREE      I006VRM01ATT.
@ERS       TPF$.                          <- clear the run's temporary file
```

What happens, step by step:

| # | Step | Evidence |
|---|---|---|
| 1 | `@SSG` reads the skeleton (param-1) and the SGS input that follows in the runstream: the `SGS` line is a file-id statement, the cards follow, `@EOF` ends them. | MANUAL (`78311784-010` §2.2, Table 2–2); SOURCE |
| 2 | The skeleton substitutes the card values into COBOL text. In CFH-COPY: `01 RECIN PIC X([INPUT,1,1,2])` becomes `PIC X(500)`; `SELECT TAPEOUT ASSIGN TO … [OUTPUT,1,1,1]` becomes `… INC`; `*INCREMENT I … TO [FIELDIN,1]` repeats once per field. | SOURCE (skeleton lines ~90–140) |
| 3 | Skeleton lines not starting `*` go to the generated output stream; a `#` in column 1 is converted to `@`, so `#ACOB` / `#MAP` become `@ACOB` (compile) and `@MAP` (link into `TPF$.CFH-COPY`). | MANUAL (`78311784-010` §4.3, `NSIGNCHAR$`); SOURCE (CFH-COPY lines 10–12, 416) |
| 4 | Unless option `B` is given, SSG `@ADD`s the last part of the generated stream before it ends, so the tailored program is compiled and linked in the same run, **on every call**. Options on `@SSG,IA`: `I` = list SGSs as input (listing only); `A` = continue on "no find" conditions. Neither changes the output. | MANUAL (`78311784-010` §2.4, Table 2–1) |
| 5 | `@ASG`/`@USE` bind the internal names on the cards (`INB`, `INC`) to real files; the generated COBOL `SELECT … ASSIGN` uses the same names. **The SGS card is what ties the COBOL to the ECL file assignments.** | SOURCE |
| 6 | `@XQT,WR .CFH-COPY` runs the just-built program from the run's temporary file (leading `.` = `TPF$`). | DERIVED |
| 7 | Contrast: the other 14 `@XQT`s (`VIRM01CO.VIR360` …) run ordinary programs compiled once and held in a program file. A report job is mostly ordinary programs, with occasional SSG-generated utility steps. | SOURCE |

### The SGS cards in the example

| Card | Reference(s) | Value | Meaning | Evidence |
|---|---|---|---|---|
| `ASCII` | `[ASCII]` | present | choose the ASCII COBOL variant | SOURCE (`*IF [ASCII] = 0`) |
| `INPUT INB,500,10` | `[INPUT,1,1,1]` / `,2` / `,3` | `INB` / `500` / `10` | input internal name / record length / third value | name + length SOURCE; third value UNKNOWN |
| `OUTPUT INC,135,10` | `[OUTPUT,1,1,1]` / `,2` / `,3` | `INC` / `135` / `10` | output internal name / record length / third value | as above |
| `FIELDIN 6,9 19,6 …` | `[FIELDIN,1,n,1]`, `[FIELDIN,1,n,2]` | 10 pairs | input fields to copy: (start, length); `6,9` expands to `FILLER PIC X(5)` + `ZONE1 PIC X(9)` | SOURCE (real-card expansion, 2026-10-12) |
| `FIELDOUT 11,9 20,6 …` | as above | 10 pairs | where each field goes in the output: (start, length); `MOVE ZONE1 TO ZONO1` | SOURCE (real-card expansion) |
| `FIXE 1,10,TAX-CLASIQ` | `[FIXE,1,1,n]` | `1`, `10`, `TAX-CLASIQ` | a constant written into the output: (position, length, value); `FIXED1 PIC X(10) VALUE 'TAX-CLASIQ'` | SOURCE (real-card expansion) |
| `SGS` | — | — | file-id statement: "stream generation statements follow"; not itself a card | MANUAL (`78311784-010` Table 2–2) |

## 3. The same step in AMT (assumed model, decided 2026-10-12)

| OS 2200 | AMT | Evidence |
|---|---|---|
| `@SSG,IA skeleton` + cards | `Invoke-Ssg -Options "IA" -Skeleton "…/UTILIT_CFH-COPY_ASCII" -SgsFile "P$SGS\VIRM01"` | AMT (ECL converter output, ours and R&D's released script) |
| SSG starts | `StartSSG`: new SGS dictionary; loads global SGSs, then `P$SGS\<JobName>` beside the scripts folder, then command-line SGS overrides | AMT (`AmtPsEclLib.psm1` `StartSSG`) |
| SGS cards | A text file of card lines loaded by `Add-Sgs`; each line parsed by `AddTo-SgsList` into label → fields → subfields | AMT |
| `[label,s,f,sf]` in the skeleton | `GetSgsValue "[label,s,f,sf]"` in the converted skeleton `.ps1` | AMT |
| Skeleton | Converted skeleton `.ps1` (SsgConverter output), run by `Invoke-Ssg` | AMT |
| `@ASG` / `@USE` | `Asg` / `Use` | AMT |
| `@XQT` | `Xqt "R, W" (".CFH-COPY")` — inserts a job request; the BatchController runs the report (a C# DLL) | AMT; Reference Docs *Overview Batch Jobs in AMT*, "Starting a report" |
| `#ACOB` / `#MAP` (compile per call) | No run-time equivalent; the report must already be built | DERIVED |

## 4. Known gaps against this model (open)

1. **The inline cards are not carried over — incorrect, logged as T3-020.** Both our ECL conversion and R&D's released
   `VIRM01_CO.ps1` drop the cards and point at `P$SGS\VIRM01`; no such file exists on this VM. Under
   the AMT model the cards **must be written into the SGS file `Invoke-Ssg` loads** (one card per line, `AddTo-SgsList`
   format, without the `SGS` file-id line). Open: how a runstream with several `@SSG` calls
   names its files. Raised for R&D (MT-033 item 11).
2. **How the values reach the pre-built report.** On OS 2200 the program is rebuilt with the card values
   on every call; in AMT the report is pre-built C#. Record lengths and field maps reach the converted
   skeleton at run time, but how the right build (or its parameters) is chosen at `Xqt` is undecided
   (epic B4/D5). Related: several of our 20 programs share a PROGRAM-ID (`CFH-COPY` ×3, `CHABAN` ×2,
   `FUSION-0` ×2).
3. **Card meanings marked ASSUMPTION/UNKNOWN** above need the skeleton read field by field; the SSG
   manual (`78311784-010`) defines the card *format*, not what a given skeleton does with it.
4. **AMT's card parser is simpler than SSG's.** `AddTo-SgsList` splits on spaces and commas only. The
   manual (§3.1.1) also allows quoted subfields (`'…'`, `''…''`), continuation with a trailing ` ;`,
   and spaces after a comma. The `VIRM01_CO` cards use none of these; any card that does must be
   checked before relying on AMT's parse. MANUAL + AMT. Raised for R&D (MT-033 item 12). **Our export now
   applies SSG's rules** (join continuations, cut at an unquoted period, drop spaces after a comma and `''`
   pairs) so AMT sees the cards SSG would have seen; this is deliberate and documented in the working-example
   README. A quoted subfield containing a space or comma cannot be fixed in the card and stays a Warning.
   Warnings show at conversion time only, not in the AMT job log yet (MT-034).

## 5. What this means for testing

- Every SSG program is tested with **real cards from a runstream** where one exists (17 of our 20;
  none for `ARCHIFORMAT`, `ARCHISEPARE` or plain `CFH-COPY`),
  supplied the AMT way (an SGS file loaded by `Invoke-Ssg`), not hand-typed seeds.
- **Two mock file sets with different record lengths** (epic D5): for `VIRM01_CO`, set 1 at 500/135
  and set 2 at different lengths with matching cards. Passing both proves the parameterisation works.
- `ARCHIFORMAT`, `ARCHISEPARE` and plain `CFH-COPY` have no runstream call; their cards are synthetic and marked so.
