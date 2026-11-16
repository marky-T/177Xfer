# Archive SSG utilities: called but missing (for Eddy, 2026-11-16)

Line numbers are in R&D's converted runstreams in the drop (`Federale_InternalRelease\Scripts\ASSURFED_F999\RUN\`).
The original runstreams (`ASSURFED_F999RUN_<name>(P).TXT`) are not in our source pack (`RunsPrd-INDEX.csv`:
InPack = N). Every block of 17 lines runs ARCHITAB2, then ARCHIFUSION two lines later, with the runstream's own
SGS file.

| Runstream | ARCHITAB2 calls | ARCHIFUSION calls | Missing program(s) and reference | Archive programs that may be missing | Expected to contain SSG? |
|---|---|---|---|---|---|
| `ASSURFED_F999RUN_ACPA04_D3.ps1` | 22, at lines 52, 69, 86 … 409 | 22, at lines 54, 71, 88 … 411 | **SSG source of `*UTILIT.ARCHITAB2` and `*UTILIT.ARCHIFUSION`** (only R&D's converted `UTILIT_ARCHITAB2.ps1` / `UTILIT_ARCHIFUSION.ps1` in the drop); **SGS card file `P$SGS.ACPA04`**; original runstream `ASSURFED_F999RUN_ACPA04_D3(P).TXT`. Tracker MT-067, MT-047; board story 120446 | **No caller found** for ARCHISEPARE, ARCHIFORMAT, ARCHITAB1 (builds ARCHITAB2's input) or ARCHIINSERT, although their skeletons are in our pack. These three runstreams are the only archive callers known | **Yes, both are SSG skeletons**, but neither generates COBOL. ARCHITAB2: SSG directives (14 SGS references) around ECL that assigns files and runs `FPB008` / `FPB009` (copied from `AFPRD*BABS`; in FEDERALE_APP as `Afprd_Bsrc_Fpb008/009.dll`). ARCHIFUSION: SSG directives (13 SGS references) around an ECL sort that merges three archive files into one for Archiware |
| `ASSURFED_F999RUN_AUPA06_D3.ps1` | 28, at lines 52, 69, 86 … 511 | 28, at lines 54, 71, 88 … 513 | As above; SGS card file **`P$SGS.AUPA06`**; original runstream `ASSURFED_F999RUN_AUPA06_D3(P).TXT` | As above | As above |
| `ASSURFED_F999RUN_INPA01_D3.ps1` | 10, at lines 52, 69, 86 … 205 | 10, at lines 54, 71, 88 … 207 | As above; SGS card file **`P$SGS.INPA01`**; original runstream `ASSURFED_F999RUN_INPA01_D3(P).TXT` | As above | As above |

Totals: 60 ARCHITAB2 calls, 60 ARCHIFUSION calls.

