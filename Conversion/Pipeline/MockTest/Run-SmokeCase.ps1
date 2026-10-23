<#
.SYNOPSIS
  Smoke run of one generated mock program: stages made-up input files from the SGS cards, runs the program in the isolated
  mock system and reports exit code, output files and the first error. There is NO reference output, so this only shows
  that the program loads, opens its files and runs to the end.
.DESCRIPTION
  Input files: one per INPUT card (<NAME>.DAT), fixed-length records of the card's length, ASCII, CRLF-ended. Each record is
  its zero-padded 8-digit number repeated across the record, so keys at any position ascend for fewer than 1000 records.
  Needs the mock file controller on 18132 (see Run-MockCase.ps1). Only touches E:\AMT_Work\MockSystem and E:\AMT_Work\MockTest.
.EXAMPLE
  pwsh -NoProfile -File Run-SmokeCase.ps1 -Case VIRD03_L766 -Application AFBUS_2200COBOL -Dll ASSURFED_UTILIT_FUSBA2_ASCII.dll -Cards E:\Repos\ssg4-work\sgs-cards\calls\ASSURFED_F999RUN-d_VIRD03__L766.sgs
#>
param(
  [Parameter(Mandatory)][String]$Case,
  [Parameter(Mandatory)][String]$Application,
  [Parameter(Mandatory)][String]$Dll,
  [Parameter(Mandatory)][String]$Cards,
  [String]$Binaries = 'E:\AMT_Work\Rebuild177a\AFBUS_2200COBOL\Binaries\Programs',
  [String]$RunnerBase = 'E:\AMT_Work\MockSystem\Run177',
  [Int32]$Records = 5,
  [Hashtable]$ExtraInputs = @{},
  [Int32]$TimeoutSeconds = 60
)
$ErrorActionPreference = 'Stop'
$sys = 'E:\AMT_Work\MockSystem'
$extract = 'E:\AMT_Work\MockTest\Extracts'
$runner = "$sys\Run_$Case"
if (-not (Get-NetTCPConnection -LocalPort 18132 -State Listen -ErrorAction SilentlyContinue)) { throw 'Mock file controller is not listening on 18132.' }

if (Test-Path $runner) { Remove-Item $runner -Recurse -Force }
robocopy $RunnerBase $runner /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
Copy-Item "$Binaries\$Dll" $runner -Force
Get-ChildItem $Binaries -Filter "$Application.*.dll" | Copy-Item -Destination $runner -Force
$ini = "$runner\Sys.ini"
dotnet "$runner\MockSystemTool.dll" seed-app --app $Application --ini $ini | Out-Null

Get-ChildItem $extract -File | Remove-Item -Force
$latin1 = [System.Text.Encoding]::GetEncoding('iso-8859-1')
$inputs = foreach ($line in Get-Content -LiteralPath $Cards) {
  if ($line -match '^\s*INPUT\s+(.*)$') { foreach ($m in [regex]::Matches($Matches[1], '(\w+),(\d+)(?:,\d+)?')) { [pscustomobject]@{ Name = $m.Groups[1].Value; Len = [Int32]$m.Groups[2].Value } } }
}
foreach ($in in $inputs) {
  $sb = [System.Text.StringBuilder]::new()
  for ($i = 1; $i -le $Records; $i++) {
    $rec = ('{0:D8}' -f $i) * [Math]::Ceiling($in.Len / 8)
    [void]$sb.Append($rec.Substring(0, $in.Len)).Append("`r`n")
  }
  [System.IO.File]::WriteAllBytes("$extract\$($in.Name).DAT", $latin1.GetBytes($sb.ToString()))
}
# prepared files, e.g. the data cards for a card reader (logical name -> file)
foreach ($k in $ExtraInputs.Keys) {
  Copy-Item $ExtraInputs[$k] "$extract\$k.DAT" -Force
  $inputs = @($inputs) + [pscustomobject]@{ Name = $k; Len = 80 }
}

$out = "$sys\smoke_$Case.out.txt"; $err = "$sys\smoke_$Case.err.txt"
$psi = [System.Diagnostics.ProcessStartInfo]::new('dotnet')
foreach ($a in "$runner\MockSystemTool.dll", 'run', '--app', $Application, '--ini', $ini, '--dll', "$runner\$Dll") { $psi.ArgumentList.Add($a) }
$psi.WorkingDirectory = $runner; $psi.UseShellExecute = $false
$psi.RedirectStandardInput = $true; $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true
$p = [System.Diagnostics.Process]::Start($psi)
$p.StandardInput.Close()
$o = $p.StandardOutput.ReadToEndAsync(); $e = $p.StandardError.ReadToEndAsync()
$timedOut = -not $p.WaitForExit($TimeoutSeconds * 1000)
if ($timedOut) { $p.Kill($true) }
$p.WaitForExit()
Set-Content $out $o.Result; Set-Content $err ($e.Result + $(if ($timedOut) { "TIMEOUT: killed after $TimeoutSeconds s" }))
$files = Get-ChildItem $extract -File | Where-Object { $inputs.Name -notcontains $_.BaseName } | ForEach-Object { '{0} ({1} bytes)' -f $_.Name, $_.Length }
$exit = (Get-Content $out | Where-Object { $_ -match 'exit code' } | Select-Object -Last 1)
$firstErr = (Get-Content $out, $err -ErrorAction SilentlyContinue | Where-Object { $_ -match 'ERROR|TIMEOUT|Exception' } | Select-Object -First 1)
[pscustomobject]@{
  Case = $Case; Inputs = ($inputs | ForEach-Object { "$($_.Name)/$($_.Len)" }) -join ' '
  Exit = $p.ExitCode; Program = $exit; NewFiles = ($files -join '; '); FirstError = $firstErr
}
