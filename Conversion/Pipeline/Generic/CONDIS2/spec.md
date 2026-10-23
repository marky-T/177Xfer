# CONDIS2 generic program (MT-043, runbook C11)

**Skeleton** `*UTILIT.CONDIS2/ASCII` (`SsgConverter\Examples\Input\CONDIS2_ASCII.TXT`), 18 calls, `@XQT TPF$.CONDIS2`.
Copies `FILEIN` (record length `FILEIN n`) to `FILEOUT` (`FILEOUT n`) field by field, with conditions:

| Card | Meaning |
|---|---|
| `PG CASE pos,len,value ...` | starts a group; every test must hold (nested `IF`s) |
| `PG OTHERWISE` | last group, no test |
| `PG MOVE in,len,out[,Dxx] ...` | input field to output; `Dxx` = date conversion (`TRANSFO-DATE-*`) |
| `PG CONST pos,len,value ...` | constant into the output |

Per record: output = spaces; groups in card order. A MOVE/CONST before the first CASE runs for every record.
The first group whose tests hold runs its items and writes the record. No match: written only if the call has
no CASE and no OTHERWISE, else dropped (`CASE-NON-PREVU`). Date codes and output lengths: D42 4->2, D24 2->4,
D22A/D22B 2->2, D66A/D66B 6->6, D68 6->8, D86 8->6. Used by the 18 calls: D42, D24, D68.

**Generic program** `ASSURFED-UTILIT-CONDIS2-GN` (`gen\New-CondisGn.ps1` builds it: table-driven core + the
skeleton's own date paragraphs, `WRITE-REC-OUTPUT` and report copied verbatim). Opens `FILEIN` (varying, max 4001,
T3-040), `FILEOUT` (record size from task value `RECSIZEFILEOUT`), `SGSPARM`.

**Parameter file** `CONPARM` (250-byte lines, `gen\CondisParm.ps1`): `FI<len5>`, `FO<len5>`, `NG|CA|OT`,
`TS<pos5><len5><value>`, `MV<in5><len5><out5><outlen5><code4>`, `CO<pos5><len5><value>`. The PG cards are read
from the raw card file (`$SgsFilePath`), because `AddTo-SgsList` splits `''  ''` (T3-028, PAIJ01_UL_L85).
SSG quoting (manual 3.x): `'x'` keeps its quotes, `''x''` does not.

**Checks**
- `check\Test-CondisParm.ps1`: parameter lines vs each call's expansion: 17 MATCH, PAIJ01_UL no expansion (T3-028).
- `check\Test-CondisReference.ps1`: model == static CONDIS2_ASCII (AUMH01, D42, short record) in mock: PASS.
  UE / DT against test-only CONDIS2-RV / -RD (from the VIRJ01_UE / AUPA02_MJ_L68 expansions) after the LionDev round.
- CC: `Prepare-CondisCc.ps1` -> job `SSG4_CONDIS_CASES` (6 cases D42, DT, BD, UL, UE, VG; qualifier `CON<case>`),
  `cc-cases.json` for `Test-CcJob.ps1 -LogPrefix CONDTEST`.
