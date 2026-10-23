# Obsolete Statement Codes

The converted scripts contain comments marking statements from the original OS2200 ECL
runstreams that have no equivalent in the target environment. Each is tagged with a code
from the table below.

| Code | Applies to | Description |
|------|-----------|-------------|
| OBS-PROGCOPY | @COPY with option A, O, R, or S | OS2200 program file element copy — options A, O, R, and S operate on program files (compiled COBOL, executable elements). The AMT runtime cannot copy program file elements; programs are deployed as .NET assemblies instead. |

## Example

```powershell
# @ASG T XA.,F///100 - obsolete [OBS-SCRATCH]
```

These lines are safe to leave in place (they are comments) or can be removed.
