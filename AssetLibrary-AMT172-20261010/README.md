# Asset library - AMT172 - 20261010

Reference library of the project assets built in the AMT172 environment (Trial 1 / AMT172 lane: C:\Amt\Working plus the shared C:\Amt\Migration, SharePipelineProcess, Transfer and .github material), for use on the AMT177 SsgTrial VM (`E:\Repos\SsgTrial`) during Trial 4.

| Item | Value |
|---|---|
| Environment | AMT172 |
| Export date | 2026-10-10 |
| AMT version / build | 8.0.26125.0 (`C:\Amt\Working`) |
| Exported by | mark.truman on WINAPOKMIUEJNHB |
| Files | 429 |

Source was read-only: files were copied byte-for-byte (no re-encoding). Several SSG/ECL files are Windows-1252, so keep `* -text` in git.

## Layout

| Folder | Files |
|---|---|
| 01-docs-html | 84 |
| 02-todo-issues | 9 |
| 03-pipelines | 300 |
| 04-prompts | 3 |
| 05-instructions | 2 |
| 06-plans | 9 |
| 07-other | 22 |

Each file keeps its relative path under `<category>/<source-label>/`. Source labels: `Migration` (C:\Amt\Migration), `Working` (C:\Amt\Working), `Parallel` / `AMT175` (C:\Amt\Parallel...), `Amt` (other C:\Amt folders), `SsgTrial-Transfer` (mirror repo docs), `ReferenceDocuments`.

## Files

- `asset-register.csv` / `asset-register.md` - one row per file.
- `duplicate-report.md` - exact duplicates, diverged same-name copies, script families.

## Caveats

- `Description`, `Trial`, `Status` and `StalePaths` in the register are heuristic (first comment/heading/title; path contains 172/175; same-name older copy = superseded). Review `unknown` rows.
- Files flagged `CONTAINS-CREDENTIAL` matched `password|pwd=|secret|token|.lic` (visibility only; copied as-is). Many are false positives (e.g. the word 'token' in parser scripts).
- Not collected: AMT product binaries, licences, databases/backups, logs, generated conversion output (PModelOut, UnloadOut, T3ConvertedSSG, SSGConverter_Output*), SSG source/test data (candidates, SSGConverter_Input), files over 5 MB.