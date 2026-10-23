-- Empty AMT system database for the local mock run (never the Federale FEDERALE_SYSTEM). Reuses the existing LionDev login,
-- so no password is needed here. Run in SSMS connected as ava (Trust server certificate), or:
--   sqlcmd -S localhost -U ava -C -b -i Create-MockSystemDb.sql
-- Latin1_General_BIN is required for migrated mainframe applications (AMT installation training).
SET NOCOUNT ON;
GO
IF DB_ID(N'AMT_MOCKSYS') IS NOT NULL
  THROW 50001, 'AMT_MOCKSYS already exists. Nothing was changed.', 1;
GO
IF SUSER_ID(N'LionDev') IS NULL
  THROW 50002, 'Login LionDev does not exist. Nothing was changed.', 1;
GO
CREATE DATABASE [AMT_MOCKSYS] COLLATE Latin1_General_BIN;
GO
USE [AMT_MOCKSYS];
GO
CREATE USER [LionDev] FOR LOGIN [LionDev];
ALTER ROLE db_owner ADD MEMBER [LionDev];
GO
SELECT DB_NAME() AS database_name,
       CAST(DATABASEPROPERTYEX(N'AMT_MOCKSYS', 'Collation') AS varchar(60)) AS collation,
       (SELECT COUNT(*) FROM sys.tables) AS tables_in_it,
       IS_ROLEMEMBER('db_owner', 'LionDev') AS liondev_is_db_owner;
GO
