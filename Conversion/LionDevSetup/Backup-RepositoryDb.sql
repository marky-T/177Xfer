-- Belt-and-braces copy of the 179 LionDev repository before the 177a switch. Read-only on the database; writes one .bak file.
-- Run in SSMS as ava. The SQL Server service account must be able to write to the folder; if it cannot, change the path
-- to one it can (for example the instance's default backup folder).
BACKUP DATABASE [AMT_REPOS]
  TO DISK = N'E:\AMT_Backup\AMT_REPOS_179.bak'
  WITH COPY_ONLY, INIT, CHECKSUM, STATS = 10;
GO
-- Proves the file is readable and complete (does not restore anything).
RESTORE VERIFYONLY FROM DISK = N'E:\AMT_Backup\AMT_REPOS_179.bak' WITH CHECKSUM;
GO
-- To restore later (only if the repository itself was damaged), from a window with nobody connected:
--   ALTER DATABASE [AMT_REPOS] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--   RESTORE DATABASE [AMT_REPOS] FROM DISK = N'E:\AMT_Backup\AMT_REPOS_179.bak' WITH REPLACE;
--   ALTER DATABASE [AMT_REPOS] SET MULTI_USER;
