$ErrorActionPreference = 'Continue'
foreach ($d in Get-ChildItem E:\Amt -Directory -Force) {
  $tmp = $d.Name + '_locktest'
  try {
    Rename-Item $d.FullName $tmp -ErrorAction Stop
    Rename-Item (Join-Path 'E:\Amt' $tmp) $d.Name -ErrorAction Stop
    '{0,-12} free (renamed and restored)' -f $d.Name
  } catch {
    '{0,-12} LOCKED: {1}' -f $d.Name, $_.Exception.Message
    if (Test-Path (Join-Path 'E:\Amt' $tmp)) { Rename-Item (Join-Path 'E:\Amt' $tmp) $d.Name }
  }
}
'--- files under E:\Amt that cannot be opened for exclusive access (Restart Manager would name the owner)'
$locked = Get-ChildItem E:\Amt -Recurse -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
  try { $fs = [System.IO.File]::Open($_.FullName, 'Open', 'ReadWrite', 'None'); $fs.Close() } catch { $_.FullName }
} | Select-Object -First 10
if ($locked) { $locked } else { 'none' }
