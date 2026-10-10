# Trial 3 - run ARCHISEPARE batch program in the AMT175 runtime.
# ARCHISEPARE: reads chercheuse, ficunload -> writes ficarchi, ficnarchi (sequential outputs).
# Run under pwsh 7.6.3 (.NET 10) - NOT powershell.exe 5.1.

$libDir = 'C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\EclConverter (1)\EclConverter\CmdLets'
Import-Module -Name (Join-Path $libDir 'AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop -ArgumentList $args
Import-Module -Name 'C:\Dev\amt-go-net-develop\Migration Tools\WflConverter\PsLibrary\AmtPsSortLib.psm1' -Force -DisableNameChecking -ErrorAction Stop -ArgumentList $args

$AmtSettingsFile = 'C:\Amt\Migration\Trial3\run\AmtSettings.xml'
$out1 = 'C:\Amt\Parallel\AMT175\Files\Extracts\AFBUS\FICARCHI\FICARCHI'
$out2 = 'C:\Amt\Parallel\AMT175\Files\Extracts\AFBUS\FICNARCHI\FICNARCHI'

Trap {
  HandleTrapAndAbort "Error trapped:" $_
}

Set-Jobname "ARCHISEPARE_RUN"
Initialize $AmtSettingsFile
Write-Host "=== Initialize OK ===" -ForegroundColor Green

Qual "" "AFBUS"
Asg "" "CHERCHEUSE"  # input file 1
Asg "" "FICUNLOAD"   # input file 2
Asg "" "FICARCHI"    # output file 1
Asg "" "FICNARCHI"   # output file 2
Xqt "" "ARCHISEPARE"
Write-Host "=== Xqt queued ===" -ForegroundColor Green

Start-Sleep -Seconds 5
Write-Host "Output files:"
if (Test-Path $out1) { "  FICARCHI: $((Get-Item $out1).Length) bytes" } else { "  FICARCHI: not created yet" }
if (Test-Path $out2) { "  FICNARCHI: $((Get-Item $out2).Length) bytes" } else { "  FICNARCHI: not created yet" }