Probable archive chain (DERIVED from the skeletons' own comments, not observed in a runstream):
ARCHISEPARE (separate records to archive) → ARCHIFORMAT (format for archiving) → ARCHITAB1 (builds the file for
ARCHITAB2) → ARCHITAB2 (runs FPB008 / FPB009) → ARCHIFUSION (merge for Archiware).

## Are they still part of the current process? (checked 2026-11-16)

They are missing from **our SSG-4 source pack**, not from Federale's current conversion. The new drop installed on
this VM (`Federale_InternalRelease` `main` `d4da9d0d80`, 2026-11-11) contains the whole chain, converted by R&D:

| Item | In the current drop (11 Nov) | Source we have seen |
|---|---|---|
| Caller runstreams `ACPA04_D3`, `AUPA06_D3`, `INPA01_D3` | Yes, converted `.ps1` in `Scripts\ASSURFED_F999\RUN\` | `Codedrop 2025\RunsPrd` (listed in our index, not copied: they call none of our 20 skeletons) |
| Skeletons `ARCHITAB2`, `ARCHIFUSION` | Yes, converted: `Scripts\ASSURFED_UTILIT\UTILIT_ARCHITAB2.ps1`, `UTILIT_ARCHIFUSION.ps1` | `Code_Source_20260804\…\RunPrd\ASSURFED_UTILIT\` (878 B and 2,489 B; recorded in our plan of 12 Oct, "parked until we hit it"); not on this VM |
| Programs `FPB002`–`FPB009` (archiving, e.g. FPB009 "Archivage – création/maj des records 0,1,2,3,9 Archiware") | Yes, compiled in FEDERALE_APP: `AFBUS_AMT\Binaries\Programs\Afprd_Bsrc_Fpb002.dll` … `Fpb009.dll` (no `Fpb001.dll`) | `Code_Source_20260804\…\AFPRD_BSRC_FPB001`–`FPB009.TXT` (COBOL) |
| Other callers of the FPB programs | Yes: 11 `RUN-D` runstreams `ASSURFED_F999RUN-D_FPGD01_D1`–`D6`, `_PR`, `FPGD02_D1`–`D4` | `Code_Source_20260804\…\RunPrd\ASSURFED_F999\RUN-D\` |
| SGS cards for the 120 archive calls (`-SgsFile "P$SGS\ACPA04"` / `AUPA06` / `INPA01`) | No: the drop has no `P$SGS` folder at all (T3-020) | Not seen: the original `_D3` runstreams are not in our pack |

So R&D has carried the archive chain into the current conversion; nothing here suggests it was retired. What we
lack is only the **SSG source** for our route, and the SGS card files.

Questions for Eddy:
1. Is the archive chain (`*_D3` runstreams → ARCHITAB2 → FPB008/FPB009 → ARCHIFUSION, and the `RUN-D` FPGD runs)
   still run in production, and how often?
2. Should ARCHITAB2 and ARCHIFUSION go through our SSG-4 route? They generate ECL only (no COBOL), so they may need
   no generic program at all, just a checked conversion.
3. **The SGS cards for the archive calls.** Can we have the original runstreams `ASSURFED_F999RUN_ACPA04_D3(P).TXT`,
   `AUPA06_D3(P).TXT` and `INPA01_D3(P).TXT`, and, if the cards are not in them, the file they come from?
   - **What an SGS card is:** the parameter lines an SSG skeleton reads to decide what to generate (e.g. `INPUT FA,536,10`,
     `KEYS ALL 6,15`). Each of the 120 archive calls passes its own cards; without them ARCHITAB2 and ARCHIFUSION
     generate nothing meaningful, and we cannot test a conversion against real calls.
   - **Where they normally are:** inline in the runstream, between the `@SSG` line and `@EOF`. Example from the
     sibling run `ASSURFED_F999RUN_ACPA04_D2(P).TXT` (in our pack), lines 472–479:
     `@SSG,IA *UTILIT.BABA/ASCII` / `SGS` / `ASCII` / `INPUT FA,536,10` / `OUTPUT FB,536,10` / `KEYS ALL 6,15` /
     `SEQERROR MULTI` / `@EOF`.
   - **Why we can't see them:** R&D's ECL converter replaces each call with
     `Invoke-Ssg … -SgsFile "P$SGS\ACPA04"` (likewise `AUPA06`, `INPA01`) but never writes the cards into that file
     (our T3-020). The drop has **no `P$SGS` folder at all** (none of the 100+ `P$SGS\<run>` files it refers to, nor the
     global `P$SGS\_ALL_` the runtime reads at start-up); `Invoke-Ssg` logs "SGS file not found … continuing without"
     and runs the skeleton with no cards. For our other utilities we took the cards from the original runstream
     text; for these three we do not have that text.
   - **Inline or a separate file?** On OS 2200 the second field of the `@SSG` line (param-2) names a file or element that
     holds the SGS cards; if it is empty, the cards follow inline up to `@EOF` (SSG manual 78311784-010, §2.1–2.2). The
     options (`IA` in D2, `MN` in D3) only control listing and headings (`I` list SGSs as read, `M` no sign-on lines,
     `N` no headings), so they do not tell us which. The converter writes `-SgsFile "P$SGS\<run>"` in both cases, even
     for D2, whose cards are inline. The original D3 text will show which: inline cards, or a named SGS file/element
     (then we need that file too).
   - **Not the same as our `P$SGS` folder:** on this VM `AmtTools\Basepaths\Extracts\P$SGS\` exists, but it holds only
     our own test cards for Control Center runs (`CN2…` CONDIS2, `LEC…` LECTIS, `ARC…` archive tests, `LDC…`, `BABA…`,
     …), written by our pipeline; no `ACPA04`, `AUPA06` or `INPA01`.
4. Do ARCHISEPARE / ARCHIFORMAT / ARCHITAB1 / ARCHIINSERT feed this chain, and from which runstream?
## Step by step: one ARCHITAB2 call, compared with a COBOL skeleton on our SSG-4 route

Columns 1–2: an ARCHITAB2 call (ACPA04_D3, first block). Column 3, for comparison: a skeleton that generates
**COBOL**, BABA, from the sibling run ACPA04_D2 (original lines 472–480, which we have; converted line 541), on our
SSG-4 route.

| # | OS 2200 (original), ARCHITAB2 | AMT, current drop, ARCHITAB2 | Our SSG-4 route, COBOL skeleton (BABA in ACPA04_D2) |
|---|---|---|---|
| 1 | The scheduler starts runstream `ACPA04_D3` (ECL). | Control Center starts `ASSURFED_F999RUN_ACPA04_D3.ps1`. | Control Center starts `ASSURFED_F999RUN_ACPA04_D2.ps1`. |
| 2 | The runstream reaches `@SSG,MN *UTILIT.ARCHITAB2 …` (in the original runstream; text not seen). | Line 52: `Invoke-Ssg -Options "MN" -Skeleton "…/UTILIT_ARCHITAB2" -SgsFile "P$SGS\ACPA04"`. | 2200 line 472 `@SSG,IA *UTILIT.BABA/ASCII` → converted line 541 `Invoke-Ssg -Options "IA" -Skeleton "…/UTILIT_BABA_ASCII" -SgsFile "P$SGS\ACPA04"`. |
| 3 | SSG reads the **SGS cards** for this call: from a file named on the `@SSG` line, or inline up to `@EOF`. They say which files to archive, with which names and sizes. | `Invoke-Ssg` looks for `P$SGS\ACPA04`. **It is not there**, so it logs "SGS file not found … continuing without" and carries on **with no cards**. | Cards inline at lines 473–478: `ASCII`, `INPUT FA,536,10`, `OUTPUT FB,536,10`, `KEYS ALL 6,15`, `SEQERROR MULTI`. The converter drops them (T3-020); **our pipeline exports them** from the original text (`Export-SgsCards.ps1`) into a card file that `Invoke-Ssg` loads, so the cards **are** present. |
| 4 | SSG reads the **skeleton** `*UTILIT.ARCHITAB2`: text lines plus directives (`*IF`, `*SET`, `*INCREMENT`, `[label,field]`). | Runs `UTILIT_ARCHITAB2.ps1`, R&D's PowerShell conversion of that skeleton. | Runs our checked copy of the converted skeleton `UTILIT_BABA_ASCII.ps1`, deployed with our **hand-off** call (`Invoke-BabaHandoff`) at its top. |
| 5 | SSG **expands** the skeleton against the cards. ARCHITAB2's result is ECL: `@ASG`, `@USE`, `@XQT MODARC.FPB008`. | Same references, but **no card values**. Expected (not run by us): loops do nothing and file names come out blank, or the script stops on a missing value. | On 2200, BABA's expansion is a **COBOL program** built for this call (record sizes, keys, …) plus compile lines (`#ACOB`, `#MAP … TPF$.BABA`). On our route the hand-off instead writes the cards into a **parameter file** (`BABPARM`, used as `SGSPARM`) and maps the call's files (`FA`, `FB`) onto the program's fixed names (`BABIN`, `BABOUT1`). |
| 6 | The generated ECL **runs**: assigns the files and runs `FPB008` / `FPB009`. | The script runs the ECL steps directly (`Asg`, `Use`, `Xqt "MODARC.FPB008"`) → `Afprd_Bsrc_Fpb008.dll` / `Fpb009.dll` in FEDERALE_APP, with wrong or no file assignments (expected, not run). | On 2200, the generated program is compiled to `TPF$.BABA`, then line 480 `@XQT TPF$.BABA` runs it. On our route **nothing is compiled**: line 542 `Xqt "TPF$.BABA"` runs our **precompiled generic program `BABA_GN`** (Control Center's `CloneReports` maps the name), which reads `SGSPARM` and behaves as that call's generated program would. |
| 7 | Two lines later, `@SSG … *UTILIT.ARCHIFUSION` with the same cards: its ECL sort merges three archive files into one for Archiware. | Line 54: same with `UTILIT_ARCHIFUSION`; same missing cards. | Output file `FB` (`IACB082EG14D`), compared with an independent model in our Control Center regression (BABA proven, job 696). |
| 8 | The runstream moves to the next label and repeats for the next file (22 times in ACPA04_D3). | Same, 22 times. | Next call, own cards, **same program**: BABA has 122 calls, one generic program. |

What this shows: ARCHITAB2 and ARCHIFUSION generate **ECL**, not COBOL, so they would not need a generic program,
but they need their cards just as much as BABA does. Without the original `_D3` runstream text we cannot supply them.

Not archive, same kind of gap: `ASSURFED_F999RUN_VIRA05(P).TXT` line 55 calls `@SSG,IA SYS$*RUNS.FILE/SSG`
(a system library skeleton, not in our pack; cards `FILE FKTPPRJASC`, `JUMP LAB030`, apparently a
file-exists check).

## Short questions (with the answer we expect)

| # | Question | Expected answer |
|---|---|---|
| 1 | Is the archive chain still run in production? | Yes. R&D converted the whole chain into the 11 Nov drop. |
| 2 | How often does it run? | Periodically (monthly or yearly), not daily. |
| 3 | What is Archiware? | An external archiving product or archive store the files are prepared for. |
| 4 | Does Archiware exist in the target setup? | Unknown. If not, what replaces it decides whether the chain is needed. |
| 5 | Can we have the original runstreams `ACPA04_D3`, `AUPA06_D3`, `INPA01_D3`? | Yes, from the full `RunsPrd` source pack. |
| 6 | Are the SGS cards inline after `@SSG`, or in a separate file? | Inline, like the `_D2` runs. |
| 7 | If a separate file, can we have it? | Yes, from the same drop. |
| 8 | Can we have the SSG source of ARCHITAB2 and ARCHIFUSION? | Yes, from `Code_Source_20260804\…\ASSURFED_UTILIT\`. |
| 9 | Which runstreams call ARCHISEPARE, ARCHIFORMAT, ARCHITAB1, ARCHIINSERT? | None in the current pack; possibly a separate or retired archive run. |
| 10 | Does ARCHISEPARE/ARCHIFORMAT/ARCHITAB1 feed ARCHITAB2? | Yes; ARCHITAB1's own header says it builds the file "pour architab2". |
| 11 | Are FPB008/FPB009 the only programs the chain runs? | Yes for ARCHITAB2; FPB002–FPB007 serve the `RUN-D` FPGD runs. |
| 12 | Should ARCHITAB2/ARCHIFUSION come onto our SSG-4 route? | Yes, but only as a checked conversion: they generate ECL, so no generic program is needed. |
| 13 | Who owns this decision: us, R&D or Federale? | Federale (business need), with the Migration Lead. |

## Background to question 6 (inline cards or a separate file?)

- **Two ways to give SSG its cards** (SSG manual 78311784-010 §2.1–2.2):
  (a) **inline**: an `SGS` line after `@SSG`, then the cards, then `@EOF`;
  (b) **a named source**: a file or element as the 2nd field of the `@SSG` line (param-2), or after the word `SGS`.
- **What our pack shows** (372 `@SSG` calls in 170 runstreams): **361 inline** (342 with options `IA`); **11 named**
  on the `@SSG` line; **0** with a file after `SGS`. The 11 named files (e.g. `NBAFPH12`, `NBCYCLEV`) are **made
  earlier in the same run** (`@ASG`, then `@ED` or a program writes the cards into it). Example
  `ASSURFED_F999RUN_AFPH12(P).TXT` lines 60–67 create `NBAFPH12`; line 81 `@SSG,MNA ,NBAFPH12.` reads it.
- **So the expected answer is "inline"**, and if not, the file is probably built by the run itself, so the
  original runstream text answers the question either way. A standing library file of cards is unlikely.
- **Why we can't tell from the drop:** R&D's converter writes `-SgsFile "P$SGS\<run>"` for every call, whatever
  the original form, and keeps none of the cards (T3-020).
- **The `MN` options** on the `_D3` calls don't decide it: `I`/`M`/`N` only control listing and headings. The 11
  named-file calls do use `MN…` (e.g. `MNA`), which is a weak hint the `_D3` calls might be named-file calls too.
