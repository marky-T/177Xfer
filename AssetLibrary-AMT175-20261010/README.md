# Asset library - AMT175 - 20261010

Reference library of the project assets built in the AMT175 environment (Trial 2 / AMT175 lane, with earlier Trial 1 / AMT172 material found in the same folders), for use on the AMT177 SsgTrial VM (`E:\Repos\SsgTrial`) during Trial 4.

| Item | Value |
|---|---|
| Environment | AMT175 |
| Export date | 2026-10-11 |
| AMT version / build | 8.0.26188.0 (`C:\Amt\Parallel\AMT175\8.0.26188.0`) |
| Exported by | mark.truman on WINAPOKMIUEJNHB |
| Files | 891 |

Source was read-only: files were copied byte-for-byte (no re-encoding). Several SSG/ECL files are Windows-1252, so keep `* -text` in git.

## Layout

| Folder | Files |
|---|---|
| 01-docs-html | 109 |
| 02-todo-issues | 40 |
| 03-pipelines | 686 |
| 04-prompts | 8 |
| 05-instructions | 3 |
| 06-plans | 15 |
| 07-other | 30 |

Each file keeps its relative path under `<category>/<source-label>/`. Source labels: `Migration` (C:\Amt\Migration), `Working` (C:\Amt\Working), `Parallel` / `AMT175` (C:\Amt\Parallel...), `Amt` (other C:\Amt folders), `SsgTrial-Transfer` (mirror repo docs), `ReferenceDocuments`.

## Files

- `asset-register.csv` / `asset-register.md` - one row per file.
- `duplicate-report.md` - exact duplicates, diverged same-name copies, script families.

## Caveats

- `Description`, `Trial`, `Status` and `StalePaths` in the register are heuristic (first comment/heading/title; path contains 172/175; same-name older copy = superseded). Review `unknown` rows.
- Files flagged `CONTAINS-CREDENTIAL` matched `password|pwd=|secret|token|.lic` (visibility only; copied as-is). Many are false positives (e.g. the word 'token' in parser scripts).
- Not collected: AMT product binaries, licences, databases/backups, logs, generated conversion output (PModelOut, UnloadOut, T3ConvertedSSG, SSGConverter_Output*), files over 5 MB.
- SSG source/test data (`candidates`, `SSGConverter_Input`, `Source-SSG`) is included under `03-pipelines` and flagged `SSG source/test data` in the register `Notes`.
- `02-todo-issues` holds `*.extract.md` (bug / known-issue logs from HTML) and `*.todo.extract.md` (done and open items from HTML status badges and markdown checkboxes). The full source files are also kept in their own category.