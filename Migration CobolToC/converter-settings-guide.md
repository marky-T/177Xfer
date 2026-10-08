# CobolConverterConsole Settings Reference

**Tool:** `CobolConverterConsole.exe` (v8.0.26125.50)  
**Path:** `C:\Dev\amt-go-net-net8\Migration Tools\CobolToAmt\CobolConverterConsole\bin\Debug\net8.0\CobolConverterConsole.exe`  
**Usage:** `CobolConverterConsole <settings-file.settings>`

> ⚠ **Use v8.0.26125.50 only.** The 260728 build produces 0 objects. Do not upgrade without testing.

## Key fields in `AppList[0]`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `AppName` | string | Yes | AMT application name, e.g. `AFBUS_COBOL` |
| `BatchDir` | string | Yes | Directory containing the clean COBOL candidate `.TXT` file |
| `OutputFile` | string | Yes | Full path to the output `.LionSource` file |
| `GlobalCopyDir` | string | Yes | Path to shared copybooks: `C:\Amt\MainframeSource\Codedrop 2025\CopyPrd` |
| `IsSelected` | bool | Yes | Must be `true` |

## Key top-level settings

| Field | Default | Notes |
|-------|---------|-------|
| `OutputInAscii` | `true` | Always `true` for ASSURFED programs |
| `UseCobolAnalyser` | `true` | Required for OS2200 COBOL |
| `DontIncludeFolderNames` | `true` | Prevents path prefixes in generated object names |
| `WriteAppDef` | `true` | Writes `<APPDEF>` block to output |
| `WriteGlbFileDefs` | `true` | Writes file definitions |
| `WriteInsertables` | `true` | Writes insertable sections |
| `WritePerformables` | `true` | Writes performable sections |
| `WriteGlobalDefs` | `true` | Writes global definitions |
| `WriteCreatedObjects` | `true` | Writes COBOL PROGRAM objects |

## Fields to leave at default

`LionVersion: null`, `FormType: -1`, `Env: 4096`, `SequenceNumberAction: 0`,  
`CbSequenceNumbers: 0`, all other boolean fields → `false`

## Template

Use `C:\Amt\Migration\Templates\trial-settings-template.json` as base.  
Only update: `AppName`, `BatchDir`, `OutputFile`, `GlobalCopyDir`.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| 0 objects in output | UTF-8 BOM in candidate col 1 (bug#14) | Rewrite file BOM-free before converting |
| 0 objects in output | Wrong CobolConverterConsole version (260728) | Use the 260505 build (v8.0.26125.50) |
| `File not found` | `BatchDir` path wrong or candidate not `.TXT` | Verify path; ensure candidate has `.TXT` extension |
| `GlobalCopyDir` warnings | Copybooks not found | Verify `C:\Amt\MainframeSource\Codedrop 2025\CopyPrd` exists |
