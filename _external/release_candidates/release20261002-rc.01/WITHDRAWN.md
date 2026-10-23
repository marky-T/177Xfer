# release20261002-rc.01 — WITHDRAWN, DO NOT USE

**Status:** withdrawn on 2026-10-21 by decision of the project owner. Kept for reference only.

**What this release was:** the 20 converted SSG programs as PowerShell scripts (bodies, Control Center `-LIVE` wrappers, SGS seeds, original SSG source).

**Why it is withdrawn:** as standalone scripts they have no end purpose. The SSG utilities are not meant to run as PowerShell. They are replaced by the SSG-4 approach: one generic, compiled program per SSG utility, which reads each call's SGS cards at run time and runs as a report/program in AMT Control Center.

**Replaced by:** `release20261002-rc.02` (planned): the SSG-4 generic programs and the converted programs proven in Control Center. Different artefact type (reports/programs, not scripts), so it is not an upgrade of this package.

**Do not:**
- deploy or test the scripts in this folder against the application;
- treat the known-issue list in `RELEASE-NOTES.md` as current;
- use the `-LIVE` wrappers or `Generate-Release-Wrappers.ps1`.

Copies of this release elsewhere (for example the 177Xfer relay branch `test-release-20261002` and the delivered `Scripts_SSG` area under the Federale release folder) are covered by the same withdrawal.

Contents of this folder are unchanged since the dates below; this note is the only file added.

## Scripts that are redundant (all of `1_ConvertedScripts`)

Dates are the files' last-modified times (the build dates of this release). The release was labelled 2026-10-02.
Per RELEASE-NOTES.md every body was produced by one SsgConverter build: `SsgConverter.dll` (Console), 51 200 bytes, SHA-256 `C586C60A39F167DA670E2F4F7BD3809C14590449147151470122E4C3D344C1DA`.
That build predates the converter fixes of October (for example T3-018, T3-025/026, T3-030/031, T3-033 to T3-036, T3-043, T3-045), so these bodies are also out of date against the current converter.

