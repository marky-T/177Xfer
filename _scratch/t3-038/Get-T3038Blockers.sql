-- T3-038: read-only. Run while a script job is stuck in Running (before any restart).
-- Needs VIEW SERVER STATE (e.g. a sysadmin login in SSMS). Changes nothing.
SET NOCOUNT ON;

-- 1) Sessions with an open transaction, oldest first: who, which process, what they last ran.
SELECT s.session_id, s.login_name, s.host_name, s.program_name, s.host_process_id,
       s.status, s.open_transaction_count, s.last_request_end_time,
       DB_NAME(s.database_id) AS db, t.transaction_begin_time,
       LEFT(REPLACE(REPLACE(st.text, CHAR(13), ' '), CHAR(10), ' '), 300) AS last_sql
FROM sys.dm_exec_sessions s
JOIN sys.dm_tran_session_transactions sst ON sst.session_id = s.session_id
JOIN sys.dm_tran_active_transactions t ON t.transaction_id = sst.transaction_id
LEFT JOIN sys.dm_exec_connections c ON c.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) st
WHERE s.is_user_process = 1
ORDER BY t.transaction_begin_time;

-- 2) Exclusive/update locks held, per session and table (run in the AMT system database).
SELECT l.request_session_id AS session_id, l.resource_type, l.request_mode, l.request_status,
       OBJECT_NAME(COALESCE(p.object_id, CASE WHEN l.resource_type = 'OBJECT' THEN l.resource_associated_entity_id END)) AS table_name,
       COUNT(*) AS locks
FROM sys.dm_tran_locks l
LEFT JOIN sys.partitions p ON p.hobt_id = l.resource_associated_entity_id
WHERE l.resource_database_id = DB_ID() AND l.request_mode IN ('X', 'IX', 'U', 'IU', 'SIX')
GROUP BY l.request_session_id, l.resource_type, l.request_mode, l.request_status,
         OBJECT_NAME(COALESCE(p.object_id, CASE WHEN l.resource_type = 'OBJECT' THEN l.resource_associated_entity_id END))
ORDER BY session_id, table_name;
