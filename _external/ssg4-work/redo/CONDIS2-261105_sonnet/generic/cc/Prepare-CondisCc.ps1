<#
.SYNOPSIS
  CONDIS2 step G8: stage the CC-Trial test of the generic program and write one CC script job, one runstream-style step
  per case (as R&D's ECL converter writes them). Written from the template (.github/skills/ssg-generic-utility/templates/Prepare-Cc.ps1);
  for use as Generic/CONDIS2/cc/Prepare-CondisCc.ps1. NOT RUN in the validation redo (no LionDev, Deliver or CC).
  Register in utilities.json: tests.prepare, tests.ccJobs and a "regress" entry (see utilities-entry.json).
.DESCRIPTION
  1. Checks the deployed set (skeleton with hand-off, include = source); refuses if not deployed.
  2. Stages each case's input under its own file name in the qualifier folder, and its cards as P$SGS\CN2<nn>.
  3. Writes <ScriptRoot>\ASSURFED_F999\RUN\SSG4_CONDIS2_CASES.ps1 (parse-checked).
  4. Writes <GenericWork>\CONDIS2\cc-cases.json: { Case, Actual, Expected } per output, for Test-CcJob.ps1.
  The cases are TEST DATA (check\cases): copies of the real calls' cards with synthetic records, and invented cards.
  Idempotent: clears and re-stages the qualifier each time (so run it before the job, never between job and check).
  The abort-* cases (the skeleton's own card checks) are not in this job: the hand-off Aborts there; they are covered by
  check\Test-CondisCases.ps1.
#>
param([String]$Environment = 'CC-Trial')
$ErrorActionPreference = 'Stop'
$utility = Split-Path $PSScriptRoot
$gn = Split-Path $utility
. "$gn\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$x = $ge.ExtractPath; $scripts = $ge.ScriptRoot; $work = "$($ge.GenericWork)\CONDIS2"
$Qual = 'CND2TEST'   # job log prefix too
$casesDir = "$utility\check\cases"
$cases = [ordered]@{}
$n = 0
foreach ($d in Get-ChildItem $casesDir -Directory | Where-Object { $_.Name -notlike 'abort-*' } | Sort-Object Name) { $n++; $cases[('{0:D2}' -f $n)] = $d.Name }

# 1. deployed set
$inc = "$scripts\ASSURFED_UTILIT\CondisParm.inc"
if (-not (Test-Path $inc) -or (Get-FileHash $inc).Hash -ne (Get-FileHash "$utility\gen\CondisParm.ps1").Hash) { throw 'Run Invoke-GnPipeline.ps1 -Stage Deploy first (include differs or missing)' }

# 2.-3. inputs, cards, job steps
New-Item -ItemType Directory -Force "$x\$Qual", "$x\P`$SGS", $work | Out-Null
Get-ChildItem "$x\$Qual" -File | Remove-Item -Force
$cc = @()
$body = foreach ($k in $cases.Keys) {
  $case = $cases[$k]
  $in = "CN2${k}I"; $out = "CN2${k}O"
  Copy-Item "$casesDir\$case\cards.sgs" "$x\P`$SGS\CN2$k" -Force
  Copy-Item "$casesDir\$case\input.dat" "$x\$Qual\$in" -Force
  $cc += [pscustomobject]@{ Case = $case; Actual = "$x\$Qual\$out"; Expected = "$casesDir\$case\expected\output.dat" }
  "  Msg `"`" (`"CONDIS2 case $k $case`")"
  "  Asg `"A`" (`"$in`")"
  "  Use (`"FILEIN`") (`"$in`")"
  "  Delete `"C`" (`"$out`")"; "  Asg `"P, U`" (`"$out`")"
  "  Use (`"FILEOUT`") (`"$out`")"
  "  Invoke-Ssg -Options `"I`" -Skeleton `"../../ASSURFED_UTILIT/UTILIT_CONDIS2_ASCII`" -SgsFile `"P```$SGS\CN2$k`""
  "  Xqt `"`" (`".CONDIS2`")"
  "  Free `"`" (`"$in`")"; "  Free `"`" (`"$out`")"
  ''
}
$job = @"
# SSG-4: the generic CONDIS2 program on $($cases.Count) cases (Prepare-CondisCc.ps1).
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsEclLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
Import-Module -Name (Join-Path `$PSScriptRoot '..\..\..\Libraries\AmtPsSortLib.psm1') -Force -DisableNameChecking -ErrorAction Stop
`$AmtSettingsFile = Join-Path `$PSScriptRoot '..\..\Settings\AmtSettings.xml'
Set-Jobname "$Qual"
Initialize `$AmtSettingsFile
Try {
  Qual "" "$Qual"
$($body -join "`r`n")
  Fin
} Catch [Exception] {
  HandleTrapAndAbort "Error trapped: " `$_
} Finally {
  Cleanup `$false
}
"@
$path = "$scripts\ASSURFED_F999\RUN\SSG4_CONDIS2_CASES.ps1"
[IO.File]::WriteAllText($path, $job)
$e = $null; [void][System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$null, [ref]$e)
if ($e.Count) { throw "SSG4_CONDIS2_CASES.ps1: $($e.Count) parse errors" }
# 4. check list
$cc | ConvertTo-Json | Set-Content "$work\cc-cases.json"
"SSG4_CONDIS2_CASES.ps1 written, $($cases.Count) steps, parse errors 0"
