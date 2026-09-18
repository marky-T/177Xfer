<#
.SYNOPSIS
  Repeatable Tier-1 (mock-shell) trial runner for a SsgConverter-generated PowerShell script.
.DESCRIPTION
  Loads SsgPsMockLib.psm1, seeds the mocked SGS parameter table from a per-program
  sgs-values.json, invokes the SsgConverter Examples/Output/<Program>.ps1 script, and
  captures every DataLineOrNoStatement-emitted line to Trials/<Program>/out/<Program>.out.txt.
  Idempotent: each run resets all mock state and overwrites the output file.
.PARAMETER Program
  Program key under SsgConverter/Trials/<Program>/ (also the .ps1 base filename under Examples/Output).
.EXAMPLE
  .\Run-SsgPsTrial.ps1 -Program ARCHISEPARE
.EXAMPLE
  .\Run-SsgPsTrial.ps1 -Program CFH-COPY -Diff
#>

param(
  [Parameter(Mandatory=$true)][String]$Program,
  [String]$ScriptPath,
  [String]$ValuesFile,
  [String]$OutDir,
  [Switch]$Diff
)

$ErrorActionPreference = "Stop"
$here = $PSScriptRoot
$trialsRoot = Split-Path $here -Parent
$ssgConverterRoot = Split-Path $trialsRoot -Parent

if (-not $ScriptPath) { $ScriptPath = Join-Path $ssgConverterRoot "Examples\Output\$Program.ps1" }
if (-not $ValuesFile) { $ValuesFile = Join-Path $trialsRoot "$Program\sgs-values.json" }
if (-not $OutDir)     { $OutDir     = Join-Path $trialsRoot "$Program\out" }

if (-not (Test-Path $ScriptPath)) { throw "Script not found: $ScriptPath" }
if (-not (Test-Path $ValuesFile)) { throw "SGS value table not found: $ValuesFile" }

Import-Module (Join-Path $here "SsgPsMockLib.psm1") -Force -DisableNameChecking

$rawValues = Get-Content $ValuesFile -Raw | ConvertFrom-Json
$values = @{}
foreach ($prop in $rawValues.PSObject.Properties) {
  if ($prop.Name -eq "_source") { continue }
  $values[$prop.Name] = $prop.Value
}

Reset-SgsMock -Values $values

if (-not (Test-Path $OutDir)) { New-Item -Path $OutDir -ItemType Directory | Out-Null }
$outFile = Join-Path $OutDir "$Program.out.txt"
$errFile = Join-Path $OutDir "$Program.error.txt"
if (Test-Path $errFile) { Remove-Item $errFile -Force -ErrorAction SilentlyContinue }

Write-Host "=== Tier-1 trial: $Program ===" -ForegroundColor Cyan
Write-Host "Script : $ScriptPath"
Write-Host "Values : $ValuesFile ($($values.Count) mocked keys)"

$failed = $false
$errorMessage = $null
try {
  & $ScriptPath -Parameters @()
} catch {
  $failed = $true
  $errorMessage = $_.Exception.Message + "`r`n" + $_.InvocationInfo.PositionMessage
  Set-Content -Path $errFile -Value $errorMessage
}

$emitted = $global:EmittedLines
Set-Content -Path $outFile -Value $emitted

Write-Host "Emitted lines   : $($emitted.Count)"
Write-Host "Unmocked GetSgsValue lookups: $($global:SgsMockWarnings.Count)"
foreach ($w in $global:SgsMockWarnings) { Write-Host "  - $w" -ForegroundColor DarkYellow }
Write-Host "Call-ExternalProgram calls  : $($global:ExternalCalls.Count)"
foreach ($c in $global:ExternalCalls) { Write-Host "  - $c" -ForegroundColor DarkGray }

if ($failed) {
  Write-Host "RESULT: FAILED - script threw during execution" -ForegroundColor Red
  Write-Host $errorMessage -ForegroundColor Red
  Write-Host "(partial output up to failure point written to $outFile)"
} else {
  Write-Host "RESULT: completed without a thrown exception" -ForegroundColor Green
}

if ($Diff) {
  $goldenCandidates = Get-ChildItem -Path (Join-Path $trialsRoot "..\..\Trial3\candidates") -Filter "*$Program*" -Directory -Recurse -ErrorAction SilentlyContinue
  if ($goldenCandidates) {
    foreach ($dir in $goldenCandidates) {
      $goldenFiles = Get-ChildItem -Path $dir.FullName -File
      foreach ($g in $goldenFiles) {
        Write-Host "--- diff vs $($g.FullName) ---" -ForegroundColor Cyan
        $goldenLines = Get-Content $g.FullName
        Compare-Object -ReferenceObject $goldenLines -DifferenceObject $emitted | Format-Table -AutoSize
      }
    }
  } else {
    Write-Host "No Trial3 candidate found matching '$Program' to diff against." -ForegroundColor DarkYellow
  }
}

return [PSCustomObject]@{
  Program  = $Program
  Failed   = $failed
  Error    = $errorMessage
  OutFile  = $outFile
  LineCount = $emitted.Count
}
