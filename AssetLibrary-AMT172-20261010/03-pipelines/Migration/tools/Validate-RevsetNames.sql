-- =============================================================================
-- Validate-RevsetNames.sql
-- Run after ANY LionSource / LincToLion import into WORKING_REPOS.
--
-- Purpose:
--   Detect and fix object names in REVSET (and matching references in REVDATA)
--   that contain characters illegal in a C# namespace.
--   The generator takes REVSET.NAME verbatim -> namespace -> CheckNameSpace()
--   which only allows:  A-Z  a-z  0-9  _  .  -  (hyphen ok: RemoveMin converts to _)
--
-- Usage:
--   1. Set @AppName to the imported application name (e.g. 'TRIAL03MONTANT')
--   2. Run the whole script - it will DETECT, FIX, then REPORT any remaining issues
-- =============================================================================

DECLARE @AppName  NVARCHAR(100) = 'TRIAL03MONTANT';   -- <-- SET THIS
DECLARE @AppId    INT;

-- Resolve APPID
SELECT @AppId = OBJECTID FROM REVSET WHERE NAME = @AppName AND KIND = 913;

IF @AppId IS NULL
BEGIN
    RAISERROR('Application ''%s'' not found in REVSET (KIND=913). Check @AppName.', 16, 1, @AppName);
    RETURN;
END

PRINT 'AppId = ' + CAST(@AppId AS NVARCHAR);
PRINT '';

-- =============================================================================
-- STEP 1: DETECT — show all REVSET names with invalid chars before any fix
-- =============================================================================
PRINT '=== DETECT: REVSET names with invalid characters ===';

SELECT
    GENSETID,
    OBJECTID,
    KIND,
    NAME AS OriginalName,
    'REVSET' AS [Table]
FROM REVSET
WHERE APPID    = @AppId
  AND REVDELETED <> 'Y'
  AND NAME NOT LIKE ''   -- not empty
  AND NAME LIKE '%[^A-Za-z0-9_.\ -]%';  -- contains chars outside safe set

-- =============================================================================
-- STEP 2: FIX — strip COBOL type suffixes (P)/(F)/(S)/(SP)/(SB) entirely
--
-- IMPORTANT — do NOT rename to _P/_F/_S etc.
--   The generator does CobolApp.Sources.Find(objNameWm) after parsing.
--   The parser indexes each source under the PROGRAM-ID found in the COBOL
--   source code, which never contains the type suffix.
--   If REVSET/REVTREE name != PROGRAM-ID the Find() returns -1 and
--   generation fails with "Could not find source with name: <name>".
--
-- SSG / ECL NOTE:
--   SSG and ECL pipelines may further transform names (e.g. add _SSG, -ECL
--   prefixes/suffixes, or use a normalised form without hyphens).
--   After running this script, verify that each object name in REVSET matches
--   the PROGRAM-ID declared in its COBOL source (REVDATA LINENR=1 contains
--   the packed source; search for PROGRAM-ID. in the data).
--   If they still don't match after stripping suffixes, the name in REVSET
--   must be manually corrected to match the PROGRAM-ID exactly.
--
--   Applied longest-first to avoid (SP) being partially matched by (S) pass.
--   Applied to: REVSET, REVTREE, REVDATA (metadata Name= field).
-- =============================================================================
PRINT '';
PRINT '=== FIX: Strip COBOL type suffixes in REVSET ===';

UPDATE REVSET SET NAME =
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        NAME,
        '(SP)', ''),   -- must come before (S)
        '(SB)', ''),   -- must come before (S)
        '(P)',  ''),
        '(F)',  ''),
        '(S)',  ''))
WHERE APPID      = @AppId
  AND REVDELETED <> 'Y'
  AND NAME LIKE '%(%[A-Z]%)%';

PRINT CAST(@@ROWCOUNT AS NVARCHAR) + ' row(s) updated in REVSET (type suffixes stripped).';

PRINT '=== FIX: Strip COBOL type suffixes in REVTREE ===';

UPDATE REVTREE SET NAME =
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        NAME,
        '(SP)', ''),
        '(SB)', ''),
        '(P)',  ''),
        '(F)',  ''),
        '(S)',  ''))
WHERE APPID = @AppId
  AND NAME LIKE '%(%[A-Z]%)%';

PRINT CAST(@@ROWCOUNT AS NVARCHAR) + ' row(s) updated in REVTREE (type suffixes stripped).';

-- Also clear any checkout locks left over from failed generation attempts
UPDATE REVCONTROL SET LOCKED='N'
WHERE APPID   = @AppId
  AND LOCKED  = 'Y';

PRINT CAST(@@ROWCOUNT AS NVARCHAR) + ' checkout lock(s) cleared in REVCONTROL.';

-- =============================================================================
-- STEP 3: FIX — replace spaces with underscore in REVSET and REVTREE
-- =============================================================================
UPDATE REVSET SET NAME = REPLACE(NAME, ' ', '_')
WHERE APPID      = @AppId
  AND REVDELETED <> 'Y'
  AND NAME LIKE '% %';

