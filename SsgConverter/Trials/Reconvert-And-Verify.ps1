<#
.SYNOPSIS
  Repeatable rebuild -> reconvert -> verify loop for the SsgConverter SSG->PowerShell fix cycle.
.DESCRIPTION
  One routine for the Area B (converter fix) -> Area C (reconvert) -> Area A (parse + run) cycle so
  the same steps can be repeated for each program as it is brought up. Idempotent and re-runnable.

  Steps (all optional via switches):
    -Rebuild        dotnet build the SsgConverter library from source.
    -RefreshDll     copy the freshly built SsgConverter.dll into Build\Console (and Build\Gui),
                    preserving the true original once as SsgConverter.dll.orig for restore.
    -UpdateGoldens  reconvert straight into Examples\Output (the goldens), backing them up first;
                    otherwise reconvert into a scratch folder.
  Always: reconverts Examples\Input, parse-checks each program's .ps1, and runs the Tier-1 harness
  for any program that has a Trials\<Program>\sgs-values.json.
.EXAMPLE
  .\Reconvert-And-Verify.ps1 -Rebuild -RefreshDll -UpdateGoldens
.EXAMPLE
  .\Reconvert-And-Verify.ps1 -Programs ARCHISEPARE,CFH-COPY
#>
[CmdletBinding()]
param(
  [String[]]$Programs,
  [Switch]$Rebuild,
  [Switch]$RefreshDll,
  [Switch]$UpdateGoldens,
  [String]$OutDir
)

$ErrorActionPreference = "Stop"
$ssg        = Split-Path $PSScriptRoot -Parent            # ...\SsgConverter
$libProj    = Join-Path $ssg "Source\SsgConverter\SsgConverter.csproj"
$builtDll   = Join-Path $ssg "Source\SsgConverter\bin\Debug\net10.0\SsgConverter.dll"
$console    = Join-Path $ssg "Build\Console"
$gui        = Join-Path $ssg "Build\Gui"
$inputDir   = Join-Path $ssg "Examples\Input"
$goldens    = Join-Path $ssg "Examples\Output"
$harness    = Join-Path $ssg "Trials\Tier1Mock\Run-SsgPsTrial.ps1"
$trialsRoot = Join-Path $ssg "Trials"
$stamp      = Get-Date -Format "yyyyMMdd-HHmmss"

# 1) Rebuild the library from source
if ($Rebuild) {
  Write-Host "== Rebuild library ==" -ForegroundColor Cyan
  dotnet build $libProj -c Debug --nologo | Select-Object -Last 3
  if ($LASTEXITCODE -ne 0) { throw "Library build failed." }
}

# 2) Refresh the console (and GUI) copy of SsgConverter.dll, keeping the true original once
if ($RefreshDll) {
  if (-not (Test-Path $builtDll)) { throw "Built DLL not found (run with -Rebuild first): $builtDll" }
  foreach ($dir in @($console, $gui)) {
    $target = Join-Path $dir "SsgConverter.dll"
    if (Test-Path $target) {
      $orig = "$target.orig"
      if (-not (Test-Path $orig)) { Copy-Item $target $orig -Force }   # preserve verified original once
      Copy-Item $builtDll $target -Force
      Write-Host ("Refreshed {0} ({1} bytes)" -f $target, (Get-Item $target).Length) -ForegroundColor Green
    }
  }
}

# 3) Decide output folder
if ($UpdateGoldens) {
  $backup = Join-Path $ssg ("_backup\Output-" + $stamp)
  New-Item -ItemType Directory -Force -Path (Split-Path $backup -Parent) | Out-Null
  Copy-Item $goldens $backup -Recurse -Force
  Write-Host "Backed up goldens -> $backup" -ForegroundColor DarkYellow
  $target = $goldens
} else {
  if (-not $OutDir) { $OutDir = Join-Path $ssg "Examples\_Verify" }
  Remove-Item $OutDir -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
  $target = $OutDir
}

# 4) Reconvert Examples\Input with the current Build\Console
Write-Host "== Reconvert -> $target ==" -ForegroundColor Cyan
dotnet (Join-Path $console "SsgConverterConsole.dll") /INPUT:"$inputDir" /OUTPUT:"$target" `
  /CONTINUEONERROR:TRUE /VERBOSE:2 /ENABLELOGFILE:TRUE /LOGFILE:"$target" 2>&1 |
  Select-String -Pattern "Conversion complete|Error converting|IMPORTANT-WORKAROUND" | ForEach-Object { $_.Line }

# 5) Determine which programs to verify
if (-not $Programs -or $Programs.Count -eq 0) {
  $Programs = Get-ChildItem $target -Filter *.ps1 | ForEach-Object { $_.BaseName } | Sort-Object
}

# 6) Parse-check + harness-run
$results = @()
foreach ($p in $Programs) {
  $ps1 = Join-Path $target "$p.ps1"
  if (-not (Test-Path $ps1)) { $results += [PSCustomObject]@{ Program=$p; ParseErrors="(missing)"; Ran="-"; Lines="-" }; continue }
  $errs = $null
  [void][System.Management.Automation.Language.Parser]::ParseFile($ps1, [ref]$null, [ref]$errs)
  $ran = "n/a (no sgs-values)"; $lines = "-"
  $valuesFile = Join-Path $trialsRoot "$p\sgs-values.json"
  if ((Test-Path $valuesFile) -and $errs.Count -eq 0) {
    $r = & $harness -Program $p -ScriptPath $ps1 6>$null
    $ran = if ($r.Failed) { "THREW" } else { "OK" }
    $lines = $r.LineCount
  } elseif (Test-Path $valuesFile) {
    $ran = "skipped (parse>0)"
  }
  $results += [PSCustomObject]@{ Program=$p; ParseErrors=$errs.Count; Ran=$ran; Lines=$lines }
}

Write-Host "== Summary ==" -ForegroundColor Cyan
$results | Format-Table -AutoSize
return $results
