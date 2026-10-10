#!/usr/bin/env pwsh
#
# Convert 3 trial programs using CobolConverterConsole
#

$console = 'C:\Dev\amt-go-net-net8\Migration Tools\CobolToAmt\CobolConverterConsole\bin\Debug\net8.0\CobolConverterConsole.exe'
$repo = 'C:\Amt\Migration\Trial3'

if (-not (Test-Path $console)) {
    Write-Host "❌ Converter not found: $console" -ForegroundColor Red
    exit 1
}

$programs = @(
    @{name = 'UNLOADIS-MULTI'; settings = 'settings\trial3-unloadis.settings' },
    @{name = 'ARCHISEPARE'; settings = 'settings\trial3-archisepare.settings' },
    @{name = 'LOADIS-ASCII'; settings = 'settings\trial3-loadis-ascii.settings' }
)

Set-Location $repo

foreach ($prog in $programs) {
    $settingsFile = Join-Path $repo $prog.settings
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Converting: $($prog.name)" -ForegroundColor Cyan
    Write-Host "Settings:   $($prog.settings)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    if (-not (Test-Path $settingsFile)) {
        Write-Host "❌ Settings not found" -ForegroundColor Red
        continue
    }
    
    & $console $settingsFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Exit code 0" -ForegroundColor Green
    } else {
        Write-Host "⚠ Exit code: $LASTEXITCODE" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Results:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Get-ChildItem "$repo\output\trial3-*.LionSource" | ForEach-Object {
    $hasCode = (Select-String -Path $_.FullName -Pattern '<DATA=Code>' -Quiet) -or (Select-String -Path $_.FullName -Pattern 'PROCEDURE DIVISION' -Quiet)
    $status = if ($hasCode) { "✓" } else { "❌" }
    Write-Host "$status $($_.Name) ($($_.Length) bytes)"
}
