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
    Regress the Control Center regression of the delivered programs, one utility at a time or all. Without -Job it runs the selected
            utilities' prepare scripts (not with -Status), then lists each job in utilities.json "regress" with its last result and
            whether that PASS is newer than the last delivery; the exit code is the number of jobs without a current PASS. A job is
            started in Control Center (ccStartJob or the Start Job tab); then -Job <name> [-JobParam P] -StartLine '<line ccStartJob
            returned>' waits for it, scans its log, byte-compares its outputs (and prints / extra checks) and records the result in
            <GenericWork>\regress-results.csv; evidence goes to <GenericWork>\regress\<job>.
    Package stages the release folder <PackageRoot>\GN-<time> for -Target (default CC-Federale), nothing is installed. It does not
            judge the state of the work: the last regression result of each job and the imported LionSource hashes go into
            RELEASE-NOTES.txt for R&D. Holds the 7 program DLLs, the application DLLs, the skeletons with hand-off and includes (from the
            deployed set), CloneReports.xml, RELEASE-NOTES.txt, INSTALL.txt and manifest.csv (SHA256). Fails only when a file to copy is
            missing. Test jobs, test data and reference programs are left out.
  Every run writes <GenericWork>\pipeline-<stage>-<time>.txt and prints a one-line-per-item table; the exit code is the number of failures.
.EXAMPLE
  Invoke-GnPipeline.ps1 -Stage Check
  Invoke-GnPipeline.ps1 -Stage Check -Utility BABA,FUSBA -Environment CC-Trial
