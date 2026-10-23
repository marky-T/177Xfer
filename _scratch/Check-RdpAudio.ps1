$since = (Get-Date).AddMinutes(-40)
$out = foreach ($log in 'Microsoft-Windows-RemoteDesktopServices-RdpCoreTS/Operational', 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational') {
  "== $log"
  Get-WinEvent -FilterHashtable @{ LogName = $log; StartTime = $since } -ErrorAction SilentlyContinue |
    Where-Object { $_.Message -match '(?i)audio|channel|logon|reconnect|connected' } |
    Select-Object -First 25 |
    ForEach-Object { $m = $_.Message -replace '\s+', ' '; '{0:HH:mm:ss} {1,5} {2}' -f $_.TimeCreated, $_.Id, $m.Substring(0, [Math]::Min(170, $m.Length)) }
}
$out | Set-Content E:\Repos\ssg4-work\rdp-audio-events.txt
