<#
.SYNOPSIS
  SSG-4 pipeline driver: for each converted program, expand it with real SGS cards and convert the result to .LionSource.
.DESCRIPTION
  Reads sgs-calls.csv from Export-SgsCards.ps1, takes up to -CallsPerProgram calls per program
  (in index order), and runs Invoke-SsgExpansion.ps1 then Invoke-CobolConversion.ps1 on each, every
  step in its own pwsh process. Writes <WorkDir>\summary.csv.
.EXAMPLE
  pwsh -NoProfile -File Invoke-RealCardBatch.ps1 -CallsPerProgram 1
#>
param(
  [String]$CardsDir = 'E:\Repos\ssg4-work\sgs-cards',
  [String]$WorkDir = 'E:\Repos\ssg4-work',
  [Int32]$CallsPerProgram = 1,
  [String[]]$Programs
)

$ErrorActionPreference = 'Stop'
$Programs = @($Programs | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
New-Item -ItemType Directory -Force (Join-Path $WorkDir 'expanded') | Out-Null
$rows = Import-Csv (Join-Path $CardsDir 'sgs-calls.csv') | Where-Object { $_.Converted -eq 'True' }
if ($Programs) { $rows = $rows | Where-Object { $Programs -contains $_.ProgramKey } }

$results = foreach ($g in ($rows | Group-Object ProgramKey | Sort-Object Name)) {
  foreach ($call in ($g.Group | Select-Object -First $CallsPerProgram)) {
    $name = "{0}__{1}_L{2}" -f $call.ProgramKey, (($call.Runstream -replace '^ASSURFED_F999RUN[-_]?(d_)?', '') -replace '\(P\)\.TXT$', ''), $call.Line
    $cob = Join-Path $WorkDir "expanded\$name.cob"
    $exp = pwsh -NoProfile -File (Join-Path $PSScriptRoot 'Invoke-SsgExpansion.ps1') -Program $call.ProgramKey `
      -CardFile (Join-Path $CardsDir $call.CardFile) -OutFile $cob -RunInfo "$($call.RunId),$($call.RunAccount),$($call.RunProject)" 2>&1
    $expExit = $LASTEXITCODE
    $expErr = ($exp | Out-String) -split "`n" | Where-Object { $_ -match '^Error\s*:\s*\S' } | Select-Object -First 1
    $lines = if (Test-Path $cob) { @(Get-Content $cob).Count } else { 0 }

    $conv = $null
    if ($expExit -eq 0 -and $lines -gt 0) {
      $conv = pwsh -NoProfile -Command "& '$(Join-Path $PSScriptRoot 'Invoke-CobolConversion.ps1')' -CobolFile '$cob' -Name '$name' -WorkDir '$(Join-Path $WorkDir 'cobol')' | ConvertTo-Json -Compress" | ConvertFrom-Json
    }
    [pscustomobject]@{
      Program    = $call.ProgramKey
      Call       = "$($call.Runstream):$($call.Line)"
      Cards      = $call.Cards
      ExpandExit = $expExit
      ExpandError = if ($expErr) { ($expErr -replace '^Error\s*:\s*', '').Trim() } else { '' }
      Lines      = $lines
      ProgramId  = $conv.ProgramId
      ConvExit   = $conv.Exit
      Errors     = $conv.Errors
      Warnings   = $conv.Warnings
      OutBytes   = $conv.OutBytes
      FirstError = $conv.FirstError
    }
  }
}

$results | Export-Csv (Join-Path $WorkDir 'summary.csv') -NoTypeInformation -Encoding utf8
$results | Format-Table Program, ExpandExit, Lines, ProgramId, ConvExit, Errors, Warnings, OutBytes -AutoSize | Out-String -Width 200
$results | Where-Object ExpandError | ForEach-Object { "{0}: {1}" -f $_.Program, $_.ExpandError }
