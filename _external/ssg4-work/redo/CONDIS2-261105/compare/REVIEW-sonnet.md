# MT-053 review — Sonnet blind CONDIS2 reconversion vs rc.02 / earlier runs (261105)

Reviewed: `E:\Repos\ssg4-work\redo\CONDIS2-261105_sonnet\` (PROMPT.md, REPORT.md, all outputs).
Compared with: rc.02 (`E:\Repos\release_candidates\release20261022-rc.02`), the repo's `Generic\CONDIS2`, the 10/19
release expansion, the 10/20–21 all-call expansions, and the real CC outputs of job 714 (regress 10/21 23:41).

## Verdict: accepted, with findings
The documented process (instructions + `/ssg-generic-utility` + templates), run blind by another model, produced
a generic CONDIS2 whose model behaves **byte-identically to the CC-proven rc.02 program** on every real-call shape.
Process compliance was good; the deviations it declared are minor and honest.

## Guardrails
| Check | Result |
|---|---|
| Protected files (741: Generic, Examples, SSG-Source, rc.02, earlier outputs) | 0 changed, 0 added, 0 removed (`protected-before-sonnet.csv`) |
| Git | no commit (HEAD still d081c5b) |
| Blind rule | one accidental sight of the CONDIS2 `regress` block (names only); declared; names deliberately chosen differently |
| Runstreams read | allowed by the gate decision (use names) |

## Results
| # | Comparison | Result |
|---|---|---|
| 1 | Per-call expansion (AUMH01): Sonnet vs my run | byte-identical |
| 2 | All 18 per-call expansions: Sonnet vs `allcalls\expanded` (10/20) and `expanded-fix` (10/21) | 18/18 byte-identical |
| 3 | 10/19 release expansion vs today | differs only in REDEFINES FILLER widths: **T3-043** (fixed 261021). Earlier note in chat blaming T3-048 was wrong |
| 4 | G7 counts | Sonnet MATCH 17 + NO-EXPANSION 1 (PAIJ01_UL, T3-028); rc.02 baseline MATCH 18 used a `~`-protected expansion for that call. Same substance |
| 5 | **Sonnet model on the 6 CC cases (D42 DT BD UL UE VG), real cards + CC inputs** | **6/6 output byte-identical to CC job 714; 6/6 report lines identical to the CC job log** (`sonnet-model-vs-cc.csv`) |
| 6 | rc.02 writer + model on Sonnet's 34 cases (`Test-OldOnSonnetCases.ps1`, `old-on-sonnet.csv`) | 18/18 real-card cases identical; synthetic: all-date-codes, d42-boundaries, quoted-spaces, short/long records, case-no-otherwise, prelude-move identical |
| 7 | Differences in 6 | V1/V4/V5 abort cases: Sonnet rejects (as the skeleton's FLAGABORT), rc.02 runs → **T3-057**. CASE-after-OTHERWISE and CONST longer than field: rc.02 rejects (program limits), Sonnet runs as written. OTHERWISE-first: both run, outputs differ at byte 4 → T3-056 area, unresolved; neither is authoritative |
| 8 | Generic COBOL | different but equivalent design: same files (PARMF, FI1, FO1), 4001-byte input, 661 vs 625 lines, 44 vs 34 paragraphs (24 shared); SGSPARM RL/CD/MV/KT/TL vs FI/FO/CA/OT/TS/MV/CO; conversion 0 errors both. **Not run** (needs LionDev + Deliver) |

## Findings to act on
1. **T3-057** (new): rc.02 CONDIS2 hand-off misses V1/V4/V5. Low impact (no real call), fix in next release.
2. **T3-056** (logged earlier today): AMT StrictMode makes the per-call skeleton throw for OTHERWISE calls; the
   expansion harness should run under StrictMode 2.
3. The static `ASSURFED_UTILIT_CONDIS2_ASCII.dll` (10/20 22:25) predates T3-043's landing (10/21 00:18), so it has
   the wrong FILLER widths; `Test-CondisReference.ps1` D42 still passed because positions are unaffected. Rebuild
   before using it as a reference again.
4. Process: the blind run needed two owner clarifications (gate decisions, StrictMode) — both now in the record;
   worth adding to the prompt: "SGS label unset → check StrictMode behaviour" and "reproduce every FLAGABORT check".

## Open
- CC run of Sonnet's own generic program (LionDev generate, Deliver to a test name, CC job) — would close the last
  gap (COBOL vs model). Optional; the model-level equivalence above is strong.
