# SSG Conversion Trial — transfer package

Self-contained package for continuing the SSG-to-PowerShell conversion trial on a
new machine, independent of any AMT175/AMT172/AMT177 application source.

## Layout

| Folder | Contents |
|--------|----------|
| `SsgConverter/` | The SsgConverter tool release (build 8.0.26188.0, 2026-08-21) — C# source, prebuilt Console/GUI exes, examples, fix log. See [SsgConverter/README.md](SsgConverter/README.md). |
| `Trial3/` | The trial workspace (manifest-driven ECL/SSG-COBOL/PowerShell conversion pipeline). See [Trial3/README.md](Trial3/README.md). |
| `SSG-Source/` | Raw OS2200 SSG/COBOL source files used as trial input (copied from `2026-07-07_SSG/CreatingCobol`). |
| `docs/` | Supporting reference docs: SSG COBOL/ECL reference + command matrix, trial progress log, AMT175/AMT172 setup guides. |
| `.github/` | Copilot instructions/prompts carried over from the migration workspace. |

## Getting started

Open `SsgTrial.code-workspace` in VS Code. See `Trial3/README.md` for how to run the
pipeline, and `SsgConverter/README.md` for how to run the converter standalone.

Before first run on a new machine, update local paths in:
- `Trial3/config/pipeline.config.json` (converter exe path, SSG source path, GlobalCopyDir)
- `SsgConverter/Examples/Settings/SsgConverterSettings-example.settings`