| Program | Body | Body built | Wrapper | Wrapper built | SGS seed | Seed built |
|---|---|---|---|---|---|---|
| `ARCHIFORMAT` | `ARCHIFORMAT.ps1` | 2026-09-30 00:58 | `ARCHIFORMAT-LIVE.ps1` | 2026-10-02 09:07 | `ARCHIFORMAT.sgs-values.json` | 2026-09-30 00:29 |
| `ARCHISEPARE` | `ARCHISEPARE.ps1` | 2026-09-30 00:58 | `ARCHISEPARE-LIVE.ps1` | 2026-10-02 09:07 | `ARCHISEPARE.sgs-values.json` | 2026-09-10 07:01 |
| `BABA_ASCII` | `BABA_ASCII.ps1` | 2026-09-30 00:58 | `BABA_ASCII-LIVE.ps1` | 2026-10-02 09:07 | `BABA_ASCII.sgs-values.json` | 2026-09-10 08:43 |
| `CFH-COPY_ASCII` | `CFH-COPY_ASCII.ps1` | 2026-09-30 00:58 | `CFH-COPY_ASCII-LIVE.ps1` | 2026-10-02 09:07 | `CFH-COPY_ASCII.sgs-values.json` | 2026-09-30 01:02 |
| `CFH-COPY` | `CFH-COPY.ps1` | 2026-09-30 00:58 | `CFH-COPY-LIVE.ps1` | 2026-10-02 09:07 | `CFH-COPY.sgs-values.json` | 2026-09-10 08:43 |
| `CHAB100_ASCII` | `CHAB100_ASCII.ps1` | 2026-09-30 00:58 | `CHAB100_ASCII-LIVE.ps1` | 2026-10-02 09:07 | `CHAB100_ASCII.sgs-values.json` | 2026-09-30 00:29 |
| `CHABAN_ASCII` | `CHABAN_ASCII.ps1` | 2026-09-30 00:58 | `CHABAN_ASCII-LIVE.ps1` | 2026-10-02 09:07 | `CHABAN_ASCII.sgs-values.json` | 2026-09-10 08:43 |
| `CONDIS2_ASCII` | `CONDIS2_ASCII.ps1` | 2026-09-30 00:58 | `CONDIS2_ASCII-LIVE.ps1` | 2026-10-02 09:07 | `CONDIS2_ASCII.sgs-values.json` | 2026-09-30 01:03 |
| `EXTEUR` | `EXTEUR.ps1` | 2026-09-30 01:28 | `EXTEUR-LIVE.ps1` | 2026-10-02 09:07 | `EXTEUR.sgs-values.json` | 2026-09-30 01:39 |
| `FUSBA_ASCII` | `FUSBA_ASCII.ps1` | 2026-09-30 00:58 | `FUSBA_ASCII-LIVE.ps1` | 2026-10-02 09:07 | `FUSBA_ASCII.sgs-values.json` | 2026-09-30 01:02 |
| `FUSBA2_ASCII` | `FUSBA2_ASCII.ps1` | 2026-09-30 00:58 | `FUSBA2_ASCII-LIVE.ps1` | 2026-10-02 09:07 | `FUSBA2_ASCII.sgs-values.json` | 2026-09-30 01:02 |
| `LECTIS_ASCII` | `LECTIS_ASCII.ps1` | 2026-09-30 00:58 | `LECTIS_ASCII-LIVE.ps1` | 2026-10-02 09:07 | `LECTIS_ASCII.sgs-values.json` | 2026-09-30 01:02 |
| `LOADIS_ASCII` | `LOADIS_ASCII.ps1` | 2026-09-30 00:58 | `LOADIS_ASCII-LIVE.ps1` | 2026-10-02 09:07 | `LOADIS_ASCII.sgs-values.json` | 2026-09-30 00:29 |
| `LOADIS_MULTI` | `LOADIS_MULTI.ps1` | 2026-09-30 00:58 | `LOADIS_MULTI-LIVE.ps1` | 2026-10-02 09:07 | `LOADIS_MULTI.sgs-values.json` | 2026-09-30 00:29 |
| `RECAP` | `RECAP.ps1` | 2026-09-30 00:58 | `RECAP-LIVE.ps1` | 2026-10-02 09:07 | `RECAP.sgs-values.json` | 2026-09-30 01:02 |
| `SCAN_ASCII` | `SCAN_ASCII.ps1` | 2026-09-30 07:48 | `SCAN_ASCII-LIVE.ps1` | 2026-10-02 09:07 | `SCAN_ASCII.sgs-values.json` | 2026-09-30 08:22 |
| `TABAN_ASCII` | `TABAN_ASCII.ps1` | 2026-09-30 00:58 | `TABAN_ASCII-LIVE.ps1` | 2026-10-02 09:07 | `TABAN_ASCII.sgs-values.json` | 2026-09-30 00:29 |
| `TAPELD_ASCII` | `TAPELD_ASCII.ps1` | 2026-09-30 00:58 | `TAPELD_ASCII-LIVE.ps1` | 2026-10-02 09:07 | `TAPELD_ASCII.sgs-values.json` | 2026-09-30 00:29 |
| `UNLOADIS_ASCII` | `UNLOADIS_ASCII.ps1` | 2026-09-30 00:58 | `UNLOADIS_ASCII-LIVE.ps1` | 2026-10-02 09:07 | `UNLOADIS_ASCII.sgs-values.json` | 2026-09-10 08:43 |
| `UNLOADIS_MULTI` | `UNLOADIS_MULTI.ps1` | 2026-09-30 00:58 | `UNLOADIS_MULTI-LIVE.ps1` | 2026-10-02 09:07 | `UNLOADIS_MULTI.sgs-values.json` | 2026-09-30 00:29 |

| Other file | Built |
|---|---|
| `1_ConvertedScripts/Generate-Release-Wrappers.ps1` | 2026-10-05 11:38 |

Total: 20 bodies, 20 wrappers, 20 SGS seeds, 1 generator script.

Not redundant (kept as reference): `2_OriginalSource/` (the 20 original SSG source files, dated 2026-09-08), README.md, RELEASE-NOTES.md and VALIDATION-PROMPT.md.
