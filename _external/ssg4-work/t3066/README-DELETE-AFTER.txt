README-DELETE-AFTER.txt  (T3-066 / MT-069 / MT-070 scratch, 2026-11-16)

WHAT THIS IS
  Scratch work and pre-change backups for T3-066 and T3-070 (SsgConverter: literal @ ECL images), taken 261116 while
  logging and fixing the DB SSG probe findings (MT-069). Source paths backed up:
    E:\Repos\amt-go-net-ours\Migration Tools\SsgConverter\SsgConverter\SymstreamProcessor.cs  (patched 261116)
    E:\Repos\SsgTrial\SsgConverter\Trials\Tier1Mock\SsgPsMockLib.psm1                       (Asg/Use/Free added 261116)

CONTENTS (810 files, 32.4 MB)
  ours-SymstreamProcessor.before-T3-066.cs   backup: amt-go-net-ours file before the patch (hash 9FB1853B61AF)
  SsgPsMockLib.before-T3-066.psm1            backup: Tier-1 mock before Asg/Use/Free (also in git HEAD)
  SymstreamProcessor.T3-066.cs               patched file (hash 2350528DA43D)
  SymstreamExpressionParser.T3-070.cs        patched file (hash D60EF1D21F8A)
  ours-SymstreamExpressionParser.before-T3-070.cs  backup: amt-go-net-ours parser before T3-070 (hash C0E600BEC3BE)
  combined\                                  expected goldens after landing both fixes
  T3-066-SymstreamProcessor.diff             the change (+29/-3)
  Apply-T3-066-T3-070.ps1                    OWNER, elevated: lands T3-066 + T3-070 in SsgTrial and checks the goldens
  SsgConverter\  MOVED 2026-11-17 to E:\Temp\Archive_to_delete\ssg4-scratch-converters-261117\ (own README)
  before\ before-mock\ after\ after2\ after3\  example reconversions (after2 = T3-066 only)
  e2e\                                       EXTEUR real-call expansion + conversion with the fix
  skeleton-regen\                            all generic skeleton copies converted with live / control / T3-066 builds
  macros-proof\                              proof that each macros-file comment gives one warning
  Related build folders (not backups): E:\Repos\amt-go-net-ours\_build\EclConverterConsole-ours-T3066 and
  ...-T3066-control (209 files, 62.8 MB each). The live _build\EclConverterConsole-ours is untouched.
  No checksum manifest; hashes above.

WHERE IT MUST NOT GO
  The scratch converter copies (with vendor binaries) are no longer here; the rest may go to the 177Xfer backup.

SAFE TO DELETE WHEN (earliest 2026-12-16)
  - T3-066 is landed in SsgTrial (Apply-T3-066-T3-070.ps1 ran, goldens committed; T3-070 too), and
  - the skeleton copies are refreshed (MT-057) or EXTEUR's generic program is built, and
  - T3-066 is merged into R&D's version (MT-058) or the owner decides otherwise.
  Keep ours-SymstreamProcessor.before-T3-066.cs until the MT-058 merge is done.

HOW TO DELETE
  Remove-Item E:\Repos\ssg4-work\t3066 -Recurse -Force
  Remove-Item E:\Repos\amt-go-net-ours\_build\EclConverterConsole-ours-T3066-control -Recurse -Force
  (keep ...-T3066 until it is promoted or replaced by the MT-057 build)



RELATED SCRATCH (no backups, delete with this folder): E:\Repos\ssg4-work\t3070\ (T3-070 isolated proof: after\, expanded\ — expanded\ is used by Generic\RECAP\check\Test-RecapParm.ps1; its SsgConverter copy moved to the archive above).
