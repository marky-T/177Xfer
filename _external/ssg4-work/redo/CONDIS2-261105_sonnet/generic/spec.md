# CONDIS2 — behaviour spec (SSG-4 generic program, step G2, 2026-11-05)

Source: `SsgConverter/Examples/Input/CONDIS2_ASCII.TXT` (skeleton `*UTILIT.CONDIS2/ASCII`, read-only; line numbers below are
that file's). Real calls: 18 (`sgs-calls.csv`, ProgramKey `CONDIS2_ASCII`), expansions in `percall/allcalls/CONDIS2_ASCII__*.cob`
(17 of 18 expand; PAIJ01_UL_L85 fails in the shared SGS code, T3-028). Shapes: `check/Classify-CondisCalls.ps1` → `evidence/shapes.md` (G1).
Program name `ASSURFED-UTILIT-CONDIS2-GN`, Xqt name `CONDIS2`, include `CondisParm`, parameter file `CNDPARM`.

CONDIS2 is a *conditional field copy*: it reads fixed-length records from FILEIN and writes one output record of fixed length to
FILEOUT per input record. Which output layout a record gets is chosen by `PG CASE` cards (a condition on bytes of the input record);
the output is built from `PG MOVE` cards (copy of an input field to an output position, optionally converting a date between two
representations of the year) and `PG CONST` cards (a literal placed at an output position). It counts the records per condition and
prints a report. Two year representations exist: plain digits (`19xx`) and a letter/symbol in place of the decade digit (`;`=200x,
`_`=201x, `|`=202x, `~`=203x), see "Date codes".

## Cards and SGS parameters

| Card / token | Meaning | Derived (`*SET`) | Value |
|---|---|---|---|
| `ASCII` | selects `#ACOB,IE` (line 99) vs `#ACOB,ITE` (101); no effect on the program text | – | – |
| `FILEIN rl,blk` | `[FILEIN,1,1,1]` input record length in bytes, `[FILEIN,1,1,2]` block (records) | `FD FILEIN … PIC X(rl)`, `ENR-INPUT` | rl 80..500 in real calls; block 10 everywhere (ignored by AMT) |
| `FILEOUT rl,blk` | `[FILEOUT,1,1,1]` output record length, `[FILEOUT,1,1,2]` block | `FD FILEOUT … PIC X(rl)`, `ENR-OUTPUT` | rl 100..500 |
| `PG CASE p,l,v …` | condition: input bytes `p`..`p+l-1` equal the literal `v`; several fields = AND | `CASE-n-k PIC X(l)`; `IF CASE-n-k = 'v'` | `[PG,I,J,1]`=p `[PG,I,J,2]`=l `[PG,I,J,3]`=v |
| `PG OTHERWISE` | the rest of the records (all conditions failed) | `NB-REC-OTHER` | no fields |
| `PG MOVE ip,il,op[,code] …` | copy input `ip..ip+il-1` to output `op`; optional date code in sub-field 4 | `MOVEIN-n-k`, `MOVEOUT-n-k` | `[PG,I,J,1..4]` |
| `PG CONST op,l,v …` | literal `v` (truncated/padded to `l`) to output `op..op+l-1` | `CONST-n-k PIC X(l)` | `[PG,I,J,1..3]` |

`n` = the running number of the condition group (`*NOCASE`: CASE and OTHERWISE cards count, MOVE/CONST cards belong to the last
one), `k` = field number within the card (`J-1`). `PG,I` = number of fields on card I including the type word (loops run J = 2..`PG,I`).
Values: unquoted token, or `''…''` (method 2, quotes removed) when it holds spaces (6 values of PAIJ01_UL_L85: `''  ''`, `''     ''`).

## Calls by shape (G1)

| Calls | Shape | Example call |
|---|---|---|
| 12 | A — no CASE, no OTHERWISE: one MOVE card (3..14 fields, 1–7 date fields) [+ one CONST card] | AUMH01_D3_L87 (408→400, 9 fields, 4×D42); PAIJ01_BD_L58 (MOVE + `CONST 9,1,0`) |
| 1 | C — 4 CASE (multi-field conditions, quoted-space values) + OTHERWISE, D42 | PAIJ01_UL_L85 (expansion fails) |
| 1 | C — 34 CASE (1 byte each, incl. `è é { } ! ?`) + OTHERWISE, MOVE + CONST per condition | VIRJ01_UE_L850 |
| 4 | C — 1 CASE (`214,2,01`) + OTHERWISE, plain moves | -d_VIGD03_L894 (also L1030, VIGD13 L899, L1035) |

Date codes in real calls: D24 (12 fields), D42 (40), D68 (13). D22A, D22B, D66A, D66B, D86: skeleton only. `evidence/shapes.md`
("Card-set checks") scans all 18 calls: **none violates a skeleton check (V1–V7), none has OTHERWISE before a CASE (0 of 6 calls with OTHERWISE),
a CASE after OTHERWISE, a MOVE/CONST card before the first CASE, or fields on an OTHERWISE card.** Every OTHERWISE call has its OTHERWISE as the last PG card.

## Record layouts (per `*IF` branch)

Input (`ENR-INPUT`, rl bytes): for each CASE card the field k is at `p..p+l-1` (`FILLER p-1`, `CASE-n-k`, `FILLER rl-p-l+1`); for each
MOVE field the input field is at `ip..ip+il-1`. Output (`ENR-OUTPUT`, rl bytes, **cleared to spaces for every record**, lines 450 ff.):

| Condition (card `[PG,I,J,4]`, `[PG,I,J,2]` = il) | Input width | Output width | Lines |
|---|---|---|---|
| no code | il | il | 312, 376–377 |
| D42 and il = 4 | 4 | 2 | 277–278 (in), 346–348 (out) |
| D24 and il = 2 | 2 | 4 | |
| D22A / D22B and il = 2 | 2 | 2 | |
| D66A / D66B and il = 6 | 6 | 6 | |
| D68 and il = 6 | 6 | 8 | |
| D86 and il = 8 | 8 | 6 | |
| any other code, or the right code with a wrong il | **error** (FLAGABORT=1): the skeleton displays "CONTRADICTION ENTRE LA LONGUEUR D'UNE ZONE ET SA DECLARATION EN DATE" | | 294–311 (in), 363–377 (out) |
| CONST field | – | l (value truncated or space padded to l) | 408–417 |

Output field positions: MOVE `op` = `[PG,I,J,3]`, CONST `op` = `[PG,I,J,1]`. A field that does not fit its record (`p+l-1 > rl`, `ip+il-1 > in rl`,
`op+width-1 > out rl`, or a position < 1) leaves no trailing `FILLER` (`If [*L2]>0`) and the field extends past `ENR-INPUT`/`ENR-OUTPUT`: the skeleton
makes no check; no real call does this (`evidence/fit-check.txt`: 18 calls, 0 fields outside their record). The generic program works on 4000-byte areas, so it reads spaces / cuts at the
record length and does not stop (UNKNOWN beyond that; not modelled).

### Checks of the card set (the skeleton's lines 4–96; each error sets FLAGABORT and `@ABORT` follows `#MAP`, lines 908–911)

Scan of the PG cards in order with counters `NOCASE, NOOTHER, NOMOVE, NOCONST`:

| Card | Error when |
|---|---|
| CASE (nth) | n ≠ 1 and no MOVE and no CONST card since the previous condition (V1); otherwise `NOMOVE=NOCONST=0` |
| OTHERWISE | `[*CASE]=0` (V8: `*CASE` is never set; see claims); more than one OTHERWISE (V2); no MOVE and no CONST card since the previous condition (V3); then `NOMOVE=NOCONST=0` |
| MOVE | more than one MOVE since the previous condition (V4) |
| CONST | more than one CONST since the previous condition (V5) |
| anything else | (V6) |
| (every MOVE field) | date code / width contradiction (V7, table above) |

The hand-off reproduces V1–V7 (the source's own checks: `Abort` naming the card, before the Xqt, as `@ABORT` does). It does **not** reproduce V8 and adds
no check the source does not make (gate decision G2): OTHERWISE before any CASE, CASE after OTHERWISE, fields on an OTHERWISE card, MOVE/CONST before the first
CASE, a field outside its record, a value containing `'`, no PG card at all: all run as the generated text would (Behaviour, step 3). Only the generic
program's own limits reject: positions and lengths > 4000, CASE/CONST length or value > 200, more than 200 CASE/OTHERWISE cards or 2000 items (what
does not fit the program's tables).
## Behaviour (byte level)

1. Open FILEIN (input), FILEOUT (output). Set all counters to 0 (`NB-REC-LU, -ECRIT, -NONECRIT, -OTHER, NB-REC-CASE-n`, the 16
   `NB-REC-TRANSFORME-*`).
2. Loop: read a record into `ENR-INPUT`; at end of file go to step 6. `MOVE SPACES TO ENR-OUTPUT` (line 455); set the 16 flags
   `WS-RECORD-TRANSFORME-*` to `N`; `NB-REC-LU` + 1.
3. Run the record through the **item list** the skeleton generates for the call (lines 453–562). The items, in card order (`n` = running number
   `*NOCASE`, counting CASE and OTHERWISE cards):
   - PG CASE: `n` + 1; if `n` ≠ 1 first a **TAIL(n−1)**; then one **condition** per field: `IF CASE-n-k = '<value>'` (nested, no period).
   - PG OTHERWISE: `n` + 1; the source tests `If NOCASE <> 1` with the bare word `NOCASE` (line 497): **taken as written, always true**, so a
     **TAIL(n−1)** always comes first; no condition (a field on the card is ignored).
   - PG MOVE / PG CONST: one **action** (4.) per field, in card order.
   - After the last card (lines 553–562): if the call has no OTHERWISE card (`*NOOTHER` = 0) a **TAIL(n)**, otherwise a **TAIL-OTHER**; then CASE-NON-PREVU.
   - **TAIL(k)** = `ADD 1 TO NB-REC-CASE-k`, write (5.), next record. **TAIL-OTHER** = `ADD 1 TO NB-REC-OTHER`, write, next record. A TAIL ends with a period:
     it also ends every open `IF`.
   Execution of the list for one record, with a flag *active* = true: a condition is evaluated only while active (alphanumeric compare of the input bytes with
   the literal, the shorter padded with spaces); if it is false, *active* becomes false. An action is performed only while active. A TAIL while active runs and
   ends the record; a TAIL while not active only makes *active* true again (the period). After the last item (no TAIL ran): nothing is written (CASE-NON-PREVU, line 562).
   This reproduces the usual shapes: no CASE → one unconditional TAIL(0); `CASE… MOVE… CASE… MOVE… OTHERWISE MOVE` → each CASE group tested in turn, the OTHERWISE
   actions for the rest; and also the odd ones (OTHERWISE first, CASE after OTHERWISE, MOVE before the first CASE), as written, none of which a real call has.
4. Perform a field, in card order (a later field overwrites an earlier one where output ranges overlap):
   - MOVE without code: output bytes `op..op+il-1` := input bytes `ip..ip+il-1`.
   - MOVE with code: take input bytes `ip..ip+il-1` as the date value, convert (Date codes), store the result (width in the table) at `op`.
   - CONST: output bytes `op..op+l-1` := value, truncated or space padded to `l`.
5. Write: `NB-REC-ECRIT` + 1; for each of the 16 flags that is `Y`: its counter + 1 (**once per record**, however many date fields of that code the
   record has); write `ENR-OUTPUT` (rl bytes).
6. At end: print the report, close both files, stop.

### Date codes (paragraphs lines 633–862). `A2`, `A4`, `A6`, `A8` are working fields of 2/4/6/8 bytes; every comparison is alphanumeric (bytewise).

| Code | Conversion |
|---|---|
| D42 | `A4`=input; `A2`=`A4`(3..4); if `'1999' < A4 < '2010'` `A2(1)`=`;` ; if `'2009' < A4 < '2020'` `_` ; if `'2019' < A4 < '2030'` `|` ; if `'2029' < A4 < '2040'` `~` ; output `A2` |
| D24 | `A2`=input; `00` → `0000`; two spaces → four spaces; `A2(1)`=`;`→`200`+`A2(2)`, `_`→`201`+, `|`→`202`+, `~`→`203`+; otherwise `19`+`A2` |
| D22A | `A2`=input; `A2(1)` = `0`→`;`, `1`→`_`, `2`→`|`, `3`→`~` with flag `22A-20nX`=Y (n = 0,1,2,3 for the old digit); other digits: unchanged, no flag |
| D22B | `A2`=input; `A2(1)` = `;`→`0`, `_`→`1`, `|`→`2`, `~`→`3` with flag `22B-20nX`=Y; otherwise unchanged |
| D66A | `A6`=input; unchanged (exit) if not all 6 bytes are digits, or `MM`=`A6(3..4)` > `15` or = `00`, or `JJ`=`A6(5..6)` > `35` or = `00`; else `A6(1)` = `0`→`;`, `1`→`_`, `2`→`|`, `3`→`~` with flag `66A-20nX`; digits 4–9 unchanged |
| D66B | `A6`=input; `A6(1)` = `;`→`0`, `_`→`1`, `|`→`2`, `~`→`3` with flag `66B-20nX`; no numeric/month/day check |
| D68 | `A8`=`19`+`A6`(input); six spaces → eight spaces; `000000` → `00000000`; `A6(1)`=`;`→`200`+`A6(2..6)`, `_`→`201`+, `|`→`202`+, `~`→`203`+; otherwise `19`+`A6` |
| D86 | `A6`=`A8(3..8)` (input `A8`); then unless `A8` is not all digits, or `A8(5..6)` > `15`/`00`, or `A8(7..8)` > `35`/`00`: `A8(1..3)`=`200`→`;`+`A8(4..8)`, `201`→`_`+, `202`→`|`+, `203`→`~`+; (`A8(1..2)`=`19` and every other value: `A6` stays `A8(3..8)`); output `A6` |

Note: for D22A/D22B/D66A/D66B the `n` of the flag is the old (D22A, D66A) or new (D22B, D66B) first character mapped to 0..3, i.e. the four counters of
each code count the records that had a decade 0,1,2,3 (the `20nX` counters of the report lines).

### Records written

| Record | Bytes | Written to |
|---|---|---|
| one per input record matched by a group | FILEOUT rl (80..500 in real calls; generic limit 4000) | FILEOUT |

### Printer report (`DISPLAY … UPON PRINTER` → job log in AMT, lines 566–628)

Counters are `PIC 9(6)` displayed as 6 digits (zero filled); `n` in `CONDITION NO n` is the ordinal of the CASE card among the CASE cards (no zero fill).
Literal text is exact, including the doubled spaces:

```
NB ENREGISTREMENTS LUS    = 000000
NB ENREGISTREMENTS ECRITS = 000000
```
then, **only when LU − ECRIT > 0** (`NB-REC-NONECRIT`): seven lines
```
*******************************
*   attention                 *
*   certains records ne       *
*   respectent aucun case     *
*   et ne figurent donc pas   *
*   sur le fichier output     *
*******************************
```
then one line per CASE card in card order, `NB ENREGISTREMENTS CONDITION NO <n> = <count>`, then
```
NB ENREGISTREMENTS OTHER = <count>
 
 
 
 
```
(four lines with one space), then 16 lines `NB RECORDS AYANT SUBI TRANSFO (<code>) <old> --> <new>    = <count>`:
`22A`: `0X --> ;X`, `1X --> _X`, `2X --> |X`, `3X --> ~X`; `22B`: `;X --> 0X`, `_X --> 1X`, `|X --> 2X`, `~X --> 3X`; `66A`: as 22A; `66B`: as 22B
(exact texts: lines 596–628 of the skeleton; the generic program uses the same literals).

## Generic program (G4)

The program runs the **item list** of Behaviour step 3: the hand-off (not the program) does what the skeleton's `*SET`/`*IF` did at generation time
(numbering `n`, the TAIL counters, `*NOOTHER`), and writes one parameter record per item.

- `SGSPARM` (record length 250), one record per item, in the order of the list:

| Type (cols 1–2) | Fields |
|---|---|
| `RL` | 3–7 input record length, 8–12 output record length, 13–17 number of CASE cards (the report prints that many `CONDITION NO` lines) — 9(5) each; first record |
| `CD` | 3–7 position, 8–12 length (9(5)), 13–212 value (X(200), space padded): condition `IF CASE-n-k = 'value'` |
| `MV` | 3–7 input position, 8–12 input length, 13–17 output position (9(5)), 18–21 code (`D24 `, `D42 `, `D22A`, `D22B`, `D66A`, `D66B`, `D68 `, `D86 `; blank = plain move) |
| `KT` | 3–7 output position, 8–12 length, 13–212 value (X(200)): CONST field |
| `TL` | col 3 kind (`C` = `NB-REC-CASE-k`, `O` = `NB-REC-OTHER`), 4–8 k (9(5)): TAIL |

- Fixed file names: `CNDIN` (the call's `FILEIN`), `CNDOUT` (the call's `FILEOUT`); the hand-off maps them with `Use`; output record size from the hand-off
  (`RecSize` = `[FILEOUT,1,1,1]`). Runstream evidence: every call has `@USE FILEIN,<file>` and `@USE FILEOUT,<file>` before the `@SSG`, then `@XQT TPF$.CONDIS2`.
- Limits: record lengths, positions and lengths ≤ 4000; CASE/CONST length and value ≤ 200; ≤ 200 CASE/OTHERWISE cards (counters 0..200); ≤ 2000 items; counters 9(6).

## Run-day bytes (masked in every comparison)

- None: neither the records nor the report contain the run date or time.

## Claims and evidence

| Claim | Class | Source |
|---|---|---|
| Item list, layouts, literals, report text (above) | OBSERVED_IN_FEDERALE_SOURCE | `CONDIS2_ASCII.TXT` lines 4–911; the expansions of the 17 calls that expand have exactly the statements of the item list (checked on VIGD03_L894, PAIJ01_BD_L58, VIRJ01_UE_L850) |
| Date conversions D24/D42/D68 on real data; all 8 codes in the skeleton | OBSERVED_IN_FEDERALE_SOURCE | lines 633–862 (paragraphs) |
| A TAIL counts into `NB-REC-CASE-(n−1)` or `-n`; the final TAIL into `NB-REC-OTHER` when an OTHERWISE card exists | OBSERVED_IN_FEDERALE_SOURCE | lines 484–488, 497–502, 553–560; expansions VIGD03_L894 (`CASE-1`, `OTHER`), VIRJ01 |
| Call's names are the use names `FILEIN` / `FILEOUT` (`@USE FILEIN,…`, `@USE FILEOUT,…`), the Xqt is `TPF$.CONDIS2` | OBSERVED_IN_FEDERALE_SOURCE | all 18 runstreams (`01-RunsPrd`, lines before/after the `@SSG`); skeleton `SELECT FILEIN ASSIGN TO DISC FILEIN` (lines 144–145) |
| Value `''  ''` = literal of two spaces (method 2 quoting) | DERIVED_WORKING_MODEL | SSG card rules as implemented in the shared `GnHandoff.ps1` splitter; the 6 values of PAIJ01_UL_L85 are never expanded by AMT's SGS code |
| Alphanumeric compare uses bytewise ASCII order (D42 range tests); shorter side padded with spaces | DERIVED_WORKING_MODEL | AMT runs ASCII; the skeleton compares text with `>`/`<`/`=` |
| Token and date-code compare is case-insensitive (`d42` = `D42`, `case` = `CASE`) | DERIVED_WORKING_MODEL | AMT's `CompareTypeSafe` uses PowerShell `-eq`; OS 2200 behaviour not known (UNKNOWN 5) |
| `[*CASE]=0` test (V8, line 29) never blocks a real OTHERWISE call | UNRESOLVED_UNISYS_SEMANTIC | `*CASE` is never set (only `NOCASE`); what an unset SGS variable is on OS 2200 is not known. The 6 production calls with OTHERWISE (after CASE) ran, so the check did not block them. The generic program does not model V8 |
| AMT's `Invoke-Ssg` runs the converted skeleton under `Set-StrictMode -Version 2`: `CompareTypeSafe $CASE "EqualTo" 0` throws "variable `$CASE` not set" for any call with an OTHERWISE card (T3-056) | AMT_PLATFORM_ADAPTATION | per-call route only; the generic route returns before that line (hand-off first). A probe of the same module/script structure confirmed the throw; the real skeleton under the full library was not run |
| `If NOCASE <> 1` in the OTHERWISE branch (bare word, line 497) is true | OBSERVED_IN_FEDERALE_SOURCE (as written) | reproduced as written: an OTHERWISE card always starts with a TAIL(n−1). Note: the converter turns the bare word into the variable (`$NOCASE -ne 1`, converted lines 475/488), which differs only when OTHERWISE is the first card; no real call. Converter output is not the definition |
| Input record shorter than the declared length; longer than it | UNKNOWN | original: runtime-defined. Generic program: padded with spaces / cut to the declared length, as the other generic programs (test expectation labelled DERIVED_WORKING_MODEL) |
| More than 999 999 records (PIC 9(6) overflow) | UNKNOWN | not modelled; same as the skeleton |
| Collation of the D42 range tests on non-digit year bytes | UNKNOWN | ASCII bytewise assumed (test expectation labelled DERIVED_WORKING_MODEL) |
| Numeric counters shown as 6 zero-filled digits by AMT's DISPLAY | DERIVED_WORKING_MODEL | `PIC 9(6)` DISPLAY; to be confirmed in CC |
| A field outside its record; OTHERWISE before any CASE; CASE after OTHERWISE; MOVE/CONST before the first CASE; fields on an OTHERWISE card | UNKNOWN (storage layout of the skeleton's expansion) | no real call (shapes.md); the item list is run as written, no rejection |
| FILEIN/FILEOUT blocking (`[FILEIN,1,1,2]`) | AMT_PLATFORM_ADAPTATION | no meaning for AMT line-sequential files; ignored |

## Open UNKNOWNs

1. `[*CASE]` (V8): unset SGS variable on OS 2200 → UNRESOLVED_UNISYS_SEMANTIC; not modelled, no rejection.
2. Bare `NOCASE <> 1`: reproduced as written (always true); only OTHERWISE as the first card could tell, no real call.
3. Short/long input records vs the declared FILEIN length.
4. Counter overflow beyond 999 999.
5. Case-sensitivity of tokens and date codes on OS 2200 (AMT: insensitive).
6. Collation of `>`/`<` on non-digit year bytes (D42 only; ASCII assumed).
7. ~~Use names~~ resolved from the runstreams (see claims).

## Differences found (G7 / CC), classified

| Difference | Classification | Decision |
|---|---|---|
| PAIJ01_UL_L85 does not expand: quoted spaces (T3-028) in the shared SGS code | UNSUPPORTED_SOURCE_CONSTRUCT | no per-call reference; the writer reads the raw card file (shared `Read-GnSgsImages`). G7: NO-EXPANSION 1; its parameter items equal the reference model's item list (Model = MATCH), `evidence/crosscheck.csv` |
| `[*CASE]` test: AMT throws (T3-056), OS 2200 unknown | UNRESOLVED_UNISYS_SEMANTIC / AMT_PLATFORM_ADAPTATION | per-call route only; generic route unaffected; no check added |
| Stricter checks one could argue for (OTHERWISE before CASE, CASE after OTHERWISE, MOVE/CONST before CASE, fields on OTHERWISE, field outside record) | FEDERALE_SOURCE_AMBIGUITY | **kept out of the program and the hand-off**; `evidence/shapes.md` shows from the 18 calls that none is reached (0 of 18 each) |
| Converter turns bare `NOCASE` into `$NOCASE` | CONVERTER_DEFECT (candidate, not logged here) | generic program follows the source text; no real call is affected |
