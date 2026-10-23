-- Empty LionDev repository database for AMT 177a (the 179 repository AMT_REPOS is left untouched). Reuses the existing
-- LionDev login, so no password is needed here. Run in SSMS as ava (Trust server certificate).
-- Latin1_General_BIN is required for migrated mainframe applications (AMT installation training).
SET NOCOUNT ON;
GO
IF DB_ID(N'AMT_REPOS177') IS NOT NULL
  THROW 50001, 'AMT_REPOS177 already exists. Nothing was changed.', 1;
GO
IF SUSER_ID(N'LionDev') IS NULL
  THROW 50002, 'Login LionDev does not exist. Nothing was changed.', 1;
GO
CREATE DATABASE [AMT_REPOS177] COLLATE Latin1_General_BIN;
GO
USE [AMT_REPOS177];
GO
CREATE USER [LionDev] FOR LOGIN [LionDev];
ALTER ROLE db_owner ADD MEMBER [LionDev];
GO
SELECT DB_NAME() AS database_name,
       CAST(DATABASEPROPERTYEX(N'AMT_REPOS177', 'Collation') AS varchar(60)) AS collation,
       (SELECT COUNT(*) FROM sys.tables) AS tables_in_it,
       IS_ROLEMEMBER('db_owner', 'LionDev') AS liondev_is_db_owner;
GO
-- Undo (only if the 177a attempt is abandoned and you want the database gone):
--   USE master; ALTER DATABASE [AMT_REPOS177] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [AMT_REPOS177];
