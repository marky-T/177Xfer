# Trial 3 - run LOADIS_ASCII batch program in the AMT175 runtime.
# LOADIS_ASCII: reads BDE[1..N] (sequential input files) -> writes DISQ (indexed output).
# Run under pwsh 7.6.3 (.NET 10) - NOT powershell.exe 5.1.

$libDir = 'C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\EclConverter (1)\EclConverter\CmdLets'
Import-Module -Name (Join-Path $libDir 'AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop -ArgumentList $args
Import-Module -Name 'C:\Dev\amt-go-net-develop\Migration Tools\WflConverter\PsLibrary\AmtPsSortLib.psm1' -Force -DisableNameChecking -ErrorAction Stop -ArgumentList $args

$AmtSettingsFile = 'C:\Amt\Migration\Trial3\run\AmtSettings.xml'
$out = 'C:\Amt\Parallel\AMT175\Files\Extracts\AFBUS\DISQ\DISQ'

Trap {
  HandleTrapAndAbort "Error trapped:" $_
}

Set-Jobname "LOADIS_ASCII_RUN"
Initialize $AmtSettingsFile
Write-Host "=== Initialize OK ===" -ForegroundColor Green

Qual "" "AFBUS"
Asg "" "BDE1"      # sequential input file 1
Asg "" "DISQ"      # indexed output file
Xqt "" "LOADIS-ASCII"
Write-Host "=== Xqt queued ===" -ForegroundColor Green

Start-Sleep -Seconds 5
if (Test-Path $out) { "OUTPUT: $((Get-Item $out).Length) bytes"; Get-Content $out -TotalCount 5 } else { "no DISQ yet (BatchController may still be running)" }
