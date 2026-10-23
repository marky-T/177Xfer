<#
.SYNOPSIS
  WORKING EXAMPLE: one SSG report step taken through the whole SSG-4 pipeline, with checked-in results.
.DESCRIPTION
  Input : input\ASSURFED_F999RUN_VIRM01_CO(P).TXT  (the runstream step that calls *UTILIT.CFH-COPY/ASCII)
          SsgConverter\Examples\Output\CFH-COPY_ASCII.ps1  (the converted SSG skeleton)
  Steps : 1 export the SGS cards   2 expand the skeleton with those cards (AMT's SGS code)
          3 convert the expanded COBOL to .LionSource (CobolConverterConsole)
  Output: regenerated into a temp folder and compared byte for byte with expected\.
  PASS means the pipeline still produces exactly the checked-in results. Use -Update to accept new ones.
.EXAMPLE
  pwsh -NoProfile -File Run-WorkingExample.ps1
#>
param(
  [Switch]$Update,
  [String]$WorkRoot = (Join-Path ([System.IO.Path]::GetTempPath()) 'ssg4-working-example')
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$pipe = Split-Path $here -Parent
$program = 'CFH-COPY_ASCII'

if (Test-Path $WorkRoot) { Remove-Item $WorkRoot -Recurse -Force }
New-Item -ItemType Directory -Path $WorkRoot | Out-Null

# 1. SGS cards
& pwsh -NoProfile -File (Join-Path $pipe 'Export-SgsCards.ps1') -RunstreamDir (Join-Path $here 'input') -OutDir (Join-Path $WorkRoot '1-cards') | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Export-SgsCards failed' }
$call = Import-Csv (Join-Path $WorkRoot '1-cards\sgs-calls.csv') | Where-Object ProgramKey -eq $program | Select-Object -First 1
if (-not $call) { throw "No @SSG call for $program found in the input" }

# 2. Expansion with the real cards
$cob = Join-Path $WorkRoot "2-expanded\$program.cob"
& pwsh -NoProfile -File (Join-Path $pipe 'Invoke-SsgExpansion.ps1') -Program $program -CardFile (Join-Path $WorkRoot "1-cards\$($call.CardFile)") `
  -OutFile $cob -RunInfo "$($call.RunId),$($call.RunAccount),$($call.RunProject)" | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Invoke-SsgExpansion failed' }

# 3. COBOL -> .LionSource
$conv = pwsh -NoProfile -Command "& '$(Join-Path $pipe 'Invoke-CobolConversion.ps1')' -CobolFile '$cob' -Name '$program' -WorkDir '$(Join-Path $WorkRoot 'work')' | ConvertTo-Json -Compress" | ConvertFrom-Json
New-Item -ItemType Directory -Path (Join-Path $WorkRoot '3-lionsource') | Out-Null
Copy-Item $conv.OutFile (Join-Path $WorkRoot "3-lionsource\$program.LionSource")

$artifacts = @(
  "1-cards\$($call.CardFile)", '1-cards\sgs-calls.csv', "2-expanded\$program.cob", "3-lionsource\$program.LionSource"
)
if (Test-Path (Join-Path $WorkRoot '1-cards\sgs-warnings.csv')) { $artifacts += '1-cards\sgs-warnings.csv' }

$expected = Join-Path $here 'expected'
if ($Update) {
  if (Test-Path $expected) { Remove-Item $expected -Recurse -Force }
  foreach ($a in $artifacts) {
    $dest = Join-Path $expected $a
    New-Item -ItemType Directory -Path (Split-Path $dest -Parent) -Force | Out-Null
    Copy-Item (Join-Path $WorkRoot $a) $dest
  }
}

$results = foreach ($a in $artifacts) {
  $new = Join-Path $WorkRoot $a; $old = Join-Path $expected $a
  # The converter writes "Application converted on : <date time>" into every .LionSource; mask it for the comparison.
  $norm = { param($p) $t = [IO.File]::ReadAllText($p, [Text.Encoding]::GetEncoding(1252)); $t = [regex]::Replace($t, '(?m)^(\s*Application converted on\s*:).*$', '$1 <masked>'); [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::GetEncoding(1252).GetBytes($t))) }
  $state = if (-not (Test-Path $old)) { 'MISSING' } elseif ((& $norm $new) -eq (& $norm $old)) { 'PASS' } else { 'DIFF' }
  [pscustomobject]@{ Artifact = $a; Result = $state }
}

$text = Get-Content $cob -Raw
$facts = [ordered]@{
  'Input record 500 bytes (INPUT INB,500)'   = $text -match 'RECIN\s+PIC\s+X\(500\)'
  'Output record 135 bytes (OUTPUT INC,135)' = $text -match 'RECOUT\s+PIC\s+X\(135\)'
  'Files assigned to INB and INC'            = ($text -match 'DISC\s+INB') -and ($text -match 'DISC\s+INC')
  'Constant TAX-CLASIQ (FIXE)'               = $text -match "VALUE\s+'TAX-CLASIQ'"
  'COBOL converter: 0 errors'                = ($conv.Exit -eq 0 -and $conv.Errors -eq 0)
}

"WORKING EXAMPLE: $program with the VIRM01_CO cards"
$results | Format-Table -AutoSize | Out-String
foreach ($k in $facts.Keys) { "{0,-6} {1}" -f $(if ($facts[$k]) { 'ok' } else { 'FAIL' }), $k }
"Converter warnings: $($conv.Warnings)   LionSource: $($conv.OutBytes) bytes"
"Skeleton    : SsgConverter\Examples\Input\$program.TXT"
"Converted PS: SsgConverter\Examples\Output\$program.ps1  (SHA-256 $((Get-FileHash (Join-Path $pipe "..\..\SsgConverter\Examples\Output\$program.ps1")).Hash.Substring(0, 16))...)"

$bad = @($results | Where-Object Result -ne 'PASS').Count + @($facts.Values | Where-Object { -not $_ }).Count
if ($bad) { 'RESULT: FAILED'; exit 1 } else { 'RESULT: PASS'; exit 0 }
