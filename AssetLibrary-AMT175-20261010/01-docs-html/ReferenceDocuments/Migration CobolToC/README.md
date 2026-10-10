# AMT Migration Reference — Index

Authority reference documentation for the COBOL → C# trial migration pipeline.
Working templates (scripts, settings) are in `C:\Amt\Migration\Templates\`.

| Document | Purpose |
|----------|---------|
| [Trial-Setup-Guide.md](Trial-Setup-Guide.md) | Step-by-step trial setup from SSG source to LionSource |
| [converter-settings-guide.md](converter-settings-guide.md) | CobolConverterConsole `.settings` field reference |
| [batch-harness-patterns.md](batch-harness-patterns.md) | AmtPsEclLib, AmtSettings.xml, BatchController patterns |
| [SSG-ECL-PowerShell-Reference.html](../../Migration/SSG-ECL-PowerShell-Reference.html) | Tool runbook (Trial 2); extend for Trial 3 (do not overwrite) |

## Pipeline overview

```
Raw SSG/COBOL source (.TXT)
    └─ Remove-SsgDirectives.ps1   (paramOverrides + conditionValues)
           └─ clean COBOL candidate (.TXT)
                  └─ CobolConverterConsole <settings>
                         └─ .LionSource
                                └─ LionDev import → F7 Logic Status → Generate C#
```

## Authoritative tool locations (verified 2026-08-18)

| Tool | Path | Notes |
|------|------|-------|
| Remove-SsgDirectives.ps1 | `C:\Amt\Migration\Templates\Remove-SsgDirectives.ps1` | Authoritative; synced from EclCobolPipeline |
| CobolConverterConsole (v8.0.26125.50) | `C:\Dev\amt-go-net-net8\Migration Tools\CobolToAmt\CobolConverterConsole\bin\Debug\net8.0\CobolConverterConsole.exe` | Use this version; 260728 produces 0 objects |
| SsgConverterConsole (v8.0.26188.0) | `C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\SsgConverter\...\bin\Debug\net10.0\SsgConverterConsole.exe` | SSG → PowerShell stream ONLY; crashes on CreatingCobol input |
| Run-EclPipeline.ps1 | `C:\Amt\Migration\Trial3\tools\` | Manifest-driven orchestrator |
| Run-EclProof.ps1 | `C:\Amt\Migration\Trial3\tools\` | Proof harness |

## Source drops

| Drop | Path | Programs |
|------|------|---------|
| Codedrop 2025 (Trial 2) | `C:\Amt\MainframeSource\Codedrop 2025\AB Suite Sources\` | 16 programs |
| 2026-07-07 SSG (Trial 3) | `C:\Amt\MainframeSource\2026-07-07_SSG\CreatingCobol\` | 20 programs |
| CopyPrd (shared copybooks) | `C:\Amt\MainframeSource\Codedrop 2025\CopyPrd\` | Both trials |

## Known gotchas

1. **BOM bug (bug#14):** CobolConverterConsole chokes on UTF-8 BOM in column 1 → 0 objects output.
   Fix: rewrite candidate file BOM-free after `Remove-SsgDirectives.ps1`.
   `[System.IO.File]::WriteAllText($path, $text, (New-Object System.Text.UTF8Encoding($false)))`

2. **Variant mismatch:** Trial 2 overlap programs may differ from 2026-07-07 drop.
   Always diff source files before reusing Trial 2 overrides or fixtures.

3. **SsgConverter wrong tool:** `SsgConverterConsole` converts SSG *symstream* → PowerShell.
   Running it against `CreatingCobol` SSG-parameterized COBOL → CRASH.

4. **Multiline regex in PS5.1:** Use `[regex]::Replace(..., [RegexOptions]::Singleline)` not `-replace`.
