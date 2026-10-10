# AMT Migration Templates

Reusable scaffolding for COBOL → C# trial migrations. Copy and customise per-program.

## Layout

```
Templates\
├── README.md                           # This file
├── trial-pilot-template.ps1            # Pilot runner — copy one per program
├── trial-settings-template.json        # CobolConverterConsole .settings base
├── AmtSettings-template.xml            # Batch harness AmtSettings.xml base
├── Remove-SsgDirectives.ps1            # SSG stripper (authoritative copy — kept in sync with EclCobolPipeline\tools\)
└── trial-checklist.md                  # Per-program DoD checklist
```

## Quick start

1. Copy `trial-pilot-template.ps1` → `Trial3\tools\Run-Pilot-<PROGRAM>.ps1`
2. Fill in `$rawFile`, `$programId`, `$paramOverrides`, `$conditionValues`
3. Copy `trial-settings-template.json` → `Trial3\settings\trial-NN-<programid>.settings`; update `BatchDir` / `OutputFile`
4. Run the pilot; inspect candidate for residual `[token]` patterns
5. Follow `trial-checklist.md` to completion

## Works with

- **EclCobolPipeline** — AMT172 validated programs (Trial 2)
- **Trial3** — AMT175 SSG 2026-07-07 drop (20 programs)

## Authoritative reference

`C:\Amt\AMT_ReferenceDocuments\Migration\` — guides, patterns, lessons learned.
