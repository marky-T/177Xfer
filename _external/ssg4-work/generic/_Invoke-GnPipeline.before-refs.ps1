<#
.SYNOPSIS
  SSG-4 (MT-043): run one stage of the generic-program pipeline for one, several or all utilities in utilities.json.
.DESCRIPTION
  Stages (built one at a time; the plan is in .github\Copilot_Plans\261021-mt043-generic-pipeline-plan.md):
    Check   no side effects on AMT: utilities.json against the repo files, then each utility's parameter check (or offline check)
            run from its Generic folder; the result counts of its cross-check must equal the baseline in utilities.json.
    Deploy  writes the release deliverables into the environment's script set: settings (Deploy-GnScriptSet), then per utility each
            skeleton with its hand-off (Deploy-GnSkeleton) and the include; verifies parse, include and GnHandoff.inc hashes and the
            CloneReports entries. Test jobs and test data are not part of this stage (CcTest).
    Build   converts the generic programs' COBOL sources (utilities.json programSource) into ONE LionSource with the COBOL converter
            (Invoke-CobolConversion): source checks first (PROGRAM-ID, T3-040 input maximum 4001), then 0 errors required. Reports which
            sources changed since the last build and how the LionSource differs from it. Output: <GenericWork>\build\<BuildName>\out.
            LionDev import and generation stay manual; Deliver follows them.
    Deliver for the selected utilities' programs (-CheckOnly: pre-checks only): Deliver-GnPrograms checks each was regenerated after the
            build's LionSource (or -Since) and has 4001-byte inputs, rebuilds them against the 177a runtime, copies the DLLs to the
            application and hash-checks. When every program of the build was delivered, the LionSource is recorded as imported.LionSource
            (the next Build compares against it).
  Every run writes <GenericWork>\pipeline-<stage>-<time>.txt and prints a one-line-per-item table; the exit code is the number of failures.
.EXAMPLE
  Invoke-GnPipeline.ps1 -Stage Check
  Invoke-GnPipeline.ps1 -Stage Check -Utility BABA,FUSBA -Environment CC-Trial
