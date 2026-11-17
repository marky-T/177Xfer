<#
.SYNOPSIS
  T3-067 spike (MT-070): prove that the per-call route converts a UCS skeleton's expansion correctly when it
  (a) chooses -Cobol85 from the skeleton's compiler call and (b) cuts any ECL images out of the expanded text.
  Opt-in scratch tool; the shared scripts (Invoke-RealCardBatch.ps1, Build-AppLionSource.ps1, Invoke-CobolConversion.ps1)
  are not changed. Each expanded file is converted twice: "today" (as the shared scripts do) and "spike".
.EXAMPLE
  .\Invoke-UcsSpike.ps1 -Program EXTEUR -CobolFile E:\Repos\ssg4-work\db-probe-261116\expanded\EXTEUR__VIRJ01_UL__L146.cob
#>
param(
  [Parameter(Mandatory)][String]$Program,
  [Parameter(Mandatory)][String[]]$CobolFile,
  [String]$WorkDir = 'E:\Repos\ssg4-work\t3067-spike',
  [String]$SsgSource = 'E:\Repos\SsgTrial\SSG-Source',
  [String]$Pipeline = 'E:\Repos\SsgTrial\Conversion\Pipeline'
)
$ErrorActionPreference = 'Stop'
$enc = [Text.Encoding]::GetEncoding(1252)
$compilerCall = '^[@#](UCOB|ACOB|COB)\b'

# (a) compiler from the skeleton: @UCOB / #ucob = UCS COBOL-85; @ACOB / #ACOB / #COB = ACOB (COBOL-74)
$skel = Get-ChildItem $SsgSource -File | Where-Object { $_.BaseName -eq $Program -or $_.Name -eq $Program } | Select-Object -First 1
if (-not $skel) { throw "No skeleton for $Program in $SsgSource" }
$compilers = @(Select-String -LiteralPath $skel.FullName -Pattern $compilerCall | ForEach-Object { $_.Matches[0].Groups[1].Value.ToUpperInvariant() } | Sort-Object -Unique)
if ($compilers.Count -eq 0) { throw "$Program : no compiler call (@/#UCOB, ACOB, COB) in the skeleton" }
if ($compilers -contains 'UCOB' -and $compilers.Count -gt 1) { throw "$Program : mixes UCOB with $($compilers -join ',')" }
$ucs = $compilers[0] -eq 'UCOB'

# (b) program source only: drop '@' images with their ';' continuations, and everything from @EOF to the next compiler call
function Get-CobolOnly ([String[]]$Lines) {
  $out = New-Object System.Collections.Generic.List[String]; $cont = $false; $afterEof = $false
  foreach ($l in $Lines) {
    if ($cont) { $cont = $l.TrimEnd().EndsWith(';'); continue }
    if ($l.StartsWith('@')) {
      if ($l -match '^@EOF\b') { $afterEof = $true } elseif ($l -match $compilerCall) { $afterEof = $false }
      $cont = $l.TrimEnd().EndsWith(';'); continue
    }
    if (-not $afterEof) { $out.Add($l) }
  }
  , $out.ToArray()
}

function Convert-One ([String]$File, [String]$Name, [Bool]$Cobol85) {
  $sw = if ($Cobol85) { '-Cobol85' } else { '' }
  $o = pwsh -NoProfile -Command "& '$Pipeline\Invoke-CobolConversion.ps1' -CobolFile '$File' -Name '$Name' -WorkDir '$WorkDir\cobol' $sw | ConvertTo-Json -Compress" 2>&1
  ($o | Where-Object { $_ -like '{*' } | Select-Object -Last 1) | ConvertFrom-Json
}

New-Item -ItemType Directory "$WorkDir\input" -Force | Out-Null
foreach ($f in $CobolFile) {
  $base = [IO.Path]::GetFileNameWithoutExtension($f)
  $lines = [IO.File]::ReadAllLines($f, $enc)
  $cut = Get-CobolOnly $lines
  $cutFile = "$WorkDir\input\$base.spike.cob"
  [IO.File]::WriteAllLines($cutFile, $cut, $enc)
  $today = Convert-One $f "$($base)_TODAY" $false
  $spike = Convert-One $cutFile "$($base)_SPIKE" $ucs
  [pscustomobject]@{
    File = $base; Compiler = $compilers -join '+'; Cobol85 = $ucs; LinesIn = $lines.Count; LinesSpike = $cut.Count
    TodayErrors = $today.Errors; TodayWarnings = $today.Warnings; SpikeErrors = $spike.Errors; SpikeWarnings = $spike.Warnings
    SpikeFirstError = $spike.FirstError
  }
}
