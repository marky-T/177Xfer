# Validation prompt — install & run an SsgConverter PowerShell release on a live AMT box

A reusable, environment-agnostic Copilot instruction for validating **this kind** of release
(an SsgConverter PowerShell package — body + wrapper pattern — under AMT Control Center) on **any**
AMT instance. No environment-specific paths are baked in: every fact (paths, scan behaviour,
service account, exit status) is **confirmed live** before being relied on.

> Origin: distilled from the first live validation of this release (CFH-COPY, AMT172, 2026-10-02),
> where the Script-path value and the required environment-variable scope both turned out different
> from what a prior environment's convention would have assumed.

---

```markdown
# Task: Validate an SsgConverter PowerShell release against a live AMT Control Center

You are installing and running ONE converted program from a release package (body + wrapper
pattern) against a real AMT Control Center instance, to prove the install instructions work
end-to-end. Do not assume any path, menu location, or account — confirm each empirically.

## Prerequisites to confirm FIRST (don't assume any of these)
- [ ] AMT Control Center is reachable and you can log in (or the user can share an already
      authenticated browser tab — you cannot complete OIDC/Keycloak login yourself).
- [ ] A COBOL/OS2200 (or equivalent) application is already registered in CC with a working
      Transaction Server, base paths, and database — the SSG reports need a real app to attach to.
- [ ] The job-hosting process is a supported PowerShell host (e.g. net8/PS7.4+). A bare desktop
      `pwsh` session is commonly NOT sufficient for the live DB connect — confirm what CC actually
      uses to launch Script-type jobs before assuming a bare `pwsh` test proves anything.
- [ ] Disk space: if pulling from git, check for repo-wide LFS-tracked or large binary folders
      unrelated to the release before fetching. Use `GIT_LFS_SKIP_SMUDGE=1` and a cone
      sparse-checkout scoped to just the release folder if the repo has unrelated large content.

## Access you may need to ask the user for (never attempt yourself)
- An authenticated CC browser session (you cannot complete interactive login).
- An **elevated** terminal, if the job-hosting service runs under a system account (e.g.
  LocalSystem) — Machine-scoped environment variables require admin rights you won't have.
  Confirm the service account first: `Get-CimInstance Win32_Service -Filter "Name='<svc>'" |
  Select StartName` — only escalate to asking for Machine scope if it's NOT the interactive user.
- Explicit confirmation before pushing anything back to a shared git remote.

## Locations — confirm live, never assume a folder convention
- The "Script path" (or equivalent job-source basepath) for the target application: find it in
  the live admin UI (e.g. System Configuration → Basepaths), not from a prior environment's
  convention or a guess. It may be a flat shared root, an app-specific subfolder, or templated —
  don't assume which.
- Body files: deploy exactly where the release's own docs say (commonly flat, no subfolder,
  named `<KEY>.ext`) — nesting is a common silent failure mode.
- Wrapper/runner files: confirm whether the job-discovery mechanism recurses into subfolders
  by testing it, not by assuming — register one file, check whether it shows up before trusting
  a folder layout.
- Runtime libraries/settings file: prefer explicit environment variables over any relative-path
  fallback the release suggests — relative fallbacks are typically depth-sensitive and fail
  silently if your deployment layout doesn't match exactly.

## Required hygiene after any cross-machine file copy
- Unblock-File (or equivalent) on everything copied — Windows mark-of-the-web (Zone.Identifier)
  silently blocks scripts under a job-hosting service even when they run fine interactively.

## Input files — stage only if the body actually reads them
- Do NOT stage input files on assumption. Converted SSG bodies are frequently **codegen-only**
  (they emit COBOL/text; they perform no runtime tape/file I/O), so they need nothing staged.
  **Inspect the body first** for real reads/opens of its logical files; stage an input (e.g. an
  `Extracts\<DESIGNATOR>` file) only if the body genuinely consumes one. (On the first live run,
  `CFH-COPY` turned out codegen-only and needed no input at all.)

## Registration & run
- **Register and run the WRAPPER (`<KEY>-LIVE`), never the body.** The body has no
  `Initialize`/`Connect-Application` and cannot resolve its own paths; only the wrapper does the
  live connect and resolves the body from the CC Script basepath. Registering the body is a
  guaranteed non-runnable entry.
- Use the release's OWN documented registration mechanism first (e.g. a "read jobs from system"
  scan) — only fall back to a different mechanism (direct DB insert, etc.) if the documented one
  doesn't exist in this environment, and flag that explicitly if you do.
- Grant whatever security/activation step the environment requires before the job becomes
  startable.

## Verification — don't trust a single signal
- Check the actual job log file on disk, not just a UI status column — some CC-style UIs flag
  any captured stdout as "Error" even when the real exit code is 0 and the log is clean.
- Check the real exit code/task value alongside the log content.

## Reporting back
- Explicitly list any deviation from the documented steps you needed to make it work — that's
  the most valuable feedback for whoever maintains the release package.
```
