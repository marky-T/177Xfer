# Done / open items extracted from SSG-Trial-Progress_20260819-191119.html

Source: `01-docs-html/Parallel/templates/output/SSG-Trial-Progress_20260819-191119.html` (original: `C:\Amt\Parallel\templates\output\SSG-Trial-Progress_20260819-191119.html`)

1 done / 41 not done (HTML status badges)

## 2 · The 16 Programs — Trial Progress

| Program | Category | Likely Purpose | A — SSG-ECL Pipeline (Convert+Proof Tier-1) | B — AMT Runtime (Tier-2) |
|---|---|---|---|---|
| `UNLOADIS_ASCII` | Unload | UNLOAD-ASCII sequential unload utility (2026-07-07 drop variant) | &#25a1; in progress trial-trial3-15 \| 7330B | — pending |
| `ARCHIFORMAT` | Archive | ARCHIFORMAT table-format archive utility (overlap — diff vs Trial 2 required) | &#mdash; pending | — pending |
| `ARCHISEPARE` | Archive | ARCHISEPARE archive separator (overlap — diff vs Trial 2 required) | &#mdash; pending | — pending |
| `BABA_ASCII` | New | BABA_ASCII — new program (no Trial 2 equivalent); fixtures/goldens to be authored | &#mdash; pending | — pending |
| `CFH-COPY` | Copy | CFH-COPY file copy utility (overlap — diff vs Trial 2 required) | &#mdash; pending | — pending |
| `CFH-COPY_ASCII` | Copy | CFH-COPY_ASCII ASCII copy variant (overlap — diff vs Trial 2 required) | &#mdash; pending | — pending |
| `CHAB100_ASCII` | New | CHAB100_ASCII — new program; fixtures to be authored | &#mdash; pending | — pending |
| `CHABAN_ASCII` | New | CHABAN_ASCII — new program; Steps 1+2 done | &#25a1; in progress trial-trial3 \| 11481B | — pending |
| `CONDIS2_ASCII` | New | CONDIS2_ASCII condition-based filter variant 2 — new program | &#mdash; pending | — pending |
| `EXTEUR` | New | EXTEUR extract utility — new program | &#mdash; pending | — pending |
| `FUSBA2_ASCII` | New | FUSBA2_ASCII fusion variant 2 — new program | &#mdash; pending | — pending |
| `FUSBA_ASCII` | New | FUSBA_ASCII fusion utility — new program | &#mdash; pending | — pending |
| `LECTIS_ASCII` | Read | LECTIS_ASCII multi-key sequential reader ASCII variant (overlap variant mismatch — Trial 2 = LECTIS_MULT) | &#mdash; pending | — pending |
| `LOADIS_ASCII` | Load | LOADIS_ASCII sequential load utility (overlap — diff vs Trial 2 required) | &#mdash; pending | — pending |
| `LOADIS_MULTI` | Load | LOADIS_MULTI multi-record load utility (overlap — diff vs Trial 2 required) | &#mdash; pending | — pending |
| `RECAP` | New | RECAP recapitulation utility — new program | &#mdash; pending | — pending |
| `SCAN_ASCII` | Scan | SCAN_ASCII scan utility ASCII variant (overlap — diff vs Trial 2 required) | &#mdash; pending | — pending |
| `TABAN_ASCII` | New | TABAN_ASCII table-based utility — new program | &#mdash; pending | — pending |
| `TAPELD_ASCII` | Tape | TAPELD_ASCII tape load ASCII variant (overlap — diff vs Trial 2 required) | &#mdash; pending | — pending |
| `UNLOADIS_ASCII` | Unload | UNLOADIS_MULTI multi-record unload utility (overlap — diff vs Trial 2 required) | &#mdash; pending | — pending |

## 3 · How to Update This Page

| Event | Column A action | Column B action |
|---|---|---|
| Manifest entry created + `status=planned` | Change to ◯ planned · trial-NN | — |
| `Convert-SsgToLion.ps1` produces 0-error candidate; fixtures + refimpl written; `Run-EclProof` PASS | Change to ✓ PASS · trial-NN · NNNBytes + add links to runbook / example | — |
| Generated C# builds and runs under AMT runtime (Tier-2) | — | Change to ✓ PASS + add trial/build ref |
