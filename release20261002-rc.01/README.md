# Federale — SSG → PowerShell Converted Report Release

**Release:** `release20261002-rc.01`
**Date:** 2026-10-02
**Component:** Converted OS2200 **SSG (Symbiont Stream Generator)** batch reports, migrated to **PowerShell** for execution under the **AMT** runtime / Control Center.
**Part of:** the Federale mainframe transformation (OS2200 COBOL / LINC / SSG / ECL / DMS → C# / PowerShell / SQL / .NET).

This package is one component of the wider AMT deliverable. It supplies the **20 converted SSG programs** (as PowerShell), their **Control Center run wrappers**, and the **original SSG source** they were converted from, so Federale can test feature-and-function parity. It is delivered alongside — and depends on — the AMT runtime and the converted COBOL / ABSuite applications shipped separately.

---

## 1. What is in this release

```
release20261002-rc.01/
├─ README.md                         ← this file
├─ RELEASE-NOTES.md                  ← test status to date + per-program known issues
├─ 1_ConvertedScripts/
│   ├─ Bodies/        <KEY>.ps1                  20 converted SSG programs (the "body")
│   ├─ Wrappers/      <KEY>-LIVE.ps1             20 Control Center run wrappers (one per body)
│   ├─ SgsSeeds/      <KEY>.sgs-values.json      20 SGS seed files (drive each wrapper)
│   └─ Generate-Release-Wrappers.ps1            regenerates the wrappers from seeds + bodies
└─ 2_OriginalSource/  <KEY>.TXT                  the original SSG source (see §5, Provenance)
```

`<KEY>` is one of the 20 program keys (e.g. `CFH-COPY`, `ARCHIFORMAT`, `EXTEUR`). The **body**, **wrapper**, **seed** and **original** for a program all share the same `<KEY>`.

### Body vs wrapper — why there are two files per program

- **Body** (`Bodies/<KEY>.ps1`) — the raw converter output. It is *pure converted SSG generator logic*: it **calls** AMT runtime functions (`GetSgsValue`, `DataLineOrNoStatement`, …) but never establishes them, has no `Set-Jobname` / `Initialize` / `Connect-Application`, and is **designed to be called, not started**. It cannot be registered as a Control Center job on its own.
- **Wrapper** (`Wrappers/<KEY>-LIVE.ps1`) — a thin, generated ECL skeleton that makes the body runnable as a real CC job:
  `Set-Jobname → Initialize (live Connect-Application) → seed the SGS values → & <body> → Fin`,
  all under a `Trap` that routes any failure to the AMT `Abort`/Control-Center error path.

This two-file shape keeps the converter output **pristine** (reconverting never needs a re-merge) and lets the wrappers be regenerated mechanically from the seeds.

---

## 2. Prerequisites (target environment)

The converted scripts do **not** run standalone — they require the AMT runtime, shipped separately with this transformation:

1. **AMT runtime libraries** — the folder containing `AmtPsEclLib.psm1` (+ `AmtPsSortLib.psm1`, and the customer-extension `AmtPsCustomerLib.psm1`). These provide `Initialize`, `AddTo-SgsList`, `GetSgsValue`, `Fin`, `Abort`, etc.
2. **A COBOL / OS2200 (`ApplicationKind = CobolOS2200`) application** registered in AMT Control Center, with a Transaction Server, base paths, and database. The converted COBOL programs this SSG set drives are delivered with that application. *(These SSG reports cannot run under an ABSuite/LINC application.)*
3. **AMT Control Center** reachable, with a login (Keycloak) that can register, secure and Start jobs.
4. **PowerShell 7.4+ host** — Control Center runs Script jobs via `AmtPowershellHost.exe` (net8 / PS 7.4). A bare desktop `pwsh` is **not** a supported host for the live DB connect.

---

## 3. Install & run (target: AMT Control Center)

> The intended test loop is **git push/pull → install on the AMT box → register & run in Control Center**.

> ### ⚠ Required runtime setup — read this first (2 critical items)
>
> These two are load-bearing. The release runs cleanly in a dry-run, but either of these, set wrong, will **silently** stop a program finding its body or its runtime:
>
> 1. **Bodies must sit FLAT at the exact Script-path root, named `<KEY>.ps1`.** Each wrapper resolves its body as `Join-Path $global:AmtPath.ScriptPath '<KEY>.ps1'` — *directly* in the folder the CC *Script path* points at. **Do not nest the bodies in a subfolder** (not under a `RUN\` or `Bodies\` child). If they are nested, the wrapper will not find them.
> 2. **Prefer setting `AMT_RT` / `AMT_SETTINGS` explicitly** (see Step 3) over the relative fallback. The fallback (`..\..\Libraries`, `..\..\Settings`) only resolves if the wrapper is **exactly two folders** below the Libraries/Settings parent; a different deployment depth breaks it silently. Setting the two environment variables removes that dependency entirely.

### Step 1 — Deploy the bodies to the CC Script basepath
Copy `1_ConvertedScripts/Bodies/*.ps1` **flat** into the application's **Script path** —
*Control Center → System Configuration → System Setup → Basepaths → Script path*.
This is where Control Center's "Read all jobs from system" scan looks, and where each wrapper resolves its body from at run time. **The bodies must be at the root of that Script path as `<KEY>.ps1`, not in any subfolder** (see Required runtime setup, item 1).

### Step 2 — Deploy the wrappers
Copy `1_ConvertedScripts/Wrappers/*-LIVE.ps1` into the run location under that Script path (e.g. `…\Scripts\SSGTRIAL\RUN\`).

### Step 3 — Point the wrappers at the runtime + settings
Each wrapper needs the AMT runtime library folder and an `AmtSettings.xml`. It resolves them in this order:

| Value | Environment variable | Relative fallback (if the env var is not set) |
|-------|----------------------|-----------------------------------------------|
| Runtime lib folder (`AmtPsEclLib.psm1`, …) | `AMT_RT` | `..\..\Libraries` (relative to the wrapper) |
| `AmtSettings.xml` for the application | `AMT_SETTINGS` | `..\..\Settings\AmtSettings.xml` |

**Preferred: set `AMT_RT` / `AMT_SETTINGS`** for the job host — this is the robust option and removes any dependency on folder depth. The relative fallback is a convenience only: it resolves **solely** when the wrapper sits exactly two folders below the Libraries/Settings parent (wrapper in `…\Scripts\<GROUP>\RUN\`, libraries in `…\Scripts\Libraries\`, settings in `…\Scripts\Settings\`). A different deployment depth breaks the fallback **silently**, so on any non-standard layout set the two environment variables (see Required runtime setup, item 2).

The **body path is never hardcoded** — it is always taken from the live CC Script basepath (`$global:AmtPath.ScriptPath`, populated by `Initialize`). Moving the Script path in Control Center moves where the bodies are read from, with no script edit.

### Step 4 — One-time Windows hygiene on copied files
Any `.ps1` / `.psm1` copied between machines on Windows can pick up a `Zone.Identifier` (mark-of-the-web) stream that the BatchController host silently refuses to run. After copying, clear it:
```powershell
Get-ChildItem <ScriptPath> -Recurse -Include *.ps1,*.psm1 | Unblock-File
```
(See RELEASE-NOTES issue **T3-010**.)

### Step 5 — Register, secure, run
Register the wrapper jobs via **Control Center → Batch & Forms → Available Jobs → Read all jobs from system**, grant security rights, then **Start Job**. Register **only the wrapper** (`<KEY>-LIVE`) as the runnable entry — the body is invoked by the wrapper, not started directly.

---

## 4. Regenerating the wrappers

The wrappers are generated, not hand-written. To regenerate them (e.g. after re-seeding):
```powershell
pwsh -File 1_ConvertedScripts\Generate-Release-Wrappers.ps1
```
It reads `SgsSeeds\*.sgs-values.json` + `Bodies\<KEY>.ps1` and rewrites `Wrappers\<KEY>-LIVE.ps1`. The run is idempotent (byte-identical output on re-run).

---

## 5. Provenance — which source is "the" source

Across this programme there have been several copies of similarly-named programs. The `2_OriginalSource/` files in this release are the **exact inputs that were fed to the SsgConverter** to produce the `Bodies/` — i.e. the authoritative, converted-from source — taken from the converter's own `Examples/Input` set. The `<KEY>` in every folder ties the original, the converted body, the wrapper and the seed together as one provably-related set.

See **RELEASE-NOTES.md** for the converter build fingerprint, the test status of each program, and the per-program known issues.
