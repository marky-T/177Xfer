-- Removes the two orphaned process jobs (30, 31) left by the deleted application APPID 4 (first release, started 2026-09-25).
-- Control Center cannot show or remove them: their application no longer exists. Run in SSMS as ava against FEDERALE_SYSTEM.
-- Commits only if exactly 2 rows are deleted, otherwise rolls back. Never leaves a transaction open:
-- an open one holds locks on AMTSYSPROCESSJOB and blocks every BatchController status update (T3-038).
-- Their full row contents are in the 2026-10-20 Read-JobConfig output.
USE FEDERALE_SYSTEM;
SET NOCOUNT ON;
SET XACT_ABORT ON;

-- Batch requests 42 and 43 belong to these jobs; show them but do not delete (the BatchController may re-create what it needs).
SELECT * FROM AMTSYSBATCHREQUEST WHERE REQUESTID IN (42, 43);

BEGIN TRAN;

DELETE FROM AMTSYSPROCESSJOB
WHERE APPID = 4
  AND PROCESSJOBID IN (30, 31)
  AND APPID NOT IN (SELECT APPID FROM AMTSYSAPPLICATION);

DECLARE @deleted int = @@ROWCOUNT;
IF @deleted = 2
  BEGIN COMMIT TRAN; SELECT @deleted AS [deleted rows], 'COMMITTED' AS result; END
ELSE
  BEGIN ROLLBACK TRAN; SELECT @deleted AS [deleted rows], 'ROLLED BACK (expected 2)' AS result; END

SELECT @@TRANCOUNT AS [open transactions: must be 0];
