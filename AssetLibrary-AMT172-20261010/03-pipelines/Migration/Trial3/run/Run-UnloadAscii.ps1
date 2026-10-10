# Trial 3 - run UNLOAD-ASCII in the AMT175 runtime via AmtPsEclLib (no ApplicationCenter).
# Matches the "ECL to PowerShell" doc skeleton: Set-Jobname -> Initialize -> Asg -> Xqt.
# Set $env:T3_CONNECT_ONLY=1 to stop after Initialize (connection test).

$libDir = 'C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\EclConverter (1)\EclConverter\CmdLets'
Import-Module -Name (Join-Path $libDir 'AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop -ArgumentList $args
# Initialize calls Sort-Init (from AmtPsSortLib); the AMT175 extract lacked it - use the develop clone copy.
Import-Module -Name 'C:\Dev\amt-go-net-develop\Migration Tools\WflConverter\PsLibrary\AmtPsSortLib.psm1' -Force -DisableNameChecking -ErrorAction Stop -ArgumentList $args

$AmtSettingsFile = 'C:\Amt\Migration\Trial3\run\AmtSettings.xml'
$out = 'C:\Amt\Migration\Trial3\run\FICHOUT-1.dat'

Trap {
  HandleTrapAndAbort "Error trapped:" $_
}

# --- Body ---
Set-Jobname "UNLOAD_ASCII_RUN"
Initialize $AmtSettingsFile
Write-Host "=== Initialize OK (connected to runtime) ===" -ForegroundColor Green

Qual "" "AFBUS"
Write-Host "ExtractPath = [$global:ExtractPath]" -ForegroundColor Yellow
Write-Host "QualPath    = [$global:QualPath]" -ForegroundColor Yellow

if ($env:T3_CONNECT_ONLY -eq '1') { Write-Host "ConnectOnly - stop before Asg/Xqt."; return }

Asg "" "FICHIN-1"
Asg "" "FICHOUT-1"
Xqt "" "UNLOAD-ASCII"
Write-Host "=== Xqt queued ===" -ForegroundColor Green
if (Test-Path $out) { "OUT bytes: $((Get-Item $out).Length)"; Get-Content $out -TotalCount 10 }
