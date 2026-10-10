# Reverts the in-place edits made to the AMT175 install tree during the failed hybrid CobolConverter build.
# Restores mutated csprojs from the clean develop clone and deletes files/folders I created.
$ErrorActionPreference = 'Continue'

$extractRoot = 'C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\CobolToAmt\CobolToAmt'
$devCobol    = 'C:\Dev\amt-go-net-develop\Migration Tools\CobolToAmt'

# 1) Restore mutated Cobol* csprojs from the develop clone (same repo files)
$projs = 'CobolConverterSupport','CobolAnalyser','CobolConverter','CobolMigrator','CobolConverterConsole'
foreach ($p in $projs) {
    $dst = Join-Path $extractRoot "$p\$p.csproj"
    $src = Join-Path $devCobol    "$p\$p.csproj"
    if ((Test-Path $src) -and (Test-Path $dst)) {
        Copy-Item $src $dst -Force
        Write-Host "restored $p.csproj"
    } else {
        Write-Host "SKIP $p (src=$([bool](Test-Path $src)) dst=$([bool](Test-Path $dst)))" -ForegroundColor Yellow
    }
}

# 2) Restore VsGenerator.csproj
$vsDst = 'C:\Amt\Parallel\AMT175\AmtLion\Lion\VsGenerator\VsGenerator.csproj'
$vsSrc = 'C:\Dev\amt-go-net-develop\AmtLion\Lion\VsGenerator\VsGenerator.csproj'
if ((Test-Path $vsSrc) -and (Test-Path $vsDst)) { Copy-Item $vsSrc $vsDst -Force; Write-Host "restored VsGenerator.csproj" }

# 3) Delete files/folders I created
$created = @(
    'C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\CobolToAmt\CobolToAmt\Directory.Build.props'
    'C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\Amt.Net\AmtAssemblyInfo.cs'
    'C:\Amt\Parallel\AMT175\Amt.Net\AmtAssemblyInfo.cs'
    'C:\Amt\Parallel\AMT175\AmtLion\Amt.Net\AmtAssemblyInfo.cs'
)
foreach ($f in $created) { if (Test-Path $f) { Remove-Item $f -Force; Write-Host "deleted $f" } }
# remove now-empty Amt.Net folders I created
foreach ($d in 'C:\Amt\Parallel\AMT175\8.0.26188.0\MigrationTools\Amt.Net','C:\Amt\Parallel\AMT175\Amt.Net','C:\Amt\Parallel\AMT175\AmtLion\Amt.Net') {
    if ((Test-Path $d) -and -not (Get-ChildItem $d -Force -EA SilentlyContinue)) { Remove-Item $d -Force; Write-Host "removed empty $d" }
}

Write-Host "`n==== verify: any residual CobolDeps/Reference edits left? ====" -ForegroundColor Cyan
Get-ChildItem $extractRoot -Recurse -Filter '*.csproj' -EA SilentlyContinue |
    Select-String -Pattern 'CobolDeps' -List | ForEach-Object { "RESIDUAL: $($_.Path)" }
Write-Host "done."