PRINT CAST(@@ROWCOUNT AS NVARCHAR) + ' row(s) updated in REVSET (spaces).';

UPDATE REVTREE SET NAME = REPLACE(NAME, ' ', '_')
WHERE APPID = @AppId
  AND NAME LIKE '% %';

PRINT CAST(@@ROWCOUNT AS NVARCHAR) + ' row(s) updated in REVTREE (spaces).';

-- =============================================================================
-- STEP 4: FIX — mirror same replacements in REVDATA.DATALINE
--   REVDATA stores object names as part of data lines; invalid chars here
--   will cause compile-time failures when the generated code references them.
-- =============================================================================
PRINT '';
PRINT '=== FIX: Replace COBOL type suffixes in REVDATA ===';

UPDATE REVDATA SET DATALINE = CAST(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        CAST(DATALINE AS NVARCHAR(MAX)),
        '(SP)', ''),
        '(SB)', ''),
        '(P)',  ''),
        '(F)',  ''),
        '(S)',  ''))
    AS NVARCHAR(MAX))
WHERE APPID    = @AppId
  AND CAST(DATALINE AS NVARCHAR(MAX)) LIKE '%(%[A-Z]%)%';

PRINT CAST(@@ROWCOUNT AS NVARCHAR) + ' row(s) updated in REVDATA (type suffixes stripped).';

UPDATE REVDATA SET DATALINE = CAST(REPLACE(CAST(DATALINE AS NVARCHAR(MAX)), ' ', '_') AS NVARCHAR(MAX))
WHERE APPID    = @AppId
  AND CAST(DATALINE AS NVARCHAR(MAX)) LIKE '% %';

PRINT CAST(@@ROWCOUNT AS NVARCHAR) + ' row(s) updated in REVDATA (spaces).';

-- =============================================================================
-- STEP 5: REPORT REMAINING — anything still invalid needs manual attention
-- =============================================================================
PRINT '';
PRINT '=== REPORT: Names still containing invalid characters (manual review needed) ===';

SELECT
    GENSETID,
    OBJECTID,
    KIND,
    NAME AS CurrentName,
    'REVSET' AS [Table]
FROM REVSET
WHERE APPID      = @AppId
  AND REVDELETED <> 'Y'
  AND NAME LIKE '%[^A-Za-z0-9_.\ -]%';

-- =============================================================================
-- STEP 6: CONFIRM — show final state of all names for the app
-- =============================================================================
PRINT '';
PRINT '=== CONFIRM: All REVSET names for application ===';

SELECT
    GENSETID,
    OBJECTID,
    KIND,
    NAME
FROM REVSET
WHERE APPID      = @AppId
  AND REVDELETED <> 'Y'
ORDER BY KIND, NAME;

-- =============================================================================
-- STEP 7: REVGENSETDATA CHECK — warn if compiler parse index is empty
--
-- REVGENSETDATA is NOT populated by .LionSource import.
-- It is written only when Logic Status (LS) -> F7 (or Edit -> Check Syntax F8)
-- is run on each COBOL object. The generator's LionCobolSource.GetSource()
-- queries this table (OBJTYPE=19/36) at generation time; if it is empty the
-- lookup returns -1 and generation fails with:
--     "Could not find source with name: X"
-- even though the import completed successfully.
--
-- Fix: In LionDev, open Logic Status (type LS in Open box), Select All, press F7.
-- Wait for all objects to show a status before generating.
-- Reference: Step 12.7 in AMT172-Setup-Guide.html
-- =============================================================================
PRINT '';
PRINT '=== STEP 7: REVGENSETDATA presence check ===';

DECLARE @RevGenCount INT;
SELECT @RevGenCount = COUNT(*)
FROM REVGENSETDATA
WHERE APPID = @AppId;

PRINT 'REVGENSETDATA rows for this app: ' + CAST(@RevGenCount AS NVARCHAR);

IF @RevGenCount = 0
BEGIN
    PRINT '';
    PRINT '*** WARNING: REVGENSETDATA is EMPTY for this application. ***';
    PRINT '    The generator will fail with "Could not find source with name: X".';
    PRINT '    Fix: In LionDev, open Logic Status (type LS), Select All, press F7.';
    PRINT '    Wait for validation to complete before running Whole System generate.';
    PRINT '    See Bug #15 and Step 12.7 in AMT172-Setup-Guide.html.';
END
ELSE
BEGIN
    PRINT 'OK -- compiler parse index is populated. Safe to generate.';

    -- Show breakdown by OBJTYPE (19 = CobolSource, 36 = CobolCopy)
    SELECT
        OBJTYPE,
        COUNT(*) AS RowCount
    FROM REVGENSETDATA
    WHERE APPID = @AppId
    GROUP BY OBJTYPE
    ORDER BY OBJTYPE;
END
