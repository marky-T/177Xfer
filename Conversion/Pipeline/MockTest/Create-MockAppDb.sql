-- Empty application database for the local mock run (the AMT application tables are created in it by the reorganize).
-- Reuses the existing LionDev login (no password here). Run in SSMS as ava (Trust server certificate).
-- Latin1_General_BIN is required for migrated mainframe applications (AMT installation training).
SET NOCOUNT ON;
GO
IF DB_ID(N'AMT_MOCKAPP') IS NOT NULL
  THROW 50001, 'AMT_MOCKAPP already exists. Nothing was changed.', 1;
GO
CREATE DATABASE [AMT_MOCKAPP] COLLATE Latin1_General_BIN;
GO
USE [AMT_MOCKAPP];
GO
CREATE USER [LionDev] FOR LOGIN [LionDev];
ALTER ROLE db_owner ADD MEMBER [LionDev];
GO
SELECT DB_NAME() AS database_name,
       CAST(DATABASEPROPERTYEX(N'AMT_MOCKAPP', 'Collation') AS varchar(60)) AS collation,
       (SELECT COUNT(*) FROM sys.tables) AS tables_in_it,
       IS_ROLEMEMBER('db_owner', 'LionDev') AS liondev_is_db_owner;
GO
