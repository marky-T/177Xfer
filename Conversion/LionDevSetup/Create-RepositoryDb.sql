-- LionDev repository database for the E:\Amt install (decision D9). Touches nothing else on the server.
-- Run as a login that may create databases, with the LionDev password in the environment variable
-- LIONDEV_PWD (sqlcmd substitutes it; it is never written into this file):
--   $env:LIONDEV_PWD = Read-Host 'LionDev password' -MaskInput
--   sqlcmd -S localhost -U ava -C -b -i Create-RepositoryDb.sql
--   Remove-Item Env:LIONDEV_PWD
-- Collation Latin1_General_BIN is required for migrated mainframe applications (AMT installation training).
--
-- In SSMS instead: connect with SQL Server Authentication as ava (Options > Connection Properties >
-- Trust server certificate), turn on Query > SQLCMD Mode, open this file, and add as the first line of the
-- window (do NOT save the file with the password in it):
--   :setvar LIONDEV_PWD "the-password-you-choose"
:on error exit
SET NOCOUNT ON;
GO
IF DB_ID(N'AMT_REPOS') IS NOT NULL
  THROW 50001, 'AMT_REPOS already exists. Nothing was changed.', 1;
GO
CREATE DATABASE [AMT_REPOS] COLLATE Latin1_General_BIN;
GO
IF SUSER_ID(N'LionDev') IS NULL
  CREATE LOGIN [LionDev] WITH PASSWORD = N'$(LIONDEV_PWD)', CHECK_POLICY = ON, DEFAULT_DATABASE = [AMT_REPOS];
GO
USE [AMT_REPOS];
GO
CREATE USER [LionDev] FOR LOGIN [LionDev];
ALTER ROLE db_owner ADD MEMBER [LionDev];
GO
SELECT DB_NAME() AS database_name,
       CAST(DATABASEPROPERTYEX(N'AMT_REPOS', 'Collation') AS varchar(60)) AS collation,
       (SELECT COUNT(*) FROM sys.tables) AS tables_in_it,
       (SELECT name FROM sys.database_principals WHERE name = N'LionDev') AS liondev_user,
       IS_ROLEMEMBER('db_owner', 'LionDev') AS liondev_is_db_owner;
GO
