# Generic CHABAN — behaviour spec (step 0, 2026-10-20)

Source: all 31 real calls (30 `*UTILIT.CHABAN/ASCII`, 1 `*UTILIT.CHAB100/ASCII`), expanded with their own cards
(31/31 clean, `E:\Repos\ssg4-work\allcalls\expanded\CHAB*_ASCII__*.cob`); skeleton logic read from
`SsgConverter/Examples/Output/CHABAN_ASCII.ps1`; shapes in `inventory.csv`. Both skeletons are run with `@XQT .CHABAN` /
`@XQT TPF$.CHABAN` (one Xqt name, `CHABAN`).

CHABAN creates a file from the run stream's data images (the lines after `@XQT`): each output record is built from
consecutive cards.

## Cards

| Card | Meaning |
|---|---|
| `OUTPUT name,len,blk` | the file to create, record length `len` |
| `NUMB n[,m]` | write `m` records (default 1); `n` is only used in the "too few cards" message |
| `NUM n` | not a label the skeleton uses: no records (same as no `NUMB`) |
| `LIST`, `FLDSEL 0`, `MOD 0` | `LIST` only prints; `FLDSEL` and `MOD` are 0 in every call (their branches are not supported) |

## Calls by shape (31)

| Calls | Cards | Records | Cards per record |
|---|---|---|---|
| 13 | no `NUMB` (8 only `OUTPUT`, 5 `NUM n`) | 0: empty output | – |
| 15 | `NUMB n,1` / `NUMB n` | 1 | ceil(len / 80) |
| 1 | `NUMB 2,2` (TABD53) | 2 | ceil(132 / 80) = 2 |
| 1 | CHAB100 `NUMB 1,1` | 1 | ceil(100 / 100) = 1 (card = 100 bytes) |
| 1 | `NUMB 1,1` with a blank data image (BSEH02) | 1 | 1 |

## Behaviour (byte level)

1. Card length: 80 (CHABAN), 100 (CHAB100). Each card is the data image padded with spaces / cut to the card length.
2. For each of the `m` records: read `ceil(len / card)` cards into consecutive card-length slots; write the slots cut to
   `len` (`WRITE ZFIC FROM ZOUT`). If the cards run out before a record is complete, stop: that record is not written.
3. Stop after `m` records (data images left over are ignored).

## How the cards reach the generic program

AMT's `Xqt` + `DataLineOrNoStatement` write the data images to the run's Accept file (`$TempFolder\Accept_File`); the
`CARD-READER` file of the static programs never receives them (T3-032, CC probe job 680). The shared hand-off maps the
generic program's input `CHAIN` onto that Accept file (`Add-GnUseAlias CHAIN '*ACCEPT*'`), or onto an empty file when the
step has no data images. Proven in CC with CFH-COPY-GN (jobs 683/684): 5 data images including a blank one and a full
100-byte one came through byte for byte.

## Interpretations to confirm (MT-033)

- A data image longer than the card length is cut (on OS 2200 a card is 80 columns).
- `NUM n` is treated as "no NUMB" because the skeleton only tests `NUMB` (5 calls create an empty file; check that this is
  what production does).
