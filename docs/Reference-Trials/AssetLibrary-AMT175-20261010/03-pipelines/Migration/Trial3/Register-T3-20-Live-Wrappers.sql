-- Register the 18 auto-generated *-LIVE.ps1 wrappers (Generate-T3-Live-Wrappers.ps1) as CC jobs.
-- JOBID 1060/1061 (CFH-COPY-LIVE, HelloWorld-LIVE) already exist; this continues from 1062.
SET IDENTITY_INSERT AMTSYSAVAILABLEJOB ON;

INSERT INTO AMTSYSAVAILABLEJOB (APPID, JOBID, JOBNAME, DESCRIPTION, [FILE], TYPE, QUEUEID) VALUES
(5, 1062, 'T3_20_ARCHIFORMAT_LIVE',      'T3 live skeleton-wrapped run - standalone PASS', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\ARCHIFORMAT-LIVE.ps1', 1, 1),
(5, 1063, 'T3_20_ARCHISEPARE_LIVE',      'T3 live skeleton-wrapped run - standalone PASS', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\ARCHISEPARE-LIVE.ps1', 1, 1),
(5, 1064, 'T3_20_BABA_ASCII_LIVE',       'T3 live skeleton-wrapped run - standalone PASS', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\BABA_ASCII-LIVE.ps1', 1, 1),
(5, 1065, 'T3_20_CFH_COPY_ASCII_LIVE',   'T3 live skeleton-wrapped run - standalone PASS', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\CFH-COPY_ASCII-LIVE.ps1', 1, 1),
(5, 1066, 'T3_20_CHAB100_ASCII_LIVE',    'T3 live skeleton-wrapped run - standalone PASS', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\CHAB100_ASCII-LIVE.ps1', 1, 1),
(5, 1067, 'T3_20_CHABAN_ASCII_LIVE',     'T3 live skeleton-wrapped run - standalone PASS', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\CHABAN_ASCII-LIVE.ps1', 1, 1),
(5, 1068, 'T3_20_CONDIS2_ASCII_LIVE',    'T3 live skeleton-wrapped run - standalone PASS (needed Log-Message stub)', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\CONDIS2_ASCII-LIVE.ps1', 1, 1),
(5, 1069, 'T3_20_EXTEUR_LIVE',           'T3 live skeleton-wrapped run - standalone FAIL (SGS value NONE -> Int32)', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\EXTEUR-LIVE.ps1', 1, 1),
(5, 1070, 'T3_20_FUSBA_ASCII_LIVE',      'T3 live skeleton-wrapped run - standalone FAIL (null array in Define_limpara)', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\FUSBA_ASCII-LIVE.ps1', 1, 1),
(5, 1071, 'T3_20_FUSBA2_ASCII_LIVE',     'T3 live skeleton-wrapped run - standalone PASS', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\FUSBA2_ASCII-LIVE.ps1', 1, 1),
(5, 1072, 'T3_20_LECTIS_ASCII_LIVE',     'T3 live skeleton-wrapped run - standalone PASS', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\LECTIS_ASCII-LIVE.ps1', 1, 1),
(5, 1073, 'T3_20_LOADIS_ASCII_LIVE',     'T3 live skeleton-wrapped run - standalone PASS', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\LOADIS_ASCII-LIVE.ps1', 1, 1),
(5, 1074, 'T3_20_LOADIS_MULTI_LIVE',     'T3 live skeleton-wrapped run - standalone PASS', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\LOADIS_MULTI-LIVE.ps1', 1, 1),
(5, 1075, 'T3_20_RECAP_LIVE',            'T3 live skeleton-wrapped run - standalone PASS (needed Log-Message stub)', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\RECAP-LIVE.ps1', 1, 1),
(5, 1077, 'T3_20_SCAN_ASCII_LIVE',       'T3 live skeleton-wrapped run - standalone PASS', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\SCAN_ASCII-LIVE.ps1', 1, 1),
(5, 1078, 'T3_20_TABAN_ASCII_LIVE',      'T3 live skeleton-wrapped run - standalone PASS (needed Log-Message stub)', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\TABAN_ASCII-LIVE.ps1', 1, 1),
(5, 1079, 'T3_20_TAPELD_ASCII_LIVE',     'T3 live skeleton-wrapped run - standalone PASS (needed Log-Message stub)', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\TAPELD_ASCII-LIVE.ps1', 1, 1),
(5, 1080, 'T3_20_UNLOADIS_ASCII_LIVE',   'T3 live skeleton-wrapped run - standalone PASS', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\UNLOADIS_ASCII-LIVE.ps1', 1, 1),
(5, 1081, 'T3_20_UNLOADIS_MULTI_LIVE',   'T3 live skeleton-wrapped run - standalone PASS', 'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\UNLOADIS_MULTI-LIVE.ps1', 1, 1);

SET IDENTITY_INSERT AMTSYSAVAILABLEJOB OFF;

SELECT JOBID, JOBNAME, [FILE] FROM AMTSYSAVAILABLEJOB WHERE JOBID >= 1062 ORDER BY JOBID;
