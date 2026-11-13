WHAT THIS IS
  MT-068 Phase 2 proof (2026-11-13): every regress step's checks re-run WITHOUT Control Center against the job logs and outputs of
  the last recorded run (12 Nov 2026, UseUnicode False), once with the old checks (before\) and once with the encoding-aware checks
  (after\: GnOutputCompare.ps1 in Test-CcJob, Test-CcPrints, Check-LoadisCc, Check-LoadisAll, Check-ArchiveCc).
  Result: same exit code for all 19 steps; 24 of 230 report files differ in text only (evidence folder name, new 'PRN encodings' line,
  new 'first difference' lines for the CONDIS2S failures already known from T3-059). Tracker: MT-068.
  Note: SCANGRP prints and LOADIS_ABORT UNSORTED fail in BOTH replays because later jobs on 12 Nov added/overwrote files; CONDIS2S's
  last real run (5 Nov) failed (T3-059). These are replay limits, not regressions.

CONTENTS (2.5 MB)
  before\<step>\   job.txt, check.txt, prints\, own\ - old checks
  after\<step>\    the same with the new checks
  before\summary.txt, after\summary.txt   exit codes per step
  Replay-RegressChecks.ps1                the driver (run: pwsh -File Replay-RegressChecks.ps1 -Out <folder>)

WHERE IT MUST NOT GO
  Copies of CC outputs and job logs (test data): local work data of this VM, not into the repo or GitHub.

SAFE TO DELETE WHEN
  Not before 2026-12-15, and only after MT-068 Phase 5 is done.

HOW TO DELETE
  Remove-Item -Recurse -Force 'E:\Repos\ssg4-work\generic\mt068-recheck'
