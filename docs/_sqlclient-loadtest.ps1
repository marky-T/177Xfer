param([string]$DllFolder)
Set-Location $DllFolder
$dll = Join-Path $DllFolder 'Microsoft.Data.SqlClient.dll'
Write-Host "Loading: $dll"
try {
  Add-Type -Path $dll
  Write-Host "Add-Type OK"
  $cs = "Server=localhost;Database=master;Integrated Security=true;Connect Timeout=2;Encrypt=false"
  $conn = New-Object Microsoft.Data.SqlClient.SqlConnection($cs)
  $conn.Open()
  Write-Host "CONNECT OK"
  $conn.Close()
} catch {
  $e = $_.Exception
  $depth = 0
  while ($e) {
    Write-Host ("[$depth] " + $e.GetType().FullName + ": " + $e.Message)
    if ($e -is [System.Reflection.ReflectionTypeLoadException]) {
      foreach ($le in $e.LoaderExceptions) { Write-Host ("   LoaderException: " + $le.Message) }
    }
    $e = $e.InnerException
    $depth++
  }
}
