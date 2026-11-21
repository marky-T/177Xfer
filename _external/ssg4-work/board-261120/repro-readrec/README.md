# Repro: line-sequential READ merges short lines into one record

## Files
| File | What |
|---|---|
| `READREC.cob` | Input FD `RECORD VARYING IN SIZE FROM 1 TO 4001 DEPENDING ON WS-LEN`, assigned `RDIN`. Reads every record and writes, per record, `nnnnnn lllll <first 60 bytes>` (record number, WS-LEN, data) to `RDOUT`; displays `RECORDS READ = n`. |
| `in1-end-pair.txt` | 18 lines of 8 bytes, then lines of 4 and 2 bytes |
| `in2-midfile.txt` | lines of 30, 12, 16 bytes |
| `in3-control.txt` | 8, 8, 8, 6, 4, 2 (control: must not merge) |
| `in4-two-merges.txt` | 8, 8, 4, 2, 4, 2 |

Every line is one letter repeated (line 1 `A...`, line 2 `B...`, ...) and ends in CR LF, so a merged record shows two letters
with CR LF between them.

## Run
1. Convert and generate READREC into an application.
2. For each input: copy it to the application's Extracts folder as `RDIN.DAT`, start the program job, read `RDOUT.DAT`.
3. Compare the number of records with the number of lines.

## Result (Control Center, AMT 177a, 20 Nov 2026)
| Input | Lines | Records read | Merged record |
|---|---|---|---|
| `in1-end-pair.txt` | 20 | **19** | 19 = `SSSS<CR><LF>TT` |
| `in2-midfile.txt` | 3 | **2** | 2 = `B x12 <CR><LF> C x16` |
| `in3-control.txt` | 6 | 6 | none |
| `in4-two-merges.txt` | 6 | **4** | 3 = `CCCC<CR><LF>DD`, 4 = `EEEE<CR><LF>FF` |

Also seen in every run: `WS-LEN` (the DEPENDING ON item) is 4001 after each READ, not the length of the record read.
The program was run under a trial program name; the source is the same apart from the PROGRAM-ID.