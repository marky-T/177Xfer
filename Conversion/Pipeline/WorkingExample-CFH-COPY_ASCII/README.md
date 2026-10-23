# WORKING EXAMPLE: CFH-COPY_ASCII with the VIRM01_CO cards

One SSG report step taken through the SSG-4 pipeline, with every input and output checked in. It is the
simplest of the 17 programs that have a real runstream call: it copies records from one file to another,
re-laying out the fields.

Run it:

```
pwsh -NoProfile -File Run-WorkingExample.ps1
```

It regenerates everything into a temp folder and compares it byte for byte with `expected\`. `RESULT: PASS`
means the pipeline still gives exactly these results. `-Update` accepts new ones after a deliberate change.

## What goes in and what comes out

| Stage | File | What it is |
|---|---|---|
| Input | `input\ASSURFED_F999RUN_VIRM01_CO(P).TXT` | 22 lines of the real runstream: the `@RUN` line and the step that calls `*UTILIT.CFH-COPY/ASCII` with its SGS cards, then assigns the files and runs the program |
| Input | `SsgConverter\Examples\Input\CFH-COPY_ASCII.TXT` | The SSG skeleton (the template) |
| Input | `SsgConverter\Examples\Output\CFH-COPY_ASCII.ps1` | The same skeleton converted to PowerShell by SsgConverter |
| 1 | `expected\1-cards\calls\*.sgs` | The 6 SGS cards, exported from the runstream (`Export-SgsCards.ps1`) |
| 2 | `expected\2-expanded\CFH-COPY_ASCII.cob` | The COBOL the skeleton generates with those cards (`Invoke-SsgExpansion.ps1`, using AMT's own SGS functions) |
| 3 | `expected\3-lionsource\CFH-COPY_ASCII.LionSource` | The COBOL converted for AMT (`Invoke-CobolConversion.ps1`, `CobolConverterConsole`): 0 errors, 4 warnings |

## What the cards do

| Card | Effect in the generated COBOL |
|---|---|
| `INPUT INB,500,10` | `SELECT TAPEIN ASSIGN TO DISC INB`; input record `RECIN PIC X(500)` |
| `OUTPUT INC,135,10` | `SELECT TAPEOUT ASSIGN TO DISC INC`; output record `RECOUT PIC X(135)` |
| `FIELDIN 6,9 19,6 ...` | 10 input fields, each (start, length) |
| `FIELDOUT 11,9 20,6 ...` | where each field lands in the output; one `MOVE ZONEn TO ZONOn` per field |
| `FIXE 1,10,TAX-CLASIQ` | the constant `TAX-CLASIQ` (`PIC X(10)`) is moved into the output record |
| `ASCII` | selects the ASCII COBOL variant |

The runstream's `@ASG` / `@USE` lines then bind the names `INB` and `INC` to real files. That is why the
card names must match the file assignments. See `docs\SSG-4-Report-Execution-Model.md`.

## Deliberate changes to the cards

The exported cards are **not a verbatim copy** of the runstream. SSG accepts card forms that AMT's runtime
parser (`AddTo-SgsList`) reads differently, because it only splits on spaces and commas. So the export applies
SSG's own rules first, **so that AMT sees the cards SSG would have seen**. **These changes are intentional and
positive; if you see a card that differs from the runstream, this is why, not an accident.** The cards in
this example need none of them (`expected\1-cards\sgs-warnings.csv` is empty).

| Rule (SSG manual `78311784-010` s3.1.1) | Example | What AMT gets | Code in `sgs-warnings.csv` |
|---|---|---|---|
| A trailing ` ;` or `,;` continues the card on the next line; text after the `;` is ignored | `LABEL1 This SGS will be continued ;` + `to the next line` | one joined card | `SGS-CONTINUED` |
| A last card that ends ` ;` is ignored by SSG | `LABEL4 last card ;` before `@EOF` | card dropped | `SGS-LAST-CONTINUED-DROPPED` |
| An unquoted period ends the scan of the card; the rest is a comment | `INDIC 5,3 8,3 1,4  .TOTAUX PAR BRANCHE` | `INDIC 5,3 8,3 1,4` | `SGS-PERIOD-CUT` |
| Spaces after a comma are ignored | `LABEL5 Leading,   spaces` | `LABEL5 Leading,spaces` | `SGS-SPACE-AFTER-COMMA-REMOVED` |
| A subfield in pairs of single quotes loses the quotes; one in single quotes keeps them | `''0000''` and `'POLICE'` | `0000` and `'POLICE'` | `SGS-DOUBLE-QUOTE-STRIPPED` |

**Cannot be fixed in the card.** A quoted subfield containing a space or comma, for example
`'MULTIPLES COUCHE HIST 31/12'` or `''  ''` (blanks), cannot be written so that `AddTo-SgsList` keeps it in one
piece. The card is left as it is and reported as a **Warning** (`SGS-QUOTED-SPECIAL`): AMT will split it into
several fields. It needs a fix in AMT's parser (R&D list, MT-033 item 12). Cards read from a separate SGS file
(`SGS-EXTERNAL`) are not exported at all.

Over the 371 `@SSG` calls in the 170 runstreams: 36 calls had continuations joined, 7 cards were cut at a period,
2 cards had quote pairs dropped, 24 cards hold a quoted subfield AMT will split, and 11 calls name an external
SGS file. `Test-SgsCardRules.ps1` (in the parent
folder) checks every rule against the manual's own examples and real cards.

## Where the warnings show

- **At conversion time:** yes. The export step lists every change and warning in `sgs-warnings.csv` (and
  the code per call in `sgs-calls.csv`, column `CardNotes`); the expansion step prints a warning for each
  card AMT cannot represent.
- **At run time in AMT: no, not yet.** When the job runs, `Invoke-Ssg` loads the SGS file silently, so the
  job log carries nothing about these changes. A tester examining a run must look up that runstream and
  call in `sgs-warnings.csv`. Writing them to the job log at run time is logged as **MT-034**; it needs
  either a log line in AMT's `Invoke-Ssg` (R&D) or a line inserted by our conversion before each `Invoke-Ssg`
  call.

## What this example does not do yet

- **It does not run the program.** There is no C# for this program and nowhere to run it yet (LionDev
  repository and a Control Center application are not available; MT-009). So there is no mock input file
  and no expected output file here. They need an independent reference implementation of the copy, which
  is the next piece of the two-mock-set test.
- **The output goes as far as `.LionSource`.**
- **The input is real client data** (file names, one label, field positions). If this repo is ever shared
  beyond the project, replace the excerpt with synthetic cards and run `-Update`.
