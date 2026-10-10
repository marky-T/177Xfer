# Trial 3 pilot: CHABAN_ASCII -> clean COBOL -> CobolConverterConsole -> .LionSource
# Same pattern as Run-Pilot-UNLOADIS.ps1. Uses 260505 converter (260728 processes 0 objects
# due to enum/API change; ALLOW-DECODED-LIONSOURCE in Lion.ini is the real import fix).
$ErrorActionPreference = 'Stop'

$repo       = 'C:\Amt\Migration\Trial3'
$rawFile    = 'C:\Amt\MainframeSource\2026-07-07_SSG\CreatingCobol\CHABAN_ASCII.TXT'
$stripper   = Join-Path $repo 'tools\Remove-SsgDirectives.ps1'
$console    = 'C:\Dev\amt-go-net-net8\Migration Tools\CobolToAmt\CobolConverterConsole\bin\Debug\net8.0\CobolConverterConsole.exe'  # 260505 - processes .TXT correctly
$globalCopy = 'C:\Amt\MainframeSource\Codedrop 2025\CopyPrd'
$templateSt = Join-Path $repo 'settings\trial-05-lectis.settings'

$candDir    = Join-Path $repo 'candidates\trial3-chaban'
$candFile   = Join-Path $candDir 'CHABAN.TXT'   # matches PROGRAM-ID
$outDir     = Join-Path $repo 'output'
$outFile    = Join-Path $outDir 'trial3-chaban.LionSource'
$settingsFile = Join-Path $repo 'settings\trial3-chaban.settings'
$log        = Join-Path $outDir 'trial3-chaban.run.log'

New-Item -ItemType Directory -Force -Path $candDir, $outDir | Out-Null
Get-ChildItem $candDir -Filter '*.TXT' -File -EA SilentlyContinue | Remove-Item -Force

$paramOverrides = @{
    '[OUTPUT,1,1,1]' = 'FICHOUT-1'
    '[OUTPUT,1,1,2]' = '80'
    '[OUTPUT,1,1,3]' = '1'
    '[NUMB,I,1,1]'   = '1'
    '[NUMB,I,1,2]'   = '1'
    '[NUMB,I,1]'     = '1'
    '[NUMB]'         = '1'
    '[MOD,I,1,1]'    = '0'
    '[MOD,I,1,2]'    = '0'
    '[MOD,I,1,3]'    = '0'
    '[MOD,I,1,4]'    = '0'
    '[MOD,I,1,5]'    = '0'
    '[MOD]'          = '0'
    '[FLDSEL,I,1,1]' = '0'
    '[FLDSEL,I,1,2]' = '1'
    '[FLDSEL,I,1,3]' = '1'
    '[FLDSEL,I]'     = '1'
    '[FLDSEL,I,K,1]' = '1'
    '[FLDSEL,I,K,2]' = '1'
    '[FLDSEL,I,K,3]' = '1'
}
$conditionValues = @{
    'ASCII'       = 1   # ASCII variant
    'LIST'        = 0   # no printer listing
    'NUMB'        = 1
    'NUMB,I,1'    = 1
    'MOD'         = 0
    'MOD,I,1,1'   = 0
    'FLDSEL,I,1,1' = 0
}

'===== STEP 1: SSG strip =====' | Set-Content $log
& $stripper -InputFile $rawFile -OutputFile $candFile `
    -ParamOverrides $paramOverrides -ConditionValues $conditionValues *>&1 |
    Tee-Object -FilePath $log -Append | Out-Null

# Remove UTF-8 BOM (CobolConverterConsole chokes on it)
$noBom = [System.IO.File]::ReadAllText($candFile)
[System.IO.File]::WriteAllText($candFile, $noBom, (New-Object System.Text.UTF8Encoding($false)))
$fb = [System.IO.File]::ReadAllBytes($candFile)[0..2] -join ' '
"candidate bytes0-2 (no BOM: not 239 187 191): $fb" | Add-Content $log
"candidate lines: $((Get-Content $candFile -EA SilentlyContinue).Count)" | Add-Content $log

# ZCAR fix: *PROCESS CALMAX is not expanded by the stripper, leaving '01 ZCAR.' empty (group with no sub-items).
# ZCPOS REDEFINES ZCAR uses 80 chars (OUTPUT,1,1,2=80), so a PIC X(80) FILLER gives it the correct size.
$raw = Get-Content $candFile -Raw
if ($raw -match '01  ZCAR\.\s*\r?\n\s*01  ZCPOS') {
    $fixed = $raw -replace '(01  ZCAR\.[ \t]*\r?\n)([ \t]*01  ZCPOS)', '$1           03  FILLER         PIC X(80).`r`n$2'
    Set-Content -Path $candFile -Value $fixed -NoNewline -Encoding UTF8
    "ZCAR fix applied" | Add-Content $log
} else {
    "ZCAR already has sub-items or pattern not found" | Add-Content $log
}

# Build settings from LECTIS template
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
    "OK  $($fi.FullName)  ($($fi.Length) bytes)" | Add-Content $log
    "CHABAN object present: $([bool](Select-String -Path $outFile -Pattern '<OBJECT=CHABAN,COBOL PROGRAM>'))" | Add-Content $log
} else {
    "FAIL  no .LionSource produced" | Add-Content $log
}

Get-Content $log
