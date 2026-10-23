$r = 'E:\AMT_Work\MockSystem\Run_VIRD03_L766'
$psi = [System.Diagnostics.ProcessStartInfo]::new('dotnet')
foreach ($a in "$r\MockSystemTool.dll", 'run', '--app', 'AFBUS_2200COBOL', '--ini', "$r\Sys.ini", '--dll', "$r\ASSURFED_UTILIT_FUSBA2_ASCII.dll") { $psi.ArgumentList.Add($a) }
$psi.WorkingDirectory = $r; $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true; $psi.RedirectStandardInput = $true; $psi.UseShellExecute = $false
$p = [System.Diagnostics.Process]::Start($psi)
$p.StandardInput.Close()
$o = $p.StandardOutput.ReadToEndAsync(); $e = $p.StandardError.ReadToEndAsync()
if (-not $p.WaitForExit(40000)) { 'TIMEOUT after 40 s - still running'; $p.Kill($true) }
'exit: ' + $p.ExitCode
'--- out'; $o.Result
'--- err'; $e.Result