#>
param(
  [Parameter(Mandatory)][ValidateSet('Check', 'Deploy', 'Build', 'Deliver')][String]$Stage,
  # 'All' or utility names; pwsh -File passes a list as one string, so commas are split here.
  [String[]]$Utility = 'All',
  [String]$Environment = 'CC-Trial',
  # Build: name of the LionSource file and of its work folder.
  [String]$BuildName = 'GNBUILD',
  # Deliver: generated programs must be newer than this (default: the build's LionSource); -CheckOnly stops before the rebuild.
  [Nullable[DateTime]]$Since,
  [Switch]$CheckOnly
)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\GnEnvironment.ps1"
$ge = Get-GnEnvironment $Environment
$catalog = Get-Content "$PSScriptRoot\utilities.json" -Raw | ConvertFrom-Json
$wanted = @($Utility | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$selected = if ($wanted -contains 'All') { @($catalog.utilities) } else { @($catalog.utilities | Where-Object { $_.utility -in $wanted }) }
foreach ($w in ($wanted | Where-Object { $_ -ne 'All' })) { if ($w -notin $catalog.utilities.utility) { throw "Unknown utility '$w' (known: $($catalog.utilities.utility -join ', '))" } }

$started = Get-Date
$rows = [Collections.Generic.List[Object]]::new()
function Add-Row([String]$Item, [String]$Check, [Boolean]$Ok, [String]$Detail) {
  $rows.Add([pscustomobject]@{ Item = $Item; Check = $Check; Result = $(if ($Ok) { 'PASS' } else { 'FAIL' }); Detail = $Detail })
}
function Invoke-Child([String]$Script, [String]$OutFile) {
  New-Item -ItemType Directory -Force (Split-Path $OutFile) | Out-Null
  & pwsh -NoProfile -File $Script -Environment $Environment *> $OutFile
  $LASTEXITCODE
}

switch ($Stage) {
  'Check' {
    $out = & pwsh -NoProfile -File "$PSScriptRoot\Test-GnUtilities.ps1" -Environment $Environment -SkipSettings
    Add-Row 'utilities.json' 'files and hand-off defaults' ($LASTEXITCODE -eq 0) (($out | Select-Object -First 3) -join ' / ')
    foreach ($u in $selected) {
      $script = if ($u.tests.parameterCheck) { $u.tests.parameterCheck } else { $u.tests.offline }
      $outFile = "$($ge.GenericWork)\$($u.folder)\pipeline-check.txt"
      $t0 = Get-Date
      $code = Invoke-Child "$PSScriptRoot\$script" $outFile
      if ($code -ne 0) { Add-Row $u.utility (Split-Path $script -Leaf) $false "exit code $code (see $outFile)"; continue }
      if ($u.check.crosscheck) {
        $csv = "$($ge.GenericWork)\$($u.folder)\crosscheck.csv"
        if (-not (Test-Path $csv) -or (Get-Item $csv).LastWriteTime -lt $t0) { Add-Row $u.utility 'cross-check' $false "crosscheck.csv not written by this run ($csv)"; continue }
        $got = @{}; foreach ($g in (Import-Csv $csv | Group-Object { ($_.Result -split ':')[0].Trim() })) { $got[$g.Name] = $g.Count }
        $want = @{}; foreach ($p in $u.check.crosscheck.PSObject.Properties) { $want[$p.Name] = [Int32]$p.Value }
        $diff = @(($got.Keys + $want.Keys) | Sort-Object -Unique | Where-Object { [Int32]$got[$_] -ne [Int32]$want[$_] } | ForEach-Object { "$_ $([Int32]$got[$_]) (baseline $([Int32]$want[$_]))" })
        $line = (($got.Keys | Sort-Object | ForEach-Object { "$_=$($got[$_])" }) -join ' ')
        Add-Row $u.utility 'cross-check vs baseline' (-not $diff) $(if ($diff) { $diff -join '; ' } else { "$line of $($u.calls) calls" })
      }
      if ($u.check.offlineOutput) {
        $text = Get-Content $outFile -Raw
        $missing = @($u.check.offlineOutput | Where-Object { -not $text.Contains($_) })
        Add-Row $u.utility 'offline check output' (-not $missing) $(if ($missing) { 'missing: ' + ($missing -join ' | ') } else { "$($u.check.offlineOutput.Count) expected lines found" })
      }
    }
  }
  'Deploy' {
    $target = Join-Path $ge.ScriptRoot 'ASSURFED_UTILIT'
    $set = & "$PSScriptRoot\Deploy-GnScriptSet.ps1" -Environment $Environment
    Add-Row 'script set' 'settings written' (@($set -match 'CloneReports').Count -gt 0) $ge.SettingsFile
    foreach ($u in $selected) {
      foreach ($s in $u.skeletons) {
        $name = "$($s.skeleton).ps1"
        try {
          $d = & "$PSScriptRoot\Deploy-GnSkeleton.ps1" -Skeleton $s.skeleton -ParmScript "$PSScriptRoot\$($u.includeSource)" -Call $s.call -Environment $Environment
          $parse = [Int32]$d.ParseErrors
        } catch { Add-Row $u.utility $name $false $_.Exception.Message; continue }
        $text = Get-Content "$target\$name" -Raw
        $inc = "$target\$($u.include).inc"
        $problems = @()
        if ($parse) { $problems += "$parse parse errors" }
        if (-not $text.Contains($s.call)) { $problems += 'hand-off call not in the skeleton' }
        if (-not (Test-Path $inc) -or (Get-FileHash $inc).Hash -ne (Get-FileHash "$PSScriptRoot\$($u.includeSource)").Hash) { $problems += "$($u.include).inc differs from its source" }
        Add-Row $u.utility $name (-not $problems) $(if ($problems) { $problems -join '; ' } else { "$($u.include).inc, $($s.call)" })
      }
    }
    $same = (Test-Path "$target\GnHandoff.inc") -and (Get-FileHash "$target\GnHandoff.inc").Hash -eq (Get-FileHash "$PSScriptRoot\GnHandoff.ps1").Hash
    Add-Row 'GnHandoff.inc' 'equals GnHandoff.ps1' $same $target
    $out = & pwsh -NoProfile -File "$PSScriptRoot\Test-GnUtilities.ps1" -Environment $Environment
    Add-Row 'settings' 'CloneReports == utilities.json' ($LASTEXITCODE -eq 0) (($out | Select-Object -First 3) -join ' / ')
  }
  'Build' {
    $dir = "$($ge.GenericWork)\build\$BuildName"
    $outFile = "$dir\out\$BuildName.LionSource"
    $prevFile = "$dir\previous.LionSource"
    $hashFile = "$dir\sources.csv"
    New-Item -ItemType Directory -Force $dir | Out-Null
    $lastHash = @{}; if (Test-Path $hashFile) { foreach ($r in Import-Csv $hashFile) { $lastHash[$r.Program] = $r.Sha256 } }
    $files = @(); $ids = @(); $hashes = @(); $ok = $true
    foreach ($u in $selected) {
      if (-not $u.programSource) { Add-Row $u.utility 'program source' $true "none: runs on $($u.usesProgramOf)'s program $($u.program)"; continue }
      $src = "$PSScriptRoot\$($u.programSource)"
      $text = Get-Content $src -Raw
      $id = ($u.program -replace '_', '-')
      $problems = @()
      if ($text -notmatch "PROGRAM-ID\.\s+'?$([regex]::Escape($id))'?") { $problems += "PROGRAM-ID is not $id" }
      if ($text -notmatch 'VARYING IN SIZE FROM 1 TO 4001') { $problems += 'no input FD VARYING 1 TO 4001 (T3-040)' }
      $sha = (Get-FileHash $src).Hash
      $state = if (-not $lastHash.ContainsKey($u.program)) { 'new since the last build' } elseif ($lastHash[$u.program] -ne $sha) { 'CHANGED since the last build' } else { 'unchanged since the last build' }
      Add-Row $u.utility 'program source' (-not $problems) $(if ($problems) { $problems -join '; ' } else { "$($u.program): $state" })
      if ($problems) { $ok = $false }
      $files += $src; $ids += $id; $hashes += [pscustomobject]@{ Program = $u.program; Sha256 = $sha }
    }
    if ($ok -and $files.Count) {
      if (Test-Path $outFile) { Copy-Item $outFile $prevFile -Force }
      $all = & "$PSScriptRoot\..\Invoke-CobolConversion.ps1" -CobolFile $files -ProgramId $ids -Name $BuildName -AppName AFBUS_2200COBOL -WorkDir $dir 2>&1
      $res = @($all | Where-Object { $_ -is [pscustomobject] -and $_.PSObject.Properties['Exit'] }) | Select-Object -Last 1
      if (-not $res) { Add-Row 'COBOL converter' 'result' $false (($all | Select-Object -Last 3) -join ' / ') }
      else {
        Add-Row 'COBOL converter' "$($files.Count) programs -> one LionSource" ($res.Exit -eq 0 -and $res.Errors -eq 0) "exit $($res.Exit), errors $($res.Errors), warnings $($res.Warnings), $([Math]::Round($res.OutBytes / 1KB)) KB$(if ($res.FirstError) { ', first error: ' + $res.FirstError })"
        if ($res.Exit -eq 0 -and $res.Errors -eq 0) {
          $keep = @($lastHash.Keys | Where-Object { $_ -notin $hashes.Program } | ForEach-Object { [pscustomobject]@{ Program = $_; Sha256 = $lastHash[$_] } })
          @($keep) + @($hashes) | Export-Csv $hashFile -NoTypeInformation
          $importedFile = "$dir\imported.LionSource"
          $ref = if (Test-Path $importedFile) { $importedFile } elseif (Test-Path $prevFile) { $prevFile }
          $refName = if ($ref -eq $importedFile) { 'the last imported build' } else { 'the previous build' }
          if ($ref) {
            $n = @(Compare-Object (Get-Content $ref | Where-Object { $_ -notmatch 'Application converted on' }) (Get-Content $outFile | Where-Object { $_ -notmatch 'Application converted on' })).Count
            # An unchanged LionSource keeps the reference's time, so Deliver's generated-after check still holds.
            if (-not $n) { (Get-Item $outFile).LastWriteTime = (Get-Item $ref).LastWriteTime }
            Add-Row 'LionSource' "vs $refName" $true $(if ($n) { "$n lines differ (import it)" } else { 'identical (nothing new to import)' })
          } else { Add-Row 'LionSource' 'vs the previous build' $true 'first build' }
          Add-Row 'LionSource' 'next (manual)' $true "LionDev: import $outFile, Get newest, start LionDevGenNet as administrator, generate from the repository; then -Stage Deliver"
        }
      }
    }
  }
  'Deliver' {
    $dir = "$($ge.GenericWork)\build\$BuildName"
    $outFile = "$dir\out\$BuildName.LionSource"
    $programs = @($selected | Where-Object programSource | ForEach-Object program)
    $sinceTime = if ($Since) { $Since } elseif (Test-Path $outFile) { (Get-Item $outFile).LastWriteTime }
    if (-not $programs) { Add-Row 'Deliver' 'programs' $false 'no selected utility has a program source'; break }
    if (-not $sinceTime) { Add-Row 'Deliver' 'generated after' $false "no LionSource at $outFile (run -Stage Build) and no -Since"; break }
    Add-Row 'Deliver' 'generated after' $true "$($sinceTime.ToString('yyyy-MM-dd HH:mm:ss')) ($(if ($Since) { '-Since' } else { 'the build LionSource' }))"
    $t0 = Get-Date
    $err = $null
    try { & "$PSScriptRoot\Deliver-GnPrograms.ps1" -Programs $programs -Since $sinceTime -Environment $Environment -CheckOnly:$CheckOnly | Out-Null } catch { $err = $_.Exception.Message }
    $tableFile = Get-ChildItem "$($ge.GenericWork)\deliver" -Filter 'deliver-*.txt' -ErrorAction SilentlyContinue | Where-Object LastWriteTime -ge $t0 | Sort-Object LastWriteTime | Select-Object -Last 1
    $lines = if ($tableFile) { @(Get-Content $tableFile.FullName) } else { @() }
    $allOk = $true
    foreach ($p in $programs) {
      $line = @($lines | Where-Object { $_ -like "$p *" }) | Select-Object -First 1
      $ok = $line -and $line -notmatch 'FAIL' -and ($CheckOnly -or $line -match 'yes, hash ok')
      if (-not $ok) { $allOk = $false }
      Add-Row $p $(if ($CheckOnly) { 'pre-build checks' } else { 'rebuilt and delivered' }) ([Boolean]$ok) $(if ($line) { ($line.Substring($p.Length) -replace '\s+', ' ').Trim() } else { 'not in the Deliver-GnPrograms table' })
    }
    if ($err) { Add-Row 'Deliver-GnPrograms' 'run' $false $err }
    elseif ($allOk -and -not $CheckOnly) {
      $everyProgram = @($catalog.utilities | Where-Object programSource | ForEach-Object program)
      if (-not @($everyProgram | Where-Object { $_ -notin $programs }).Count -and (Test-Path $outFile)) {
        Copy-Item $outFile "$dir\imported.LionSource" -Force
        Add-Row 'LionSource' 'recorded as imported' $true "$dir\imported.LionSource (the next Build compares against it)"
      } else { Add-Row 'LionSource' 'recorded as imported' $true 'not recorded: a subset of the programs was delivered' }
    }
  }
}

$failed = @($rows | Where-Object Result -eq 'FAIL').Count
$report = @("Stage $Stage, environment $Environment, started $($started.ToString('yyyy-MM-dd HH:mm:ss'))") + @($rows | ForEach-Object { '{0,-4} {1,-14} {2,-30} {3}' -f $_.Result, $_.Item, $_.Check, $_.Detail }) + "=== $Stage : $(if ($failed) { "$failed failure(s)" } else { 'all passed' })"
$reportFile = "$($ge.GenericWork)\pipeline-$($Stage.ToLower())-$($started.ToString('yyyyMMdd-HHmmss')).txt"
$report | Set-Content $reportFile
$report
"report: $reportFile"
exit $failed
