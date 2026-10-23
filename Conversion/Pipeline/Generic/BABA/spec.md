# Generic BABA — behaviour spec (step 0, 2026-10-20)

Source: all 122 real BABA_ASCII calls, expanded with their own cards by `Conversion/Pipeline/Expand-AllCalls.ps1`
(AMT's SGS functions): `E:\Repos\ssg4-work\allcalls\expanded\BABA_ASCII__*.cob` (122/122 clean); skeleton logic read
from `SsgConverter/Examples/Output/BABA_ASCII.ps1`; card edge cases from `Scan-BabaCards.ps1`.

BABA reads one file and splits it into one or two outputs by a record key.

## Cards

| Card | Meaning |
|---|---|
| `INPUT name,len,blk` | the input (always 1 file in the real calls) |
| `OUTPUT name,len,blk [name,len,blk]` | 1 or 2 outputs, each with its own record length |
| `KEYS mode pos,len[,value] ...` | mode `R` (retain), `E` (exclude) or `ALL`; up to 8 key fields; no KEYS card = `ALL` |
| more `KEYS` cards | each card is one more alternative set of values (up to 19 seen); field layout = first card |
| `SEQERROR MULTI` (or `YES`/`OUI`/`YA`) | check the key is ascending; `MULTI` also routes duplicates |

## Calls by shape (122)

| Calls | Mode | Outputs | SEQERROR |
|---|---|---|---|
| 42 | R | 2 | – |
| 22 | none (copy) | 1 | – |
| 17 | ALL | 1 | MULTI |
| 13 | R | 2 | MULTI |
| 8 | E | 1 | – |
| 6 | none (copy) | 2 | – |
| 6 | R | 1 | – |
| 4 | E | 2 | – |
| 2 | ALL | 2 | MULTI |
| 1 | E | 1 | MULTI |
| 1 | – | – | – (DEPM01_L139: no INPUT/OUTPUT cards; nothing to run) |

## Behaviour (byte level)

1. Open the output(s), open the input. Empty input: go to 7.
2. For each record (the first one included), the **key** is the input bytes at each key field, concatenated in
   **card order** (`MOVE CORRESPONDING` uses the field names, not positions; 2 calls list fields out of position order).
3. Sequence check (only with `SEQERROR`), from the second record on: if key < previous key, display the
   sequence-error lines and abort the run (`CALL 'ABORT'`). With `MULTI`, a record whose key equals the previous key is
   a **duplicate**.
4. Route the record:
   - `MULTI`: first of its key → output 1; duplicate → output 2, or dropped with one output. The `R`/`E` value test is
     **never reached** with `MULTI` (the skeleton's GO TO comes first), so the values are ignored.
   - `ALL` or no `KEYS`: → output 1 (a second output stays empty).
   - `R`: key equals any value set → output 1; otherwise → output 2, or dropped.
   - `E`: key equals any value set → output 2, or dropped; otherwise → output 1.
5. Write the input record to that output at the output's length: pad with spaces or cut on the right.
6. Read the next record; stop at end of file, or when the read count reaches 99,999,999. Back to 2.
7. Display the counts (records read, written per output, totals) and stop.

Value sets: one per `KEYS` card. Each field's value is padded with spaces to the field length or cut on the right;
`BLANC` = spaces; `<` becomes `;` (the skeleton's `INSPECT`). The set's value is the field values concatenated in card
order, compared byte for byte with the key.

Limits seen: input/output ≤ 3,300 B, ≤ 8 key fields, key ≤ 376 B, ≤ 19 value sets.

## Interpretations to confirm (MT-033)

- A value written in quotes on the card (`KEYS R 2,1,'W'`, SOCM02_D1) is generated as `VALUE ''W''`, which is not a
  valid COBOL literal. Taken as `W` (quotes removed), as for CFH-COPY constants.
- Two value sets of SINM05 end in a lone `'` or `"` (`00000000000'`). Taken literally.
- Tape outputs (4th subfield, trailer record), card-reader input and printer output exist in the skeleton but not in
  any real call: not supported.
