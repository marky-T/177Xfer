WHAT THIS IS
  MT-068 Phase 6 restore point, taken 2026-11-13 before the owner switches LionDev "Define Unicode for all extract/print files" on in
  AFBUS_2200COBOL and regenerates CFH-COPY-GN and SCAN-GN. Holds the proven (option off) state of those two programs.
CONTENTS (manifest.csv has SHA256 of every file)
  app-dll\      CFH_COPY_GN.* and SCAN_GN.* from E:\Repos\AMT\Apps\AFBUS_2200COBOL_AMT\Binaries\Programs (what CC-Trial runs)
  liondev-cs\   Cfh_Copy_Gn, Scan_Gn generated C# from E:\AMT_Work\Apps177\Development\Programs
  rebuild-cs\   the same from the 177a rebuild tree E:\AMT_Work\Rebuild177a-spike\AFBUS_2200COBOL\Development\Programs
  rebuild-dll\  CFH_COPY_GN.*, SCAN_GN.* from the rebuild tree's Binaries\Programs
RESTORE
  Copy app-dll\* back to the application Programs folder (and rebuild-dll\* to the rebuild tree), elevated; or switch the option off,
  regenerate the two programs and Deliver again. Then re-run SSG4_*_CFH_COPY and SSG4_SCANGRP_PRINTS.
WHERE IT MUST NOT GO
  Product binaries and generated code of the trial application: local only, not into the repo or GitHub.
SAFE TO DELETE WHEN
  Not before 2026-12-15, and only after Phase 6 is finished and CC-Trial's CFH_COPY_GN/SCAN_GN are the proven builds again.
HOW TO DELETE
  Remove-Item -Recurse -Force 'E:\Repos\ssg4-work\generic\mt068-phase6-before'
