# SsgConverter — Release Package
## Build 8.0.26188.0 | Date 2026-08-21

Converts OS2200 SSG skeleton files (*IF/*SET/*DEFINE etc.) to PowerShell scripts
for use with the AMT PowerShell runtime.

---

## Quick Start

### Run with GUI (recommended)

cmd.exe:
  Build\Gui\SsgConverterGui.exe "Examples\Settings\SsgConverterSettings-example.settings"

PowerShell:
  & 'Build\Gui\SsgConverterGui.exe' 'Examples\Settings\SsgConverterSettings-example.settings'

### Run from console

  Build\Console\SsgConverterConsole.exe /SETTINGSFILE:"Examples\Settings\SsgConverterSettings-example.settings"

  Or with individual parameters:
  Build\Console\SsgConverterConsole.exe /INPUT:"<folder>" /OUTPUT:"<folder>" /CONTINUEONERROR:TRUE /VERBOSE:2 /ENABLELOGFILE:TRUE /LOGFILE:"<log-folder>"

---

## Prerequisites

- .NET SDK 10.0.x to BUILD from source (not needed to run pre-built binaries)
- To rebuild: dotnet build Source\SsgConverter.slnx -c Debug

---

## Package Contents

  Source\          Full C# source with all fixes applied
  Build\Console\   Pre-built SsgConverterConsole.exe (run without SDK)
  Build\Gui\       Pre-built SsgConverterGui.exe     (run without SDK)
  Examples\Input\  5 representative SSG source files
  Examples\Output\ Pre-generated .ps1 output for comparison
  Examples\Settings\  Example settings file (update paths before use)
  Fixes\           SsgConverter-Fix-20260820.md — full fix log

---

## Fixes Applied (vs original build 8.0.26188.0)

1+2  Deprecated *End accepted as *DEFINE / *DO block terminator
3    Unary sign with non-primitive operand emits (0 +/- expr) instead of throwing
4    Whitespace-only lines no longer crash the expression parser
5    Dash-separator strings (---) treated as literal strings
6    ECL pipeline crash on embedded COBOL content caught gracefully
7    GUI: file appender NullRef fixed; logger Start signal corrected
8    GUI: silent crashes replaced with MessageBox error display
9    GUI: settings pre-fill from command-line argument on launch
10   GUI: repeated Convert clicks no longer fail on locked log file
11   *MULTIPLY implemented; *REMOVE VARIABLE supported; *SORT multi-part key fixed
     Unrecognised directives emit warning + comment instead of failing the whole file
     IMPORTANT-WORKAROUND: *ITERATE on outer loop variable (see Fixes\ for R&D spec)

---

## Copilot Instructions

Open SsgConverter-COPILOT.md in your workspace or paste its contents into Copilot
chat to give the AI full context about this tool before asking questions.

---

## Known Issues (R&D)

- *ITERATE targeting outer loop: workaround applied, emits red warning in GUI log
  and PS comment in output. See Fixes\SsgConverter-Fix-20260820.md Fix 11 for spec.
- *DIVIDE GIVING quotient,remainder: pre-existing bug assigns modulo to wrong var.
- Mixed ECL+SSG+COBOL files: SSG portion converts correctly; ECL runstream is
  captured as comments (requires ECL converter integration for full conversion).
