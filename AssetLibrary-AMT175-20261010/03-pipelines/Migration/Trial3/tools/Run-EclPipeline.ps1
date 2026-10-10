<#
.SYNOPSIS
  Repeatable driver for the ECL/COBOL/PowerShell conversion stream.

.DESCRIPTION
  Reads config\pipeline.config.json + manifest\programs.manifest.json and runs
  the SSG pre-process -> CobolConverterConsole pipeline for each program.

  The driver is self-contained and idempotent:
   * The converter exe is referenced by configurable path (never vendored).
   * For each program the source .settings is rewritten to repo-relative
     BatchDir / OutputFile / GlobalCopyDir before invocation, so the repo can
     be cloned to any machine and re-run with a single command.
   * ParamOverrides ([TOKEN]=value) and ConditionValues (PARAM=value) are read
     from the manifest and forwarded to Convert-SsgToLion.ps1.

.PARAMETER Program
  One or more manifest 'key' values to run. Omit to run all 'done' programs.

.PARAMETER IncludePlanned
  Also process entries whose status is 'planned' (normally skipped).

.PARAMETER ConfigPath
  Override path to pipeline.config.json (default: ..\config\pipeline.config.json).

.PARAMETER ManifestPath
  Override path to programs.manifest.json (default: ..\manifest\programs.manifest.json).

.PARAMETER ListOnly
  Print the resolved plan without invoking the converter.

.EXAMPLE
  .\Run-EclPipeline.ps1 -ListOnly

.EXAMPLE
  .\Run-EclPipeline.ps1 -Program LECTIS

.EXAMPLE
  .\Run-EclPipeline.ps1            # run every validated ('done') program
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string[]]$Program,
    [switch]$IncludePlanned,
    [string]$ConfigPath,
    [string]$ManifestPath,
    [switch]$ListOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot  = Split-Path -Parent $PSScriptRoot
if (-not $ConfigPath)   { $ConfigPath   = Join-Path $RepoRoot 'config\pipeline.config.json' }
if (-not $ManifestPath) { $ManifestPath = Join-Path $RepoRoot 'manifest\programs.manifest.json' }

foreach ($f in @($ConfigPath, $ManifestPath)) {
    if (-not (Test-Path $f)) { Write-Error "Required file not found: $f"; exit 1 }
}

$config   = Get-Content $ConfigPath   -Raw | ConvertFrom-Json
$manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json

function Resolve-RepoPath([string]$p) {
    if ([System.IO.Path]::IsPathRooted($p)) { return $p }
    return (Join-Path $RepoRoot $p)
}

$consolePath   = $config.converterConsolePath
$rawSourceDir  = $config.rawSourceDir
$globalCopyDir = $config.globalCopyDir
$settingsDir   = Resolve-RepoPath $config.settingsDir
$candidatesDir = Resolve-RepoPath $config.candidatesDir
$outputDir     = Resolve-RepoPath $config.outputDir
$convertScript = Join-Path $PSScriptRoot 'Convert-SsgToLion.ps1'
$tmpDir        = Join-Path $outputDir '.tmp'

if (-not (Test-Path $convertScript)) { Write-Error "Convert-SsgToLion.ps1 not found beside the driver: $convertScript"; exit 1 }
New-Item -ItemType Directory -Force -Path $outputDir, $tmpDir | Out-Null

$programs = $manifest.programs
if ($Program) { $programs = $programs | Where-Object { $Program -contains $_.key } }

if (-not $programs) { Write-Warning 'No matching programs in manifest.'; return }

$ran = 0; $skipped = 0
foreach ($p in $programs) {
    Write-Host ''
    Write-Host "=== $($p.key)  [$($p.programId)]  status=$($p.status) ===" -ForegroundColor Cyan

    if ($p.status -eq 'planned' -and -not $IncludePlanned) {
        Write-Warning "  planned entry skipped (use -IncludePlanned to force)"; $skipped++; continue
    }

    $srcSettings = Join-Path $settingsDir $p.settingsFile
    $batchDir    = Join-Path $candidatesDir $p.candidateDir
    $outFile     = Join-Path $outputDir $p.outputName

    Write-Host "  settings : $srcSettings"
    Write-Host "  batchDir : $batchDir"
    Write-Host "  output   : $outFile"

    if ($ListOnly) { $skipped++; continue }

    if (-not (Test-Path $srcSettings)) { Write-Warning "  settings file missing - skipped"; $skipped++; continue }

    # Rewrite settings to repo-relative paths so the run is portable.
    $s = Get-Content $srcSettings -Raw | ConvertFrom-Json
    $s.AppList[0].BatchDir      = $batchDir
    $s.AppList[0].OutputFile    = $outFile
    $s.AppList[0].GlobalCopyDir = $globalCopyDir
    $tmpSettings = Join-Path $tmpDir ($p.key + '.settings')
    $s | ConvertTo-Json -Depth 20 | Set-Content -Path $tmpSettings -Encoding UTF8

    # Build override hashtables from manifest objects.
    $po = @{}
    if ($p.PSObject.Properties.Name -contains 'paramOverrides' -and $p.paramOverrides) {
        $p.paramOverrides.PSObject.Properties | ForEach-Object { $po[$_.Name] = $_.Value }
    }
    $cv = @{}
    if ($p.PSObject.Properties.Name -contains 'conditionValues' -and $p.conditionValues) {
        $p.conditionValues.PSObject.Properties | ForEach-Object { $cv[$_.Name] = $_.Value }
    }

    # AnnotateStubs (Trial-07+): append  *> SSG-STUB [token]  to substituted lines for stub lineage.
    # Use hashtable splat so the [switch] parameter binds correctly in PS5.1.
    $annotateArg = @{}
    if ($p.PSObject.Properties.Name -contains 'annotateStubs' -and $p.annotateStubs) {
        $annotateArg = @{ AnnotateStubs = $true }
    }

    if ($PSCmdlet.ShouldProcess($p.key, 'Convert SSG -> Lion')) {
        & $convertScript -SettingsFile $tmpSettings -RawSourceDir $rawSourceDir `
            -ConsolePath $consolePath -ParamOverrides $po -ConditionValues $cv @annotateArg
        $ran++
    }
}

Write-Host ''
Write-Host "Done. Converted=$ran  Skipped=$skipped" -ForegroundColor Green
