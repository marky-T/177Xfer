-- Copy of the database behind the first release (application AFBUS_2200COBOL_AMT, database definition 5) before it is replaced.
-- Writes one .bak file; changes nothing in the database. Run in SSMS as ava. The SQL Server service account must be able
-- to write to the folder; if it cannot, use a folder it can (for example the instance's default backup folder).
BACKUP DATABASE [AFBUS_2200COBOL_AMT]
  TO DISK = N'E:\AMT_Backup\AFBUS_2200COBOL_AMT_firstrelease.bak'
  WITH COPY_ONLY, INIT, CHECKSUM, STATS = 10;
GO
RESTORE VERIFYONLY FROM DISK = N'E:\AMT_Backup\AFBUS_2200COBOL_AMT_firstrelease.bak' WITH CHECKSUM;
GO
-- Restore later (only if the database itself was damaged), with nobody connected:
--   ALTER DATABASE [AFBUS_2200COBOL_AMT] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--   RESTORE DATABASE [AFBUS_2200COBOL_AMT] FROM DISK = N'E:\AMT_Backup\AFBUS_2200COBOL_AMT_firstrelease.bak' WITH REPLACE;
--   ALTER DATABASE [AFBUS_2200COBOL_AMT] SET MULTI_USER;
