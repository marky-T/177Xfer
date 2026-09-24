# AMT177 Runtime transfer — build 8.0.26230.0

Full AMT 8.0.26230.0 release drop, transferred to fix the AMT177 `MissingMethodException`
on `Asysco.Amt.Runtime.Skeleton.AmtBaseCobolProgram..ctor` (compile-side 177 7-param ctor
vs deployed 177a 5-param ctor).

## Why it's split
Two files exceed GitHub's 100 MB per-file hard limit, so they were chopped into <90 MB
`.partNNN` pieces (plain binary split, no archive tool):
- `AMT_177.dat` (258 MB)
- `Release_8.0.26230.0.7z` (268 MB)

Every other file was copied as-is. `MANIFEST.json` lists each file with its size, SHA256,
and part count.

## Reassemble on the VM
```powershell
cd AMT177-Runtime-8.0.26230.0
pwsh -File .\Reassemble.ps1
```
Rejoins the split files, copies the rest, and verifies every file's SHA256.
Output lands in `.\Reassembled\8.0.26230.0\`. No 7-Zip required for this step.

## What to do with it (the actual fix)
The reassembled tree is a standard AMT release: `Setup.exe` + `.7z` component archives.
For the ctor fix specifically, extract **`YDrive_C#.7z`** — it's the 177a-generation
`Amt.Net` C# source tree — then point the Y: drive at it and rebuild the report:
```powershell
subst Y: <extracted-Amt.Net-folder>
# rebuild the report .csproj  -> now compiles against 177a's 5-param ctor
# redeploy via ProdInstall.exe / PInstall.exe
```

## Caveat — 7-Zip may be blocked
7-Zip was blocked by Avanade Endpoint Privilege Management on the source machine
("Vulnerable Version Blocked"). If the same policy is on the VM, extracting `YDrive_C#.7z`
(or any `.7z`) needs either the AMT `Setup.exe` install path or a Workstation Compliance
Exception. Reassembly itself does NOT need 7-Zip.
