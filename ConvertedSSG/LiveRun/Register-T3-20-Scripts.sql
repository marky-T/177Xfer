SET NOCOUNT ON;

-- T3 20-program bundle: register as TYPE=1 Script jobs under AFBUS_2200COBOL (APPID 5).
-- Physical location mirrors the DLL convention (Binaries\Reports\) as Binaries\Scripts\.
-- Execution status is embedded in DESCRIPTION so it's visible directly in the CC job list —
-- per the AMT177/178 bundle: 19/20 are tier1-only (mock-shell), CFH-COPY is tier1+stagea;
-- NONE have completed a live Connect-Application run yet.

SET IDENTITY_INSERT AMTSYSAVAILABLEJOB ON;

INSERT INTO AMTSYSAVAILABLEJOB (APPID, JOBID, JOBNAME, DESCRIPTION, [FILE], TYPE, QUEUEID) VALUES
(5, 1020, 'T3_20_ARCHIFORMAT',     'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\ARCHIFORMAT.ps1', 1, 1),
(5, 1021, 'T3_20_ARCHISEPARE',     'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\ARCHISEPARE.ps1', 1, 1),
(5, 1022, 'T3_20_BABA_ASCII',      'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\BABA_ASCII.ps1', 1, 1),
(5, 1023, 'T3_20_CFH_COPY',        'T3 20-pgm bundle - tier1+stagea, no live run',     'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\CFH-COPY.ps1', 1, 1),
(5, 1024, 'T3_20_CFH_COPY_ASCII',  'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\CFH-COPY_ASCII.ps1', 1, 1),
(5, 1025, 'T3_20_CHAB100_ASCII',   'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\CHAB100_ASCII.ps1', 1, 1),
(5, 1026, 'T3_20_CHABAN_ASCII',    'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\CHABAN_ASCII.ps1', 1, 1),
(5, 1027, 'T3_20_CONDIS2_ASCII',   'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\CONDIS2_ASCII.ps1', 1, 1),
(5, 1028, 'T3_20_EXTEUR',          'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\EXTEUR.ps1', 1, 1),
(5, 1029, 'T3_20_FUSBA2_ASCII',    'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\FUSBA2_ASCII.ps1', 1, 1),
(5, 1030, 'T3_20_FUSBA_ASCII',     'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\FUSBA_ASCII.ps1', 1, 1),
(5, 1031, 'T3_20_LECTIS_ASCII',    'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\LECTIS_ASCII.ps1', 1, 1),
(5, 1032, 'T3_20_LOADIS_ASCII',    'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\LOADIS_ASCII.ps1', 1, 1),
(5, 1033, 'T3_20_LOADIS_MULTI',    'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\LOADIS_MULTI.ps1', 1, 1),
(5, 1034, 'T3_20_RECAP',           'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\RECAP.ps1', 1, 1),
(5, 1035, 'T3_20_SCAN_ASCII',      'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\SCAN_ASCII.ps1', 1, 1),
(5, 1036, 'T3_20_TABAN_ASCII',     'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\TABAN_ASCII.ps1', 1, 1),
(5, 1037, 'T3_20_TAPELD_ASCII',    'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\TAPELD_ASCII.ps1', 1, 1),
(5, 1038, 'T3_20_UNLOADIS_ASCII',  'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\UNLOADIS_ASCII.ps1', 1, 1),
(5, 1039, 'T3_20_UNLOADIS_MULTI',  'T3 20-pgm bundle - tier1-only, no live run',       'C:\Amt\Working\Apps\AFBUS_2200COBOL\Binaries\Scripts\UNLOADIS_MULTI.ps1', 1, 1);

SET IDENTITY_INSERT AMTSYSAVAILABLEJOB OFF;

SELECT JOBID, JOBNAME, TYPE, QUEUEID, APPID FROM AMTSYSAVAILABLEJOB WHERE JOBID BETWEEN 1020 AND 1039 ORDER BY JOBID;
