-- READ-ONLY diagnostics for the SSG-4 Control Center run (Step 8). Run in SSMS against FEDERALE_SYSTEM as ava.
-- Only SELECTs. Paste the result grids back; none of this contains passwords.
-- Table/column names marked (known) come from the Trial 1/2 registration SQL and the 2026-10-13 backup note;
-- everything else is discovered with TOP/SELECT * so no column name is guessed.
USE FEDERALE_SYSTEM;
SET NOCOUNT ON;

-- 1. Registered applications (known columns)
SELECT APPID, APPNAME, APPBASEPATH, APPLICATIONKIND, DATABASEID, CONFIGID, GUIADDRESS, AUTOSTART
FROM AMTSYSAPPLICATION ORDER BY APPID;

-- 2. Which job/queue/batch/service tables exist (names only)
SELECT name FROM sys.tables
WHERE name LIKE 'AMTSYS%JOB%' OR name LIKE 'AMTSYS%QUEUE%' OR name LIKE 'AMTSYS%BATCH%'
   OR name LIKE 'AMTSYS%SERVER%' OR name LIKE 'AMTSYS%SERVICE%' ORDER BY name;

-- 3. Available jobs of our application (known columns: APPID, JOBID, JOBNAME, DESCRIPTION, FILE, TYPE, QUEUEID)
SELECT AJ.* FROM AMTSYSAVAILABLEJOB AJ
JOIN AMTSYSAPPLICATION A ON A.APPID = AJ.APPID
WHERE A.APPNAME LIKE 'AFBUS_2200COBOL%' ORDER BY AJ.JOBID;

-- 4. Available jobs whose application no longer exists (these would be invisible in Control Center)
SELECT * FROM AMTSYSAVAILABLEJOB WHERE APPID NOT IN (SELECT APPID FROM AMTSYSAPPLICATION);

-- 5. Process jobs 30 and 31 (first column of AMTSYSPROCESSJOB is assumed to be the process job id)
SELECT name, column_id FROM sys.columns WHERE object_id = OBJECT_ID('AMTSYSPROCESSJOB') ORDER BY column_id;
DECLARE @c sysname = (SELECT TOP 1 name FROM sys.columns WHERE object_id = OBJECT_ID('AMTSYSPROCESSJOB') ORDER BY column_id);
EXEC('SELECT * FROM AMTSYSPROCESSJOB WHERE ' + @c + ' IN (30, 31)');

-- 6. Everything currently queued or running, whatever application it belongs to
EXEC('SELECT TOP 50 * FROM AMTSYSPROCESSJOB ORDER BY ' + @c + ' DESC');
