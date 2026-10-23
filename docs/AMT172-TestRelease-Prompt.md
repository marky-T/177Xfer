# Prompt for the AMT172 Copilot — test-install the SSG→PowerShell release and run one program

Copy everything below the line into the AMT172 Copilot session.

---

**Task: pull a new test-release of the converted SSG→PowerShell programs, install it per its own README, and prove ONE program runs live through Control Center.**

**1. Pull the release**
- Remote: `marky-T/177Xfer`, branch **`test-release-20261002`**.
- In your local `177Xfer` clone: `git fetch origin`, then check out `test-release-20261002` (it branches off `main`, so it contains only the release payload under `release20261002-rc.01/`).
- Gotcha: if `GIT_LFS_SKIP_SMUDGE` is set in the shell, run `Remove-Item Env:\GIT_LFS_SKIP_SMUDGE` first, then pull, or files may arrive as pointer stubs.
- The payload is:
  - `release20261002-rc.01/README.md` and `RELEASE-NOTES.md`
  - `1_ConvertedScripts/Bodies/<KEY>.ps1` (20 converted bodies)
  - `1_ConvertedScripts/Wrappers/<KEY>-LIVE.ps1` (20 Control Center wrappers)
  - `1_ConvertedScripts/SgsSeeds/<KEY>.sgs-values.json` (20 SGS seeds)
  - `2_OriginalSource/` (the original SSG source, for reference)

**2. Read the README first — especially the "⚠ Required runtime setup" box.** Two items are load-bearing and will *silently* fail if wrong:
  1. **Each body must be deployed FLAT at the Control Center *Script path* root as `<KEY>.ps1`** (not nested in a subfolder). The wrapper resolves the body as `Join-Path $global:AmtPath.ScriptPath '<KEY>.ps1'`.
  2. **Set `AMT_RT` and `AMT_SETTINGS` explicitly** for the job host (preferred over the relative `..\..\Libraries` / `..\..\Settings` fallback, which only works at an exact folder depth).

**3. Install for ONE program — use `CFH-COPY`** (the proven baseline; it produces visible output, and unlike some others it does NOT call `Log-Message`, so it needs no customer-lib stub):
  - Deploy `Bodies/CFH-COPY.ps1` flat into your application's CC Script path.
  - Deploy `Wrappers/CFH-COPY-LIVE.ps1` into your run location.
  - Point `AMT_RT` at the folder holding `AmtPsEclLib.psm1` (+ `AmtPsSortLib.psm1`, `AmtPsCustomerLib.psm1`), and `AMT_SETTINGS` at the `AmtSettings.xml` for your `AFBUS_2200COBOL` application.
  - **Unblock-File** every `.ps1`/`.psm1` you copied in (mark-of-the-web; see RELEASE-NOTES issue T3-010): `Get-ChildItem <path> -Recurse -Include *.ps1,*.psm1 | Unblock-File`.
  - Stage the input file `CFH-COPY` reads (`ECL-TAPEIN`) in the application's `Extracts` folder, the same way your earlier 20-program live run did.

**4. Register and run it through Control Center**
  - Register the wrapper `CFH-COPY-LIVE` as the job (via "Read all jobs from system", or your established registration route). Register **only the wrapper**, not the body.
  - Grant security rights, then **Start Job**.

**5. Report back:**
  - Did `Initialize` reach the "live Connect-Application succeeded" line and the body reach "Body completed without a thrown exception" → `Fin`?
  - The job's final Control Center status (Completed vs Error) and the output it produced (`ECL-TAPEOUT`), ideally diffed against the expected result.
  - **Any deviation from the README install steps you had to make to get it to run** — this is the main thing I need back: whether the two "Required runtime setup" items (flat body placement + `AMT_RT`/`AMT_SETTINGS`) were sufficient and correctly described, or whether anything else was needed. List any step, path, or syntax issue so I can fix the release before the full 20-program install.

Note: this release was validated on the originating VM with a mock install dry-run (install layout, path resolution, wrapper/body syntax, run sequence all pass) but has **not** been run against a real AMT application on this side — your run is the first live validation of this specific release package.

---
