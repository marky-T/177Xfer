<#
.SYNOPSIS
  Runs one generated mock program in the isolated mock system and compares its output with the independent reference.
.DESCRIPTION
  Per case (a folder under E:\AMT_Work\MockTest with input\ and expected\, made by New-CopyMockTest.ps1):
  builds a runner folder (copy of Run\ plus the case's generated DLLs), stages the input as <NAME>.DAT in the mock
  extract folder, runs the program through MockSystemTool and compares the <NAME>.DAT it wrote.
  Needs the mock file controller running (E:\AMT_Work\MockSystem\FC\AmtFileController.exe /VS /N:MockFileController).
  Only touches E:\AMT_Work\MockSystem and E:\AMT_Work\MockTest; the tool itself refuses any database but AMT_MOCKSYS.
.EXAMPLE
  pwsh -NoProfile -File Run-MockCase.ps1 -Case PBDA04_L545 -Application CFHCOPYASCIIPBDA04L545 -Cards E:\Repos\ssg4-work\sgs-cards\calls\ASSURFED_F999RUN_PBDA04__L545.sgs
#>
param(
  [Parameter(Mandatory)][String]$Case,
  [Parameter(Mandatory)][String]$Application,
  [Parameter(Mandatory)][String]$Cards,
  [String]$Dll = 'CFH_COPY.dll',
  [String]$Binaries = 'E:\AMT_Work\Apps\Binaries\Programs',
  [String]$Records = '',
  [String]$RunnerBase = 'E:\AMT_Work\MockSystem\Run',
  [Switch]$UseExistingRunner
)
$ErrorActionPreference = 'Stop'
$mock = 'E:\AMT_Work\MockTest'
$sys = 'E:\AMT_Work\MockSystem'
$extract = "$mock\Extracts"
$caseDir = "$mock\$Case"
$runner = "$sys\Run_$Case"
$here = $PSScriptRoot

# the file controller must be up
if (-not (Get-NetTCPConnection -LocalPort 18132 -State Listen -ErrorAction SilentlyContinue)) { throw 'Mock file controller is not listening on 18132. Start FC\AmtFileController.exe /VS /N:MockFileController first.' }

# runner folder: copy of Run\ plus the DLLs generated for this application
if (-not $UseExistingRunner -or -not (Test-Path $runner)) {
  robocopy $RunnerBase $runner /MIR /NFL /NDL /NJH /NJS /NP | Out-Null
  Copy-Item "$Binaries\$Dll" $runner -Force
  Get-ChildItem $Binaries -Filter "$Application.*.dll" | Copy-Item -Destination $runner -Force
}

# register the application if the mock system does not know it yet
$ini = "$runner\Sys.ini"
dotnet "$runner\MockSystemTool.dll" seed-app --app $Application --ini $ini | Select-String 'Registered|already' | ForEach-Object { $_.Line }

# test data: make it if missing, then stage the input as <NAME>.DAT
if (-not (Test-Path "$caseDir\input")) {
  $extra = @(); if ($Records) { $extra = '-Records', $Records }
  pwsh -NoProfile -File "$here\New-CopyMockTest.ps1" -Cards $Cards -OutDir $caseDir @extra | Out-Null
}
$in = Get-ChildItem "$caseDir\input" -File | Select-Object -First 1
$exp = Get-ChildItem "$caseDir\expected" -File | Select-Object -First 1
Get-ChildItem $extract -File | Remove-Item -Force
Copy-Item $in.FullName "$extract\$($in.Name).DAT"

# run
$out = "$sys\run_$Case.out.txt"; $err = "$sys\run_$Case.err.txt"
$p = Start-Process -FilePath dotnet -ArgumentList "`"$runner\MockSystemTool.dll`"", 'run', '--app', $Application, '--ini', "`"$ini`"", '--dll', "`"$runner\$Dll`"" `
  -WorkingDirectory $runner -RedirectStandardOutput $out -RedirectStandardError $err -NoNewWindow -PassThru -Wait
Get-Content $out | Where-Object { $_ -match 'ERROR|Done|Failed|exit code' } | ForEach-Object { "  $_" }
$actual = "$extract\$($exp.Name).DAT"
if (-not (Test-Path $actual)) { "FAIL  $Case : no output file $($exp.Name).DAT (exit $($p.ExitCode))"; exit 1 }
pwsh -NoProfile -File "$here\New-CopyMockTest.ps1" -Cards $Cards -OutDir $caseDir -Actual $actual | ForEach-Object { "$Case : $_" }
exit $LASTEXITCODE
