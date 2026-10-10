---
mode: agent
description: "Export this workspace's trial-built assets (docs/runbooks/todo/issues, pipeline scripts, prompts, instructions) into one asset-library folder with a register, ready for git transfer to the AMT177 SsgTrial VM."
---

# Export trial asset library (run in the AMT172 or AMT175 workspace)

You are packaging the **project assets we built** in this workspace so they can be transferred by
git to the AMT177 VM (`E:\Repos\SsgTrial`) and kept there as a reference library for Trial 4.

**Read-only on the source.** Copy, never move or edit. Do not change any AMT installation, database,
service, IIS site, Keycloak config or application in this environment.

## 1. Identify this environment

Set `<ENV>` = `AMT172` or `AMT175` (ask the user if it isn't obvious from the paths/install). Use
today's date as `<yyyymmdd>`.

## 2. What to collect (our builds only)

Search the workspace and the usual project folders (e.g. `C:\Amt\Migration\`, `C:\Amt\Working\SSG*`,
`C:\Amt\Parallel\templates\`, `.github\`, any trial/pipeline folders). Collect:

| Category folder | Include |
|---|---|
| `01-docs-html` | HTML runbooks, setup guides, progress trackers, reference pages **and** whatever creates them (templates, JSON content, fill/generator scripts, CSS) |
| `02-todo-issues` | ToDo, gap, bug and issue logs in any form (HTML sections, MD, CSV, JSON). If a log is only embedded in an HTML page, also extract it to `<name>.extract.md` as a table, keeping the original IDs |
| `03-pipelines` | PowerShell/C#/Python scripts we wrote: pipelines, converters wrappers, harnesses, mocks, deploy/release/verify scripts, manifests, `.settings`, config JSON, macros, schemas, refimpl/oracle scripts, fixtures **small enough to be useful** (< 5 MB each) |
| `04-prompts` | `.prompt.md` and any saved prompt text |
| `05-instructions` | `copilot-instructions.md`, `.instructions.md`, `AGENTS.md`, `SKILL.md`, agent files |
| `06-plans` | Copilot plans, design notes, decision records |
| `07-other` | Anything else we built that doesn't fit above — say why in the register |

## 3. What to exclude

- AMT product binaries, AMT/Lion source changes, AMT tool drops (`MigrationTools`, `AMTTools`, `Lion`).
- Licence files (`*.lic`) and Keycloak exports.
- **Do not redact or exclude a file just because it contains a password, connection string or
  hostname.** Copy it as-is and set the register's `Notes` column to `CONTAINS-CREDENTIAL` so it's
  visible at a glance. These are the user's own environment credentials, not a security boundary for
  this export — the point of flagging is visibility, not blocking.

  **No mid-run pauses for this.** Flagging a credential is a one-line note in the register, not a
  decision — never stop, never ask a clarifying question, never wait for input over a credential hit.
  Keep copying and move to the next file. The only checkpoint in this whole prompt is the git push in
  §7.
- Databases, backups, logs, generated build output (`bin/`, `obj/`, `.LionSource` bulk exports),
  production data, anything > 5 MB unless the user approves it.

## 4. Output layout

Create one parent folder (outside any AMT install):

```text
AssetLibrary-<ENV>-<yyyymmdd>/
  README.md                 # what this is, ENV, date, AMT version, who exported it
  asset-register.csv        # one row per file (see §5)
  asset-register.md         # same content as a readable table, grouped by category
  01-docs-html/
  02-todo-issues/
  03-pipelines/
  04-prompts/
  05-instructions/
  06-plans/
  07-other/
```

Keep each file's relative sub-path under its category so related files stay together. Preserve
file bytes exactly (many SSG/ECL sources are **Windows-1252** — copy as binary, never re-encode).

## 5. Asset register columns

| Column | Content |
|---|---|
| `Object` | File name |
| `Category` | Category folder |
| `LibraryPath` | Path inside the library |
| `OriginalPath` | Full source path in this environment |
| `Description` | One line: what it does / what it records |
| `Trial` | `Trial1` (AMT172) / `Trial2` (AMT175), or `Both` |
| `LastUsed` | Last git commit date for the file if tracked, otherwise LastWriteTime (`yyyy-MM-dd`) |
| `Status` | `active` / `superseded` / `unknown` — superseded if a newer file clearly replaces it |
| `StalePaths` | `yes` if it hard-codes `C:\Amt\...`, `C:\Dev\...` or a machine name, else `no` |
| `SHA256` | File hash |
| `DuplicateOf` | `LibraryPath` of the first row with the same `SHA256`, else empty. Keep every copy — do not deduplicate |
| `SameNameDiffHash` | `yes` if another row has the same `Object` name but a different `SHA256` (diverged copy), else `no` |
| `Notes` | Dependencies, known issues, excluded reason |

Record the AMT version / build number of this environment in `README.md`.

## 6. Verify before handing over

- Every file in the library has exactly one register row, and every row points at a real file.
- Re-hash a sample of 5 files against the originals.
- Search the library for `password`, `pwd=`, `secret`, `token`, `.lic` — tag every match
  `CONTAINS-CREDENTIAL` in the register and **keep going**. This is a tally for the final report, not
  a decision point — do not pause, do not ask, do not exclude the file.
- Fill `DuplicateOf` and `SameNameDiffHash` for every row, and write `duplicate-report.md` in the
  library root: (a) exact-duplicate groups (same SHA256) with their paths, (b) same-name/different-hash
  groups, (c) families of similarly named scripts (e.g. `fill-*-cells.ps1`) as candidates for shared
  logic. Informational only — do not delete, merge or pause.
- Report totals per category and the 10 most recently used assets.

## 7. Git transfer (checkpoint — ask before pushing)

Add the folder to the transfer repo `marky-T/177Xfer` on a new branch
`asset-library-<ENV>-<yyyymmdd>`, with a `.gitattributes` entry `* -text` for the library folder so
Windows-1252 files are not normalised. **Show the user the file count, total size and the
credential tally, and wait for confirmation before committing and pushing.** Never force-push.

## 8. Report back

Return: library path, branch name, commit hash, totals per category, excluded items (with reason),
and any assets marked `unknown` that need the user's judgement. List `CONTAINS-CREDENTIAL` files by
name in the summary (count + filenames) so they're visible, but this is informational only — it does
not require a decision before the report is given. Include the duplicate counts (exact-duplicate
groups, extra copies, same-name/diff-hash groups) from `duplicate-report.md`.
