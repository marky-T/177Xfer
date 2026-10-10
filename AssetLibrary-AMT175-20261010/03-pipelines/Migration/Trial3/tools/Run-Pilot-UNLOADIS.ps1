# Trial 3 pilot: UNLOADIS_ASCII -> clean COBOL -> CobolConverterConsole -> .LionSource
# Direct/in-repo invocation (bypasses Convert-SsgToLion.ps1 LECTIS-filter + external preprocessor gotchas).
$ErrorActionPreference = 'Stop'

$repo       = 'C:\Amt\Migration\Trial3'
$rawFile    = 'C:\Amt\MainframeSource\2026-07-07_SSG\CreatingCobol\UNLOADIS_ASCII.TXT'
$stripper   = Join-Path $repo 'tools\Remove-SsgDirectives.ps1'
$console    = 'C:\Dev\amt-go-net-net8\Migration Tools\CobolToAmt\CobolConverterConsole\bin\Debug\net8.0\CobolConverterConsole.exe'  # 260505 - processes .TXT correctly (260728 produces 0 objects)
$globalCopy = 'C:\Amt\MainframeSource\Codedrop 2025\CopyPrd'
$templateSt = Join-Path $repo 'settings\trial-05-lectis.settings'

$candDir    = Join-Path $repo 'candidates\trial3-unloadis'
$candFile   = Join-Path $candDir 'UNLOAD-ASCII.TXT'   # name matches PROGRAM-ID (AMT172 bug#14)
$outDir     = Join-Path $repo 'output'
$outFile    = Join-Path $outDir 'trial3-unloadis.LionSource'
$settingsFile = Join-Path $repo 'settings\trial3-unloadis.settings'
$log        = Join-Path $outDir 'trial3-unloadis.run.log'

New-Item -ItemType Directory -Force -Path $candDir, $outDir | Out-Null
Get-ChildItem $candDir -Filter '*.TXT' -File -EA SilentlyContinue | Remove-Item -Force

# --- Manifest values for UNLOADIS_ASCII (PROGRAM-ID UNLOAD-ASCII) -------------
$paramOverrides = @{
    '[INPUT,1,1,1]'  = 'FICHIN-1'
    '[INPUT,1,1,2]'  = '80'
    '[INPUT,1,1,3]'  = '1'
    '[OUTPUT,1,1,1]' = 'FICHOUT-1'
    '[OUTPUT,1,1,2]' = '80'
    '[OUTPUT,1,1,3]' = '1'
    '[KEYIS,1,1,1]'  = '0'
    '[KEYIS,1,1,2]'  = '1'
    '[KEYIS,1,1,3]'  = '1'
    '[MAXREC,1,1,1]' = '0'
}
$conditionValues = @{
    'ASCII'       = 1   # ASCII variant
    'OUTPUT,1,1'  = 0   # <=3 -> DISC assign (not INTERCHANGE)
    'OMITTED'     = 0
    'KEYIS,1,1,1' = 0   # = 0 branch
    'MAXREC'      = 0
}

'===== STEP 1: SSG strip -> clean COBOL =====' | Set-Content $log
& $stripper -InputFile $rawFile -OutputFile $candFile `
    -ParamOverrides $paramOverrides -ConditionValues $conditionValues *>&1 |
    Tee-Object -FilePath $log -Append | Out-Null

# CobolConverterConsole chokes on a UTF-8 BOM in col 1 (-> 0 objects, AMT172 bug#14). Rewrite BOM-free.
$noBom = [System.IO.File]::ReadAllText($candFile)
[System.IO.File]::WriteAllText($candFile, $noBom, (New-Object System.Text.UTF8Encoding($false)))
$fb = [System.IO.File]::ReadAllBytes($candFile)[0..2] -join ' '
"candidate first bytes (no BOM expected, not 239 187 191): $fb" | Add-Content $log
"candidate exists: $(Test-Path $candFile)  lines: $((Get-Content $candFile -EA SilentlyContinue).Count)" | Add-Content $log

# --- Build a valid settings file from the LECTIS template (clean JSON) --------
$s = Get-Content $templateSt -Raw | ConvertFrom-Json
$s.AppList[0].AppName       = 'AFBUS_COBOL'
$s.AppList[0].BatchDir      = $candDir
$s.AppList[0].OutputFile    = $outFile
$s.AppList[0].GlobalCopyDir = $globalCopy
$s | ConvertTo-Json -Depth 30 | Set-Content -Path $settingsFile -Encoding UTF8

'' | Add-Content $log
'===== STEP 2: CobolConverterConsole =====' | Add-Content $log
& $console $settingsFile *>&1 | Tee-Object -FilePath $log -Append | Out-Null
"converter exit: $LASTEXITCODE" | Add-Content $log

'' | Add-Content $log
'===== RESULT =====' | Add-Content $log
if (Test-Path $outFile) {
    $fi = Get-Item $outFile
    "OK  .LionSource: $($fi.FullName)  ($($fi.Length) bytes)" | Add-Content $log
} else {
    "FAIL  no .LionSource produced" | Add-Content $log
}

Get-Content $log
