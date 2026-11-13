# Handback — MT-068 UseUnicode spike done (261113) → parent release process (rc.03 / rc.04)

For the **release session** (rc.03 / ADO tickets). Paste the block below as a message there. Source: the MT-068 session
(plan `.github\Copilot_Plans\261113-useunicode-dual-mode-plan.md`, tracker rows MT-068, T3-065, T3-039).

## Paste this into the release session

> MT-068 (UseUnicode spike) is finished. Three settings were tested in Control Center: the AMT setting `UseUnicode` in AmtSettings.xml (True and False, all 18 regression jobs + CONDIS2S), and the LionDev application options "Define Unicode for all extract files" and "Define Unicode for all print files" (each on and off, on CFH_COPY_GN and SCAN_GN, then both off again and the proven builds restored hash-identical). Read `E:\Repos\ssg4-work\handback-mt068-useunicode-261113.md` and pick up the markers
> below. Summary:
>
> **Result.** The generic programs work with `UseUnicode=True` and `False`. All 18 regression jobs pass under True (13 Nov 18:33);
> False stays proven (12 Nov 18/18, still current). Under True only Asy-Cat pre-created outputs are UTF-16 (VIRM01: decoded equal,
> CR LF present; T3-039's "no CR LF" was wrong and is corrected); all other outputs are 8-bit, byte-identical. The T3-059 merge rule
> (CONDIS2S 33/36, LECTIS KEYIMAGE) and the T3-040 padding (BABA 11/11) do not depend on UseUnicode.
>
> **New build-time finding.** LionDev "Define Unicode for all extract files" sets the runtime `unicode` flag on every file of a
> program. With it on, every extract output of a generic program is UTF-16 (8-bit inputs and the hand-off's SGSPARM are still
> read correctly). "Define Unicode for all print files" changes nothing: AMT 177 generates every print file as Unicode anyway.
> BSP has both options off today. The released programs take the BSP application's value, so MT-046 now has **two** values to
> confirm: `UseUnicode` in the target's AmtSettings.xml **and** BSP's "Define Unicode for all extract files".
>
> **rc.03 — recut?** No code recut. The spike changed no program, hand-off or skeleton (CFH_COPY_GN/SCAN_GN were tried with the
> option on and restored hash-identical). One documentation correction: `release20261112-rc.03\Utilities\INSTALL.md` says
> "`UseUnicode` must be `False` … (T3-039)". That is superseded: both values are proven, and main's settings ship True (rc.03's
> placement leaves it as is, which is now a proven setting). Owner to decide: amend INSTALL.md in rc.03 (docs only, no
> rebuild), or carry the correction into rc.04.
>
> **Markers to pick up.**
> 1. rc.04 (owner decision 261113): run the False regression once (`-Stage Deploy -UseUnicode False`, the 18 jobs, then
>    `-Stage Deploy` back to True). CC-Trial's profile default is now **True**; CC-Federale/Repo-BSP/Mock stay False until MT-046.
> 2. Before packaging rc.04: `-Stage Package` from CC-Trial now defaults to True (results from `regress-results-unicode.csv`,
>    RELEASE-NOTES names the value), but its INSTALL text and `New-GnReleaseDocs.ps1` still say "UseUnicode must be False" and the
>    docs read `regress-results.csv` (False) only. Update both to state the two proven values, the extract option's effect,
>    and which results file they list; or package with `-UseUnicode False`.
> 3. Testing task 120437 (ADO): add the result (both values proven; the extract option makes outputs UTF-16) and the
>    second R&D confirmation (BSP extract option) next to UseUnicode.
> 4. T3-065 (fixed): the test-only CONDIS2S program was never rebuilt after the MT-063 rename. Lesson for any renamed or new
>    program: after Deliver, CC needs System Configuration → AvailableJobs → Read all jobs (that application) and Security →
>    Jobs → activate, or the Xqt fails with "Report [...] not found".
> 5. CC note: Start Job lists the SSG4 jobs under two applications (FEDERALE_APP and AFBUS_2200COBOL_AMT); `ccStartJob` only
>    finds a job under the selected application filter.
> 6. BSP regeneration seen 13 Nov 17:27 (17 objects): BSP still holds 6 old-named `Assurfed_Utilit_*_Gn` objects next to the
>    new names; worth tidying before rc.04.
>
> **Runbook updated** (`docs\SSG4-ControlCenter-Runbook.html`): tab 2 pipeline (`-UseUnicode`, box "UseUnicode and the LionDev Unicode options" `#s-unicode`, Deliver step 4 register/activate, Regress results per value, two-application Start Job filter), tab 3 run card 2026-11-13, tab 5 run-time rules (3 new rows).
>
> **Pipeline changes (commit `f7a595c` on SsgTrial `main`).** `-UseUnicode True|False` on Deploy/Regress/Package (value in every report);
> True results in `regress-results-unicode.csv` / `regress-unicode\`; a job is recorded only if the deployed settings carry the
> run's value; encoding-aware compares (new shared `GnOutputCompare.ps1`: 8-bit byte for byte, UTF-16 decoded and reported
> `PASS decoded UTF-16…`); per-utility checks take `-Evidence`. Low-risk notes in the plan (no-BOM UTF-16 heuristic; LOADIS index
> check with a UTF-16 data file).

## Local work folders (each has README-DELETE-AFTER, not before 261215)

`E:\Repos\ssg4-work\generic\mt068-baseline-False` (Phase 0 copies + False per-utility evidence), `mt068-recheck` (Phase 2
offline replay), `mt068-phase6-before` (restore point), `mt068-phase6-extract-on`, `mt068-phase6\` (Phase 6 evidence).
