# Generic FUSBA — behaviour spec (step 0, 2026-10-20)

Source: all 36 real calls (32 `*UTILIT.FUSBA/ASCII`, 4 `*UTILIT.FUSBA2/ASCII`), expanded with their own cards by
`Conversion/Pipeline/Expand-AllCalls.ps1` (36/36 clean, `E:\Repos\ssg4-work\allcalls\expanded\FUSBA*_ASCII__*.cob`);
skeleton logic read from `SsgConverter/Examples/Output/FUSBA_ASCII.ps1` / `FUSBA2_ASCII.ps1`; shapes from
`Classify-FusbaCalls.ps1` (`inventory.csv`). Both skeletons are run with `@XQT TPF$.FUSBA` (one Xqt name).

FUSBA merges two key-sorted files: file 1 is the **update** file, file 2 the **master**. The result is a copy of the
master, split, cut down or updated by the update file. The runstream comment of COMA16_U1 says it:
"UNL(KEYS) sans CLE(UPDATE) = LOA ; SUP = UNL(KEYS)=CLE(UPD)".

## Cards

| Card | Meaning |
|---|---|
| `INPUT name1,len,blk name2,len,blk` | file 1 = update file, file 2 = master (always 2 files in the real calls) |
| `OUTPUT name,len,blk [name,len,blk]` | 1 or 2 outputs, each with its own record length |
| `KEYS pos,len ...` | key fields of the master (file 2) |
| `UPDATE pos,len ...` | key fields of the update file (file 1); always present in the real calls |
| `ANNUL COPY` / `ANNUL YES` | delete matched masters; `COPY` writes them to output 2 |
| `FIELDIN pos,len ...` / `FIELDOUT pos,len ...` | field *i* of the update record replaces field *i* of the output record |
| `NOLIST`, `ASCII` | always present; `NOLIST` removes the "NO MATCH" listing (no file effect) |

## Calls by shape (36)

| Calls | Skeleton | Cards | Mode | Outputs |
|---|---|---|---|---|
| 27 | FUSBA | `ANNUL COPY` | **C** split | 2 |
| 2 | FUSBA | `ANNUL YES` | **D** delete | 1 |
| 3 | FUSBA | `FIELDIN`/`FIELDOUT`, no `ANNUL` | **U** update | 1 |
| 4 | FUSBA2 | `FIELDIN`/`FIELDOUT` | **M** update, many masters per key | 1 |

Not used by any call, not supported: no `UPDATE` (plain N-file merge), more than 2 inputs, `INSERT`, `SEQERROR`,
`TRACE`, tape/card-reader files.

## Behaviour (byte level)

Keys: key 1 = the update record's bytes at the `UPDATE` fields, key 2 = the master's bytes at the `KEYS` fields, each
concatenated in **card order** (`MOVE CORRESPONDING`). Compared byte for byte; a shorter key is padded with spaces.
At end of file the key is HIGH-VALUES (greater than any real key). Records are padded with spaces / cut to the file's
length when read; written at the output's length (pad / cut on the right).

1. Read the first record of each file.
2. Loop:
   - both files at end → stop (display counts).
   - key 1 < key 2 → read file 1 (an update record with no master is skipped).
   - key 1 > key 2 → write the master to output 1 unchanged; read file 2.
   - equal → by mode:
     - **C**: write the master to output 2; read file 2.
     - **D**: drop the master; read file 2.
     - **U**: output 1 = master, then each `FIELDOUT` field := the matching `FIELDIN` field of the update record
       (alphanumeric move: pad / cut); read file 1 **and** file 2.
     - **M**: as U, but read file 2 only; then read file 1 only when the new master key is greater than the previous
       one (or file 2 is at end). So every master with that key gets the same update.

In C and D, file 1 is not read on a match, so several masters with the same key all match.

## Interpretations to confirm (MT-033)

- End of file is handled with flags, not by putting HIGH-VALUES into the record: the same unless a real key is
  all X'FF'.
- `ANNUL` with a value other than `COPY` deletes (the skeleton tests only `COPY`).
