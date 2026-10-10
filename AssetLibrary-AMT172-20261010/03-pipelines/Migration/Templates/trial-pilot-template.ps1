# Trial Pilot Runner Template
# Copy to: Trial3\tools\Run-Pilot-<PROGRAM>.ps1
# Replace all <PLACEHOLDER> values before running.

$ErrorActionPreference = 'Stop'

# ─── Configure these per program ──────────────────────────────────────────────
$programKey  = '<PROGRAM_KEY>'          # SSG element name, e.g. UNLOADIS_ASCII
$programId   = '<PROGRAM-ID>'           # COBOL PROGRAM-ID, e.g. UNLOAD-ASCII
$trialNum    = 'trial3'                 # trial folder prefix
$rawFile     = "C:\Amt\MainframeSource\2026-07-07_SSG\CreatingCobol\$programKey.TXT"

$paramOverrides = @{
    '[INPUT,1,1,1]'  = 'FICHIN-1'       # ECL file designator
    '[INPUT,1,1,2]'  = '80'             # record length
    '[INPUT,1,1,3]'  = '1'              # block factor
    # '[OUTPUT,1,1,1]' = 'FICHOUT-1'    # uncomment if program writes output
}
$conditionValues = @{
    'ASCII'  = 1                        # variant selector
    # add *IF condition names as needed
}
# ──────────────────────────────────────────────────────────────────────────────

$repo       = 'C:\Amt\Migration\Trial3'
$stripper   = 'C:\Amt\Migration\Templates\Remove-SsgDirectives.ps1'
$console    = 'C:\Dev\amt-go-net-net8\Migration Tools\CobolToAmt\CobolConverterConsole\bin\Debug\net8.0\CobolConverterConsole.exe'
$globalCopy = 'C:\Amt\MainframeSource\Codedrop 2025\CopyPrd'

$candDir    = Join-Path $repo "candidates\$trialNum-$($programId.ToLower())"
$candFile   = Join-Path $candDir "$programId.TXT"
$outDir     = Join-Path $repo 'output'
$outFile    = Join-Path $outDir "$trialNum-$($programId.ToLower()).LionSource"
$settingsFile = Join-Path $repo "settings\$trialNum-$($programId.ToLower()).settings"
$log        = Join-Path $outDir "$trialNum-$($programId.ToLower()).run.log"

New-Item -ItemType Directory -Force -Path $candDir, $outDir | Out-Null
Get-ChildItem $candDir -Filter '*.TXT' -File -EA SilentlyContinue | Remove-Item -Force

# ─── Step 1: SSG strip → clean COBOL ─────────────────────────────────────────
"===== STEP 1: SSG strip -> clean COBOL =====" | Set-Content $log
& $stripper -InputFile $rawFile -OutputFile $candFile `
    -ParamOverrides $paramOverrides -ConditionValues $conditionValues *>&1 |
    Tee-Object -FilePath $log -Append | Out-Null

# Rewrite BOM-free (CobolConverterConsole bug#14 — chokes on UTF-8 BOM in col 1)
$noBom = [System.IO.File]::ReadAllText($candFile)
[System.IO.File]::WriteAllText($candFile, $noBom, (New-Object System.Text.UTF8Encoding($false)))
$fb = [System.IO.File]::ReadAllBytes($candFile)[0..2] -join ' '
"candidate first bytes (not 239 187 191): $fb" | Add-Content $log
"candidate lines: $((Get-Content $candFile -EA SilentlyContinue).Count)" | Add-Content $log

# ─── Step 2: Build settings file ──────────────────────────────────────────────
"===== STEP 2: Build settings file =====" | Add-Content $log
$templateSettings = 'C:\Amt\Migration\Templates\trial-settings-template.json'
$s = Get-Content $templateSettings -Raw | ConvertFrom-Json
$s.AppList[0].AppName       = 'AFBUS_COBOL'
$s.AppList[0].BatchDir      = $candDir
$s.AppList[0].OutputFile    = $outFile
$s.AppList[0].GlobalCopyDir = $globalCopy
$s | ConvertTo-Json -Depth 10 | Set-Content $settingsFile -Encoding UTF8
"settings written: $settingsFile" | Add-Content $log

# ─── Step 3: CobolConverterConsole ────────────────────────────────────────────
"===== STEP 3: CobolConverterConsole =====" | Add-Content $log
& $console $settingsFile *>&1 | Tee-Object -FilePath $log -Append | Out-Null
if (-not (Test-Path $outFile)) { throw "CobolConverterConsole produced no output: $outFile" }
$sz = (Get-Item $outFile).Length
"output: $outFile ($sz B)" | Add-Content $log

Write-Host "DONE: $outFile ($sz B)" -ForegroundColor Green
Write-Host "Log:  $log"
