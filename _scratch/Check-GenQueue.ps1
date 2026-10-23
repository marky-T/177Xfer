$ErrorActionPreference = 'Stop'
# Read-only look at the LionDev repository for generation queue / lock tables.
$cs = 'Server=VMFEDPE08;Database=AMT_REPOS177;Integrated Security=True;TrustServerCertificate=True;Connect Timeout=10'
$conn = New-Object System.Data.SqlClient.SqlConnection $cs
$conn.Open()
function Q([String]$sql) {
  $cmd = $conn.CreateCommand(); $cmd.CommandText = $sql; $cmd.CommandTimeout = 20
  $t = New-Object System.Data.DataTable; $t.Load($cmd.ExecuteReader()); $t
}
"== tables that look like generation/queue/lock"
$tables = Q "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE '%GEN%' OR TABLE_NAME LIKE '%QUEUE%' OR TABLE_NAME LIKE '%LOCK%' OR TABLE_NAME LIKE '%REQ%' OR TABLE_NAME LIKE '%JOB%' OR TABLE_NAME LIKE '%TASK%' ORDER BY TABLE_NAME"
$tables | Format-Table -AutoSize | Out-String -Width 200
foreach ($t in $tables.TABLE_NAME) {
  "== $t"
  $n = (Q "SELECT COUNT(*) AS N FROM [$t]").N
  "rows: $n"
  if ($n -gt 0 -and $n -le 50) { Q "SELECT TOP 20 * FROM [$t]" | Format-Table -AutoSize | Out-String -Width 300 }
}
$conn.Close()
