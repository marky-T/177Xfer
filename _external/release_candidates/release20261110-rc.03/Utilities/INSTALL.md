# Install — release20261110-rc.03

The release is placed in the repository; it takes effect when the application is deployed. Verify the files against
`manifest.csv` first. Steps marked **CONFIRM** depend on answers from R&D (tracker MT-044, MT-046).

1. **Programs.** The projects in `BSP_AMT\Development\Utilities` are in `_All_.sln` (solution folder *Utilities*); `Build-And-Publish.ps1`
   builds them with the application into `BSP_AMT\Binaries\Programs\ASSURFED_UTILIT_*_GN.dll`. No separate step.
2. **Skeletons and includes — replaces R&D files, CONFIRM with R&D first (MT-046).** The converted runstreams call each skeleton by
   a fixed relative path (`Invoke-Ssg -Skeleton "../../ASSURFED_UTILIT/UTILIT_<X>"`). This release's skeletons have the same names
   as R&D's and carry the hand-off after `param()`, followed by `return`. `Scripts\ASSURFED_UTILIT` receives 16 skeletons
   and 12 includes. R&D has no `UTILIT_CHAB100_ASCII.ps1` (MT-045). Roll back: restore R&D's files from the previous commit.
3. **Settings — CONFIRM with R&D (MT-044).** `Scripts\Settings\AmtSettings.xml` receives the 12 `CloneReports` entries
   (Xqt name → generic program). `UseUnicode` must be `False` for the jobs that use these utilities (T3-039: `True` makes the runtime
   pre-create UTF-16 files). **CONFIRM** AppName in the same file: on main it was AFBUS_AMT (with UseUnicode True) when
   rc.02 was reviewed (2026-10-23), while the application is BSP; neither rc.02 nor this release changes them.
4. **Jobs.** After *Read all jobs from system*, Start Job also lists the `ASSURFED_UTILIT_*_GN` programs and the `UTILIT_*` skeletons.
   They are started only by a calling parent; started by hand they have no parameter file or cards. Leave them unactivated where possible.
5. **Check.** Run one real runstream that calls a converted utility (PROGRAM-SUMMARY Appendix A lists them). The job log shows the
   hand-off lines (`SSG-4 hand-off (...)`), then the child job named after the Xqt with the program's own report lines.
6. **ARCHIFORMAT:** do not run it against production tables until the table mapping is done (known issue MT-052).

**Roll back:** revert the release commit (skeletons, includes, settings entries, projects and the `_All_.sln` entries) and redeploy.
