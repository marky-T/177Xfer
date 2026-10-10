$ErrorActionPreference = 'Continue'
$ssg  = 'C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\SsgConverter\SsgConverter\SsgConverterConsole\bin\Debug\net10.0\SsgConverterConsole.exe'
$base = 'C:\Amt\Migration\Trial3\_baseline'
$in   = Join-Path $base 'in'
$out  = Join-Path $base 'out'
$log  = Join-Path $base 'baseline.log'

New-Item -ItemType Directory -Force -Path $in, $out | Out-Null
Copy-Item 'C:\Amt\MainframeSource\2026-07-07_SSG\CreatingCobol\LECTIS_ASCII.TXT' $in -Force

& $ssg "/INPUT:$in" "/OUTPUT:$out" /VERBOSE:3 /CLEAROUTPUT:TRUE /CONTINUEONERROR:TRUE *>&1 |
    Tee-Object -FilePath $log | Out-Null

"===== EXIT: $LASTEXITCODE ====="            | Add-Content $log
"===== OUTPUT TREE ====="                    | Add-Content $log
Get-ChildItem $out -Recurse -File | ForEach-Object { "{0}  ({1} bytes)" -f $_.FullName, $_.Length } | Add-Content $log

Get-Content $log
