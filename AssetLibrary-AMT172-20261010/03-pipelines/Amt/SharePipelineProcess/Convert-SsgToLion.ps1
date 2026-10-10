<#
.SYNOPSIS
  Option A pipeline wrapper: SSG pre-process → CobolConverterConsole.

.DESCRIPTION
  1. Reads BatchDir from the .settings JSON
  2. For each .txt file in RawSourceDir, runs Remove-SsgDirectives.ps1
     and writes the cleaned file to BatchDir
  3. Runs CobolConverterConsole.exe <SettingsFile>
  4. Reports output file size and location

  This is the "Option A" (external PowerShell) integration — no GUI required.

.PARAMETER SettingsFile
  Path to the .settings JSON file for this trial.
  BatchDir in AppList[0] must point to the pre-processed candidate folder.

.PARAMETER RawSourceDir
  Folder containing the raw SSG-COBOL .txt files.
  If omitted, BatchDir is assumed already pre-processed and Step 1 is skipped.

.PARAMETER ConsolePath
  Full path to CobolConverterConsole.exe.
  Defaults to the Debug/net8.0 build in the local workspace.

.EXAMPLE
  # Pre-process from raw SSG folder, then convert:
  .\Convert-SsgToLion.ps1 `
    -SettingsFile "C:\Amt\Migration\CobolConvert\settings\trial-03-montant.settings" `
    -RawSourceDir "C:\Amt\MainframeSource\Codedrop 2025\SSG Prd\SSG Creating COBOL"

.EXAMPLE
  # Candidate folder already pre-processed manually — just run the converter:
  .\Convert-SsgToLion.ps1 `
    -SettingsFile "C:\Amt\Migration\CobolConvert\settings\trial-03-montant.settings"
#>
param(
    [Parameter(Mandatory)][string]$SettingsFile,
    [string]$RawSourceDir = '',
    [string]$ConsolePath  = 'C:\Dev\amt-go-net-net8\Migration Tools\CobolToAmt\CobolConverterConsole\bin\Debug\net8.0\CobolConverterConsole.exe',
    [hashtable]$ParamOverrides   = @{},   # [TOKEN]=value overrides for inline COBOL substitution
    [hashtable]$ConditionValues  = @{}    # PARAM=value for *IF branch evaluation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent

# ── Validate inputs ───────────────────────────────────────────────────────────
if (-not (Test-Path $SettingsFile)) {
    Write-Error "Settings file not found: $SettingsFile"
    exit 1
}
if (-not (Test-Path $ConsolePath)) {
    Write-Error "CobolConverterConsole.exe not found: $ConsolePath"
    exit 1
}

# ── Read BatchDir from settings JSON ──────────────────────────────────────────
$settings = Get-Content $SettingsFile -Raw | ConvertFrom-Json
$batchDir = $settings.AppList[0].BatchDir
if (-not $batchDir) {
    Write-Error "No BatchDir in settings AppList[0]"
    exit 1
}

Write-Host ""
Write-Host "=== Convert-SsgToLion (Option A) ===" -ForegroundColor Cyan
Write-Host "Settings  : $SettingsFile"
Write-Host "BatchDir  : $batchDir"
Write-Host "Console   : $ConsolePath"
Write-Host ""

# ── Step 1: SSG Pre-processing ────────────────────────────────────────────────
if ($RawSourceDir) {
    if (-not (Test-Path $RawSourceDir)) {
        Write-Error "RawSourceDir not found: $RawSourceDir"
        exit 1
    }

    $preprocessor = Join-Path $ScriptDir 'Remove-SsgDirectives.ps1'
    if (-not (Test-Path $preprocessor)) {
        Write-Error "Pre-processor script not found: $preprocessor"
        exit 1
    }

    # Create BatchDir if it doesn't exist
    if (-not (Test-Path $batchDir)) {
        New-Item -ItemType Directory -Force $batchDir | Out-Null
        Write-Host "Created   : $batchDir"
    }

    $sourceFiles = Get-ChildItem $RawSourceDir -Filter '*.txt' -File
    if ($sourceFiles.Count -eq 0) {
        Write-Error "No .txt files found in RawSourceDir: $RawSourceDir"
        exit 1
    }

    Write-Host "--- Step 1: SSG Pre-processing ($($sourceFiles.Count) file(s)) ---" -ForegroundColor Yellow
    foreach ($f in $sourceFiles) {
        $dest = Join-Path $batchDir $f.Name
        Write-Host "  $($f.Name)"
        & powershell -NoProfile -File $preprocessor -InputFile $f.FullName -OutputFile $dest -ParamOverrides $ParamOverrides -ConditionValues $ConditionValues
    }
    Write-Host "Pre-processing complete." -ForegroundColor Green
    Write-Host ""

} else {
    Write-Host "Step 1 skipped — RawSourceDir not supplied. BatchDir used as-is." -ForegroundColor DarkGray
    Write-Host ""
}

# ── Step 2: Run CobolConverterConsole ─────────────────────────────────────────
Write-Host "--- Step 2: CobolConverterConsole ---" -ForegroundColor Yellow
Write-Host ""

& $ConsolePath $SettingsFile
$exitCode = $LASTEXITCODE

Write-Host ""
if ($exitCode -eq 0) {
    Write-Host "Converter exit code: $exitCode (success)" -ForegroundColor Green
} else {
    Write-Host "Converter exit code: $exitCode" -ForegroundColor Yellow
}

# ── Step 3: Check output ──────────────────────────────────────────────────────
$outputFile = $settings.AppList[0].OutputFile
Write-Host ""
if ($outputFile -and (Test-Path $outputFile)) {
    $info = Get-Item $outputFile
    Write-Host "Output    : $outputFile" -ForegroundColor Green
    Write-Host "Size      : $($info.Length) bytes"
    Write-Host "Modified  : $($info.LastWriteTime)"
} else {
    Write-Host "Output file not found: $outputFile" -ForegroundColor Red
}

# Show most recent log if LogFile pattern is set
$logPattern = $settings.LogFile
if ($logPattern) {
    $logDir = Split-Path $logPattern -Parent
    if (Test-Path $logDir) {
        $appName = $settings.AppList[0].AppName
        $latestLog = Get-ChildItem $logDir -Filter "*.log" |
            Where-Object { $_.Name -like "*$($appName.ToLower())*" -or $_.Name -like "*trial-03*" } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1
        if ($latestLog) {
            Write-Host "Log       : $($latestLog.FullName) ($($latestLog.Length) bytes)"
        }
    }
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
