<#
.SYNOPSIS
  Stages the SsgConverter change package for R&D: the changed source files at R&D's paths, a patch against R&D develop, and SHA256SUMS.
.DESCRIPTION
  Only .cs files are shipped. The three .csproj files are NOT sent: ours differ only for the local build (shipped _deps binaries, no signing).
  CHANGELIST.md is written by hand into the output folder and is included in SHA256SUMS when present. Idempotent.
  The patch is verified by applying it to a scratch copy of develop and comparing every file with the shipped one.
.EXAMPLE
  pwsh -NoProfile -File New-RnDPackage.ps1
#>
param(
  [String]$Source = (Join-Path $PSScriptRoot '..\Source'),
  [String]$Develop = 'E:\Repos\amt-go-net-ref\Migration Tools\SsgConverter',
  [String]$Out = (Join-Path $PSScriptRoot '..\Release-RnD-20261014')
)
$ErrorActionPreference = 'Stop'
$Source = (Resolve-Path $Source).Path
$Out = [IO.Path]::GetFullPath($Out)
$files = @(
  'SsgConverter\SymstreamProcessor.cs',
  'SsgConverter\SymstreamExpressionMigrator.cs',
  'SsgConverter\SymstreamExpressionParser.cs',
  'SsgConverterConsole\Os2200ContentConverter.cs',
  'SsgConverterConsole\Program.cs',
  'SsgConverterGui\App.xaml.cs',
  'SsgConverterGui\MainWindow.xaml.cs'
)
$root = Join-Path $Out 'Migration Tools\SsgConverter'
New-Item -ItemType Directory -Force $root | Out-Null
foreach ($f in $files) {
  $dst = Join-Path $root $f
  New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
  Copy-Item (Join-Path $Source $f) $dst -Force
}

# patch against R&D develop; paths are relative to 'Migration Tools/SsgConverter', apply with: git apply -p1 --ignore-whitespace
$tmp = Join-Path ([IO.Path]::GetTempPath()) ('rndpatch-' + [Guid]::NewGuid().ToString('N'))
foreach ($side in 'a', 'b') { foreach ($f in $files) { New-Item -ItemType Directory -Force (Split-Path (Join-Path $tmp "$side\$f")) | Out-Null } }
foreach ($f in $files) {
  Copy-Item (Join-Path $Develop $f) (Join-Path $tmp "a\$f")
  Copy-Item (Join-Path $root $f) (Join-Path $tmp "b\$f")
}
$patchFile = Join-Path $Out 'SsgConverter-vs-develop.patch'
Push-Location $tmp
try {
  $patch = git -c core.autocrlf=false diff --no-index --no-prefix a b
  [IO.File]::WriteAllLines($patchFile, $patch, (New-Object Text.UTF8Encoding($false)))
} finally { Pop-Location }

# verify: apply the patch to a scratch copy of develop and compare with the shipped files
$check = Join-Path $tmp 'check'
foreach ($f in $files) { New-Item -ItemType Directory -Force (Split-Path (Join-Path $check $f)) | Out-Null; Copy-Item (Join-Path $Develop $f) (Join-Path $check $f) }
Push-Location $check
try { git -c core.autocrlf=false apply -p1 --ignore-whitespace $patchFile 2>&1 | ForEach-Object { "$_" } } finally { Pop-Location }
$bad = @($files | Where-Object { (Get-FileHash (Join-Path $check $_)).Hash -ne (Get-FileHash (Join-Path $root $_)).Hash })
Remove-Item $tmp -Recurse -Force
if ($bad.Count -gt 0) { throw "Patch does not reproduce: $($bad -join ', ')" }
"Patch verified: applying it to develop reproduces all $($files.Count) shipped files."

# checksums of everything shipped
$sums = Get-ChildItem $Out -Recurse -File | Where-Object { $_.Name -ne 'SHA256SUMS.txt' } | Sort-Object FullName | ForEach-Object {
  '{0}  {1}' -f (Get-FileHash $_.FullName -Algorithm SHA256).Hash, $_.FullName.Substring($Out.Length + 1).Replace('\', '/')
}
[IO.File]::WriteAllLines((Join-Path $Out 'SHA256SUMS.txt'), $sums, (New-Object Text.UTF8Encoding($false)))
"Package: $Out"
Get-ChildItem $Out -Recurse -File | ForEach-Object { '{0,9}  {1}' -f $_.Length, $_.FullName.Substring($Out.Length + 1) }
