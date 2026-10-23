# Obsolete Statement Codes

The converted scripts contain comments marking statements from the original OS2200 ECL
runstreams that have no equivalent in the target environment. Each is tagged with a code
from the table below.

| Code | Applies to | Description |
|------|-----------|-------------|
| OBS-SCRATCH | @ASG/@FREE XA–XZ | OS2200 scratch file — temporary workspace allocated by the operating system. Not needed on Windows; the runtime manages temporary storage automatically. |
| OBS-SYSFILE | @ASG/@FREE R$CORE, SYS$.DLOC$ | OS2200 system file — internal operating system resource (core dump area, directory locator). No equivalent exists in the target environment. |
| OBS-TEMPFILE | @ASG/@FREE TPF$ | OS2200 temporary print file — used for spooling print output. The runtime handles print file management automatically. |
| OBS-PROGCOPY | @COPY with option A, O, R, or S | OS2200 program file element copy — options A, O, R, and S operate on program files (compiled COBOL, executable elements). The AMT runtime cannot copy program file elements; programs are deployed as .NET assemblies instead. |

## Example

```powershell
# @ASG T XA.,F///100 - obsolete [OBS-SCRATCH]
```

These lines are safe to leave in place (they are comments) or can be removed.
