WHAT THIS IS
  Phase 0 baseline of MT-068 (UseUnicode dual mode), taken 2026-11-13 16:27 before any pipeline change.
  Sources: E:\Repos\Federale_InternalRelease\AmtTools\Basepaths\Scripts\SSG4\Settings\AmtSettings.xml (CC-Trial, UseUnicode=False)
           E:\Repos\ssg4-work\generic\regress-results.csv and pipeline-regress-20261113-162617.txt (-Stage Regress -Status: 18/18 current PASS).
  Why: Phase 1 must deploy with False and give a settings file identical to this copy; regression results must stay unchanged.
  Tracker: MT-068 (plan .github\Copilot_Plans\261113-useunicode-dual-mode-plan.md).

CONTENTS (3 files + manifest, about 32 KB)
  AmtSettings.xml                      deployed CC-Trial settings (False) - 2728 bytes
  regress-results.csv                  regression results (False) - 25149 bytes
  pipeline-regress-20261113-162617.txt the -Status report (18/18 PASS)
  manifest.csv                         SHA256 of each file

WHERE IT MUST NOT GO
  Local work data of this VM; not into the repo or GitHub (AmtSettings.xml is an AMT product settings file).

SAFE TO DELETE WHEN
  Not before 2026-12-15, and only after MT-068 Phase 5 is done (False restored in CC-Trial and the
  tracker/release documents state which UseUnicode values are proven).

HOW TO DELETE
  Remove-Item -Recurse -Force 'E:\Repos\ssg4-work\generic\mt068-baseline-False'

ADDED 2026-11-13 17:01: cc-runs-LOADIS_cc-runs_ALL and cc-runs-ARCHIVE_cc-runs_SSG4_ARCHIVE_CASES = the per-utility check evidence of the
last False run (12 Nov), copied before the UseUnicode True run overwrote those fixed folders (MT-068 Phase 3).
