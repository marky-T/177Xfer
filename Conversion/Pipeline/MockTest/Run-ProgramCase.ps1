<#
.SYNOPSIS
  Runs one generated program on prepared input files and compares one output file byte for byte with an expected file.
.DESCRIPTION
  -Inputs   hashtable logical-name -> file (copied to <NAME>.DAT in the mock extract folder; an existing '<file>.Index' goes along as <NAME>.DAT.Index)
  -ExpectedName / -ExpectedFile   the output file the program must write (<NAME>.DAT) and what it must contain
  Needs the mock file controller (MockFc.ps1: Start-MockFc), the 177a runner and the rebuilt set.
  Returns an object: Case, Result (PASS/FAIL/ERROR), Exit, Detail, plus -KeepOutputAs to save a named output file (for round trips).
#>
param(
  [Parameter(Mandatory)][String]$Case,
  [Parameter(Mandatory)][String]$Dll,
  [Parameter(Mandatory)][Hashtable]$Inputs,
  [String]$ExpectedName,
  [String]$ExpectedFile,
  [String]$KeepOutputAs,
  [String]$KeepOutputTo,
  [String]$Application = 'AFBUS_2200COBOL',
  [String]$Binaries = 'E:\AMT_Work\Rebuild177a\AFBUS_2200COBOL\Binaries\Programs',
  [String]$RunnerBase = 'E:\AMT_Work\MockSystem\Run177',
  [Int32]$TimeoutSeconds = 60
)
$ErrorActionPreference = 'Stop'
$sys = 'E:\AMT_Work\MockSystem'; $extract = 'E:\AMT_Work\MockTest\Extracts'
if (-not (Get-NetTCPConnection -LocalPort 18132 -State Listen -ErrorAction SilentlyContinue)) { throw 'Mock file controller is not listening on 18132.' }
$runner = "$sys\Run_$Case"
if (Test-Path $runner) { Remove-Item $runner -Recurse -Force }
robocopy $RunnerBase $runner /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
Copy-Item "$Binaries\$Dll" $runner -Force
Get-ChildItem $Binaries -Filter "$Application.*.dll" | Copy-Item -Destination $runner -Force
$ini = "$runner\Sys.ini"
dotnet "$runner\MockSystemTool.dll" seed-app --app $Application --ini $ini | Out-Null

Get-ChildItem $extract -File | Remove-Item -Force
foreach ($k in $Inputs.Keys) {
  Copy-Item $Inputs[$k] "$extract\$k.DAT" -Force
  if (Test-Path "$($Inputs[$k]).Index") { Copy-Item "$($Inputs[$k]).Index" "$extract\$k.DAT.Index" -Force }
}

$psi = [System.Diagnostics.ProcessStartInfo]::new('dotnet')
foreach ($a in "$runner\MockSystemTool.dll", 'run', '--app', $Application, '--ini', $ini, '--dll', "$runner\$Dll") { $psi.ArgumentList.Add($a) }
$psi.WorkingDirectory = $runner; $psi.UseShellExecute = $false
$psi.RedirectStandardInput = $true; $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true
$p = [System.Diagnostics.Process]::Start($psi); $p.StandardInput.Close()
$o = $p.StandardOutput.ReadToEndAsync(); $e = $p.StandardError.ReadToEndAsync()
$timedOut = -not $p.WaitForExit($TimeoutSeconds * 1000); if ($timedOut) { $p.Kill($true) }; $p.WaitForExit()
$log = ($o.Result + $e.Result)
Set-Content "$sys\case_$Case.log" $log
$err = ($log -split "`n" | Where-Object { $_ -match 'ERROR|Exception' } | Select-Object -First 1)

if ($KeepOutputAs -and (Test-Path "$extract\$KeepOutputAs.DAT")) {
  Copy-Item "$extract\$KeepOutputAs.DAT" $KeepOutputTo -Force
  if (Test-Path "$extract\$KeepOutputAs.DAT.Index") { Copy-Item "$extract\$KeepOutputAs.DAT.Index" "$KeepOutputTo.Index" -Force }
}
$res = [ordered]@{ Case = $Case; Result = 'ERROR'; Exit = $p.ExitCode; Detail = '' }
if ($timedOut) { $res.Detail = "timed out after $TimeoutSeconds s" }
elseif ($p.ExitCode -ne 0) { $res.Detail = "program exit $($p.ExitCode): $err" }
elseif ($ExpectedName) {
  $actual = "$extract\$ExpectedName.DAT"
  if (-not (Test-Path $actual)) { $res.Detail = "no output file $ExpectedName.DAT" }
  else {
    $a = [System.IO.File]::ReadAllBytes($actual); $x = [System.IO.File]::ReadAllBytes($ExpectedFile)
    $first = -1; $n = [Math]::Min($a.Length, $x.Length)
    for ($i = 0; $i -lt $n; $i++) { if ($a[$i] -ne $x[$i]) { $first = $i; break } }
    if ($first -lt 0 -and $a.Length -eq $x.Length) { $res.Result = 'PASS'; $res.Detail = "$ExpectedName.DAT matches the expected file ($($a.Length) bytes)" }
    else { $res.Result = 'FAIL'; $res.Detail = "actual $($a.Length) bytes, expected $($x.Length); first difference at byte $(if ($first -lt 0) { $n } else { $first })" }
  }
} else { $res.Result = 'PASS'; $res.Detail = 'ran to exit 0 (no expected file given)' }
[pscustomobject]$res
