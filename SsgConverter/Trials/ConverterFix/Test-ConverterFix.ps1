<#
.SYNOPSIS
  Reusable "Test" step for an SsgConverter source fix (replaces _scratch\Test-FixN.ps1).
.DESCRIPTION
  Builds a scratch copy of Build\Console with the scratch-built SsgConverter.dll from
  New-ConverterFix.ps1, reconverts all of Examples\Input, then for every converted program: parse-
  checks it, diffs it against the Examples\Output golden (line count only, not content), and runs it
  through the Tier-1 harness. If -ExpansionPrograms is given, also expands each of those programs with
  its first real exported @SSG call (same mechanism as Preflight-Next5.ps1 / Invoke-SsgExpansion.ps1).
  Writes full detail under the workspace and prints a short summary only.
.EXAMPLE
  pwsh -NoProfile -File Test-ConverterFix.ps1 -FixId T3-035 -ExpansionPrograms SCAN_ASCII,TAPELD_ASCII
#>
param(
  [Parameter(Mandatory)][String]$FixId,
  [String[]]$ExpansionPrograms = @(),
  [String]$CardsDir = 'E:\Repos\ssg4-work\sgs-cards',
  [String]$Repo = 'E:\Repos\SsgTrial'
)
$ErrorActionPreference = 'Stop'
# pwsh -File passes "-ExpansionPrograms A,B" as the single string 'A,B'.
$ExpansionPrograms = @($ExpansionPrograms | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$work = Join-Path $Repo "_scratch\fix-$FixId"
$builtDll = Join-Path $work 'src\SsgConverter\bin\Debug\net10.0\SsgConverter.dll'
if (-not (Test-Path $builtDll)) { throw "No built DLL at $builtDll - run New-ConverterFix.ps1 first." }

$ex = Join-Path $Repo 'SsgConverter\Examples'
$con = Join-Path $work 'console'; $out = Join-Path $work 'out'
Remove-Item $con, $out -Recurse -Force -ErrorAction SilentlyContinue
robocopy (Join-Path $Repo 'SsgConverter\Build\Console') $con /E /NFL /NDL /NJH /NJS | Out-Null
Copy-Item $builtDll (Join-Path $con 'SsgConverter.dll') -Force
New-Item -ItemType Directory -Force -Path $out | Out-Null

$convertLog = Join-Path $work 'convert.log'
Write-Host ("[{0}] Converting Examples\Input (20 programs)..." -f (Get-Date -Format 'HH:mm:ss'))
dotnet (Join-Path $con 'SsgConverterConsole.dll') /INPUT:"$ex\Input" /OUTPUT:"$out" /CONTINUEONERROR:TRUE /VERBOSE:2 /ENABLELOGFILE:TRUE /LOGFILE:"$out" *> $convertLog
Write-Host ("[{0}] Conversion done." -f (Get-Date -Format 'HH:mm:ss'))

$harness = Join-Path $Repo 'SsgConverter\Trials\Tier1Mock\Run-SsgPsTrial.ps1'
$rows = foreach ($f in Get-ChildItem $out -Filter *.ps1 | Sort-Object Name) {
  Write-Host ("[{0}] {1}: parse + diff + Tier-1..." -f (Get-Date -Format 'HH:mm:ss'), $f.BaseName)
  $errs = $null; [void][System.Management.Automation.Language.Parser]::ParseFile($f.FullName, [ref]$null, [ref]$errs)
  $goldFile = Join-Path $ex "Output\$($f.Name)"
  $d = if (Test-Path $goldFile) { @(Compare-Object (Get-Content $goldFile) (Get-Content $f.FullName) -SyncWindow 0).Count } else { -1 }
  $r = & $harness -Program $f.BaseName -ScriptPath $f.FullName -OutDir (Join-Path $work "tier1\$($f.BaseName)") 6>$null
  [pscustomobject]@{ Program = $f.BaseName; Parse = $errs.Count; Differing = $d; Tier1 = $(if ($r.Failed) { 'THREW' } else { 'OK' }); Lines = $r.LineCount }
}
$rows | Export-Csv (Join-Path $work 'test-report.csv') -NoTypeInformation -Encoding utf8
$rows | Format-Table -AutoSize | Out-File (Join-Path $work 'test-summary.txt')

$diffLog = Join-Path $work 'changed-lines.log'
Remove-Item $diffLog -Force -ErrorAction SilentlyContinue
foreach ($r in $rows | Where-Object Differing -gt 0) {
  $goldFile = Join-Path $ex "Output\$($r.Program).ps1"; $newFile = Join-Path $out "$($r.Program).ps1"
  "---- $($r.Program)" | Out-File $diffLog -Append
  git diff --no-index --unified=0 $goldFile $newFile 2>$null | Select-Object -Skip 4 | Where-Object { $_ -match '^[-+]' } | Out-File $diffLog -Append
}

$expRows = @()
if ($ExpansionPrograms) {
  $calls = Import-Csv (Join-Path $CardsDir 'sgs-calls.csv') | Where-Object { $_.Converted -eq 'True' }
  $logDir = Join-Path $work 'logs'; New-Item -ItemType Directory -Force $logDir | Out-Null
  foreach ($key in $ExpansionPrograms) {
    $callRows = @($calls | Where-Object ProgramKey -eq $key)
    if (-not $callRows) { $expRows += [pscustomobject]@{ Program = $key; Exit = '-'; Failed = '-'; Detail = 'no exported call' }; continue }
    $call = $callRows[0]
    $expLog = Join-Path $logDir "$key.expand.log"
    Write-Host ("[{0}] {1}: real-card expansion..." -f (Get-Date -Format 'HH:mm:ss'), $key)
    pwsh -NoProfile -File (Join-Path $Repo 'Conversion\Pipeline\Invoke-SsgExpansion.ps1') -Program $key `
      -CardFile (Join-Path $CardsDir $call.CardFile) -OutFile (Join-Path $work "expanded\$key.cob") `
      -RunInfo "$($call.RunId),$($call.RunAccount),$($call.RunProject)" -ScriptPath (Join-Path $out "$key.ps1") *> $expLog
    $exit = $LASTEXITCODE
    Write-Host ("[{0}] {1}: expansion done (exit {2})" -f (Get-Date -Format 'HH:mm:ss'), $key, $exit)
    $text = (Get-Content $expLog -Raw) -replace "`e\[[0-9;]*m", ''
    $failed = [regex]::Match($text, 'Failed\s*:\s*(True|False)').Groups[1].Value
    $expRows += [pscustomobject]@{ Program = $key; Exit = $exit; Failed = $failed; Detail = '' }
  }
  $expRows | Export-Csv (Join-Path $work 'expansion-report.csv') -NoTypeInformation -Encoding utf8
}

"Workspace : $work"
"Convert log : $convertLog"
"Reports   : $work\test-report.csv, $work\test-summary.txt, $diffLog"
$failParse = @($rows | Where-Object { $_.Parse -gt 0 })
$failTier1 = @($rows | Where-Object { $_.Tier1 -ne 'OK' })
$changed = @($rows | Where-Object { $_.Differing -gt 0 })
"20-program check: $($rows.Count) converted, $($failParse.Count) parse failures, $($failTier1.Count) Tier-1 failures, $($changed.Count) differ from goldens"
if ($expRows) {
  $expFail = @($expRows | Where-Object { $_.Failed -eq 'True' -or ($_.Exit -ne 0 -and $_.Exit -ne '-') })
  "Real-card expansion: $($expRows.Count) checked, $($expFail.Count) failing$(if ($expFail) { ' (' + ($expFail.Program -join ', ') + ')' })"
}