#>
param(
  [Parameter(Mandatory)][ValidateSet('Check', 'Deploy', 'Build', 'Deliver', 'Regress', 'Package')][String]$Stage,
  # 'All' or utility names; pwsh -File passes a list as one string, so commas are split here.
  [String[]]$Utility = 'All',
  [String]$Environment = 'CC-Trial',
  # Build: name of the LionSource file and of its work folder.
  [String]$BuildName = 'GNBUILD',
  # Build/Deliver: the test-only reference programs (utilities.json "references") go into a second LionSource.
  [String]$RefBuildName = 'GNREF',
  # Build/Deliver: leave the reference programs out (a build for the client application, e.g. -Environment CC-Federale).
  [Switch]$NoReferences,
  # Deliver: generated programs must be newer than this (default: the build's LionSource); -CheckOnly stops before the rebuild.
  [Nullable[DateTime]]$Since,
  [Switch]$CheckOnly,
  # Regress: -Job (+ -JobParam) with -StartLine checks one CC job; -Status only shows the table instead of preparing first.
  [String]$Job,
  [String]$JobParam,
  [String]$StartLine,
  [Switch]$Status,
  # Package: environment profile the package is made for (install steps and paths come from it).
  [String]$Target = 'CC-Federale',
  # Package: lines for RELEASE-NOTES.txt naming the Control Center proof of this build (job ids, result).
  [String[]]$Proof
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
    function Get-BuildState([String]$Name, [String]$Program, [String]$Sha) {
      $f = "$($ge.GenericWork)\build\$Name\sources.csv"
      $last = if (Test-Path $f) { @(Import-Csv $f | Where-Object Program -eq $Program) | Select-Object -First 1 }
      if (-not $last) { 'new since the last build' } elseif ($last.Sha256 -ne $Sha) { 'CHANGED since the last build' } else { 'unchanged since the last build' }
    }
    # Sources: objects {Program, Id, File, Sha}; returns the LionSource path when the converter passed.
    function Invoke-LionBuild([String]$Name, [String]$Label, [Object[]]$Sources) {
      $dir = "$($ge.GenericWork)\build\$Name"
      $outFile = "$dir\out\$Name.LionSource"
      $prevFile = "$dir\previous.LionSource"
      $hashFile = "$dir\sources.csv"
      New-Item -ItemType Directory -Force $dir | Out-Null
      if (Test-Path $outFile) { Copy-Item $outFile $prevFile -Force }
      $all = & "$PSScriptRoot\..\Invoke-CobolConversion.ps1" -CobolFile @($Sources.File) -ProgramId @($Sources.Id) -Name $Name -AppName $ge.LionApp -WorkDir $dir 2>&1
      $res = @($all | Where-Object { $_ -is [pscustomobject] -and $_.PSObject.Properties['Exit'] }) | Select-Object -Last 1
      if (-not $res) { Add-Row "COBOL converter $Label" 'result' $false (($all | Select-Object -Last 3) -join ' / '); return }
      $good = $res.Exit -eq 0 -and $res.Errors -eq 0
      Add-Row "COBOL converter $Label" "$(@($Sources).Count) programs -> $Name.LionSource" $good "exit $($res.Exit), errors $($res.Errors), warnings $($res.Warnings), $([Math]::Round($res.OutBytes / 1KB)) KB$(if ($res.FirstError) { ', first error: ' + $res.FirstError })"
      if (-not $good) { return }
      $old = if (Test-Path $hashFile) { @(Import-Csv $hashFile) } else { @() }
      @($old | Where-Object { $_.Program -notin $Sources.Program }) + @($Sources | ForEach-Object { [pscustomobject]@{ Program = $_.Program; Sha256 = $_.Sha } }) | Export-Csv $hashFile -NoTypeInformation
      $importedFile = "$dir\imported.LionSource"
      $ref = if (Test-Path $importedFile) { $importedFile } elseif (Test-Path $prevFile) { $prevFile }
      $refName = if ($ref -eq $importedFile) { 'the last imported build' } else { 'the previous build' }
      if ($ref) {
        $n = @(Compare-Object (Get-Content $ref | Where-Object { $_ -notmatch 'Application converted on' }) (Get-Content $outFile | Where-Object { $_ -notmatch 'Application converted on' })).Count
        # An unchanged LionSource keeps the reference's time, so Deliver's generated-after check still holds.
        if (-not $n) { (Get-Item $outFile).LastWriteTime = (Get-Item $ref).LastWriteTime }
        Add-Row "LionSource $Label" "vs $refName" $true $(if ($n) { "$n lines differ (import it)" } else { 'identical (nothing new to import)' })
      } else { Add-Row "LionSource $Label" 'vs the previous build' $true 'first build' }
      $outFile
    }

    $gn = @(); $ok = $true
    foreach ($u in $selected) {
      if (-not $u.programSource) { Add-Row $u.utility 'program source' $true "none: runs on $($u.usesProgramOf)'s program $($u.program)"; continue }
      $src = "$PSScriptRoot\$($u.programSource)"
      $text = Get-Content $src -Raw
      $id = ($u.program -replace '_', '-')
      $problems = @()
      if ($text -notmatch "PROGRAM-ID\.\s+'?$([regex]::Escape($id))'?") { $problems += "PROGRAM-ID is not $id" }
      if ($text -notmatch 'VARYING IN SIZE FROM 1 TO 4001') { $problems += 'no input FD VARYING 1 TO 4001 (T3-040)' }
      $sha = (Get-FileHash $src).Hash
      Add-Row $u.utility 'program source' (-not $problems) $(if ($problems) { $problems -join '; ' } else { "$($u.program): $(Get-BuildState $BuildName $u.program $sha)" })
      if ($problems) { $ok = $false }
      $gn += [pscustomobject]@{ Program = $u.program; Id = $id; File = $src; Sha = $sha }
    }
    $refs = @()
    foreach ($g in @($catalog.references | Where-Object { -not $NoReferences -and @($_.utilities | Where-Object { $_ -in $selected.utility }).Count })) {
      try { $made = @(& "$PSScriptRoot\$($g.builder)" -Environment $Environment -RefsOnly) } catch { Add-Row $g.name 'reference sources' $false $_.Exception.Message; $ok = $false; continue }
      $want = @($g.programs | ForEach-Object { $_ -replace '_', '-' } | Sort-Object); $got = @($made.Id | Sort-Object)
      if (($want -join ',') -ne ($got -join ',')) { Add-Row $g.name 'reference sources' $false "builder returned [$($got -join ', ')], utilities.json lists [$($want -join ', ')]"; $ok = $false; continue }
      foreach ($m in $made) {
        $sha = (Get-FileHash $m.File).Hash
        Add-Row $g.name $m.Id.Replace('ASSURFED-UTILIT-', '') $true "reference: $(Get-BuildState $RefBuildName $m.Id $sha)"
        $refs += [pscustomobject]@{ Program = $m.Id; Id = $m.Id; File = $m.File; Sha = $sha }
      }
    }
    $built = @()
    if ($ok -and $gn.Count) { $o = Invoke-LionBuild $BuildName '(programs)' $gn; if ($o) { $built += $o } }
    if ($ok -and $refs.Count) { $o = Invoke-LionBuild $RefBuildName '(references)' $refs; if ($o) { $built += $o } }
    if ($built.Count) { Add-Row 'LionSource' 'next (manual)' $true "LionDev: import $($built -join ' and ') (any order), Get newest, start LionDevGenNet as administrator, generate from the repository; then -Stage Deliver" }
  }
  'Deliver' {
    $sets = @()
    $gnPrograms = @($selected | Where-Object programSource | ForEach-Object program)
    if ($gnPrograms) { $sets += [pscustomobject]@{ Name = $BuildName; Programs = $gnPrograms; All = @($catalog.utilities | Where-Object programSource | ForEach-Object program); Static = $false } }
    $refPrograms = @($catalog.references | Where-Object { -not $NoReferences -and @($_.utilities | Where-Object { $_ -in $selected.utility }).Count } | ForEach-Object { $_.programs })
    if ($refPrograms) { $sets += [pscustomobject]@{ Name = $RefBuildName; Programs = $refPrograms; All = @($catalog.references | ForEach-Object { $_.programs }); Static = $true } }
    if (-not $sets) { Add-Row 'Deliver' 'programs' $false 'no selected utility has a program source'; break }
    foreach ($s in $sets) {
      $dir = "$($ge.GenericWork)\build\$($s.Name)"
      $outFile = "$dir\out\$($s.Name).LionSource"
      $sinceTime = if ($Since) { $Since } elseif (Test-Path $outFile) { (Get-Item $outFile).LastWriteTime }
      if (-not $sinceTime) { Add-Row $s.Name 'generated after' $false "no LionSource at $outFile (run -Stage Build) and no -Since"; continue }
      Add-Row $s.Name 'generated after' $true "$($sinceTime.ToString('yyyy-MM-dd HH:mm:ss')) ($(if ($Since) { '-Since' } else { 'the build LionSource' }))"
      # Whole-system generation rewrites every program, so only a rising revision (Info.cs) shows that LionDev imported this LionSource.
      $folderOf = { param($n) ($n.ToLowerInvariant() -split '_' | ForEach-Object { $_.Substring(0, 1).ToUpperInvariant() + $_.Substring(1) }) -join '_' }
      $revOf = { param($p) $f = & $folderOf $p; $i = "$($ge.LionDevelopment)\Programs\$f\${f}_Info.cs"; if (Test-Path $i) { $m = [regex]::Match((Get-Content $i -Raw), 'AssemblyFileVersion\("([\d.]+)"'); if ($m.Success) { [Version]$m.Groups[1].Value } } }
      $verFile = "$dir\delivered-versions.csv"
      $impFile = "$dir\imported.LionSource"
      $partFile = "$dir\delivered-partial.LionSource"
      $cmpFile = if (Test-Path $impFile) { $impFile } elseif (Test-Path $partFile) { $partFile } else { $impFile }
      $isNew = -not (Test-Path $cmpFile) -or -not (Test-Path $outFile) -or @(Compare-Object (Get-Content $cmpFile | Where-Object { $_ -notmatch 'Application converted on' }) (Get-Content $outFile | Where-Object { $_ -notmatch 'Application converted on' })).Count
      $base = @{}; if (Test-Path $verFile) { foreach ($r in Import-Csv $verFile) { $base[$r.Program] = [Version]$r.Version } }
      $stale = @(); if ($isNew) { foreach ($p in $s.Programs) { $now = & $revOf $p; if ($base.ContainsKey($p) -and (-not $now -or $now -le $base[$p])) { $stale += "$p still $now" } } }
      Add-Row $s.Name 'imported since the last delivery' (-not $stale) $(if ($stale) { "revision unchanged ($($stale -join '; ')): this LionSource differs from the last delivered one, so import it in LionDev and generate again" } elseif (-not $isNew) { 'nothing new to import' } elseif ($base.Count) { 'every revision is newer' } else { 'no earlier delivery recorded: revisions not checked' })
      if ($stale) { continue }
      $t0 = Get-Date
      $err = $null
      try { & "$PSScriptRoot\Deliver-GnPrograms.ps1" -Programs $s.Programs -Since $sinceTime -Environment $Environment -CheckOnly:$CheckOnly -SkipInputCheck:$s.Static | Out-Null } catch { $err = $_.Exception.Message }
      $tableFile = Get-ChildItem "$($ge.GenericWork)\deliver" -Filter 'deliver-*.txt' -ErrorAction SilentlyContinue | Where-Object LastWriteTime -ge $t0 | Sort-Object LastWriteTime | Select-Object -Last 1
      $lines = if ($tableFile) { @(Get-Content $tableFile.FullName) } else { @() }
      $allOk = $true
      foreach ($p in $s.Programs) {
        $line = @($lines | Where-Object { $_ -like "$p *" }) | Select-Object -First 1
        $ok = $line -and $line -notmatch 'FAIL' -and ($CheckOnly -or $line -match 'yes, hash ok')
        if (-not $ok) { $allOk = $false }
        Add-Row $p $(if ($CheckOnly) { 'pre-build checks' } else { 'rebuilt and delivered' }) ([Boolean]$ok) $(if ($line) { ($line.Substring($p.Length) -replace '\s+', ' ').Trim() } else { 'not in the Deliver-GnPrograms table' })
      }
      if ($err) { Add-Row 'Deliver-GnPrograms' "run ($($s.Name))" $false $err }
      elseif ($allOk -and -not $CheckOnly) {
        @(@($base.Keys | Where-Object { $_ -notin $s.Programs } | ForEach-Object { [pscustomobject]@{ Program = $_; Version = $base[$_] } }) + @($s.Programs | ForEach-Object { [pscustomobject]@{ Program = $_; Version = (& $revOf $_) } })) | Export-Csv $verFile -NoTypeInformation
        if (-not @($s.All | Where-Object { $_ -notin $s.Programs }).Count -and (Test-Path $outFile)) {
          Copy-Item $outFile "$dir\imported.LionSource" -Force
          Remove-Item $partFile -ErrorAction SilentlyContinue
          Add-Row 'LionSource' "$($s.Name) recorded as imported" $true "$dir\imported.LionSource (the next Build compares against it)"
        } else { if (Test-Path $outFile) { Copy-Item $outFile $partFile -Force }; Add-Row 'LionSource' "$($s.Name) recorded as imported" $true 'not recorded: a subset of the programs was delivered (kept as delivered-partial.LionSource)' }
      }
    }
  }
  'Regress' {
    $work = $ge.GenericWork
    $resFile = "$work\regress-results.csv"
    $steps = @($catalog.regress | Where-Object { @($_.utilities | Where-Object { $_ -in $selected.utility }).Count })
    $keyOf = { param($j, $p) if ($p) { "$j [$p]" } else { $j } }
    $last = @{}; if (Test-Path $resFile) { foreach ($r in Import-Csv $resFile) { $last[$r.Key] = $r } }
    $deliveredAt = @(Get-ChildItem "$work\build\*\delivered-versions.csv" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime | Select-Object -Last 1).LastWriteTime
    function Invoke-Check([String]$Script, [String[]]$Arguments, [String]$OutFile) {
      New-Item -ItemType Directory -Force (Split-Path $OutFile) | Out-Null
      & pwsh -NoProfile -File $Script @Arguments -Environment $Environment *> $OutFile
      $LASTEXITCODE
    }
    if ($Job) {
      $step = @($steps | Where-Object { $_.job -eq $Job -and [String]$_.param -eq [String]$JobParam }) | Select-Object -First 1
      if (-not $step) { Add-Row $Job 'regression' $false "no such step for the selected utilities (param '$JobParam')"; break }
      if (-not $StartLine) { Add-Row $Job 'regression' $false "pass -StartLine with the line ccStartJob returned, unchanged: 'JOB: started yyyy-MM-dd HH:mm:ss'"; break }
      $k = & $keyOf $step.job $step.param
      $ev = "$work\regress\$($k -replace '[^\w-]+', '_')"
      $ok = $true; $detail = @()
      $a = @('-Job', $step.job, '-LogPrefix', $step.logPrefix, '-After', $StartLine, '-Evidence', $ev)
      if ($step.cases) { $a += @('-Cases', "$work\$($step.cases)") }
      $code = Invoke-Check "$PSScriptRoot\Test-CcJob.ps1" $a "$ev\job.txt"
      if ($step.expectError) { $detail += 'job ended in Error as expected' } else {
        if ($code) { $ok = $false }
        $detail += @(Get-Content "$ev\job.txt" | Where-Object { $_ -match 'byte-identical|^=== |problem' } | Select-Object -Last 2 | ForEach-Object { $_.Trim() })
      }
      if ($step.prints) {
        $code = Invoke-Check "$PSScriptRoot\Test-CcPrints.ps1" @('-After', $StartLine, '-Cases', "$work\$($step.prints)", '-Evidence', "$ev\prints", '-Folder', "$($ge.ExtractPath)\PRINTCAP") "$ev\prints.txt"
        if ($code) { $ok = $false }
        $detail += @(Get-Content "$ev\prints.txt" | Where-Object { $_ -match '^=== |PRN files' } | ForEach-Object { $_.Trim() })
      }
      if ($step.check) {
        $a = @($step.check.args | Where-Object { $_ }); if ($step.check.after) { $a += @('-After', $StartLine) }
        $code = Invoke-Check "$PSScriptRoot\$($step.check.script)" $a "$ev\check.txt"
        if ($code) { $ok = $false }
        $detail += @(Get-Content "$ev\check.txt" | Where-Object { $_ -match 'pass$|problems:|PASS|FAIL' } | Select-Object -Last 1 | ForEach-Object { $_.Trim() })
      }
      $text = ($detail -join ' | ')
      Add-Row $k 'regression' $ok $text
      [pscustomobject]@{ Key = $k; Time = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'); Result = $(if ($ok) { 'PASS' } else { 'FAIL' }); Started = $StartLine; Detail = $text } | Export-Csv $resFile -Append -NoTypeInformation
    } else {
      if (-not $Status) {
        $prep = @($selected | ForEach-Object { $_.tests.prepare } | Where-Object { $_ } | Select-Object -Unique)
        foreach ($p in $prep) { $code = Invoke-Child "$PSScriptRoot\$p" "$work\regress\prepare-$(Split-Path $p -Leaf).txt"; Add-Row 'prepare' (Split-Path $p -Leaf) ($code -eq 0) $(if ($code) { "exit code $code" } else { 'inputs, job scripts and hand-offs staged' }) }
      }
      foreach ($step in $steps) {
        $k = & $keyOf $step.job $step.param
        $r = $last[$k]
        $current = $r -and $r.Result -eq 'PASS' -and (-not $deliveredAt -or [DateTime]$r.Time -ge $deliveredAt)
        $start = "-Job $($step.job)$(if ($step.param) { ' -JobParam ' + $step.param }) -StartLine '<ccStartJob line>'"
        Add-Row $k 'regression' ([Boolean]$current) $(if ($current) { "PASS $($r.Time): $($r.Detail)" } elseif ($r -and $r.Result -eq 'PASS') { "PASS $($r.Time) is older than the last delivery ($($deliveredAt.ToString('yyyy-MM-dd HH:mm:ss'))): run again" } elseif ($r) { "last run $($r.Time) FAILED: $($r.Detail)" } else { "not run yet: start it in CC (ccStartJob '$($step.job)'$(if ($step.param) { ", '$($step.param)'" })), then -Stage Regress $start" })
      }
    }
  }
  'Package' {
    $work = $ge.GenericWork
    $tgt = Get-GnEnvironment $Target
    $root = $ge.PackageRoot
    if ($root -notlike 'E:\AMT_Work\*') { throw "PackageRoot must be under E:\AMT_Work (was $root)." }
    # Information for R&D, not a gate: the package holds what is deployed and delivered now.
    $res = @{}; if (Test-Path "$work\regress-results.csv") { foreach ($r in Import-Csv "$work\regress-results.csv") { $res[$r.Key] = $r } }
    $deliveredAt = @(Get-ChildItem "$work\build\*\delivered-versions.csv" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime | Select-Object -Last 1).LastWriteTime
    $regStatus = @(foreach ($s in @($catalog.regress | Where-Object { @($_.utilities | Where-Object { $_ -in $selected.utility }).Count })) {
        $k = if ($s.param) { "$($s.job) [$($s.param)]" } else { $s.job }; $r = $res[$k]
        $state = if (-not $r) { 'not run' } elseif ($r.Result -ne 'PASS') { 'FAILED' } elseif ($deliveredAt -and [DateTime]$r.Time -lt $deliveredAt) { 'PASS, before the last delivery' } else { 'PASS' }
        [pscustomobject]@{ Key = $k; Time = $r.Time; State = $state } })
    $notPass = @($regStatus | Where-Object State -ne 'PASS')
    Add-Row 'Package' 'regression (information)' $true $(if ($notPass) { "$($notPass.Count) of $($regStatus.Count) jobs not passed since the last delivery, listed in RELEASE-NOTES.txt" } else { "all $($regStatus.Count) jobs passed since the last delivery" })
    $imp = @(foreach ($n in $BuildName) { $i = "$work\build\$n\imported.LionSource"; $o = "$work\build\$n\out\$n.LionSource"; if (Test-Path $i) { "  $n  SHA256 $((Get-FileHash $i).Hash)" } elseif (Test-Path $o) { "  $n  SHA256 $((Get-FileHash $o).Hash) (the build; not recorded as imported because only some programs were delivered)" } else { "  $n  no imported record" } })
    # Built for the target application itself: the programs use its own application DLLs, so none are shipped.
    $ownApp = $ge.Name -eq $tgt.Name

    $stamp = Get-Date -Format 'yyyyMMdd-HHmm'
    $tag = if ($wanted -contains 'All') { '' } else { '-' + (($selected.utility -join '_') -replace '[^\w-]', '') }
    $pkg = "$root\GN-$stamp$tag"
    $prg = "$pkg\Binaries\Programs"; $app = "$pkg\Binaries\Application"
    # Same relative place as in the script set: the runstreams call ../../ASSURFED_UTILIT/UTILIT_<X>.
    $scr = "$pkg\Scripts\ASSURFED_UTILIT"
    New-Item -ItemType Directory -Force $prg, $scr | Out-Null
    if (-not $ownApp) { New-Item -ItemType Directory -Force $app | Out-Null }
    $programs = @($selected | ForEach-Object program | Select-Object -Unique)
    $diff = @(foreach ($p in $programs) {
        $src = "$($ge.ProgramsPath)\$p.dll"
        if (-not (Test-Path $src)) { "$p missing in the application"; continue }
        Copy-Item $src $prg
        $rb = "$($ge.RebuildPrograms)\$p.dll"; if ((Test-Path $rb) -and (Get-FileHash $rb).Hash -ne (Get-FileHash $src).Hash) { "$p differs from the 177a rebuild" } })
    Add-Row 'Package' "$($programs.Count) program DLLs" (-not $diff) $(if ($diff) { $diff -join '; ' } else { 'copied from the application, equal to the 177a rebuild' })
    # The 177a rebuild's application DLLs (the application's own Application folder can hold the 177 originals used for the reorganize).
    $rbApp = "$($ge.RebuildRoot)\$($ge.LionApp)\Binaries\Application"
    if (-not $ownApp) { Get-ChildItem $rbApp -File | Copy-Item -Destination $app }
    $skel = @($selected | ForEach-Object { $_.skeletons } | ForEach-Object { "$($_.skeleton).ps1" })
    $inc = @($selected | ForEach-Object { "$($_.include).inc" }) + 'GnHandoff.inc' | Select-Object -Unique
    $missing = @(foreach ($n in $skel + $inc) { if (Test-Path "$($ge.ScriptRoot)\ASSURFED_UTILIT\$n") { Copy-Item "$($ge.ScriptRoot)\ASSURFED_UTILIT\$n" $scr } else { $n } })
    Add-Row 'Package' "$($skel.Count) skeletons, $($inc.Count) includes" (-not $missing) $(if ($missing) { 'missing in the deployed set: ' + ($missing -join ', ') } else { 'copied from the deployed (proven) set' })
    $x = [xml]'<CloneReports/>'
    foreach ($u in $selected) { foreach ($name in $u.xqt) { $e = $x.CreateElement('OrginalReport'); $e.SetAttribute('Name', $u.program); $e.SetAttribute('Clone', $name); [void]$x.DocumentElement.AppendChild($e) } }
    $x.Save("$pkg\CloneReports.xml")
    # Federale maintains the PowerShell and the C# of its migrated application and does not convert again: the C# that built the DLLs goes along.
    $csDir = "$pkg\Sources\CSharp"; $cobDir = "$pkg\Reference\Cobol"; New-Item -ItemType Directory -Force $csDir, $cobDir | Out-Null
    $appHint = '..\..\..\Binaries\Application'; $nsHint = '..\..\..\Binaries\Application\Newtonsoft.Json.dll'
    if ($ownApp) { New-Item -ItemType Directory -Force "$csDir\lib" | Out-Null; Copy-Item "$rbApp\Newtonsoft.Json.dll" "$csDir\lib"; $appHint = '$(AmtApplicationDir)'; $nsHint = '..\lib\Newtonsoft.Json.dll' }
    $noSrc = @(foreach ($p in $programs) {
        $fo = ($p.ToLowerInvariant() -split '_' | ForEach-Object { $_.Substring(0, 1).ToUpperInvariant() + $_.Substring(1) }) -join '_'
        $d = "$($ge.RebuildRoot)\$($ge.LionApp)\Development\Programs\$fo"
        if (Test-Path $d) { Copy-Item $d "$csDir\$fo" -Recurse; Get-ChildItem "$csDir\$fo" -Recurse -Include *.csproj.user | Remove-Item -Force } else { $p } })
    # Visual Studio: runtime DLLs through one property (Directory.Build.props), application DLLs and Newtonsoft from this package, relative.
    foreach ($pj in Get-ChildItem $csDir -Recurse -Filter *.csproj) {
        $c = [IO.File]::ReadAllText($pj.FullName)
        $c = [regex]::Replace($c, '<HintPath>[^<]*\\Rebuild177a[^<]*\\lib\\([^<\\]+)</HintPath>', '<HintPath>$(AmtRuntimeDir)\$1</HintPath>')
        $c = [regex]::Replace($c, '<HintPath>[^<]*Newtonsoft\.Json\.dll</HintPath>', "<HintPath>$nsHint</HintPath>")
        $c = [regex]::Replace($c, '<ProjectReference Include="[^"]*\\(' + [regex]::Escape($ge.LionApp) + '\.(?:Application|Database))\.csproj">\s*</ProjectReference>', "<Reference Include=`"`$1`"><HintPath>$appHint\`$1.dll</HintPath><Private>false</Private></Reference>")
        [IO.File]::WriteAllText($pj.FullName, $c)
    }
    @"
<Project>
  <PropertyGroup>
    <!-- Folder with the runtime DLLs (Asysco.Amt.*, ComScript, ...) of your application; change it here or build with -p:AmtRuntimeDir=... -->
    <AmtRuntimeDir Condition="'`$(AmtRuntimeDir)' == ''">$($tgt.ProgramsPath)</AmtRuntimeDir>
$(if ($ownApp) { "    <!-- Folder with your application's own $($tgt.LionApp).Application/Database DLLs -->`r`n    <AmtApplicationDir Condition=`"'`$(AmtApplicationDir)' == ''`">$($tgt.AppBasepath)\Application</AmtApplicationDir>" })
  </PropertyGroup>
</Project>
"@ | Set-Content "$csDir\Directory.Build.props"
    Push-Location $csDir
    try { & dotnet new sln -n GenericPrograms --format sln *> $null; foreach ($pj in Get-ChildItem $csDir -Recurse -Filter *.csproj) { & dotnet sln GenericPrograms.sln add $pj.FullName *> $null } } finally { Pop-Location }
    Add-Row 'Package' "$($programs.Count) C# project folders" (-not $noSrc) $(if ($noSrc) { 'no rebuilt source for: ' + ($noSrc -join ', ') } else { 'the C# the delivered DLLs were built from (177a rebuild)' })
    foreach ($u in $selected) { if ($u.programSource) { Copy-Item "$PSScriptRoot\$($u.programSource)" $cobDir } }
    @"
Maintaining these programs after hand-over (Federale maintains the PowerShell and the C#; nothing is converted again).
- A call's cards: read at run time from the parameter file the hand-off writes. Changing a call means changing its runstream cards; nothing is rebuilt.
- Hand-off and parameter file layout (PowerShell): the .inc files in Scripts\ASSURFED_UTILIT, edited in place. GnHandoff.inc is the common part
  (parameter file, Free/Asg/Use, record sizes). A skeleton is R&D's converted skeleton with the hand-off call inserted after param(), then return.
- Program logic (C#): open Sources\CSharp\GenericPrograms.sln in Visual Studio ($($programs.Count) project(s), net10.0). They are the project folders the delivered
  DLLs were built from, for the 177a runtime; the one change to the generated code is marked REBUILT-FOR-177A (generation date and time dropped
  from the base(...) call). Set AmtRuntimeDir in Sources\CSharp\Directory.Build.props to the folder with your runtime DLLs (Asysco.Amt.*,
  ComScript, ...), or build with -p:AmtRuntimeDir=...; $(if ($ownApp) { "the application DLLs come from AmtApplicationDir (your own $($tgt.LionApp).Application/Database) and Newtonsoft.Json from Sources\CSharp\lib." } else { 'the application DLLs and Newtonsoft.Json come from Binaries\Application in this package.' })
  Built unchanged against the Federale runtime folder, the projects give the delivered DLLs byte for byte. Output goes to Binaries\Programs.
- Keep every input file's record maximum at 4001 (AmtVarAlpha(4001, ...) in the Fd_*.cs files; T3-040), or long cards are cut.
- Which program an Xqt name starts: CloneReports in AmtSettings.xml (CloneReports.xml here). In the run history the program appears as a child job
  named after the Xqt (e.g. CFH_COPY, TPF`$ for TAPELD), "Started by" the calling parent runstream, not as ASSURFED_UTILIT_*_GN.
- Reference\Cobol: the COBOL each program was generated from, for reading only; it is not maintained.
- Re-test after a change: compare outputs byte for byte against known-good results. The Control Center regression used for this release (14 jobs) is not part of this package.
"@ | Set-Content "$pkg\MAINTENANCE.txt"
    $vers = @{}; foreach ($n in $BuildName, $RefBuildName) { $vf = "$work\build\$n\delivered-versions.csv"; if (Test-Path $vf) { foreach ($r in Import-Csv $vf) { $vers[$r.Program] = $r.Version } } }
    $res = @{}; if (Test-Path "$work\regress-results.csv") { foreach ($r in Import-Csv "$work\regress-results.csv") { $res[$r.Key] = $r } }
    $tp = $tgt.ProgramsPath; $ts = $tgt.ScriptRoot; $tset = Join-Path $tgt.ScriptRoot 'Settings\AmtSettings.xml'
    @"
Generic utility programs (SSG-4, MT-043) for $($tgt.AppName), packaged $stamp from $Environment ($($ge.AppName)).
Nothing in this folder has been copied into $($tgt.AppName); see INSTALL.txt.

Programs (revision in LionDev 177, built from the imported LionSources, rebuilt for the 177a runtime):
$(($programs | ForEach-Object { "  $_  rev $($vers[$_])" }) -join "`r`n")

LionSource imported into LionDev 177 (what the programs were generated from, LionDev application $($ge.LionApp)):
$($imp -join "`r`n")
$(if ($Proof) { "`r`nControl Center proof of this build in $($tgt.AppName):`r`n" + (($Proof | ForEach-Object { "  $_" }) -join "`r`n") + "`r`n" })
Control Center regression of the same COBOL$(if ($ownApp) { ' (earlier AFBUS_2200COBOL build in CC-Trial, not this build)' } else { " ($Environment)" }), result of the last run of each job:
$(($regStatus | ForEach-Object { "  $($_.Time)  $($_.State)  $($_.Key)" }) -join "`r`n")

Not included: the test jobs (ASSURFED_F999\RUN\SSG4_*), their data, and the reference programs (*_RA, *_RB, *_RD, *_RV).
"@ | Set-Content "$pkg\RELEASE-NOTES.txt"
    @"
Install into $($tgt.AppName) (verify every file against manifest.csv first). Steps marked CONFIRM depend on answers from R&D.
1. Programs: copy Binaries\Programs\*.dll to $tp
$(if ($ownApp) { "2. Application DLLs: none. The programs were generated for $($tgt.AppName) (LionDev application $($tgt.LionApp)) and use its own $($tgt.LionApp).Application/Database." } else { "2. Application DLLs (Binaries\Application): copy only if $($tgt.AppBasepath)\Application lacks them or they differ (CONFIRM which application DLL set FEDERALE_APP uses)." })
3. Skeletons and includes -- REPLACES R&D FILES, CONFIRM WITH R&D FIRST.

   The converted runstreams call each skeleton by a fixed relative path, e.g.
       Invoke-Ssg -Skeleton "../../ASSURFED_UTILIT/UTILIT_CFH-COPY_ASCII"
   i.e. the folder ASSURFED_UTILIT of the script set (beside ASSURFED_F999, Libraries and Settings). Today that folder holds
   R&D's converted skeletons; for these 12 utilities they are 4-line failed-conversion stubs ("# ERROR: Conversion failed"),
   so steps calling them do not work today. Ours have the same names and the full converted skeleton, with the hand-off inserted
   right after param() and followed by return, so the step's Xqt starts the generic program. To use them they must be at that path under those names:
     a. back up R&D's ASSURFED_UTILIT folder;
     b. copy Scripts\ASSURFED_UTILIT\* from this package into it: $($skel.Count) skeletons (those R&D has are overwritten;
        R&D has no UTILIT_CHAB100_ASCII.ps1, MT-045) and $($inc.Count) .inc files (new);
     c. roll back = restore the backup.
   The alternative (pointing ~2,800 runstreams elsewhere) is not proposed.

4. Settings (the script set's Settings\AmtSettings.xml, which the runstreams load as ..\..\Settings\AmtSettings.xml; CONFIRM with R&D):
   AppName must be $($tgt.AppName); UseUnicode False (T3-039: True makes Asy-Cat pre-create UTF-16 files; this affects every job using
   that settings file); add the child elements of CloneReports.xml under <Amt> (Xqt name -> generic program; MT-044, CONFIRM the
   element name OrginalReport).
5. Check: run one real runstream that calls a converted utility; the job log shows the hand-off lines and the program's own output.
6. Jobs: after "Read all jobs from system" Start Job also lists the ASSURFED_UTILIT_*_GN programs and the UTILIT_* skeletons. They are started only by a
   calling parent (a converted runstream: Invoke-Ssg runs the skeleton, its Xqt starts the program). Ideally leave them unactivated in Security > Jobs;
   if the application is switched on with Activate All they are startable, and started by hand they have no parameter file or cards (untested).
Roll back: restore R&D's ASSURFED_UTILIT folder and the settings file from your backup and delete the ASSURFED_UTILIT_*_GN.dll files.
"@ | Set-Content "$pkg\INSTALL.txt"
    $mf = Get-ChildItem $pkg -Recurse -File | ForEach-Object { [pscustomobject]@{ Path = $_.FullName.Substring($pkg.Length + 1); Bytes = $_.Length; Sha256 = (Get-FileHash $_.FullName).Hash } }
    $mf | Export-Csv "$pkg\manifest.csv" -NoTypeInformation -Encoding utf8
    $bad = @($mf | Where-Object { (Get-FileHash "$pkg\$($_.Path)").Hash -ne $_.Sha256 })
    Add-Row 'Package' 'manifest' (-not $bad) "$($mf.Count) files, $([Math]::Round(($mf | Measure-Object Bytes -Sum).Sum / 1KB)) KB, SHA256 re-checked"
    Add-Row 'Package' 'staged (local only)' $true $pkg
  }
}

$failed = @($rows | Where-Object Result -eq 'FAIL').Count
$report = @("Stage $Stage, environment $Environment, started $($started.ToString('yyyy-MM-dd HH:mm:ss'))") + @($rows | ForEach-Object { '{0,-4} {1,-14} {2,-30} {3}' -f $_.Result, $_.Item, $_.Check, $_.Detail }) + "=== $Stage : $(if ($failed) { "$failed failure(s)" } else { 'all passed' })"
$reportFile = "$($ge.GenericWork)\pipeline-$($Stage.ToLower())-$($started.ToString('yyyyMMdd-HHmmss')).txt"
$report | Set-Content $reportFile
$report
"report: $reportFile"
exit $failed
